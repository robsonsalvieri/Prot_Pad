Create procedure CTB021C_## ( 
    @IN_CALIAS       Char(03),
    @IN_FILIAL       Char('CT2_FILIAL'),
    @IN_CUSTO        Char('CT2_CCD'),
    @IN_ITEM         Char('CT2_ITEMD'),
    @IN_CLASSE       Char('CT2_CLVLDB'),
    @IN_DATA         Char(08),    
    @IN_LMOEDAESP    Char(01),
    @IN_MOEDA        Char('CQ0_MOEDA'),
    @IN_TPSALDO      Char('CT2_TPSALD'),
    @IN_TRANSACTION  Char(01),
    @OUT_RESULTADO   Char(01) OutPut )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P12 </v>    
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Zera os arquivos a serem posteriormente reprocessados </d>
    Fonte Microsiga - <s> CTBA190.PRW </s>
    Entrada         - <ri> @IN_CALIAS       - Alias que será deletado
                           @IN_FILIAL       - Filial que será processada                           
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
declare @cFilial_CT2 char('CT2_FILIAL')
declare @cFilial_CQ3 char('CQ3_FILIAL')
declare @cFilial_CQ5 char('CQ5_FILIAL')
declare @cFilial_CQ7 char('CQ7_FILIAL')
declare @cFilial_CQ8 char('CQ8_FILIAL')
declare @cFilial_CQ9 char('CQ9_FILIAL')
declare @cMoeda      char('CQ0_MOEDA')
declare @iRecno      Integer
declare @nCTX_DEBITO Float
declare @nCTX_CREDIT Float
declare @cCTX_DTLP   Char(08)
declare @cCTX_LP     Char('CQ0_LP')
declare @cCTX_STATUS Char('CQ0_STATUS')
declare @cCTX_SLBASE Char('CQ0_SLBASE')
declare @cCT2_DTLP   Char(08)
declare @nVALORDeb   Float
declare @nVALORCred  Float
declare @cDataI      Char(08)
declare @cDataF      Char(08)
Declare @iTranCount  Integer --Var.de ajuste para SQLServer e Sybase.-- Será trocada por Commit no CFGX051 após passar pelo Parse

