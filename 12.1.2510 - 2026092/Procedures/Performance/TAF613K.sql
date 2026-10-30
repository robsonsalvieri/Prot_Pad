CREATE PROCEDURE TAF613K_##(
    @OUT_ID VARCHAR(36) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613K </s>
    Descricao   -  <d> Integraùùo entre ERP Livros Fiscais X TAF (SPED) - Retorna o UUID </d>
    Saida       -  <ro> @OUT_ID - UUID </ro>
    Responsavel :  <r> Melkz Siqueira </r>
    Data        :  <dt> 04/09/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */
##IF_001({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
    DECLARE @UUID VARCHAR(32)
##ENDIF_001

BEGIN
    ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
        SELECT @OUT_ID = CONVERT(VARCHAR(36), NEWID()) 
    ##ENDIF_002

    ##IF_003({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
        SELECT @UUID = RAWTOHEX(SYS_GUID())
        SELECT @OUT_ID = SUBSTR(@UUID, 1, 8) ||'-'|| SUBSTR(@UUID, 9, 4) ||'-'|| SUBSTR(@UUID, 13, 4) ||'-'|| SUBSTR(@UUID, 17, 4) ||'-'|| SUBSTR(@UUID, 21, 12)
    ##ENDIF_003

    ##IF_004({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
        SELECT @OUT_ID = CONVERT(VARCHAR(36), gen_random_uuid())
    ##ENDIF_004
END