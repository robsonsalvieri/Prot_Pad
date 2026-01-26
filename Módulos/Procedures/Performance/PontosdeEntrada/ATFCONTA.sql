Create Procedure ATFCONTA_## (
   @IN_CONTA   Char( 'N5_CONTA' ),
   @IN_DATA    Char( 08 ),
   @IN_TIPO    Char( 'N5_TIPO' ),
   @IN_VALOR1  float,
   @IN_VALOR2  float,
   @IN_VALOR3  float,
   @IN_VALOR4  float,
   @IN_VALOR5  float,
   @IN_SINAL   char( 01 ), 
   @IN_TAXA    float,
   @IN_SUBCTA  char( 'N3_SUBCTA'),
   @IN_FILIAL  Char( 'N5_FILIAL' ),
   @IN_CLVL    Char( 'N3_CLVLCON' ),
   @IN_CUSTO   Char( 'N3_CCDESP' ), 
    ##FIELDP01( 'SN3.N3_VORIG6' )
    @IN_VALOR6  float,
    ##ENDFIELDP01
    ##FIELDP02( 'SN3.N3_VORIG7' )
    @IN_VALOR7  float,
    ##ENDFIELDP02
    ##FIELDP03( 'SN3.N3_VORIG8' )
    @IN_VALOR8  float,
    ##ENDFIELDP03
    ##FIELDP04( 'SN3.N3_VORIG9' )
    @IN_VALOR9  float,
    ##ENDFIELDP04
    ##FIELDP05( 'SN3.N3_VORIG10' )
    @IN_VALOR10  float,
    ##ENDFIELDP05
    ##FIELDP06( 'SN3.N3_VORIG11' )
    @IN_VALOR11  float,
    ##ENDFIELDP06
    ##FIELDP07( 'SN3.N3_VORIG12' )
    @IN_VALOR12  float,
    ##ENDFIELDP07
    ##FIELDP08( 'SN3.N3_VORIG13' )
    @IN_VALOR13  float,
    ##ENDFIELDP08
    ##FIELDP09( 'SN3.N3_VORIG14' )
    @IN_VALOR14  float,
    ##ENDFIELDP09
    ##FIELDP10( 'SN3.N3_VORIG15' )
    @IN_VALOR15  float,
    ##ENDFIELDP10
   @OUT_CONTA  Char( 'N5_CONTA' ) OutPut
)

as
/* ---------------------------------------------------------------------------------------------------------------------
    Assinatura  :   <a> 001 </a>
--------------------------------------------------------------------------------------------------------------------- */
Declare @cConta Char( 'N5_CONTA' )

begin
   Select @cConta = @IN_CONTA

   Select @OUT_CONTA = @cConta
end

