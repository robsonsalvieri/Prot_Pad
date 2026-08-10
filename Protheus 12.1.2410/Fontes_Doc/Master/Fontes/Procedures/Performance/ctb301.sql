
-- Procedure creation 
CREATE PROCEDURE CTB301_## (
@IN_FILIAL Char( 'CT2_FILIAL' ) , 
@IN_DATAINI Char( 08 ) , 
@IN_DATAFIM Char( 08 ) , 
@IN_LTDSMOEDA Char( 01 ) , 
@IN_MOEDA Char( 'CT2_MOEDLC' ) , 
@IN_TPSDEST VarChar( 20 ) , 
@IN_LCOPIA Integer , 
@IN_TPSORIG Char( 001 ) , 
@IN_LLOTE Integer , 
@IN_LHIST Integer , 
@IN_CODHIST Char( 003 ) , 
@IN_LOTE Char( 'CT2_LOTE' ) , 
@IN_SBLOTE Char( 'CT2_SBLOTE' ) , 
@IN_MAXLINHA Integer , 
@IN_LTPSALD Char( 01 ) , 
@IN_MV_SOMA CHAR(01),
@IN_CLRCTLSLD CHAR(01),
@IN_TPAPAGA Char(01),
@IN_SLDFILA Char(01),
@IN_ATUSLD Char(01),
@IN_TRANSACTION Char(01), 
@OUT_RESULTADO Char( 01 )  output ) AS

/* ------------------------------------------------------------------------------------
    Versao          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBM300.PRW </s>
    Descricao       - <d>  Copia de Saldos </d>
    Funcao do Siga  -      CTBM300()
    Entrada         - <ri> @IN_FILIAL     - Filial do processamento</ri>
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Douglas Rodrigues da Silva	</r>
    Data        :     21/03/2023
    Parametro   : MV_CTBCUBE = 2 Nao | Utiliza cubo de entidades cont�beis
    Parametro   : MV_CTBJOB  = 2 Nao | Define se usa Job para processamento.

    CTBM300 - Copia de Saldos

    2.[CTBM300PAI]==> CTB301 - Copia simples e Multiplos saldos de lancamentos. - aProc[11]
            NAO FAZ copia pelos saldos das contas                      
      2.1 [CTB300CTC ] ==> CTB309   - Atualiza Cabecalho do Lote               - aProc[10]		   
      2.1 [CTBM300DOC] ==> CTB308   - Proxima linha, documento e lote          - aProc[9]  
      2.1.[CTM300SOMA] ==> MSSOMA1  - Cria a procedure SOMA1                   - aproc[8]  
      2.1.[CTBM300STR] ==> MSSTRZERO                                           - aProc[7]
      2.1 [CTBM300CT7] ==> CTB305   - Atualizacao de saldos no CQ0/CQ1         - aProc[6]
      2.2 [CTBM300CT3] ==> CTB304   - Atualizacao de saldos no CQ2/CQ3         - aProc[5]
      2.3 [CTBM300CT4] ==> CTB303   - Atualizacao de saldos no CQ4/CQ5         - aProc[4]
      2.4 [CTBM300CTI] ==> CTB302   - Atualizacao de saldos no CQ6/CQ7         - aProc[3]
      1.  CTBM300LDAY - Lastday - Retorna o Ultimo dia do Mes                  - aProc[2]
      0.  CallXFILIAL - Cria a procedure xfilial                               - aProc[1]

  //-------------------------------------------------------------------------------------- */
