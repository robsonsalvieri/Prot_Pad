##IF_999({|| AliasInDic('QLJ') })
Create procedure CTB965F_## ( 
   @IN_FILIAL       Char('CT2_FILIAL'),
   @IN_DATADE       Char('CT2_DATA'),
   @IN_DATAATE      Char('CT2_DATA'),
   @IN_LMOEDAESP    Char(01),
   @IN_MOEDA        Char('CT2_MOEDLC'),
   @IN_TPSALDO      Char('CT2_TPSALD'),
   @IN_UUID			Char('QLJ_UUID'),
   @IN_LMULTIFIL    Char(01),
   @IN_TRANSACTION  Char(01),
   @OUT_RESULTADO   Char(01) OutPut )
as
/* ------------------------------------------------------------------------------------

    Versao          - <v>  Protheus P.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  backoffice.accountingclosing.checkbalance.data.protheus.tlpp </s>
    Descricao       - <d>  Checagem de Saldos SigaCTB </d>
    Procedure       -      Verifica divergencia de saldos
    Funcao do Siga  -      ExecProcSald()
    Entrada         - <ri> @IN_FILIAL       - Filial Corrente
                           @IN_LCUSTO       - Centro de Custo em uso
                           @IN_LITEM        - Item em uso
                           @IN_LCLVL        - Classe de Valor em uso                          
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
						   @IN_UUID		    - UUID para gravar na tabela QLJ
                           @IN_TRANSACTION  - '1' chamada dentro de transacao - '0' fora de transacao
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  TOTVS </r>
    Data        :     04/10/2023
    Obs: a variavel @iTranCount = 0 sera trocada por 'commit tran' no CFGX051 pro SQLSERVER 
         e SYBASE
   -------------------------------------------------------------------------------------- */
declare @cFilAux	Char('CT2_FILIAL')
declare @cFilial	Char('CT2_FILIAL')
declare @cFilQLJ    Char('QLJ_FILIAL')
declare @cDatIni    Char(8)
declare @cDatFim    Char(8)
declare @cStrTran   Char(1)

begin
    
