##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. ) .And. AliasInDic('QLJ')})
Create procedure CTB209D_##
(  
   @IN_FILIAL       Char('CVX_FILIAL'),
   @IN_DATA         Char('CVX_DATA'),
   @IN_MOEDA        Char('CVX_MOEDA'),
   @IN_TPSALDO      Char('CVX_TPSALD'),   
   @IN_CONTA        Char('CVX_NIV01'),
   @IN_CUSTO        Char('CVX_NIV02'),
   @IN_ITEM         Char('CVX_NIV03'),
   @IN_CLVL         Char('CVX_NIV04'),
   
   ##IF_002({|| CVX->(FieldPos('CVX_NIV05'))>0})
      @IN_ENT05  Char( 'CVX_NIV05' ),
   ##ELSE_002
      @IN_ENT05  Char(01),
   ##ENDIF_002
   
   ##IF_002({|| CVX->(FieldPos('CVX_NIV06'))>0})
      @IN_ENT06  Char( 'CVX_NIV06' ),
   ##ELSE_002
      @IN_ENT06  Char(01),
   ##ENDIF_002
   
   ##IF_002({|| CVX->(FieldPos('CVX_NIV07'))>0})
      @IN_ENT07  Char( 'CVX_NIV07' ),
   ##ELSE_002
      @IN_ENT07  Char(01),
   ##ENDIF_002

   ##IF_002({|| CVX->(FieldPos('CVX_NIV08'))>0})
      @IN_ENT08  Char( 'CVX_NIV08' ),
   ##ELSE_002
      @IN_ENT08  Char(01),
   ##ENDIF_002

   ##IF_002({|| CVX->(FieldPos('CVX_NIV09'))>0})
      @IN_ENT09  Char( 'CVX_NIV09' ),
   ##ELSE_002
      @IN_ENT09  Char(01),
   ##ENDIF_002
   
   @IN_CONFIG       Char('CVX_CONFIG'),   
   @IN_TRANSACTION  Char(01),    
   @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versao          - <v> Protheus P12 </v>    
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Zera os saldos diarios dos cubos CVX e CVY </d>
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
declare @cFilial_CVX Char('CVX_FILIAL')
declare @cFilial_CT0 Char('CT0_FILIAL')
Declare @cDataMes    Char( 08 )
Declare @iRecnoCVX   integer
Declare @iRecnoCVY   integer

begin   
   select @OUT_RESULTADO = '0'

   select @iRecnoCVX  = 0 
   select @iRecnoCVY  = 0

   Exec LASTDAY_## @IN_DATA, @cDataMes OutPut
   
   Exec XFILIAL_## 'CVX', @IN_FILIAL, @cFilial_CVX OutPut

   Exec XFILIAL_## 'CT0', @IN_FILIAL, @cFilial_CT0 OutPut

   /* ---------------------------------------------------------------------------------
      Exclusao de CVX - Saldos Diarios  
      ---------------------------------------------------------------------------------- */
   Declare CUR_CVX insensitive cursor for
    select IsNull( CVX.R_E_C_N_O_, 0 )
      from CVX### CVX
     where CVX.CVX_FILIAL  = @cFilial_CVX
       and CVX.CVX_DATA    = @IN_DATA
       and CVX.CVX_NIV01   = @IN_CONTA
       and CVX.CVX_NIV02   = @IN_CUSTO
       and CVX.CVX_NIV03   = @IN_ITEM
       and CVX.CVX_NIV04   = @IN_CLVL
       
       ##IF_002({|| CVX->(FieldPos('CVX_NIV05'))>0})
         and CVX.CVX_NIV05 = @IN_ENT05
       ##ENDIF_002

       ##IF_002({|| CVX->(FieldPos('CVX_NIV06'))>0})
         and CVX.CVX_NIV06 = @IN_ENT06
       ##ENDIF_002

       ##IF_002({|| CVX->(FieldPos('CVX_NIV07'))>0})
         and CVX.CVX_NIV07 = @IN_ENT07
       ##ENDIF_002

       ##IF_002({|| CVX->(FieldPos('CVX_NIV08'))>0})
         and CVX.CVX_NIV08 = @IN_ENT08
       ##ENDIF_002

       ##IF_002({|| CVX->(FieldPos('CVX_NIV09'))>0})
         and CVX.CVX_NIV09 = @IN_ENT09
       ##ENDIF_002

       and CVX.CVX_MOEDA   = @IN_MOEDA 
       and CVX_TPSALD      = @IN_TPSALDO
       and CVX_CONFIG      = @IN_CONFIG
       and CVX.D_E_L_E_T_  = ' '      
   for read only
   Open CUR_CVX
   Fetch CUR_CVX into @iRecnoCVX
   
   While ( @@Fetch_status = 0 ) begin
      ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
       Delete from CVX###
       Where R_E_C_N_O_ = @iRecnoCVX
      ##CHECK_TRANSACTION_COMMIT

      SELECT @fim_CUR = 0
      Fetch CUR_CVX into @iRecnoCVX
   End
   close CUR_CVX
   deallocate CUR_CVX  
   
   select @OUT_RESULTADO = '1'
End
##ENDIF_001
