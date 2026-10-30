/*
====================================================================
 Procedure CTBS500 - Apuracao do Balancete da DeRE (evento D-1101 / evtBalancete)
====================================================================
 Le CQ0 (saldo mensal por conta - MOVIMENTO BRUTO do mes), CT2
 (SOMENTE os estornos), CT1 (natureza da conta) e QLT (amarracao
 Plano de Contas x Codigo de Tributacao) e grava o resultado apurado
 na tabela QLU, por conta e periodo (AAAA-MM).

 UNIVERSO DE CONTAS (Nivel M):
   Uma conta entra no balancete se teve MOVIMENTO no periodo OU se
   possui SALDO > 0. O Nivel M e a UNIAO de tres fontes de contas:
     (1) movimento do mes (CQ0 no ultimo dia, CQ0_DATA = dFimPer);
     (2) saldo da QLU da apuracao imediatamente anterior (QLU_VLFIM > 0);
     (3) acumulo da CQ0 anterior ao periodo (1o envio).
   As fontes (2) e (3) contribuem com movimento ZERO -- servem apenas
   para TRAZER a conta ao universo; o valor do saldo inicial e resolvido
   adiante pelos CASE de VLINI/ORIGSI (JOINs ANT e CQ). Sem essa uniao,
   contas sem movimento no mes mas com saldo ficavam de fora do arquivo.

 FONTE DO MOVIMENTO (performance):
   - Movimento BRUTO do mes vem da CQ0, lida no ULTIMO dia do mes
     (CQ0_DATA = dFimPer), onde o Protheus grava o consolidado do
     periodo: vMovDebt = SUM(CQ0_DEBITO), vMovCred = SUM(CQ0_CREDIT).
     Uma linha por conta/lote, evitando varrer milhoes de linhas da CT2.
   - Os ESTORNOS sao lidos apenas da CT2 (unica tabela com o marcador
     CT2_ESTORN = '1'). O estorno e uma partida reversa, entao o
     de-para do ajuste e CRUZADO em relacao a posicao lancada: o
     estorno lancado a CREDITO reverte um debito e alimenta vAjusteDebt;
     o estorno lancado a DEBITO reverte um credito e alimenta
     vAjusteCred. Esse cruzamento reflete o duplo proposito do ajuste
     no Manual (o ajuste de uma posicao inclui valores na posicao
     oposta para fins de calculo do vApur) e faz o CONFERIR_VAPUR anular
     o estorno reverso puro.

 EXPURGO DE APURACAO (@IN_dUltApur):
   Quando a data da ultima apuracao e informada (nao vazia) e cai
   dentro do mes, os lancamentos de apuracao sao ignorados:
     - CQ0: registros com CQ0_DTLP = @IN_dUltApur E CQ0_LP = 'Z'
     - CT2: registros com CT2_DTLP = @IN_dUltApur
   Quando @IN_dUltApur vem vazia, os filtros ficam neutros (a condicao
   com ' ' nao exclui nada), pois nao ha lote de apuracao a expurgar.

 CODTRIB (amarracao QLT): obtido da QLT considerando SOMENTE os
 registros 1:1 nao desdobrados (QLT_DBMIST = '000'), com QLT_CODTRB
 preenchido e vigentes no ultimo dia do periodo (QLT_INIVIG <= dFimPer
 e QLT_FIMVIG vazio ou >= dFimPer). Contas SEM amarracao valida, ou
 com MAIS DE UM CODTRIB distinto (mistas), sao EXCLUIDAS do balancete
 (INNER JOIN com QTDTRB = 1). O cCta = conta (sem pontos) + '.' + QLT_DBMIST.

 CALCULO conforme o Manual da DeRE (fonte: regra_calculo_dere.txt):
   Saldo Liquido (SL) - BRUTO (ajustes/estornos NAO entram no SL):
     Natureza inicial D: SL = vSaldoInic + vMovDebt - vMovCred
     Natureza inicial C: SL = (vSaldoInic * -1) + vMovDebt - vMovCred
   Saldo Final (vSaldoFinal) e sua natureza (natSaldoFinal):
     SL > 0 -> vSaldoFinal = SL        ; natSaldoFinal = 'D'
     SL < 0 -> vSaldoFinal = SL * -1   ; natSaldoFinal = 'C'
     SL = 0 -> vSaldoFinal = 0         ; natSaldoFinal = natSaldoInic
   Valor de Apuracao (vApur) - regra CONFERIR_VAPUR:
     natVApur 'D': vApur = vMovDebt - vAjusteDebt + vAjusteCred
     natVApur 'C': vApur = vMovCred - vAjusteCred + vAjusteDebt
   A natureza (natVApur) e determinada pelo PREFIXO do CODTRIB
   (QLT_CODTRB), conforme regra_natVapur.txt (prefixo '2'/'3' -> 'C';
   '4' -> 'D'; '1'/Ativo -> prefixos devedores especificos 'D', demais
   'C'; fallback 'C'). Regra imune a edicoes nas descricoes das tabelas
   da RFB. O CASE de direcao e injetado por EngPos##Compile (CTBD1Dir).

 SALDO INICIAL (por conta): QLU do periodo anterior (origem 'A') ->
   senao acumulo da CQ0 anterior ao periodo (origem 'Q') -> senao zero
   c/ CT1_NORMAL ('Z').

 --------------------------------------------------------------------
 TOKENS DE INJECAO (SPTK_*):
 --------------------------------------------------------------------
 O parser do instalador de procedures REMOVE as expressoes CASE WHEN.
 Por isso, todo CASE foi substituido por um TOKEN neutro (string
 literal 'SPTK_xxx'), que sobrevive ao parser. O ponto de entrada
 EngPos##Compile (ver CTBS500.prw) reinjeta o CASE real no buffer
 JA parseado, imediatamente antes da compilacao no SGBD. NAO remova
 nem altere os tokens sem ajustar o EngPos##Compile correspondente.

 Tokens do engine (traduzidos na compilacao / MsParse):
   ##  -> sufixo do processo/empresa
   ### -> sufixo fisico da tabela (RetSqlName)
   XFILIAL_## -> resolucao de filial no padrao do dicionario
====================================================================
*/
CREATE PROCEDURE CTBS500_## (
    @IN_cFilial   CHAR('CT2_FILIAL'),
    @IN_cPerApur  CHAR(7),
    @IN_dIniPer   CHAR(8),
    @IN_dFimPer   CHAR(8),
    @IN_cMoeda    CHAR('CT2_MOEDLC'),
    @IN_cTpSald   CHAR('CT2_TPSALD'),
    @IN_dUltApur  CHAR(8),
    @IN_dDtProc   CHAR(8),
    @IN_cHrProc   CHAR('QLU_HRPROC'),
    @OUT_RESULT   CHAR(1) OUTPUT )
