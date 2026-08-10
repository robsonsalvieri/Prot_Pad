Create procedure CTB021B_## ( 
    @IN_CALIAS       Char(03),
    @IN_FILIAL       Char('CT2_FILIAL'),
    @IN_CONTA        Char('CT2_DEBITO'),
    @IN_CUSTO        Char('CT2_CCD'),
    @IN_ITEM         Char('CT2_ITEMD'),
    @IN_CLASSE       Char('CT2_CLVLDB'),
    @IN_DATA         Char(08),
    @IN_LMOEDAESP    Char(01),
    @IN_MOEDA        Char('CQ0_MOEDA'),
    @IN_TPSALDO      Char('CT2_TPSALD'),
    @IN_EMPANT       Char(02),
    @IN_FILANT       Char('CT2_FILIAL'), 
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
                           @IN_CONTA        - Conta que será atualizada
                           @IN_CUSTO        - Centro de Custo que será atualizado
                           @IN_ITEM         - Item que será atualizado
                           @IN_CLASSE       - Classe que será atualizada
                           @IN_DATA         - Data para atualização dos saldos
                           @IN_MOEDAESP     - Se será reprocessado uma moeda específica
                           @IN_MOEDA        - Moeda específica
                           @IN_TPSALDO      - Tipo de saldo
                           @IN_EMPANT       - Grupo empresa
                           @IN_FILANT       - Filial
                           @IN_TRANSACTION  - '1' se em transação - '0' -fora de transação  </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Data        :     08/11/2023
-------------------------------------------------------------------------------------- */
declare @cFilial_CT2 char('CT2_FILIAL')
declare @cCT2FilDe   char('CT2_FILIAL')
declare @cFILCT2     char('CT2_FILIAL')
declare @cFilial_CQ0 char('CQ0_FILIAL')
declare @cFilial_CQ1 char('CQ1_FILIAL')
declare @cFilial_CQ2 char('CQ2_FILIAL')
declare @cFilial_CQ3 char('CQ3_FILIAL')
declare @cFilial_CQ4 char('CQ4_FILIAL')
declare @cFilial_CQ5 char('CQ5_FILIAL')
declare @cFilial_CQ6 char('CQ6_FILIAL')
declare @cFilial_CQ7 char('CQ7_FILIAL')
declare @cFilial_CQ8 char('CQ8_FILIAL')
declare @cFilial_CQ9 char('CQ9_FILIAL')
declare @cAux        char(03)
declare @nDebMes     Float
declare @nCrdMes     Float
declare @cTabela     Char(03)
declare @iRecno      Integer
declare @nCTX_DEBITO Float
declare @nCTX_CREDIT Float
declare @cCTX_DTLP   Char(08)
declare @cCTX_LP     Char('CQ0_LP')
declare @cCTX_STATUS Char('CQ0_STATUS')
declare @cCTX_SLBASE Char('CQ0_SLBASE')
declare @cCT2_DTLP   Char(08)
declare @cTIPO       Char(01)
declare @cDATA       Char(08)
declare @cCONTA      Char('CQ0_CONTA')
declare @cCUSTO      Char('CQ2_CCUSTO')
declare @cITEM       Char('CQ4_ITEM')
declare @cCLVL       Char('CQ6_CLVL')
declare @cMOEDA      Char('CQ0_MOEDA')
declare @nVALOR      Float
declare @nVALORDeb   Float
declare @nVALORCred  Float
declare @cIdent      VarChar(03)
declare @cDataI      Char(08)
declare @cDataF      Char(08)
Declare @cAnoMes     Char(06)
Declare @lPrim       Char(01)
Declare @iTranCount  Integer --Var.de ajuste para SQLServer e Sybase.-- Será trocada por Commit no CFGX051 após passar pelo Parse
Declare @cDATACQ     Char(06)
Declare @cCodigo     Char('CQ8_CODIGO')


