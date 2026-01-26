Create Procedure CTB233_## (
   @IN_FILIAL  char( 'CTC_FILIAL' ),
   @IN_DATA    Char( 08 ),
   @IN_LOTE    Char( 'CTC_LOTE' ),
   @IN_SBLOTE  Char( 'CTC_SBLOTE' ),
   @IN_DOC     Char( 'CTC_DOC' ),
   @IN_MOEDA   Char( 'CTC_MOEDA' ),
   @IN_TPSALDO Char( 01 ),
   @IN_DC      Char( 01 ),
   @IN_SINAL   Char( 01 ),
   @IN_MVSOMA  Char( 01 ),
   @IN_VALOR   FLOAT,
   @OUT_RESULT Char( 01 ) OutPut
   
)
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ctbxatu.prx </s>
    Descricao       - <d>  Atualizacao de Saldos na Exlusao do Lote  </d>
    Entrada         - <ri> @IN_FILIAL       - Filial onde a manutencao sera feita
                           @IN_DATA         - Data do Lote
                           @IN_LOTE         - Nro do Lote a ser alterado ou excluido
                           @IN_SBLOTE       - Nro do Sublote a ser alterado ou excluido
                           @IN_DOC          - Nro do Documento a ser alterado ou excluido
                           @IN_MOEDA        - Moeda a Atualizar
                           @IN_TPSALDO      - Tipo de saldo a atualizar
                           @IN_DC           - '1' Debito, '2' Credito, '3' Partida dobrada
                           @IN_SINAL        - '-' se for se chamado na exclusão, '+' na inclusão
                           @IN_MVSOMA       -  '1' soma uma vez ,'2' soma duas vezes
                           @IN_VALOR        - valor a somar
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Data        :     24/03/2014
--------------------------------------------------------------------------------------------------------------------- */

as 
Declare @cAux         Char( 03 )
Declare @cFilial_CTC  Char( 'CTC_FILIAL' )
Declare @iRecno       Integer
Declare @iRecnoCTC    Integer
Declare @nValor       Float
Declare @nCTC_DEBITOX Float
Declare @nCTC_CREDITX Float
Declare @nCTC_DIGX    Float
Declare @nCTC_DIG     Float
Declare @nCTC_DEBITO  Float
Declare @nCTC_CREDIT  Float
Declare @nCTC_INF     Float

Begin
   Select @OUT_RESULT = '0'
   select @cAux = 'CTC'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CTC OutPut
   
   If @IN_SINAL = '-' begin
      select @nValor = Round( @IN_VALOR * (-1) , 2)
   End Else begin
   select @nValor = Round( @IN_VALOR,2 )
   End
   
   Select @nCTC_DEBITOX = 0
   Select @nCTC_CREDITX = 0
   Select @nCTC_DIGX    = 0
   select @nCTC_DIG     = 0
   select @nCTC_DEBITO  = 0
   select @nCTC_CREDIT  = 0
   select @nCTC_INF     = 0
   
   Select @iRecnoCTC = IsNull( MIN(R_E_C_N_O_),0 )
     From CTC###
    Where CTC_FILIAL = @cFilial_CTC
      and CTC_DATA   = @IN_DATA
      and CTC_LOTE   = @IN_LOTE
      and CTC_SBLOTE = @IN_SBLOTE
      and CTC_DOC    = @IN_DOC
      and CTC_MOEDA  = @IN_MOEDA
      and CTC_TPSALD = @IN_TPSALDO
      and D_E_L_E_T_ = ' '
   
   If @iRecnoCTC = 0 begin
      /* --------------------------------------------------------------------------
         Recupera o R_E_C_N_O_ para ser gravado
         -------------------------------------------------------------------------- */
      select @iRecno = Max(R_E_C_N_O_) FROM CTC###
      select @iRecno = @iRecno + 1
      
      if (@iRecno is null or @iRecno = 0) begin
		select @iRecno = 1
	  end
      
      if @IN_DC IN ('1','3') begin
         select @nCTC_DEBITOX = @nValor
      end
      
      if @IN_DC IN ('2','3') begin
         select @nCTC_CREDITX = @nValor
      end
      
      If @IN_DC = '3' begin
         If @IN_MVSOMA = '1' begin
			Select @nCTC_DIGX = @nValor
         end else begin
			Select @nCTC_DIGX = ( 2 * @nValor )
		 end
      
      end else begin
		Select @nCTC_DIGX = @nValor
      end
      
   end else begin
      
      Select @nCTC_DIG = CTC_DIG, @nCTC_DEBITO = CTC_DEBITO, @nCTC_CREDIT = CTC_CREDIT, @nCTC_INF = CTC_INF
        From CTC###
       Where R_E_C_N_O_ = @iRecnoCTC
      
      if @IN_DC = '1' begin
         select @nCTC_DEBITOX = @nCTC_DEBITO + @nValor
         select @nCTC_CREDITX = @nCTC_CREDIT
      end
      if @IN_DC ='2' begin
         select @nCTC_CREDITX = @nCTC_CREDIT + @nValor
         select @nCTC_DEBITOX = @nCTC_DEBITO
      end
      If @IN_DC = '3' begin
         select @nCTC_DEBITOX = @nCTC_DEBITO + @nValor
         select @nCTC_CREDITX = @nCTC_CREDIT + @nValor
         
         If @IN_MVSOMA = '1' begin 
			Select @nCTC_DIGX = @nCTC_DIG + @nValor
         end else begin 
			Select @nCTC_DIGX  = @nCTC_DIG + ( 2 * @nValor )
		 end
         
      end else begin
		Select @nCTC_DIGX = @nCTC_DIG + @nValor
	  end
      
   end
   /*---------------------------------------------------------------
     Insercao / Atualizacao CTC
   --------------------------------------------------------------- */
   If @iRecnoCTC = 0 begin
      ##TRATARECNO @iRecno\
      begin Tran
      Insert into CTC###( CTC_FILIAL,   CTC_MOEDA, CTC_TPSALD,  CTC_DATA, CTC_LOTE, CTC_SBLOTE, CTC_DOC, CTC_STATUS, CTC_DEBITO,    CTC_CREDIT,    CTC_DIG,    R_E_C_N_O_ )
                  values( @cFilial_CTC, @IN_MOEDA, @IN_TPSALDO, @IN_DATA, @IN_LOTE, @IN_SBLOTE, @IN_DOC,  '1',       @nCTC_DEBITOX, @nCTC_CREDITX, @nCTC_DIGX, @iRecno  )
      commit Tran
      ##FIMTRATARECNO
   end else begin
      begin Tran
      Update CTC###
         Set CTC_DEBITO = @nCTC_DEBITOX, CTC_CREDIT = @nCTC_CREDITX, CTC_DIG = @nCTC_DIGX
       Where R_E_C_N_O_ = @iRecnoCTC
      commit Tran
   End
   Select @OUT_RESULT = '1'
End
