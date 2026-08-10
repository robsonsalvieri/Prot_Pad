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
Create procedure CTB965D_## 
 ( 
    @IN_FILIAL      Char('CT2_FILIAL'),
    @IN_DATA        Char(08),
    @IN_MOEDA       Char('CT2_MOEDLC'),  
    @IN_TPSALDO     Char('CT2_TPSALD'),
    @IN_TIPO        Char(01),
    @IN_RECNO       Float,
    @IN_VALOR       Float,
    @IN_CONFIG      Char('CVX_CONFIG'),
    @IN_NIV01       Char('CVX_NIV01'),
    @IN_NIV02       Char('CVX_NIV02'),
    @IN_NIV03       Char('CVX_NIV03'),
    @IN_NIV04       Char('CVX_NIV04'),
    ##IF_005({|| lNiv05})
        @IN_NIV05   Char('CVX_NIV05'),
    ##ELSE_005
        @IN_NIV05   Char(01),
    ##ENDIF_005
    ##IF_006({|| lNiv06})    
        @IN_NIV06   Char('CVX_NIV06'),
    ##ELSE_006
        @IN_NIV06   Char(01),
    ##ENDIF_006
    ##IF_007({|| lNiv07})    
        @IN_NIV07   Char('CVX_NIV07'),
    ##ELSE_007
        @IN_NIV07   Char(01),
    ##ENDIF_007
    ##IF_008({|| lNiv08})    
        @IN_NIV08   Char('CVX_NIV08'),
    ##ELSE_008
        @IN_NIV08   Char(01),
    ##ENDIF_008
    ##IF_009({|| lNiv09})    
        @IN_NIV09   Char('CVX_NIV09'),
    ##ELSE_009
        @IN_NIV09   Char(01),
    ##ENDIF_009
    @IN_TRANSACTION Char(01),
    @OUT_RESULTADO  Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Vers�o          - <v> Protheus P12 </v>    
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Zera os arquivos a serem posteriormente reprocessados </d>
    Fonte Microsiga - <s> CTBA190.PRW </s>
    Entrada         - <ri>  @IN_FILIAL       - Filial a ser processada
                            @IN_DATA         - Data de referencia
                            @IN_MOEDA        - Moeda 
                            @IN_TPSALDO      - Tipo de Saldo
                            @IN_TIPO         - 1 = Debito, 2 = Cr�dito
                            @IN_VALOR        - Valor encontrado como diverg�ncia
                            @IN_CONFIG       - Indica o c�digo da entidade adicional
                            @IN_NIV01        - Entidade 01
                            @IN_NIV02        - Entidade 02
                            @IN_NIV03        - Entidade 03
                            @IN_NIV04        - Entidade 04
                            @IN_NIV05        - Entidade 05
                            @IN_NIV06        - Entidade 06
                            @IN_NIV07        - Entidade 07
                            @IN_NIV08        - Entidade 08
                            @IN_NIV09        - Entidade 09
                            @IN_TRANSACTION  - Indica se est� em trasa��o </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Data        :     08/11/2023
-------------------------------------------------------------------------------------- */
declare @lControla    Char(01)
declare @cFilial_CT0  Char('CT0_FILIAL')
declare @cDatMes      Char(08)
declare @nSaldo       Float
declare @nRecno       Integer

Begin
    select @OUT_RESULTADO = '0'
    
    exec XFILIAL_## 'CT0', @IN_FILIAL, @cFilial_CT0 OutPut
    exec LASTDAY_## @IN_DATA, @cDatMes OutPut

    select @lControla = CT0_CONTR From CT0### where CT0_FILIAL = @cFilial_CT0 and CT0_ID = @IN_CONFIG and D_E_L_E_T_ = ' '
    
    If @lControla = '1' begin
        If @IN_TIPO = '1' begin             
            Select @nSaldo = 0
            Select @nRecno = 0
            
            SELECT @nSaldo = ((CVX_SLDDEB+CVX_SLDCRD) - @IN_VALOR), @nRecno = R_E_C_N_O_
            FROM CVX### 
            WHERE CVX_FILIAL = @IN_FILIAL AND 
                CVX_DATA     = @IN_DATA AND 
                CVX_MOEDA    = @IN_MOEDA AND 
                CVX_CONFIG   = @IN_CONFIG AND 
                CVX_NIV01    = @IN_NIV01 AND 
                CVX_NIV02    = @IN_NIV02 AND 
                CVX_NIV03    = @IN_NIV03 AND 
                CVX_NIV04    = @IN_NIV04 AND 
                ##IF_001({|| lNiv05})
                    CVX_NIV05 = @IN_NIV05 AND 
                ##ENDIF_001
                ##IF_001({|| lNiv06})
                    CVX_NIV06 = @IN_NIV06 AND 
                ##ENDIF_001
                ##IF_001({|| lNiv07})
                    CVX_NIV07 = @IN_NIV07 AND 
                ##ENDIF_001
                ##IF_001({|| lNiv08})
                    CVX_NIV08 = @IN_NIV08 AND 
                ##ENDIF_001
                ##IF_001({|| lNiv09})
                    CVX_NIV09 = @IN_NIV09 AND 
                ##ENDIF_001
                CVX_TPSALD = @IN_TPSALDO AND 
                D_E_L_E_T_ = ' '
        
            If @nSaldo > 0 Begin                
                UPDATE CVX### SET CVX_SLDDEB = ROUND(CVX_SLDDEB - @IN_VALOR,2) WHERE R_E_C_N_O_ = @nRecno
            End Else Begin                                
                DELETE FROM CVX### WHERE R_E_C_N_O_ = @nRecno                
            End

            /*Ajusta saldo mensal*/            
            Select @nRecno = 0 
            Select @nSaldo = 0
            
            SELECT @nSaldo = ((CVY_SLDDEB+CVY_SLDCRD) - @IN_VALOR), @nRecno = R_E_C_N_O_ 
                FROM CVY### 
                WHERE CVY_FILIAL = @IN_FILIAL AND 
                    CVY_DATA     = @cDatMes AND 
                    CVY_MOEDA    = @IN_MOEDA AND 
                    CVY_CONFIG   = @IN_CONFIG AND 
                    CVY_NIV01    = @IN_NIV01 AND 
                    CVY_NIV02    = @IN_NIV02 AND 
                    CVY_NIV03    = @IN_NIV03 AND 
                    CVY_NIV04    = @IN_NIV04 AND 
                    ##IF_001({|| lNiv05})
                        CVY_NIV05 = @IN_NIV05 AND 
                    ##ENDIF_001
                    ##IF_001({|| lNiv06})
                        CVY_NIV06 = @IN_NIV06 AND 
                    ##ENDIF_001
                    ##IF_001({|| lNiv07})
                        CVY_NIV07 = @IN_NIV07 AND 
                    ##ENDIF_001
                    ##IF_001({|| lNiv08})
                        CVY_NIV08 = @IN_NIV08 AND 
                    ##ENDIF_001
                    ##IF_001({|| lNiv09})
                        CVY_NIV09 = @IN_NIV09 AND 
                    ##ENDIF_001
                    CVY_TPSALD = @IN_TPSALDO AND 
                    D_E_L_E_T_ = ' '

            If @nSaldo > 0 Begin                
                UPDATE CVY### SET CVY_SLDDEB = ROUND(CVY_SLDDEB - @IN_VALOR,2) WHERE R_E_C_N_O_ = @nRecno
            End Else Begin                                
                DELETE FROM CVY### WHERE R_E_C_N_O_ = @nRecno                
            End
        End else Begin
            Select @nSaldo = 0
            Select @nRecno = 0
            
            SELECT @nSaldo = ((CVX_SLDDEB+CVX_SLDCRD) - @IN_VALOR), @nRecno = R_E_C_N_O_
            FROM CVX### 
            WHERE  CVX_FILIAL = @IN_FILIAL AND 
                CVX_DATA     = @IN_DATA AND 
                CVX_MOEDA    = @IN_MOEDA AND 
                CVX_CONFIG   = @IN_CONFIG AND 
                CVX_NIV01    = @IN_NIV01 AND 
                CVX_NIV02    = @IN_NIV02 AND 
                CVX_NIV03    = @IN_NIV03 AND 
                CVX_NIV04    = @IN_NIV04 AND 
                ##IF_001({|| lNiv05})
                    CVX_NIV05 = @IN_NIV05 AND 
                ##ENDIF_001
                ##IF_001({|| lNiv06})
                    CVX_NIV06 = @IN_NIV06 AND 
                ##ENDIF_001
                ##IF_001({|| lNiv07})
                    CVX_NIV07 = @IN_NIV07 AND 
                ##ENDIF_001
                ##IF_001({|| lNiv08})
                    CVX_NIV08 = @IN_NIV08 AND 
                ##ENDIF_001
                ##IF_001({|| lNiv09})
                    CVX_NIV09 = @IN_NIV09 AND 
                ##ENDIF_001
                CVX_TPSALD = @IN_TPSALDO AND 
                D_E_L_E_T_ = ' '
            
            If @nSaldo > 0 Begin                
                UPDATE CVX### SET CVX_SLDCRD = ROUND(CVX_SLDCRD - @IN_VALOR,2) WHERE R_E_C_N_O_ = @nRecno
            End Else Begin                                
                DELETE FROM CVX### WHERE R_E_C_N_O_ = @nRecno               
            End

            /*Ajusta saldo mensal*/            
            Select @nRecno = 0 
            Select @nSaldo = 0

            SELECT @nSaldo = ((CVY_SLDDEB+CVY_SLDCRD) - @IN_VALOR), @nRecno = R_E_C_N_O_ 
                FROM CVY### 
                WHERE CVY_FILIAL = @IN_FILIAL AND 
                    CVY_DATA     = @cDatMes AND 
                    CVY_MOEDA    = @IN_MOEDA AND 
                    CVY_CONFIG   = @IN_CONFIG AND 
                    CVY_NIV01    = @IN_NIV01 AND 
                    CVY_NIV02    = @IN_NIV02 AND 
                    CVY_NIV03    = @IN_NIV03 AND 
                    CVY_NIV04    = @IN_NIV04 AND 
                    ##IF_001({|| lNiv05})
                        CVY_NIV05 = @IN_NIV05 AND 
                    ##ENDIF_001
                    ##IF_001({|| lNiv06})
                        CVY_NIV06 = @IN_NIV06 AND 
                    ##ENDIF_001
                    ##IF_001({|| lNiv07})
                        CVY_NIV07 = @IN_NIV07 AND 
                    ##ENDIF_001
                    ##IF_001({|| lNiv08})
                        CVY_NIV08 = @IN_NIV08 AND 
                    ##ENDIF_001
                    ##IF_001({|| lNiv09})
                        CVY_NIV09 = @IN_NIV09 AND 
                    ##ENDIF_001
                    CVY_TPSALD = @IN_TPSALDO AND 
                    D_E_L_E_T_ = ' '

            If @nSaldo > 0 Begin                
                UPDATE CVY### SET CVY_SLDCRD = ROUND(CVY_SLDCRD - @IN_VALOR,2) WHERE R_E_C_N_O_ = @nRecno
            End Else Begin                                
                DELETE FROM CVY### WHERE R_E_C_N_O_ = @nRecno                
            End
        End
    End

    select @OUT_RESULTADO = '1'
End
##ENDIF_999
##ENDIF_998