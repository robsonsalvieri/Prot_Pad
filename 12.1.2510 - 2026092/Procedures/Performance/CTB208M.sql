##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. ) .And. AliasInDic('QLJ')})
Create Procedure CTB208M_## (     
   @IN_FILIAL Char( 'CVX_FILIAL' ), 
   @IN_DATA   Char( 06 ),
   @IN_MOEDA  Char( 'CVX_MOEDA' ),
   @IN_TPSALD Char( 'CVX_TPSALD' ),    
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

   @IN_CONFIG  Char('CVX_CONFIG'), 
   @IN_TRANSACTION  Char(01),    
   @OUT_RESULTADO   Char(01) OutPut
)
as
/* ------------------------------------------------------------------------------------
    Versao          - <v> Protheus P12 </v>    
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Reprocessa os saldos Mensais dos cubos CVX e CVY </d>
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
                              @IN_CONFIG  - CVX_CONFIG - Entidade que sera atualizada                              
                              @IN_TRANSACTION - '1' se for chamado dentro de transacao   </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Data        :     08/11/2023
-------------------------------------------------------------------------------------- */
Declare @iRecnoCVX integer
Declare @iRecno integer
Declare @nValDeb  float
Declare @nValCrd  float
Declare @cConfig  Char( 'CVX_CONFIG' )
Declare @cDataI   Char( 08 )
Declare @cDataF   Char( 08 )
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

##IF_002({|| CVX->(FieldPos('CVX_NIV07'))>0})
   Declare @cNiv07   Char('CVX_NIV07')