begin
    
    select @OUT_RESULTADO = '0'
    select @cDataI = Substring(@IN_DATA, 1, 6 )||'01'       
    exec LASTDAY_## @IN_DATA, @cDataF OutPut  

    exec XFILIAL_## 'CT2', @IN_FILIAL, @cFilial_CT2 OutPut
    exec XFILIAL_## 'CQ3', @IN_FILIAL, @cFilial_CQ3 OutPut
    exec XFILIAL_## 'CQ5', @IN_FILIAL, @cFilial_CQ5 OutPut
    exec XFILIAL_## 'CQ7', @IN_FILIAL, @cFilial_CQ7 OutPut
    exec XFILIAL_## 'CQ8', @IN_FILIAL, @cFilial_CQ8 OutPut
    exec XFILIAL_## 'CQ9', @IN_FILIAL, @cFilial_CQ9 OutPut

    If @IN_CALIAS = 'CTT' begin
        Declare CUR_CQ3 insensitive cursor for
            Select CQ3_MOEDA,CQ3_DTLP, CQ3_LP, SUM(CQ3_DEBITO), SUM(CQ3_CREDIT)
            From CQ3###
            Where CQ3_FILIAL = @cFilial_CQ3
            and CQ3_CCUSTO = @IN_CUSTO
            and CQ3_DATA   = @IN_DATA
            and CQ3_TPSALD = @IN_TPSALDO
            and ((@IN_LMOEDAESP = '1' and CQ3_MOEDA = @IN_MOEDA) or @IN_LMOEDAESP = '0' )
            and D_E_L_E_T_= ' '
            Group By CQ3_MOEDA, CQ3_DTLP, CQ3_LP        
        for read only
        Open CUR_CQ3
        Fetch CUR_CQ3 into @cMoeda, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        
        /*====================
            Gravação da CQ9
        ======================*/                 
        While (@@Fetch_status = 0 ) begin            
            select @nCTX_DEBITO = 0
            select @nCTX_CREDIT = 0
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'            
            select @nCTX_DEBITO = @nVALORDeb
            select @nCTX_CREDIT = @nVALORCred            
            select @iRecno  = 0

            ##UNIQUEKEY_START 
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ9###
             Where CQ9_FILIAL = @cFilial_CQ9
               and CQ9_DATA   = @IN_DATA
               and CQ9_IDENT  = @IN_CALIAS
               and CQ9_CODIGO = @IN_CUSTO
               and CQ9_MOEDA  = @cMoeda
               and CQ9_TPSALD = @IN_TPSALDO
               and CQ9_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
                select @iRecno = @iRecno + 1
                
                ##TRATARECNO @iRecno\    
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ9### ( CQ9_FILIAL,    CQ9_IDENT,  CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA,  CQ9_TPSALD,   CQ9_SLBASE,   CQ9_DTLP,   CQ9_LP,   CQ9_STATUS,   CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
                             values( @cFilial_CQ9, @IN_CALIAS,   @IN_CUSTO, @cMoeda, @IN_DATA, @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,            0,          0, @iRecno )
                ##CHECK_TRANSACTION_COMMIT 
                ##FIMTRATARECNO
            end
           
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update CQ9###
               set CQ9_DEBITO = CQ9_DEBITO + @nVALORDeb,
                   CQ9_CREDIT = CQ9_CREDIT + @nVALORCred
             Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQ3 into @cMoeda, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ3
        deallocate CUR_CQ3
        
        Declare CUR_CTT insensitive cursor for
            Select CQ9_MOEDA, CQ9_DTLP, CQ9_LP, SUM(CQ9_DEBITO), SUM(CQ9_CREDIT)
            From CQ9###
            Where CQ9_FILIAL = @cFilial_CQ9
            and CQ9_IDENT  = @IN_CALIAS
            and CQ9_TPSALD = @IN_TPSALDO
            and CQ9_CODIGO = @IN_CUSTO
            and ((@IN_LMOEDAESP = '1' and CQ9_MOEDA = @IN_MOEDA) or @IN_LMOEDAESP = '0' )
            and CQ9_DATA between @cDataI and @cDataF
            and D_E_L_E_T_= ' '
	     Group By CQ9_MOEDA, CQ9_DTLP, CQ9_LP	     
	    for read only
        Open CUR_CTT
        Fetch CUR_CTT into @cMoeda, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
	    
        /*====================
            Gravação da CQ8
        ======================*/                 
        While (@@Fetch_status = 0 ) begin
            select @nCTX_DEBITO = @nVALORDeb
	        select @nCTX_CREDIT = @nVALORCred
	        select @cCTX_STATUS = '1'
	        select @cCTX_SLBASE = 'S'            
            select @iRecno  = 0

            ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ8###
             Where CQ8_FILIAL = @cFilial_CQ8
               and CQ8_IDENT  = @IN_CALIAS
               and CQ8_CODIGO = @IN_CUSTO
               and CQ8_MOEDA  = @cMoeda
               and CQ8_DATA   = @cDataF
               and CQ8_TPSALD = @IN_TPSALDO
               and CQ8_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
	            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ8###
	            select @iRecno = @iRecno + 1
	            
	            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
	            select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
	            ##TRATARECNO @iRecno\
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
	            Insert into CQ8### ( CQ8_FILIAL,  CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA,  CQ8_TPSALD,   CQ8_SLBASE,   CQ8_DTLP,   CQ8_LP,   CQ8_STATUS,   CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                           values( @cFilial_CQ8, @IN_CALIAS, @IN_CUSTO, @cMoeda,  @cDataF, @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,            0,          0, @iRecno )
 		        ##CHECK_TRANSACTION_COMMIT
	            ##FIMTRATARECNO
            end
	        
	        select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
	        select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
	        Update CQ8###
		       set CQ8_DTLP    = @cCTX_DTLP,
                   CQ8_DEBITO  = CQ8_DEBITO + @nCTX_DEBITO,
		           CQ8_CREDIT  = CQ8_CREDIT + @nCTX_CREDIT
             where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CTT into @cMoeda, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CTT
        deallocate CUR_CTT
    End


    If @IN_CALIAS = 'CTD' begin
        Declare CUR_CQ5 insensitive cursor for
            Select CQ5_MOEDA, CQ5_DTLP, CQ5_LP, SUM(CQ5_DEBITO), SUM(CQ5_CREDIT)
            From CQ5###
            Where CQ5_FILIAL = @cFilial_CQ5
            and CQ5_ITEM   = @IN_ITEM
            and CQ5_DATA   = @IN_DATA
            and CQ5_TPSALD = @IN_TPSALDO
            and ((@IN_LMOEDAESP = '1' and CQ5_MOEDA = @IN_MOEDA) or @IN_LMOEDAESP = '0' )
            and D_E_L_E_T_= ' '
            Group By CQ5_MOEDA, CQ5_DTLP, CQ5_LP        
        for read only
        Open CUR_CQ5
        Fetch CUR_CQ5 into @cMoeda, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        
        /*====================
            Gravação da CQ9
        ======================*/                 
        While (@@Fetch_status = 0 ) begin            
            select @nCTX_DEBITO = 0
            select @nCTX_CREDIT = 0
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'            
            select @nCTX_DEBITO = @nVALORDeb
            select @nCTX_CREDIT = @nVALORCred            
            select @iRecno  = 0

            ##UNIQUEKEY_START 
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ9###
             Where CQ9_FILIAL = @cFilial_CQ9
               and CQ9_DATA   = @IN_DATA
               and CQ9_IDENT  = @IN_CALIAS
               and CQ9_CODIGO = @IN_ITEM
               and CQ9_MOEDA  = @cMoeda
               and CQ9_TPSALD = @IN_TPSALDO
               and CQ9_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
                select @iRecno = @iRecno + 1
                
                ##TRATARECNO @iRecno\    
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ9### ( CQ9_FILIAL,    CQ9_IDENT,  CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA,  CQ9_TPSALD,   CQ9_SLBASE,   CQ9_DTLP,   CQ9_LP,   CQ9_STATUS,   CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
                             values( @cFilial_CQ9, @IN_CALIAS,    @IN_ITEM, @cMoeda, @IN_DATA, @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,            0,          0, @iRecno )
                ##CHECK_TRANSACTION_COMMIT 
                ##FIMTRATARECNO
            end
           
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update CQ9###
               set CQ9_DEBITO = CQ9_DEBITO + @nVALORDeb,
                   CQ9_CREDIT = CQ9_CREDIT + @nVALORCred
             Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQ5 into @cMoeda, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ5
        deallocate CUR_CQ5
        
        Declare CUR_CTD insensitive cursor for
            Select CQ9_MOEDA, CQ9_DTLP, CQ9_LP, SUM(CQ9_DEBITO), SUM(CQ9_CREDIT)
            From CQ9###
            Where CQ9_FILIAL = @cFilial_CQ9
            and CQ9_IDENT  = @IN_CALIAS
            and CQ9_TPSALD = @IN_TPSALDO
            and CQ9_CODIGO = @IN_ITEM
            and ((@IN_LMOEDAESP = '1' and CQ9_MOEDA = @IN_MOEDA) or @IN_LMOEDAESP = '0' )
            and CQ9_DATA between @cDataI and @cDataF
            and D_E_L_E_T_= ' '
	     Group By CQ9_MOEDA, CQ9_DTLP, CQ9_LP	     
	    for read only
        Open CUR_CTD
        Fetch CUR_CTD into @cMoeda, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
	    
        /*====================
            Gravação da CQ8
        ======================*/                 
        While (@@Fetch_status = 0 ) begin
            select @nCTX_DEBITO = @nVALORDeb
	        select @nCTX_CREDIT = @nVALORCred
	        select @cCTX_STATUS = '1'
	        select @cCTX_SLBASE = 'S'            
            select @iRecno  = 0

            ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ8###
             Where CQ8_FILIAL = @cFilial_CQ8
               and CQ8_IDENT  = @IN_CALIAS
               and CQ8_CODIGO = @IN_ITEM
               and CQ8_MOEDA  = @cMoeda
               and CQ8_DATA   = @cDataF
               and CQ8_TPSALD = @IN_TPSALDO
               and CQ8_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
	            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ8###
	            select @iRecno = @iRecno + 1
	            
	            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
	            select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
	            ##TRATARECNO @iRecno\
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
	            Insert into CQ8### ( CQ8_FILIAL,  CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA,  CQ8_TPSALD,   CQ8_SLBASE,   CQ8_DTLP,   CQ8_LP,   CQ8_STATUS,   CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                           values( @cFilial_CQ8, @IN_CALIAS,   @IN_ITEM, @cMoeda,  @cDataF, @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,            0,          0, @iRecno )
 		        ##CHECK_TRANSACTION_COMMIT
	            ##FIMTRATARECNO
            end
	        
	        select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
	        select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
	        Update CQ8###
		       set CQ8_DTLP    = @cCTX_DTLP,
                   CQ8_DEBITO  = CQ8_DEBITO + @nCTX_DEBITO,
		           CQ8_CREDIT  = CQ8_CREDIT + @nCTX_CREDIT
             where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CTD into @cMoeda, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CTD
        deallocate CUR_CTD
    End


    If @IN_CALIAS = 'CTH' begin
        Declare CUR_CQ7 insensitive cursor for
            Select CQ7_MOEDA, CQ7_DTLP, CQ7_LP, SUM(CQ7_DEBITO), SUM(CQ7_CREDIT)
            From CQ7###
            Where CQ7_FILIAL = @cFilial_CQ7
            and CQ7_CLVL   = @IN_CLASSE
            and CQ7_DATA   = @IN_DATA
            and CQ7_TPSALD = @IN_TPSALDO
            and ((@IN_LMOEDAESP = '1' and CQ7_MOEDA = @IN_MOEDA) or @IN_LMOEDAESP = '0' )
            and D_E_L_E_T_= ' '
            Group By CQ7_MOEDA, CQ7_DTLP, CQ7_LP        
        for read only
        Open CUR_CQ7
        Fetch CUR_CQ7 into @cMoeda, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        
        /*====================
            Gravação da CQ9
        ======================*/                 
        While (@@Fetch_status = 0 ) begin            
            select @nCTX_DEBITO = 0
            select @nCTX_CREDIT = 0
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'            
            select @nCTX_DEBITO = @nVALORDeb
            select @nCTX_CREDIT = @nVALORCred            
            select @iRecno  = 0

            ##UNIQUEKEY_START 
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ9###
             Where CQ9_FILIAL = @cFilial_CQ9
               and CQ9_DATA   = @IN_DATA
               and CQ9_IDENT  = @IN_CALIAS
               and CQ9_CODIGO = @IN_CLASSE
               and CQ9_MOEDA  = @cMoeda
               and CQ9_TPSALD = @IN_TPSALDO
               and CQ9_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
                select @iRecno = @iRecno + 1
                
                ##TRATARECNO @iRecno\    
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ9### ( CQ9_FILIAL,    CQ9_IDENT,  CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA,  CQ9_TPSALD,   CQ9_SLBASE,   CQ9_DTLP,   CQ9_LP,   CQ9_STATUS,   CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
                             values( @cFilial_CQ9, @IN_CALIAS,    @IN_CLASSE, @cMoeda, @IN_DATA, @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,            0,          0, @iRecno )
                ##CHECK_TRANSACTION_COMMIT 
                ##FIMTRATARECNO
            end
           
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update CQ9###
               set CQ9_DEBITO = CQ9_DEBITO + @nVALORDeb,
                   CQ9_CREDIT = CQ9_CREDIT + @nVALORCred
             Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQ7 into @cMoeda, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ7
        deallocate CUR_CQ7
        
        Declare CUR_CTH insensitive cursor for
            Select CQ9_MOEDA, CQ9_DTLP, CQ9_LP, SUM(CQ9_DEBITO), SUM(CQ9_CREDIT)
            From CQ9###
            Where CQ9_FILIAL = @cFilial_CQ9
            and CQ9_IDENT  = @IN_CALIAS
            and CQ9_TPSALD = @IN_TPSALDO
            and CQ9_CODIGO = @IN_CLASSE
            and ((@IN_LMOEDAESP = '1' and CQ9_MOEDA = @IN_MOEDA) or @IN_LMOEDAESP = '0' )
            and CQ9_DATA between @cDataI and @cDataF
            and D_E_L_E_T_= ' '
	     Group By CQ9_MOEDA, CQ9_DTLP, CQ9_LP	     
	    for read only
        Open CUR_CTH
        Fetch CUR_CTH into @cMoeda, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
	    
        /*====================
            Gravação da CQ8
        ======================*/                 
        While (@@Fetch_status = 0 ) begin
            select @nCTX_DEBITO = @nVALORDeb
	        select @nCTX_CREDIT = @nVALORCred
	        select @cCTX_STATUS = '1'
	        select @cCTX_SLBASE = 'S'            
            select @iRecno  = 0

            ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ8###
             Where CQ8_FILIAL = @cFilial_CQ8
               and CQ8_IDENT  = @IN_CALIAS
               and CQ8_CODIGO = @IN_CLASSE
               and CQ8_MOEDA  = @cMoeda
               and CQ8_DATA   = @cDataF
               and CQ8_TPSALD = @IN_TPSALDO
               and CQ8_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
	            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ8###
	            select @iRecno = @iRecno + 1
	            
	            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
	            select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
	            ##TRATARECNO @iRecno\
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
	            Insert into CQ8### ( CQ8_FILIAL,  CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA,  CQ8_TPSALD,   CQ8_SLBASE,   CQ8_DTLP,   CQ8_LP,   CQ8_STATUS,   CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                           values( @cFilial_CQ8, @IN_CALIAS,   @IN_CLASSE, @cMoeda,  @cDataF, @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,            0,          0, @iRecno )
 		        ##CHECK_TRANSACTION_COMMIT
	            ##FIMTRATARECNO
            end
	        
	        select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
	        select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
	        Update CQ8###
		       set CQ8_DTLP    = @cCTX_DTLP,
                   CQ8_DEBITO  = CQ8_DEBITO + @nCTX_DEBITO,
		           CQ8_CREDIT  = CQ8_CREDIT + @nCTX_CREDIT
             where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CTH into @cMoeda, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CTH
        deallocate CUR_CTH
    End
   
    /*===================================
        Se a execucao foi OK retorna '1'
    ===================================== */
    select @OUT_RESULTADO = '1'
end