AS
DECLARE @cFilCT2  CHAR('CT2_FILIAL')
DECLARE @cFilCT1  CHAR('CT1_FILIAL')
DECLARE @cFilCQ0  CHAR('CQ0_FILIAL')
DECLARE @cFilQLU  CHAR('QLU_FILIAL')
DECLARE @cFilQLT  CHAR('QLT_FILIAL')

BEGIN    
    SELECT @OUT_RESULT = '0'

    -- Resolucao das filiais de cada tabela a partir da filial informada
    EXEC XFILIAL_## 'CT2', @IN_cFilial, @cFilCT2 output
    EXEC XFILIAL_## 'CT1', @IN_cFilial, @cFilCT1 output
    EXEC XFILIAL_## 'CQ0', @IN_cFilial, @cFilCQ0 output
    EXEC XFILIAL_## 'QLU', @IN_cFilial, @cFilQLU output
    EXEC XFILIAL_## 'QLT', @IN_cFilial, @cFilQLT output

    -- Reprocesso - remove fisicamente o periodo/filial (todos os
    -- CODTRIB, pois o codigo agora e derivado da QLT por conta)
    DELETE FROM QLU###
     WHERE QLU_FILIAL = @cFilQLU
       AND QLU_PERAPU = @IN_cPerApur

    -- Apura por conta e grava a QLU numa unica passagem
    INSERT INTO QLU###
        ( QLU_FILIAL, QLU_PERAPU, QLU_CONTA, QLU_CODTRB, QLU_CCTA,
          QLU_NATINI, QLU_VLINI, QLU_MOVDEB, QLU_AJUDEB, QLU_MOVCRE, QLU_AJUCRE,
          QLU_NATFIM, QLU_VLFIM, QLU_NATAPU, QLU_VLAPUR,
          QLU_MOEDA, QLU_TPSALD, QLU_DTPROC, QLU_HRPROC, QLU_ORIGSI )
    SELECT
        @cFilQLU,
        @IN_cPerApur,
        C.CONTA,
        C.CODTRB,
        REPLACE(RTRIM(C.CONTA), '.', '') || '.' || RTRIM(C.DBMIST),
        C.NATINI,
        C.VLINI,
        C.MOVDEB,
        C.AJUDEB,
        C.MOVCRE,
        C.AJUCRE,
        'SPTK_NATFIM',        -- natSaldoFinal (CASE injetado por EngPos##Compile)
        'SPTK_VLFIM',         -- vSaldoFinal   (CASE injetado por EngPos##Compile)
        'SPTK_NATAPU',        -- natVApur      (CASE injetado por EngPos##Compile)
        C.VAPUR,
        @IN_cMoeda,
        @IN_cTpSald,
        @IN_dDtProc,
        @IN_cHrProc,
        C.ORIGSI
    FROM (
        -- Nivel C: adiciona SL (Saldo Liquido) e VAPUR (Valor de Apuracao)
        SELECT
            B.CONTA, B.CODTRB, B.DBMIST, B.MOVDEB, B.AJUDEB, B.MOVCRE, B.AJUCRE,
            B.NATINI, B.VLINI, B.ORIGSI,
            'SPTK_SL'    AS SL,      -- SL     (CASE injetado por EngPos##Compile)
            'SPTK_VAPUR' AS VAPUR    -- vApur  (CASE injetado por EngPos##Compile)
        FROM (
            -- Nivel B: movimento bruto (CQ0) + estorno (CT2) + CODTRIB (QLT) + saldo inicial
            SELECT
                M.CONTA,
                TRB.CODTRB,
                TRB.DBMIST,
                M.MOVDEB,
                COALESCE(EST.AJUDEB, 0) AS AJUDEB,
                M.MOVCRE,
                COALESCE(EST.AJUCRE, 0) AS AJUCRE,
                'SPTK_NATINI' AS NATINI,   -- natSaldoInic (CASE injetado)
                'SPTK_VLINI'  AS VLINI,    -- vSaldoInic   (CASE injetado)
                'SPTK_ORIGSI' AS ORIGSI    -- origem saldo (CASE injetado)
            FROM (
                -- Nivel M: UNIVERSO DE CONTAS = contas com MOVIMENTO no
                -- periodo (CQ0 no ultimo dia do mes) UNIAO contas com
                -- SALDO (QLU do periodo anterior ou acumulo da CQ0
                -- anterior ao periodo). Regra: a conta entra no balancete
                -- se teve movimento no periodo OU se possui saldo > 0.
                -- As fontes de SALDO contribuem com movimento ZERO -- elas
                -- servem apenas para TRAZER a conta ao universo; o valor do
                -- saldo inicial e resolvido adiante pelos CASE de VLINI/
                -- ORIGSI (JOINs ANT e CQ), ligados por M.CONTA.
                -- Uma linha por conta (agregando eventuais lotes CQ0_LP).
                -- Expurgo de apuracao: ignora CQ0_DTLP = dUltApur E CQ0_LP = 'Z'.
                SELECT U.CONTA AS CONTA,
                       SUM(U.MOVDEB) AS MOVDEB,
                       SUM(U.MOVCRE) AS MOVCRE
                  FROM (
                        -- (1) Movimento bruto do mes (CQ0 no ultimo dia)
                        SELECT CQ0_CONTA AS CONTA,
                               CQ0_DEBITO AS MOVDEB,
                               CQ0_CREDIT AS MOVCRE
                          FROM CQ0###
                         WHERE CQ0_FILIAL = @cFilCQ0
                           AND CQ0_DATA   = @IN_dFimPer
                           AND CQ0_MOEDA  = @IN_cMoeda
                           AND CQ0_TPSALD = @IN_cTpSald
                           AND NOT ( CQ0_DTLP = @IN_dUltApur AND CQ0_LP = 'Z' AND @IN_dUltApur <> ' ' )
                           AND D_E_L_E_T_ = ' '
                        UNION ALL
                        -- (2) Contas com saldo na QLU da apuracao
                        --     imediatamente anterior (mesmo criterio do
                        --     JOIN ANT: MAX(QLU_PERAPU) < periodo atual).
                        --     Considera apenas o ULTIMO periodo anterior
                        --     para nao trazer conta que ja zerou o saldo.
                        --     Movimento zero -- so traz a conta ao universo.
                        SELECT QA.QLU_CONTA AS CONTA,
                               0 AS MOVDEB,
                               0 AS MOVCRE
                          FROM QLU### QA
                         INNER JOIN (
                                SELECT QLU_CONTA, QLU_CODTRB, MAX(QLU_PERAPU) AS MAXPER
                                  FROM QLU###
                                 WHERE QLU_FILIAL = @cFilQLU
                                   AND QLU_PERAPU < @IN_cPerApur
                                   AND D_E_L_E_T_ = ' '
                                 GROUP BY QLU_CONTA, QLU_CODTRB
                               ) QM
                            ON QM.QLU_CONTA  = QA.QLU_CONTA
                           AND QM.QLU_CODTRB = QA.QLU_CODTRB
                           AND QM.MAXPER     = QA.QLU_PERAPU
                         WHERE QA.QLU_FILIAL = @cFilQLU
                           AND QA.QLU_VLFIM > 0
                           AND QA.D_E_L_E_T_ = ' '
                        UNION ALL
                        -- (3) Contas com acumulo na CQ0 anterior ao periodo
                        --     (movimento zero -- so traz a conta ao universo)
                        SELECT CQ0_CONTA AS CONTA,
                               0 AS MOVDEB,
                               0 AS MOVCRE
                          FROM CQ0###
                         WHERE CQ0_FILIAL = @cFilCQ0
                           AND CQ0_MOEDA  = @IN_cMoeda
                           AND CQ0_TPSALD = @IN_cTpSald
                           AND CQ0_DATA   < @IN_dIniPer
                           AND D_E_L_E_T_ = ' '
                       ) U
                 GROUP BY U.CONTA
            ) M
            -- Estornos da CT2 (unica tabela com CT2_ESTORN). De-para
            -- CRUZADO (partida reversa): estorno lancado a CREDITO
            -- reverte um debito -> AJUDEB (vAjusteDebt); estorno lancado
            -- a DEBITO reverte um credito -> AJUCRE (vAjusteCred).
            -- Expurgo: ignora CT2_DTLP = dUltApur.
            LEFT JOIN (
                SELECT CONTA,
                       'SPTK_ESTAJUDEB' AS AJUDEB,   -- SUM(CASE POS='C') injetado (estorno a credito reverte debito)
                       'SPTK_ESTAJUCRE' AS AJUCRE    -- SUM(CASE POS='D') injetado (estorno a debito reverte credito)
                FROM (
                    SELECT CT2_DEBITO AS CONTA, 'D' AS POS, CT2_VALOR AS VALOR
                      FROM CT2###
                     WHERE CT2_FILIAL = @cFilCT2
                       AND CT2_DATA  >= @IN_dIniPer
                       AND CT2_DATA  <= @IN_dFimPer
                       AND CT2_MOEDLC = @IN_cMoeda
                       AND CT2_TPSALD = @IN_cTpSald
                       AND CT2_DC IN('1','3')
                       AND CT2_DEBITO <> ' '
                       AND CT2_ESTORN = '1'                       
                       AND CT2_DTLP = ' '
                       AND D_E_L_E_T_ = ' '
                    UNION ALL
                    SELECT CT2_CREDIT AS CONTA, 'C' AS POS, CT2_VALOR AS VALOR
                      FROM CT2###
                     WHERE CT2_FILIAL = @cFilCT2
                       AND CT2_DATA  >= @IN_dIniPer
                       AND CT2_DATA  <= @IN_dFimPer
                       AND CT2_MOEDLC = @IN_cMoeda
                       AND CT2_TPSALD = @IN_cTpSald
                       AND CT2_DC IN('2','3')
                       AND CT2_CREDIT <> ' '
                       AND CT2_ESTORN = '1'
                       AND CT2_DTLP = ' '
                       AND D_E_L_E_T_ = ' '
                ) E
                GROUP BY CONTA
            ) EST
              ON EST.CONTA = M.CONTA
            -- CODTRIB pela amarracao QLT: SOMENTE contas 1:1 (QTDTRB = 1),
            -- nao desdobradas (QLT_DBMIST = '000'), com CODTRIB preenchido
            -- e vigentes no ultimo dia do periodo. INNER JOIN: contas sem
            -- amarracao ou mistas (QTDTRB > 1) sao excluidas do balancete.
            INNER JOIN (
                SELECT QLT_CONTA AS CONTA,
                       MAX(QLT_CODTRB)            AS CODTRB,
                       MAX(QLT_DBMIST)            AS DBMIST,
                       COUNT(DISTINCT QLT_CODTRB) AS QTDTRB
                  FROM QLT###
                 WHERE QLT_FILIAL = @cFilQLT
                   AND QLT_DBMIST = '000'
                   AND QLT_CODTRB <> ' '
                   AND QLT_INIVIG <= @IN_dFimPer
                   AND ( QLT_FIMVIG = ' ' OR QLT_FIMVIG >= @IN_dFimPer )
                   AND D_E_L_E_T_ = ' '
                 GROUP BY QLT_CONTA
            ) TRB
              ON TRB.CONTA  = M.CONTA
             AND TRB.QTDTRB = 1
            -- Saldo final da apuracao imediatamente anterior (mesma conta/CODTRIB)
            LEFT JOIN (
                SELECT Q.QLU_CONTA, Q.QLU_CODTRB, Q.QLU_NATFIM, Q.QLU_VLFIM
                FROM QLU### Q
                INNER JOIN (
                        SELECT QLU_CONTA, QLU_CODTRB, MAX(QLU_PERAPU) AS MAXPER
                          FROM QLU###
                         WHERE QLU_FILIAL = @cFilQLU
                           AND QLU_PERAPU < @IN_cPerApur
                           AND D_E_L_E_T_ = ' '
                         GROUP BY QLU_CONTA, QLU_CODTRB
                       ) MX
                    ON MX.QLU_CONTA  = Q.QLU_CONTA
                   AND MX.QLU_CODTRB = Q.QLU_CODTRB
                   AND MX.MAXPER     = Q.QLU_PERAPU
                 WHERE Q.QLU_FILIAL = @cFilQLU
                   AND Q.D_E_L_E_T_ = ' '
            ) ANT
              ON ANT.QLU_CONTA  = M.CONTA
             AND ANT.QLU_CODTRB = TRB.CODTRB
            -- Acumulo da CQ0 anterior ao periodo (1o envio - saldo inicial)
            LEFT JOIN (
                SELECT CQ0_CONTA, SUM(CQ0_DEBITO) - SUM(CQ0_CREDIT) AS ACUM
                  FROM CQ0###
                 WHERE CQ0_FILIAL = @cFilCQ0
                   AND CQ0_MOEDA  = @IN_cMoeda
                   AND CQ0_TPSALD = @IN_cTpSald
                   AND CQ0_DATA   < @IN_dIniPer
                   AND D_E_L_E_T_ = ' '
                 GROUP BY CQ0_CONTA
            ) CQ
              ON CQ.CQ0_CONTA = M.CONTA
            -- Natureza da conta (CT1_NORMAL: 1=Devedora, 2=Credora)
            LEFT JOIN CT1### CT1
              ON CT1.CT1_FILIAL = @cFilCT1
             AND CT1.CT1_CONTA  = M.CONTA
             AND CT1.D_E_L_E_T_ = ' '
        ) B
    ) C

    SELECT @OUT_RESULT = '1'
END