select @cBegin = ''    
    select @OUT_RESULTADO = '0'
    
    If @IN_FILIAL = ' ' select @cFilAux = ' '
    else select @cFilAux = @IN_FILIAL
    
    exec XFILIAL_## 'QLJ', @cFilAux, @cFilQLJ OutPut
	exec XFILIAL_## 'CQ1', @cFilAux, @cFilial OutPut

    select @cDatIni = SUBSTRING(@IN_DATADE,1,6) || '01'
    select @cDatFim = SUBSTRING(@IN_DATAATE,1,6) || '31'

    -- Corrige CQ0
	SELECT @cStrTran = '1'      	
        SELECT
            CQ1_FILIAL,
            SUBSTRING(CQ1_DATA,1,6) AS ANOMES,
            CQ1_CONTA,
            CQ1_MOEDA,
            CQ1_TPSALD,
            'SUB_CQ1_LP' AS CQ1_LP, -- Normaliza S/N como nao-zeramento
            SUM(CQ1_DEBITO) AS DEB_DIA,
            SUM(CQ1_CREDIT) AS CRED_DIA
        FROM CQ1###
        WHERE
            ((@IN_LMULTIFIL = '0' AND CQ1_FILIAL = @cFilial) OR (CQ1_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
            CQ1_DATA BETWEEN @cDatIni AND @cDatFim AND
            ((CQ1_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                
            ((@IN_TPSALDO = '*' AND CQ1_TPSALD <> '9') OR CQ1_TPSALD = @IN_TPSALDO) AND       
            D_E_L_E_T_ = ' '
        GROUP BY
            CQ1_FILIAL,
            SUBSTRING(CQ1_DATA,1,6),
            CQ1_CONTA,
            CQ1_MOEDA,
            CQ1_TPSALD,
            'SUB_CQ1_LP' -- Normaliza S/N como nao-zeramento
    SELECT @cStrTran = '2'
        SELECT
            CQ0_FILIAL,
            SUBSTRING(CQ0_DATA,1,6) AS ANOMES,
            CQ0_CONTA,
            CQ0_MOEDA,
            CQ0_TPSALD,
            'SUB_CQ0_LP' AS CQ0_LP, -- Normaliza S/N como nao-zeramento
            SUM(CQ0_DEBITO) AS DEB_MES,
            SUM(CQ0_CREDIT) AS CRED_MES
        FROM CQ0###
        WHERE
            ((@IN_LMULTIFIL = '0' AND CQ0_FILIAL = @cFilial) OR (CQ0_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
            CQ0_DATA BETWEEN @cDatIni AND @cDatFim AND
            ((CQ0_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                
            ((@IN_TPSALDO = '*' AND CQ0_TPSALD <> '9') OR CQ0_TPSALD = @IN_TPSALDO) AND       
            D_E_L_E_T_ = ' '
        GROUP BY
            CQ0_FILIAL,
            SUBSTRING(CQ0_DATA,1,6),
            CQ0_CONTA,
            CQ0_MOEDA,
            CQ0_TPSALD,
            'SUB_CQ0_LP' -- Normaliza S/N como nao-zeramento
    SELECT @cStrTran = '3'      
        SELECT
            COALESCE(D.CQ1_FILIAL, M.CQ0_FILIAL) FILIAL,
            COALESCE(D.ANOMES,     M.ANOMES)     ANOMES,
            COALESCE(D.CQ1_CONTA,  M.CQ0_CONTA)  CONTA,
            COALESCE(D.CQ1_MOEDA,  M.CQ0_MOEDA)  MOEDA,
            COALESCE(D.CQ1_TPSALD, M.CQ0_TPSALD) TPSALD,
            COALESCE(D.CQ1_LP,     M.CQ0_LP)     LP,
            COALESCE(D.DEB_DIA,0)  AS DEB_DIA,
            COALESCE(M.DEB_MES,0)  AS DEB_MES,
            COALESCE(D.CRED_DIA,0) AS CRED_DIA,
            COALESCE(M.CRED_MES,0) AS CRED_MES
        FROM SLD_DIA_MES D
        FULL OUTER JOIN SLD_MES M
            ON M.CQ0_FILIAL = D.CQ1_FILIAL
            AND M.ANOMES     = D.ANOMES
            AND M.CQ0_CONTA  = D.CQ1_CONTA
            AND M.CQ0_MOEDA  = D.CQ1_MOEDA
            AND M.CQ0_TPSALD = D.CQ1_TPSALD
            AND M.CQ0_LP     = D.CQ1_LP
    SELECT @cStrTran = '4'       
        SELECT 
            FILIAL, 
            ANOMES, 
            CONTA,
            MOEDA, 
            TPSALD, 
            DEB_DIA, 
            DEB_MES, 
            CRED_DIA, 
            CRED_MES
        FROM CONC_DET
        WHERE 
            ABS(DEB_DIA - DEB_MES)  > 0.005
            OR ABS(CRED_DIA - CRED_MES) > 0.005
    SELECT @cStrTran = '5'      
        SELECT
            FILIAL,
            ANOMES,
            CONTA,
            MOEDA,
            TPSALD,
            SUM(DEB_DIA)  AS DEB_DIA,
            SUM(DEB_MES)  AS DEB_MES,
            SUM(CRED_DIA) AS CRED_DIA,
            SUM(CRED_MES) AS CRED_MES
        FROM ERROS_DET
        GROUP BY
            FILIAL,
            ANOMES,
            CONTA,
            MOEDA,
            TPSALD
    SELECT @cStrTran = '6'   
    SELECT
        @cFilQLJ,
        EC.FILIAL,
        EC.ANOMES||'01',
        EC.CONTA,
        ' ' AS QLJ_CUSTO,
        ' ' AS QLJ_ITEM,
        ' ' AS QLJ_CLVL,
        ' ' AS QLJ_ENT05,
        ' ' AS QLJ_ENT06,
        ' ' AS QLJ_ENT07,
        ' ' AS QLJ_ENT08,
        ' ' AS QLJ_ENT09,        
        EC.DEB_DIA,
        EC.DEB_MES,
        EC.CRED_DIA,
        EC.CRED_MES,
        EC.MOEDA,
        EC.TPSALD,
        @IN_UUID,	
        'CQ1'
    FROM ERROS_CONSOL EC
    WHERE NOT EXISTS (
        SELECT 1
        FROM QLJ### Q
        WHERE Q.QLJ_FILIAL = @cFilQLJ
        AND Q.QLJ_FILORI  = EC.FILIAL
        AND Q.QLJ_DATA BETWEEN EC.ANOMES||'01' AND EC.ANOMES||'31'
        AND Q.QLJ_CONTA  = EC.CONTA
        AND Q.QLJ_CUSTO  = ' '
        AND Q.QLJ_ITEM   = ' '
        AND Q.QLJ_CLVL   = ' '
        AND Q.QLJ_ENT05  = ' '
        AND Q.QLJ_ENT06  = ' '
        AND Q.QLJ_ENT07  = ' '
        AND Q.QLJ_ENT08  = ' '
        AND Q.QLJ_ENT09  = ' '
        AND Q.QLJ_MOEDA  = EC.MOEDA
        AND Q.QLJ_TPSALD = EC.TPSALD
        AND Q.QLJ_TABORI = 'CQ1'
        AND Q.QLJ_UUID   = @IN_UUID
        AND Q.D_E_L_E_T_ = ' '
    )
    
    -- Corrige CQ2
	SELECT @cStrTran = '1'      	
        SELECT
            CQ3_FILIAL,
            SUBSTRING(CQ3_DATA,1,6) AS ANOMES,
            CQ3_CONTA,
            CQ3_CCUSTO,
            CQ3_MOEDA,
            CQ3_TPSALD,
            'SUB_CQ3_LP' AS CQ3_LP, -- Normaliza S/N como nao-zeramento
            SUM(CQ3_DEBITO) AS DEB_DIA,
            SUM(CQ3_CREDIT) AS CRED_DIA
        FROM CQ3###
        WHERE
            ((@IN_LMULTIFIL = '0' AND CQ3_FILIAL = @cFilial) OR (CQ3_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
            CQ3_DATA BETWEEN @cDatIni AND @cDatFim AND
            ((CQ3_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                
            ((@IN_TPSALDO = '*' AND CQ3_TPSALD <> '9') OR CQ3_TPSALD = @IN_TPSALDO) AND       
            D_E_L_E_T_ = ' '
        GROUP BY
            CQ3_FILIAL,
            SUBSTRING(CQ3_DATA,1,6),
            CQ3_CONTA,
            CQ3_CCUSTO,
            CQ3_MOEDA,
            CQ3_TPSALD,
            'SUB_CQ3_LP' -- Normaliza S/N como nao-zeramento
    SELECT @cStrTran = '2'
        SELECT
            CQ2_FILIAL,
            SUBSTRING(CQ2_DATA,1,6) AS ANOMES,
            CQ2_CONTA,
            CQ2_CCUSTO,
            CQ2_MOEDA,
            CQ2_TPSALD,
            'SUB_CQ2_LP' AS CQ2_LP, -- Normaliza S/N como nao-zeramento
            SUM(CQ2_DEBITO) AS DEB_MES,
            SUM(CQ2_CREDIT) AS CRED_MES
        FROM CQ2###
        WHERE
            ((@IN_LMULTIFIL = '0' AND CQ2_FILIAL = @cFilial) OR (CQ2_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
            CQ2_DATA BETWEEN @cDatIni AND @cDatFim AND
            ((CQ2_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                
            ((@IN_TPSALDO = '*' AND CQ2_TPSALD <> '9') OR CQ2_TPSALD = @IN_TPSALDO) AND       
            D_E_L_E_T_ = ' '
        GROUP BY
            CQ2_FILIAL,
            SUBSTRING(CQ2_DATA,1,6),
            CQ2_CONTA,
            CQ2_CCUSTO,
            CQ2_MOEDA,
            CQ2_TPSALD,
            'SUB_CQ2_LP' -- Normaliza S/N como nao-zeramento
    SELECT @cStrTran = '3'      
        SELECT
            COALESCE(D.CQ3_FILIAL, M.CQ2_FILIAL) FILIAL,
            COALESCE(D.ANOMES,     M.ANOMES)     ANOMES,
            COALESCE(D.CQ3_CONTA,  M.CQ2_CONTA)  CONTA,
            COALESCE(D.CQ3_CCUSTO,  M.CQ2_CCUSTO) CCUSTO,
            COALESCE(D.CQ3_MOEDA,  M.CQ2_MOEDA)  MOEDA,
            COALESCE(D.CQ3_TPSALD, M.CQ2_TPSALD) TPSALD,
            COALESCE(D.CQ3_LP,     M.CQ2_LP)     LP,
            COALESCE(D.DEB_DIA,0)  AS DEB_DIA,
            COALESCE(M.DEB_MES,0)  AS DEB_MES,
            COALESCE(D.CRED_DIA,0) AS CRED_DIA,
            COALESCE(M.CRED_MES,0) AS CRED_MES
        FROM SLD_DIA_MES D
        FULL OUTER JOIN SLD_MES M
            ON M.CQ2_FILIAL = D.CQ3_FILIAL
            AND M.ANOMES     = D.ANOMES
            AND M.CQ2_CONTA  = D.CQ3_CONTA
            AND M.CQ2_CCUSTO = D.CQ3_CCUSTO
            AND M.CQ2_MOEDA  = D.CQ3_MOEDA
            AND M.CQ2_TPSALD = D.CQ3_TPSALD
            AND M.CQ2_LP     = D.CQ3_LP
    SELECT @cStrTran = '4'       
        SELECT 
            FILIAL, 
            ANOMES, 
            CONTA,
            CCUSTO,
            MOEDA, 
            TPSALD, 
            DEB_DIA, 
            DEB_MES, 
            CRED_DIA, 
            CRED_MES
        FROM CONC_DET
        WHERE 
            ABS(DEB_DIA - DEB_MES)  > 0.005
            OR ABS(CRED_DIA - CRED_MES) > 0.005
    SELECT @cStrTran = '5'      
        SELECT
            FILIAL,
            ANOMES,
            CONTA,
            CCUSTO,
            MOEDA,
            TPSALD,
            SUM(DEB_DIA)  AS DEB_DIA,
            SUM(DEB_MES)  AS DEB_MES,
            SUM(CRED_DIA) AS CRED_DIA,
            SUM(CRED_MES) AS CRED_MES
        FROM ERROS_DET
        GROUP BY
            FILIAL,
            ANOMES,
            CONTA,
            CCUSTO,
            MOEDA,
            TPSALD
    SELECT @cStrTran = '6'    
    SELECT
        @cFilQLJ,
        EC.FILIAL,
        EC.ANOMES||'01',
        EC.CONTA,
        EC.CCUSTO,
        ' ' AS QLJ_ITEM,
        ' ' AS QLJ_CLVL,
        ' ' AS QLJ_ENT05,
        ' ' AS QLJ_ENT06,
        ' ' AS QLJ_ENT07,
        ' ' AS QLJ_ENT08,
        ' ' AS QLJ_ENT09,
        EC.DEB_DIA,
        EC.DEB_MES,
        EC.CRED_DIA,
        EC.CRED_MES,
        EC.MOEDA,
        EC.TPSALD,
        @IN_UUID,	
        'CQ3'
    FROM ERROS_CONSOL EC
    WHERE NOT EXISTS (
        SELECT 1
        FROM QLJ### Q
        WHERE Q.QLJ_FILIAL = @cFilQLJ
        AND Q.QLJ_FILORI  = EC.FILIAL
        AND Q.QLJ_DATA BETWEEN EC.ANOMES||'01' AND EC.ANOMES||'31'
        AND Q.QLJ_CONTA  = EC.CONTA
        AND Q.QLJ_CUSTO  = EC.CCUSTO
        AND Q.QLJ_ITEM   = ' '
        AND Q.QLJ_CLVL   = ' '
        AND Q.QLJ_ENT05  = ' '
        AND Q.QLJ_ENT06  = ' '
        AND Q.QLJ_ENT07  = ' '
        AND Q.QLJ_ENT08  = ' '
        AND Q.QLJ_ENT09  = ' '
        AND Q.QLJ_MOEDA  = EC.MOEDA
        AND Q.QLJ_TPSALD = EC.TPSALD
        AND Q.QLJ_TABORI = 'CQ3'
        AND Q.QLJ_UUID   = @IN_UUID
        AND Q.D_E_L_E_T_ = ' '
    )    

     -- Corrige CQ4
	SELECT @cStrTran = '1'      	
        SELECT
            CQ5_FILIAL,
            SUBSTRING(CQ5_DATA,1,6) AS ANOMES,
            CQ5_CONTA,
            CQ5_CCUSTO,
            CQ5_ITEM,
            CQ5_MOEDA,
            CQ5_TPSALD,
            'SUB_CQ5_LP' AS CQ5_LP, -- Normaliza S/N como nao-zeramento
            SUM(CQ5_DEBITO) AS DEB_DIA,
            SUM(CQ5_CREDIT) AS CRED_DIA
        FROM CQ5###
        WHERE
            ((@IN_LMULTIFIL = '0' AND CQ5_FILIAL = @cFilial) OR (CQ5_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
            CQ5_DATA BETWEEN @cDatIni AND @cDatFim AND
            ((CQ5_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                
            ((@IN_TPSALDO = '*' AND CQ5_TPSALD <> '9') OR CQ5_TPSALD = @IN_TPSALDO) AND       
            D_E_L_E_T_ = ' '
        GROUP BY
            CQ5_FILIAL,
            SUBSTRING(CQ5_DATA,1,6),
            CQ5_CONTA,
            CQ5_CCUSTO,
            CQ5_ITEM,
            CQ5_MOEDA,
            CQ5_TPSALD,
            'SUB_CQ5_LP' -- Normaliza S/N como nao-zeramento
    SELECT @cStrTran = '2'
        SELECT
            CQ4_FILIAL,
            SUBSTRING(CQ4_DATA,1,6) AS ANOMES,
            CQ4_CONTA,
            CQ4_CCUSTO,
            CQ4_ITEM,
            CQ4_MOEDA,
            CQ4_TPSALD,
            'SUB_CQ4_LP' AS CQ4_LP, -- Normaliza S/N como nao-zeramento
            SUM(CQ4_DEBITO) AS DEB_MES,
            SUM(CQ4_CREDIT) AS CRED_MES
        FROM CQ4###
        WHERE
            ((@IN_LMULTIFIL = '0' AND CQ4_FILIAL = @cFilial) OR (CQ4_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
            CQ4_DATA BETWEEN @cDatIni AND @cDatFim AND
            ((CQ4_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                
            ((@IN_TPSALDO = '*' AND CQ4_TPSALD <> '9') OR CQ4_TPSALD = @IN_TPSALDO) AND       
            D_E_L_E_T_ = ' '
        GROUP BY
            CQ4_FILIAL,
            SUBSTRING(CQ4_DATA,1,6),
            CQ4_CONTA,
            CQ4_CCUSTO,
            CQ4_ITEM,
            CQ4_MOEDA,
            CQ4_TPSALD,
            'SUB_CQ4_LP' -- Normaliza S/N como nao-zeramento
    SELECT @cStrTran = '3'      
        SELECT
            COALESCE(D.CQ5_FILIAL, M.CQ4_FILIAL) FILIAL,
            COALESCE(D.ANOMES,     M.ANOMES)     ANOMES,
            COALESCE(D.CQ5_CONTA,  M.CQ4_CONTA)  CONTA,
            COALESCE(D.CQ5_CCUSTO, M.CQ4_CCUSTO) CCUSTO,
            COALESCE(D.CQ5_ITEM,   M.CQ4_ITEM)   ITEM,
            COALESCE(D.CQ5_MOEDA,  M.CQ4_MOEDA)  MOEDA,
            COALESCE(D.CQ5_TPSALD, M.CQ4_TPSALD) TPSALD,
            COALESCE(D.CQ5_LP,     M.CQ4_LP)     LP,
            COALESCE(D.DEB_DIA,0)  AS DEB_DIA,
            COALESCE(M.DEB_MES,0)  AS DEB_MES,
            COALESCE(D.CRED_DIA,0) AS CRED_DIA,
            COALESCE(M.CRED_MES,0) AS CRED_MES
        FROM SLD_DIA_MES D
        FULL OUTER JOIN SLD_MES M
            ON M.CQ4_FILIAL = D.CQ5_FILIAL
            AND M.ANOMES     = D.ANOMES
            AND M.CQ4_CONTA  = D.CQ5_CONTA
            AND M.CQ4_CCUSTO = D.CQ5_CCUSTO
            AND M.CQ4_ITEM   = D.CQ5_ITEM
            AND M.CQ4_MOEDA  = D.CQ5_MOEDA
            AND M.CQ4_TPSALD = D.CQ5_TPSALD
            AND M.CQ4_LP     = D.CQ5_LP
    SELECT @cStrTran = '4'       
        SELECT 
            FILIAL, 
            ANOMES, 
            CONTA,
            CCUSTO,
            ITEM,
            MOEDA, 
            TPSALD, 
            DEB_DIA, 
            DEB_MES, 
            CRED_DIA, 
            CRED_MES
        FROM CONC_DET
        WHERE 
            ABS(DEB_DIA - DEB_MES)  > 0.005
            OR ABS(CRED_DIA - CRED_MES) > 0.005
    SELECT @cStrTran = '5'      
        SELECT
            FILIAL,
            ANOMES,
            CONTA,
            CCUSTO,
            ITEM,
            MOEDA,
            TPSALD,
            SUM(DEB_DIA)  AS DEB_DIA,
            SUM(DEB_MES)  AS DEB_MES,
            SUM(CRED_DIA) AS CRED_DIA,
            SUM(CRED_MES) AS CRED_MES
        FROM ERROS_DET
        GROUP BY
            FILIAL,
            ANOMES,
            CONTA,
            CCUSTO,
            ITEM,
            MOEDA,
            TPSALD
    SELECT @cStrTran = '6'    
    SELECT
        @cFilQLJ,
        EC.FILIAL,
        EC.ANOMES||'01',
        EC.CONTA,
        EC.CCUSTO,
        EC.ITEM,
        ' ' AS QLJ_CLVL,
        ' ' AS QLJ_ENT05,
        ' ' AS QLJ_ENT06,
        ' ' AS QLJ_ENT07,
        ' ' AS QLJ_ENT08,
        ' ' AS QLJ_ENT09,
        EC.DEB_DIA,
        EC.DEB_MES,
        EC.CRED_DIA,
        EC.CRED_MES,
        EC.MOEDA,
        EC.TPSALD,
        @IN_UUID,	
        'CQ5'
    FROM ERROS_CONSOL EC
    WHERE NOT EXISTS (
        SELECT 1
        FROM QLJ### Q
        WHERE Q.QLJ_FILIAL = @cFilQLJ
        AND Q.QLJ_FILORI  = EC.FILIAL
        AND Q.QLJ_DATA BETWEEN EC.ANOMES||'01' AND EC.ANOMES||'31'
        AND Q.QLJ_CONTA  = EC.CONTA
        AND Q.QLJ_CUSTO  = EC.CCUSTO
        AND Q.QLJ_ITEM   = EC.ITEM
        AND Q.QLJ_CLVL   = ' '
        AND Q.QLJ_ENT05  = ' '
        AND Q.QLJ_ENT06  = ' '
        AND Q.QLJ_ENT07  = ' '
        AND Q.QLJ_ENT08  = ' '
        AND Q.QLJ_ENT09  = ' '
        AND Q.QLJ_MOEDA  = EC.MOEDA
        AND Q.QLJ_TPSALD = EC.TPSALD
        AND Q.QLJ_TABORI = 'CQ5'
        AND Q.QLJ_UUID   = @IN_UUID
        AND Q.D_E_L_E_T_ = ' '
    )  

      -- Corrige CQ6
	SELECT @cStrTran = '1'      	
        SELECT
            CQ7_FILIAL,
            SUBSTRING(CQ7_DATA,1,6) AS ANOMES,
            CQ7_CONTA,
            CQ7_CCUSTO,
            CQ7_ITEM,
            CQ7_CLVL,
            CQ7_MOEDA,
            CQ7_TPSALD,
            'SUB_CQ7_LP' AS CQ7_LP, -- Normaliza S/N como nao-zeramento
            SUM(CQ7_DEBITO) AS DEB_DIA,
            SUM(CQ7_CREDIT) AS CRED_DIA
        FROM CQ7###
        WHERE
            ((@IN_LMULTIFIL = '0' AND CQ7_FILIAL = @cFilial) OR (CQ7_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
            CQ7_DATA BETWEEN @cDatIni AND @cDatFim AND
            ((CQ7_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                
            ((@IN_TPSALDO = '*' AND CQ7_TPSALD <> '9') OR CQ7_TPSALD = @IN_TPSALDO) AND       
            D_E_L_E_T_ = ' '
        GROUP BY
            CQ7_FILIAL,
            SUBSTRING(CQ7_DATA,1,6),
            CQ7_CONTA,
            CQ7_CCUSTO,
            CQ7_ITEM,
            CQ7_CLVL,
            CQ7_MOEDA,
            CQ7_TPSALD,
            'SUB_CQ7_LP' -- Normaliza S/N como nao-zeramento
    SELECT @cStrTran = '2'
        SELECT
            CQ6_FILIAL,
            SUBSTRING(CQ6_DATA,1,6) AS ANOMES,
            CQ6_CONTA,
            CQ6_CCUSTO,
            CQ6_ITEM,
            CQ6_CLVL,
            CQ6_MOEDA,
            CQ6_TPSALD,
            'SUB_CQ6_LP' AS CQ6_LP, -- Normaliza S/N como nao-zeramento
            SUM(CQ6_DEBITO) AS DEB_MES,
            SUM(CQ6_CREDIT) AS CRED_MES
        FROM CQ6###
        WHERE
            ((@IN_LMULTIFIL = '0' AND CQ6_FILIAL = @cFilial) OR (CQ6_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
            CQ6_DATA BETWEEN @cDatIni AND @cDatFim AND
            ((CQ6_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                
            ((@IN_TPSALDO = '*' AND CQ6_TPSALD <> '9') OR CQ6_TPSALD = @IN_TPSALDO) AND       
            D_E_L_E_T_ = ' '
        GROUP BY
            CQ6_FILIAL,
            SUBSTRING(CQ6_DATA,1,6),
            CQ6_CONTA,
            CQ6_CCUSTO,
            CQ6_ITEM,
            CQ6_CLVL,
            CQ6_MOEDA,
            CQ6_TPSALD,
            'SUB_CQ6_LP' -- Normaliza S/N como nao-zeramento
    SELECT @cStrTran = '3'      
        SELECT
            COALESCE(D.CQ7_FILIAL, M.CQ6_FILIAL) FILIAL,
            COALESCE(D.ANOMES,     M.ANOMES)     ANOMES,
            COALESCE(D.CQ7_CONTA,  M.CQ6_CONTA)  CONTA,
            COALESCE(D.CQ7_CCUSTO, M.CQ6_CCUSTO) CCUSTO,
            COALESCE(D.CQ7_ITEM,   M.CQ6_ITEM)   ITEM,
            COALESCE(D.CQ7_CLVL,   M.CQ6_CLVL)   CLVL,
            COALESCE(D.CQ7_MOEDA,  M.CQ6_MOEDA)  MOEDA,
            COALESCE(D.CQ7_TPSALD, M.CQ6_TPSALD) TPSALD,
            COALESCE(D.CQ7_LP,     M.CQ6_LP)     LP,
            COALESCE(D.DEB_DIA,0)  AS DEB_DIA,
            COALESCE(M.DEB_MES,0)  AS DEB_MES,
            COALESCE(D.CRED_DIA,0) AS CRED_DIA,
            COALESCE(M.CRED_MES,0) AS CRED_MES
        FROM SLD_DIA_MES D
        FULL OUTER JOIN SLD_MES M
            ON M.CQ6_FILIAL = D.CQ7_FILIAL
            AND M.ANOMES     = D.ANOMES
            AND M.CQ6_CONTA  = D.CQ7_CONTA
            AND M.CQ6_CCUSTO = D.CQ7_CCUSTO
            AND M.CQ6_ITEM   = D.CQ7_ITEM
            AND M.CQ6_CLVL   = D.CQ7_CLVL
            AND M.CQ6_MOEDA  = D.CQ7_MOEDA
            AND M.CQ6_TPSALD = D.CQ7_TPSALD
            AND M.CQ6_LP     = D.CQ7_LP
    SELECT @cStrTran = '4'       
        SELECT 
            FILIAL, 
            ANOMES, 
            CONTA,
            CCUSTO,
            ITEM,
            CLVL,
            MOEDA, 
            TPSALD, 
            DEB_DIA, 
            DEB_MES, 
            CRED_DIA, 
            CRED_MES
        FROM CONC_DET
        WHERE 
            ABS(DEB_DIA - DEB_MES)  > 0.005
            OR ABS(CRED_DIA - CRED_MES) > 0.005
    SELECT @cStrTran = '5'      
        SELECT
            FILIAL,
            ANOMES,
            CONTA,
            CCUSTO,
            ITEM,
            CLVL,
            MOEDA,
            TPSALD,
            SUM(DEB_DIA)  AS DEB_DIA,
            SUM(DEB_MES)  AS DEB_MES,
            SUM(CRED_DIA) AS CRED_DIA,
            SUM(CRED_MES) AS CRED_MES
        FROM ERROS_DET
        GROUP BY
            FILIAL,
            ANOMES,
            CONTA,
            CCUSTO,
            CLVL,
            ITEM,
            MOEDA,
            TPSALD
    SELECT @cStrTran = '6'   
    SELECT
        @cFilQLJ,
        EC.FILIAL,
        EC.ANOMES||'01',
        EC.CONTA,
        EC.CCUSTO,
        EC.ITEM,
        EC.CLVL,
        ' ' AS QLJ_ENT05,
        ' ' AS QLJ_ENT06,
        ' ' AS QLJ_ENT07,
        ' ' AS QLJ_ENT08,
        ' ' AS QLJ_ENT09,
        EC.DEB_DIA,
        EC.DEB_MES,
        EC.CRED_DIA,
        EC.CRED_MES,
        EC.MOEDA,
        EC.TPSALD,
        @IN_UUID,	
        'CQ7'
    FROM ERROS_CONSOL EC
    WHERE NOT EXISTS (
        SELECT 1
        FROM QLJ### Q
        WHERE Q.QLJ_FILIAL = @cFilQLJ
        AND Q.QLJ_FILORI  = EC.FILIAL
        AND Q.QLJ_DATA BETWEEN EC.ANOMES||'01' AND EC.ANOMES||'31'
        AND Q.QLJ_CONTA  = EC.CONTA
        AND Q.QLJ_CUSTO  = EC.CCUSTO
        AND Q.QLJ_ITEM   = EC.ITEM
        AND Q.QLJ_CLVL   = EC.CLVL
        AND Q.QLJ_ENT05  = ' '
        AND Q.QLJ_ENT06  = ' '
        AND Q.QLJ_ENT07  = ' '
        AND Q.QLJ_ENT08  = ' '
        AND Q.QLJ_ENT09  = ' '
        AND Q.QLJ_MOEDA  = EC.MOEDA
        AND Q.QLJ_TPSALD = EC.TPSALD
        AND Q.QLJ_TABORI = 'CQ7'
        AND Q.QLJ_UUID   = @IN_UUID
        AND Q.D_E_L_E_T_ = ' '
    )    

    --Corrige CQ8
    SELECT @cStrTran = '1' 
    SELECT 
            CQ9_FILIAL,
            SUBSTRING(CQ9_DATA,1,6) AS ANOMES,
            CQ9_IDENT,
            CQ9_CODIGO,
            CQ9_MOEDA,
            CQ9_TPSALD,
            'SUB_CQ9_LP' AS CQ9_LP, -- Normaliza S/N como nao-zeramento
            SUM(CQ9_DEBITO)  AS DEB_DIA,
            SUM(CQ9_CREDIT) AS CRED_DIA
    FROM CQ9###
    WHERE 
        ((@IN_LMULTIFIL = '0' AND CQ9_FILIAL = @cFilial) OR (CQ9_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
        CQ9_DATA BETWEEN @cDatIni AND @cDatFim AND
        ((CQ9_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                
        ((@IN_TPSALDO = '*' AND CQ9_TPSALD <> '9') OR CQ9_TPSALD = @IN_TPSALDO) AND       
        D_E_L_E_T_ = ' '    
    GROUP BY 
            CQ9_FILIAL,
            SUBSTRING(CQ9_DATA,1,6),
            CQ9_IDENT,
            CQ9_CODIGO,
            CQ9_MOEDA,
            CQ9_TPSALD,
            'SUB_CQ9_LP' -- Normaliza S/N como nao-zeramento
    SELECT @cStrTran = '2' 
    SELECT 
            CQ8_FILIAL,
            SUBSTRING(CQ8_DATA,1,6) AS ANOMES,
            CQ8_IDENT,
            CQ8_CODIGO,
            CQ8_MOEDA,
            CQ8_TPSALD,
            'SUB_CQ8_LP' AS CQ8_LP, -- Normaliza S/N como nao-zeramento
            SUM(CQ8_DEBITO)  AS DEB_MES,
            SUM(CQ8_CREDIT) AS CRED_MES
    FROM CQ8###
    WHERE 
        ((@IN_LMULTIFIL = '0' AND CQ8_FILIAL = @cFilial) OR (CQ8_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
        CQ8_DATA BETWEEN @cDatIni AND @cDatFim AND
        ((CQ8_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                
        ((@IN_TPSALDO = '*' AND CQ8_TPSALD <> '9') OR CQ8_TPSALD = @IN_TPSALDO) AND       
        D_E_L_E_T_ = ' '
    GROUP BY 
            CQ8_FILIAL,
            SUBSTRING(CQ8_DATA,1,6),
            CQ8_IDENT,
            CQ8_CODIGO,
            CQ8_MOEDA,
            CQ8_TPSALD,
            'SUB_CQ8_LP' -- Normaliza S/N como nao-zeramento
    SELECT @cStrTran = '3' 
    SELECT 
            COALESCE(D.CQ9_FILIAL, M.CQ8_FILIAL) AS FILIAL,
            COALESCE(D.ANOMES, M.ANOMES) AS ANOMES,
            COALESCE(D.CQ9_IDENT, M.CQ8_IDENT) AS IDENT,
            COALESCE(D.CQ9_CODIGO, M.CQ8_CODIGO) AS CODIGO,
            COALESCE(D.CQ9_MOEDA, M.CQ8_MOEDA) AS MOEDA,
            COALESCE(D.CQ9_TPSALD, M.CQ8_TPSALD) AS TPSALD,
            COALESCE(D.CQ9_LP, M.CQ8_LP) AS LP,
            COALESCE(D.DEB_DIA,0)  AS DEB_DIA,
            COALESCE(M.DEB_MES,0)  AS DEB_MES,
            COALESCE(D.CRED_DIA,0) AS CRED_DIA,
            COALESCE(M.CRED_MES,0) AS CRED_MES
    FROM SLD_DIA_MES D
    FULL OUTER JOIN SLD_MES M
        ON M.CQ8_FILIAL = D.CQ9_FILIAL
        AND M.ANOMES     = D.ANOMES
        AND M.CQ8_IDENT  = D.CQ9_IDENT
        AND M.CQ8_CODIGO = D.CQ9_CODIGO
        AND M.CQ8_MOEDA  = D.CQ9_MOEDA
        AND M.CQ8_TPSALD = D.CQ9_TPSALD
        AND M.CQ8_LP     = D.CQ9_LP
    SELECT @cStrTran = '4' 
    SELECT 
        FILIAL,
        ANOMES,
        IDENT,
        CODIGO,
        MOEDA,
        TPSALD,
        LP,
        DEB_DIA,
        DEB_MES,
        CRED_DIA,
        CRED_MES
    FROM CONC_DET
    WHERE ABS(DEB_DIA  - DEB_MES)  > 0.005
        OR ABS(CRED_DIA - CRED_MES) > 0.005
    SELECT @cStrTran = '5' 
    SELECT 
        FILIAL,
        ANOMES,
        IDENT,
        'CUSTO' AS CUSTO,
        'ITEM' AS ITEM,
        'CLASSE' AS CLVL,  
        MOEDA,
        TPSALD,
        SUM(DEB_DIA)  AS DEB_DIA,
        SUM(DEB_MES)  AS DEB_MES,
        SUM(CRED_DIA) AS CRED_DIA,
        SUM(CRED_MES) AS CRED_MES
    FROM ERROS_DET
    GROUP BY FILIAL, ANOMES, IDENT, CODIGO, MOEDA, TPSALD
    SELECT @cStrTran = '6'    
    SELECT
        @cFilQLJ,
        EC.FILIAL,
        EC.ANOMES || '01',    
        ' ' AS QLJ_CONTA,    
        EC.CUSTO,
        EC.ITEM,
        EC.CLVL,
        ' ' AS QLJ_ENT05,
        ' ' AS QLJ_ENT06,
        ' ' AS QLJ_ENT07,
        ' ' AS QLJ_ENT08,
        ' ' AS QLJ_ENT09,        
        EC.DEB_DIA,
        EC.DEB_MES,
        EC.CRED_DIA,
        EC.CRED_MES,
        EC.MOEDA,
        EC.TPSALD,
        @IN_UUID,
        'CQ9'
    FROM ERROS_CONSOL EC
    WHERE NOT EXISTS (
        SELECT 1
        FROM QLJ### Q
        WHERE Q.QLJ_FILIAL = @cFilQLJ
        AND Q.QLJ_FILORI = EC.FILIAL
        AND Q.QLJ_DATA BETWEEN EC.ANOMES || '01' AND EC.ANOMES || '31'
        AND ((EC.IDENT = 'CTT' AND QLJ_CUSTO = EC.CUSTO) OR (EC.IDENT = 'CTD' AND QLJ_ITEM = EC.ITEM) OR (EC.IDENT = 'CTH' AND QLJ_CLVL = EC.CLVL))      
        AND Q.QLJ_MOEDA  = EC.MOEDA
        AND Q.QLJ_TPSALD = EC.TPSALD        
        AND Q.D_E_L_E_T_ = ' '
    )

    ##IF_998({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
        ##IF_001({|| lNiv05 := CT2->(FieldPos('CT2_EC05DB'))>0})
        ##ENDIF_001
        ##IF_002({|| lNiv06 := CT2->(FieldPos('CT2_EC06DB'))>0})
        ##ENDIF_002
        ##IF_003({|| lNiv07 := CT2->(FieldPos('CT2_EC07DB'))>0})
        ##ENDIF_003
        ##IF_004({|| lNiv08 := CT2->(FieldPos('CT2_EC08DB'))>0})
        ##ENDIF_004
        ##IF_005({|| lNiv09 := CT2->(FieldPos('CT2_EC09DB'))>0})
        ##ENDIF_005

        -- Corrige CQ6
        SELECT @cStrTran = '1'      	
            SELECT
                CVX_FILIAL,
                CVX_CONFIG,
                SUBSTRING(CVX_DATA,1,6) AS ANOMES,
                CVX_MOEDA,
                CVX_TPSALD,
                CVX_NIV01, 
                CVX_NIV02, 
                CVX_NIV03, 
                CVX_NIV04,
                ##IF_006({|| lNiv05 }) 
                    CVX_NIV05,
                ##ENDIF_006
                ##IF_007({|| lNiv06 }) 
                    CVX_NIV06,
                ##ENDIF_007
                ##IF_008({|| lNiv07 }) 
                    CVX_NIV07,
                ##ENDIF_008
                ##IF_009({|| lNiv08 }) 
                    CVX_NIV08,
                ##ENDIF_009
                ##IF_010({|| lNiv09 }) 
                    CVX_NIV09,
                ##ENDIF_010
                SUM(CVX_SLDDEB) AS DEB_DIA,
                SUM(CVX_SLDCRD) AS CRED_DIA
            FROM CVX###
            WHERE
                ((@IN_LMULTIFIL = '0' AND CVX_FILIAL = @cFilial) OR (CVX_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
                CVX_DATA BETWEEN @cDatIni AND @cDatFim AND
                ((CVX_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                
                ((@IN_TPSALDO = '*' AND CVX_TPSALD <> '9') OR CVX_TPSALD = @IN_TPSALDO) AND       
                D_E_L_E_T_ = ' '            
            GROUP BY
                CVX_FILIAL,
                CVX_CONFIG,
                SUBSTRING(CVX_DATA,1,6),                
                CVX_NIV01,
                CVX_NIV02,
                CVX_NIV03,
                CVX_NIV04,
                ##IF_011({|| lNiv05 }) 
                    CVX_NIV05,
                ##ENDIF_011
                ##IF_012({|| lNiv06 }) 
                    CVX_NIV06,
                ##ENDIF_012
                ##IF_013({|| lNiv07 }) 
                    CVX_NIV07,
                ##ENDIF_013
                ##IF_014({|| lNiv08 }) 
                    CVX_NIV08,
                ##ENDIF_014
                ##IF_015({|| lNiv09 }) 
                    CVX_NIV09,
                ##ENDIF_015
                CVX_MOEDA,
                CVX_TPSALD
        SELECT @cStrTran = '2'
            SELECT
                CVY_FILIAL,
                CVY_CONFIG,
                SUBSTRING(CVY_DATA,1,6) AS ANOMES,
                CVY_NIV01,
                CVY_NIV02,
                CVY_NIV03,
                CVY_NIV04,
                ##IF_016({|| lNiv05 }) 
                    CVY_NIV05,
                ##ENDIF_016
                ##IF_017({|| lNiv06 }) 
                    CVY_NIV06,
                ##ENDIF_017
                ##IF_018({|| lNiv07 }) 
                    CVY_NIV07,
                ##ENDIF_018
                ##IF_019({|| lNiv08 }) 
                    CVY_NIV08,  
                ##ENDIF_019
                ##IF_020({|| lNiv09 }) 
                    CVY_NIV09,  
                ##ENDIF_020               
                CVY_MOEDA,
                CVY_TPSALD,
                SUM(CVY_SLDDEB) AS DEB_MES,
                SUM(CVY_SLDCRD) AS CRED_MES
            FROM CVY###
            WHERE
                ((@IN_LMULTIFIL = '0' AND CVY_FILIAL = @cFilial) OR (CVY_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
                CVY_DATA BETWEEN @cDatIni AND @cDatFim AND
                ((CVY_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                
                ((@IN_TPSALDO = '*' AND CVY_TPSALD <> '9') OR CVY_TPSALD = @IN_TPSALDO) AND       
                D_E_L_E_T_ = ' '
            GROUP BY
                CVY_FILIAL,
                CVY_CONFIG,
                SUBSTRING(CVY_DATA,1,6),
                CVY_NIV01,
                CVY_NIV02,
                CVY_NIV03,
                CVY_NIV04,
                ##IF_021({|| lNiv05 }) 
                    CVY_NIV05,
                ##ENDIF_021
                ##IF_022({|| lNiv06 }) 
                    CVY_NIV06,
                ##ENDIF_022
                ##IF_023({|| lNiv07 }) 
                    CVY_NIV07,  
                ##ENDIF_023
                ##IF_024({|| lNiv08 }) 
                    CVY_NIV08,
                ##ENDIF_024
                ##IF_025({|| lNiv09 }) 
                    CVY_NIV09,
                ##ENDIF_025
                CVY_MOEDA,
                CVY_TPSALD
        SELECT @cStrTran = '3'      
            SELECT
                COALESCE(D.CVX_FILIAL, M.CVY_FILIAL) FILIAL,
                COALESCE(D.ANOMES,     M.ANOMES)     ANOMES,
                COALESCE(D.CVX_CONFIG, M.CVY_CONFIG) CONFIG,
                COALESCE(D.CVX_NIV01,  M.CVY_NIV01)  CONTA,
                COALESCE(D.CVX_NIV02,  M.CVY_NIV02)  CUSTO,
                COALESCE(D.CVX_NIV03,  M.CVY_NIV03)  ITEM,
                COALESCE(D.CVX_NIV04,  M.CVY_NIV04)  CLVL,
                ##IF_026({|| lNiv05 })
                    COALESCE(D.CVX_NIV05,  M.CVY_NIV05)  NIV05,
                ##ENDIF_026
                ##IF_027({|| lNiv06 })
                    COALESCE(D.CVX_NIV06,  M.CVY_NIV06)  NIV06,
                ##ENDIF_027
                ##IF_028({|| lNiv07 })
                    COALESCE(D.CVX_NIV07,  M.CVY_NIV07)  NIV07,
                ##ENDIF_028
                ##IF_029({|| lNiv08 })
                    COALESCE(D.CVX_NIV08,  M.CVY_NIV08)  NIV08,
                ##ENDIF_029
                ##IF_030({|| lNiv09 })
                    COALESCE(D.CVX_NIV09,  M.CVY_NIV09)  NIV09,
                ##ENDIF_030
                COALESCE(D.CVX_MOEDA,  M.CVY_MOEDA)  MOEDA,
                COALESCE(D.CVX_TPSALD, M.CVY_TPSALD) TPSALD,                
                COALESCE(D.DEB_DIA,0)  AS DEB_DIA,
                COALESCE(M.DEB_MES,0)  AS DEB_MES,
                COALESCE(D.CRED_DIA,0) AS CRED_DIA,
                COALESCE(M.CRED_MES,0) AS CRED_MES
            FROM SLD_DIA_MES D
            FULL OUTER JOIN SLD_MES M
                ON M.CVY_FILIAL  = D.CVX_FILIAL
                AND M.ANOMES     = D.ANOMES
                AND M.CVY_CONFIG = D.CVX_CONFIG
                AND M.CVY_NIV01  = D.CVX_NIV01
                AND M.CVY_NIV02  = D.CVX_NIV02
                AND M.CVY_NIV03  = D.CVX_NIV03
                AND M.CVY_NIV04  = D.CVX_NIV04
                ##IF_031({|| lNiv05 })
                    AND M.CVY_NIV05  = D.CVX_NIV05
                ##ENDIF_031
                ##IF_032({|| lNiv06 })
                    AND M.CVY_NIV06  = D.CVX_NIV06
                ##ENDIF_032
                ##IF_033({|| lNiv07 })
                    AND M.CVY_NIV07  = D.CVX_NIV07
                ##ENDIF_033
                ##IF_034({|| lNiv08 })
                    AND M.CVY_NIV08  = D.CVX_NIV08
                ##ENDIF_034
                ##IF_035({|| lNiv09 })
                    AND M.CVY_NIV09  = D.CVX_NIV09
                ##ENDIF_035
                AND M.CVY_MOEDA  = D.CVX_MOEDA
                AND M.CVY_TPSALD = D.CVX_TPSALD                
        SELECT @cStrTran = '4'       
            SELECT 
                FILIAL, 
                ANOMES, 
                CONFIG,
                CONTA,
                CUSTO,
                ITEM,
                CLVL,
                ##IF_036({|| lNiv05 })
                    NIV05,
                ##ENDIF_036
                ##IF_037({|| lNiv06 })
                    NIV06,
                ##ENDIF_037
                ##IF_038({|| lNiv07 })
                    NIV07,
                ##ENDIF_038
                ##IF_039({|| lNiv08 })
                    NIV08,
                ##ENDIF_039
                ##IF_040({|| lNiv09 })
                    NIV09,
                ##ENDIF_040
                MOEDA, 
                TPSALD, 
                DEB_DIA, 
                DEB_MES, 
                CRED_DIA, 
                CRED_MES
            FROM CONC_DET
            WHERE 
                ABS(DEB_DIA - DEB_MES)  > 0.005
                OR ABS(CRED_DIA - CRED_MES) > 0.005
        SELECT @cStrTran = '5'      
            SELECT
                FILIAL,
                ANOMES,
                CONTA,
                CUSTO,
                ITEM,
                CLVL,
                ##IF_041({|| lNiv05 })
                    NIV05,
                ##ENDIF_041
                ##IF_042({|| lNiv06 })
                    NIV06,
                ##ENDIF_042
                ##IF_043({|| lNiv07 })
                    NIV07,
                ##ENDIF_043
                ##IF_044({|| lNiv08 })
                    NIV08,
                ##ENDIF_044
                ##IF_045({|| lNiv09 })
                    NIV09,
                ##ENDIF_045
                MOEDA,
                TPSALD,
                DEB_DIA,
                DEB_MES,
                CRED_DIA,
                CRED_MES
            FROM ERROS_DET
            GROUP BY
                FILIAL,
                ANOMES,                
                CONTA,
                CUSTO,
                ITEM,
                CLVL,
                ##IF_046({|| lNiv05 })
                    NIV05,
                ##ENDIF_046
                ##IF_047({|| lNiv06 })
                    NIV06,
                ##ENDIF_047
                ##IF_048({|| lNiv07 })
                    NIV07,
                ##ENDIF_048
                ##IF_049({|| lNiv08 })
                    NIV08,
                ##ENDIF_049
                ##IF_050({|| lNiv09 })
                    NIV09,
                ##ENDIF_050                
                MOEDA,
                TPSALD,
                DEB_DIA,
                DEB_MES,
                CRED_DIA,
                CRED_MES
        SELECT @cStrTran = '6'        
        SELECT
            @cFilQLJ,
            EC.FILIAL,
            EC.ANOMES||'01',
            EC.CONTA,
            EC.CUSTO,
            EC.ITEM,
            EC.CLVL,
            ##IF_051({|| lNiv05 })
                EC.NIV05,
            ##ELSE_051
                ' ' AS NIV05,
            ##ENDIF_051
            ##IF_052({|| lNiv06 })
                EC.NIV06,
            ##ELSE_052
                ' ' AS NIV06,
            ##ENDIF_052
            ##IF_053({|| lNiv07 })
                EC.NIV07,
            ##ELSE_053
                ' ' AS NIV07,
            ##ENDIF_053
            ##IF_054({|| lNiv08 })
                EC.NIV08,
            ##ELSE_054
                ' ' AS NIV08,
            ##ENDIF_054
            ##IF_055({|| lNiv09 })
                EC.NIV09,
            ##ELSE_055
                ' ' AS NIV09,
            ##ENDIF_055
            EC.DEB_DIA,
            EC.DEB_MES,
            EC.CRED_DIA,
            EC.CRED_MES,
            EC.MOEDA,
            RTRIM(EC.TPSALD),
            @IN_UUID,	
            'CVX'
        FROM ERROS_CONSOL EC
        WHERE NOT EXISTS (
            SELECT 1
            FROM QLJ### Q
            WHERE Q.QLJ_FILIAL = @cFilQLJ
            AND Q.QLJ_FILORI  = EC.FILIAL
            AND Q.QLJ_DATA BETWEEN EC.ANOMES||'01' AND EC.ANOMES||'31'
            AND Q.QLJ_CONTA  = EC.CONTA
            AND Q.QLJ_CUSTO  = EC.CUSTO
            AND Q.QLJ_ITEM   = EC.ITEM
            AND Q.QLJ_CLVL   = EC.CLVL
            ##IF_056({|| lNiv05 })
                AND Q.QLJ_ENT05  = EC.NIV05
            ##ELSE_056
                AND Q.QLJ_ENT05  = ' '
            ##ENDIF_056
            ##IF_057({|| lNiv06 })
                AND Q.QLJ_ENT06  = EC.NIV06
            ##ELSE_057
                AND Q.QLJ_ENT06  = ' '
            ##ENDIF_057
            ##IF_058({|| lNiv07 })
                AND Q.QLJ_ENT07  = EC.NIV07
            ##ELSE_058
                AND Q.QLJ_ENT07  = ' '
            ##ENDIF_058
            ##IF_059({|| lNiv08 })
                AND Q.QLJ_ENT08  = EC.NIV08
            ##ELSE_059
                AND Q.QLJ_ENT08  = ' '
            ##ENDIF_059
            ##IF_060({|| lNiv09 })
                AND Q.QLJ_ENT09  = EC.NIV09
            ##ELSE_060
                AND Q.QLJ_ENT09  = ' '
            ##ENDIF_060
            AND Q.QLJ_MOEDA  = EC.MOEDA
            AND Q.QLJ_TPSALD = EC.TPSALD            
            AND Q.QLJ_UUID   = @IN_UUID
            AND Q.D_E_L_E_T_ = ' '
        )    
    ##ENDIF_998

	select @OUT_RESULTADO = '1'
select @cEnd = ''    
end
##ENDIF_999