-- Declaration of variables
declare @cAux Char( 03 )
declare @cFil_CT8 Char( 'CT8_FILIAL' )
declare @cFil_CT2 Char( 'CT2_FILIAL' )
declare @cCT2_FILIAL Char( 'CT2_FILIAL' )
declare @cCT2_DATA Char( 'CT2_DATA' )
declare @cCT2_LOTE Char( 'CT2_LOTE' )
declare @cCT2_SBLOTE Char( 'CT2_SBLOTE' )
declare @cCT2_DOC Char( 'CT2_DOC' )
declare @cCT2_LINHA Char( 'CT2_LINHA' )
declare @cCT2_MOEDLC Char( 'CT2_MOEDLC' )
declare @cCT2_DC Char( 'CT2_DC' )
declare @cCT2_DEBITO Char( 'CT2_DEBITO' )
declare @cCT2_CREDIT Char( 'CT2_CREDIT' )
declare @cCT2_DCD Char( 'CT2_DCD' )
declare @cCT2_DCC Char( 'CT2_DCC' )
declare @nCT2_VALOR Float
declare @cCT2_MOEDAS Char( 'CT2_MOEDAS' )
declare @cCT2_HP Char( 'CT2_HP' )
declare @cCT2_HIST Char( 'CT2_HIST' )
declare @cCT2_CCD Char( 'CT2_CCD' )
declare @cCT2_CCC Char( 'CT2_CCC' )
declare @cCT2_ITEMD Char( 'CT2_ITEMD' )
declare @cCT2_ITEMC Char( 'CT2_ITEMC' )
declare @cCT2_CLVLDB Char( 'CT2_CLVLDB' )
declare @cCT2_CLVLCR Char( 'CT2_CLVLCR' )
declare @cCT2_ATIVDE Char( 'CT2_ATIVDE' )
declare @cCT2_ATIVCR Char( 'CT2_ATIVCR' )
declare @cCT2_EMPORI Char( 'CT2_EMPORI' )
declare @cCT2_FILORI Char( 'CT2_FILIAL' )
declare @cCT2_INTERC Char( 'CT2_INTERC' )
declare @cCT2_IDENTC Char( 'CT2_IDENTC' )
declare @cCT2_TPSALD Char( 'CT2_TPSALD' )
declare @cCT2_SEQUEN Char( 'CT2_SEQUEN' )
declare @cCT2_MANUAL Char( 'CT2_MANUAL' )
declare @cCT2_ORIGEM Char( 'CT2_ORIGEM' )
declare @cCT2_ROTINA Char( 'CT2_ROTINA' )
declare @cCT2_AGLUT Char( 'CT2_AGLUT' )
declare @cCT2_LP Char( 'CT2_LP' )
declare @cCT2_SEQHIS Char( 'CT2_SEQHIS' )
declare @cCT2_SEQLAN Char( 'CT2_SEQLAN' )
declare @cCT2_DTVENC Char( 'CT2_DTVENC' )
declare @cCT2_SLBASE Char( 'CT2_SLBASE' )
declare @cCT2_DTLP Char( 'CT2_DTLP' )
declare @cCT2_DATATX Char( 'CT2_DATATX' )
declare @nCT2_TAXA Float
declare @nCT2_VLR01 Float
declare @nCT2_VLR02 Float
declare @nCT2_VLR03 Float
declare @nCT2_VLR04 Float
declare @nCT2_VLR05 Float
declare @cCT2_CRCONV Char( 'CT2_CRCONV' )
declare @cCT2_CRITER Char( 'CT2_CRITER' )
declare @cCT2_KEY Char( 'CT2_KEY' )
declare @cCT2_SEGOFI Char( 'CT2_SEGOFI' )
declare @cCT2_DTCV3 Char( 'CT2_DTCV3' )
declare @cCT2_SEQIDX Char( 'CT2_SEQIDX' )
declare @cCT2_CONFST Char( 'CT2_CONFST' )
declare @cCT2_OBSCNF Char( 'CT2_OBSCNF' )
declare @cCT2_USRCNF Char( 'CT2_USRCNF' )
declare @cCT2_DTCONF Char( 'CT2_DTCONF' )
declare @cCT2_HRCONF Char( 'CT2_HRCONF' )
declare @cCT2_MLTSLD Char( 'CT2_MLTSLD' )
declare @cCT2_CTLSLD Char( 'CT2_CTLSLD' )
declare @cCTLSLDAux  Char( 'CT2_CTLSLD' )
declare @cCT2_CODPAR Char( 'CT2_CODPAR' )
declare @cCT2_NODIA Char( 'CT2_NODIA' )
declare @cCT2_DIACTB Char( 'CT2_DIACTB' )
declare @cCT2_CODCLI Char( 'CT2_CODCLI' )
declare @cCT2_CODFOR Char( 'CT2_CODFOR' )
declare @cCT2_AT01DB Char( 'CT2_AT01DB' )
declare @cCT2_AT01CR Char( 'CT2_AT01CR' )
declare @cCT2_AT02DB Char( 'CT2_AT02DB' )
declare @cCT2_AT02CR Char( 'CT2_AT02CR' )
declare @cCT2_AT03DB Char( 'CT2_AT03DB' )
declare @cCT2_AT03CR Char( 'CT2_AT03CR' )
declare @cCT2_AT04DB Char( 'CT2_AT04DB' )
declare @cCT2_AT04CR Char( 'CT2_AT04CR' )
declare @cCT2_MOEFDB Char( 'CT2_MOEFDB' )
declare @cCT2_MOEFCR Char( 'CT2_MOEFCR' )
declare @cCT2_LANCSU Char( 'CT2_LANCSU' )
declare @cCT2_GRPDIA Char( 'CT2_GRPDIA' )
declare @cCT2_LANC Char( 'CT2_LANC' )
declare @cCT2_CTRLSD Char( 'CT2_CTRLSD' )
##FIELDP01( 'CT2.CT2_EC05DB' )
declare @cCT2_EC05DB Char( 'CT2_EC05DB' )
declare @cCT2_EC05CR Char( 'CT2_EC05CR' )
##ENDFIELDP01
##FIELDP02( 'CT2.CT2_EC06DB' )
declare @cCT2_EC06DB Char( 'CT2_EC06DB' )
declare @cCT2_EC06CR Char( 'CT2_EC06CR' )
##ENDFIELDP02
##FIELDP03( 'CT2.CT2_EC07DB' )
declare @cCT2_EC07DB Char( 'CT2_EC07DB' )
declare @cCT2_EC07CR Char( 'CT2_EC07CR' )
##ENDFIELDP03
##FIELDP04( 'CT2.CT2_EC08DB' )
declare @cCT2_EC08DB Char( 'CT2_EC08DB' )
declare @cCT2_EC08CR Char( 'CT2_EC08CR' )
##ENDFIELDP04
##FIELDP05( 'CT2.CT2_EC09DB' )
declare @cCT2_EC09DB Char( 'CT2_EC09DB' )
declare @cCT2_EC09CR Char( 'CT2_EC09CR' )
##ENDFIELDP05
##FIELDP06( 'CT2.CT2_VLR06' )
declare @nCT2_VLR06 Float
##ENDFIELDP06
##FIELDP07( 'CT2.CT2_VLR07' )
declare @nCT2_VLR07 Float
##ENDFIELDP07
declare @cMltSldAux VarChar( 20 )
declare @cChar VarChar( 01 )
declare @iX Integer
declare @iRecnoCT2 Integer
declare @iRecnoAux Integer
declare @iRecno Integer
declare @iRecnoDel Integer
declare @cDc Char( 01 )
declare @cMoedaAnt Char( 002 )
declare @nValorAnt Float
declare @nCont Integer
declare @cTpSald Char( 001 )
declare @nTamHist Integer
declare @cLoteOld Char( 'CT2_LOTE' ) 
declare @cDataOld Char( 'CT2_DATA' )
declare @cDocOld Char( 'CT2_DOC' )
declare @cSbLtOld Char( 'CT2_SBLOTE' )
declare @cDocAux Char( 'CT2_DOC' )
declare @cLinhaAux Char( 'CT2_LINHA' )

