CREATE PROCEDURE TAF613U_##(
    @IN_FILIAL CHAR('V14_FILIAL'),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 
/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613U </s>
    Descricao   -  <d> Integraùùo entre ERP Livros Fiscais X TAF (SPED) - Saneamento da tabela de participantes (C1H) </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execuùùo da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Carlos Eduardo Silva </r>
    Data        :  <dt> 21/03/2024 </dt>
--------------------------------------------------------------------------------------------------------------------- */
Declare @V14 char(3)
Declare @C1H char(3)
Declare @C09 char(3)
Declare @C07 char(3) 
Declare @filial_V14 varchar('V14_FILIAL')
Declare @filial_C1H varchar('C1H_FILIAL')
Declare @filial_C09 varchar('C09_FILIAL')
Declare @filial_C07 varchar('C07_FILIAL')

Declare @RegAtualizado  char(1)
Declare @statusReg      char('C1H_NEWCAD')
Declare @IdC1H_V14      varchar('V14_IDC1H')
Declare @CNPJ_V14       varchar('V14_CNPJ')
Declare @IE_V14         varchar('V14_IE')
Declare @IE_AUX          varchar('V14_IE')
Declare @INSCMU_V14     varchar('V14_INSCMU')
Declare @CODMUN_V14     varchar('C07_ID')
Declare @CEP_V14        varchar('V14_CEP')
Declare @UF_V14         varchar('C09_ID')
Declare @idParticipante varchar('C1H_ID')
Declare @indCadastro    char('C1H_NEWCAD')

Begin
    
    --Atribui valores iniciais pra as variaveis
    Select @V14 = 'V14' 
    Select @C1H = 'C1H'
    Select @C09 = 'C09'
    Select @C07 = 'C07'    
    Select @OUT_RESULT    = '0'
    Select @RegAtualizado = '0'
    Select @statusReg     = ' '
    
    --Busca filial das tabelas que serùo suadas
    exec XFILIAL_## @V14, @IN_FILIAL, @filial_V14 output 
    exec XFILIAL_## @C1H, @IN_FILIAL, @filial_C1H output    
    exec XFILIAL_## @C09, @IN_FILIAL, @filial_C09 output 
    exec XFILIAL_## @C07, @IN_FILIAL, @filial_C07 output

    --Declara o cursor com a query de consulta da tabela V14
    declare select_V14 insensitive cursor for
        SELECT 
            V14.V14_IDC1H,
            V14.V14_CNPJ,
            V14.V14_IE,
            V14.V14_INSCMU,
            C07.C07_ID V14_CODMUN,
            V14.V14_CEP,
            C09.C09_ID V14_UF
        FROM V14###	V14
            INNER JOIN C09### C09 ON C09_FILIAL = @filial_C09 AND C09.C09_UF = V14.V14_UF AND C09.D_E_L_E_T_ = ' '
            INNER JOIN C07### C07 ON C07_FILIAL = @filial_C07 AND C07.C07_UF = C09.C09_ID AND C07.C07_CODIGO = V14.V14_CODMUN AND C07.D_E_L_E_T_ = ' '
        WHERE V14.D_E_L_E_T_ = ' '
            AND V14.V14_FILIAL = @filial_V14
            AND V14.V14_INTEGR = '1'
        ORDER BY V14.V14_IDC1H	
    for read only 

    --Abre o cursor declarado
    open select_V14

    --Carrega as variaveis com os dados do cursor posicioando
    fetch select_V14 into @IdC1H_V14, @CNPJ_V14, @IE_V14, @INSCMU_V14, @CODMUN_V14, @CEP_V14, @UF_V14

    Begin transaction

        while @@fetch_status = 0 begin
                
            select @RegAtualizado = '1'

            if LTRIM(RTRIM(@IE_V14)) = 'ISENTO' begin
                select @IE_AUX  = ' '
            end else begin
                select @IE_AUX = @IE_V14
            end    

            --Declara o cursor com a query de consulta da tabela C1H
            declare select_C1H insensitive cursor for
                SELECT 
                    C1H_ID, 
                    C1H_NEWCAD
                FROM 
                    C1H### 
                WHERE D_E_L_E_T_ = ' ' 
                    AND C1H_FILIAL = @filial_C1H
                    AND	( C1H_CNPJ = @CNPJ_V14 OR C1H_CPF = @CNPJ_V14 )
                    AND C1H_IE IN ( @IE_V14 , @IE_AUX )
                    AND C1H_IM 	   = @INSCMU_V14
                    AND C1H_CODMUN = @CODMUN_V14 
                    AND C1H_CEP    = @CEP_V14 
                    AND C1H_UF 	   = @UF_V14
                    AND C1H_NEWCAD IN (' ','1')                
            for read only

            --Abre o cursor declarado 
            open select_C1H

            --Carrega as variaveis com os dados do cursor posicioando
            fetch select_C1H into @idParticipante, @indCadastro

            while @@fetch_status = 0 begin

                if @indCadastro = ' ' begin
                    select @statusReg = '3' -- Legado Saneado
                end else begin
                    select @statusReg = '2' --Cadastro novo integrado e saneado(V14)
                end

                --Atualiza o registro da tabela de participantes
                UPDATE 
                    C1H### 
                SET 
                    C1H_NEWCAD = @statusReg
                WHERE D_E_L_E_T_ = ' ' 
                    AND C1H_FILIAL = @filial_C1H 
                    AND C1H_ID = @idParticipante

                --Carrega as variaveis com os dados do proximo registro do cursor
                fetch select_C1H into @idParticipante, @indCadastro

            end

            --Fecha cursor
            close select_C1H
            
            --Libera todos os recursos utilizados pelo cursor
            deallocate select_C1H

            ##IF_001({|| alltrim(upper(TcGetDB())) == 'POSTGRES' })
                --Zera variavel de controle do loop
                select @fim_CUR = 0
            ##ENDIF_001

            --Atualiza a tabela intermediùria com o status Integrado e saneado
            UPDATE 
                V14### 
            SET 
                V14_INTEGR = '2' --Participante integrado e saneado
            WHERE D_E_L_E_T_ = ' '
                AND V14_FILIAL = @filial_V14
                AND V14_IDC1H  = @IdC1H_V14

            --Carrega as variaveis com os dados do proximo registro do cursor
            fetch select_V14 into @IdC1H_V14, @CNPJ_V14, @IE_V14, @INSCMU_V14, @CODMUN_V14, @CEP_V14, @UF_V14
            
        end

        --Fecha cursor
        close select_V14
        
        --Libera todos os recursos utilizados pelo cursor
        deallocate select_V14

        select @OUT_RESULT = @RegAtualizado

    commit transaction
    
End