begin
    
    select @OUT_RESULTADO = '0'
    select @cDataI = Substring(@IN_DATA, 1, 6 )||'01'       
    exec LASTDAY_## @IN_DATA, @cDataF OutPut  

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

    /*
    ######################################
    # ATUALIZAR CONTA CONTABIL - CQ0/CQ1 #
    ######################################
    */
    If @IN_CALIAS = 'CQ0' begin    
        
        Declare CUR_CTB190 insensitive cursor for
        Select CT2_FILIAL, CONTA, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), TIPO 
            From (  Select CT2_FILIAL, CT2_DEBITO CONTA, CT2_MOEDLC, CT2_DATA, CT2_DTLP, CT2_VALOR, '1' TIPO,
                            CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI
                        From CT2###
                        Where CT2_FILIAL = @cFilial_CT2
                        and CT2_DEBITO = @IN_CONTA
                        and CT2_DATA = @IN_DATA                        
                        and (CT2_DC = '1' or CT2_DC = '3')
                        and CT2_TPSALD = @IN_TPSALDO
                        and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )                        
                        and D_E_L_E_T_= ' '                    
                    Union
                    Select CT2_FILIAL, CT2_CREDIT CONTA, CT2_MOEDLC, CT2_DATA, CT2_DTLP, CT2_VALOR, '2' TIPO,
                            CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI
                        From CT2###
                        Where CT2_FILIAL = @cFilial_CT2
                        and CT2_CREDIT = @IN_CONTA
                        and CT2_DATA = @IN_DATA
                        and (CT2_DC = '2' or CT2_DC = '3')
                        and CT2_TPSALD = @IN_TPSALDO
                        and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                        and D_E_L_E_T_ = ' ' ) CT2TRB1
            Where NOT EXISTS (Select 1 
                                From CQA### CQA
                                Where CQA_FILCT2 = CT2_FILIAL
                                and CQA_DATA     = CT2_DATA 
                                and CQA_LOTE     = CT2_LOTE 
                                and CQA_SBLOTE   = CT2_SBLOTE
                                and CQA_DOC      = CT2_DOC 
                                and CQA_LINHA    = CT2_LINHA
                                and CQA_TPSALD   = CT2_TPSALD
                                and CQA_EMPORI   = CT2_EMPORI
                                and CQA_FILORI   = CT2_FILORI
                                and CQA_MOEDLC   = CT2_MOEDLC
                                and CQA.D_E_L_E_T_ = ' ')
        Group By CT2_FILIAL, CONTA, CT2_MOEDLC, CT2_DATA, CT2_DTLP, TIPO
        order by 1, 2, 3, 4, 5, 7
        for read only
        Open CUR_CTB190
        Fetch CUR_CTB190 into  @cFILCT2, @cCONTA, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
        
        /*====================
            Gravação da CQ1
        ======================*/
        While (@@Fetch_status = 0 ) begin
        
            select @nCTX_DEBITO = 0
            select @nCTX_CREDIT = 0
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            select @cCTX_DTLP = ' '
            select @iRecno  = 0

            if @cTIPO = '1' begin
                select @nCTX_DEBITO = Round(@nVALOR, 2)
                select @nCTX_CREDIT = 0
            end
            if @cTIPO = '2' begin
                select @nCTX_CREDIT = Round(@nVALOR, 2)
                select @nCTX_DEBITO = 0
            end
            if @cCT2_DTLP = ' ' begin
                select @cCTX_LP = 'N'
                select @cCTX_DTLP = ' '
            end else begin
                select @cCTX_LP = 'Z'
                select @cCTX_DTLP = @cCT2_DTLP
            end
            
            ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
            From CQ1###
            Where CQ1_FILIAL = @cFilial_CQ1
            and CQ1_DATA   = @cDATA
            and CQ1_CONTA  = @cCONTA
            and CQ1_MOEDA  = @cMOEDA
            and CQ1_TPSALD = @IN_TPSALDO
            and CQ1_LP     = @cCTX_LP   
            and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ1###
                select @iRecno = @iRecno + 1
                
                ##TRATARECNO @iRecno\
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ1### ( CQ1_FILIAL,  CQ1_CONTA, CQ1_MOEDA, CQ1_DATA, CQ1_TPSALD,  CQ1_SLBASE,   CQ1_DTLP,   CQ1_LP, CQ1_STATUS,   CQ1_DEBITO, CQ1_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ1, @cCONTA,   @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,          0, @iRecno )
                ##CHECK_TRANSACTION_COMMIT
                ##FIMTRATARECNO
            end
           
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update CQ1###
            set CQ1_DEBITO = CQ1_DEBITO + @nCTX_DEBITO, CQ1_CREDIT  = CQ1_CREDIT + @nCTX_CREDIT
            Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT
            
            /*====================
             Atualiza flag de LP
            ======================*/
            if @cCT2_DTLP != ' ' begin
                select @cCUSTO = ' '
                select @cITEM  = ' '
                select @cCLVL  = ' '
                select @cIdent  = ' '
                select @cTabela = 'CQ1'
                Exec CTB025_##  @cFilial_CQ1, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @IN_TRANSACTION, @OUT_RESULTADO OutPut
            end
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CTB190 into  @cFILCT2, @cCONTA, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
        end
        close CUR_CTB190
        deallocate CUR_CTB190

        Declare CUR_CQ1 insensitive cursor for
        Select CQ1_FILIAL, CQ1_CONTA , CQ1_MOEDA, Substring( CQ1_DATA, 1, 6 ), CQ1_DTLP, CQ1_LP, SUM(CQ1_DEBITO), SUM(CQ1_CREDIT)
        From CQ1###
        Where CQ1_FILIAL = @cFilial_CQ1
        and CQ1_TPSALD = @IN_TPSALDO
        and ( ( CQ1_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
        and CQ1_DATA between @cDataI and @cDataF 
        and CQ1_CONTA = @IN_CONTA
        and D_E_L_E_T_= ' '
        Group By CQ1_FILIAL, CQ1_CONTA , CQ1_MOEDA, Substring( CQ1_DATA, 1, 6 ), CQ1_DTLP, CQ1_LP
        order by 1,2,3,4, 5, 6
        for read only
        Open CUR_CQ1
        Fetch CUR_CQ1 into  @cFILCT2, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        
        /*====================
            Gravação da CQ0
        ======================*/
        While (@@Fetch_status = 0 ) begin
            
            select @nCTX_DEBITO = Round(@nVALORDeb, 2)
            select @nCTX_CREDIT = Round(@nVALORCred, 2)
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'             
            select @iRecno  = 0
            
            ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
            From CQ0###
            Where CQ0_FILIAL  = @cFilial_CQ0
                and CQ0_CONTA  = @cCONTA
                and CQ0_MOEDA  = @cMOEDA
                and CQ0_DATA   = @cDataF
                and CQ0_TPSALD = @IN_TPSALDO
                and CQ0_LP     = @cCTX_LP
                and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ0###
                select @iRecno = @iRecno + 1
               
                ##TRATARECNO @iRecno\
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ0### ( CQ0_FILIAL, CQ0_CONTA, CQ0_MOEDA, CQ0_DATA, CQ0_TPSALD,  CQ0_SLBASE,   CQ0_DTLP,   CQ0_LP,   CQ0_STATUS,   CQ0_DEBITO, CQ0_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ0, @cCONTA,   @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,          0, @iRecno )
	            ##CHECK_TRANSACTION_COMMIT
                ##FIMTRATARECNO
            end 
           
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Update CQ0###
                set CQ0_DTLP   = @cCTX_DTLP,
                    CQ0_DEBITO = CQ0_DEBITO + @nCTX_DEBITO,
                    CQ0_CREDIT = CQ0_CREDIT + @nCTX_CREDIT
                Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT            
            /* --------------------------------------------------------------------------------------------------------------
            Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQ1 into  @cFILCT2, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ1
        deallocate CUR_CQ1
    end

    /*
    ########################################
    # ATUALIZAR CENTRO DE CUSTOS - CQ2/CQ3 #
    ########################################
    */    
    If @IN_CALIAS = 'CQ2' begin
           
        Declare CUR_CT3 insensitive cursor for
        Select CT2_FILIAL, CONTA, CCUSTO, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), TIPO
        From (  Select CT2_FILIAL, CT2_DEBITO CONTA, CT2_CCD CCUSTO, CT2_MOEDLC, CT2_DATA, CT2_DTLP, CT2_VALOR, '1' TIPO,
                        CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI
                    From CT2###
                    Where CT2_FILIAL = @cFilial_CT2
                    and CT2_DEBITO = @IN_CONTA
                    and CT2_DATA  = @IN_DATA
                    and CT2_CCD = @IN_CUSTO
                    and (CT2_DC = '1' or CT2_DC = '3')                    
                    and CT2_TPSALD = @IN_TPSALDO
                    and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )                    
                    and D_E_L_E_T_= ' '
                Union
                Select CT2_FILIAL, CT2_CREDIT CONTA, CT2_CCC CCUSTO, CT2_MOEDLC, CT2_DATA, CT2_DTLP, CT2_VALOR, '2' TIPO,
                        CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI
                    From CT2###
                    Where CT2_FILIAL = @cFilial_CT2
                    and CT2_CREDIT = @IN_CONTA
                    and CT2_DATA = @IN_DATA
                    and CT2_CCC = @IN_CUSTO
                    and (CT2_DC = '2' or CT2_DC = '3')
                    and CT2_CCC != ' '
                    and CT2_TPSALD = @IN_TPSALDO
                    and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
                    and D_E_L_E_T_ = ' ' ) CT2TRB2
        Where NOT EXISTS (Select 1 
                            From CQA### CQA
                            Where CQA_FILCT2 = CT2_FILIAL
                            and CQA_DATA     = CT2_DATA 
                            and CQA_LOTE     = CT2_LOTE 
                            and CQA_SBLOTE   = CT2_SBLOTE
                            and CQA_DOC      = CT2_DOC 
                            and CQA_LINHA    = CT2_LINHA
                            and CQA_TPSALD   = CT2_TPSALD
                            and CQA_EMPORI   = CT2_EMPORI
                            and CQA_FILORI   = CT2_FILORI
                            and CQA_MOEDLC   = CT2_MOEDLC
                            and CQA.D_E_L_E_T_ = ' ')
        Group By CT2_FILIAL, CONTA, CCUSTO, CT2_MOEDLC, CT2_DATA, CT2_DTLP, TIPO
        order by 1, 2, 3, 4, 5, 6, 8
        for read only
        Open CUR_CT3
        Fetch CUR_CT3 into  @cFILCT2, @cCONTA, @cCUSTO, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO

        /*====================
            Gravação da CQ3
        ======================*/
        While (@@Fetch_status = 0 ) begin
             
            select @nCTX_DEBITO = 0
            select @nCTX_CREDIT = 0
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            select @cCTX_DTLP = ' '
            select @iRecno  = 0
           
            if @cTIPO = '1' begin
                select @nCTX_DEBITO = @nVALOR
                select @nCTX_CREDIT = 0
            end
            if @cTIPO = '2' begin
                select @nCTX_CREDIT = @nVALOR
                select @nCTX_DEBITO = 0
            end
            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
            select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)      

            if @cCT2_DTLP = ' ' begin
                select @cCTX_LP = 'N'
                select @cCTX_DTLP = ' '
            end else begin
                select @cCTX_LP = 'Z'
                select @cCTX_DTLP = @cCT2_DTLP
            end
                                   
            ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ3###
             Where CQ3_FILIAL = @cFilial_CQ3
               and CQ3_DATA   = @cDATA
               and CQ3_CONTA  = @cCONTA
               and CQ3_CCUSTO = @cCUSTO
               and CQ3_MOEDA  = @cMOEDA
               and CQ3_TPSALD = @IN_TPSALDO
               and CQ3_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ3###
                select @iRecno = @iRecno + 1
                
                ##TRATARECNO @iRecno\
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ3### ( CQ3_FILIAL,  CQ3_CONTA, CQ3_CCUSTO, CQ3_MOEDA, CQ3_DATA, CQ3_TPSALD,  CQ3_SLBASE,   CQ3_DTLP,   CQ3_LP,   CQ3_STATUS,  CQ3_DEBITO, CQ3_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ3, @cCONTA,   @cCUSTO,    @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,          0, @iRecno )
                ##CHECK_TRANSACTION_COMMIT
                ##FIMTRATARECNO 
            end
           
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update CQ3###
               set CQ3_DEBITO = CQ3_DEBITO + @nCTX_DEBITO, CQ3_CREDIT = CQ3_CREDIT + @nCTX_CREDIT
             Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT
            
            /*====================
             Atualiza flag de LP
            ======================*/
            if @cCT2_DTLP != ' ' begin
                select @cITEM  = ' '
                select @cCLVL  = ' '
                select @cIdent  = ' '
                select @cTabela = 'CQ3'
                Exec CTB025_##  @cFilial_CQ3, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @IN_TRANSACTION, @OUT_RESULTADO OutPut
            end
            /* --------------------------------------------------------------------------------------------------------------
            Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0         
            Fetch CUR_CT3 into  @cFILCT2, @cCONTA, @cCUSTO, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
        end
        close CUR_CT3
        deallocate CUR_CT3
	    
        Declare CUR_CQ3 insensitive cursor for
		    Select CQ3_FILIAL, CQ3_CCUSTO, CQ3_CONTA, CQ3_MOEDA, Substring( CQ3_DATA, 1, 6 ), CQ3_DTLP, CQ3_LP, SUM(CQ3_DEBITO),SUM(CQ3_CREDIT)
		    From CQ3###
		    Where CQ3_FILIAL = @cFilial_CQ3
			    and CQ3_TPSALD = @IN_TPSALDO
			    and ( ( CQ3_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
			    and CQ3_DATA between @cDataI and @cDataF
                and CQ3_CONTA = @IN_CONTA
                and CQ3_CCUSTO = @IN_CUSTO
			    and D_E_L_E_T_= ' '
		    Group By CQ3_FILIAL, CQ3_CONTA ,CQ3_CCUSTO, CQ3_MOEDA, Substring( CQ3_DATA, 1, 6 ), CQ3_DTLP, CQ3_LP
		    order by 1,2,3,4,5,6,7
		    for read only
        Open CUR_CQ3
        Fetch CUR_CQ3 into  @cFILCT2, @cCUSTO, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
	   
        /*====================
            Gravação da CQ2
        ======================*/                 
        While (@@Fetch_status = 0 ) begin            
	        
            select @nCTX_DEBITO = @nVALORDeb
            select @nCTX_CREDIT = @nVALORCred
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'            
            select @iRecno  = 0

            ##UNIQUEKEY_START
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
	            From CQ2###
                Where CQ2_FILIAL = @cFilial_CQ2
                and CQ2_CONTA  = @cCONTA
                and CQ2_CCUSTO = @cCUSTO
                and CQ2_MOEDA  = @cMOEDA
                and CQ2_DATA   = @cDataF
                and CQ2_TPSALD = @IN_TPSALDO
                and CQ2_LP     = @cCTX_LP
                and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
	            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ2###
	            select @iRecno = @iRecno + 1	           
	            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
	            select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)

	            ##TRATARECNO @iRecno\
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ2### ( CQ2_FILIAL, CQ2_CONTA, CQ2_CCUSTO, CQ2_MOEDA, CQ2_DATA, CQ2_TPSALD,  CQ2_SLBASE,   CQ2_DTLP,   CQ2_LP,   CQ2_STATUS,   CQ2_DEBITO,   CQ2_CREDIT,   R_E_C_N_O_ )
                            values( @cFilial_CQ2, @cCONTA,   @cCUSTO,    @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,             0, @iRecno )
	            ##CHECK_TRANSACTION_COMMIT
	            ##FIMTRATARECNO
            end
	        
            select @nCTX_DEBITO  =  Round(@nCTX_DEBITO, 2)
            select @nCTX_CREDIT  =  Round(@nCTX_CREDIT, 2)

            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
			Update CQ2###
			      set CQ2_DTLP = @cCTX_DTLP,
                   CQ2_DEBITO = CQ2_DEBITO + @nCTX_DEBITO,
			          CQ2_CREDIT = CQ2_CREDIT + @nCTX_CREDIT
            Where R_E_C_N_O_  = @iRecno
            ##CHECK_TRANSACTION_COMMIT
            /* --------------------------------------------------------------------------------------------------------------
            Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
		    SELECT @fim_CUR = 0
            Fetch CUR_CQ3 into @cFILCT2, @cCUSTO, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ3
        deallocate CUR_CQ3
    
        select @cIdent = 'CTT'            
        Declare CUR_CTT insensitive cursor for
         Select CQ3_FILIAL, CQ3_CCUSTO, CQ3_MOEDA, CQ3_DATA, CQ3_DTLP, CQ3_LP, SUM(CQ3_DEBITO), SUM(CQ3_CREDIT)
           From CQ3###
          Where CQ3_FILIAL = @cFilial_CQ3
            and CQ3_CCUSTO = @IN_CUSTO
            and CQ3_DATA   = @IN_DATA
            and CQ3_TPSALD = @IN_TPSALDO
            and ( ( CQ3_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )                        
            and D_E_L_E_T_= ' '
         Group By CQ3_FILIAL, CQ3_CCUSTO, CQ3_MOEDA, CQ3_DATA, CQ3_DTLP, CQ3_LP
        order by 1, 2, 3, 4, 6
        for read only
        Open CUR_CTT
        Fetch CUR_CTT into  @cFILCT2, @cCUSTO, @cMOEDA, @cDATA, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        
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
               and CQ9_DATA   = @cDATA
               and CQ9_IDENT  = @cIdent
               and CQ9_CODIGO = @cCUSTO
               and CQ9_MOEDA  = @cMOEDA
               and CQ9_TPSALD = @IN_TPSALDO
               and CQ9_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
            
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
                select @iRecno = @iRecno + 1
                
                ##TRATARECNO @iRecno\    
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ9### ( CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA, CQ9_TPSALD,  CQ9_SLBASE,   CQ9_DTLP,   CQ9_LP,   CQ9_STATUS,   CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
                             values( @cFilial_CQ9, @cIdent,   @cCUSTO,    @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,          0,          0, @iRecno )
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
            Fetch CUR_CTT into  @cFILCT2, @cCUSTO, @cMOEDA, @cDATA, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CTT
        deallocate CUR_CTT
        
        Declare CUR_CQT insensitive cursor for
	     Select CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP, CQ9_LP, SUM(CQ9_DEBITO), SUM(CQ9_CREDIT)
	       From CQ9###
          Where CQ9_FILIAL = @cFilial_CQ9
            and CQ9_IDENT  = @cIdent
		    and CQ9_TPSALD = @IN_TPSALDO
            and CQ9_CODIGO = @IN_CUSTO
		    and ( ( CQ9_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
		    and CQ9_DATA between @cDataI and @cDataF
		    and D_E_L_E_T_= ' '
	     Group By CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP, CQ9_LP
	     order by 1,2,3,4,5,7
	    for read only
        Open CUR_CQT
        Fetch CUR_CQT into  @cFILCT2, @cIdent, @cCodigo, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
	    
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
               and CQ8_IDENT  = @cIdent
               and CQ8_CODIGO = @cCodigo
               and CQ8_MOEDA  = @cMOEDA
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
	            Insert into CQ8### ( CQ8_FILIAL, CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD,  CQ8_SLBASE,   CQ8_DTLP,   CQ8_LP, CQ8_STATUS,   CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                           values( @cFilial_CQ8, @cIdent,   @cCodigo,   @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,        0,          0, @iRecno )
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
            Fetch CUR_CQT into  @cFILCT2, @cIdent, @cCodigo, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQT
        deallocate CUR_CQT
    End
   
    /*
    #####################################
    # ATUALIZAR ITEM CONTABIL - CQ4/CQ5 #
    #####################################
    */
    If @IN_CALIAS = 'CQ4' begin
        
        Declare CUR_CT4 insensitive cursor for
        Select CT2_FILIAL, CONTA, CCUSTO, ITEM, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), TIPO
         From (  Select CT2_FILIAL, CT2_DEBITO CONTA, CT2_CCD CCUSTO, CT2_ITEMD ITEM, CT2_MOEDLC, CT2_DATA, CT2_DTLP, CT2_VALOR, '1' TIPO,
                         CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI
                        From CT2###
                        Where CT2_FILIAL = @cFilial_CT2                        
                        and CT2_DEBITO = @IN_CONTA
                        and CT2_DATA = @IN_DATA  
                        and CT2_CCD = @IN_CUSTO
                        and CT2_ITEMD = @IN_ITEM
                        and (CT2_DC = '1' or CT2_DC = '3')
                        and CT2_TPSALD = @IN_TPSALDO
                        and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )                                                                      
                        and D_E_L_E_T_= ' '                    
                    Union
                    Select CT2_FILIAL, CT2_CREDIT CONTA, CT2_CCC CCUSTO, CT2_ITEMC ITEM, CT2_MOEDLC, CT2_DATA, CT2_DTLP, CT2_VALOR, '2' TIPO,
                            CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI
                        From CT2###
                        Where CT2_FILIAL = @cFilial_CT2
                        and CT2_CREDIT = @IN_CONTA
                        and CT2_DATA = @IN_DATA
                        and CT2_CCC = @IN_CUSTO
                        and CT2_ITEMC = @IN_ITEM                                
                        and (CT2_DC = '2' or CT2_DC = '3')                        
                        and CT2_TPSALD = @IN_TPSALDO
                        and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )                        
                        and D_E_L_E_T_ = ' ' ) CT2TRB1
         Where NOT EXISTS (Select 1 
                            From CQA### CQA
                            Where CQA_FILCT2 = CT2_FILIAL
                            and CQA_DATA     = CT2_DATA 
                            and CQA_LOTE     = CT2_LOTE 
                            and CQA_SBLOTE   = CT2_SBLOTE
                            and CQA_DOC      = CT2_DOC 
                            and CQA_LINHA    = CT2_LINHA
                            and CQA_TPSALD   = CT2_TPSALD
                            and CQA_EMPORI   = CT2_EMPORI
                            and CQA_FILORI   = CT2_FILORI
                            and CQA_MOEDLC   = CT2_MOEDLC
                            and CQA.D_E_L_E_T_ = ' ')
        Group By CT2_FILIAL, CONTA, CCUSTO, ITEM, CT2_MOEDLC, CT2_DATA, CT2_DTLP, TIPO
        order by 1,2,3,4,5,6,7,9
        for read only
        Open CUR_CT4
        Fetch CUR_CT4 into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
        
        /*====================
            Gravação da CQ5
        ======================*/                 
        While (@@Fetch_status = 0 ) begin
            select @nCTX_DEBITO = 0
            select @nCTX_CREDIT = 0
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            select @cCTX_DTLP = ' '
            select @iRecno = 0

            if @cTIPO = '1' begin
                select @nCTX_DEBITO = Round(@nVALOR, 2)
                select @nCTX_CREDIT = 0
            end
            if @cTIPO = '2' begin
                select @nCTX_CREDIT = Round(@nVALOR, 2)
                select @nCTX_DEBITO = 0
            end
            if @cCT2_DTLP = ' ' begin
                select @cCTX_LP = 'N'
                select @cCTX_DTLP = ' '
            end else begin
                select @cCTX_LP = 'Z'
                select @cCTX_DTLP = @cCT2_DTLP
            end
                        
            ##UNIQUEKEY_START 
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ5###
             Where CQ5_FILIAL = @cFilial_CQ5
               and CQ5_DATA   = @cDATA
               and CQ5_CONTA  = @cCONTA
               and CQ5_CCUSTO = @cCUSTO
               and CQ5_ITEM   = @cITEM
               and CQ5_MOEDA  = @cMOEDA
               and CQ5_TPSALD = @IN_TPSALDO
               and CQ5_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
         
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ5###
                select @iRecno = @iRecno + 1
                
                ##TRATARECNO @iRecno\
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ5### ( CQ5_FILIAL,   CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, CQ5_MOEDA, CQ5_DATA, CQ5_TPSALD,  CQ5_SLBASE,   CQ5_DTLP,   CQ5_LP,   CQ5_STATUS,  CQ5_DEBITO, CQ5_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ5, @cCONTA,   @cCUSTO,    @cITEM,   @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,           0, @iRecno )
                ##CHECK_TRANSACTION_COMMIT
                ##FIMTRATARECNO
            end
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update CQ5###
               set CQ5_DEBITO = CQ5_DEBITO + @nCTX_DEBITO, CQ5_CREDIT = CQ5_CREDIT + @nCTX_CREDIT
             Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT
           
            /*====================
             Atualiza flag de LP
            ======================*/
            if @cCT2_DTLP != ' ' begin
                select @cCLVL   = ' '
                select @cIdent  = ' '
                select @cTabela = 'CQ5'
                Exec CTB025_##  @cFilial_CQ5, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @IN_TRANSACTION, @OUT_RESULTADO OutPut
            end
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CT4 into  @cFILCT2, @cCONTA, @cCUSTO, @cITEM, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
        end
        close CUR_CT4
        deallocate CUR_CT4
	    
      
        Declare CUR_CQ5 insensitive cursor for
         Select CQ5_FILIAL, CQ5_ITEM, CQ5_CCUSTO, CQ5_CONTA, CQ5_MOEDA, Substring( CQ5_DATA, 1, 6 ), CQ5_DTLP, CQ5_LP, SUM(CQ5_DEBITO), SUM(CQ5_CREDIT)
		   From CQ5###
		  Where CQ5_FILIAL = @cFilial_CQ5
            and CQ5_TPSALD = @IN_TPSALDO
            and ( ( CQ5_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
            and CQ5_DATA between @cDataI and @cDataF
            and CQ5_CONTA = @IN_CONTA
            and CQ5_CCUSTO = @IN_CUSTO
            and CQ5_ITEM = @IN_ITEM
            and D_E_L_E_T_= ' '
        Group By CQ5_FILIAL, CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, CQ5_MOEDA, Substring( CQ5_DATA, 1, 6 ), CQ5_DTLP, CQ5_LP
        order by 1,2,3,4,5,6, 7, 8
        for read only
        Open CUR_CQ5
        Fetch CUR_CQ5 into  @cFILCT2, @cITEM, @cCUSTO, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
	    
        /*====================
            Gravação da CQ4
        ======================*/                 
        While (@@Fetch_status = 0 ) begin            
           
            select @nCTX_DEBITO = Round(@nVALORDeb, 2)
            select @nCTX_CREDIT = Round(@nVALORCred, 2)
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            select @iRecno  = 0

            ##UNIQUEKEY_START 
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ4###
             Where CQ4_FILIAL = @cFilial_CQ4
               and CQ4_CONTA  = @cCONTA
               and CQ4_CCUSTO = @cCUSTO
               and CQ4_ITEM   = @cITEM
               and CQ4_MOEDA  = @cMOEDA
               and CQ4_DATA   = @cDataF
               and CQ4_TPSALD = @IN_TPSALDO
               and CQ4_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END

            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ4###
                select @iRecno = @iRecno + 1
                
                ##TRATARECNO @iRecno\
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ4### ( CQ4_FILIAL, CQ4_CONTA, CQ4_CCUSTO, CQ4_ITEM, CQ4_MOEDA, CQ4_DATA, CQ4_TPSALD,  CQ4_SLBASE,   CQ4_DTLP,   CQ4_LP,   CQ4_STATUS,  CQ4_DEBITO, CQ4_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ4, @cCONTA,  @cCUSTO,    @cITEM,   @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,          0, @iRecno )
                ##CHECK_TRANSACTION_COMMIT
                ##FIMTRATARECNO
            end
           
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update CQ4###
                set CQ4_DTLP   = @cCTX_DTLP,
	                CQ4_DEBITO = CQ4_DEBITO + @nCTX_DEBITO,
                    CQ4_CREDIT = CQ4_CREDIT + @nCTX_CREDIT
            Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQ5 into  @cFILCT2, @cITEM, @cCUSTO, @cCONTA, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ5
        deallocate CUR_CQ5   

        select @cIdent = 'CTD'                
        Declare CUR_CTD insensitive cursor for
         Select CQ5_FILIAL, CQ5_ITEM, CQ5_MOEDA, CQ5_DATA, CQ5_DTLP, CQ5_LP, SUM(CQ5_DEBITO), SUM(CQ5_CREDIT)
           From CQ5###
          Where CQ5_FILIAL = @cFilial_CT2
            and CQ5_ITEM   = @IN_ITEM
            and CQ5_DATA   = @IN_DATA
            and CQ5_TPSALD = @IN_TPSALDO
            and ( ( CQ5_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
            and D_E_L_E_T_= ' '
         Group By CQ5_FILIAL, CQ5_ITEM, CQ5_MOEDA, CQ5_DATA, CQ5_DTLP, CQ5_LP
         order by 1, 2, 3, 4, 6
        for read only
        Open CUR_CTD
        Fetch CUR_CTD into  @cFILCT2, @cITEM, @cMOEDA, @cDATA, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        
        /*====================
            Gravação da CQ9
        ======================*/                 
        While (@@Fetch_status = 0 ) begin
            select @cAux = 'CQ9'
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ9 OutPut
               
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
               and CQ9_DATA   = @cDATA
               and CQ9_IDENT  = @cIdent
               and CQ9_CODIGO = @cITEM
               and CQ9_MOEDA  = @cMOEDA
               and CQ9_TPSALD = @IN_TPSALDO
               and CQ9_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
		    
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
                select @iRecno = @iRecno + 1
                
                ##TRATARECNO @iRecno\
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ9### ( CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA, CQ9_TPSALD,  CQ9_SLBASE,   CQ9_DTLP,   CQ9_LP,   CQ9_STATUS,   CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
                             values( @cFilial_CQ9, @cIdent,   @cITEM,     @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,          0,          0, @iRecno )
                ##CHECK_TRANSACTION_COMMIT
                ##FIMTRATARECNO
            end
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update CQ9###
                set CQ9_DEBITO = CQ9_DEBITO + @nVALORDeb ,
                    CQ9_CREDIT = CQ9_CREDIT + @nVALORCred
                Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CTD into  @cFILCT2, @cITEM, @cMOEDA, @cDATA, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CTD
        deallocate CUR_CTD

	    Declare CUR_CQD insensitive cursor for
		 Select CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP, CQ9_LP, SUM(CQ9_DEBITO), SUM(CQ9_CREDIT)
		   From CQ9###
          Where CQ9_FILIAL = @cFilial_CQ9
            and CQ9_IDENT  = @cIdent
		    and CQ9_TPSALD = @IN_TPSALDO
		    and CQ9_CODIGO = @IN_ITEM
            and ( ( CQ9_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
		    and (CQ9_DATA between @cDataI and @cDataF)            
		    and D_E_L_E_T_= ' '
		 Group By CQ9_FILIAL, CQ9_IDENT ,CQ9_CODIGO , CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP, CQ9_LP
		 order by 1,2,3,4,5,7
		for read only
	    Open CUR_CQD
	    Fetch CUR_CQD into  @cFILCT2, @cIdent, @cCodigo, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
	    
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
               and CQ8_IDENT  = @cIdent
               and CQ8_CODIGO = @cCodigo
               and CQ8_MOEDA  = @cMOEDA
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
                Insert into CQ8### ( CQ8_FILIAL,   CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD,  CQ8_SLBASE,   CQ8_DTLP,   CQ8_LP,   CQ8_STATUS,   CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                             values( @cFilial_CQ8, @cIdent,   @cCodigo,   @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,          0,          0, @iRecno )
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
             Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQD into  @cFILCT2, @cIdent, @cCodigo, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
	    close CUR_CQD
	    deallocate CUR_CQD
    End

    /*
    #######################################
    # ATUALIZAR CLASSE DE VALOR - CQ6/CQ7 #
    #######################################
    */
    If @IN_CALIAS = 'CQ6' begin
              
        Declare CUR_CTI insensitive cursor for
        Select CT2_FILIAL, CLASSE, ITEM, CCUSTO, CONTA, CT2_MOEDLC, CT2_DATA, CT2_DTLP, SUM(CT2_VALOR), TIPO
        From( Select CT2_FILIAL, CT2_CLVLDB CLASSE, CT2_ITEMD ITEM, CT2_CCD CCUSTO, CT2_DEBITO CONTA, CT2_MOEDLC, CT2_DATA, CT2_DTLP, CT2_VALOR, '1' TIPO,
                        CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI
                    From CT2###
                    Where CT2_FILIAL = @cFilial_CT2
                    and CT2_DEBITO = @IN_CONTA
                    and CT2_DATA = @IN_DATA                    
                    and CT2_CCD = @IN_CUSTO
                    and CT2_ITEMD = @IN_ITEM
                    and CT2_CLVLDB = @IN_CLASSE
                    and (CT2_DC = '1' or CT2_DC = '3')                    
                    and CT2_TPSALD = @IN_TPSALDO
                    and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )                      
                    and D_E_L_E_T_= ' '                    
                Union
                    Select CT2_FILIAL, CT2_CLVLCR CLASSE, CT2_ITEMC ITEM, CT2_CCC CCUSTO, CT2_CREDIT CONTA, CT2_MOEDLC, CT2_DATA, CT2_DTLP, CT2_VALOR, '2' TIPO,
                            CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI
                    From CT2###
                   Where CT2_FILIAL = @cFilial_CT2
                    and CT2_CREDIT = @IN_CONTA
                    and CT2_DATA = @IN_DATA                    
                    and CT2_CCC = @IN_CUSTO
                    and CT2_ITEMC = @IN_ITEM
                    and CT2_CLVLCR = @IN_CLASSE
                    and (CT2_DC = '2' or CT2_DC = '3')                    
                    and CT2_TPSALD = @IN_TPSALDO
                    and ( ( CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )                    
                    and D_E_L_E_T_ = ' ' ) CT2TRB2
         Where NOT EXISTS (Select 1 
                            From CQA### CQA
                            Where CQA_FILCT2 = CT2_FILIAL
                            and CQA_DATA     = CT2_DATA 
                            and CQA_LOTE     = CT2_LOTE 
                            and CQA_SBLOTE   = CT2_SBLOTE
                            and CQA_DOC      = CT2_DOC 
                            and CQA_LINHA    = CT2_LINHA
                            and CQA_TPSALD   = CT2_TPSALD
                            and CQA_EMPORI   = CT2_EMPORI
                            and CQA_FILORI   = CT2_FILORI
                            and CQA_MOEDLC   = CT2_MOEDLC
                            and CQA.D_E_L_E_T_ = ' ')
        Group By CT2_FILIAL, CLASSE, ITEM, CCUSTO, CONTA, CT2_MOEDLC, CT2_DATA, CT2_DTLP, TIPO
        order by 1,2,3,4,5,6,7,8,10
      
        for read only
        Open CUR_CTI
        Fetch CUR_CTI into  @cFILCT2, @cCLVL, @cITEM, @cCUSTO, @cCONTA, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
        
        /*====================
            Gravação da CQ7
        ======================*/ 
        While (@@Fetch_status = 0 ) begin

            select @nCTX_DEBITO = 0
            select @nCTX_CREDIT = 0
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'
            select @cCTX_DTLP = ' '
            select @iRecno  = 0

            if @cTIPO = '1' begin
                select @nCTX_DEBITO = Round(@nVALOR, 2)
                select @nCTX_CREDIT = 0
            end
            if @cTIPO = '2' begin
                select @nCTX_CREDIT = Round(@nVALOR, 2)
                select @nCTX_DEBITO = 0
            end
         
            if @cCT2_DTLP = ' ' begin
                select @cCTX_LP = 'N'
                select @cCTX_DTLP = ' '
            end else begin
                select @cCTX_LP = 'Z'
                select @cCTX_DTLP = @cCT2_DTLP
            end
            
            ##UNIQUEKEY_START 
                select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
                From CQ7###
                Where CQ7_FILIAL = @cFilial_CQ7
                and CQ7_DATA   = @cDATA
                and CQ7_CONTA  = @cCONTA
                and CQ7_CCUSTO = @cCUSTO
                and CQ7_ITEM   = @cITEM
                and CQ7_CLVL   = @cCLVL
                and CQ7_MOEDA  = @cMOEDA
                and CQ7_TPSALD = @IN_TPSALDO
                and CQ7_LP     = @cCTX_LP
                and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
         
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ7###
                select @iRecno = @iRecno + 1

                ##TRATARECNO @iRecno\
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ7### ( CQ7_FILIAL,  CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL, CQ7_MOEDA, CQ7_DATA, CQ7_TPSALD,  CQ7_SLBASE,   CQ7_DTLP,   CQ7_LP, CQ7_STATUS,   CQ7_DEBITO, CQ7_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ7, @cCONTA,   @cCUSTO,    @cITEM,   @cCLVL,   @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,        0,          0, @iRecno )
                ##CHECK_TRANSACTION_COMMIT
                ##FIMTRATARECNO
            end
           
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update CQ7###
                set CQ7_DEBITO = CQ7_DEBITO + @nCTX_DEBITO, CQ7_CREDIT = CQ7_CREDIT + @nCTX_CREDIT
            Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT

            /*====================
             Atualiza flag de LP
            ======================*/
            if @cCT2_DTLP != ' ' begin
                select @cIdent  = ' '
                select @cTabela = 'CQ7'                
                Exec CTB025_##  @cFilial_CQ7, @cTabela, @cIdent, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cCT2_DTLP, @cMOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @IN_TRANSACTION, @OUT_RESULTADO OutPut
            end
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CTI into  @cFILCT2, @cCLVL, @cITEM, @cCUSTO, @cCONTA, @cMOEDA, @cDATA, @cCT2_DTLP, @nVALOR, @cTIPO
        end
        close CUR_CTI
        deallocate CUR_CTI
	   
        Declare CUR_CQ7 insensitive cursor for
        Select CQ7_FILIAL, CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL, CQ7_MOEDA, Substring( CQ7_DATA, 1, 6 ), CQ7_DTLP, CQ7_LP, SUM(CQ7_DEBITO), SUM(CQ7_CREDIT)
          From CQ7###
         Where CQ7_FILIAL = @cFilial_CQ7
	       and CQ7_TPSALD = @IN_TPSALDO
	       and ((CQ7_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0')
	       and CQ7_DATA between @cDataI and @cDataF
           and CQ7_CONTA  = @IN_CONTA
           and CQ7_CCUSTO = @IN_CUSTO
           and CQ7_ITEM   = @IN_ITEM
           and CQ7_CLVL   = @IN_CLASSE
	       and D_E_L_E_T_= ' '
        Group By CQ7_FILIAL, CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM, CQ7_CLVL, CQ7_MOEDA, Substring( CQ7_DATA, 1, 6 ), CQ7_DTLP, CQ7_LP
        order by 1,2,3,4,5,6,7,9
        for read only
        Open CUR_CQ7
        Fetch CUR_CQ7 into @cFILCT2,  @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cMOEDA, @cDATACQ, @cCTX_DTLP,@cCTX_LP, @nVALORDeb, @nVALORCred
        
        /*====================
            Gravação da CQ6
        ======================*/ 
        While (@@Fetch_status = 0 ) begin           
	      
            select @nCTX_DEBITO = Round(@nVALORDeb, 2)
            select @nCTX_CREDIT = Round(@nVALORCred, 2)
            select @cCTX_STATUS = '1'
            select @cCTX_SLBASE = 'S'          
            select @iRecno = 0

            ##UNIQUEKEY_START 
            select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
              From CQ6###
             Where CQ6_FILIAL = @cFilial_CQ6
               and CQ6_CONTA  = @cCONTA
               and CQ6_CCUSTO = @cCUSTO
               and CQ6_ITEM   = @cITEM
               and CQ6_CLVL   = @cCLVL
               and CQ6_MOEDA  = @cMOEDA
               and CQ6_DATA   = @cDataF
               and CQ6_TPSALD = @IN_TPSALDO
               and CQ6_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
                        
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ6###
                select @iRecno = @iRecno + 1
                
                ##TRATARECNO @iRecno\			 
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ6### ( CQ6_FILIAL,   CQ6_CONTA, CQ6_CCUSTO, CQ6_ITEM, CQ6_CLVL, CQ6_MOEDA, CQ6_DATA, CQ6_TPSALD,  CQ6_SLBASE,   CQ6_DTLP,   CQ6_LP, CQ6_STATUS,   CQ6_DEBITO, CQ6_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ6, @cCONTA,   @cCUSTO,    @cITEM,   @cCLVL,   @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,         0,          0, @iRecno )
                ##CHECK_TRANSACTION_COMMIT
                ##FIMTRATARECNO
            end
	    
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
	        Update CQ6###
		       set CQ6_DTLP    = @cCTX_DTLP, 
		           CQ6_DEBITO  = CQ6_DEBITO + @nCTX_DEBITO,
		           CQ6_CREDIT  = CQ6_CREDIT + @nCTX_CREDIT
		     Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT            
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQ7 into @cFILCT2,  @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cMOEDA, @cDATACQ, @cCTX_DTLP,@cCTX_LP, @nVALORDeb, @nVALORCred
        end
        close CUR_CQ7
        deallocate CUR_CQ7


        Select @cIdent = 'CTH'
        Declare CUR_CTH insensitive cursor for
        Select CQ7_FILIAL, CQ7_CLVL , CQ7_MOEDA, CQ7_DATA, CQ7_LP, CQ7_DTLP, SUM(CQ7_DEBITO), SUM(CQ7_CREDIT)
        From CQ7###
        Where CQ7_FILIAL   = @cFilial_CQ7
            and CQ7_CLVL   = @IN_CLASSE
            and CQ7_DATA   = @IN_DATA
            and CQ7_TPSALD = @IN_TPSALDO            
            and ( ( CQ7_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )            
            and D_E_L_E_T_= ' '
        Group By CQ7_FILIAL, CQ7_CLVL , CQ7_MOEDA, CQ7_DATA, CQ7_LP, CQ7_DTLP
        order by 1, 2, 3, 4, 5
        for read only
        Open CUR_CTH
        Fetch CUR_CTH into  @cFILCT2, @cCLVL, @cMOEDA, @cDATA, @cCTX_LP, @cCTX_DTLP,@nVALORDeb, @nVALORCred
        
        /*====================
            Gravação da CQ9
        ======================*/ 
        While (@@Fetch_status = 0 ) begin
            select @cAux = 'CQ9'
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CQ9 OutPut
               
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
               and CQ9_DATA   = @cDATA
               and CQ9_IDENT  = @cIdent
               and CQ9_CODIGO = @cCLVL
               and CQ9_MOEDA  = @cMOEDA
               and CQ9_TPSALD = @IN_TPSALDO
               and CQ9_LP     = @cCTX_LP
               and D_E_L_E_T_ = ' '
            ##UNIQUEKEY_END
         
            If @iRecno = 0 begin
                select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
                select @iRecno = @iRecno + 1
               
                ##TRATARECNO @iRecno\
                ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                Insert into CQ9### ( CQ9_FILIAL,   CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA, CQ9_TPSALD,  CQ9_SLBASE,   CQ9_DTLP,   CQ9_LP,   CQ9_STATUS,   CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
                             values( @cFilial_CQ9, @cIdent,   @cCLVL,     @cMOEDA,   @cDATA,   @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,          0,          0, @iRecno )
                ##CHECK_TRANSACTION_COMMIT
                ##FIMTRATARECNO
            end
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update CQ9###
                set CQ9_DEBITO = CQ9_DEBITO + @nVALORDeb ,
                    CQ9_CREDIT = CQ9_CREDIT + @nVALORCred
                Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT            
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CTH into  @cFILCT2, @cCLVL, @cMOEDA, @cDATA, @cCTX_LP, @cCTX_DTLP,@nVALORDeb, @nVALORCred
        end
        close CUR_CTH
        deallocate CUR_CTH       
	   
	    
	    Declare CUR_CQH insensitive cursor for
         Select CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP, CQ9_LP, SUM(CQ9_DEBITO), SUM(CQ9_CREDIT)
           From CQ9###
          Where CQ9_FILIAL = @cFilial_CQ9
            and CQ9_IDENT  = @cIdent
            and CQ9_TPSALD = @IN_TPSALDO
            and CQ9_CODIGO = @IN_CLASSE
            and ( ( CQ9_MOEDA = @IN_MOEDA and @IN_LMOEDAESP = '1' ) or @IN_LMOEDAESP = '0' )
            and (CQ9_DATA between @cDataI and @cDataF)
            and D_E_L_E_T_= ' '
		 Group By CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, Substring( CQ9_DATA, 1, 6 ), CQ9_DTLP, CQ9_LP
		 order by 1,2,3,4,5,7
		for read only
	    Open CUR_CQH
	    Fetch CUR_CQH into @cFILCT2, @cIdent, @cCodigo, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
         
        /*====================
            Gravação da CQ9
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
               and CQ8_IDENT  = @cIdent
               and CQ8_CODIGO = @cCodigo
               and CQ8_MOEDA  = @cMOEDA
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
	            Insert into CQ8### ( CQ8_FILIAL,  CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD,  CQ8_SLBASE,   CQ8_DTLP,   CQ8_LP,   CQ8_STATUS,   CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                            values( @cFilial_CQ8, @cIdent,   @cCodigo,   @cMOEDA,   @cDataF,  @IN_TPSALDO, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS,           0,          0, @iRecno )
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
		        Where R_E_C_N_O_ = @iRecno
            ##CHECK_TRANSACTION_COMMIT            
            /* --------------------------------------------------------------------------------------------------------------
                Tratamento para Postgres
            -------------------------------------------------------------------------------------------------------------- */
            SELECT @fim_CUR = 0
            Fetch CUR_CQH into @cFILCT2, @cIdent, @cCodigo, @cMOEDA, @cDATACQ, @cCTX_DTLP, @cCTX_LP, @nVALORDeb, @nVALORCred
        end
	    close CUR_CQH
        deallocate CUR_CQH 
    End

    /*===================================
        Se a execucao foi OK retorna '1'
    ===================================== */
    select @OUT_RESULTADO = '1'
end

