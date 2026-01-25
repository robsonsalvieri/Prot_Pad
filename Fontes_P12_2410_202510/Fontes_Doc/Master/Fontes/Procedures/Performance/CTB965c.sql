##IF_998({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
##IF_001({|| lNiv05 := CT2->(FieldPos('CT2_EC05DB'))>0})
##ENDIF_001
##IF_001({|| lNiv06 := CT2->(FieldPos('CT2_EC06DB'))>0})
##ENDIF_001
##IF_001({|| lNiv07 := CT2->(FieldPos('CT2_EC07DB'))>0})
##ENDIF_001
##IF_001({|| lNiv08 := CT2->(FieldPos('CT2_EC08DB'))>0})
##ENDIF_001
##IF_001({|| lNiv09 := CT2->(FieldPos('CT2_EC09DB'))>0})
##ENDIF_001

##IF_999({|| AliasInDic('QLJ') })
Create procedure CTB965C_## 
 ( 
  @IN_FILCT0       Char('CT0_FILIAL'),
  @IN_DATADE       Char(08),
  @IN_DATAATE      Char(08),
  @IN_LMOEDAESP    Char(01),
  @IN_MOEDA        Char('CT2_MOEDLC'),
  @IN_TPSALDO      Char('CT2_TPSALD'),
  @IN_UUID         Char(36),
  @IN_LMULTIFIL    Char(01),
  @IN_TRANSACTION  Char(01),
  @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versao          - <v> Protheus P12 </v>    
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Zera os arquivos a serem posteriormente reprocessados </d>
    Fonte Microsiga - <s> CTBA190.PRW </s>
    Entrada         - <ri> @IN_DATADE       - Data inicio para correcao
                           @IN_DATAATE      - Data final para correcao
                           @IN_LMOEDAESP    - Data final para correcao
                           @IN_MOEDA        - Moeda especifica
                           @IN_TPSALDO      - Tipo de saldo                           
                           @IN_UUID         - Chave para pesquisa na tabela TRZ
                           @IN_TRANSACTION  - '1' se em transacao - '0' -fora de transacao  </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Data        :     08/11/2023
-------------------------------------------------------------------------------------- */
declare @nRecno     Integer
declare @fim_CUR    Integer
declare @nSaldo     Float
declare @nValCur    Float
declare @cTipo      Char(1)
declare @cFilCur    Char('CVX_FILIAL')
declare @cDatCur    Char(08)
declare @cDatMes    Char(08)
declare @cModCur    Char('CVX_MOEDA')
declare @cTpSldCur  Char('CVX_TPSALD')
declare @cNIV01     Char('CVX_NIV01')
declare @cNIV02     Char('CVX_NIV02')
declare @cNIV03     Char('CVX_NIV03')
declare @cNIV04     Char('CVX_NIV04')
##IF_005({|| lNiv05})
    declare @cNIV05 Char('CVX_NIV05')
##ELSE_005
    declare @cNIV05 Char(01)
##ENDIF_005
##IF_006({|| lNiv06})
    declare @cNIV06 Char('CVX_NIV06')
##ELSE_006
    declare @cNIV06 Char(01)
##ENDIF_006
##IF_007({|| lNiv07})
    declare @cNIV07 Char('CVX_NIV07')
##ELSE_007
    declare @cNIV07 Char(01)
##ENDIF_007    
##IF_008({|| lNiv08})
    declare @cNIV08 Char('CVX_NIV08')
##ELSE_008
    declare @cNIV08 Char(01)
##ENDIF_008
##IF_009({|| lNiv09})    
    declare @cNIV09 Char('CVX_NIV09')
##ELSE_009
    declare @cNIV09 Char(01)
##ENDIF_009
declare @cLP        Char(1)
declare @cConfig    Char(2)

begin  
    select @OUT_RESULTADO = '0'
    
    Select @cConfig = IsNull(Max(CT0_ID),' ') From CT0### Where CT0_FILIAL = @IN_FILCT0 and D_E_L_E_T_ = ' '   

    /*---------------------------------------------------------------
        Apaga registros CQ1 sem movimento na CT2
    ----------------------------------------------------------------*/
    Declare CUR_CVXDEL insensitive cursor for
    SELECT 
        CVX_FILIAL, CVX_DATA, ROUND(CVX_SLDDEB,2), CVX_NIV01, CVX_NIV02, CVX_NIV03, CVX_NIV04, 
        
        ##IF_006({|| lNiv05})
            CVX_NIV05, 
        ##ELSE_006
            ' ' CVX_NIV05,
        ##ENDIF_006
        
        ##IF_007({|| lNiv06})
            CVX_NIV06,
        ##ELSE_007
            ' ' CVX_NIV06, 
        ##ENDIF_007
        
        ##IF_008({|| lNiv07})
            CVX_NIV07, 
        ##ELSE_008
            ' ' CVX_NIV07,
        ##ENDIF_008
        
        ##IF_009({|| lNiv08})
            CVX_NIV08, 
        ##ELSE_009
            ' ' CVX_NIV08,
        ##ENDIF_009
        
        ##IF_010({|| lNiv09})
            CVX_NIV09, 
        ##ELSE_010
            ' ' CVX_NIV09,
        ##ENDIF_010
        
        CVX_MOEDA, CVX_TPSALD, CVX.R_E_C_N_O_, '1' AS TIPO
        FROM 
            CVX### CVX
            LEFT JOIN 
                CT2### CT2
                ON
                    CT2_FILIAL = CVX_FILIAL AND
                    CT2_DATA   = CVX_DATA AND
                    CT2_DEBITO = CVX_NIV01 AND
                    CT2_CCD	   = CVX_NIV02 AND
                    CT2_ITEMD  = CVX_NIV03 AND
                    CT2_CLVLDB = CVX_NIV04 AND
                    ##IF_012({|| lNiv05})
                        CT2_EC05DB = CVX_NIV05 AND
                    ##ENDIF_012
                    ##IF_013({|| lNiv06})
                        CT2_EC06DB = CVX_NIV06 AND
                    ##ENDIF_013
                    ##IF_014({|| lNiv07})
                        CT2_EC07DB = CVX_NIV07 AND
                    ##ENDIF_014
                    ##IF_015({|| lNiv08})
                        CT2_EC08DB = CVX_NIV08 AND
                    ##ENDIF_015
                    ##IF_016({|| lNiv09})
                        CT2_EC09DB = CVX_NIV09 AND
                    ##ENDIF_016
                    CT2_MOEDLC = CVX_MOEDA AND 
                    CT2_TPSALD = CVX_TPSALD AND
                    CT2.D_E_L_E_T_ = ' '
            WHERE 
            ((@IN_LMULTIFIL = '0' AND CVX_FILIAL = @IN_FILCT0) OR (CVX_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND
            CVX_DATA BETWEEN @IN_DATADE and @IN_DATAATE AND            
            CVX_SLDDEB <> 0 AND
            ((CVX_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
            ((@IN_TPSALDO = '*' AND CVX_TPSALD <> '9') OR CVX_TPSALD = @IN_TPSALDO) AND            
            CVX_CONFIG = @cConfig AND
            CT2_FILIAL IS NULL AND
            CVX.D_E_L_E_T_ = ' ' 
   UNION
   SELECT 
        CVX_FILIAL, CVX_DATA, ROUND(CVX_SLDCRD,2), CVX_NIV01, CVX_NIV02, CVX_NIV03, CVX_NIV04, 
        
        ##IF_017({|| lNiv05})
            CVX_NIV05,
        ##ELSE_017
            ' ' CVX_NIV05, 
        ##ENDIF_017
        
        ##IF_018({|| lNiv06})
            CVX_NIV06,
        ##ELSE_018
            ' ' CVX_NIV06, 
        ##ENDIF_018
        
        ##IF_019({|| lNiv07})
            CVX_NIV07,         
        ##ELSE_019
            ' ' CVX_NIV07,
        ##ENDIF_019
        
        ##IF_020({|| lNiv08})
            CVX_NIV08, 
        ##ELSE_020
            ' ' CVX_NIV08,
        ##ENDIF_020
        
        ##IF_021({|| lNiv09})
            CVX_NIV09, 
        ##ELSE_021
            ' ' CVX_NIV09,
        ##ENDIF_021
        
        CVX_MOEDA, CVX_TPSALD, CVX.R_E_C_N_O_, '2' AS TIPO
        FROM 
            CVX### CVX
            LEFT JOIN 
                CT2### CT2
                ON
                    CT2_FILIAL = CVX_FILIAL AND
                    CT2_DATA   = CVX_DATA AND
                    CT2_CREDIT = CVX_NIV01 AND
                    CT2_CCC    = CVX_NIV02 AND
                    CT2_ITEMC  = CVX_NIV03 AND
                    CT2_CLVLCR = CVX_NIV04 AND
                    ##IF_022({|| lNiv05})
                        CT2_EC05CR = CVX_NIV05 AND
                    ##ENDIF_022
                    ##IF_023({|| lNiv06})
                        CT2_EC06CR = CVX_NIV06 AND
                    ##ENDIF_023
                    ##IF_024({|| lNiv07})
                        CT2_EC07CR = CVX_NIV07 AND
                    ##ENDIF_024
                    ##IF_025({|| lNiv08})
                        CT2_EC08CR = CVX_NIV08 AND
                    ##ENDIF_025
                    ##IF_026({|| lNiv09})
                        CT2_EC09CR = CVX_NIV09 AND
                    ##ENDIF_026
                    CT2_MOEDLC = CVX_MOEDA AND
                    CT2_TPSALD = CVX_TPSALD AND
                    CT2.D_E_L_E_T_ = ' '
            WHERE 
            ((@IN_LMULTIFIL = '0' AND CVX_FILIAL = @IN_FILCT0) OR (CVX_FILIAL IN(SELECT TRZ_FILIAL FROM TRZ###_SP WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = @IN_UUID))) AND            
            CVX_DATA BETWEEN @IN_DATADE and @IN_DATAATE AND            
            CVX_SLDCRD <> 0 AND
            ((CVX_MOEDA = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0') AND
            ((@IN_TPSALDO = '*' AND CVX_TPSALD <> '9') OR CVX_TPSALD = @IN_TPSALDO) AND            
            CVX_CONFIG = @cConfig AND
            CT2_FILIAL IS NULL AND
            CVX.D_E_L_E_T_ = ' '   
   Order by 1, 2, 3, 4, 5, 6       
   for read only
   Open CUR_CVXDEL
   Fetch CUR_CVXDEL into @cFilCur, @cDatCur, @nValCur, @cNIV01, @cNIV02, @cNIV03, @cNIV04, @cNIV05, @cNIV06, @cNIV07, @cNIV08, @cNIV09, @cModCur, @cTpSldCur, @nRecno, @cTipo

    While (@@Fetch_status = 0 ) begin
        
        exec CTB965D_## @cFilCur, @cDatCur, @cModCur, @cTpSldCur, @cTipo, @nRecno, @nValCur, '01', @cNIV01, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', @IN_TRANSACTION, @OUT_RESULTADO OutPut
        exec CTB965D_## @cFilCur, @cDatCur, @cModCur, @cTpSldCur, @cTipo, @nRecno, @nValCur, '02', @cNIV01, @cNIV02, ' ', ' ', ' ', ' ', ' ', ' ', ' ', @IN_TRANSACTION, @OUT_RESULTADO OutPut
        exec CTB965D_## @cFilCur, @cDatCur, @cModCur, @cTpSldCur, @cTipo, @nRecno, @nValCur, '03', @cNIV01, @cNIV02, @cNIV03, ' ', ' ', ' ', ' ', ' ', ' ', @IN_TRANSACTION, @OUT_RESULTADO OutPut
        exec CTB965D_## @cFilCur, @cDatCur, @cModCur, @cTpSldCur, @cTipo, @nRecno, @nValCur, '04', @cNIV01, @cNIV02, @cNIV03, @cNIV04, ' ', ' ', ' ', ' ', ' ', @IN_TRANSACTION, @OUT_RESULTADO OutPut
        
        If @cConfig > '04' Begin
            exec CTB965D_## @cFilCur, @cDatCur, @cModCur, @cTpSldCur, @cTipo, @nRecno, @nValCur, '05', @cNIV01, @cNIV02, @cNIV03, @cNIV04, @cNIV05, ' ', ' ', ' ', ' ', @IN_TRANSACTION, @OUT_RESULTADO OutPut
        End

        If @cConfig > '05' Begin
            exec CTB965D_## @cFilCur, @cDatCur, @cModCur, @cTpSldCur, @cTipo, @nRecno, @nValCur, '06', @cNIV01, @cNIV02, @cNIV03, @cNIV04, @cNIV05, @cNIV06, ' ', ' ', ' ', @IN_TRANSACTION, @OUT_RESULTADO OutPut
        End
        
        If @cConfig > '06' Begin
            exec CTB965D_## @cFilCur, @cDatCur, @cModCur, @cTpSldCur, @cTipo, @nRecno, @nValCur, '07', @cNIV01, @cNIV02, @cNIV03, @cNIV04, @cNIV05, @cNIV06, @cNIV07, ' ', ' ', @IN_TRANSACTION, @OUT_RESULTADO OutPut
        End
        
        If @cConfig > '07' Begin
            exec CTB965D_## @cFilCur, @cDatCur, @cModCur, @cTpSldCur, @cTipo, @nRecno, @nValCur, '08', @cNIV01, @cNIV02, @cNIV03, @cNIV04, @cNIV05, @cNIV06, @cNIV07, @cNIV08, ' ', @IN_TRANSACTION, @OUT_RESULTADO OutPut
        End
        
        If @cConfig > '08' Begin
            exec CTB965D_## @cFilCur, @cDatCur, @cModCur, @cTpSldCur, @cTipo, @nRecno, @nValCur, '09', @cNIV01, @cNIV02, @cNIV03, @cNIV04, @cNIV05, @cNIV06, @cNIV07, @cNIV08, @cNIV09, @IN_TRANSACTION, @OUT_RESULTADO OutPut
        End
      
        /*Tratamento para Postgres*/
        SELECT @fim_CUR = 0
        Fetch CUR_CVXDEL into @cFilCur, @cDatCur, @nValCur, @cNIV01, @cNIV02, @cNIV03, @cNIV04, @cNIV05, @cNIV06, @cNIV07, @cNIV08, @cNIV09, @cModCur, @cTpSldCur, @nRecno, @cTipo
    end
    close CUR_CVXDEL
    deallocate CUR_CVXDEL

    select @OUT_RESULTADO = '1'
end
##ENDIF_999
##ENDIF_998