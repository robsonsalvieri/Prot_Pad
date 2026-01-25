CREATE PROCEDURE TAF613_##(
    @IN_FILIAL CHAR('C20_FILIAL'),
    @IN_PROCEDURE CHAR(7),
    @IN_PROCESSO CHAR(36),
    @IN_PENDING_STATUS CHAR('C20_STATUS'),
    @IN_ATUDOC CHAR('C20_ATUDOC'),
    @IN_MV_ICMPAD FLOAT,
    @IN_MV_BLKTP00 VARCHAR(255),
    @IN_MV_BLKTP01 VARCHAR(255),
    @IN_MV_BLKTP02 VARCHAR(255),
    @IN_MV_BLKTP03 VARCHAR(255),
    @IN_MV_BLKTP04 VARCHAR(255),
    @IN_MV_BLKTP06 VARCHAR(255),
    @IN_MV_BLKTP10 VARCHAR(255),
    @IN_MV_CSDXML VARCHAR(3),
    @IN_MV_SPEDNAT VARCHAR(3),
    @IN_KEYREG VARCHAR(255),
    @IN_NEWID VARCHAR(255),
    @IN_PARGER VARCHAR(255),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versùo      -  <v> Protheus P12 </v>
    Programa    -  <s> TAFA613 </s>
    Descricao   -  <d> Integraùùo entre ERP Livros Fiscais X TAF (SPED) </d>
    Entrada     -  <ri> 
                        @IN_FILIAL - Filial a ser executada a procedure
                        @IN_PROCEDURE - Procedure a ser executada
                        @IN_PROCESSO - Processo em que a procedure estù sendo executada
                        @IN_PENDING_STATUS - Status do Documento Fiscal pendente para Integraùùo (C20_STATUS)
                        @IN_ATUDOC - Status de atualizaùùo do documento: 1 - Inclusùo; 2 - Cancelamento; 3 - Exclusùo; 4 = Complemento 
                        @IN_MV_ICMPAD   - Conteudo do Parùmetro MV_ICMPAD 
                        @IN_MV_BLKTP00  - Conteudo do Parùmetro MV_BLKTP00 
                        @IN_MV_BLKTP01  - Conteudo do Parùmetro MV_BLKTP01 
                        @IN_MV_BLKTP02  - Conteudo do Parùmetro MV_BLKTP02 
                        @IN_MV_BLKTP03  - Conteudo do Parùmetro MV_BLKTP03 
                        @IN_MV_BLKTP04  - Conteudo do Parùmetro MV_BLKTP04 
                        @IN_MV_BLKTP06  - Conteudo do Parùmetro MV_BLKTP06 
                        @IN_MV_BLKTP10  - Conteudo do Parùmetro MV_BLKTP10
                        @IN_MV_CSDXML   - Conteudo do Parùmetro MV_CSDXML 
                        @IN_MV_SPEDNAT  - Conteudo do Parùmetro MV_SPEDNAT 
                        @IN_KEYREG - Chave do registro a ser pesquisado nas tabelas de cadastro do ERP
                        @IN_NEWID - Id para gerar novo registro na tabela de cadastro
                        @IN_PARGER - parametro para conteudo geral
                    </ri>  
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execuùùo da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Melkz Siqueira </r>
    Data        :  <dt> 24/07/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */

DECLARE @PROCEDURE_RESULT CHAR(1)

