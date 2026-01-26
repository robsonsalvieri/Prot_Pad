##IF_999({|| AliasInDic('QLJ') })
Create procedure CTB965_## ( 
   @IN_FILIAL       Char('CT2_FILIAL'),
   @IN_LCUSTO       Char(01),
   @IN_LITEM        Char(01),
   @IN_LCLVL        Char(01),   
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
declare @cFilCT2    Char('CT2_FILIAL')
declare @cFilCT0    Char('CT0_FILIAL')
declare @cFilCQA    Char('CQA_FILIAL')
declare @cDATA      Char('QLJ_DATA')
declare @cCONTA     Char('QLJ_CONTA')
declare @cCUSTO     Char('QLJ_CUSTO')
declare @cITEM      Char('QLJ_ITEM')
declare @cCLVL      Char('QLJ_CLVL')
declare @cMOEDA     Char('QLJ_MOEDA')
declare @cTPSald    Char('QLJ_TPSALD')
declare @cEC05		Char('QLJ_ENT05')
declare @cEC06		Char('QLJ_ENT06')
declare @cEC07		Char('QLJ_ENT07')
declare @cEC08		Char('QLJ_ENT08')
declare @cEC09		Char('QLJ_ENT09')
declare @cConfig    Char('CVX_CONFIG')
declare @fim_CUR    Integer
declare @iRecno		Integer
declare @nMovDeb	Float
declare @nSldDeb	Float
declare @nMovCred	Float
declare @nSldCred	Float

