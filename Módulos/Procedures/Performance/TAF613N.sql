
CREATE PROCEDURE TAF613N_##(
    @IN_FILIAL CHAR('DA3_FILIAL'),
    @KEY_PROC VARCHAR(255),
    @IN_NEWID VARCHAR(255),
    @OUT_RESULT VARCHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      - <v> Protheus P12 </v>
    Programa    - <s> TAF613C </s>
    Descricao   - <d> Integração entre ERP Livros Fiscais X TAF (SPED)-DA3(Cadastro de Veiculos-OMS-TMS)x C0Q(Cadastro de veiculos- TAF) </d>
    Entrada     - <ri> @IN_FILIAL - Filial a ser executada a procedure </ri> 
    Saida       - <ro> @OUT_RESULT - Indica o termino da execução da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel : <r> Washington Miranda Leão </r>
    Data        : <dt> 27/09/2023 </dt>
----------------------------------------------------------------------------------------------------------------- */
DECLARE @C0Q            CHAR(3)
DECLARE @DA3            CHAR(3)
DECLARE @INSERT_UPDT    CHAR(1)
DECLARE @FILIAL_C0Q     VARCHAR('C0Q_FILIAL') 
DECLARE @ID_C0Q         VARCHAR('C0Q_ID')
DECLARE @CODIGO_C0Q     VARCHAR('C0Q_CODIGO')
DECLARE @PLACA_C0Q      VARCHAR('C0Q_PLACA')
DECLARE @UF_C0Q         VARCHAR('C0Q_UF')
DECLARE @CODMUN_C0Q     VARCHAR('C0Q_CODMUN')
DECLARE @DESCRI_C0Q     VARCHAR('C0Q_DESCRI')
DECLARE @CHASSI_C0Q     VARCHAR('C0Q_CHASSI')
DECLARE @FILIAL_DA3     VARCHAR('DA3_FILIAL') 
DECLARE @COD_VEIC_DA3   VARCHAR('DA3_COD') 
DECLARE @PLACA_VEIC_DA3 VARCHAR('DA3_PLACA') 
DECLARE @UF_VEIC_DA3    VARCHAR('DA3_ESTPLA')  
DECLARE @CODMUN_DA3     VARCHAR('DA3_CODMUN')
DECLARE @DESCRI_DA3     VARCHAR('DA3_DESC')
DECLARE @CHASSI_DA3     VARCHAR('DA3_CHASSI')
DECLARE @MUNPLA_DA3     VARCHAR('DA3_MUNPLA')
DECLARE @TIPVEI_DA3     VARCHAR('DA3_TIPVEI')
DECLARE @ESTPLA_DA3     VARCHAR('DA3_ESTPLA')

BEGIN
    SELECT @OUT_RESULT      = '0'
    SELECT @INSERT_UPDT     = '0'
    SELECT @C0Q             = 'C0Q'
    SELECT @DA3             = 'DA3'
    
    EXEC XFILIAL_## @C0Q, @IN_FILIAL, @FILIAL_C0Q OUTPUT

    DECLARE PROCESS_INSERT INSENSITIVE CURSOR FOR
        SELECT 
            DA3.DA3_COD,     
            REPLACE(DA3.DA3_PLACA, '-',''),   
            DA3.DA3_ESTPLA, 
            DA3.DA3_CODMUN, 
            DA3.DA3_DESC,  
            LEFT(DA3.DA3_CHASSI,17)
         FROM DA3### DA3
            WHERE DA3.D_E_L_E_T_ = ''
                AND DA3.DA3_FILIAL = @IN_FILIAL
		        AND DA3.DA3_COD = @KEY_PROC
				
    FOR READ ONLY    
    OPEN PROCESS_INSERT

    FETCH PROCESS_INSERT 
    INTO
       @COD_VEIC_DA3,   
       @PLACA_VEIC_DA3,  
       @UF_VEIC_DA3,      
       @CODMUN_DA3,     
       @DESCRI_DA3,     
       @CHASSI_DA3     

        
    BEGIN TRANSACTION

        IF @@FETCH_STATUS = 0 
            BEGIN
                INSERT INTO C0Q### (
                    C0Q_FILIAL,
                    C0Q_ID,
                    C0Q_CODIGO, 
                    C0Q_PLACA, 
                    C0Q_UF,
                    C0Q_CODMUN,
                    C0Q_DESCRI,
                    C0Q_CHASSI
    
                ) VALUES (
                    @FILIAL_C0Q,
                    @IN_NEWID,
                    @COD_VEIC_DA3,  
                    @PLACA_VEIC_DA3,  
                    @UF_VEIC_DA3, 
                    @CODMUN_DA3,  
                    @DESCRI_DA3,   
                    @CHASSI_DA3  

                )
                SELECT @INSERT_UPDT = '1'
            END
    COMMIT TRANSACTION
    CLOSE PROCESS_INSERT
    DEALLOCATE PROCESS_INSERT

    SELECT @OUT_RESULT = @INSERT_UPDT /*A STORED PROCEDURE RETORNA 1 CASO TUDO TENHA EXECUTADO ATÉ AQUI SEM ERROS*/
END