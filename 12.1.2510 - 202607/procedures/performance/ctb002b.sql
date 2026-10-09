Create procedure CTB002B_## 
 ( 
  @IN_CALIAS       Char(03),
  @IN_FILIAL       Char('CT2_FILIAL'),
  @IN_CONTA        Char('CT2_DEBITO'),
  @IN_CUSTO        Char('CT2_CCD'),
  @IN_ITEM         Char('CT2_ITEMD'),
  @IN_CLASSE       Char('CT2_CLVLDB'),
  @IN_DATA         Char(08),
  @IN_MOEDAESP     Char(01),
  @IN_MOEDA        Char('CT2_MOEDLC'),
  @IN_TPSALDO      char('CT2_TPSALD'),
  @IN_TRANSACTION  cHAR(01),
  @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P12 </v>    
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Zera os arquivos a serem posteriormente reprocessados </d>
    Fonte Microsiga - <s> CTBA190.PRW </s>
    Entrada         - <ri> @IN_CALIAS       - Alias que será deletado
                           @IN_FILIAL       - Filial que será processada
                           @IN_CONTA        - Conta que será atualizada
                           @IN_CUSTO        - Centro de Custo que será atualizado
                           @IN_ITEM         - Item que será atualizado
                           @IN_CLASSE       - Classe que será atualizada
                           @IN_DATA         - Data para atualização dos saldos
                           @IN_MOEDAESP     - Se será reprocessado uma moeda específica
                           @IN_MOEDA        - Moeda específica
                           @IN_TPSALDO      - Tipo de saldo                           
                           @IN_TRANSACTION  - '1' se em transação - '0' -fora de transação  </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Data        :     08/11/2023
-------------------------------------------------------------------------------------- */
declare @iMinRecno    integer
declare @iMaxRecno    integer
declare @cFilial_CT2 char('CT2_FILIAL')
declare @cFilial_CQ0 char('CQ0_FILIAL')  --Conta Mes
declare @cFilial_CQ1 char('CQ1_FILIAL')  --Conta Dia
declare @cFilial_CQ2 char('CQ2_FILIAL')  --Ccusto Mes
declare @cFilial_CQ3 char('CQ3_FILIAL')  --CCusto Dia
declare @cFilial_CQ4 char('CQ4_FILIAL')  --Item Mes
declare @cFilial_CQ5 char('CQ5_FILIAL')  --Item Dia
declare @cFilial_CQ6 char('CQ6_FILIAL')  --Clvl Mes
declare @cFilial_CQ7 char('CQ7_FILIAL')  --Clvl Dia
declare @cFilial_CQ8 char('CQ8_FILIAL')  --CTU entidades Mes
declare @cFilial_CQ9 char('CQ9_FILIAL')  --CTU entidades Dia
declare @cFilial_CTC char('CTC_FILIAL')  -- documento
declare @cFilial_CQA char('CQA_FILIAL')  -- documento
declare @cCT2Fil     char('CT2_FILIAL')  -- documento
declare @cAux        char(03)
declare @cDatMensal  Char(08)
declare @cCodigo     Char('CQ8_CODIGO')
begin   
       
   select @OUT_RESULTADO = '0'

   exec LASTDAY_## @IN_DATA, @cDatMensal OutPut
   exec XFILIAL_## 'CT2', @IN_FILIAL, @cFilial_CT2 OutPut
   exec XFILIAL_## 'CQ0', @IN_FILIAL, @cFilial_CQ0 OutPut
   exec XFILIAL_## 'CQ1', @IN_FILIAL, @cFilial_CQ1 OutPut
   exec XFILIAL_## 'CQ2', @IN_FILIAL, @cFilial_CQ2 OutPut
   exec XFILIAL_## 'CQ3', @IN_FILIAL, @cFilial_CQ3 OutPut
   exec XFILIAL_## 'CQ4', @IN_FILIAL, @cFilial_CQ4 OutPut
   exec XFILIAL_## 'CQ5', @IN_FILIAL, @cFilial_CQ5 OutPut
   exec XFILIAL_## 'CQ6', @IN_FILIAL, @cFilial_CQ6 OutPut
   exec XFILIAL_## 'CQ7', @IN_FILIAL, @cFilial_CQ7 OutPut
   exec XFILIAL_## 'CQ8', @IN_FILIAL, @cFilial_CQ8 OutPut
   exec XFILIAL_## 'CQ9', @IN_FILIAL, @cFilial_CQ9 OutPut
   
   /* -------------------------------------------------------------------------
      Zera as tabelas Contas -  CQ0 Mes
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ0' ) begin    
	   
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ0###
       where CQ0_FILIAL = @cFilial_CQ0
         and CQ0_DATA = @cDatMensal
         and CQ0_CONTA = @IN_CONTA
         and CQ0_TPSALD = @IN_TPSALDO
         and ( @IN_MOEDAESP = '0' OR CQ0_MOEDA = @IN_MOEDA )
         
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\           
            delete from CQ0###
            where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 1024
               and CQ0_FILIAL = @cFilial_CQ0
               and CQ0_DATA   = @cDatMensal
               and CQ0_CONTA  = @IN_CONTA
               and CQ0_TPSALD = @IN_TPSALDO
               and ( @IN_MOEDAESP = '0' OR CQ0_MOEDA = @IN_MOEDA )           
            ##CHECK_TRANSACTION_COMMIT

            select @iMinRecno = @iMinRecno + 1024    
         end
      end
   end

   /* -------------------------------------------------------------------------
      Zera as tabelas Contas - CQ1 Dia
      -------------------------------------------------------------------------*/   
   if ( @IN_CALIAS = 'CQ1' ) begin	      
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ1###
       where CQ1_FILIAL = @cFilial_CQ1
         and CQ1_DATA = @IN_DATA
         and CQ1_CONTA = @IN_CONTA
         and CQ1_TPSALD = @IN_TPSALDO
         and ( @IN_MOEDAESP = '0' OR CQ1_MOEDA = @IN_MOEDA )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\           
            delete from CQ1###
            where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 1024
               and CQ1_FILIAL = @cFilial_CQ1
               and CQ1_DATA   = @IN_DATA
               and CQ1_CONTA  = @IN_CONTA
               and CQ1_TPSALD = @IN_TPSALDO
               and ( @IN_MOEDAESP = '0' OR CQ1_MOEDA = @IN_MOEDA )                  
            ##CHECK_TRANSACTION_COMMIT

            select @iMinRecno = @iMinRecno + 1024    
         end
      end
   end

   /* -------------------------------------------------------------------------
      Zera as tabelas CCustos - CQ2 Mes
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ2' ) begin
	   
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ2###
       where CQ2_FILIAL = @cFilial_CQ2
         and CQ2_DATA   = @cDatMensal
         and CQ2_CONTA  = @IN_CONTA
         and CQ2_CCUSTO = @IN_CUSTO
         and CQ2_TPSALD = @IN_TPSALDO
         and ( @IN_MOEDAESP = '0' OR CQ2_MOEDA = @IN_MOEDA )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\           
            delete from CQ2###
            where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 1024
               and CQ2_FILIAL = @cFilial_CQ2
               and CQ2_DATA   = @cDatMensal
               and CQ2_CONTA  = @IN_CONTA
               and CQ2_CCUSTO = @IN_CUSTO
               and CQ2_TPSALD = @IN_TPSALDO
               and ( @IN_MOEDAESP = '0' OR CQ2_MOEDA = @IN_MOEDA )              
            ##CHECK_TRANSACTION_COMMIT

            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end

   /* -------------------------------------------------------------------------
      Zera as tabelas CCustos - CQ3 Dia
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ3' ) begin   
    
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ3###
       where CQ3_FILIAL = @cFilial_CQ3
         and CQ3_DATA   = @IN_DATA
         and CQ3_CONTA  = @IN_CONTA
         and CQ3_CCUSTO = @IN_CUSTO
         and CQ3_TPSALD = @IN_TPSALDO
         and ( @IN_MOEDAESP = '0' OR CQ3_MOEDA = @IN_MOEDA )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin

            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\           
            delete from CQ3###
            where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 1024
               and CQ3_FILIAL = @cFilial_CQ3
               and CQ3_DATA   = @IN_DATA
               and CQ3_CONTA  = @IN_CONTA
               and CQ3_CCUSTO = @IN_CUSTO
               and CQ3_TPSALD = @IN_TPSALDO
               and ( @IN_MOEDAESP = '0' OR CQ3_MOEDA = @IN_MOEDA )           
            ##CHECK_TRANSACTION_COMMIT

            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end

   /* -------------------------------------------------------------------------
      Zera a tabela Item Contabil - CQ4 - Mes
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ4' ) begin
	   
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ4###
       where CQ4_FILIAL = @cFilial_CQ4
         and CQ4_DATA   = @cDatMensal
         and CQ4_CONTA  = @IN_CONTA
         and CQ4_CCUSTO = @IN_CUSTO
         and CQ4_ITEM   = @IN_ITEM
         and CQ4_TPSALD = @IN_TPSALDO
         and ( @IN_MOEDAESP = '0' OR CQ4_MOEDA = @IN_MOEDA )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            delete from CQ4###
            where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 1024
               and CQ4_FILIAL = @cFilial_CQ4
               and CQ4_DATA   = @cDatMensal
               and CQ4_CONTA  = @IN_CONTA
               and CQ4_CCUSTO = @IN_CUSTO
               and CQ4_ITEM   = @IN_ITEM
               and CQ4_TPSALD = @IN_TPSALDO
               and ( @IN_MOEDAESP = '0' OR CQ4_MOEDA = @IN_MOEDA )
            ##CHECK_TRANSACTION_COMMIT

            select @iMinRecno = @iMinRecno + 1024
            
         end
      end
   end

   /* -------------------------------------------------------------------------
      Zera ITEM contabil CQ5 - Dia
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ5' ) begin   	
          
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ5###
       where CQ5_FILIAL = @cFilial_CQ5
         and CQ5_DATA   = @IN_DATA
         and CQ5_CONTA  = @IN_CONTA
         and CQ5_CCUSTO = @IN_CUSTO
         and CQ5_ITEM   = @IN_ITEM
         and CQ5_TPSALD = @IN_TPSALDO
         and ( @IN_MOEDAESP = '0' OR CQ5_MOEDA = @IN_MOEDA )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
         
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\            
            delete from CQ5###
            where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 1024
               and CQ5_FILIAL = @cFilial_CQ5
               and CQ5_DATA   = @IN_DATA
               and CQ5_CONTA  = @IN_CONTA
               and CQ5_CCUSTO = @IN_CUSTO
               and CQ5_ITEM   = @IN_ITEM
               and CQ5_TPSALD = @IN_TPSALDO
               and ( @IN_MOEDAESP = '0' OR CQ5_MOEDA = @IN_MOEDA )
            ##CHECK_TRANSACTION_COMMIT

            select @iMinRecno = @iMinRecno + 1024            
         end
      end
   end

   /* -------------------------------------------------------------------------
      Zera a tabela Classe de Valor CQ6 - Mes
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ6' ) begin
 	         
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ6###
       where CQ6_FILIAL = @cFilial_CQ6
         and CQ6_DATA   = @cDatMensal
         and CQ6_CONTA  = @IN_CONTA
         and CQ6_CCUSTO = @IN_CUSTO
         and CQ6_ITEM   = @IN_ITEM
         and CQ6_CLVL   = @IN_CLASSE
         and CQ6_TPSALD = @IN_TPSALDO
         and ( @IN_MOEDAESP = '0' OR CQ6_MOEDA = @IN_MOEDA )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin

            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\          
            delete from CQ6###
            where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 1024
               and CQ6_FILIAL = @cFilial_CQ6
               and CQ6_DATA   = @cDatMensal
               and CQ6_CONTA  = @IN_CONTA
               and CQ6_CCUSTO = @IN_CUSTO
               and CQ6_ITEM   = @IN_ITEM
               and CQ6_CLVL   = @IN_CLASSE
               and CQ6_TPSALD = @IN_TPSALDO
               and ( @IN_MOEDAESP = '0' OR CQ6_MOEDA = @IN_MOEDA )                 
            ##CHECK_TRANSACTION_COMMIT

            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end

   /* -------------------------------------------------------------------------
      Zera a tabela Classe de Valor CQ7 - DIA
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CQ7' ) begin
   	
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ7###
       where CQ7_FILIAL = @cFilial_CQ7
         and CQ7_DATA   = @IN_DATA
         and CQ7_CONTA  = @IN_CONTA
         and CQ7_CCUSTO = @IN_CUSTO
         and CQ7_ITEM   = @IN_ITEM
         and CQ7_CLVL   = @IN_CLASSE
         and CQ7_TPSALD = @IN_TPSALDO
         and ( @IN_MOEDAESP = '0' OR CQ7_MOEDA = @IN_MOEDA )  
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin

            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\          
            delete from CQ7###
            where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 1024
               and CQ7_FILIAL = @cFilial_CQ7
               and CQ7_DATA   = @IN_DATA
               and CQ7_CONTA  = @IN_CONTA
               and CQ7_CCUSTO = @IN_CUSTO
               and CQ7_ITEM   = @IN_ITEM
               and CQ7_CLVL   = @IN_CLASSE
               and CQ7_TPSALD = @IN_TPSALDO
               and ( @IN_MOEDAESP = '0' OR CQ7_MOEDA = @IN_MOEDA )                  
            ##CHECK_TRANSACTION_COMMIT

            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end

   /* -------------------------------------------------------------------------
      Zera a Saldo entidades CQ8/CQ9
      -------------------------------------------------------------------------*/

   if (@IN_CALIAS = 'CTT' or  @IN_CALIAS = 'CTD' or  @IN_CALIAS = 'CTH') begin 
      
      select @cCodigo = ' '
      if ( @IN_CALIAS = 'CTT' ) begin
         select @cCodigo = @IN_CUSTO
      end else if ( @IN_CALIAS = 'CTD' ) begin
         select @cCodigo = @IN_ITEM
      end else if ( @IN_CALIAS = 'CTH' ) begin
         select @cCodigo = @IN_CLASSE
      end
         
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ8###
       where CQ8_FILIAL = @cFilial_CQ8
         and CQ8_DATA   = @cDatMensal
         and CQ8_TPSALD = @IN_TPSALDO
         and CQ8_IDENT  = @IN_CALIAS
         and CQ8_CODIGO = @cCodigo
         and ( @IN_MOEDAESP = '0' OR CQ8_MOEDA = @IN_MOEDA )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\            
            delete from CQ8###
            where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 1024
               and CQ8_FILIAL = @cFilial_CQ8
               and CQ8_DATA   = @cDatMensal
               and CQ8_TPSALD = @IN_TPSALDO
               and CQ8_IDENT  = @IN_CALIAS
               and CQ8_CODIGO = @cCodigo
               and ( @IN_MOEDAESP = '0' OR CQ8_MOEDA = @IN_MOEDA )                  
            ##CHECK_TRANSACTION_COMMIT

            select @iMinRecno = @iMinRecno + 1024
         end
      end

      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CQ9###
       where CQ9_FILIAL = @cFilial_CQ9
         and CQ9_DATA   = @IN_DATA
         and CQ9_TPSALD = @IN_TPSALDO
         and CQ9_IDENT  = @IN_CALIAS
         and CQ9_CODIGO = @cCodigo  
         and ( @IN_MOEDAESP = '0' OR CQ9_MOEDA = @IN_MOEDA )
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\           
            delete from CQ9###
            where R_E_C_N_O_ between @iMinRecno and @iMinRecno + 1024
               and CQ9_FILIAL = @cFilial_CQ9
               and CQ9_DATA   = @IN_DATA
               and CQ9_TPSALD = @IN_TPSALDO
               and CQ9_IDENT  = @IN_CALIAS
               and CQ9_CODIGO = @cCodigo
               and ( @IN_MOEDAESP = '0' OR CQ9_MOEDA = @IN_MOEDA )                  
            ##CHECK_TRANSACTION_COMMIT

            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end 

   /* -------------------------------------------------------------------------
      Zera a tabela CTC
      -------------------------------------------------------------------------*/
   if ( @IN_CALIAS = 'CTC' ) begin
      select @cAux = 'CTC'
      exec XFILIAL_## @cAux, @cFilial_CT2, @cFilial_CTC OutPut
      
      select @iMinRecno = isnull( Min( R_E_C_N_O_ ), 0 ), @iMaxRecno = isnull( Max( R_E_C_N_O_ ), 0 )
        from CTC###
        where EXISTS( select 1 
                     from CT2###
                     where CT2_FILIAL = @cFilial_CT2
                        and CT2_DATA = @IN_DATA
                        and (CT2_DEBITO = @IN_CONTA  OR CT2_CREDIT = @IN_CONTA)
                        and (CT2_CCD    = @IN_CUSTO  OR CT2_CCC    = @IN_CUSTO)
                        and (CT2_ITEMD  = @IN_ITEM   OR CT2_ITEMC  = @IN_ITEM)
                        and (CT2_CLVLDB = @IN_CLASSE OR CT2_CLVLCR = @IN_CLASSE)
                        and CT2_FILIAL = CTC_FILIAL
                        and CT2_DATA = CTC_DATA
                        and CT2_LOTE = CTC_LOTE
                        and CT2_SBLOTE = CTC_SBLOTE
                        and CT2_DOC = CTC_DOC
                        and CT2_TPSALD = CTC_TPSALD
                        and CT2_MOEDLC = CTC_MOEDA
                        and D_E_L_E_T_ = ' '
                     )		
      
      if @iMinRecno != 0 begin
         while ( @iMinRecno <= @iMaxRecno ) begin
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            delete from CTC###
            where R_E_C_N_O_ between @iMinRecno   and @iMinRecno + 1024
               and EXISTS( select 1 
                           from CT2###
                           where CT2_FILIAL = @cFilial_CT2
                              and CT2_DATA = @IN_DATA
                              and (CT2_DEBITO = @IN_CONTA  OR CT2_CREDIT = @IN_CONTA)
                              and (CT2_CCD    = @IN_CUSTO  OR CT2_CCC    = @IN_CUSTO)
                              and (CT2_ITEMD  = @IN_ITEM   OR CT2_ITEMC  = @IN_ITEM)
                              and (CT2_CLVLDB = @IN_CLASSE OR CT2_CLVLCR = @IN_CLASSE)
                              and CT2_FILIAL = CTC_FILIAL
                              and CT2_DATA = CTC_DATA
                              and CT2_LOTE = CTC_LOTE
                              and CT2_SBLOTE = CTC_SBLOTE
                              and CT2_DOC = CTC_DOC
                              and CT2_TPSALD = CTC_TPSALD
                              and CT2_MOEDLC = CTC_MOEDA
                              and D_E_L_E_T_ = ' '
                              )
            ##CHECK_TRANSACTION_COMMIT

            select @iMinRecno = @iMinRecno + 1024
         end
      end
   end

   select @OUT_RESULTADO = '1'
end