begin
    
    select @OUT_RESULTADO = '0'
    
    If @IN_FILIAL = ' ' select @cFilAux = ' '
    else select @cFilAux = @IN_FILIAL
    
	exec XFILIAL_## 'CT0', @cFilAux, @cFilCT0 OutPut
    exec XFILIAL_## 'CT2', @cFilAux, @cFilial OutPut
	exec XFILIAL_## 'QLJ', @cFilAux, @cFilQLJ OutPut
	exec XFILIAL_## 'CQA', @cFilAux, @cFilCQA OutPut
	
	 /* Deleta Saldos sem movimento (CQ's sem CT2)*/
	exec CTB965A_## @cFilial, @IN_DATADE, @IN_DATAATE, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_UUID, @IN_LMULTIFIL, @IN_TRANSACTION, @OUT_RESULTADO OutPut  
	
	/* Corrige Saldos de documentos (CTC)*/
	exec CTB965E_## @cFilial, @IN_DATADE, @IN_DATAATE, @IN_LMOEDAESP, @IN_MOEDA, @IN_UUID, @IN_LMULTIFIL, @IN_TRANSACTION, @OUT_RESULTADO OutPut  

	/* Deleta Saldos sem movimento (CVX e CVY sem CT2) antes de checar o movimento*/
	##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. ) .And. AliasInDic("CVX")})
	##FIELDP01( 'CT0.CT0_ID' )
		exec CTB965C_## @cFilCT0, @IN_DATADE, @IN_DATAATE, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_UUID, @IN_LMULTIFIL, @IN_TRANSACTION, @OUT_RESULTADO OutPut
	##ENDFIELDP01
	##ENDIF_001

	/*--------------------------------------------------
		Compara CQ1
	---------------------------------------------------*/    
    Declare CUR_CTBCQ1 insensitive cursor for
	SELECT 
		CT2_FILIAL, CT2_DATA, CONTA, CUSTO, ITEM, CLVL, EC05, EC06, EC07, EC08, EC09, MOVDEB, SLDDEB, MOVCRED, SLDCRED, CT2_MOEDLC, CT2_TPSALD 		 
		FROM ( SELECT 	
				CT2_FILIAL, CT2_DATA, CONTA, CUSTO, ITEM, CLVL, EC05, EC06, EC07, EC08, EC09, SUM(MOVDEB) MOVDEB, SLDDEB, SUM(MOVCRED) MOVCRED, SLDCRED, CT2_MOEDLC, CT2_TPSALD 
				FROM ( SELECT 
						CT2_FILIAL, CT2_TPSALD, CT2_MOEDLC,			
						CT2_DATA, CT2_DEBITO CONTA, ' ' CUSTO, ' ' ITEM, ' ' CLVL, 
						' ' EC05, ' ' EC06, ' ' EC07, ' ' EC08, ' ' EC09,
						CT2_VALOR MOVDEB, ISNULL(CQ1_DEBITO,0) SLDDEB, 0 MOVCRED, 0 SLDCRED                          
						FROM 
							CT2### CT2  
							LEFT JOIN 
								CQA### CQA 
								ON 
									CQA.CQA_FILIAL = @cFilCQA AND
									CQA.CQA_FILCT2 = CT2.CT2_FILIAL AND 
									CQA.CQA_DATA = CT2.CT2_DATA AND 
									CQA.CQA_LOTE = CT2.CT2_LOTE AND 
									CQA.CQA_SBLOTE = CT2.CT2_SBLOTE AND 
									CQA.CQA_DOC = CT2.CT2_DOC AND 
									CQA.CQA_LINHA = CT2.CT2_LINHA AND 
									CQA.CQA_EMPORI = CT2.CT2_EMPORI AND 
									CQA.CQA_MOEDLC = CT2.CT2_MOEDLC AND
									CQA.D_E_L_E_T_ = ' '                           
							LEFT JOIN 
								CQ1### CQ1                              
								ON 
									CQ1_FILIAL = CT2_FILIAL AND                                  
									CQ1_CONTA  = CT2_DEBITO AND                                  
									CQ1_DATA   = CT2_DATA AND                                  
									CQ1_MOEDA  = CT2_MOEDLC AND                                  
									CQ1_TPSALD = CT2_TPSALD AND 
									((CQ1_LP = 'Z' AND CT2_DTLP <> ' ') OR (CQ1_LP <> 'Z' AND CT2_DTLP = ' ')) AND                                 
									CQ1.D_E_L_E_T_ = ' '                          
							WHERE 
								((@IN_LMULTIFIL = '0' AND CT2_FILIAL = @cFilial) OR (CT2_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                   
								CT2_DATA BETWEEN @IN_DATADE AND @IN_DATAATE AND
								((CT2_MOEDLC = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND                                  
								((@IN_TPSALDO = '*' AND CT2_TPSALD <> '9') OR CT2_TPSALD = @IN_TPSALDO) AND
								CT2_DC IN('1','3') AND                               
								CT2.D_E_L_E_T_ = ' ' AND
								CQA.CQA_DATA IS NULL
					UNION ALL
					SELECT 
						CT2_FILIAL, CT2_TPSALD, CT2_MOEDLC,
						CT2_DATA, CT2_CREDIT CONTA, ' ' CUSTO, ' ' ITEM, ' ' CLVL, 
						' ' EC05, ' ' EC06, ' ' EC07, ' ' EC08, ' ' EC09,
						0 MOVDEB, 0 SLDDEB, CT2_VALOR MOVCRED,  ISNULL(CQ1_CREDIT,0) SLDCRED                          
						FROM 
							CT2### CT2 
							LEFT JOIN 
								CQA### CQA 
								ON 
									CQA.CQA_FILIAL = @cFilCQA AND
									CQA.CQA_FILCT2 = CT2.CT2_FILIAL AND 
									CQA.CQA_DATA = CT2.CT2_DATA AND 
									CQA.CQA_LOTE = CT2.CT2_LOTE AND 
									CQA.CQA_SBLOTE = CT2.CT2_SBLOTE AND 
									CQA.CQA_DOC = CT2.CT2_DOC AND 
									CQA.CQA_LINHA = CT2.CT2_LINHA AND 
									CQA.CQA_EMPORI = CT2.CT2_EMPORI AND 
									CQA.CQA_MOEDLC = CT2.CT2_MOEDLC AND
									CQA.D_E_L_E_T_ = ' '                             
							LEFT JOIN 
								CQ1### CQ1                                  
								ON 
									CQ1_FILIAL = CT2_FILIAL AND                                      
									CQ1_CONTA  = CT2_CREDIT AND                                      
									CQ1_DATA   = CT2_DATA AND                                      
									CQ1_MOEDA  = CT2_MOEDLC AND                                      
									CQ1_TPSALD = CT2_TPSALD AND
									((CQ1_LP = 'Z' AND CT2_DTLP <> ' ') OR (CQ1_LP <> 'Z' AND CT2_DTLP = ' ')) AND                                      
									CQ1.D_E_L_E_T_ = ' '                          
							WHERE 
								((@IN_LMULTIFIL = '0' AND CT2_FILIAL = @cFilial) OR (CT2_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                   
								CT2_DATA BETWEEN @IN_DATADE AND @IN_DATAATE AND
								((CT2_MOEDLC = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
								((@IN_TPSALDO = '*' AND CT2_TPSALD <> '9') OR CT2_TPSALD = @IN_TPSALDO) AND                                   
								CT2_DC IN('2','3') AND                                   
								CT2.D_E_L_E_T_ = ' ' AND
								CQA.CQA_DATA IS NULL ) 
								
				TABTRB           
				GROUP BY CT2_FILIAL, CT2_DATA, CONTA, CUSTO, ITEM, CLVL, EC05, EC06, EC07, EC08, EC09, CT2_MOEDLC, CT2_TPSALD, SLDDEB, SLDCRED ) 
			TRBSLD
			WHERE (ROUND(MOVDEB,2) <> ROUND(SLDDEB,2) OR ROUND(MOVCRED,2) <> ROUND(SLDCRED,2)) AND		
				NOT EXISTS (Select 1 
								From QLJ###
								Where QLJ_FILIAL = @cFilQLJ AND								
										QLJ_DATA = CT2_DATA AND
										QLJ_CONTA = CONTA AND
										QLJ_CUSTO = CUSTO AND
										QLJ_ITEM = ITEM AND
										QLJ_CLVL = CLVL AND
										QLJ_ENT05 = EC05 AND
										QLJ_ENT06 = EC06 AND
										QLJ_ENT07 = EC07 AND
										QLJ_ENT08 = EC08 AND
										QLJ_ENT09 = EC09 AND
										QLJ_MOEDA = CT2_MOEDLC AND
										QLJ_TPSALD = CT2_TPSALD AND
										D_E_L_E_T_ = ' ')
    ORDER BY  1, 2, 3, 4, 5, 6
    for read only
    Open CUR_CTBCQ1
    Fetch CUR_CTBCQ1 into @cFilCT2, @cDATA, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @nMovDeb, @nSldDeb, @nMovCred, @nSldCred, @cMOEDA, @cTPSald
						
    While (@@Fetch_status = 0 ) begin    

		select @iRecno = 0

		##UNIQUEKEY_START		 
		select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
		From QLJ###
		Where QLJ_FILIAL = @cFilQLJ AND
			QLJ_FILORI = @cFilCT2 AND								
			QLJ_DATA = @cDATA AND
			QLJ_CONTA = @cCONTA AND
			QLJ_CUSTO = @cCUSTO AND
			QLJ_ITEM = @cITEM AND
			QLJ_CLVL = @cCLVL AND
			QLJ_ENT05 = @cEC05 AND
			QLJ_ENT06 = @cEC06 AND
			QLJ_ENT07 = @cEC07 AND
			QLJ_ENT08 = @cEC08 AND
			QLJ_ENT09 = @cEC09 AND	
			QLJ_MOEDA = @cMOEDA AND
			QLJ_TPSALD = @cTPSald AND
			D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END		
		
		If @iRecno = 0 begin
			##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
			Insert into QLJ### ( QLJ_FILIAL, QLJ_FILORI, QLJ_DATA, QLJ_CONTA, QLJ_CUSTO, QLJ_ITEM, QLJ_CLVL, QLJ_ENT05, QLJ_ENT06, QLJ_ENT07, QLJ_ENT08, QLJ_ENT09, QLJ_MOVDEB, QLJ_SLDDEB, QLJ_MOVCRE, QLJ_SLDCRE, QLJ_MOEDA, QLJ_TPSALD, QLJ_UUID, QLJ_STATUS, QLJ_TABORI )
						values ( @cFilQLJ,	 @cFilCT2,	 @cDATA,   @cCONTA,	  @cCUSTO,   @cITEM,   @cCLVL, 	 @cEC05,    @cEC06,    @cEC07,    @cEC08,    @cEC09,    0,   		0,   		0,          0,  		@cMOEDA,   @cTPSald,   @IN_UUID, '0',        'CQ1')
			##CHECK_TRANSACTION_COMMIT	
			/* O recno é auto incremental */
			select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM QLJ###		
		end

		 ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         Update QLJ###
         set QLJ_MOVDEB = QLJ_MOVDEB + @nMovDeb,
	         QLJ_SLDDEB = QLJ_SLDDEB + @nSldDeb,
			 QLJ_MOVCRE = QLJ_MOVCRE + @nMovCred,
			 QLJ_SLDCRE = QLJ_SLDCRE + @nSldCred
         Where R_E_C_N_O_ = @iRecno
         ##CHECK_TRANSACTION_COMMIT

		/* --------------------------------------------------------------------------------------------------------------
         Tratamento para o DB2
        -------------------------------------------------------------------------------------------------------------- */
        SELECT @fim_CUR = 0
        Fetch CUR_CTBCQ1 into @cFilCT2, @cDATA, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @nMovDeb, @nSldDeb, @nMovCred, @nSldCred, @cMOEDA, @cTPSald
    end
    close CUR_CTBCQ1
    deallocate CUR_CTBCQ1

	/*--------------------------------------------------
		Compara CQ3
	---------------------------------------------------*/	
	If @IN_LCUSTO = '1' begin
		Declare CUR_CTBCQ3 insensitive cursor for
		SELECT 
			CT2_FILIAL, CT2_DATA, CONTA, CUSTO, ITEM, CLVL, EC05, EC06, EC07, EC08, EC09, MOVDEB, SLDDEB, MOVCRED, SLDCRED, CT2_MOEDLC, CT2_TPSALD		
			FROM ( SELECT 	
					CT2_FILIAL, CT2_DATA, CONTA, CUSTO, ITEM, CLVL, EC05, EC06, EC07, EC08, EC09, SUM(MOVDEB) MOVDEB, SLDDEB, SUM(MOVCRED) MOVCRED, SLDCRED, CT2_MOEDLC, CT2_TPSALD 
					FROM ( SELECT 
							CT2_FILIAL, CT2_TPSALD, CT2_MOEDLC,			
							CT2_DATA, CT2_DEBITO CONTA, CT2_CCD CUSTO, ' ' ITEM, ' ' CLVL, 
							' ' EC05, ' ' EC06, ' ' EC07, ' ' EC08, ' ' EC09,
							CT2_VALOR MOVDEB, ISNULL(CQ3_DEBITO,0) SLDDEB, 0 MOVCRED, 0 SLDCRED                          
							FROM 
								CT2### CT2  
								LEFT JOIN 
									CQA### CQA 
									ON 
										CQA.CQA_FILIAL = @cFilCQA AND
										CQA.CQA_FILCT2 = CT2.CT2_FILIAL AND 
										CQA.CQA_DATA = CT2.CT2_DATA AND 
										CQA.CQA_LOTE = CT2.CT2_LOTE AND 
										CQA.CQA_SBLOTE = CT2.CT2_SBLOTE AND 
										CQA.CQA_DOC = CT2.CT2_DOC AND 
										CQA.CQA_LINHA = CT2.CT2_LINHA AND 
										CQA.CQA_EMPORI = CT2.CT2_EMPORI AND 
										CQA.CQA_MOEDLC = CT2.CT2_MOEDLC AND
										CQA.D_E_L_E_T_ = ' '                              
								LEFT JOIN 
									CQ3### CQ3                                  
									ON 
										CQ3_FILIAL  = CT2_FILIAL AND
										CQ3_CONTA	= CT2_DEBITO AND						
										CQ3_CCUSTO	= CT2_CCD AND                                 
										CQ3_DATA	= CT2_DATA AND                                  
										CQ3_MOEDA	= CT2_MOEDLC AND                                  
										CQ3_TPSALD	= CT2_TPSALD AND   
										((CQ3_LP = 'Z' AND CT2_DTLP <> ' ') OR (CQ3_LP <> 'Z' AND CT2_DTLP = ' ')) AND                               
										CQ3.D_E_L_E_T_ = ' '                          
								WHERE 
									((@IN_LMULTIFIL = '0' AND CT2_FILIAL = @cFilial) OR (CT2_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
									CT2_DATA BETWEEN @IN_DATADE AND @IN_DATAATE AND
									((CT2_MOEDLC = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND    
									CT2_CCD != ' ' AND
									((@IN_TPSALDO = '*' AND CT2_TPSALD <> '9') OR CT2_TPSALD = @IN_TPSALDO) AND                                  
									CT2_DC IN('1','3') AND                                   
									CT2.D_E_L_E_T_ = ' ' AND
									CQA.CQA_DATA IS NULL
						UNION ALL
						SELECT 
							CT2_FILIAL, CT2_TPSALD, CT2_MOEDLC,
							CT2_DATA, CT2_CREDIT CONTA, CT2_CCC CUSTO, ' ' ITEM, ' ' CLVL, 
							' ' EC05, ' ' EC06, ' ' EC07, ' ' EC08, ' ' EC09,
							0 MOVDEB, 0 SLDDEB, CT2_VALOR MOVCRED,  ISNULL(CQ3_CREDIT,0) SLDCRED                          
							FROM 
								CT2### CT2  
								LEFT JOIN 
									CQA### CQA 
									ON 
										CQA.CQA_FILIAL = @cFilCQA AND
										CQA.CQA_FILCT2 = CT2.CT2_FILIAL AND 
										CQA.CQA_DATA = CT2.CT2_DATA AND 
										CQA.CQA_LOTE = CT2.CT2_LOTE AND 
										CQA.CQA_SBLOTE = CT2.CT2_SBLOTE AND 
										CQA.CQA_DOC = CT2.CT2_DOC AND 
										CQA.CQA_LINHA = CT2.CT2_LINHA AND 
										CQA.CQA_EMPORI = CT2.CT2_EMPORI AND 
										CQA.CQA_MOEDLC = CT2.CT2_MOEDLC AND
										CQA.D_E_L_E_T_ = ' '                              
								LEFT JOIN 
									CQ3### CQ3                                  
									ON 
										CQ3_FILIAL  = CT2_FILIAL AND
										CQ3_CONTA	= CT2_CREDIT AND
										CQ3_CCUSTO  = CT2_CCC AND						
										CQ3_DATA	= CT2_DATA AND                                  
										CQ3_MOEDA	= CT2_MOEDLC AND                                  
										CQ3_TPSALD	= CT2_TPSALD AND 
										((CQ3_LP = 'Z' AND CT2_DTLP <> ' ') OR (CQ3_LP <> 'Z' AND CT2_DTLP = ' ')) AND                                  
										CQ3.D_E_L_E_T_ = ' '                     
								WHERE 
									((@IN_LMULTIFIL = '0' AND CT2_FILIAL = @cFilial) OR (CT2_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                 
									CT2_DATA BETWEEN @IN_DATADE AND @IN_DATAATE AND
									((CT2_MOEDLC = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
									CT2_CCC != ' ' AND
									((@IN_TPSALDO = '*' AND CT2_TPSALD <> '9') OR CT2_TPSALD = @IN_TPSALDO) AND                                   
									CT2_DC IN('2','3') AND                                   
									CT2.D_E_L_E_T_ = ' ' AND
									CQA.CQA_DATA IS NULL )
					TABTRB    				
					GROUP BY CT2_FILIAL, CT2_DATA, CONTA, CUSTO, ITEM, CLVL, EC05, EC06, EC07, EC08, EC09, CT2_MOEDLC, CT2_TPSALD, SLDDEB, SLDCRED ) 
				TRBSLD
				WHERE (ROUND(MOVDEB,2) <> ROUND(SLDDEB,2) OR ROUND(MOVCRED,2) <> ROUND(SLDCRED,2)) AND	
					NOT EXISTS (Select 1 
									From QLJ###
									Where QLJ_FILIAL = @cFilQLJ AND								
											QLJ_DATA = CT2_DATA AND
											QLJ_CONTA = CONTA AND
											QLJ_CUSTO = CUSTO AND
											QLJ_ITEM = ITEM AND
											QLJ_CLVL = CLVL AND
											QLJ_ENT05 = EC05 AND
											QLJ_ENT06 = EC06 AND
											QLJ_ENT07 = EC07 AND
											QLJ_ENT08 = EC08 AND
											QLJ_ENT09 = EC09 AND	
											QLJ_MOEDA = CT2_MOEDLC AND
											QLJ_TPSALD = CT2_TPSALD AND
											D_E_L_E_T_ = ' ' )		
		ORDER BY  1, 2, 3, 4, 5, 6
		for read only
		Open CUR_CTBCQ3
		Fetch CUR_CTBCQ3 into @cFilCT2, @cDATA, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @nMovDeb, @nSldDeb, @nMovCred, @nSldCred, @cMOEDA, @cTPSald						
		While (@@Fetch_status = 0 ) begin    

			select @iRecno = 0

			##UNIQUEKEY_START		 
			select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
			From QLJ###
			Where QLJ_FILIAL = @cFilQLJ AND
				QLJ_FILORI = @cFilCT2 AND								
				QLJ_DATA = @cDATA AND
				QLJ_CONTA = @cCONTA AND
				QLJ_CUSTO = @cCUSTO AND
				QLJ_ITEM = @cITEM AND
				QLJ_CLVL = @cCLVL AND
				QLJ_ENT05 = @cEC05 AND
				QLJ_ENT06 = @cEC06 AND
				QLJ_ENT07 = @cEC07 AND
				QLJ_ENT08 = @cEC08 AND
				QLJ_ENT09 = @cEC09 AND	
				QLJ_MOEDA = @cMOEDA AND
				QLJ_TPSALD = @cTPSald AND
				D_E_L_E_T_ = ' '
			##UNIQUEKEY_END		
			
			If @iRecno = 0 begin				
				##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
				Insert into QLJ### ( QLJ_FILIAL, QLJ_FILORI, QLJ_DATA, QLJ_CONTA, QLJ_CUSTO, QLJ_ITEM, QLJ_CLVL, QLJ_ENT05, QLJ_ENT06, QLJ_ENT07, QLJ_ENT08, QLJ_ENT09, QLJ_MOVDEB, QLJ_SLDDEB, QLJ_MOVCRE, QLJ_SLDCRE, QLJ_MOEDA, QLJ_TPSALD, QLJ_UUID, QLJ_STATUS, QLJ_TABORI )
							values ( @cFilQLJ,	 @cFilCT2,	 @cDATA,   @cCONTA,	  @cCUSTO,   @cITEM,   @cCLVL, 	 @cEC05,    @cEC06,    @cEC07,    @cEC08,    @cEC09,    0,   		0,   		0,          0,  		@cMOEDA,   @cTPSald,   @IN_UUID, '0',        'CQ3' )
				##CHECK_TRANSACTION_COMMIT
				/* O recno é auto incremental */
				select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM QLJ###
			end

			##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
			Update QLJ###
			set QLJ_MOVDEB = QLJ_MOVDEB + @nMovDeb,
				QLJ_SLDDEB = QLJ_SLDDEB + @nSldDeb,
				QLJ_MOVCRE = QLJ_MOVCRE + @nMovCred,
				QLJ_SLDCRE = QLJ_SLDCRE + @nSldCred
			Where R_E_C_N_O_ = @iRecno
			##CHECK_TRANSACTION_COMMIT

			/* --------------------------------------------------------------------------------------------------------------
			Tratamento para o DB2
			-------------------------------------------------------------------------------------------------------------- */
			SELECT @fim_CUR = 0
			Fetch CUR_CTBCQ3 into @cFilCT2, @cDATA, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @nMovDeb, @nSldDeb, @nMovCred, @nSldCred, @cMOEDA, @cTPSald
		end
		close CUR_CTBCQ3
		deallocate CUR_CTBCQ3
	end

	/*--------------------------------------------------
		Compara CQ5
	---------------------------------------------------*/
	If @IN_LITEM = '1' begin
		Declare CUR_CTBCQ5 insensitive cursor for
		SELECT 
			CT2_FILIAL, CT2_DATA, CONTA, CUSTO, ITEM, CLVL, EC05, EC06, EC07, EC08, EC09, MOVDEB, SLDDEB, MOVCRED, SLDCRED, CT2_MOEDLC, CT2_TPSALD		
			FROM ( SELECT 	
					CT2_FILIAL, CT2_DATA, CONTA, CUSTO, ITEM, CLVL, EC05, EC06, EC07, EC08, EC09, SUM(MOVDEB) MOVDEB, SLDDEB, SUM(MOVCRED) MOVCRED, SLDCRED, CT2_MOEDLC, CT2_TPSALD 
					FROM ( SELECT 
							CT2_FILIAL, CT2_TPSALD, CT2_MOEDLC,			
							CT2_DATA, CT2_DEBITO CONTA, CT2_CCD CUSTO, CT2_ITEMD ITEM, ' ' CLVL, 
							' ' EC05, ' ' EC06, ' ' EC07, ' ' EC08, ' ' EC09,
							CT2_VALOR MOVDEB, ISNULL(CQ5_DEBITO,0) SLDDEB, 0 MOVCRED, 0 SLDCRED                          
							FROM 
								CT2### CT2 
								LEFT JOIN 
									CQA### CQA 
									ON 
										CQA.CQA_FILIAL = @cFilCQA AND
										CQA.CQA_FILCT2 = CT2.CT2_FILIAL AND 
										CQA.CQA_DATA = CT2.CT2_DATA AND 
										CQA.CQA_LOTE = CT2.CT2_LOTE AND 
										CQA.CQA_SBLOTE = CT2.CT2_SBLOTE AND 
										CQA.CQA_DOC = CT2.CT2_DOC AND 
										CQA.CQA_LINHA = CT2.CT2_LINHA AND 
										CQA.CQA_EMPORI = CT2.CT2_EMPORI AND 
										CQA.CQA_MOEDLC = CT2.CT2_MOEDLC AND
										CQA.D_E_L_E_T_ = ' '                               
								LEFT JOIN 
									CQ5### CQ5                                  
									ON 
										CQ5_FILIAL  = CT2_FILIAL AND
										CQ5_CONTA	= CT2_DEBITO AND						
										CQ5_CCUSTO	= CT2_CCD AND                                 
										CQ5_ITEM	= CT2_ITEMD AND
										CQ5_DATA	= CT2_DATA AND                                  
										CQ5_MOEDA	= CT2_MOEDLC AND                                  
										CQ5_TPSALD	= CT2_TPSALD AND 
										((CQ5_LP = 'Z' AND CT2_DTLP <> ' ') OR (CQ5_LP <> 'Z' AND CT2_DTLP = ' ')) AND                                  
										CQ5.D_E_L_E_T_ = ' '                          
								WHERE 
									((@IN_LMULTIFIL = '0' AND CT2_FILIAL = @cFilial) OR (CT2_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                  
									CT2_DATA BETWEEN @IN_DATADE AND @IN_DATAATE AND
									((CT2_MOEDLC = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
									CT2_ITEMD != ' ' AND
									((@IN_TPSALDO = '*' AND CT2_TPSALD <> '9') OR CT2_TPSALD = @IN_TPSALDO) AND                                  
									CT2_DC IN('1','3') AND                                   
									CT2.D_E_L_E_T_ = ' ' AND 
									CQA.CQA_DATA IS NULL					
						UNION ALL
						SELECT 
							CT2_FILIAL, CT2_TPSALD, CT2_MOEDLC,
							CT2_DATA, CT2_CREDIT CONTA, CT2_CCC CUSTO, CT2_ITEMC ITEM, ' ' CLVL, 
							' ' EC05, ' ' EC06, ' ' EC07, ' ' EC08, ' ' EC09,
							0 MOVDEB, 0 SLDDEB, CT2_VALOR MOVCRED,  ISNULL(CQ5_CREDIT,0) SLDCRED                          
							FROM 
								CT2### CT2  
								LEFT JOIN 
									CQA### CQA 
									ON 
										CQA.CQA_FILIAL = @cFilCQA AND
										CQA.CQA_FILCT2 = CT2.CT2_FILIAL AND 
										CQA.CQA_DATA = CT2.CT2_DATA AND 
										CQA.CQA_LOTE = CT2.CT2_LOTE AND 
										CQA.CQA_SBLOTE = CT2.CT2_SBLOTE AND 
										CQA.CQA_DOC = CT2.CT2_DOC AND 
										CQA.CQA_LINHA = CT2.CT2_LINHA AND 
										CQA.CQA_EMPORI = CT2.CT2_EMPORI AND 
										CQA.CQA_MOEDLC = CT2.CT2_MOEDLC AND
										CQA.D_E_L_E_T_ = ' '                              
								LEFT JOIN 
									CQ5### CQ5                                  
									ON 
										CQ5_FILIAL  = CT2_FILIAL AND
										CQ5_CONTA	= CT2_CREDIT AND						
										CQ5_CCUSTO	= CT2_CCC AND                                 
										CQ5_ITEM	= CT2_ITEMC AND
										CQ5_DATA	= CT2_DATA AND                                  
										CQ5_MOEDA	= CT2_MOEDLC AND                                  
										CQ5_TPSALD	= CT2_TPSALD AND  
										((CQ5_LP = 'Z' AND CT2_DTLP <> ' ') OR (CQ5_LP <> 'Z' AND CT2_DTLP = ' ')) AND                                 
										CQ5.D_E_L_E_T_ = ' '                     
								WHERE 
									((@IN_LMULTIFIL = '0' AND CT2_FILIAL = @cFilial) OR (CT2_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                
									CT2_DATA BETWEEN @IN_DATADE AND @IN_DATAATE AND
									((CT2_MOEDLC = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
									CT2_ITEMC != ' ' AND
									((@IN_TPSALDO = '*' AND CT2_TPSALD <> '9') OR CT2_TPSALD = @IN_TPSALDO) AND                                   
									CT2_DC IN('2','3') AND                                   
									CT2.D_E_L_E_T_ = ' ' AND
									CQA.CQA_DATA IS NULL )					 
					TABTRB
					GROUP BY CT2_FILIAL, CT2_DATA, CONTA, CUSTO, ITEM, CLVL, EC05, EC06, EC07, EC08, EC09, CT2_MOEDLC, CT2_TPSALD, SLDDEB, SLDCRED )
				TRBSLD
				WHERE (ROUND(MOVDEB,2) <> ROUND(SLDDEB,2) OR ROUND(MOVCRED,2) <> ROUND(SLDCRED,2)) AND
					NOT EXISTS (Select 1 
									From QLJ###
									Where QLJ_FILIAL = @cFilQLJ AND								
											QLJ_DATA = CT2_DATA AND
											QLJ_CONTA = CONTA AND
											QLJ_CUSTO = CUSTO AND
											QLJ_ITEM = ITEM AND
											QLJ_CLVL = CLVL AND
											QLJ_ENT05 = EC05 AND
											QLJ_ENT06 = EC06 AND
											QLJ_ENT07 = EC07 AND
											QLJ_ENT08 = EC08 AND
											QLJ_ENT09 = EC09 AND	
											QLJ_MOEDA = CT2_MOEDLC AND
											QLJ_TPSALD = CT2_TPSALD AND
											D_E_L_E_T_ = ' ')
		ORDER BY  1, 2, 3, 4, 5, 6
		for read only
		Open CUR_CTBCQ5
		Fetch CUR_CTBCQ5 into @cFilCT2, @cDATA, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @nMovDeb, @nSldDeb, @nMovCred, @nSldCred, @cMOEDA, @cTPSald
							
		While (@@Fetch_status = 0 ) begin    

			select @iRecno = 0

			##UNIQUEKEY_START		 
			select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
			From QLJ###
			Where QLJ_FILIAL = @cFilQLJ AND
				QLJ_FILORI = @cFilCT2 AND								
				QLJ_DATA = @cDATA AND
				QLJ_CONTA = @cCONTA AND
				QLJ_CUSTO = @cCUSTO AND
				QLJ_ITEM = @cITEM AND
				QLJ_CLVL = @cCLVL AND
				QLJ_ENT05 = @cEC05 AND
				QLJ_ENT06 = @cEC06 AND
				QLJ_ENT07 = @cEC07 AND
				QLJ_ENT08 = @cEC08 AND
				QLJ_ENT09 = @cEC09 AND	
				QLJ_MOEDA = @cMOEDA AND
				QLJ_TPSALD = @cTPSald AND
				D_E_L_E_T_ = ' '
			##UNIQUEKEY_END		
			
			If @iRecno = 0 begin
				##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
				Insert into QLJ### ( QLJ_FILIAL, QLJ_FILORI, QLJ_DATA, QLJ_CONTA, QLJ_CUSTO, QLJ_ITEM, QLJ_CLVL, QLJ_ENT05, QLJ_ENT06, QLJ_ENT07, QLJ_ENT08, QLJ_ENT09, QLJ_MOVDEB, QLJ_SLDDEB, QLJ_MOVCRE, QLJ_SLDCRE, QLJ_MOEDA, QLJ_TPSALD, QLJ_UUID, QLJ_STATUS, QLJ_TABORI )
							values ( @cFilQLJ,	 @cFilCT2,	 @cDATA,   @cCONTA,	  @cCUSTO,   @cITEM,   @cCLVL, 	 @cEC05,    @cEC06,    @cEC07,    @cEC08,    @cEC09,    0,   		0,   		0,          0,  		@cMOEDA,   @cTPSald,   @IN_UUID, '0',        'CQ5' )
				##CHECK_TRANSACTION_COMMIT
				/* O recno é auto incremental */
				select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM QLJ###
			end

			##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
			Update QLJ###
			set QLJ_MOVDEB = QLJ_MOVDEB + @nMovDeb,
				QLJ_SLDDEB = QLJ_SLDDEB + @nSldDeb,
				QLJ_MOVCRE = QLJ_MOVCRE + @nMovCred,
				QLJ_SLDCRE = QLJ_SLDCRE + @nSldCred
			Where R_E_C_N_O_ = @iRecno
			##CHECK_TRANSACTION_COMMIT

			/* --------------------------------------------------------------------------------------------------------------
			Tratamento para o DB2
			-------------------------------------------------------------------------------------------------------------- */
			SELECT @fim_CUR = 0
			Fetch CUR_CTBCQ5 into @cFilCT2, @cDATA, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @nMovDeb, @nSldDeb, @nMovCred, @nSldCred, @cMOEDA, @cTPSald
		end
		close CUR_CTBCQ5
		deallocate CUR_CTBCQ5
	End

	
	/*--------------------------------------------------
		Compara CQ7
	---------------------------------------------------*/
	if @IN_LCLVL = '1' begin
		Declare CUR_CTBCQ7 insensitive cursor for
		SELECT 
			CT2_FILIAL, CT2_DATA, CONTA, CUSTO, ITEM, CLVL, EC05, EC06, EC07, EC08, EC09, MOVDEB, SLDDEB, MOVCRED, SLDCRED, CT2_MOEDLC, CT2_TPSALD		
			FROM ( SELECT 	
					CT2_FILIAL, CT2_DATA, CONTA, CUSTO, ITEM, CLVL, EC05, EC06, EC07, EC08, EC09, SUM(MOVDEB) MOVDEB, SLDDEB, SUM(MOVCRED) MOVCRED, SLDCRED, CT2_MOEDLC, CT2_TPSALD 
					FROM ( SELECT 
							CT2_FILIAL, CT2_TPSALD, CT2_MOEDLC,			
							CT2_DATA, CT2_DEBITO CONTA, CT2_CCD CUSTO, CT2_ITEMD ITEM, CT2_CLVLDB CLVL, 
							' ' EC05, ' ' EC06, ' ' EC07, ' ' EC08, ' ' EC09,
							CT2_VALOR MOVDEB, ISNULL(CQ7_DEBITO,0) SLDDEB, 0 MOVCRED, 0 SLDCRED                          
							FROM 
								CT2### CT2 
								LEFT JOIN 
									CQA### CQA 
									ON 
										CQA.CQA_FILIAL = @cFilCQA AND
										CQA.CQA_FILCT2 = CT2.CT2_FILIAL AND 
										CQA.CQA_DATA = CT2.CT2_DATA AND 
										CQA.CQA_LOTE = CT2.CT2_LOTE AND 
										CQA.CQA_SBLOTE = CT2.CT2_SBLOTE AND 
										CQA.CQA_DOC = CT2.CT2_DOC AND 
										CQA.CQA_LINHA = CT2.CT2_LINHA AND 
										CQA.CQA_EMPORI = CT2.CT2_EMPORI AND 
										CQA.CQA_MOEDLC = CT2.CT2_MOEDLC AND
										CQA.D_E_L_E_T_ = ' '                               
								LEFT JOIN 
									CQ7### CQ7                                  
									ON 
										CQ7_FILIAL  = CT2_FILIAL AND
										CQ7_CONTA	= CT2_DEBITO AND						
										CQ7_CCUSTO	= CT2_CCD AND                                 
										CQ7_ITEM	= CT2_ITEMD AND
										CQ7_CLVL	= CT2_CLVLDB AND
										CQ7_DATA	= CT2_DATA AND                                  
										CQ7_MOEDA	= CT2_MOEDLC AND                                  
										CQ7_TPSALD	= CT2_TPSALD AND
										((CQ7_LP = 'Z' AND CT2_DTLP <> ' ') OR (CQ7_LP <> 'Z' AND CT2_DTLP = ' ')) AND                                   
										CQ7.D_E_L_E_T_ = ' '                          
								WHERE 
									((@IN_LMULTIFIL = '0' AND CT2_FILIAL = @cFilial) OR (CT2_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                 
									CT2_DATA BETWEEN @IN_DATADE AND @IN_DATAATE AND
									((CT2_MOEDLC = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND   
									CT2_CLVLDB != ' ' AND
									((@IN_TPSALDO = '*' AND CT2_TPSALD <> '9') OR CT2_TPSALD = @IN_TPSALDO) AND                                  
									CT2_DC IN('1','3') AND                                   
									CT2.D_E_L_E_T_ = ' ' AND
									CQA.CQA_DATA IS NULL
						UNION ALL
						SELECT 
							CT2_FILIAL, CT2_TPSALD, CT2_MOEDLC,
							CT2_DATA, CT2_CREDIT CONTA, CT2_CCC CUSTO, CT2_ITEMC ITEM, CT2_CLVLCR CLVL,
							' ' EC05, ' ' EC06, ' ' EC07, ' ' EC08, ' ' EC09, 
							0 MOVDEB, 0 SLDDEB, CT2_VALOR MOVCRED,  ISNULL(CQ7_CREDIT,0) SLDCRED                          
							FROM 
								CT2### CT2  
								LEFT JOIN 
									CQA### CQA 
									ON 
										CQA.CQA_FILIAL = @cFilCQA AND
										CQA.CQA_FILCT2 = CT2.CT2_FILIAL AND 
										CQA.CQA_DATA = CT2.CT2_DATA AND 
										CQA.CQA_LOTE = CT2.CT2_LOTE AND 
										CQA.CQA_SBLOTE = CT2.CT2_SBLOTE AND 
										CQA.CQA_DOC = CT2.CT2_DOC AND 
										CQA.CQA_LINHA = CT2.CT2_LINHA AND 
										CQA.CQA_EMPORI = CT2.CT2_EMPORI AND 
										CQA.CQA_MOEDLC = CT2.CT2_MOEDLC AND
										CQA.D_E_L_E_T_ = ' '                              
								LEFT JOIN 
									CQ7### CQ7                                  
									ON 
										CQ7_FILIAL  = CT2_FILIAL AND
										CQ7_CONTA	= CT2_CREDIT AND						
										CQ7_CCUSTO	= CT2_CCC AND                                 
										CQ7_ITEM	= CT2_ITEMC AND
										CQ7_CLVL	= CT2_CLVLCR AND
										CQ7_DATA	= CT2_DATA AND                                  
										CQ7_MOEDA	= CT2_MOEDLC AND                                  
										CQ7_TPSALD	= CT2_TPSALD AND 
										((CQ7_LP = 'Z' AND CT2_DTLP <> ' ') OR (CQ7_LP <> 'Z' AND CT2_DTLP = ' ')) AND                                  
										CQ7.D_E_L_E_T_ = ' '                     
								WHERE 
									((@IN_LMULTIFIL = '0' AND CT2_FILIAL = @cFilial) OR (CT2_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND                                 
									CT2_DATA BETWEEN @IN_DATADE AND @IN_DATAATE AND
									((CT2_MOEDLC = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
									CT2_CLVLCR != ' ' AND
									((@IN_TPSALDO = '*' AND CT2_TPSALD <> '9') OR CT2_TPSALD = @IN_TPSALDO) AND                                   
									CT2_DC IN('2','3') AND                                   
									CT2.D_E_L_E_T_ = ' ' AND
									CQA.CQA_DATA IS NULL )				
					TABTRB            
					GROUP BY CT2_FILIAL, CT2_DATA, CONTA, CUSTO, ITEM, CLVL, EC05, EC06, EC07, EC08, EC09, CT2_MOEDLC, CT2_TPSALD, SLDDEB, SLDCRED ) 
				TRBSLD
				WHERE (ROUND(MOVDEB,2) <> ROUND(SLDDEB,2) OR ROUND(MOVCRED,2) <> ROUND(SLDCRED,2)) AND	
					NOT EXISTS (Select 1 
									From QLJ###
									Where QLJ_FILIAL = @cFilQLJ AND								
											QLJ_DATA = CT2_DATA AND
											QLJ_CONTA = CONTA AND
											QLJ_CUSTO = CUSTO AND
											QLJ_ITEM = ITEM AND
											QLJ_CLVL = CLVL AND
											QLJ_ENT05 = EC05 AND
											QLJ_ENT06 = EC06 AND
											QLJ_ENT07 = EC07 AND
											QLJ_ENT08 = EC08 AND
											QLJ_ENT09 = EC09 AND	
											QLJ_MOEDA = CT2_MOEDLC AND
											QLJ_TPSALD = CT2_TPSALD AND
											D_E_L_E_T_ = ' ')
		ORDER BY  1, 2, 3, 4, 5, 6
		for read only
		Open CUR_CTBCQ7
		Fetch CUR_CTBCQ7 into @cFilCT2, @cDATA, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @nMovDeb, @nSldDeb, @nMovCred, @nSldCred, @cMOEDA, @cTPSald
							
		While (@@Fetch_status = 0 ) begin    

			select @iRecno = 0
			
			##UNIQUEKEY_START		 
			select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
			From QLJ###
			Where QLJ_FILIAL = @cFilQLJ AND
				QLJ_FILORI = @cFilCT2 AND								
				QLJ_DATA = @cDATA AND
				QLJ_CONTA = @cCONTA AND
				QLJ_CUSTO = @cCUSTO AND
				QLJ_ITEM = @cITEM AND
				QLJ_CLVL = @cCLVL AND
				QLJ_ENT05 = @cEC05 AND
				QLJ_ENT06 = @cEC06 AND
				QLJ_ENT07 = @cEC07 AND
				QLJ_ENT08 = @cEC08 AND
				QLJ_ENT09 = @cEC09 AND	
				QLJ_MOEDA = @cMOEDA AND
				QLJ_TPSALD = @cTPSald AND
				D_E_L_E_T_ = ' '
			##UNIQUEKEY_END		
			
			If @iRecno = 0 begin
				##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
				Insert into QLJ### ( QLJ_FILIAL, QLJ_FILORI, QLJ_DATA, QLJ_CONTA, QLJ_CUSTO, QLJ_ITEM, QLJ_CLVL, QLJ_ENT05, QLJ_ENT06, QLJ_ENT07, QLJ_ENT08, QLJ_ENT09, QLJ_MOVDEB, QLJ_SLDDEB, QLJ_MOVCRE, QLJ_SLDCRE, QLJ_MOEDA, QLJ_TPSALD, QLJ_UUID, QLJ_STATUS, QLJ_TABORI )
							values ( @cFilQLJ,	 @cFilCT2,	 @cDATA,   @cCONTA,	  @cCUSTO,   @cITEM,   @cCLVL, 	 @cEC05,    @cEC06,    @cEC07,    @cEC08,    @cEC09,    0,   		0,   		0,          0,  		@cMOEDA,   @cTPSald,   @IN_UUID, '0',        'CQ7' )
				##CHECK_TRANSACTION_COMMIT
				/* O recno é auto incremental */
				select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM QLJ###
			end

			##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
			Update QLJ###
			set QLJ_MOVDEB = QLJ_MOVDEB + @nMovDeb,
				QLJ_SLDDEB = QLJ_SLDDEB + @nSldDeb,
				QLJ_MOVCRE = QLJ_MOVCRE + @nMovCred,
				QLJ_SLDCRE = QLJ_SLDCRE + @nSldCred
			Where R_E_C_N_O_ = @iRecno
			##CHECK_TRANSACTION_COMMIT

			/* --------------------------------------------------------------------------------------------------------------
			Tratamento para o DB2
			-------------------------------------------------------------------------------------------------------------- */
			SELECT @fim_CUR = 0
			Fetch CUR_CTBCQ7 into @cFilCT2, @cDATA, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @nMovDeb, @nSldDeb, @nMovCred, @nSldCred, @cMOEDA, @cTPSald
		end
		close CUR_CTBCQ7
		deallocate CUR_CTBCQ7
	end


	##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. ) .And. AliasInDic("CVX")})
    ##FIELDP01( 'CT0.CT0_ID' )

 		Select @nMovDeb = 0
		Select @nSldDeb = 0
		Select @nMovCred = 0
		Select @nSldCred = 0
		Select @cConfig  = IsNull(Max(CT0_ID),' ') From CT0### Where CT0_FILIAL = @cFilCT0 and D_E_L_E_T_ = ' '
			
		Declare CUR_CTBCUB insensitive cursor for
		SELECT 
			CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_TPSALD, CONTA, CCUSTO, ITEM, CLASSE, EC05, EC06, EC07, EC08, EC09, MOVDEB, SLDDEB, MOVCRE, SLDCRE 
			FROM ( SELECT 
						CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_TPSALD, CONTA, CCUSTO, ITEM, CLASSE, EC05, EC06, EC07, EC08, EC09, 
						MOVDEB, SLDDEB, MOVCRE, SLDCRE
						FROM ( SELECT 								
								CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_TPSALD, CT2_DEBITO CONTA, CT2_CCD CCUSTO, CT2_ITEMD ITEM, CT2_CLVLDB CLASSE,
								
								##IF_002({|| CT2->(FieldPos('CT2_EC05DB'))>0})
									CT2_EC05DB EC05,
								##ELSE_002
									' ' EC05,
								##ENDIF_002
								
								##IF_002({|| CT2->(FieldPos('CT2_EC06DB'))>0})
									CT2_EC06DB EC06,
								##ELSE_002
									' ' EC06,
								##ENDIF_002

								##IF_002({|| CT2->(FieldPos('CT2_EC07DB'))>0})
									CT2_EC07DB EC07,
								##ELSE_002
									' ' EC07,
								##ENDIF_002

								##IF_002({|| CT2->(FieldPos('CT2_EC08DB'))>0})
									CT2_EC08DB EC08,
								##ELSE_002
									' ' EC08,
								##ENDIF_002

								##IF_002({|| CT2->(FieldPos('CT2_EC09DB'))>0})
									CT2_EC09DB EC09,
								##ELSE_002
									' ' EC09,
								##ENDIF_002

								SUM(CT2_VALOR) MOVDEB, ISNULL(CVX_SLDDEB,0) SLDDEB, 0 MOVCRE, 0 SLDCRE
								FROM CT2### CT2
									LEFT JOIN 
										CQA### CQA 
										ON 
											CQA.CQA_FILIAL = @cFilCQA AND
											CQA.CQA_FILCT2 = CT2.CT2_FILIAL AND 
											CQA.CQA_DATA = CT2.CT2_DATA AND 
											CQA.CQA_LOTE = CT2.CT2_LOTE AND 
											CQA.CQA_SBLOTE = CT2.CT2_SBLOTE AND 
											CQA.CQA_DOC = CT2.CT2_DOC AND 
											CQA.CQA_LINHA = CT2.CT2_LINHA AND 
											CQA.CQA_EMPORI = CT2.CT2_EMPORI AND 
											CQA.CQA_MOEDLC = CT2.CT2_MOEDLC AND
											CQA.D_E_L_E_T_ = ' ' 
									LEFT JOIN 
										CVX### CVX
										ON
											CVX_FILIAL = CT2_FILIAL AND
											CVX_DATA = CT2_DATA AND
											CVX_CONFIG = @cConfig AND
											CVX_MOEDA = CT2_MOEDLC AND
											CVX_TPSALD = CT2_TPSALD AND
											CVX_NIV01 = CT2_DEBITO AND
											CVX_NIV02 = CT2_CCD AND
											CVX_NIV03 = CT2_ITEMD AND
											CVX_NIV04 = CT2_CLVLDB AND
											
											##FIELDP02( 'CT2.CT2_EC05DB' )
												CVX_NIV05 = CT2_EC05DB AND
											##ENDFIELDP02
											
											##FIELDP02( 'CT2.CT2_EC06DB' )
												CVX_NIV06 = CT2_EC06DB AND
											##ENDFIELDP02
											
											##FIELDP02( 'CT2.CT2_EC07DB' )
												CVX_NIV07 = CT2_EC07DB AND
											##ENDFIELDP02
											
											##FIELDP02( 'CT2.CT2_EC08DB' )
												CVX_NIV08 = CT2_EC08DB AND
											##ENDFIELDP02
											
											##FIELDP02( 'CT2.CT2_EC09DB' )
												CVX_NIV09 = CT2_EC09DB AND
											##ENDFIELDP02
											
											CVX.D_E_L_E_T_ = ' ' 
								WHERE 
									((@IN_LMULTIFIL = '0' AND CT2_FILIAL = @cFilial) OR (CT2_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND
									(CT2_DC = '1' or CT2_DC = '3') and
									((@IN_TPSALDO = '*' AND CT2_TPSALD <> '9') OR CT2_TPSALD = @IN_TPSALDO) and
									((CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1') or @IN_LMOEDAESP != '1') and
									(CT2_DATA between @IN_DATADE and @IN_DATAATE) and
									CT2_DEBITO != ' ' and
									(
										##FIELDP02( 'CT2.CT2_EC05DB' )
											CT2_EC05DB <> ' ' OR
										##ENDFIELDP02
										
										##FIELDP02( 'CT2.CT2_EC06DB' )
											CT2_EC06DB <> ' ' OR
										##ENDFIELDP02

										##FIELDP02( 'CT2.CT2_EC07DB' )
											CT2_EC07DB <> ' ' OR
										##ENDFIELDP02

										##FIELDP02( 'CT2.CT2_EC08DB' )
											CT2_EC08DB <> ' ' OR
										##ENDFIELDP02

										##FIELDP02( 'CT2.CT2_EC09DB' )
											CT2_EC09DB <> ' ' OR
										##ENDFIELDP02
										
										1=0
									) and
									CT2.D_E_L_E_T_= ' ' and
									CQA.CQA_DATA IS NULL
							GROUP BY CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_TPSALD, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB, 
									
									##FIELDP02( 'CT2.CT2_EC05DB' )
										CT2_EC05DB,
									##ENDFIELDP02
									
									##FIELDP02( 'CT2.CT2_EC06DB' )
										CT2_EC06DB,
									##ENDFIELDP02
									
									##FIELDP02( 'CT2.CT2_EC07DB' )
										CT2_EC07DB,
									##ENDFIELDP02
									
									##FIELDP02( 'CT2.CT2_EC08DB' )
										CT2_EC08DB,
									##ENDFIELDP02
									
									##FIELDP02( 'CT2.CT2_EC09DB' )
										CT2_EC09DB,
									##ENDFIELDP02 
									
									CVX_SLDDEB
							UNION
								SELECT 
									CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_TPSALD, CT2_CREDIT CONTA, CT2_CCC CCUSTO, CT2_ITEMC ITEM, CT2_CLVLCR CLASSE,
									
									##IF_002({|| CT2->(FieldPos('CT2_EC05CR'))>0})
										CT2_EC05CR EC05,
									##ELSE_002
										' ' EC05,
									##ENDIF_002
									
									##IF_002({|| CT2->(FieldPos('CT2_EC06CR'))>0})
										CT2_EC06CR EC06,
									##ELSE_002
										' ' EC06,
									##ENDIF_002

									##IF_002({|| CT2->(FieldPos('CT2_EC07CR'))>0})
										CT2_EC07CR EC07,
									##ELSE_002
										' ' EC07,
									##ENDIF_002

									##IF_002({|| CT2->(FieldPos('CT2_EC08CR'))>0})
										CT2_EC08CR EC08,
									##ELSE_002
										' ' EC08,
									##ENDIF_002

									##IF_002({|| CT2->(FieldPos('CT2_EC09CR'))>0})
										CT2_EC09CR EC09,
									##ELSE_002
										' ' EC09,
									##ENDIF_002

									0 MOVDEB, 0 SLDDEB, SUM(CT2_VALOR) MOVCRE, ISNULL(CVX_SLDCRD,0) SLDCRE
									FROM CT2### CT2
										LEFT JOIN 
										CQA### CQA 
										ON 
											CQA.CQA_FILIAL = @cFilCQA AND
											CQA.CQA_FILCT2 = CT2.CT2_FILIAL AND 
											CQA.CQA_DATA = CT2.CT2_DATA AND 
											CQA.CQA_LOTE = CT2.CT2_LOTE AND 
											CQA.CQA_SBLOTE = CT2.CT2_SBLOTE AND 
											CQA.CQA_DOC = CT2.CT2_DOC AND 
											CQA.CQA_LINHA = CT2.CT2_LINHA AND 
											CQA.CQA_EMPORI = CT2.CT2_EMPORI AND 
											CQA.CQA_MOEDLC = CT2.CT2_MOEDLC AND
											CQA.D_E_L_E_T_ = ' ' 
										LEFT JOIN 
										CVX### CVX
										ON
											CVX_FILIAL = CT2_FILIAL AND
											CVX_DATA = CT2_DATA AND
											CVX_CONFIG = @cConfig AND
											CVX_MOEDA = CT2_MOEDLC AND
											CVX_TPSALD = CT2_TPSALD AND
											CVX_NIV01 = CT2_CREDIT AND
											CVX_NIV02 = CT2_CCC AND
											CVX_NIV03 = CT2_ITEMC AND
											CVX_NIV04 = CT2_CLVLCR AND
											
											##FIELDP02( 'CT2.CT2_EC05CR' )
												CVX_NIV05 = CT2_EC05CR AND
											##ENDFIELDP02
											
											##FIELDP02( 'CT2.CT2_EC06CR' )
												CVX_NIV06 = CT2_EC06CR AND
											##ENDFIELDP02
											
											##FIELDP02( 'CT2.CT2_EC07CR' )
												CVX_NIV07 = CT2_EC07CR AND
											##ENDFIELDP02
											
											##FIELDP02( 'CT2.CT2_EC08CR' )
												CVX_NIV08 = CT2_EC08CR AND
											##ENDFIELDP02
											
											##FIELDP02( 'CT2.CT2_EC09CR' )
												CVX_NIV09 = CT2_EC09CR AND
											##ENDFIELDP02
											
											CVX.D_E_L_E_T_ = ' ' 
									WHERE 
										((@IN_LMULTIFIL = '0' AND CT2_FILIAL = @cFilial) OR (CT2_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND
										(CT2_DC = '2' or CT2_DC = '3') and
										((@IN_TPSALDO = '*' AND CT2_TPSALD <> '9') OR CT2_TPSALD = @IN_TPSALDO) and
										((CT2_MOEDLC = @IN_MOEDA and @IN_LMOEDAESP = '1') or @IN_LMOEDAESP != '1') and
										(CT2_DATA between @IN_DATADE and @IN_DATAATE) and
										CT2_CREDIT != ' ' and
										(																						
											##FIELDP02( 'CT2.CT2_EC06CR' )
												CT2_EC06CR <> ' ' OR
											##ENDFIELDP02

											##FIELDP02( 'CT2.CT2_EC07CR' )
												CT2_EC07CR <> ' ' OR
											##ENDFIELDP02

											##FIELDP02( 'CT2.CT2_EC08CR' )
												CT2_EC08CR <> ' ' OR
											##ENDFIELDP02

											##FIELDP02( 'CT2.CT2_EC09CR' )
												CT2_EC09CR <> ' ' OR
											##ENDFIELDP02

											##FIELDP02( 'CT2.CT2_EC05CR' )
												CT2_EC05CR <> ' ' OR
											##ENDFIELDP02

											1=0
										) and
										CT2.D_E_L_E_T_ = ' ' and
										CQA.CQA_DATA IS NULL
							GROUP BY CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_TPSALD, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR,
									
									##FIELDP02( 'CT2.CT2_EC05CR' )
										CT2_EC05CR,
									##ENDFIELDP02
									
									##FIELDP02( 'CT2.CT2_EC06CR' )
										CT2_EC06CR,
									##ENDFIELDP02
									
									##FIELDP02( 'CT2.CT2_EC07CR' )
										CT2_EC07CR,
									##ENDFIELDP02
									
									##FIELDP02( 'CT2.CT2_EC08CR' )
										CT2_EC08CR,
									##ENDFIELDP02
									
									##FIELDP02( 'CT2.CT2_EC09CR' )
										CT2_EC09CR,
									##ENDFIELDP02
									
									CVX_SLDCRD ) TABTRB
				Group By CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_TPSALD, CONTA, CCUSTO, ITEM, CLASSE, EC05, EC06, EC07, EC08, EC09, MOVDEB, SLDDEB, MOVCRE, SLDCRE) TABSLD
			WHERE (ROUND(MOVDEB,2) <> ROUND(SLDDEB,2) OR ROUND(MOVCRE,2) <> ROUND(SLDCRE,2))
			order by CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CONTA, CCUSTO, ITEM, CLASSE, EC05, EC06, EC07, EC08, EC09			
		for read only
		Open CUR_CTBCUB
		Fetch CUR_CTBCUB into @cFilCT2, @cDATA, @cMOEDA, @cTPSald, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @nMovDeb, @nSldDeb, @nMovCred, @nSldCred
		
		While (@@Fetch_status = 0 ) begin

			select @iRecno = 0

			##UNIQUEKEY_START		 
			select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
			From QLJ###
			Where QLJ_FILIAL = @cFilQLJ AND
				QLJ_FILORI = @cFilCT2 AND								
				QLJ_DATA = @cDATA AND
				QLJ_CONTA = @cCONTA AND
				QLJ_CUSTO = @cCUSTO AND
				QLJ_ITEM = @cITEM AND
				QLJ_CLVL = @cCLVL AND
				QLJ_ENT05 = @cEC05 AND
				QLJ_ENT06 = @cEC06 AND
				QLJ_ENT07 = @cEC07 AND
				QLJ_ENT08 = @cEC08 AND
				QLJ_ENT09 = @cEC09 AND
				QLJ_MOEDA = @cMOEDA AND
				QLJ_TPSALD = @cTPSald AND
				D_E_L_E_T_ = ' '
			##UNIQUEKEY_END		
			
			If @iRecno = 0 begin				
				##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
				Insert into QLJ### ( QLJ_FILIAL, QLJ_FILORI, QLJ_DATA, QLJ_CONTA, QLJ_CUSTO, QLJ_ITEM, QLJ_CLVL, QLJ_ENT05, QLJ_ENT06, QLJ_ENT07, QLJ_ENT08, QLJ_ENT09, QLJ_MOVDEB, QLJ_SLDDEB, QLJ_MOVCRE, QLJ_SLDCRE, QLJ_MOEDA, QLJ_TPSALD, QLJ_UUID, QLJ_STATUS, QLJ_TABORI )
							values ( @cFilQLJ,	 @cFilCT2,	 @cDATA,   @cCONTA,	  @cCUSTO,   @cITEM,   @cCLVL,   @cEC05,	@cEC06,	    @cEC07,	  @cEC08,	 @cEC09,	0,   		0,   		0,          0,  		@cMOEDA,   @cTPSald,   @IN_UUID, '0',        'CVX' )
				##CHECK_TRANSACTION_COMMIT
				/* O recno é auto incremental */
				select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM QLJ###				
			end

			##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
			Update QLJ###
			set QLJ_MOVDEB = QLJ_MOVDEB + @nMovDeb,
				QLJ_SLDDEB = QLJ_SLDDEB + @nSldDeb,
				QLJ_MOVCRE = QLJ_MOVCRE + @nMovCred,
				QLJ_SLDCRE = QLJ_SLDCRE + @nSldCred
			Where R_E_C_N_O_ = @iRecno
			##CHECK_TRANSACTION_COMMIT			
			
			/* --------------------------------------------------------------------------------------------------------------
			Tratamento para o DB2
			-------------------------------------------------------------------------------------------------------------- */
			SELECT @fim_CUR = 0
			Fetch CUR_CTBCUB into @cFilCT2, @cDATA, @cMOEDA, @cTPSald, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @nMovDeb, @nSldDeb, @nMovCred, @nSldCred			   
		end
		close CUR_CTBCUB
		deallocate CUR_CTBCUB
	##ENDFIELDP01
    ##ENDIF_001

	select @OUT_RESULTADO = '1'
end
##ENDIF_999