BEGIN
    SELECT @OUT_RESULT          = '0'
    SELECT @PROCEDURE_RESULT    = '0'
   
    /*---------------------------------------------------------------
    Integraùùo de Produtos
    ---------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613A'
        BEGIN
            EXEC TAF613A_## @IN_FILIAL, @IN_PENDING_STATUS, @IN_ATUDOC, @IN_MV_ICMPAD, @IN_MV_BLKTP00, @IN_MV_BLKTP01, @IN_MV_BLKTP02,
                @IN_MV_BLKTP03, @IN_MV_BLKTP04, @IN_MV_BLKTP06, @IN_MV_BLKTP10, @PROCEDURE_RESULT OUTPUT
        END

    /*---------------------------------------------------------------
    Integraùùo de Fatores de Conversùo
    ---------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613B'
        BEGIN
            EXEC TAF613B_## @IN_FILIAL, @IN_PROCESSO, @IN_PENDING_STATUS, @IN_ATUDOC, @IN_MV_CSDXML, @PROCEDURE_RESULT OUTPUT
        END

    /*---------------------------------------------------------------
    Integraùùo de Unidades de Medida
    ---------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613C'
        BEGIN
            EXEC TAF613C_## @IN_FILIAL, @IN_PROCESSO, @PROCEDURE_RESULT OUTPUT
        END

    /*---------------------------------------------------------------
    Integraùùo de Planos de Contas
    ---------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613D'
        BEGIN
            EXEC TAF613D_## @IN_FILIAL, @PROCEDURE_RESULT OUTPUT
        END
    
    /*---------------------------------------------------------------
    Integraùùo de Centro de Custos
    ---------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613I'
        BEGIN            
            EXEC TAF613I_## @IN_FILIAL, @IN_PROCESSO , @PROCEDURE_RESULT OUTPUT      
        END

    /*---------------------------------------------------------------
    Integraùùo de NCM para o TAF Tabela  C0A
    ---------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613L'
        BEGIN            
            EXEC TAF613L_## @IN_FILIAL, @IN_PROCESSO , @PROCEDURE_RESULT OUTPUT      
        END

    /*---------------------------------------------------------------
    Integraùùo de Natureza da Operaùùo TAF- Tabela C1N
    ---------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613M'
        BEGIN            
            EXEC TAF613M_## @IN_FILIAL,@IN_MV_SPEDNAT,@IN_PROCESSO , @PROCEDURE_RESULT OUTPUT      
        END

    /*---------------------------------------------------------------
    DA3(Cadastro de Veiculos-OMS-TMS)x C0Q(Cadastro de veiculos- TAF
    ---------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613N'
        BEGIN
    
            EXEC TAF613N_## @IN_FILIAL, @IN_KEYREG, @IN_NEWID, @PROCEDURE_RESULT OUTPUT
        END

    /*---------------------------------------------------------------
    Integraùùo de Informaùùo complementar do Movimento TAF- Tabela C3R
    ---------------------------------------------------------------*/    
    IF @IN_PROCEDURE = 'TAF613O'
        BEGIN            
            EXEC TAF613O_## @IN_FILIAL, @IN_KEYREG, @IN_NEWID , @IN_PARGER, @PROCEDURE_RESULT OUTPUT 
        END        
     
    /*---------------------------------------------------------------
    Integraùùo de de cadastro do ECF / SAT-CFE (Cupom Fiscal)
    ---------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613P'
        BEGIN            
            EXEC TAF613P_## @IN_FILIAL, @IN_KEYREG , @IN_NEWID, @PROCEDURE_RESULT OUTPUT      
        END        

    /*---------------------------------------------------------------
    Integraùùo de Processos Referenciados - Tabela (CCF)
    ---------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613Q'
        BEGIN            
            EXEC TAF613Q_## @IN_FILIAL, @IN_KEYREG , @IN_NEWID, @PROCEDURE_RESULT OUTPUT      
        END
 
    /*---------------------------------------------------------------
    Integraùùo de Documento de Arrecadaùùo
    ---------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613R'
        BEGIN            
            EXEC TAF613R_## @IN_FILIAL, @IN_KEYREG , @IN_NEWID, @PROCEDURE_RESULT OUTPUT      
        END

    /*--------------------------------------------------------------------------------
    Cadastro de Informaùùes Complementares
    ----------------------------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613S'
        BEGIN            
            EXEC TAF613S_## @IN_FILIAL, @IN_KEYREG, @IN_NEWID, @PROCEDURE_RESULT OUTPUT      
        END

    /*------------------------------------------------------------------------------------------
    Inclusùo de registro na tabela intermediùria(V14) de integraùùo do cadastro de participantes
    --------------------------------------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613T'
        BEGIN            
            EXEC TAF613T_## @IN_FILIAL, @IN_PROCESSO, @IN_MV_BLKTP00, @IN_MV_BLKTP01, @IN_MV_BLKTP02, @IN_MV_BLKTP03, @IN_MV_BLKTP04, @IN_MV_BLKTP06, @IN_PARGER, @IN_MV_BLKTP10, @PROCEDURE_RESULT output
        END

    /*--------------------------------------------------------------------------------
    Procedure para saneamento do cadastro de Participantes
    ----------------------------------------------------------------------------------*/
    IF @IN_PROCEDURE = 'TAF613U'
        BEGIN            
            EXEC TAF613U_## @IN_FILIAL, @PROCEDURE_RESULT OUTPUT      
        END            

    SELECT @OUT_RESULT = @PROCEDURE_RESULT
END