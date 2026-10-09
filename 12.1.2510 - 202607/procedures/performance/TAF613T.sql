CREATE PROCEDURE TAF613T_##(
    @FILIAL_V14    CHAR('V14_FILIAL'),
    @CODMV14       CHAR('V14_CODMUN'),
    @CNPJV14       CHAR('V14_CNPJ'),
    @IEV14         CHAR('V14_IE'),
    @INSMV14       CHAR('V14_INSCMU'),
    @CEPV14        CHAR('V14_CEP'),
    @IDC1H         CHAR('V14_IDC1H'),
    @CODPAR        CHAR('V14_CODPAR'),
    @UFV14         CHAR('V14_UF'),
    @ORIGEM        CHAR(3),
    @OUT_RESULT    CHAR(1) OUTPUT  
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAFA613T </s>
    Descricao   -  <d> Integração entre ERP Livros Fiscais X TAF (SPED) - Atualização da Tabela Intermediaria V14 </d>
    Entrada     -  <ri> @FILIAL_V14    Filial a ser executada a procedure
                        @CODMV14       Código Municipal do participante
                        @CNPJV14       CNPJ do participante
                        @IEV14         Inscrição Estadual do participante
                        @INSMV14       Inscrição Municipal do participante
                        @CEPV14        CEP do participante
                        @IDC1H         ID da C1H do participante
                        @CODPAR        Campo CODPAR da C1H do participante
                        @COD_A1        Código do participante da SA1
                        @LOJA_A1       Loja do participante da SA1
                        @LOJA_A2       Loja do participante da SA2
                        @COD_A2        Código do participante da SA2
                        @COD_A4        Código do Particonate da SA4
                        @UFV14         UF do participante  
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execução da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Adilson Roberto </r>
    Data        :  <dt> 22/03/2024 </dt>
--------------------------------------------------------------------------------------------------------------------- */
BEGIN 
    SELECT @OUT_RESULT = '0'

    INSERT INTO V14### (
        V14_FILIAL,
        V14_IDC1H,
        V14_CNPJ,
        V14_IE,
        V14_INSCMU,
        V14_CODMUN,
        V14_CEP,
        V14_ORIG,
        V14_INTEGR,
        V14_UF,
        V14_CODPAR)
    VALUES (
        @FILIAL_V14,
        @IDC1H,
        @CNPJV14,
        @IEV14,
        @INSMV14, 
        @CODMV14,				
        @CEPV14,
        @ORIGEM,
        '1',				
        @UFV14,
        @CODPAR) 		

    SELECT @OUT_RESULT = '1'
END

       