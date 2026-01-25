Create procedure CTB301B_##
 ( 
  @IN_FILIAL       Char('CT2_FILIAL'),
  @IN_DATA         Char(08),
  @IN_LOTE         Char('CT2_LOTE'),
  @IN_SBLOTE       Char('CT2_SBLOTE'),
  @IN_DOC          Char('CT2_DOC'),
  @IN_LINHA        Char('CT2_LINHA'),
  @IN_MOEDLC       Char('CT2_MOEDLC'),
  @IN_EMPORI       Char('CT2_EMPORI'),
  @IN_FILORI       Char('CT2_FILORI'),  
  @IN_TPSALD       Char('CT2_TPSALD'),  
  @IN_TRANSACTION  Char(01),
  @OUT_RESULTADO   Char(01) OutPut
 )
as

declare @iRecnoCQA   integer
declare @cFilial_CQA char('CQA_FILIAL')

begin
   EXEC XFILIAL_## 'CQA', @IN_FILIAL, @cFilial_CQA output 

   --uniquekey
   ##UNIQUEKEY_START
      SELECT 
         @iRecnoCQA = COALESCE(Min(R_E_C_N_O_), 0)
         FROM 
            CQA###
            WHERE 
               CQA_FILIAL = @cFilial_CQA AND
               CQA_FILCT2 = @IN_FILIAL AND
               CQA_DATA   = @IN_DATA AND
               CQA_LOTE   = @IN_LOTE AND
               CQA_SBLOTE = @IN_SBLOTE AND
               CQA_DOC    = @IN_DOC AND
               CQA_LINHA  = @IN_LINHA AND
               CQA_TPSALD = @IN_TPSALD AND
               CQA_EMPORI = @IN_EMPORI AND
               CQA_FILORI = @IN_FILORI AND
               CQA_MOEDLC = @IN_MOEDLC AND
               D_E_L_E_T_ = ' ' 
   ##UNIQUEKEY_END

   If @iRecnoCQA = 0 begin
      SELECT @iRecnoCQA  = COALESCE(MAX( R_E_C_N_O_ ), 0 ) FROM CQA### 
      SELECT @iRecnoCQA  = @iRecnoCQA  + 1 
      
      ##TRATARECNO @iRecnoCQA\
      ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
      insert into CQA### (CQA_FILIAL, CQA_FILCT2, CQA_DATA, CQA_LOTE, CQA_SBLOTE, CQA_DOC, CQA_LINHA, CQA_MOEDLC, CQA_EMPORI, CQA_FILORI, CQA_TPSALD, R_E_C_N_O_ )
                  values (@cFilial_CQA, @IN_FILIAL, @IN_DATA, @IN_LOTE, @IN_SBLOTE, @IN_DOC, @IN_LINHA, @IN_MOEDLC, @IN_EMPORI, @IN_FILORI, @IN_TPSALD, @iRecnoCQA )
      ##CHECK_TRANSACTION_COMMIT
      ##FIMTRATARECNO
   End

   select @OUT_RESULTADO = '1'
end
