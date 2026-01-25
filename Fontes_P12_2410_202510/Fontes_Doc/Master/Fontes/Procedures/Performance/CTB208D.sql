##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. ) .And. AliasInDic('QLJ') })
Create Procedure CTB208D_## (     
   @IN_FILIAL Char( 'CVX_FILIAL' ), 
   @IN_DATA   Char( 08 ),
   @IN_MOEDA  Char( 'CT2_MOEDLC' ),
   @IN_TPSALD Char( 'CT2_TPSALD' ),    
   @IN_CONTA  Char( 'CVX_NIV01' ),
   @IN_CUSTO  Char( 'CVX_NIV02' ),
   @IN_ITEM   Char( 'CVX_NIV03' ),
   @IN_CLVL   Char( 'CVX_NIV04' ),   

   ##IF_002({|| CVX->(FieldPos('CVX_NIV05'))>0})
      @IN_NIV05  Char( 'CVX_NIV05' ),
   ##ELSE_002
      @IN_NIV05  Char(01),
   ##ENDIF_002

   ##IF_002({|| CVX->(FieldPos('CVX_NIV06'))>0})
      @IN_NIV06  Char( 'CVX_NIV06' ),
   ##ELSE_002
      @IN_NIV06  Char(01),
   ##ENDIF_002
    
   ##IF_002({|| CVX->(FieldPos('CVX_NIV07'))>0})
      @IN_NIV07  Char( 'CVX_NIV07' ),
   ##ELSE_002
      @IN_NIV07  Char(01),
   ##ENDIF_002

   ##IF_002({|| CVX->(FieldPos('CVX_NIV08'))>0})
      @IN_NIV08  Char( 'CVX_NIV08' ),
   ##ELSE_002
      @IN_NIV08  Char(01),
   ##ENDIF_002

   ##IF_002({|| CVX->(FieldPos('CVX_NIV09'))>0})
      @IN_NIV09  Char( 'CVX_NIV09' ),
   ##ELSE_002
      @IN_NIV09  Char(01),
   ##ENDIF_002
   
   @IN_CUBO   Char( 'CVX_CONFIG' ),
   @IN_VALORD float,
   @IN_VALORC float,
   @IN_TRANSACTION char(01),    
   @OUT_RESULTADO   Char(01) OutPut
)
as
/* ------------------------------------------------------------------------------------
    Versao          - <v> Protheus P12 </v>    
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Reprocessa os saldos diarios dos cubos CVX e CVY </d>
    Fonte Microsiga - <s> CTBA190.PRW </s>
    Entrada         - <ri>    @IN_FILIAL  - Filial de Processamento
                              @IN_DATA    - Data de Processamento
                              @IN_MOEDA   - Moeda de processamento
                              @IN_TPSALD  - Tipo de saldo
                              @IN_CONTA   - Conta 
                              @IN_CUSTO   - Centro de custo
                              @IN_ITEM    - Item Contabil
                              @IN_CLVL    - Classe de Valor
                              @IN_NIV05   - Entidade 05
                              @IN_NIV06   - Entidade 06
                              @IN_NIV07   - Entidade 07
                              @IN_NIV08   - Entidade 08
                              @IN_NIV09   - Entidade 09
                              @IN_CUBO    - CVX_CONFIG - Entidade que sera atualizada
                              @IN_VALORD  - Valor a debito
                              @IN_VALORC  - Valor a Credito
                              @IN_TRANSACTION - '1' se for chamado dentro de transacao   </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Data        :     08/11/2023
-------------------------------------------------------------------------------------- */
Declare @iRecno integer
Declare @iRecnoCVY integer
Declare @nValDeb  float
Declare @nValCrd  float
Declare @cConfig  Char( 'CVX_CONFIG' )
Declare @cFilial_CVX Char( 'CT2_FILIAL' )
Declare @cFilial_CVY Char( 'CT2_FILIAL' )
Declare @cNiv01   Char('CVX_NIV01')
Declare @cNiv02   Char('CVX_NIV02')
Declare @cNiv03   Char('CVX_NIV03')
Declare @cNiv04   Char('CVX_NIV04')

##IF_002({|| CVX->(FieldPos('CVX_NIV05'))>0})
   Declare @cNiv05   Char('CVX_NIV05')
##ELSE_002
   Declare @cNiv05   Char(01)
##ENDIF_002

##IF_002({|| CVX->(FieldPos('CVX_NIV06'))>0})
   Declare @cNiv06   Char('CVX_NIV06')
##ELSE_002
   Declare @cNiv06   Char(01)
##ENDIF_002

##IF_002({|| CVX->(FieldPos('CVX_NIV08'))>0})
   Declare @cNiv08   Char('CVX_NIV08')
##ELSE_002
   Declare @cNiv08   Char(01)
##ENDIF_002

##IF_002({|| CVX->(FieldPos('CVX_NIV09'))>0})
   Declare @cNiv09   Char('CVX_NIV09')
