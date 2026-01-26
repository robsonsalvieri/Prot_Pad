##IF_001({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo('CT0',,'05') .And. FWAliasInDic('QL6') .And. CT2->(FieldPos('CT2_EC05DB'))>0})
Create Procedure CTB184_##(
   @IN_FILIAL     Char( 'CQ0_FILIAL' ),
   @IN_OPER       Char( 01 ),
   @IN_DC         Char( 01 ),
   @IN_CONTAD     Char( 'CQ0_CONTA' ),
   @IN_CONTAC     Char( 'CQ0_CONTA' ),
   @IN_CUSTOD     Char( 'CQ2_CCUSTO' ),
   @IN_CUSTOC     Char( 'CQ2_CCUSTO' ),
   @IN_ITEMD      Char( 'CQ4_ITEM' ),
   @IN_ITEMC      Char( 'CQ4_ITEM' ),
   @IN_CLVLD      Char( 'CQ6_CLVL' ), 
   @IN_CLVLC      Char( 'CQ6_CLVL' ), 
   @IN_EC05DB     Char( 'CT2_EC05DB' ),
   @IN_EC05CR     Char( 'CT2_EC05CR' ),
   @IN_MOEDA      Char( 'CQ0_MOEDA' ),
   @IN_DATA       Char( 08 ),
   @IN_TPSALDO    Char( 'CQ0_TPSALD' ),
   @IN_DTLP       Char( 08 ),
   @IN_VALOR      Float,
   @IN_INTEGRIDADE   Char( 01 ),
   @IN_TRANSACTION Char(01),
   @OUT_RESULT    Char( 01 ) OutPut

)
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA102.PRW </s>
    Descricao       - <d>  Atualiza Débito</d>
    Funcao do Siga  -      CTB102Proc()
    Entrada         - <ri> @IN_FILIAL       - Filial corrente da manutencao do arquivo de lanctos
						         @IN_OPER         - Operacao Aritmética ( '+' = Somar '-' = Subtrair )
                           @IN_DC           - Natureza do Lancto (1-Débito, 2-Crédito, 3-Partida Dobrada)
                           @IN_CONTAD       - Conta a Débito
                           @IN_CONTAC       - Conta a Crédito
                           @IN_CUSTOD       - C.Custo a Débito
                           @IN_CUSTOC       - C.Custo a Crédito
                           @IN_ITEMD        - Item  a Débito
                           @IN_ITEMC        - Item a Crédito
                           @IN_CLVLD        - Classe de Valor a Débito
                           @IN_CLVLC        - Classe de Valor a Crédito
                           @IN_EC05DB       - Entidade 05 Débito
                           @IN_EC05CR       - Entidade 05 Crédito
                           @IN_MOEDA        - Moeda do Lancto
                           @IN_DATA         - Data do Lancto
                           @IN_TPSALDO      - Tipo de Saldo
                           @IN_DTLP         - Data de Apuracao de Lp
                           @IN_VALOR        - Valor Atual
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.   </ri>
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     229/09/2005
    
-------------------------------------------------------------------------------------- */
declare @cAuxDC      VarChar( 01 )
declare @cLp         Char( 'CQ0_LP' )
declare @cSlBase     Char( 'CQ0_SLBASE' )
declare @cStatus     Char( 'CQ0_STATUS' )
declare @iRecno      Integer
declare @nValor      Float
declare @cDataF      Char( 08 )