BEGIN

   SELECT @cAux  = 'CT2' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CT2 output 

   --CTB301A - Deleta arquio via procedure
   IF @IN_TPAPAGA != '1' BEGIN
      EXEC CTB301A_## @cFil_CT2, @IN_DATAINI, @IN_DATAFIM, @IN_LCOPIA, @IN_TPSORIG, @IN_TPSDEST, @IN_LTDSMOEDA, @IN_MOEDA, @IN_SLDFILA, @IN_ATUSLD, @IN_TRANSACTION, @OUT_RESULTADO Output 
         
      --Se for moeda especifica e for diferente de 01, preciso apagar tambem o valor da 01, pois sera criado novamente pela procedure
      IF @IN_LTDSMOEDA = '0' AND @IN_MOEDA != '01' BEGIN
         EXEC CTB301A_## @cFil_CT2, @IN_DATAINI, @IN_DATAFIM, @IN_LCOPIA, @IN_TPSORIG, @IN_TPSDEST, @IN_LTDSMOEDA, '01', @IN_SLDFILA, @IN_ATUSLD, @IN_TRANSACTION, @OUT_RESULTADO Output 
      END
   END

   If @IN_TPAPAGA != '3' BEGIN
      SELECT @OUT_RESULTADO  = '0' 
      SELECT @nTamHist  = 40  
      SELECT @cAux  = 'CT8' 
      EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CT8 output 
      SELECT @iRecnoCT2  = 0 
      SELECT @cMoedaAnt  = '' 
      SELECT @nValorAnt  = 0 
      SELECT @cTpSald  = '' 
      SELECT @iRecnoDel  = 0 
      SELECT @cLoteOld = ' '
      SELECT @cDataOld = ' '
      SELECT @cDocOld  = ' '
      SELECT @cSbLtOld = ' '
      SELECT @cDocAux  = ' '
      -- Cursor declaration CUR_MOVTO
      DECLARE CUR_MOVTO insensitive  CURSOR FOR 
      SELECT CT2_FILIAL , CT2_DATA , CT2_LOTE , CT2_SBLOTE , CT2_DOC , CT2_LINHA , CT2_MOEDLC , CT2_DC , CT2_DEBITO , CT2_CREDIT , 
      CT2_DCD , CT2_DCC , CT2_VALOR , CT2_MOEDAS , CT2_HP , CT2_HIST , CT2_CCD , CT2_CCC , CT2_ITEMD , CT2_ITEMC , CT2_CLVLDB , 
      CT2_CLVLCR , CT2_ATIVDE , CT2_ATIVCR , CT2_EMPORI , CT2_FILORI , CT2_INTERC , CT2_IDENTC , CT2_TPSALD , CT2_SEQUEN , CT2_MANUAL , 
      CT2_ORIGEM , CT2_ROTINA , CT2_AGLUT , CT2_LP , CT2_SEQHIS , CT2_SEQLAN , CT2_DTVENC , CT2_SLBASE , CT2_DTLP , CT2_DATATX , 
      CT2_TAXA , CT2_VLR01 , CT2_VLR02 , CT2_VLR03 , CT2_VLR04 , CT2_VLR05 , CT2_CRCONV , CT2_CRITER , CT2_KEY , CT2_SEGOFI , 
      CT2_DTCV3 , CT2_SEQIDX , CT2_CONFST , CT2_OBSCNF , CT2_USRCNF , CT2_DTCONF , CT2_HRCONF , CT2_MLTSLD , CT2_CTLSLD , CT2_CODPAR , 
      CT2_NODIA , CT2_DIACTB , CT2_CODCLI , CT2_CODFOR , CT2_AT01DB , CT2_AT01CR , CT2_AT02DB , CT2_AT02CR , CT2_AT03DB , CT2_AT03CR , 
      CT2_AT04DB , CT2_AT04CR , CT2_MOEFDB , CT2_MOEFCR , CT2_LANCSU , CT2_GRPDIA , CT2_LANC , CT2_CTRLSD 
      ##FIELDP08( 'CT2.CT2_EC05DB' )
      ,CT2_EC05DB , CT2_EC05CR 
      ##ENDFIELDP08
      ##FIELDP09( 'CT2.CT2_EC06DB' )
      ,CT2_EC06DB , CT2_EC06CR
      ##ENDFIELDP09
      ##FIELDP10( 'CT2.CT2_EC07DB' )
      ,CT2_EC07DB , CT2_EC07CR 
      ##ENDFIELDP10
      ##FIELDP11( 'CT2.CT2_EC08DB' )
      ,CT2_EC08DB , CT2_EC08CR  
      ##ENDFIELDP11
      ##FIELDP12( 'CT2.CT2_EC09DB' )
      ,CT2_EC09DB , CT2_EC09CR 
      ##ENDFIELDP12
      ##FIELDP13( 'CT2.CT2_VLR06' )
      ,CT2_VLR06 
      ##ENDFIELDP13
      ##FIELDP14( 'CT2.CT2_VLR07' )
      ,CT2_VLR07
      ##ENDFIELDP14
      , R_E_C_N_O_
      FROM CT2### 
      WHERE CT2_FILIAL  = @cFil_CT2  and CT2_DATA  between @IN_DATAINI and @IN_DATAFIM  and  ( (CT2_TPSALD  = @IN_TPSORIG 
      and @IN_LTPSALD  = '1'  and CT2_MLTSLD  = ' ' )  or  (@IN_LTPSALD  = '0'  and CT2_MLTSLD  != ' ' ) )  and  ( (@IN_LTDSMOEDA  = '0' 
      and CT2_MOEDLC  = @IN_MOEDA )  or @IN_LTDSMOEDA  = '1' )  and  ( @IN_CLRCTLSLD = '1' or (@IN_CLRCTLSLD = '0' and CT2_CTLSLD  != '2' ))  
      and D_E_L_E_T_  = ' ' 
      FOR READ ONLY 
      
      OPEN CUR_MOVTO
      FETCH CUR_MOVTO 
      INTO @cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_LINHA , @cCT2_MOEDLC , @cCT2_DC , @cCT2_DEBITO , 
      @cCT2_CREDIT , @cCT2_DCD , @cCT2_DCC , @nCT2_VALOR , @cCT2_MOEDAS , @cCT2_HP , @cCT2_HIST , @cCT2_CCD , @cCT2_CCC , @cCT2_ITEMD , 
      @cCT2_ITEMC , @cCT2_CLVLDB , @cCT2_CLVLCR , @cCT2_ATIVDE , @cCT2_ATIVCR , @cCT2_EMPORI , @cCT2_FILORI , @cCT2_INTERC , 
      @cCT2_IDENTC , @cCT2_TPSALD , @cCT2_SEQUEN , @cCT2_MANUAL , @cCT2_ORIGEM , @cCT2_ROTINA , @cCT2_AGLUT , @cCT2_LP , @cCT2_SEQHIS , 
      @cCT2_SEQLAN , @cCT2_DTVENC , @cCT2_SLBASE , @cCT2_DTLP , @cCT2_DATATX , @nCT2_TAXA , @nCT2_VLR01 , @nCT2_VLR02 , @nCT2_VLR03 , 
      @nCT2_VLR04 , @nCT2_VLR05 , @cCT2_CRCONV , @cCT2_CRITER , @cCT2_KEY , @cCT2_SEGOFI , @cCT2_DTCV3 , @cCT2_SEQIDX , @cCT2_CONFST , 
      @cCT2_OBSCNF , @cCT2_USRCNF , @cCT2_DTCONF , @cCT2_HRCONF , @cCT2_MLTSLD , @cCT2_CTLSLD , @cCT2_CODPAR , @cCT2_NODIA , 
      @cCT2_DIACTB , @cCT2_CODCLI , @cCT2_CODFOR , @cCT2_AT01DB , @cCT2_AT01CR , @cCT2_AT02DB , @cCT2_AT02CR , @cCT2_AT03DB , 
      @cCT2_AT03CR , @cCT2_AT04DB , @cCT2_AT04CR , @cCT2_MOEFDB , @cCT2_MOEFCR , @cCT2_LANCSU , 
      @cCT2_GRPDIA , @cCT2_LANC , @cCT2_CTRLSD 
      ##FIELDP15( 'CT2.CT2_EC05DB' )
      ,@cCT2_EC05DB , @cCT2_EC05CR
      ##ENDFIELDP15
      ##FIELDP16( 'CT2.CT2_EC06DB' )
      ,@cCT2_EC06DB , @cCT2_EC06CR
      ##ENDFIELDP16
      ##FIELDP17( 'CT2.CT2_EC07DB' )
      ,@cCT2_EC07DB , @cCT2_EC07CR
      ##ENDFIELDP17
      ##FIELDP18( 'CT2.CT2_EC08DB' )
      ,@cCT2_EC08DB , @cCT2_EC08CR
      ##ENDFIELDP18
      ##FIELDP19( 'CT2.CT2_EC09DB' )
      ,@cCT2_EC09DB , @cCT2_EC09CR
      ##ENDFIELDP19
      ##FIELDP20( 'CT2.CT2_VLR06' )
      ,@nCT2_VLR06
      ##ENDFIELDP20
      ##FIELDP21( 'CT2.CT2_VLR07' )
      ,@nCT2_VLR07
      ##ENDFIELDP21
      ,@iRecno 
      WHILE (@@fetch_status  = 0 )
      BEGIN
         IF @IN_LHIST  = 2 
         BEGIN 
            SELECT @cCT2_HIST  = SUBSTRING ( CT8_DESC , 1 , @nTamHist )
            FROM CT8### 
            WHERE CT8_FILIAL  = @cFil_CT8  and CT8_HIST  = @IN_CODHIST  and D_E_L_E_T_  = ' ' 
         END 
         SELECT @cMltSldAux  = '' 
         IF @IN_LCOPIA  = 2 
         BEGIN 
            SELECT @iX  = 1 
            WHILE (@iX  <= LEN ( @cCT2_MLTSLD ))
            BEGIN
               SELECT @cChar  = '' 
               SELECT @cChar  = SUBSTRING ( @cCT2_MLTSLD , @iX , 1 )
               IF @cChar  = @cCT2_TPSALD 
               BEGIN 
                  SELECT @cChar  = '' 
               END 
               SELECT @cMltSldAux  = @cMltSldAux  + @cChar 
               SELECT @iX  = @iX  + 1 
            END 
         END 
         ELSE 
         BEGIN 
            IF  (@IN_CLRCTLSLD  = '1' or @cCT2_CTLSLD  != '2' )  and @cCT2_MLTSLD  = ' ' 
            BEGIN 
               SELECT @cMltSldAux  = @IN_TPSDEST 
            END 
         END 
         IF @IN_LLOTE  = 2 
         BEGIN        
            SELECT @cCT2_LOTE  = @IN_LOTE 
            SELECT @cCT2_SBLOTE  = @IN_SBLOTE        
         END 

         IF @cDataOld||@cLoteOld||@cSbLtOld||@cDocOld <> @cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_DOC
         BEGIN
            SELECT @cDataOld = @cCT2_DATA	
            SELECT @cLoteOld = @cCT2_LOTE
            SELECT @cSbLtOld = @cCT2_SBLOTE		
            SELECT @cDocOld  = @cCT2_DOC
            SELECT @cLinhaAux = ' '

            SELECT @cDocAux = COALESCE(MAX(CT2_DOC),'000001') FROM CT2### WHERE CT2_FILIAL  = @cCT2_FILIAL  and CT2_DATA  = @cCT2_DATA  and CT2_LOTE  = @cCT2_LOTE  and CT2_SBLOTE  = @cCT2_SBLOTE and D_E_L_E_T_  = ' ' 
            EXEC MSSOMA1 @cDocAux , '1' ,  @cDocAux output 
         END

         SELECT @cCT2_DOC = @cDocAux
         
         SELECT @iX  = 1 
         SELECT @iRecnoCT2  = 0

         SELECT @cChar  = SUBSTRING ( @cMltSldAux , @iX , 1 )
         WHILE (@iX  <= LEN ( @cMltSldAux ) and @cChar  != '#' )
         BEGIN
         
            if @cLinhaAux = ' ' begin
               SELECT  @cLinhaAux = @cCT2_LINHA
            end else begin
               EXEC MSSOMA1 @cLinhaAux, '1', @cLinhaAux output
            end

            IF @cChar  != @cCT2_TPSALD 
            BEGIN 
               SELECT @cCTLSLDAux  = '2' 
               SELECT @cTpSald  = @cChar    

               --uniquekey
               ##UNIQUEKEY_START
               SELECT @iRecnoCT2 = COALESCE(Min(R_E_C_N_O_), 0)
               FROM CT2###
               WHERE CT2_FILIAL = @cCT2_FILIAL
               AND CT2_DATA = @cCT2_DATA
               AND CT2_LOTE = @cCT2_LOTE
               AND CT2_SBLOTE = @cCT2_SBLOTE
               AND CT2_DOC = @cCT2_DOC
               AND CT2_LINHA = @cLinhaAux
               AND CT2_EMPORI = @cCT2_EMPORI
               AND CT2_FILORI = @cCT2_FILORI
               AND CT2_MOEDLC = @cCT2_MOEDLC
               AND CT2_SEQIDX = @cCT2_SEQIDX
               AND D_E_L_E_T_ = ' ' 
               ##UNIQUEKEY_END
               
               IF @iRecnoCT2 = 0
               BEGIN                   
                  SELECT @iRecnoCT2  = COALESCE(MAX( R_E_C_N_O_ ), 0 )
                  FROM CT2### 
                  SELECT @iRecnoCT2  = @iRecnoCT2  + 1 
                  --tratarecno
                  ##TRATARECNO @iRecnoCT2\
                  ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                  INSERT INTO CT2### (CT2_FILIAL , CT2_DATA , CT2_LOTE , CT2_SBLOTE , CT2_DOC , CT2_LINHA , CT2_MOEDLC , CT2_DC , 
                  CT2_DEBITO , CT2_CREDIT , CT2_DCD , CT2_DCC , CT2_VALOR , CT2_MOEDAS , CT2_HP , CT2_HIST , CT2_CCD , CT2_CCC , 
                  CT2_ITEMD , CT2_ITEMC , CT2_CLVLDB , CT2_CLVLCR , CT2_ATIVDE , CT2_ATIVCR , CT2_EMPORI , CT2_FILORI , CT2_INTERC , 
                  CT2_IDENTC , CT2_TPSALD , CT2_SEQUEN , CT2_MANUAL , CT2_ORIGEM , CT2_ROTINA , CT2_AGLUT , CT2_LP , CT2_SEQHIS , 
                  CT2_SEQLAN , CT2_DTVENC , CT2_SLBASE , CT2_DTLP , CT2_DATATX , CT2_TAXA , CT2_VLR01 , CT2_VLR02 , CT2_VLR03 , 
                  CT2_VLR04 , CT2_VLR05 , CT2_CRCONV , CT2_CRITER , CT2_KEY , CT2_SEGOFI , CT2_DTCV3 , CT2_SEQIDX , CT2_CONFST , 
                  CT2_OBSCNF , CT2_USRCNF , CT2_DTCONF , CT2_HRCONF , CT2_MLTSLD , CT2_CTLSLD , CT2_CODPAR , CT2_NODIA , CT2_DIACTB , 
                  CT2_CODCLI , CT2_CODFOR , CT2_AT01DB , CT2_AT01CR , CT2_AT02DB , CT2_AT02CR , CT2_AT03DB , CT2_AT03CR , CT2_AT04DB , 
                  CT2_AT04CR , CT2_MOEFDB , CT2_MOEFCR , CT2_LANCSU , CT2_GRPDIA , CT2_LANC , CT2_CTRLSD
                  ##FIELDP22( 'CT2.CT2_EC05DB' )
                  ,CT2_EC05DB , CT2_EC05CR 
                  ##ENDFIELDP22
                  ##FIELDP23( 'CT2.CT2_EC06DB' )
                  ,CT2_EC06DB , CT2_EC06CR
                  ##ENDFIELDP23
                  ##FIELDP24( 'CT2.CT2_EC07DB' )
                  ,CT2_EC07DB , CT2_EC07CR 
                  ##ENDFIELDP24
                  ##FIELDP25( 'CT2.CT2_EC08DB' )
                  ,CT2_EC08DB , CT2_EC08CR  
                  ##ENDFIELDP25
                  ##FIELDP26( 'CT2.CT2_EC09DB' )
                  ,CT2_EC09DB , CT2_EC09CR 
                  ##ENDFIELDP26
                  ##FIELDP27( 'CT2.CT2_VLR06' )
                  ,CT2_VLR06 
                  ##ENDFIELDP27
                  ##FIELDP28( 'CT2.CT2_VLR07' )
                  ,CT2_VLR07
                  ##ENDFIELDP28
                  ,R_E_C_N_O_ ) 
                  VALUES (@cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cLinhaAux , @cCT2_MOEDLC , @cCT2_DC , 
                  @cCT2_DEBITO , @cCT2_CREDIT , @cCT2_DCD , @cCT2_DCC , 0 , @cCT2_MOEDAS , @cCT2_HP , @cCT2_HIST , @cCT2_CCD , 
                  @cCT2_CCC , @cCT2_ITEMD , @cCT2_ITEMC , @cCT2_CLVLDB , @cCT2_CLVLCR , @cCT2_ATIVDE , @cCT2_ATIVCR , @cCT2_EMPORI , 
                  @cCT2_FILORI , @cCT2_INTERC , @cCT2_IDENTC , @cTpSald , @cCT2_SEQUEN , @cCT2_MANUAL , @cCT2_ORIGEM , @cCT2_ROTINA , 
                  @cCT2_AGLUT , @cCT2_LP , @cCT2_SEQHIS , @cCT2_SEQLAN , @cCT2_DTVENC , @cCT2_SLBASE , @cCT2_DTLP , @cCT2_DATATX , 
                  0 , 0 , 0 , 0 , 0 , 0 , @cCT2_CRCONV , @cCT2_CRITER , 
                  @cCT2_KEY , @cCT2_SEGOFI , @cCT2_DTCV3 , @cCT2_SEQIDX , @cCT2_CONFST , @cCT2_OBSCNF , @cCT2_USRCNF , @cCT2_DTCONF , 
                  @cCT2_HRCONF , @cCT2_MLTSLD , @cCTLSLDAux , @cCT2_CODPAR , @cCT2_NODIA , @cCT2_DIACTB , @cCT2_CODCLI , @cCT2_CODFOR , 
                  @cCT2_AT01DB , @cCT2_AT01CR , @cCT2_AT02DB , @cCT2_AT02CR , @cCT2_AT03DB , @cCT2_AT03CR , @cCT2_AT04DB , @cCT2_AT04CR , 
                  @cCT2_MOEFDB , @cCT2_MOEFCR , @cCT2_LANCSU , @cCT2_GRPDIA , @cCT2_LANC , @cCT2_CTRLSD
                  ##FIELDP29( 'CT2.CT2_EC05DB' )
                  ,@cCT2_EC05DB , @cCT2_EC05CR
                  ##ENDFIELDP29
                  ##FIELDP30( 'CT2.CT2_EC06DB' )
                  ,@cCT2_EC06DB , @cCT2_EC06CR
                  ##ENDFIELDP30
                  ##FIELDP31( 'CT2.CT2_EC07DB' )
                  ,@cCT2_EC07DB , @cCT2_EC07CR
                  ##ENDFIELDP31
                  ##FIELDP32( 'CT2.CT2_EC08DB' )
                  ,@cCT2_EC08DB , @cCT2_EC08CR
                  ##ENDFIELDP32
                  ##FIELDP33( 'CT2.CT2_EC09DB' )
                  ,@cCT2_EC09DB , @cCT2_EC09CR
                  ##ENDFIELDP33
                  ##FIELDP34( 'CT2.CT2_VLR06' )
                  ,0
                  ##ENDFIELDP34
                  ##FIELDP35( 'CT2.CT2_VLR07' )
                  ,0
                  ##ENDFIELDP35  
                  ,@iRecnoCT2 )
                  ##CHECK_TRANSACTION_COMMIT
                  ##FIMTRATARECNO
               END
               --update
               ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                  UPDATE CT2###
                  SET CT2_VALOR = CT2_VALOR + @nCT2_VALOR
                     ,CT2_TAXA = CT2_TAXA + @nCT2_TAXA
                     ,CT2_VLR01 = CT2_VLR01 + @nCT2_VLR01
                     ,CT2_VLR02 = CT2_VLR02 + @nCT2_VLR02
                     ,CT2_VLR03 = CT2_VLR03 + @nCT2_VLR03
                     ,CT2_VLR04 = CT2_VLR04 + @nCT2_VLR04
                     ,CT2_VLR05 = CT2_VLR05 + @nCT2_VLR05 
                     ##FIELDP36( 'CT2.CT2_VLR06' )
                     ,CT2_VLR06 = CT2_VLR06 + @nCT2_VLR06 
                     ##ENDFIELDP36 
                     ##FIELDP37( 'CT2.CT2_VLR07' )
                     ,CT2_VLR07 = CT2_VLR07 + @nCT2_VLR07 
                     ##ENDFIELDP37
                  WHERE R_E_C_N_O_ = @iRecnoCT2
               ##CHECK_TRANSACTION_COMMIT

               --CTB301B - Inclui o novo registro na Fila
               IF @IN_ATUSLD = '1' AND @IN_SLDFILA = '1' BEGIN
                  EXEC CTB301B_##  @cCT2_FILIAL, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cLinhaAux, @cCT2_MOEDLC, @cCT2_EMPORI, @cCT2_FILORI, @cTpSald, @IN_TRANSACTION, @OUT_RESULTADO Output 
               END 

               --Se for moeda especifica diferente de 01, preciso incluir tambem a linha da 01
               IF @IN_LTDSMOEDA  = '0'  and @cCT2_MOEDLC  != '01' 
               BEGIN 

                  SELECT @cMoedaAnt  = @cCT2_MOEDLC 
                  SELECT @nValorAnt  = @nCT2_VALOR 
                  SELECT @cCT2_MOEDLC = '01' 
                  SELECT @nCT2_VALOR  = 0 
                  --uniquekey
                  ##UNIQUEKEY_START
                  SELECT @iRecnoCT2 = COALESCE(Min(R_E_C_N_O_), 0)
                  FROM CT2###
                  WHERE CT2_FILIAL = @cCT2_FILIAL
                  AND CT2_DATA = @cCT2_DATA
                  AND CT2_LOTE = @cCT2_LOTE
                  AND CT2_SBLOTE = @cCT2_SBLOTE
                  AND CT2_DOC = @cCT2_DOC
                  AND CT2_LINHA = @cLinhaAux
                  AND CT2_EMPORI = @cCT2_EMPORI
                  AND CT2_FILORI = @cCT2_FILORI
                  AND CT2_MOEDLC = @cCT2_MOEDLC
                  AND CT2_SEQIDX = @cCT2_SEQIDX
                  AND D_E_L_E_T_ = ' ' 
                  ##UNIQUEKEY_END

                  IF @iRecnoCT2 = 0
                  BEGIN
                     SELECT @iRecnoCT2  = COALESCE(MAX( R_E_C_N_O_ ), 0 )
                     FROM CT2### 
                     SELECT @iRecnoCT2  = @iRecnoCT2  + 1 
                     --tratarecno
                     ##TRATARECNO @iRecnoCT2\
                     ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                     INSERT INTO CT2### (CT2_FILIAL , CT2_DATA , CT2_LOTE , CT2_SBLOTE , CT2_DOC , CT2_LINHA , CT2_MOEDLC , CT2_DC , 
                     CT2_DEBITO , CT2_CREDIT , CT2_DCD , CT2_DCC , CT2_VALOR , CT2_MOEDAS , CT2_HP , CT2_HIST , CT2_CCD , CT2_CCC , 
                     CT2_ITEMD , CT2_ITEMC , CT2_CLVLDB , CT2_CLVLCR , CT2_ATIVDE , CT2_ATIVCR , CT2_EMPORI , CT2_FILORI , CT2_INTERC , 
                     CT2_IDENTC , CT2_TPSALD , CT2_SEQUEN , CT2_MANUAL , CT2_ORIGEM , CT2_ROTINA , CT2_AGLUT , CT2_LP , CT2_SEQHIS , 
                     CT2_SEQLAN , CT2_DTVENC , CT2_SLBASE , CT2_DTLP , CT2_DATATX , CT2_TAXA , CT2_VLR01 , CT2_VLR02 , CT2_VLR03 , 
                     CT2_VLR04 , CT2_VLR05 , CT2_CRCONV , CT2_CRITER , CT2_KEY , CT2_SEGOFI , CT2_DTCV3 , CT2_SEQIDX , CT2_CONFST , 
                     CT2_OBSCNF , CT2_USRCNF , CT2_DTCONF , CT2_HRCONF , CT2_MLTSLD , CT2_CTLSLD , CT2_CODPAR , CT2_NODIA , CT2_DIACTB , 
                     CT2_CODCLI , CT2_CODFOR , CT2_AT01DB , CT2_AT01CR , CT2_AT02DB , CT2_AT02CR , CT2_AT03DB , CT2_AT03CR , CT2_AT04DB , 
                     CT2_AT04CR , CT2_MOEFDB , CT2_MOEFCR , CT2_LANCSU , CT2_GRPDIA , CT2_LANC , CT2_CTRLSD 
                     ##FIELDP38( 'CT2.CT2_EC05DB' )
                     ,CT2_EC05DB , CT2_EC05CR 
                     ##ENDFIELDP38
                     ##FIELDP39( 'CT2.CT2_EC06DB' )
                     ,CT2_EC06DB , CT2_EC06CR
                     ##ENDFIELDP39
                     ##FIELDP40( 'CT2.CT2_EC07DB' )
                     ,CT2_EC07DB , CT2_EC07CR 
                     ##ENDFIELDP40
                     ##FIELDP41( 'CT2.CT2_EC08DB' )
                     ,CT2_EC08DB , CT2_EC08CR  
                     ##ENDFIELDP41
                     ##FIELDP42( 'CT2.CT2_EC09DB' )
                     ,CT2_EC09DB , CT2_EC09CR 
                     ##ENDFIELDP42
                     ##FIELDP43( 'CT2.CT2_VLR06' )
                     ,CT2_VLR06 
                     ##ENDFIELDP43
                     ##FIELDP44( 'CT2.CT2_VLR07' )
                     ,CT2_VLR07
                     ##ENDFIELDP44
                     ,R_E_C_N_O_) 
                     VALUES (@cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cLinhaAux , @cCT2_MOEDLC , @cCT2_DC , 
                     @cCT2_DEBITO , @cCT2_CREDIT , @cCT2_DCD , @cCT2_DCC , 0 , @cCT2_MOEDAS , @cCT2_HP , @cCT2_HIST , 
                     @cCT2_CCD , @cCT2_CCC , @cCT2_ITEMD , @cCT2_ITEMC , @cCT2_CLVLDB , @cCT2_CLVLCR , @cCT2_ATIVDE , @cCT2_ATIVCR , 
                     @cCT2_EMPORI , @cCT2_FILORI , @cCT2_INTERC , @cCT2_IDENTC , @cTpSald , @cCT2_SEQUEN , @cCT2_MANUAL , @cCT2_ORIGEM , 
                     @cCT2_ROTINA , @cCT2_AGLUT , @cCT2_LP , @cCT2_SEQHIS , @cCT2_SEQLAN , @cCT2_DTVENC , @cCT2_SLBASE , @cCT2_DTLP , 
                     @cCT2_DATATX , 0, 0 , 0 , 0 , 0 , 0 , @cCT2_CRCONV , 
                     @cCT2_CRITER , @cCT2_KEY , @cCT2_SEGOFI , @cCT2_DTCV3 , @cCT2_SEQIDX , @cCT2_CONFST , @cCT2_OBSCNF , @cCT2_USRCNF , 
                     @cCT2_DTCONF , @cCT2_HRCONF , @cCT2_MLTSLD , @cCTLSLDAux , @cCT2_CODPAR , @cCT2_NODIA , @cCT2_DIACTB , @cCT2_CODCLI , 
                     @cCT2_CODFOR , @cCT2_AT01DB , @cCT2_AT01CR , @cCT2_AT02DB , @cCT2_AT02CR , @cCT2_AT03DB , @cCT2_AT03CR , @cCT2_AT04DB , 
                     @cCT2_AT04CR , @cCT2_MOEFDB , @cCT2_MOEFCR , @cCT2_LANCSU , @cCT2_GRPDIA , @cCT2_LANC , 
                     @cCT2_CTRLSD 
                     ##FIELDP45( 'CT2.CT2_EC05DB' )
                     ,@cCT2_EC05DB , @cCT2_EC05CR
                     ##ENDFIELDP45
                     ##FIELDP46( 'CT2.CT2_EC06DB' )
                     ,@cCT2_EC06DB , @cCT2_EC06CR
                     ##ENDFIELDP46
                     ##FIELDP47( 'CT2.CT2_EC07DB' )
                     ,@cCT2_EC07DB , @cCT2_EC07CR
                     ##ENDFIELDP47
                     ##FIELDP48( 'CT2.CT2_EC08DB' )
                     ,@cCT2_EC08DB , @cCT2_EC08CR
                     ##ENDFIELDP48
                     ##FIELDP49( 'CT2.CT2_EC09DB' )
                     ,@cCT2_EC09DB , @cCT2_EC09CR
                     ##ENDFIELDP49
                     ##FIELDP50( 'CT2.CT2_VLR06' )
                     ,0
                     ##ENDFIELDP50
                     ##FIELDP51( 'CT2.CT2_VLR07' )
                     ,0
                     ##ENDFIELDP51
                     ,@iRecnoCT2 )
                     ##CHECK_TRANSACTION_COMMIT
                     ##FIMTRATARECNO
                  END      
                  --update
                  ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                  UPDATE CT2###
                  SET CT2_VALOR = CT2_VALOR + @nCT2_VALOR
                  ,CT2_TAXA = CT2_TAXA + @nCT2_TAXA
                  ,CT2_VLR01 = CT2_VLR01 + @nCT2_VLR01
                  ,CT2_VLR02 = CT2_VLR02 + @nCT2_VLR02
                  ,CT2_VLR03 = CT2_VLR03 + @nCT2_VLR03
                  ,CT2_VLR04 = CT2_VLR04 + @nCT2_VLR04
                  ,CT2_VLR05 = CT2_VLR05 + @nCT2_VLR05 
                  ##FIELDP52( 'CT2.CT2_VLR06' )
                  ,CT2_VLR06 = CT2_VLR06 + @nCT2_VLR06 
                  ##ENDFIELDP52 
                  ##FIELDP53( 'CT2.CT2_VLR07' )
                  ,CT2_VLR07 = CT2_VLR07 + @nCT2_VLR07 
                  ##ENDFIELDP53
                  WHERE R_E_C_N_O_ = @iRecnoCT2
                  ##CHECK_TRANSACTION_COMMIT

                  --CTB301B - Inclui o novo registro na Fila
                  IF @IN_ATUSLD = '1' AND @IN_SLDFILA = '1' BEGIN
                     EXEC CTB301B_##  @cCT2_FILIAL, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cLinhaAux, @cCT2_MOEDLC, @cCT2_EMPORI, @cCT2_FILORI, @cTpSald, @IN_TRANSACTION, @OUT_RESULTADO Output 
                  END 

                  SELECT @cCT2_MOEDLC  = @cMoedaAnt 
                  SELECT @nCT2_VALOR  = ROUND ( @nValorAnt , 2 )
               END 
            END   
            SELECT @iX  = @iX  + 1 
            SELECT @cChar  = SUBSTRING ( @cMltSldAux , @iX , 1 )
         END 

         IF @cCT2_CTLSLD != '2'
         BEGIN
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            UPDATE CT2### 
               SET CT2_CTLSLD  = '2' 
            WHERE R_E_C_N_O_  = @iRecno 
            ##CHECK_TRANSACTION_COMMIT
         END

         FETCH CUR_MOVTO 
         INTO @cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_LINHA , @cCT2_MOEDLC , @cCT2_DC , @cCT2_DEBITO , 
         @cCT2_CREDIT , @cCT2_DCD , @cCT2_DCC , @nCT2_VALOR , @cCT2_MOEDAS , @cCT2_HP , @cCT2_HIST , @cCT2_CCD , @cCT2_CCC , 
         @cCT2_ITEMD , @cCT2_ITEMC , @cCT2_CLVLDB , @cCT2_CLVLCR , @cCT2_ATIVDE , @cCT2_ATIVCR , @cCT2_EMPORI , @cCT2_FILORI , 
         @cCT2_INTERC , @cCT2_IDENTC , @cTpSald , @cCT2_SEQUEN , @cCT2_MANUAL , @cCT2_ORIGEM , @cCT2_ROTINA , @cCT2_AGLUT , 
         @cCT2_LP , @cCT2_SEQHIS , @cCT2_SEQLAN , @cCT2_DTVENC , @cCT2_SLBASE , @cCT2_DTLP , @cCT2_DATATX , @nCT2_TAXA , @nCT2_VLR01 , 
         @nCT2_VLR02 , @nCT2_VLR03 , @nCT2_VLR04 , @nCT2_VLR05 , @cCT2_CRCONV , @cCT2_CRITER , @cCT2_KEY , @cCT2_SEGOFI , @cCT2_DTCV3 , 
         @cCT2_SEQIDX , @cCT2_CONFST , @cCT2_OBSCNF , @cCT2_USRCNF , @cCT2_DTCONF , @cCT2_HRCONF , @cCT2_MLTSLD , @cCT2_CTLSLD , 
         @cCT2_CODPAR , @cCT2_NODIA , @cCT2_DIACTB , @cCT2_CODCLI , @cCT2_CODFOR , @cCT2_AT01DB , @cCT2_AT01CR , @cCT2_AT02DB , 
         @cCT2_AT02CR , @cCT2_AT03DB , @cCT2_AT03CR , @cCT2_AT04DB , @cCT2_AT04CR , @cCT2_MOEFDB , @cCT2_MOEFCR , 
         @cCT2_LANCSU , @cCT2_GRPDIA , @cCT2_LANC , @cCT2_CTRLSD 
         ##FIELDP54( 'CT2.CT2_EC05DB' )
         ,@cCT2_EC05DB , @cCT2_EC05CR
         ##ENDFIELDP54
         ##FIELDP55( 'CT2.CT2_EC06DB' )
         ,@cCT2_EC06DB , @cCT2_EC06CR
         ##ENDFIELDP55
         ##FIELDP56( 'CT2.CT2_EC07DB' )
         ,@cCT2_EC07DB , @cCT2_EC07CR
         ##ENDFIELDP56
         ##FIELDP57( 'CT2.CT2_EC08DB' )
         ,@cCT2_EC08DB , @cCT2_EC08CR
         ##ENDFIELDP57
         ##FIELDP58( 'CT2.CT2_EC09DB' )
         ,@cCT2_EC09DB , @cCT2_EC09CR
         ##ENDFIELDP58
         ##FIELDP59( 'CT2.CT2_VLR06' )
         ,@nCT2_VLR06
         ##ENDFIELDP59
         ##FIELDP60( 'CT2.CT2_VLR07' )
         ,@nCT2_VLR07
         ##ENDFIELDP60
         ,@iRecno 
      END 
      CLOSE CUR_MOVTO
      DEALLOCATE CUR_MOVTO
   END
   SELECT @OUT_RESULTADO  = '1' 
END 

