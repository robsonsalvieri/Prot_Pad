Create procedure CTB301A_##
 ( 
  @IN_FILIAL       Char('CT2_FILIAL'),
  @IN_DATAINI      Char(08),
  @IN_DATAFIM      Char(08),
  @IN_LCOPIA       Char(01),
  @IN_TPSORIG      Char('CT2_TPSALD'),
  @IN_TPSDEST      Char(20),
  @IN_LTDSMOEDA    Char(01),
  @IN_MOEDA        Char('CT2_MOEDLC'),
  @IN_SLDFILA      Char(01),
  @IN_ATUSLD       Char(01),
  @IN_TRANSACTION  Char(01),
  @OUT_RESULTADO   Char(01) OutPut
 )
as

declare @iMaxRecno   integer
declare @iMinRecno   integer
declare @iRecnoCT2   integer
declare @iRecnoTRW   integer
declare @cCT2_FILIAL Char('CT2_FILIAL')
declare @cCT2_DATA   Char('CT2_DATA')
declare @cCT2_LOTE   Char('CT2_LOTE')
declare @cCT2_SBLOTE Char('CT2_SBLOTE')
declare @cCT2_DOC    Char('CT2_DOC')
declare @cCT2_MOEDLC Char('CT2_MOEDLC')  
declare @cCT2_TPSALD Char('CT2_TPSALD')
declare @cCT2_DC     Char('CT2_DC')
declare @cCT2_DEBITO Char('CT2_DEBITO')
declare @cCT2_CREDIT Char('CT2_CREDIT')
declare @nCT2_VALOR  Char('CT2_VALOR')
declare @cCT2_CCD    Char('CT2_CCD')
declare @cCT2_CCC    Char('CT2_CCC')
declare @cCT2_ITEMD  Char('CT2_ITEMD')
declare @cCT2_ITEMC  Char('CT2_ITEMC')
declare @cCT2_CLVLDB Char('CT2_CLVLDB')
declare @cCT2_CLVLCR Char('CT2_CLVLCR')
declare @cCT2_EMPORI Char('CT2_EMPORI')
declare @cCT2_FILORI Char('CT2_FILORI')
declare @cCT2_LINHA  Char('CT2_LINHA')
declare @cCT2_ATIVDE Char('CT2_ATIVDE')
declare @cCT2_SEQIDX Char('CT2_SEQIDX')
##FIELDP15( 'CT2.CT2_EC05DB' )
declare @cCT2_EC05DB Char('CT2_EC05DB')
declare @cCT2_EC05CR Char('CT2_EC05CR')
##ENDFIELDP15
##FIELDP16( 'CT2.CT2_EC06DB' )
declare @cCT2_EC06DB Char('CT2_EC06DB')
declare @cCT2_EC06CR Char('CT2_EC06CR')
##ENDFIELDP16
##FIELDP17( 'CT2.CT2_EC07DB' )
declare @cCT2_EC07DB Char('CT2_EC07DB')
declare @cCT2_EC07CR Char('CT2_EC07CR')
##ENDFIELDP17
##FIELDP18( 'CT2.CT2_EC08DB' )
declare @cCT2_EC08DB Char('CT2_EC08DB')
declare @cCT2_EC08CR Char('CT2_EC08CR')
##ENDFIELDP18
##FIELDP19( 'CT2.CT2_EC09DB' )
declare @cCT2_EC09DB Char('CT2_EC09DB')
declare @cCT2_EC09CR Char('CT2_EC09CR')
##ENDFIELDP19
begin  

   DECLARE CUR_CT2 insensitive  CURSOR FOR 
   SELECT 
      CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_MOEDLC, CT2_TPSALD, CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_VALOR,  
      CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_EMPORI, CT2_FILORI, CT2_LINHA, CT2_ATIVDE, CT2_SEQIDX
      ##FIELDP08( 'CT2.CT2_EC05DB' )
      ,CT2_EC05DB , CT2_EC05CR 
      ##ENDFIELDP08
      ##FIELDP09( 'CT2.CT2_EC06DB' )
      ,CT2_EC06DB , CT2_EC06CR
      ##ENDFIELDP09
      ##FIELDP10( 'CT2.CT2_EC07DB' )
      ,CT2_EC07DB , CT2_EC07CR 
      ##ENDFIELDP10
      ##FIELDP11( 'CT2.CT2_EC08DB' )
      ,CT2_EC08DB , CT2_EC08CR  
      ##ENDFIELDP11
      ##FIELDP12( 'CT2.CT2_EC09DB' )
      ,CT2_EC09DB , CT2_EC09CR 
      ##ENDFIELDP12         
      , R_E_C_N_O_
      FROM 
         CT2### 
         WHERE 
            CT2_FILIAL = @IN_FILIAL and
            CT2_DATA  between @IN_DATAINI and @IN_DATAFIM and 
            ((@IN_LTDSMOEDA = '1') or (@IN_LTDSMOEDA = '0' and CT2_MOEDLC = @IN_MOEDA)) and
            CT2_TPSALD <> @IN_TPSORIG and
            CT2_CTLSLD <> '0' and
            D_E_L_E_T_ = ' '          
   FOR READ ONLY 
   

   OPEN CUR_CT2
   FETCH CUR_CT2 
   INTO @cCT2_FILIAL, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_MOEDLC, @cCT2_TPSALD, @cCT2_DC, @cCT2_DEBITO, @cCT2_CREDIT, @nCT2_VALOR, 
         @cCT2_CCD, @cCT2_CCC, @cCT2_ITEMD, @cCT2_ITEMC, @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_EMPORI, @cCT2_FILORI, @cCT2_LINHA, @cCT2_ATIVDE, @cCT2_SEQIDX             
         ##FIELDP15( 'CT2.CT2_EC05DB' )
         ,@cCT2_EC05DB , @cCT2_EC05CR
         ##ENDFIELDP15
         ##FIELDP16( 'CT2.CT2_EC06DB' )
         ,@cCT2_EC06DB , @cCT2_EC06CR
         ##ENDFIELDP16
         ##FIELDP17( 'CT2.CT2_EC07DB' )
         ,@cCT2_EC07DB , @cCT2_EC07CR
         ##ENDFIELDP17
         ##FIELDP18( 'CT2.CT2_EC08DB' )
         ,@cCT2_EC08DB , @cCT2_EC08CR
         ##ENDFIELDP18
         ##FIELDP19( 'CT2.CT2_EC09DB' )
         ,@cCT2_EC09DB , @cCT2_EC09CR
         ##ENDFIELDP19           
         ,@iRecnoCT2

   WHILE (@@fetch_status = 0 ) begin
      --Se o saldo do registro está contido na lista de saldo destino, posso apagar
      if @IN_TPSDEST LIKE '%'||@cCT2_TPSALD||'%' begin
         if @IN_SLDFILA = '1' and @IN_ATUSLD = '1' begin
            --uniquekey
            ##UNIQUEKEY_START
               SELECT @iRecnoTRW = COALESCE(Min(R_E_C_N_O_), 0)
               FROM TRW###
               WHERE CT2_FILIAL = @cCT2_FILIAL
               AND CT2_DATA   = @cCT2_DATA
               AND CT2_LOTE   = @cCT2_LOTE
               AND CT2_SBLOTE = @cCT2_SBLOTE
               AND CT2_DOC    = @cCT2_DOC
               AND CT2_LINHA  = @cCT2_LINHA
               AND CT2_EMPORI = @cCT2_EMPORI
               AND CT2_FILORI = @cCT2_FILORI
               AND CT2_MOEDLC = @cCT2_MOEDLC
               AND CT2_SEQIDX = @cCT2_SEQIDX
               AND D_E_L_E_T_ = ' ' 
            ##UNIQUEKEY_END

            IF @iRecnoTRW = 0 BEGIN               

               SELECT @iRecnoTRW  = COALESCE(MAX( R_E_C_N_O_ ), 0 )
               FROM TRW### 
               SELECT @iRecnoTRW  = @iRecnoTRW  + 1 
               
               --tratarecno
               ##TRATARECNO @iRecnoTRW\
               ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\            
                  insert into TRW### ( CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_MOEDLC, CT2_TPSALD, CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_VALOR,  
                                       CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_EMPORI, CT2_FILORI, CT2_LINHA, CT2_ATIVDE, CT2_SEQIDX
                                       ##FIELDP08( 'CT2.CT2_EC05DB' )
                                       ,CT2_EC05DB , CT2_EC05CR 
                                       ##ENDFIELDP08
                                       ##FIELDP09( 'CT2.CT2_EC06DB' )
                                       ,CT2_EC06DB , CT2_EC06CR
                                       ##ENDFIELDP09
                                       ##FIELDP10( 'CT2.CT2_EC07DB' )
                                       ,CT2_EC07DB , CT2_EC07CR 
                                       ##ENDFIELDP10
                                       ##FIELDP11( 'CT2.CT2_EC08DB' )
                                       ,CT2_EC08DB , CT2_EC08CR  
                                       ##ENDFIELDP11
                                       ##FIELDP12( 'CT2.CT2_EC09DB' )
                                       ,CT2_EC09DB , CT2_EC09CR 
                                       ##ENDFIELDP12                                      
                                       , R_E_C_N_O_)
                  values( @cCT2_FILIAL, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_MOEDLC, @cCT2_TPSALD, @cCT2_DC, @cCT2_DEBITO, @cCT2_CREDIT, 0, 
                           @cCT2_CCD, @cCT2_CCC, @cCT2_ITEMD, @cCT2_ITEMC, @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_EMPORI, @cCT2_FILORI, @cCT2_LINHA, @cCT2_ATIVDE, @cCT2_SEQIDX             
                           ##FIELDP15( 'CT2.CT2_EC05DB' )
                           ,@cCT2_EC05DB , @cCT2_EC05CR
                           ##ENDFIELDP15
                           ##FIELDP16( 'CT2.CT2_EC06DB' )
                           ,@cCT2_EC06DB , @cCT2_EC06CR
                           ##ENDFIELDP16
                           ##FIELDP17( 'CT2.CT2_EC07DB' )
                           ,@cCT2_EC07DB , @cCT2_EC07CR
                           ##ENDFIELDP17
                           ##FIELDP18( 'CT2.CT2_EC08DB' )
                           ,@cCT2_EC08DB , @cCT2_EC08CR
                           ##ENDFIELDP18
                           ##FIELDP19( 'CT2.CT2_EC09DB' )
                           ,@cCT2_EC09DB , @cCT2_EC09CR
                           ##ENDFIELDP19                          
                           ,@iRecnoTRW )
               ##CHECK_TRANSACTION_COMMIT
               ##FIMTRATARECNO 
            End
            
            --update
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
               UPDATE TRW###
               SET CT2_VALOR = CT2_VALOR + @nCT2_VALOR                  
               WHERE R_E_C_N_O_ = @iRecnoTRW
            ##CHECK_TRANSACTION_COMMIT
         End

         --Após gravar a deleção dos saldos, posso excluir a CT2
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\            
            delete from CT2### where R_E_C_N_O_ = @iRecnoCT2
         ##CHECK_TRANSACTION_COMMIT
      End            

      FETCH CUR_CT2 
      INTO @cCT2_FILIAL, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_MOEDLC, @cCT2_TPSALD, @cCT2_DC, @cCT2_DEBITO, @cCT2_CREDIT, @nCT2_VALOR, 
            @cCT2_CCD, @cCT2_CCC, @cCT2_ITEMD, @cCT2_ITEMC, @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_EMPORI, @cCT2_FILORI, @cCT2_LINHA, @cCT2_ATIVDE, @cCT2_SEQIDX             
            ##FIELDP15( 'CT2.CT2_EC05DB' )
            ,@cCT2_EC05DB , @cCT2_EC05CR
            ##ENDFIELDP15
            ##FIELDP16( 'CT2.CT2_EC06DB' )
            ,@cCT2_EC06DB , @cCT2_EC06CR
            ##ENDFIELDP16
            ##FIELDP17( 'CT2.CT2_EC07DB' )
            ,@cCT2_EC07DB , @cCT2_EC07CR
            ##ENDFIELDP17
            ##FIELDP18( 'CT2.CT2_EC08DB' )
            ,@cCT2_EC08DB , @cCT2_EC08CR
            ##ENDFIELDP18
            ##FIELDP19( 'CT2.CT2_EC09DB' )
            ,@cCT2_EC09DB , @cCT2_EC09CR
            ##ENDFIELDP19             
            ,@iRecnoCT2 
   End
   close CUR_CT2
   deallocate CUR_CT2


   select @OUT_RESULTADO = '1'
end