begin
   
    select @OUT_RESULT = '0'
    select @nValor = Round(@IN_VALOR , 2)
    /* ------------------------------------------------------------- 
        Se for negativo, multiplico por -1
        ------------------------------------------------------------- */
    If @IN_OPER = '-' begin
        select @nValor = Round(@IN_VALOR * (-1), 2)
    End
    /* ------------------------------------------------------------- 
        Marcacao de saldo base e Status
        ------------------------------------------------------------- */
    select @cSlBase = 'S'
    select @cStatus = '1'
    /* ------------------------------------------------------------- 
        Ultimo dia do MES para o saldo do Mes
        ------------------------------------------------------------- */
    Exec LASTDAY_## @IN_DATA, @cDataF OutPut
    /* ------------------------------------------------------------------------------------
        Inicio Atualizacao DEBITO NA TABELA QL7 DIA - Saldo por CONTA + CCUSTO + ITEM + CLVL
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ------------------------------------------------------------------------------------ */
    If @IN_EC05DB != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do QL7
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a ctaD+CustoD+ItemD+ClvlD existe na tabela de saldos QL7
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From QL7###
        Where QL7_FILIAL = @IN_FILIAL
            and QL7_CONTA  = @IN_CONTAD
            and QL7_CCUSTO = @IN_CUSTOD
            and QL7_ITEM   = @IN_ITEMD
            and QL7_CLVL   = @IN_CLVLD
            and QL7_ENT05  = @IN_EC05DB
            and QL7_MOEDA  = @IN_MOEDA
            and QL7_TPSALD = @IN_TPSALDO
            and QL7_DATA   = @IN_DATA
            and QL7_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
         
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From QL7###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Insert into QL7###( QL7_FILIAL, QL7_CONTA,  QL7_CCUSTO, QL7_ITEM,  QL7_CLVL, QL7_ENT05, QL7_MOEDA, QL7_TPSALD,  QL7_DATA, QL7_DEBITO, QL7_SLBASE, QL7_STATUS, QL7_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD, @IN_CLVLD, @IN_EC05DB, @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0,  @cSlBase,   @cStatus,   @cLp,   @iRecno )
            ##CHECK_TRANSACTION_COMMIT
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um update
        --------------------------------------------------------------------- */
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        Update QL7###
        Set QL7_DEBITO = QL7_DEBITO + @nValor
        Where R_E_C_N_O_ = @iRecno
        ##CHECK_TRANSACTION_COMMIT
    End
    /* -------------------------------------------------------------------
        Inicio Atualizacao Credito na tabela QL7 - Saldo cta+Custo+Item+Clvl
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ------------------------------------------------------------------------------------ */
    If @IN_EC05CR != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' )  begin
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /* ---------------------------------------------------------------------
            Verifica se a ctaC+CustoC+ItemC+clvlC existe na tabela de saldos QL7
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From QL7###
        Where QL7_FILIAL = @IN_FILIAL
            and QL7_CONTA  = @IN_CONTAC
            and QL7_CCUSTO = @IN_CUSTOC
            and QL7_ITEM   = @IN_ITEMC
            and QL7_CLVL   = @IN_CLVLC
            and QL7_ENT05  = @IN_EC05CR
            and QL7_MOEDA  = @IN_MOEDA
            and QL7_TPSALD = @IN_TPSALDO
            and QL7_DATA   = @IN_DATA
            and QL7_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
         
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From QL7###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Insert into QL7###( QL7_FILIAL, QL7_CONTA,  QL7_CCUSTO, QL7_ITEM,  QL7_CLVL, QL7_ENT05, QL7_MOEDA, QL7_TPSALD,  QL7_DATA, QL7_CREDIT, QL7_SLBASE, QL7_STATUS, QL7_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC, @IN_CLVLC, @IN_EC05CR, @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0,  @cSlBase,   @cStatus,   @cLp,   @iRecno )
            ##CHECK_TRANSACTION_COMMIT
            ##FIMTRATARECNO
        end
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        UpDate QL7###
        Set QL7_CREDIT = QL7_CREDIT + @nValor
        Where R_E_C_N_O_ = @iRecno
        ##CHECK_TRANSACTION_COMMIT
    End 
    /* ---------------------------------------------------------------------
        Exclui os registros de saldos na tabela QL7 c/deb e cred Zerados
        --------------------------------------------------------------------- */
    If @IN_INTEGRIDADE = '1' begin
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        Update QL7###
            Set D_E_L_E_T_   = '*'
        Where QL7_FILIAL   = @IN_FILIAL
            and Round(QL7_DEBITO, 2) = 0.00
            and Round(QL7_CREDIT, 2) = 0.00
            and QL7_DATA     = @IN_DATA
            and  ((QL7_CONTA = @IN_CONTAC AND QL7_CCUSTO = @IN_CUSTOC AND QL7_ITEM = @IN_ITEMC AND QL7_CLVL = @IN_CLVLC AND QL7_ENT05 = @IN_EC05CR) 
                or (QL7_CONTA = @IN_CONTAD AND QL7_CCUSTO = @IN_CUSTOD AND QL7_ITEM = @IN_ITEMD AND QL7_CLVL = @IN_CLVLD AND QL7_ENT05 = @IN_EC05DB))
            and QL7_TPSALD   = @IN_TPSALDO
            and QL7_MOEDA    = @IN_MOEDA
            and QL7_LP       = @cLp
            and D_E_L_E_T_   = ' '
        ##CHECK_TRANSACTION_COMMIT
      
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        delete from QL7###
        Where QL7_FILIAL  = @IN_FILIAL
            and Round(QL7_DEBITO, 2) = 0.00
            and Round(QL7_CREDIT, 2) = 0.00
            and QL7_DATA     = @IN_DATA
            and  ((QL7_CONTA = @IN_CONTAC AND QL7_CCUSTO = @IN_CUSTOC AND QL7_ITEM = @IN_ITEMC AND QL7_CLVL = @IN_CLVLC AND QL7_ENT05 = @IN_EC05CR) 
                or (QL7_CONTA = @IN_CONTAD AND QL7_CCUSTO = @IN_CUSTOD AND QL7_ITEM = @IN_ITEMD AND QL7_CLVL = @IN_CLVLD AND QL7_ENT05 = @IN_EC05DB))
            and QL7_TPSALD   = @IN_TPSALDO
                and QL7_MOEDA    = @IN_MOEDA
            and QL7_LP       = @cLp
                and D_E_L_E_T_   = '*'
            ##CHECK_TRANSACTION_COMMIT
    end else begin
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        delete from QL7###
        Where QL7_FILIAL  = @IN_FILIAL
            and Round(QL7_DEBITO, 2) = 0.00
            and Round(QL7_CREDIT, 2) = 0.00
            and QL7_DATA     = @IN_DATA
            and  ((QL7_CONTA = @IN_CONTAC AND QL7_CCUSTO = @IN_CUSTOC AND QL7_ITEM = @IN_ITEMC AND QL7_CLVL = @IN_CLVLC AND QL7_ENT05 = @IN_EC05CR) 
                or (QL7_CONTA = @IN_CONTAD AND QL7_CCUSTO = @IN_CUSTOD AND QL7_ITEM = @IN_ITEMD AND QL7_CLVL = @IN_CLVLD AND QL7_ENT05 = @IN_EC05DB))
            and QL7_TPSALD   = @IN_TPSALDO
                and QL7_MOEDA    = @IN_MOEDA
            and QL7_LP       = @cLp
                and D_E_L_E_T_   = ' '
            ##CHECK_TRANSACTION_COMMIT
    End
    /* ------------------------------------------------------------------------------------
        Inicio Atualizacao DEBITO NA TABELA QL6 MES - Saldo por CONTA + CCUSTO + ITEM + CLVL
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ------------------------------------------------------------------------------------ */
    If @IN_EC05DB != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do QL6
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a ctaD+CustoD+ItemD+ClvlD existe na tabela de saldos QL6
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From QL6###
        Where QL6_FILIAL = @IN_FILIAL
            and QL6_CONTA  = @IN_CONTAD
            and QL6_CCUSTO = @IN_CUSTOD
            and QL6_ITEM   = @IN_ITEMD
            and QL6_CLVL   = @IN_CLVLD
            and QL6_ENT05  = @IN_EC05DB
            and QL6_MOEDA  = @IN_MOEDA
            and QL6_TPSALD = @IN_TPSALDO
            and QL6_DATA   = @cDataF
            and QL6_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
         
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From QL6###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Insert into QL6###( QL6_FILIAL, QL6_CONTA,  QL6_CCUSTO, QL6_ITEM,  QL6_CLVL,  QL6_ENT05,  QL6_MOEDA, QL6_TPSALD, QL6_DATA, QL6_DEBITO, QL6_SLBASE, QL6_STATUS, QL6_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAD, @IN_CUSTOD, @IN_ITEMD, @IN_CLVLD, @IN_EC05DB, @IN_MOEDA, @IN_TPSALDO, @cDataF,           0,  @cSlBase,   @cStatus,   @cLp,   @iRecno )
            ##CHECK_TRANSACTION_COMMIT
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um update
        --------------------------------------------------------------------- */
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        Update QL6###
        Set QL6_DEBITO = QL6_DEBITO + @nValor
        Where R_E_C_N_O_ = @iRecno
        ##CHECK_TRANSACTION_COMMIT
    End
    /* -------------------------------------------------------------------
        Inicio Atualizacao Credito na tabela QL6 - Saldo cta+Custo+Item+Clvl
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ------------------------------------------------------------------------------------ */
    If @IN_EC05CR != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' )  begin
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /* ---------------------------------------------------------------------
            Verifica se a ctaC+CustoC+ItemC+clvlC existe na tabela de saldos QL6
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From QL6###
        Where QL6_FILIAL = @IN_FILIAL
            and QL6_CONTA  = @IN_CONTAC
            and QL6_CCUSTO = @IN_CUSTOC
            and QL6_ITEM   = @IN_ITEMC
            and QL6_CLVL   = @IN_CLVLC
            and QL6_ENT05  = @IN_EC05CR
            and QL6_MOEDA  = @IN_MOEDA
            and QL6_TPSALD = @IN_TPSALDO
            and QL6_DATA   = @cDataF
            and QL6_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
         
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From QL6###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Insert into QL6###( QL6_FILIAL, QL6_CONTA,  QL6_CCUSTO, QL6_ITEM,  QL6_CLVL, QL6_ENT05,   QL6_MOEDA, QL6_TPSALD,  QL6_DATA, QL6_CREDIT, QL6_SLBASE, QL6_STATUS, QL6_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, @IN_CONTAC, @IN_CUSTOC, @IN_ITEMC, @IN_CLVLC, @IN_EC05CR, @IN_MOEDA, @IN_TPSALDO, @cDataF,           0,  @cSlBase,   @cStatus,   @cLp,   @iRecno )
            ##CHECK_TRANSACTION_COMMIT
            ##FIMTRATARECNO
        end 
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        UpDate QL6###
        Set QL6_CREDIT = QL6_CREDIT + @nValor
        Where R_E_C_N_O_ = @iRecno
        ##CHECK_TRANSACTION_COMMIT
    End 
    /* ---------------------------------------------------------------------
        Exclui os registros de saldos na tabela QL6 c/deb e cred Zerados
        --------------------------------------------------------------------- */
    If @IN_INTEGRIDADE = '1' begin
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        Update QL6###
            Set D_E_L_E_T_   = '*'
        Where QL6_FILIAL   = @IN_FILIAL
            and Round(QL6_DEBITO, 2) = 0.00
            and Round(QL6_CREDIT, 2) = 0.00
            and QL6_DATA     = @cDataF
            and  ((QL6_CONTA = @IN_CONTAC AND QL6_CCUSTO = @IN_CUSTOC AND QL6_ITEM = @IN_ITEMC AND QL6_CLVL = @IN_CLVLC AND QL6_ENT05 = @IN_EC05CR) 
                or (QL6_CONTA = @IN_CONTAD AND QL6_CCUSTO = @IN_CUSTOD AND QL6_ITEM = @IN_ITEMD AND QL6_CLVL = @IN_CLVLD AND QL6_ENT05 = @IN_EC05DB))
            and QL6_TPSALD   = @IN_TPSALDO
            and QL6_MOEDA    = @IN_MOEDA
            and QL6_LP       =  @cLp
            and D_E_L_E_T_   = ' '
        ##CHECK_TRANSACTION_COMMIT
      
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        delete from QL6###
        Where QL6_FILIAL  = @IN_FILIAL
            and Round(QL6_DEBITO, 2) = 0.00
            and Round(QL6_CREDIT, 2) = 0.00
            and QL6_DATA     = @cDataF
            and  ((QL6_CONTA = @IN_CONTAC AND QL6_CCUSTO = @IN_CUSTOC AND QL6_ITEM = @IN_ITEMC AND QL6_CLVL = @IN_CLVLC AND QL6_ENT05 = @IN_EC05CR) 
                or (QL6_CONTA = @IN_CONTAD AND QL6_CCUSTO = @IN_CUSTOD AND QL6_ITEM = @IN_ITEMD AND QL6_CLVL = @IN_CLVLD AND QL6_ENT05 = @IN_EC05DB))
            and QL6_TPSALD   = @IN_TPSALDO
                and QL6_MOEDA    = @IN_MOEDA
            and QL6_LP       = @cLp
                and D_E_L_E_T_   = '*'
        ##CHECK_TRANSACTION_COMMIT
    end else begin
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        delete from QL6###
        Where QL6_FILIAL  = @IN_FILIAL
            and Round(QL6_DEBITO, 2) = 0.00
            and Round(QL6_CREDIT, 2) = 0.00
            and QL6_DATA     = @cDataF
            and  ((QL6_CONTA = @IN_CONTAC AND QL6_CCUSTO = @IN_CUSTOC AND QL6_ITEM = @IN_ITEMC AND QL6_CLVL = @IN_CLVLC AND QL6_ENT05 = @IN_EC05CR) 
                or (QL6_CONTA = @IN_CONTAD AND QL6_CCUSTO = @IN_CUSTOD AND QL6_ITEM = @IN_ITEMD AND QL6_CLVL = @IN_CLVLD AND QL6_ENT05 = @IN_EC05DB))
            and QL6_TPSALD   = @IN_TPSALDO
                and QL6_MOEDA    = @IN_MOEDA
            and QL6_LP       = @cLp
                and D_E_L_E_T_   = ' '
        ##CHECK_TRANSACTION_COMMIT
    End
    /* -----------------------------------------------------------------------------
        Inicio Atualizacao DEBITO NA TABELA CQ9 DIA - Saldo por Entidade CLVL
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_EC05DB != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
        /*---------------------------------------------------------------
        Inicio Atualizacao Debito na tabela CQ9 - SALDO POR ENTIDADE CC
        --------------------------------------------------------------- */
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do CQ9
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a CustoD existe na tabela de saldos CQ9 MENSAL
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From CQ9###
        Where CQ9_FILIAL = @IN_FILIAL
            and CQ9_IDENT  = 'CV0'
            and CQ9_CODIGO = @IN_EC05DB
            and CQ9_MOEDA  = @IN_MOEDA
            and CQ9_TPSALD = @IN_TPSALDO
            and CQ9_DATA   = @IN_DATA
            and CQ9_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ9###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO \@iRecno
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Insert into CQ9###( CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_TPSALD,  CQ9_DATA, CQ9_DEBITO, CQ9_SLBASE, CQ9_STATUS, CQ9_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, 'CV0',     @IN_EC05DB,  @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0,  @cSlBase,   @cStatus,   @cLp,   @iRecno )
            ##CHECK_TRANSACTION_COMMIT
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um update
        --------------------------------------------------------------------- */
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        Update CQ9###
        Set CQ9_DEBITO = CQ9_DEBITO + @nValor
        Where R_E_C_N_O_ = @iRecno
        ##CHECK_TRANSACTION_COMMIT
    End
    /*----------------------------------------------------------------------
        Inicio Atualizacao CREDITO NA TABELA CQ9 - Saldo por ENTIDADE ITEM DIA
        ---------------------------------------------------------------------- */
    If @IN_EC05CR != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' )  begin
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do CQ9
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a ctaC+CustoC existe na tabela de saldos CQ9
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CQ9###
        Where CQ9_FILIAL = @IN_FILIAL
            and CQ9_IDENT  = 'CV0'
            and CQ9_CODIGO = @IN_EC05CR
            and CQ9_MOEDA  = @IN_MOEDA
            and CQ9_TPSALD = @IN_TPSALDO
            and CQ9_DATA   = @IN_DATA
            and CQ9_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ9###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Insert into CQ9###( CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_TPSALD,  CQ9_DATA, CQ9_CREDIT, CQ9_SLBASE, CQ9_STATUS, CQ9_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, 'CV0',     @IN_EC05CR,  @IN_MOEDA, @IN_TPSALDO, @IN_DATA,          0,  @cSlBase,   @cStatus,   @cLp,   @iRecno )
            ##CHECK_TRANSACTION_COMMIT
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um update
        --------------------------------------------------------------------- */
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        UpDate CQ9###
        Set CQ9_CREDIT = CQ9_CREDIT + @nValor
        Where R_E_C_N_O_ = @iRecno
        ##CHECK_TRANSACTION_COMMIT
    End 
    /* ---------------------------------------------------------------------
        Exclui os registros de saldos na tabela CQ9 c/deb e cred Zerados
        --------------------------------------------------------------------- */
    If @IN_INTEGRIDADE = '1' begin
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        UpDate CQ9###
            Set D_E_L_E_T_   = '*'
        Where CQ9_FILIAL   = @IN_FILIAL
            and Round(CQ9_DEBITO, 2) = 0.00
            and Round(CQ9_CREDIT, 2) = 0.00
   	    and CQ9_DATA     = @IN_DATA
            and ((CQ9_IDENT  = 'CV0' AND CQ9_CODIGO = @IN_EC05CR) or (CQ9_IDENT  = 'CV0' AND CQ9_CODIGO = @IN_EC05DB))
            and CQ9_TPSALD   = @IN_TPSALDO
            and CQ9_MOEDA    = @IN_MOEDA
            and CQ9_LP       = @cLp
            and D_E_L_E_T_   = ' '
        ##CHECK_TRANSACTION_COMMIT
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        delete from CQ9###
        Where CQ9_FILIAL   = @IN_FILIAL
            and Round(CQ9_DEBITO, 2) = 0.00
            and Round(CQ9_CREDIT, 2) = 0.00
            and CQ9_DATA     = @IN_DATA
            and ((CQ9_IDENT  = 'CV0' AND CQ9_CODIGO = @IN_EC05CR) or (CQ9_IDENT  = 'CV0' AND CQ9_CODIGO = @IN_EC05DB))
            and CQ9_TPSALD   = @IN_TPSALDO
            and CQ9_MOEDA    = @IN_MOEDA
            and CQ9_LP       = @cLp
            and D_E_L_E_T_   = '*'
        ##CHECK_TRANSACTION_COMMIT
    end else begin
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        delete from CQ9###
        Where CQ9_FILIAL  = @IN_FILIAL
            and Round(CQ9_DEBITO, 2) = 0.00
            and Round(CQ9_CREDIT, 2) = 0.00
            and CQ9_DATA     = @IN_DATA
            and ((CQ9_IDENT  = 'CTH' AND CQ9_CODIGO = @IN_EC05CR) or (CQ9_IDENT  = 'CTH' AND CQ9_CODIGO = @IN_EC05DB))
            and CQ9_TPSALD   = @IN_TPSALDO
            and CQ9_MOEDA    = @IN_MOEDA
            and CQ9_LP       = @cLp
            and D_E_L_E_T_   = ' '
        ##CHECK_TRANSACTION_COMMIT
    End
    /* -----------------------------------------------------------------------------
        Inicio Atualizacao DEBITO NA TABELA CQ8 MES - Saldo por ENTIDADE ITEM
        Se @IN_DC = '1', Debito, '2', Credito , se '3', atualizo a Debito e a Credito
        ----------------------------------------------------------------------------- */      
    If @IN_EC05DB != ' ' and ( @IN_DC = '1' or  @IN_DC = '3' )  begin
        /*---------------------------------------------------------------
        Inicio Atualizacao Debito na tabela CQ8 - Saldo por CCUSTO
        --------------------------------------------------------------- */
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do CQ8
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se CustoD existe na tabela de saldos CQ8 MENSAL
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull(Min( R_E_C_N_O_ ), 0)
        From CQ8###
        Where CQ8_FILIAL = @IN_FILIAL
            and CQ8_IDENT  = 'CV0'
            and CQ8_CODIGO = @IN_EC05DB
            and CQ8_MOEDA  = @IN_MOEDA
            and CQ8_TPSALD = @IN_TPSALDO
            and CQ8_DATA   = @cDataF
            and CQ8_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ8###
            select @iRecno = @iRecno + 1
            
            ##TRATARECNO \@iRecno
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Insert into CQ8###( CQ8_FILIAL, CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_TPSALD,  CQ8_DATA, CQ8_DEBITO, CQ8_SLBASE, CQ8_STATUS, CQ8_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, 'CV0',     @IN_EC05DB,  @IN_MOEDA, @IN_TPSALDO, @cDataF,           0,   @cSlBase,    @cStatus,  @cLp,   @iRecno )
            ##CHECK_TRANSACTION_COMMIT
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um update
        --------------------------------------------------------------------- */
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        Update CQ8###
        Set CQ8_DEBITO = CQ8_DEBITO + @nValor
        Where R_E_C_N_O_ = @iRecno
        ##CHECK_TRANSACTION_COMMIT
    End
    /*----------------------------------------------------------------------
        Inicio Atualizacao CREDITO NA TABELA CQ8 - Saldo por ENTIDADE MES
        ---------------------------------------------------------------------- */
    If @IN_EC05CR != ' ' and ( @IN_DC = '2' or  @IN_DC = '3' )  begin
        select @cLp = 'N'
        If @IN_DTLP != ' ' begin
            select @cLp = 'Z'
        end
        /*---------------------------------------------------------------
        Inicia Atualização do CQ8
        --------------------------------------------------------------- */
        /* ---------------------------------------------------------------------
            Verifica se a CustoC existe na tabela de saldos CQ8
            --------------------------------------------------------------------- */
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
    		    -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0 
        ##UNIQUEKEY_START
        Select @iRecno = IsNull( Min(R_E_C_N_O_ ), 0)
        From CQ8###
        Where CQ8_FILIAL = @IN_FILIAL
            and CQ8_IDENT  = 'CV0'
            and CQ8_CODIGO = @IN_EC05CR
            and CQ8_MOEDA  = @IN_MOEDA
            and CQ8_TPSALD = @IN_TPSALDO
            and CQ8_DATA   = @cDataF
            and CQ8_LP     = @cLp
            and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
      
        If @iRecno = 0 begin
            select @iRecno = IsNull(Max( R_E_C_N_O_), 0) From CQ8###
            select @iRecno = @iRecno + 1
         
            ##TRATARECNO @iRecno\
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Insert into CQ8###( CQ8_FILIAL, CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_TPSALD,  CQ8_DATA, CQ8_CREDIT, CQ8_SLBASE, CQ8_STATUS, CQ8_LP, R_E_C_N_O_ )
                        Values( @IN_FILIAL, 'CV0',     @IN_EC05CR,  @IN_MOEDA, @IN_TPSALDO, @cDataF,           0,   @cSlBase,   @cStatus,   @cLp,   @iRecno )
            ##CHECK_TRANSACTION_COMMIT
            ##FIMTRATARECNO
        end
        /* ---------------------------------------------------------------------
        Se achou efetua um update
        --------------------------------------------------------------------- */
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        UpDate CQ8###
        Set CQ8_CREDIT = CQ8_CREDIT + @nValor
        Where R_E_C_N_O_ = @iRecno
        ##CHECK_TRANSACTION_COMMIT
    End 
    /* ---------------------------------------------------------------------
        Exclui os registros de saldos na tabela CQ8 c/deb e cred Zerados
        --------------------------------------------------------------------- */
    If @IN_INTEGRIDADE = '1' begin
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        UpDate CQ8###
            Set D_E_L_E_T_   = '*'
        Where CQ8_FILIAL   = @IN_FILIAL
            and Round(CQ8_DEBITO, 2) = 0.00
            and Round(CQ8_CREDIT, 2) = 0.00
   	    and CQ8_DATA     = @cDataF
            and ((CQ8_IDENT  = 'CV0' AND CQ8_CODIGO = @IN_EC05CR) or (CQ8_IDENT  = 'CV0' AND CQ8_CODIGO = @IN_EC05CR))
            and CQ8_TPSALD   = @IN_TPSALDO
            and CQ8_MOEDA    = @IN_MOEDA
            and CQ8_LP       = @cLp
            and D_E_L_E_T_   = ' '
        ##CHECK_TRANSACTION_COMMIT
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        delete from CQ8###
        Where CQ8_FILIAL   = @IN_FILIAL
            and Round(CQ8_DEBITO, 2) = 0.00
            and Round(CQ8_CREDIT, 2) = 0.00
            and CQ8_DATA     = @cDataF
            and ((CQ8_IDENT  = 'CV0' AND CQ8_CODIGO = @IN_EC05CR) or (CQ8_IDENT  = 'CV0' AND CQ8_CODIGO = @IN_EC05CR))
            and CQ8_TPSALD   = @IN_TPSALDO
            and CQ8_MOEDA    = @IN_MOEDA
            and CQ8_LP       = @cLp
            and D_E_L_E_T_   = '*'
        ##CHECK_TRANSACTION_COMMIT
    end else begin
        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        delete from CQ8###
        Where CQ8_FILIAL  = @IN_FILIAL
            and Round(CQ8_DEBITO, 2) = 0.00
            and Round(CQ8_CREDIT, 2) = 0.00
            and CQ8_DATA     = @cDataF
            and ((CQ8_IDENT  = 'CV0' AND CQ8_CODIGO = @IN_EC05CR) or (CQ8_IDENT  = 'CV0' AND CQ8_CODIGO = @IN_EC05CR))
            and CQ8_TPSALD   = @IN_TPSALDO
            and CQ8_MOEDA    = @IN_MOEDA
            and CQ8_LP       = @cLp
            and D_E_L_E_T_   = ' '
        ##CHECK_TRANSACTION_COMMIT
    End
    select @OUT_RESULT = '1'
End
##ENDIF_001