##ELSE_002
   Declare @cNiv09   Char(01)
##ENDIF_002

begin
   
   /*--------------------------------------------------------------------
      Atualizacao do CVX
     -------------------------------------------------------------------- */   
   select @OUT_RESULTADO = '0'
   select @cConfig = @IN_CUBO 
   exec XFILIAL_## 'CVX', @IN_FILIAL, @cFilial_CVX OutPut
   exec XFILIAL_## 'CVY', @IN_FILIAL, @cFilial_CVY OutPut  

   select @iRecno = 0
   Select @iRecno = IsNull(Max(R_E_C_N_O_), 0)
      From CVX###
      where CVX_FILIAL = @cFilial_CVX
      and CVX_CONFIG = @cConfig
      and CVX_MOEDA  = @IN_MOEDA
      and CVX_TPSALD = @IN_TPSALD
      and CVX_DATA   = @IN_DATA
      and CVX_NIV01  = @IN_CONTA
      and CVX_NIV02  = @IN_CUSTO
      and CVX_NIV03  = @IN_ITEM
      and CVX_NIV04  = @IN_CLVL      

      ##IF_002({|| CVX->(FieldPos('CVX_NIV05'))>0})
         and CVX_NIV05  = @IN_NIV05
      ##ENDIF_002

      ##IF_002({|| CVX->(FieldPos('CVX_NIV06'))>0})
         and CVX_NIV06  = @IN_NIV06
      ##ENDIF_002
      
      ##IF_002({|| CVX->(FieldPos('CVX_NIV07'))>0})
         and CVX_NIV07  = @IN_NIV07
      ##ENDIF_002
      
      ##IF_002({|| CVX->(FieldPos('CVX_NIV08'))>0})
         and CVX_NIV08  = @IN_NIV08
      ##ENDIF_002
      
      ##IF_002({|| CVX->(FieldPos('CVX_NIV09'))>0})
         and CVX_NIV09  = @IN_NIV09
      ##ENDIF_002
      
      and D_E_L_E_T_ = ' '
   
   If @iRecno is null or @iRecno = 0 begin
      select @iRecno = 0
      select @iRecno = IsNull(max(R_E_C_N_O_), 0 ) from CVX###
      select @iRecno = @iRecno + 1
      
      ##TRATARECNO @iRecno\
      ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
      insert into CVX### ( CVX_FILIAL,   CVX_CONFIG, CVX_MOEDA, CVX_DATA,  CVX_TPSALD, CVX_SLDCRD, CVX_SLDDEB, CVX_NIV01, CVX_NIV02, CVX_NIV03, CVX_NIV04,
                           ##FIELDP02( 'CVX.CVX_NIV05' )
                              CVX_NIV05,    
                           ##ENDFIELDP02

                           ##FIELDP02( 'CVX.CVX_NIV06' )
                              CVX_NIV06,    
                           ##ENDFIELDP02

                           ##FIELDP02( 'CVX.CVX_NIV07' )
                              CVX_NIV07,    
                           ##ENDFIELDP02

                           ##FIELDP02( 'CVX.CVX_NIV08' )
                              CVX_NIV08,    
                           ##ENDFIELDP02

                           ##FIELDP02( 'CVX.CVX_NIV09' )
                              CVX_NIV09,    
                           ##ENDFIELDP02

                           R_E_C_N_O_  )
                  values ( @cFilial_CVX, @cConfig,   @IN_MOEDA, @IN_DATA,  @IN_TPSALD, @IN_VALORC,   @IN_VALORD,   @IN_CONTA, @IN_CUSTO, @IN_ITEM,  @IN_CLVL,
                           ##FIELDP02( 'CVX.CVX_NIV05' )
                              @IN_NIV05,    
                           ##ENDFIELDP02

                           ##FIELDP02( 'CVX.CVX_NIV06' )
                              @IN_NIV06,    
                           ##ENDFIELDP02

                           ##FIELDP02( 'CVX.CVX_NIV07' )
                              @IN_NIV07,    
                           ##ENDFIELDP02

                           ##FIELDP02( 'CVX.CVX_NIV08' )
                              @IN_NIV08,    
                           ##ENDFIELDP02

                           ##FIELDP02( 'CVX.CVX_NIV09' )
                              @IN_NIV09,    
                           ##ENDFIELDP02                          

                           @iRecno )
      ##CHECK_TRANSACTION_COMMIT
      ##FIMTRATARECNO
   end else begin
      ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
      Update CVX###
         Set CVX_SLDDEB = CVX_SLDDEB + @IN_VALORD, CVX_SLDCRD = CVX_SLDCRD + @IN_VALORC
         Where R_E_C_N_O_ = @iRecno
      ##CHECK_TRANSACTION_COMMIT
   End
   
   select @OUT_RESULTADO = '1'   
End
##ENDIF_001
