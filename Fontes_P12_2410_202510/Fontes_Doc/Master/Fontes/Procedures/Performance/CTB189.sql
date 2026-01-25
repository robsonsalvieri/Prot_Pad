Create Procedure CTB189_##(
   @IN_FILIAL   Char( 'CQ0_FILIAL' ),
   @IN_OPER     Char( 01 ),
   @IN_DC       Char( 'CT2_DC' ),
   @IN_CONTAD   Char( 'CQ0_CONTA' ),
   @IN_CONTAC   Char( 'CQ0_CONTA' ),
   @IN_CUSTOD   Char( 'CQ2_CCUSTO' ),
   @IN_CUSTOC   Char( 'CQ2_CCUSTO' ),
   @IN_ITEMD    Char( 'CQ4_ITEM' ),
   @IN_ITEMC    Char( 'CQ4_ITEM' ),
   @IN_CLVLD    Char( 'CQ6_CLVL' ),
   @IN_CLVLC    Char( 'CQ6_CLVL' ),
   ##IF_001({|| lColPer05 := (cPaisLoc $ 'COL|PER' .And. CtbMovSaldo("CT0",,"05") .And. FWAliasInDic('QL6')) .And. CT2->(FieldPos('CT2_EC05DB'))>0})
      @IN_EC05DB   Char( 'CT2_EC05DB' ),   
      @IN_EC05CR   Char( 'CT2_EC05DB' ),
   ##ELSE_001
      @IN_EC05DB   Char( 01 ),   
      @IN_EC05CR   Char( 01 ),
   ##ENDIF_001
   @IN_TPSALDO  Char( 'CQ6_TPSALD' ),
   @IN_MOEDA    Char( 'CQ0_MOEDA' ),
   @IN_DATA     Char( 08 ),
   @IN_DTLP     Char( 08 ),
   @IN_VALOR    Float,
   @IN_INTEGRID Char( 01 ),
   @IN_TRANSACTION Char(01),
   @OUT_RESULT  Char( 01 ) OutPut
)

as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P.11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ctbxatu.prx </s>
    Descricao       - <d>  Atualizacao de Saldos na Alteração do Lote  </d>
    Entrada         - <ri> @IN_FILIAL   - Filial onde a manutencao sera feita
                           @IN_OPER     - '+' ou '-'
                           @IN_DC       - 1 debito, 2- credito, 3 - partida dobrada
                           @IN_CONTAD   - conta a debito
                           @IN_CONTAC   - Conta Credito
                           @IN_CUSTOD   - CCusto debito
                           @IN_CUSTOC   - CCusto credito
                           @IN_ITEMD    - Item debito
                           @IN_ITEMC    - Item credito
                           @IN_CLVLD    - Classe de valor debito
                           @IN_CLVLC    - Classe credito
                           @IN_TPSALDO  - tipode slado
                           @IN_MOEDA    - moeda 
                           @IN_DATA     - Data 
                           @IN_DTLP     - Data de apuracao
                           @IN_VALOR    - valor
                           @IN_INTEGRID - '1' integridade ligada, '0'- Integridade desligada
    Saida           - <o>  @OUT_RESULT  - Indica o termino OK da procedure </ro>
    Data        :     19/10/2009
--------------------------------------------------------------------------------------------------------------------- */
declare @cFilial_CT2 Char( 'CT2_FILIAL' )
declare @cFilial_CQ0 Char( 'CQ0_FILIAL' )
declare @cFilial_CQ2 Char( 'CQ2_FILIAL' )
declare @cFilial_CQ4 Char( 'CQ4_FILIAL' )
declare @cFilial_CQ6 Char( 'CQ6_FILIAL' )
declare @cFilial_QL6 Char( 'CQ6_FILIAL' )
declare @cAux        VarChar( 03 )
declare @cResult     Char( 01 )

