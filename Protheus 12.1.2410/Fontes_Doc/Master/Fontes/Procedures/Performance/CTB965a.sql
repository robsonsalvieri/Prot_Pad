##IF_999({|| AliasInDic('QLJ') })
Create procedure CTB965A_## 
 ( 
  @IN_FILIAL       Char('CT2_FILIAL'),
  @IN_DATADE       Char(08),
  @IN_DATAATE      Char(08),
  @IN_LMOEDAESP    Char(01),
  @IN_MOEDA        Char('CT2_MOEDLC'),
  @IN_TPSALDO      Char('CT2_TPSALD'),
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
                           @IN_TPSALDO      - Tipo de saldo                           
                           @IN_UUID         - Chave para pesquisa na tabela TRZ
                           @IN_TRANSACTION  - '1' se em transacao - '0' -fora de transacao  </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Data        :     08/11/2023
-------------------------------------------------------------------------------------- */
declare @nRecno    Integer
declare @nRecAux   Integer
declare @fim_CUR   Integer
declare @cTipo     Char(1)
declare @nSaldo    Float
declare @nValCur   Float
declare @cFilCur   Char('CQ1_FILIAL')
declare @cDatCur   Char(08)
declare @cDatMes   Char(08)
declare @cContaCur Char('CQ1_CONTA')
declare @cCustoCur Char('CQ3_CCUSTO')
declare @cItemCur  Char('CQ5_ITEM')
declare @cCLVLCur  Char('CQ7_CLVL')
declare @cMoedCur  Char('CQ1_MOEDA')
declare @cTpSldCur Char('CQ1_TPSALD')
declare @cLP       Char(1)

begin   
       
   select @OUT_RESULTADO = '0'   


   /*---------------------------------------------------------------
      Apaga registros CTC sem movimento na CT2
   ----------------------------------------------------------------*/
   Declare CUR_CTCDEL insensitive cursor for
   SELECT 
      CTC.R_E_C_N_O_
      FROM 
         CTC### CTC
         LEFT JOIN 
            CT2### CT2
            ON
               CTC_FILIAL = CT2_FILIAL AND
               CTC_DATA   = CT2_DATA AND
               CTC_LOTE   = CT2_LOTE AND 
               CTC_SBLOTE = CT2_SBLOTE AND
               CTC_DOC    = CT2_DOC AND
               CTC_MOEDA  = CT2_MOEDLC AND
               CTC_TPSALD = CT2_TPSALD AND				  
               CT2.D_E_L_E_T_ = ' '
         WHERE        
            ((@IN_LMULTIFIL = '0' AND CTC_FILIAL = @IN_FILIAL) OR (CTC_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND   
            CTC_DATA BETWEEN @IN_DATADE and @IN_DATAATE AND            
            ((CTC_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
            CT2_FILIAL IS NULL AND
            CTC.D_E_L_E_T_ = ' '     
   Order by 1
   for read only
   Open CUR_CTCDEL
   Fetch CUR_CTCDEL into @nRecno

   While (@@Fetch_status = 0 ) begin     
      
      ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         DELETE FROM CTC### WHERE R_E_C_N_O_ = @nRecno 
      ##CHECK_TRANSACTION_COMMIT           
   
      /*Tratamento para Postgres*/
      SELECT @fim_CUR = 0
      Fetch CUR_CTCDEL into @nRecno
   end
   close CUR_CTCDEL
   deallocate CUR_CTCDEL  

   /*---------------------------------------------------------------
      Apaga registros CQ1 sem movimento na CT2
   ----------------------------------------------------------------*/
   Declare CUR_CQ1DEL insensitive cursor for
   SELECT 
      CQ1_FILIAL, CQ1_DATA, CQ1_CONTA, CQ1_MOEDA, CQ1_TPSALD, CQ1_LP, CQ1_DEBITO, CQ1.R_E_C_N_O_, '1' AS TIPO
      FROM 
            CQ1### CQ1
            LEFT JOIN 
               CT2### CT2
               ON
                  CT2_FILIAL = CQ1_FILIAL AND
                  CT2_DATA   = CQ1_DATA AND
                  CT2_DEBITO = CQ1_CONTA AND
                  CT2_MOEDLC = CQ1_MOEDA AND 
                  CT2_TPSALD = CQ1_TPSALD AND
                  CT2.D_E_L_E_T_ = ' '

            WHERE 
               ((@IN_LMULTIFIL = '0' AND CQ1_FILIAL = @IN_FILIAL) OR (CQ1_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND   
               CQ1_DATA BETWEEN @IN_DATADE and @IN_DATAATE AND
               CQ1_DEBITO <> 0 AND
               ((CQ1_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
               ((@IN_TPSALDO = '*' AND CQ1_TPSALD <> '9') OR CQ1_TPSALD = @IN_TPSALDO) AND
               CT2_FILIAL IS NULL AND
               CQ1.D_E_L_E_T_ = ' '   
   UNION
   SELECT 
      CQ1_FILIAL, CQ1_DATA, CQ1_CONTA, CQ1_MOEDA, CQ1_TPSALD, CQ1_LP, CQ1_CREDIT, CQ1.R_E_C_N_O_, '2' AS TIPO
      FROM 
            CQ1### CQ1
            LEFT JOIN 
               CT2### CT2
               ON
                  CT2_FILIAL = CQ1_FILIAL AND
                  CT2_DATA   = CQ1_DATA AND
                  CT2_CREDIT = CQ1_CONTA AND
                  CT2_MOEDLC = CQ1_MOEDA AND
                  CT2_TPSALD = CQ1_TPSALD AND
                  CT2.D_E_L_E_T_ = ' '
            WHERE 
               ((@IN_LMULTIFIL = '0' AND CQ1_FILIAL = @IN_FILIAL) OR (CQ1_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND   
               CQ1_DATA BETWEEN @IN_DATADE and @IN_DATAATE AND
               CQ1_CREDIT <> 0 AND
               ((CQ1_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
               ((@IN_TPSALDO = '*' AND CQ1_TPSALD <> '9') OR CQ1_TPSALD = @IN_TPSALDO) AND
               CT2_FILIAL IS NULL AND
               CQ1.D_E_L_E_T_ = ' '
   Order by 1, 2, 3, 4, 5, 6, 7, 8, 9
   for read only
   Open CUR_CQ1DEL
   Fetch CUR_CQ1DEL into @cFilCur, @cDatCur, @cContaCur, @cMoedCur, @cTpSldCur, @cLP, @nValCur, @nRecno, @cTipo

   While (@@Fetch_status = 0 ) begin

      exec LASTDAY_## @cDatCur, @cDatMes OutPut
           
      IF @cTipo = '1' Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ1### SET CQ1_DEBITO = 0 WHERE R_E_C_N_O_ = @nRecno
         ##CHECK_TRANSACTION_COMMIT

         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ0### 
         SET CQ0_DEBITO = ROUND(CQ0_DEBITO-@nValCur,2)         
         WHERE CQ0_FILIAL = @cFilCur AND
               CQ0_DATA   = @cDatMes AND
               CQ0_CONTA  = @cContaCur AND
               CQ0_MOEDA  = @cMoedCur AND
               CQ0_TPSALD = @cTpSldCur AND
               CQ0_LP     = @cLP AND
               D_E_L_E_T_ = ' '
         ##CHECK_TRANSACTION_COMMIT
      End Else Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ1### SET CQ1_CREDIT = 0 WHERE R_E_C_N_O_ = @nRecno
         ##CHECK_TRANSACTION_COMMIT

         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ0### 
         SET CQ0_CREDIT = ROUND(CQ0_CREDIT-@nValCur,2)         
         WHERE CQ0_FILIAL = @cFilCur AND
               CQ0_DATA   = @cDatMes AND
               CQ0_CONTA  = @cContaCur AND
               CQ0_MOEDA  = @cMoedCur AND
               CQ0_TPSALD = @cTpSldCur AND
               CQ0_LP     = @cLP AND
               D_E_L_E_T_ = ' '
         ##CHECK_TRANSACTION_COMMIT
      End
      
      select @nSaldo = 0   
      Select @nSaldo = ROUND(CQ1_DEBITO+CQ1_CREDIT,2) From CQ1### WHERE R_E_C_N_O_ = @nRecno
      
      /* Se nao tem valor de debito e nem credito, exclui a linha */
      If @nSaldo = 0 Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         DELETE FROM CQ1### WHERE R_E_C_N_O_ = @nRecno 
         ##CHECK_TRANSACTION_COMMIT     
      End

      select @nSaldo = 0
      select @nRecAux = 0
      Select @nSaldo = ROUND(CQ0_DEBITO+CQ0_CREDIT,2), @nRecAux = R_E_C_N_O_ 
      From CQ0###       
      WHERE CQ0_FILIAL = @cFilCur AND
            CQ0_DATA   = @cDatMes AND
            CQ0_CONTA  = @cContaCur AND
            CQ0_MOEDA  = @cMoedCur AND
            CQ0_TPSALD = @cTpSldCur AND
            CQ0_LP     = @cLP AND
            D_E_L_E_T_ = ' '

      /* Se nao tem valor de debito e nem credito, exclui a linha */
      If @nSaldo = 0 Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         DELETE FROM CQ0### WHERE R_E_C_N_O_ = @nRecAux
         ##CHECK_TRANSACTION_COMMIT     
      End
   
      /*Tratamento para Postgres*/
      SELECT @fim_CUR = 0
      Fetch CUR_CQ1DEL into @cFilCur, @cDatCur, @cContaCur, @cMoedCur, @cTpSldCur, @cLP, @nValCur, @nRecno, @cTipo
   end
   close CUR_CQ1DEL
   deallocate CUR_CQ1DEL        

   /*---------------------------------------------------------------
      Apaga registros CQ3 sem movimento na CT2
   ----------------------------------------------------------------*/
   Declare CUR_CQ3DEL insensitive cursor for
   SELECT 
      CQ3_FILIAL, CQ3_DATA, CQ3_CONTA, CQ3_CCUSTO, CQ3_MOEDA, CQ3_TPSALD, CQ3_LP, CQ3_DEBITO, CQ3.R_E_C_N_O_, '1' AS TIPO
      FROM 
            CQ3### CQ3
            LEFT JOIN 
               CT2### CT2
               ON
                  CT2_FILIAL = CQ3_FILIAL AND
                  CT2_DATA   = CQ3_DATA AND
                  CT2_DEBITO = CQ3_CONTA AND
                  CT2_CCD    = CQ3_CCUSTO AND
                  CT2_MOEDLC = CQ3_MOEDA AND 
                  CT2_TPSALD = CQ3_TPSALD AND
                  CT2.D_E_L_E_T_ = ' '

            WHERE 
               ((@IN_LMULTIFIL = '0' AND CQ3_FILIAL = @IN_FILIAL) OR (CQ3_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND   
               CQ3_DATA BETWEEN @IN_DATADE and @IN_DATAATE AND
               CQ3_DEBITO <> 0 AND
               ((CQ3_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
               ((@IN_TPSALDO = '*' AND CQ3_TPSALD <> '9') OR CQ3_TPSALD = @IN_TPSALDO) AND
               CT2_FILIAL IS NULL AND
               CQ3.D_E_L_E_T_ = ' '
   UNION
   SELECT 
      CQ3_FILIAL, CQ3_DATA, CQ3_CONTA, CQ3_CCUSTO, CQ3_MOEDA, CQ3_TPSALD, CQ3_LP, CQ3_CREDIT, CQ3.R_E_C_N_O_, '2' AS TIPO
      FROM 
            CQ3### CQ3
            LEFT JOIN 
               CT2### CT2
               ON
                  CT2_FILIAL = CQ3_FILIAL AND
                  CT2_DATA   = CQ3_DATA AND
                  CT2_CREDIT = CQ3_CONTA AND
                  CT2_CCC    = CQ3_CCUSTO AND
                  CT2_MOEDLC = CQ3_MOEDA AND
                  CT2_TPSALD = CQ3_TPSALD AND
                  CT2.D_E_L_E_T_ = ' '
            WHERE 
               ((@IN_LMULTIFIL = '0' AND CQ3_FILIAL = @IN_FILIAL) OR (CQ3_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND   
               CQ3_DATA BETWEEN @IN_DATADE and @IN_DATAATE AND
               CQ3_CREDIT <> 0 AND
               ((CQ3_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
               ((@IN_TPSALDO = '*' AND CQ3_TPSALD <> '9') OR CQ3_TPSALD = @IN_TPSALDO) AND
               CT2_FILIAL IS NULL AND
               CQ3.D_E_L_E_T_ = ' '
   Order by 1, 2, 3, 4, 5, 6, 7, 8, 9
   for read only
   Open CUR_CQ3DEL
   Fetch CUR_CQ3DEL into @cFilCur, @cDatCur, @cContaCur, @cCustoCur, @cMoedCur, @cTpSldCur, @cLP, @nValCur, @nRecno, @cTipo

   While (@@Fetch_status = 0 ) begin

      exec LASTDAY_## @cDatCur, @cDatMes OutPut  
     
      IF @cTipo = '1' Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ3### SET CQ3_DEBITO = 0 WHERE R_E_C_N_O_ = @nRecno
         ##CHECK_TRANSACTION_COMMIT

         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ2### 
         SET CQ2_DEBITO = ROUND(CQ2_DEBITO-@nValCur,2)         
         WHERE CQ2_FILIAL = @cFilCur AND
               CQ2_DATA   = @cDatMes AND
               CQ2_CONTA  = @cContaCur AND
               CQ2_CCUSTO = @cCustoCur AND
               CQ2_MOEDA  = @cMoedCur AND
               CQ2_TPSALD = @cTpSldCur AND
               CQ2_LP     = @cLP AND
               D_E_L_E_T_ = ' '
         ##CHECK_TRANSACTION_COMMIT
      End Else Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ3### SET CQ3_CREDIT = 0 WHERE R_E_C_N_O_ = @nRecno
         ##CHECK_TRANSACTION_COMMIT

         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ2### 
         SET CQ2_CREDIT = ROUND(CQ2_CREDIT-@nValCur,2)         
         WHERE CQ2_FILIAL = @cFilCur AND
               CQ2_DATA   = @cDatMes AND
               CQ2_CONTA  = @cContaCur AND
               CQ2_CCUSTO = @cCustoCur AND
               CQ2_MOEDA  = @cMoedCur AND
               CQ2_TPSALD = @cTpSldCur AND
               CQ2_LP     = @cLP AND
               D_E_L_E_T_ = ' '
         ##CHECK_TRANSACTION_COMMIT
      End

      Select @nSaldo = 0
      Select @nSaldo = ROUND(CQ3_DEBITO+CQ3_CREDIT,2) From CQ3### WHERE R_E_C_N_O_ = @nRecno
      
      /* Se nao tem valor de debito e nem credito, exclui a linha */
      If @nSaldo = 0 Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         DELETE FROM CQ3### WHERE R_E_C_N_O_ = @nRecno 
         ##CHECK_TRANSACTION_COMMIT     
      End

      Select @nSaldo = 0
      Select @nRecAux = 0
      Select @nSaldo = ROUND(CQ2_DEBITO+CQ2_CREDIT,2), @nRecAux = R_E_C_N_O_ From CQ2### 
      WHERE CQ2_FILIAL = @cFilCur AND
            CQ2_DATA   = @cDatMes AND
            CQ2_CONTA  = @cContaCur AND
            CQ2_CCUSTO = @cCustoCur AND
            CQ2_MOEDA  = @cMoedCur AND
            CQ2_TPSALD = @cTpSldCur AND
            CQ2_LP     = @cLP AND
            D_E_L_E_T_ = ' '

      /* Se nao tem valor de debito e nem credito, exclui a linha */
      If @nSaldo = 0 Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         DELETE FROM CQ2### WHERE R_E_C_N_O_ = @nRecAux
         ##CHECK_TRANSACTION_COMMIT     
      End

      exec CTB965B_## @cFilCur, @cDatCur, @cDatMes, 'CTT', @cCustoCur, @cMoedCur, @cTpSldCur, @cLP, @cTipo, @nValCur, @IN_TRANSACTION, @OUT_RESULTADO OutPut
   
      /*Tratamento para Postgres*/
      SELECT @fim_CUR = 0
      Fetch CUR_CQ3DEL into @cFilCur, @cDatCur, @cContaCur, @cCustoCur, @cMoedCur, @cTpSldCur, @cLP, @nValCur, @nRecno, @cTipo
   end
   close CUR_CQ3DEL
   deallocate CUR_CQ3DEL

   /*---------------------------------------------------------------
      Apaga registros CQ5 sem movimento na CT2
   ----------------------------------------------------------------*/
   Declare CUR_CQ5DEL insensitive cursor for
   SELECT 
      CQ5_FILIAL, CQ5_DATA, CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, CQ5_MOEDA, CQ5_TPSALD, CQ5_LP, CQ5_DEBITO, CQ5.R_E_C_N_O_, '1' AS TIPO
      FROM 
            CQ5### CQ5
            LEFT JOIN 
               CT2### CT2
               ON
                  CT2_FILIAL = CQ5_FILIAL AND
                  CT2_DATA   = CQ5_DATA AND
                  CT2_DEBITO = CQ5_CONTA AND
                  CT2_CCD    = CQ5_CCUSTO AND
                  CT2_ITEMD  = CQ5_ITEM AND
                  CT2_MOEDLC = CQ5_MOEDA AND 
                  CT2_TPSALD = CQ5_TPSALD AND
                  CT2.D_E_L_E_T_ = ' '

            WHERE 
               ((@IN_LMULTIFIL = '0' AND CQ5_FILIAL = @IN_FILIAL) OR (CQ5_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND   
               CQ5_DATA BETWEEN @IN_DATADE and @IN_DATAATE AND
               CQ5_DEBITO <> 0 AND
               ((CQ5_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
               ((@IN_TPSALDO = '*' AND CQ5_TPSALD <> '9') OR CQ5_TPSALD = @IN_TPSALDO) AND
               CT2_FILIAL IS NULL AND
               CQ5.D_E_L_E_T_ = ' '
   UNION
   SELECT 
      CQ5_FILIAL, CQ5_DATA, CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, CQ5_MOEDA, CQ5_TPSALD, CQ5_LP, CQ5_CREDIT, CQ5.R_E_C_N_O_, '2' AS TIPO
      FROM 
            CQ5### CQ5
            LEFT JOIN 
               CT2### CT2
               ON
                  CT2_FILIAL = CQ5_FILIAL AND
                  CT2_DATA   = CQ5_DATA AND
                  CT2_CREDIT = CQ5_CONTA AND
                  CT2_CCC    = CQ5_CCUSTO AND
                  CT2_ITEMC  = CQ5_ITEM AND
                  CT2_MOEDLC = CQ5_MOEDA AND
                  CT2_TPSALD = CQ5_TPSALD AND
                  CT2.D_E_L_E_T_ = ' '
            WHERE 
               ((@IN_LMULTIFIL = '0' AND CQ5_FILIAL = @IN_FILIAL) OR (CQ5_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND   
               CQ5_DATA BETWEEN @IN_DATADE and @IN_DATAATE AND
               CQ5_CREDIT <> 0 AND
               ((CQ5_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
               ((@IN_TPSALDO = '*' AND CQ5_TPSALD <> '9') OR CQ5_TPSALD = @IN_TPSALDO) AND
               CT2_FILIAL IS NULL AND
               CQ5.D_E_L_E_T_ = ' '
   Order by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
   for read only
   Open CUR_CQ5DEL
   Fetch CUR_CQ5DEL into @cFilCur, @cDatCur, @cContaCur, @cCustoCur, @cItemCur, @cMoedCur, @cTpSldCur, @cLP, @nValCur, @nRecno, @cTipo

   While (@@Fetch_status = 0 ) begin

      exec LASTDAY_## @cDatCur, @cDatMes OutPut  
     
      IF @cTipo = '1' Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ5### SET CQ5_DEBITO = 0 WHERE R_E_C_N_O_ = @nRecno
         ##CHECK_TRANSACTION_COMMIT

         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ4### 
         SET CQ4_DEBITO = ROUND(CQ4_DEBITO-@nValCur,2)         
         WHERE CQ4_FILIAL = @cFilCur AND
               CQ4_DATA   = @cDatMes AND
               CQ4_CONTA  = @cContaCur AND
               CQ4_CCUSTO = @cCustoCur AND
               CQ4_ITEM   = @cItemCur AND
               CQ4_MOEDA  = @cMoedCur AND
               CQ4_TPSALD = @cTpSldCur AND
               CQ4_LP     = @cLP AND
               D_E_L_E_T_ = ' '
         ##CHECK_TRANSACTION_COMMIT
      End Else Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ5### SET CQ5_CREDIT = 0 WHERE R_E_C_N_O_ = @nRecno
         ##CHECK_TRANSACTION_COMMIT

         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ4### 
         SET CQ4_CREDIT = ROUND(CQ4_CREDIT-@nValCur,2)         
         WHERE CQ4_FILIAL = @cFilCur AND
               CQ4_DATA   = @cDatMes AND
               CQ4_CONTA  = @cContaCur AND
               CQ4_CCUSTO = @cCustoCur AND
               CQ4_ITEM   = @cItemCur AND
               CQ4_MOEDA  = @cMoedCur AND
               CQ4_TPSALD = @cTpSldCur AND
               CQ4_LP     = @cLP AND
               D_E_L_E_T_ = ' '
         ##CHECK_TRANSACTION_COMMIT
      End

      Select @nSaldo = 0
      Select @nSaldo = ROUND(CQ5_DEBITO+CQ5_CREDIT,2) From CQ5### WHERE R_E_C_N_O_ = @nRecno
      
      /* Se nao tem valor de debito e nem credito, exclui a linha */
      If @nSaldo = 0 Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         DELETE FROM CQ5### WHERE R_E_C_N_O_ = @nRecno 
         ##CHECK_TRANSACTION_COMMIT     
      End

      Select @nSaldo = 0
      Select @nRecAux = 0
      Select @nSaldo = ROUND(CQ4_DEBITO+CQ4_CREDIT,2), @nRecAux = R_E_C_N_O_ From CQ4### 
      WHERE CQ4_FILIAL = @cFilCur AND
            CQ4_DATA   = @cDatMes AND
            CQ4_CONTA  = @cContaCur AND
            CQ4_CCUSTO = @cCustoCur AND
            CQ4_ITEM   = @cItemCur AND
            CQ4_MOEDA  = @cMoedCur AND
            CQ4_TPSALD = @cTpSldCur AND
            CQ4_LP     = @cLP AND
            D_E_L_E_T_ = ' '

      /* Se nao tem valor de debito e nem credito, exclui a linha */
      If @nSaldo = 0 Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         DELETE FROM CQ4### WHERE R_E_C_N_O_ = @nRecAux
         ##CHECK_TRANSACTION_COMMIT     
      End

      exec CTB965B_## @cFilCur, @cDatCur, @cDatMes, 'CTD', @cItemCur, @cMoedCur, @cTpSldCur, @cLP, @cTipo, @nValCur, @IN_TRANSACTION, @OUT_RESULTADO OutPut
   
      /*Tratamento para Postgres*/
      SELECT @fim_CUR = 0
      Fetch CUR_CQ5DEL into @cFilCur, @cDatCur, @cContaCur, @cCustoCur, @cItemCur, @cMoedCur, @cTpSldCur, @cLP, @nValCur, @nRecno, @cTipo
   end
   close CUR_CQ5DEL
   deallocate CUR_CQ5DEL   

   /*---------------------------------------------------------------
      Apaga registros CQ7 sem movimento na CT2
   ----------------------------------------------------------------*/
   Declare CUR_CQ7DEL insensitive cursor for
   SELECT 
      CQ7_FILIAL, CQ7_DATA, CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL, CQ7_MOEDA, CQ7_TPSALD, CQ7_LP, CQ7_DEBITO, CQ7.R_E_C_N_O_, '1' AS TIPO
      FROM 
            CQ7### CQ7
            LEFT JOIN 
               CT2### CT2
               ON
                  CT2_FILIAL = CQ7_FILIAL AND
                  CT2_DATA   = CQ7_DATA AND
                  CT2_DEBITO = CQ7_CONTA AND
                  CT2_CCD    = CQ7_CCUSTO AND
                  CT2_ITEMD  = CQ7_ITEM AND
                  CT2_CLVLDB = CQ7_CLVL AND
                  CT2_MOEDLC = CQ7_MOEDA AND 
                  CT2_TPSALD = CQ7_TPSALD AND
                  CT2.D_E_L_E_T_ = ' '

            WHERE 
               ((@IN_LMULTIFIL = '0' AND CQ7_FILIAL = @IN_FILIAL) OR (CQ7_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND   
               CQ7_DATA BETWEEN @IN_DATADE and @IN_DATAATE AND
               CQ7_DEBITO <> 0 AND
               ((CQ7_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
               ((@IN_TPSALDO = '*' AND CQ7_TPSALD <> '9') OR CQ7_TPSALD = @IN_TPSALDO) AND
               CT2_FILIAL IS NULL AND
               CQ7.D_E_L_E_T_ = ' '
   UNION
   SELECT 
      CQ7_FILIAL, CQ7_DATA, CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL, CQ7_MOEDA, CQ7_TPSALD, CQ7_LP, CQ7_CREDIT, CQ7.R_E_C_N_O_, '2' AS TIPO
      FROM 
            CQ7### CQ7
            LEFT JOIN 
               CT2### CT2
               ON
                  CT2_FILIAL = CQ7_FILIAL AND
                  CT2_DATA   = CQ7_DATA AND
                  CT2_CREDIT = CQ7_CONTA AND
                  CT2_CCC    = CQ7_CCUSTO AND
                  CT2_ITEMC  = CQ7_ITEM AND
                  CT2_CLVLCR = CQ7_CLVL AND
                  CT2_MOEDLC = CQ7_MOEDA AND
                  CT2_TPSALD = CQ7_TPSALD AND
                  CT2.D_E_L_E_T_ = ' '
            WHERE 
               ((@IN_LMULTIFIL = '0' AND CQ7_FILIAL = @IN_FILIAL) OR (CQ7_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND   
               CQ7_DATA BETWEEN @IN_DATADE and @IN_DATAATE AND
               CQ7_CREDIT <> 0 AND
               ((CQ7_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
               ((@IN_TPSALDO = '*' AND CQ7_TPSALD <> '9') OR CQ7_TPSALD = @IN_TPSALDO) AND
               CT2_FILIAL IS NULL AND
               CQ7.D_E_L_E_T_ = ' '
   Order by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
   for read only
   Open CUR_CQ7DEL
   Fetch CUR_CQ7DEL into @cFilCur, @cDatCur, @cContaCur, @cCustoCur, @cItemCur, @cCLVLCur, @cMoedCur, @cTpSldCur, @cLP, @nValCur, @nRecno, @cTipo

   While (@@Fetch_status = 0 ) begin

      exec LASTDAY_## @cDatCur, @cDatMes OutPut  
     
      IF @cTipo = '1' Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ7### SET CQ7_DEBITO = 0 WHERE R_E_C_N_O_ = @nRecno
         ##CHECK_TRANSACTION_COMMIT

         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ6### 
         SET CQ6_DEBITO = ROUND(CQ6_DEBITO-@nValCur,2)         
         WHERE CQ6_FILIAL = @cFilCur AND
               CQ6_DATA   = @cDatMes AND
               CQ6_CONTA  = @cContaCur AND
               CQ6_CCUSTO = @cCustoCur AND
               CQ6_ITEM   = @cItemCur AND
               CQ6_CLVL   = @cCLVLCur AND
               CQ6_MOEDA  = @cMoedCur AND
               CQ6_TPSALD = @cTpSldCur AND
               CQ6_LP     = @cLP AND
               D_E_L_E_T_ = ' '
         ##CHECK_TRANSACTION_COMMIT
      End Else Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ7### SET CQ7_CREDIT = 0 WHERE R_E_C_N_O_ = @nRecno
         ##CHECK_TRANSACTION_COMMIT

         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         UPDATE CQ6### 
         SET CQ6_CREDIT = ROUND(CQ6_CREDIT-@nValCur,2)         
         WHERE CQ6_FILIAL = @cFilCur AND
               CQ6_DATA   = @cDatMes AND
               CQ6_CONTA  = @cContaCur AND
               CQ6_CCUSTO = @cCustoCur AND
               CQ6_ITEM   = @cItemCur AND
               CQ6_CLVL   = @cCLVLCur AND
               CQ6_MOEDA  = @cMoedCur AND
               CQ6_TPSALD = @cTpSldCur AND
               CQ6_LP     = @cLP AND
               D_E_L_E_T_ = ' '
         ##CHECK_TRANSACTION_COMMIT
      End

      Select @nSaldo = 0
      Select @nSaldo = ROUND(CQ7_DEBITO+CQ7_CREDIT,2) From CQ7### WHERE R_E_C_N_O_ = @nRecno
      
      /* Se nao tem valor de debito e nem credito, exclui a linha */
      If @nSaldo = 0 Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         DELETE FROM CQ7### WHERE R_E_C_N_O_ = @nRecno 
         ##CHECK_TRANSACTION_COMMIT     
      End

      Select @nSaldo = 0
      Select @nRecAux = 0
      Select @nSaldo = ROUND(CQ6_DEBITO+CQ6_CREDIT,2), @nRecAux = R_E_C_N_O_ From CQ6### 
      WHERE CQ6_FILIAL = @cFilCur AND
            CQ6_DATA   = @cDatMes AND
            CQ6_CONTA  = @cContaCur AND
            CQ6_CCUSTO = @cCustoCur AND
            CQ6_ITEM   = @cItemCur AND
            CQ6_CLVL   = @cCLVLCur AND
            CQ6_MOEDA  = @cMoedCur AND
            CQ6_TPSALD = @cTpSldCur AND
            CQ6_LP     = @cLP AND
            D_E_L_E_T_ = ' '

      /* Se nao tem valor de debito e nem credito, exclui a linha */
      If @nSaldo = 0 Begin
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         DELETE FROM CQ6### 
         WHERE R_E_C_N_O_ = @nRecAux
         ##CHECK_TRANSACTION_COMMIT     
      End

      exec CTB965B_## @cFilCur, @cDatCur, @cDatMes, 'CTH', @cCLVLCur, @cMoedCur, @cTpSldCur, @cLP, @cTipo, @nValCur, @IN_TRANSACTION, @OUT_RESULTADO OutPut
   
      /*Tratamento para Postgres*/
      SELECT @fim_CUR = 0
      Fetch CUR_CQ7DEL into @cFilCur, @cDatCur, @cContaCur, @cCustoCur, @cItemCur, @cCLVLCur, @cMoedCur, @cTpSldCur, @cLP, @nValCur, @nRecno, @cTipo
   end
   close CUR_CQ7DEL
   deallocate CUR_CQ7DEL       

   select @OUT_RESULTADO = '1'
end
##ENDIF_999