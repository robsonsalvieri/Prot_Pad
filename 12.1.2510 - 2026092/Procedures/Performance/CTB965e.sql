##IF_999({|| AliasInDic('QLJ') })
Create procedure CTB965E_## 
 ( 
  @IN_FILIAL       Char('CT2_FILIAL'),
  @IN_DATADE       Char(08),
  @IN_DATAATE      Char(08),
  @IN_LMOEDAESP    Char(01),
  @IN_MOEDA        Char('CT2_MOEDLC'),  
  @IN_UUID         Char(36),
  @IN_LMULTIFIL    Char(01),
  @IN_TRANSACTION  Char(01),
  @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versao          - <v> Protheus P12 </v>    
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Zera os arquivos a serem posteriormente reprocessados </d>
    Fonte Microsiga - <s> CTBA190.PRW </s>
    Entrada         - <ri> @IN_DATADE       - Data inicio para correcao
                           @IN_DATAATE      - Data final para correcao
                           @IN_LMOEDAESP    - Data final para correcao
                           @IN_MOEDA        - Moeda especifica                          
                           @IN_UUID         - Chave para pesquisa na tabela TRZ
                           @IN_TRANSACTION  - '1' se em transacao - '0' -fora de transacao  </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Data        :     08/11/2023
-------------------------------------------------------------------------------------- */
declare @iRecno      Integer
declare @fim_CUR     Integer
declare @macro       Integer
declare @cCT2_FILIAL CHAR('CT2_FILIAL')
declare @cCT2_DATA   CHAR('CT2_DATA')
declare @cCT2_LOTE   CHAR('CT2_LOTE')
declare @cCT2_SBLOTE CHAR('CT2_SBLOTE')
declare @cCT2_DOC    CHAR('CT2_DOC')
declare @cCT2_MOEDLC CHAR('CT2_MOEDLC')
declare @cCT2_TPSALD CHAR('CT2_TPSALD')
declare @nMOV_DB     Float
declare @nMOV_CR     Float
declare @nMOV_DG     Float
declare @nSLD_DB     Float
declare @nSLD_CR     Float
declare @nSLD_DG     Float

begin   
       
   select @OUT_RESULTADO = '0'
/*---------------------------------------------------------------
      Apaga registros CTC sem movimento na CT2
   ----------------------------------------------------------------*/
   Declare CUR_CTCDEL insensitive cursor for   
   SELECT 
      CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_MOEDLC, CT2_TPSALD,
      SUM(MOV_DB) MOV_DB, SLD_DB,
      SUM(MOV_CR) MOV_CR, SLD_CR,
      SUM(MOV_DG) MOV_DG, SLD_DG
   FROM (
      SELECT 
         CT2_FILIAL, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_DATA, CT2_MOEDLC, CT2_TPSALD,
         _MOV_DB,
         CTC_DEBITO SLD_DB,
         _MOV_CR,
         CTC_CREDIT SLD_CR,
         _MOV_DG,
         CTC_DIG SLD_DG
      FROM CT2TRB
   ) TBLTRB   
   GROUP BY CT2_FILIAL, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_DATA, CT2_MOEDLC, CT2_TPSALD, SLD_DB, SLD_CR, SLD_DG
   HAVING ROUND(SUM(MOV_DB),2) <> ROUND(SLD_DB,2) OR 
         ROUND(SUM(MOV_CR),2) <> ROUND(SLD_CR,2) OR 
         ROUND(SUM(MOV_DG),2) <> ROUND(SLD_DG,2) 
   ORDER BY 1, 2, 3, 4, 5, 6, 7
   for read only
   Open CUR_CTCDEL
   Fetch CUR_CTCDEL into @cCT2_FILIAL, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_MOEDLC, @cCT2_TPSALD, 
                        @nMOV_DB, @nSLD_DB, @nMOV_CR, @nSLD_CR, @nMOV_DG, @nSLD_DG

   While (@@Fetch_status = 0 ) begin     

      /* ---------------------------------------------------------------
      As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
      houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
      após a MsParse() devolver o código na linguagem do banco em uso.
      -------------------------------------------------------------------------------------------------------------- */
      select @iRecno  = 0
      ##UNIQUEKEY_START
         Select @iRecno = IsNull( MIN(R_E_C_N_O_),0 )
         From CTC###
         Where CTC_FILIAL  = @cCT2_FILIAL
            and CTC_DATA   = @cCT2_DATA
            and CTC_LOTE   = @cCT2_LOTE
            and CTC_SBLOTE = @cCT2_SBLOTE
            and CTC_DOC    = @cCT2_DOC
            and CTC_MOEDA  = @cCT2_MOEDLC
            and CTC_TPSALD = @cCT2_TPSALD
            and D_E_L_E_T_ = ' '
      ##UNIQUEKEY_END
                  
      If @iRecno = 0 begin
         /* --------------------------------------------------------------------------
         Recupera o R_E_C_N_O_ para ser gravado
         -------------------------------------------------------------------------- */
         select @iRecno = Isnull(MAX(R_E_C_N_O_), 0) FROM CTC###
         select @iRecno = @iRecno + 1
         /*---------------------------------------------------------------
         Insercao / Atualizacao CTC
         --------------------------------------------------------------- */
         ##TRATARECNO @iRecno\
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Insert into CTC### ( CTC_FILIAL, CTC_MOEDA,  CTC_TPSALD,  CTC_DATA,   CTC_LOTE,  CTC_SBLOTE, CTC_DOC,   CTC_STATUS, CTC_DEBITO, CTC_CREDIT, CTC_DIG, R_E_C_N_O_ )
                        values( @cCT2_FILIAL, @cCT2_MOEDLC, @cCT2_TPSALD, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC,   '1',          0,          0,       0, @iRecno  )
      
         ##CHECK_TRANSACTION_COMMIT
         ##FIMTRATARECNO
      end
      
      ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         Update CTC###
         Set CTC_DEBITO = @nMOV_DB, CTC_CREDIT = @nMOV_CR, CTC_DIG = @nMOV_DG
         Where R_E_C_N_O_ = @iRecno
      ##CHECK_TRANSACTION_COMMIT
   
      /*Tratamento para Postgres*/
      SELECT @fim_CUR = 0
      Fetch CUR_CTCDEL into @cCT2_FILIAL, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_MOEDLC, @cCT2_TPSALD,
                           @nMOV_DB, @nSLD_DB, @nMOV_CR, @nSLD_CR, @nMOV_DG, @nSLD_DG
   end
   close CUR_CTCDEL
   deallocate CUR_CTCDEL  

   select @OUT_RESULTADO = '1'
end
##ENDIF_999