##ELSE_002
   Declare @cNiv07   Char(01)
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
      Atualizacao do CVY
     -------------------------------------------------------------------- */
   select @OUT_RESULTADO = '0'
   select @cConfig = @IN_CONFIG
   select @cDataI = @IN_DATA||'01'       
   exec LASTDAY_## @cDataI, @cDataF output  
   exec XFILIAL_## 'CVX', @IN_FILIAL, @cFilial_CVX OutPut
   exec XFILIAL_## 'CVY', @IN_FILIAL, @cFilial_CVY OutPut    
   
   select @iRecno = 0
   select @nValDeb = 0
   select @nValCrd = 0

   Declare CUR_CVXTMP insensitive cursor for
      Select CVX_NIV01, CVX_NIV02, CVX_NIV03, CVX_NIV04
         
         ##IF_002({|| CVX->(FieldPos('CVX_NIV05'))>0})
            ,CVX_NIV05
         ##ENDIF_002
         
         ##IF_002({|| CVX->(FieldPos('CVX_NIV06'))>0})
            ,CVX_NIV06
         ##ENDIF_002
         
         ##IF_002({|| CVX->(FieldPos('CVX_NIV07'))>0})
            ,CVX_NIV07
         ##ENDIF_002

         ##IF_002({|| CVX->(FieldPos('CVX_NIV08'))>0})
            ,CVX_NIV08 
         ##ENDIF_002

         ##IF_002({|| CVX->(FieldPos('CVX_NIV09'))>0})
            ,CVX_NIV09
         ##ENDIF_002
         
         ,SUM(CVX_SLDDEB), SUM(CVX_SLDCRD)

         From CVX###
         where CVX_FILIAL = @cFilial_CVX
         and CVX_CONFIG = @cConfig
         and CVX_TPSALD = @IN_TPSALD
         and CVX_MOEDA  = @IN_MOEDA 
         and CVX_DATA between @cDataI and @cDataF
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
      Group by CVX_NIV01, CVX_NIV02, CVX_NIV03, CVX_NIV04

               ##IF_002({|| CVX->(FieldPos('CVX_NIV05'))>0})
                  ,CVX_NIV05
               ##ENDIF_002

               ##IF_002({|| CVX->(FieldPos('CVX_NIV06'))>0})
                  ,CVX_NIV06
               ##ENDIF_002

               ##IF_002({|| CVX->(FieldPos('CVX_NIV07'))>0})
                  ,CVX_NIV07
               ##ENDIF_002

               ##IF_002({|| CVX->(FieldPos('CVX_NIV08'))>0})
                  ,CVX_NIV08 
               ##ENDIF_002

               ##IF_002({|| CVX->(FieldPos('CVX_NIV09'))>0})
                  ,CVX_NIV09
               ##ENDIF_002

      Order by CVX_NIV01, CVX_NIV02, CVX_NIV03, CVX_NIV04
               
               ##IF_005({|| CVX->(FieldPos('CVX_NIV05'))>0})
                  ,CVX_NIV05
               ##ENDIF_005

               ##IF_006({|| CVX->(FieldPos('CVX_NIV06'))>0})
                  ,CVX_NIV06
               ##ENDIF_006

               ##IF_007({|| CVX->(FieldPos('CVX_NIV07'))>0})
                  ,CVX_NIV07
               ##ENDIF_007

               ##IF_008({|| CVX->(FieldPos('CVX_NIV08'))>0})
                  ,CVX_NIV08 
               ##ENDIF_008

               ##IF_009({|| CVX->(FieldPos('CVX_NIV09'))>0})
                  ,CVX_NIV09
               ##ENDIF_009

   for read only
   Open CUR_CVXTMP
   Fetch CUR_CVXTMP into @cNiv01, @cNiv02, @cNiv03, @cNiv04

                           ##IF_015({|| CVX->(FieldPos('CVX_NIV05'))>0})
                              , @cNiv05
                           ##ENDIF_015
                           
                           ##IF_016({|| CVX->(FieldPos('CVX_NIV06'))>0})
                              , @cNiv06
                           ##ENDIF_016
                           
                           ##IF_017({|| CVX->(FieldPos('CVX_NIV07'))>0})
                              , @cNiv07
                           ##ENDIF_017

                           ##IF_018({|| CVX->(FieldPos('CVX_NIV08'))>0})
                              , @cNiv08
                           ##ENDIF_018

                           ##IF_019({|| CVX->(FieldPos('CVX_NIV09'))>0})
                              , @cNiv09
                           ##ENDIF_019
                        
                        , @nValDeb, @nValCrd
   
   While (@@Fetch_status = 0 ) begin

      Select @iRecno = IsNull(Max(R_E_C_N_O_), 0)
         From CVY###
         where CVY_FILIAL = @cFilial_CVY
         and CVY_CONFIG = @cConfig
         and CVY_MOEDA  = @IN_MOEDA
         and CVY_TPSALD = @IN_TPSALD
         and CVY_DATA   = @cDataF
         and CVY_NIV01  = @IN_CONTA
         and CVY_NIV02  = @IN_CUSTO
         and CVY_NIV03  = @IN_ITEM
         and CVY_NIV04  = @IN_CLVL
         
         ##IF_002({|| CVY->(FieldPos('CVY_NIV05'))>0})
            and CVY_NIV05  = @IN_NIV05
         ##ENDIF_002

         ##IF_002({|| CVY->(FieldPos('CVY_NIV06'))>0})
            and CVY_NIV06  = @IN_NIV06
         ##ENDIF_002
         
         ##IF_002({|| CVY->(FieldPos('CVY_NIV07'))>0})
            and CVY_NIV07  = @IN_NIV07
         ##ENDIF_002

         ##IF_002({|| CVY->(FieldPos('CVY_NIV08'))>0})
            and CVY_NIV08  = @IN_NIV08
         ##ENDIF_002

         ##IF_002({|| CVY->(FieldPos('CVY_NIV09'))>0})
            and CVY_NIV09  = @IN_NIV09
         ##ENDIF_002

         and D_E_L_E_T_ = ' '
         
      If @iRecno is null or @iRecno = 0 begin
         select @iRecno = 0
         select @iRecno = IsNull(max(R_E_C_N_O_), 0 ) from CVY###
         select @iRecno = @iRecno + 1
         
         ##TRATARECNO @iRecno\
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         insert into CVY### ( CVY_FILIAL,   CVY_CONFIG, CVY_MOEDA, CVY_DATA,  CVY_TPSALD, CVY_SLDCRD, CVY_SLDDEB, CVY_NIV01, CVY_NIV02, CVY_NIV03, CVY_NIV04
                              
                              ##IF_002({|| CVY->(FieldPos('CVY_NIV05'))>0})
                                 , CVY_NIV05
                              ##ENDIF_002

                              ##IF_002({|| CVY->(FieldPos('CVY_NIV06'))>0})
                                 , CVY_NIV06
                              ##ENDIF_002
                              
                              ##IF_002({|| CVY->(FieldPos('CVY_NIV07'))>0})
                                 , CVY_NIV07
                              ##ENDIF_002

                              ##IF_002({|| CVY->(FieldPos('CVY_NIV08'))>0})
                                 , CVY_NIV08
                              ##ENDIF_002

                              ##IF_002({|| CVY->(FieldPos('CVY_NIV09'))>0})
                                 , CVY_NIV09
                              ##ENDIF_002
                              
                              ,  R_E_C_N_O_ )

                     values ( @cFilial_CVY, @cConfig,   @IN_MOEDA, @cDataF,   @IN_TPSALD, @nValCrd,   @nValDeb,   @IN_CONTA, @IN_CUSTO, @IN_ITEM,  @IN_CLVL                              

                              ##IF_002({|| CVY->(FieldPos('CVY_NIV05'))>0})
                                 , @IN_NIV05
                              ##ENDIF_002

                              ##IF_002({|| CVY->(FieldPos('CVY_NIV06'))>0})
                                 , @IN_NIV06
                              ##ENDIF_002
                              
                              ##IF_002({|| CVY->(FieldPos('CVY_NIV07'))>0})
                                 , @IN_NIV07
                              ##ENDIF_002

                              ##IF_002({|| CVY->(FieldPos('CVY_NIV08'))>0})
                                 , @IN_NIV08
                              ##ENDIF_002

                              ##IF_002({|| CVY->(FieldPos('CVY_NIV09'))>0})
                                 , @IN_NIV09
                              ##ENDIF_002
                              
                              , @iRecno )
         ##CHECK_TRANSACTION_COMMIT
         ##FIMTRATARECNO
      End
      
      SELECT @fim_CUR = 0
      Fetch CUR_CVXTMP into @cNiv01, @cNiv02, @cNiv03, @cNiv04                            

                              ##IF_002({|| CVX->(FieldPos('CVX_NIV05'))>0})
                                 , @cNiv05
                              ##ENDIF_002

                              ##IF_002({|| CVX->(FieldPos('CVX_NIV06'))>0})
                                 , @cNiv06
                              ##ENDIF_002
                              
                              ##IF_002({|| CVX->(FieldPos('CVX_NIV07'))>0})
                                 , @cNiv07
                              ##ENDIF_002

                              ##IF_002({|| CVX->(FieldPos('CVX_NIV08'))>0})
                                 , @cNiv08
                              ##ENDIF_002

                              ##IF_002({|| CVX->(FieldPos('CVX_NIV09'))>0})
                                 , @cNiv09
                              ##ENDIF_002
                              
                              , @nValDeb, @nValCrd
   end
   close CUR_CVXTMP
   deallocate CUR_CVXTMP

   select @OUT_RESULTADO = '1'
End
##ENDIF_001
