##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. ) .And. AliasInDic('QLJ')})
Create procedure CTB209M_##
(  
   @IN_FILIAL       Char('CVY_FILIAL'),
   @IN_DATA         Char(06),
   @IN_MOEDA        Char('CVY_MOEDA'),
   @IN_TPSALDO      Char('CVY_TPSALD'),   
   @IN_CONTA        Char('CVY_NIV01'),
   @IN_CUSTO        Char('CVY_NIV02'),
   @IN_ITEM         Char('CVY_NIV03'),
   @IN_CLVL         Char('CVY_NIV04'),

   ##IF_002({|| CVY->(FieldPos('CVY_NIV05'))>0})
      @IN_ENT05  Char( 'CVY_NIV05' ),
   ##ELSE_002
      @IN_ENT05  Char(01),
   ##ENDIF_002
   
   ##IF_002({|| CVY->(FieldPos('CVY_NIV06'))>0})
      @IN_ENT06  Char( 'CVY_NIV06' ),
   ##ELSE_002
      @IN_ENT06  Char(01),
   ##ENDIF_002
   
   ##IF_002({|| CVY->(FieldPos('CVY_NIV07'))>0})
      @IN_ENT07  Char( 'CVY_NIV07' ),
   ##ELSE_002
      @IN_ENT07  Char(01),
   ##ENDIF_002

   ##IF_002({|| CVY->(FieldPos('CVY_NIV08'))>0})
      @IN_ENT08  Char( 'CVY_NIV08' ),
   ##ELSE_002
      @IN_ENT08  Char(01),
   ##ENDIF_002

   ##IF_002({|| CVY->(FieldPos('CVY_NIV09'))>0})
      @IN_ENT09  Char( 'CVY_NIV09' ),
   ##ELSE_002
      @IN_ENT09  Char(01),
   ##ENDIF_002

   @IN_CONFIG       Char('CVY_CONFIG'), 
   @IN_TRANSACTION  Char(01),    
   @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versao          - <v> Protheus P12 </v>    
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Zera os saldos Mensais dos cubos CVX e CVY </d>
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
                              @IN_CONFIG  - CVX_CONFIG - Entidade que serao atualizada
                              @IN_TRANSACTION - '1' se for chamado dentro de transacao   </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Data        :     08/11/2023
-------------------------------------------------------------------------------------- */
declare @cFilial_CVY Char('CVY_FILIAL')
Declare @cDataI      Char( 08 )
Declare @cDataMes    Char( 08 )
Declare @iRecnoCVY   integer

begin   
   select @OUT_RESULTADO = '0'
   
   select @iRecnoCVY  = 0
   select @cDataI = @IN_DATA||'01'

   Exec LASTDAY_## @cDataI, @cDataMes OutPut
   
   Exec XFILIAL_## 'CVY', @IN_FILIAL, @cFilial_CVY OutPut

  
   /* ---------------------------------------------------------------------------------
      Exclusao de CVY - Saldos Mensais
      ---------------------------------------------------------------------------------- */
   Declare CUR_CVY insensitive cursor for
   select IsNull( CVY.R_E_C_N_O_, 0 )
     from CVY### CVY, CT0### CT0
    where CVY.CVY_FILIAL  = @cFilial_CVY
      and CVY.CVY_DATA    = @cDataMes
      and CVY.CVY_NIV01   = @IN_CONTA
      and CVY.CVY_NIV02   = @IN_CUSTO
      and CVY.CVY_NIV03   = @IN_ITEM
      and CVY.CVY_NIV04   = @IN_CLVL
      
      ##IF_002({|| CVY->(FieldPos('CVY_NIV05'))>0})
        and CVY.CVY_NIV05 = @IN_ENT05
      ##ENDIF_002

      ##IF_002({|| CVY->(FieldPos('CVY_NIV06'))>0})
         and CVY.CVY_NIV06 = @IN_ENT06
      ##ENDIF_002

      ##IF_002({|| CVY->(FieldPos('CVY_NIV07'))>0})
         and CVY.CVY_NIV07 = @IN_ENT07
      ##ENDIF_002

      ##IF_002({|| CVY->(FieldPos('CVY_NIV08'))>0})
         and CVY.CVY_NIV08 = @IN_ENT08
      ##ENDIF_002

      ##IF_002({|| CVY->(FieldPos('CVY_NIV09'))>0})
         and CVY.CVY_NIV09 = @IN_ENT09
      ##ENDIF_002

      and CVY.CVY_MOEDA   = @IN_MOEDA
      and CVY_TPSALD      = @IN_TPSALDO
      and CVY_CONFIG      = @IN_CONFIG        
      and CVY.D_E_L_E_T_  = ' '  
   for read only
   Open CUR_CVY
   Fetch CUR_CVY into @iRecnoCVY
   
   While ( @@Fetch_status = 0 ) begin
      ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
       Delete from CVY###
       Where R_E_C_N_O_ = @iRecnoCVY
      ##CHECK_TRANSACTION_COMMIT

      SELECT @fim_CUR = 0
      Fetch CUR_CVY into @iRecnoCVY
   End
   close CUR_CVY
   deallocate CUR_CVY
   
   select @OUT_RESULTADO = '1'
End
##ENDIF_001