##IF_001({|| lColPer05 })
   declare @cEC05DB Char( 'CT2_EC05DB' )
   declare @cEC05CR Char( 'CT2_EC05DB' )   
   select @cEC05DB = @IN_EC05DB
   select @cEC05CR = @IN_EC05CR
##ELSE_001
   Declare @cEC05DB Char( 01 )
   Declare @cEC05CR Char( 01 )
   select @cEC05DB = ' '
   select @cEC05CR = ' '
##ENDIF_001

begin
   Select @OUT_RESULT = '0'
   Select @cResult = '0'
   select @cAux = 'CQ0'
   exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ0 OutPut
   /* ----------------------------------------------------------------------
      Exclusão de saldos do CQ0/CQ1, CQ2/CQ3, CQ4/CQ5, CQ6/CQ7, CQ8/CQ9, CTC
      ---------------------------------------------------------------------- */
   exec CTB180_## @cFilial_CQ0, @IN_OPER, @IN_DC, @IN_CONTAD, @IN_CONTAC, @IN_MOEDA, @IN_DATA, @IN_TPSALDO, @IN_DTLP, 
                  @IN_VALOR, @IN_INTEGRID, @IN_TRANSACTION, @cResult OutPut
   
   If @IN_CUSTOD != ' ' or @IN_CUSTOC != ' ' begin
      select @cAux = 'CQ2'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ2 OutPut
      
      exec CTB181_## @cFilial_CQ2, @IN_OPER, @IN_DC, @IN_CONTAD, @IN_CONTAC, @IN_CUSTOD, @IN_CUSTOC, @IN_MOEDA, @IN_DATA, 
                     @IN_TPSALDO, @IN_DTLP, @IN_VALOR, @IN_INTEGRID, @IN_TRANSACTION, @cResult OutPut
   End
   
   If @IN_ITEMD != ' ' or @IN_ITEMC != ' ' begin
      select @cAux = 'CQ4'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ4 OutPut

      exec CTB182_## @cFilial_CQ4, @IN_OPER, @IN_DC, @IN_CONTAD, @IN_CONTAC, @IN_CUSTOD, @IN_CUSTOC, @IN_ITEMD, @IN_ITEMC, 
                     @IN_MOEDA, @IN_DATA, @IN_TPSALDO, @IN_DTLP, @IN_VALOR, @IN_INTEGRID, @IN_TRANSACTION, @cResult OutPut
   End
   
   If @IN_CLVLD != ' ' or @IN_CLVLC != ' ' begin
      select @cAux = 'CQ6'
      exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CQ6 OutPut
      
      exec CTB183_## @cFilial_CQ6, @IN_OPER, @IN_DC, @IN_CONTAD, @IN_CONTAC, @IN_CUSTOD, @IN_CUSTOC, @IN_ITEMD, @IN_ITEMC, @IN_CLVLD, 
                     @IN_CLVLC, @IN_MOEDA, @IN_DATA, @IN_TPSALDO, @IN_DTLP, @IN_VALOR, @IN_INTEGRID, @IN_TRANSACTION, @cResult OutPut
   End

   ##IF_001({|| lColPer05 })   
      If @cEC05DB != ' ' or @cEC05CR != ' ' begin
         select @cAux = 'QL6'
         exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_QL6 OutPut
         
         exec CTB184_## @cFilial_QL6, @IN_OPER, @IN_DC, @IN_CONTAD, @IN_CONTAC, @IN_CUSTOD, @IN_CUSTOC, @IN_ITEMD, @IN_ITEMC, @IN_CLVLD, 
                        @IN_CLVLC, @cEC05DB, @cEC05CR, @IN_MOEDA, @IN_DATA, @IN_TPSALDO, @IN_DTLP, @IN_VALOR, @IN_INTEGRID, @IN_TRANSACTION, @cResult OutPut
      End      
   ##ENDIF_001
   
   Select @OUT_RESULT = @cResult
End
