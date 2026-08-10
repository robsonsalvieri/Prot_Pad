-- Procedure creation CT105PRGRV
CREATE PROCEDURE CTBA105A_## (
    @IN_cDataLanc Char( 8 ) , 
    @IN_cLote Char( 'CT2_LOTE' ) , 
    @IN_cSubLote Char( 'CT2_SBLOTE' ) , 
    @IN_cDoc Char( 'CT2_DOC' ) , 
    @IN_cFilOri Char( 'CT2_FILORI' ) , 
    @IN_cEmpOri Char( 'CT2_EMPORI' ) , 
    @IN_cSequenc Char( 'CT2_SEQUEN' ) ,  
    @IN_lAglut Char( 1 ) , 
    @IN_cProg Char( 'CT2_ROTINA' ) , 
    @IN_cSeqLan Char( 'CT2_SEQLAN' ) , 
    @IN_lSeqCorr Char( 1 ) , 
    @IN_cSeqCorr Char( 'CT2_NODIA' ) , 
    @IN_lCusto Char( 1 ) , 
    @IN_lItem Char( 1 ) , 
    @IN_lCLVL Char( 1 ) , 
    @IN_nMoedas Integer , 
    @IN_cFilialCT2 Char( 'CT2_FILIAL' ) , 
    @IN_cHoraLc Char( 8 ) , 
    @IN_cManual Char( 1 ) , 
    @IN_lCTBA101 Char( 1 ) , 
    @IN_lCT2_DIACTB Char( 1 ) , 
    @IN_lCT2_MLTSLD Char( 1 ) , 
    @IN_lCT2_CTLSLD Char( 1 ) , 
    @IN_lGrvTRW Char( 1 ) , 
    @IN_cPreLcto VarChar( 1 ) , 
    @IN_ThreadID Char( 'CT2_ATIVDE' ) , 
    @IN_LSIMULA Char( 01 ) , 
    @IN_TOTINF Float , 
    @IN_LATUBASE Char( 01 ) , 
    @IN_LREPROC Char( 01 ) , 
    @IN_NOPC Integer , 
    @IN_FILIAL Char( 'CT2_FILORI' ) , 
    @IN_PROCES Char( 32 ) , 
    @IN_cTmpName Char( 20 ) ,
    @IN_TRANSACTION Char(01),
    @OUT_RET Char( 1 )  output ) AS
-- Declaration of variables
DECLARE @nContador Integer
DECLARE @cMoeda Char( 2 )
DECLARE @nValor Float
DECLARE @iNroRegs Integer
DECLARE @cKey VarChar( 'CT2_KEY' )
DECLARE @cAglut Char( 1 )
DECLARE @iRecno Integer
DECLARE @iRecCV3 Integer
DECLARE @iRecTRW Integer
DECLARE @nSeqHis Integer
DECLARE @cNewSeq Char( 3 )
DECLARE @lContinua Integer
DECLARE @lOutrMoeda Char( 1 )
DECLARE @CTK_DATA Char( 8 )
DECLARE @lNoMltSld Char( 1 )
DECLARE @cTipoOri Char( 1 )
DECLARE @cPoint Char( 1 )
DECLARE @cChar VarChar( 01 )
DECLARE @cMltSldAux VarChar( 20 )
DECLARE @CTK_SEQUEN Char( 'CTK_SEQUEN' )
DECLARE @CTK_DC VarChar( 'CTK_DC' )
DECLARE @CTK_LP VarChar( 'CTK_LP' )
DECLARE @CTK_LPSEQ VarChar( 'CTK_LPSEQ' )
DECLARE @CTK_KEY VarChar( 'CTK_KEY' )
DECLARE @CTK_DEBITO VarChar( 'CTK_DEBITO' )
DECLARE @CTK_CREDIT VarChar( 'CTK_CREDIT' )
DECLARE @CTK_VLR01 Float
DECLARE @CTK_VLR02 Float
DECLARE @CTK_VLR03 Float
DECLARE @CTK_VLR04 Float
DECLARE @CTK_VLR05 Float
DECLARE @iX Integer
DECLARE @nPosition Integer
DECLARE @CTK_HIST VarChar( 'CTK_HIST' )
DECLARE @CTK_CCC VarChar( 'CTK_CCC' )
DECLARE @CTK_CCD VarChar( 'CTK_CCD' )
DECLARE @CTK_ITEMC VarChar( 'CTK_ITEMC' )
DECLARE @CTK_ITEMD VarChar( 'CTK_ITEMD' )
DECLARE @CTK_CLVLDB VarChar( 'CTK_CLVLDB' )
DECLARE @CTK_CLVLCR VarChar( 'CTK_CLVLCR' )
DECLARE @CTK_MOEDLC VarChar( 'CTK_MOEDLC' )
##FIELDP01( 'CTK.CTK_TABORI' )
   DECLARE @CTK_TABORI VarChar( 'CTK_TABORI' )
##ENDFIELDP01
##FIELDP02( 'CTK.CTK_RECORI' )
   DECLARE @CTK_RECORI VarChar( 'CTK_RECORI' )
##ENDFIELDP02
##FIELDP03( 'CTK.CTK_RECDES' )
   DECLARE @CTK_RECDES VarChar( 'CTK_RECDES' )
##ENDFIELDP03
DECLARE @cCT2LinAux Char( 'CT2_LINHA' )
DECLARE @cSeqLan Char( 'CT2_SEQLAN' )
DECLARE @iAux Integer
DECLARE @cAux Char( 03 )
DECLARE @cFilCV3 Char( 'CT2_FILIAL' )
DECLARE @CTK_RECCV3 Char( 'CTK_RECCV3' )
DECLARE @CT2_KEY Char( 'CT2_KEY' )
Declare @iRecAglCTK integer
Declare @iRecAglCV3 integer
DECLARE @CT2_DTCV3 Char( 'CT2_DTCV3' ) --sobrescreve Declaration of variables

##FIELDP12( 'CT2.CT2_MSUIDT' )
   DECLARE @CT2_MSUIDT VarChar( 36 )
##ENDFIELDP12

##FIELDP13( 'CT2.CT2_HORALC' )
   DECLARE @cCT2_HORALC Char( 'CT2_HORALC' )
##ENDFIELDP13
DECLARE @cExecSql  nvarchar(MAX)

##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
   DECLARE @cCursorCTB Char( 2 )
##ENDIF_003

##IF_005({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})      
   DECLARE @cCursorCTB CHAR(1)
##ENDIF_005

BEGIN
   SELECT @iRecno = 0
   SELECT @cAux  = 'CV3' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCV3 output 
   SELECT @cSeqLan  = @IN_cSeqLan 
   SELECT @iAux  = 10 
   IF @IN_cPreLcto  = 'S' 
   BEGIN 
      SELECT @cExecSql = " UPDATE " || @IN_cTmpName || " SET CT2_TPSALD  = ''9'' "
      ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
         exec sp_executesql @cExecSql
      ##ENDIF_001
      ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
         SELECT @cExecSql = 'IMMEDIATE'
      ##ENDIF_002
      ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
         EXECUTE @cExecSql
      ##ENDIF_003
   END 
   SELECT @OUT_RET  = '0' 
   SELECT @nContador  = 1 
   SELECT @cTipoOri  = ' ' 
   SELECT @iNroRegs  = 0 
   IF @IN_lAglut  = '1' 
   BEGIN 
      SELECT @cAglut  = '1' 
   END 
   ELSE 
   BEGIN 
      SELECT @cAglut  = '2' 
   END 

   SELECT @cExecSql = ' '

   -- Cursor declaration cCursorCTB
   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = 'DECLARE cCursorCTB insensitive CURSOR FOR '
   ##ENDIF_001

   SELECT @cExecSql = @cExecSql || ' SELECT CT2_FILIAL --ini select'
   
   SELECT @cExecSql = @cExecSql ||  ' FROM '  
   SELECT @cExecSql = @cExecSql || @IN_cTmpName            

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = @cExecSql || " FOR READ ONLY "
      exec sp_executesql @cExecSql
      OPEN cCursorCTB
   ##ENDIF_001

   ##IF_002({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})      
      OPEN cCursorCTB
   ##ENDIF_002
   
   ##IF_003({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})      
      OPEN cCursorCTB --Não tirar de dentro do IF - será substituído no pos compile
   ##ENDIF_003
   
   FETCH cCursorCTB 
    INTO @cCT2_FILIAL --ini cursor        
   WHILE ( (@@FETCH_STATUS  = 0 ) )
   BEGIN
      ##FIELDPA7( 'CT2.CT2_CTRLSD' )
         SELECT @cMltSldAux  = @cCT2_TPSALD 
         SELECT @cTipoOri  = @cCT2_TPSALD 
         SELECT @iX  = 1 
         IF @cCT2_TPSALD  != "9" AND @cCT2_CTRLSD = "1" 
         BEGIN 
            WHILE (@iX  <= LEN ( @cCT2_MLTSLD ))
            BEGIN
               SELECT @cChar  = '' 
               SELECT @cChar  = SUBSTRING ( @cCT2_MLTSLD , @iX , 1 )
               IF @cChar in ( ';' , ',' , '/' , '|' , ' ' , '9' , '0'  )  or @cChar  = @cCT2_TPSALD 
               BEGIN 
                  SELECT @cChar  = '' 
               END 
               SELECT @cMltSldAux  =  (@cMltSldAux  + @cChar ) 
               SELECT @iX  = @iX  + 1 
            END 
            SELECT @cPoint  = SUBSTRING ( @cCT2_MLTSLD , 2 , 1 )
               IF  (@cPoint  = ';' )  and  (@cCT2_CTRLSD  = '1' ) 
               BEGIN 
                  SELECT @lNoMltSld  = '1' 
               END 
         END 
         SELECT @iX  = 1 
         SELECT @nPosition  = 1 
         WHILE (@iX  <= LEN ( @cMltSldAux ))
         BEGIN
            SELECT @cCT2_TPSALD  = SUBSTRING ( @cMltSldAux , @nPosition , 1 )
            SELECT @nPosition  = @nPosition  + 1 
            SELECT @iX  = @iX  + 1 
            IF @cCT2_TPSALD  = ' ' 
            BEGIN 
               break
            END 
      ##ENDFIELDPA7
         SELECT @lOutrMoeda  = '0' 
         ##FIELDP02( 'CT2.CT2_VALR02' )
            IF @nCT2_VALR02  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP02
         ##FIELDP03( 'CT2.CT2_VALR03' )
            IF @nCT2_VALR03  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP03
         ##FIELDP04( 'CT2.CT2_VALR04' )
            IF @nCT2_VALR04  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP04
         ##FIELDP05( 'CT2.CT2_VALR05' )
            IF @nCT2_VALR05  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP05
         ##FIELDP06( 'CT2.CT2_VALR06' )
            IF @nCT2_VALR06  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP06
         ##FIELDP07( 'CT2.CT2_VALR07' )
            IF @nCT2_VALR07  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP07
         ##FIELDP08( 'CT2.CT2_VALR08' )
            IF @nCT2_VALR08  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP08
         ##FIELDP09( 'CT2.CT2_VALR09' )
            IF @nCT2_VALR09  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP09
         ##FIELDP10( 'CT2.CT2_VALR10' )
            IF @nCT2_VALR10  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP10
         ##FIELDP11( 'CT2.CT2_VALR11' )
            IF @nCT2_VALR11  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP11
         ##FIELDP12( 'CT2.CT2_VALR12' )
            IF @nCT2_VALR12  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP12
         ##FIELDP13( 'CT2.CT2_VALR13' )
            IF @nCT2_VALR13  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP13
         ##FIELDP14( 'CT2.CT2_VALR14' )
            IF @nCT2_VALR14  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP14
         ##FIELDP15( 'CT2.CT2_VALR15' )
            IF @nCT2_VALR15  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP15
         ##FIELDP16( 'CT2.CT2_VALR16' )
            IF @nCT2_VALR16  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP16
         ##FIELDP17( 'CT2.CT2_VALR17' )
            IF @nCT2_VALR17  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP17
         ##FIELDP18( 'CT2.CT2_VALR18' )
            IF @nCT2_VALR18  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP18
         ##FIELDP19( 'CT2.CT2_VALR19' )
            IF @nCT2_VALR19  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP19
         ##FIELDP20( 'CT2.CT2_VALR20' )
            IF @nCT2_VALR20  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP20
         ##FIELDP21( 'CT2.CT2_VALR21' )
            IF @nCT2_VALR21  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP21
         ##FIELDP22( 'CT2.CT2_VALR22' )
            IF @nCT2_VALR22  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP22
         ##FIELDP23( 'CT2.CT2_VALR23' )
            IF @nCT2_VALR23  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP23
         ##FIELDP24( 'CT2.CT2_VALR24' )
            IF @nCT2_VALR24  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP24
         ##FIELDP25( 'CT2.CT2_VALR25' )
            IF @nCT2_VALR25  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP25
         ##FIELDP26( 'CT2.CT2_VALR26' )
            IF @nCT2_VALR26  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP26
         ##FIELDPD9( 'CT2.CT2_VALR27' )
            IF @nCT2_VALR27  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDPD9
         ##FIELDP28( 'CT2.CT2_VALR28' )
            IF @nCT2_VALR28  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP28
         ##FIELDP29( 'CT2.CT2_VALR29' )
            IF @nCT2_VALR29  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP29
         ##FIELDP30( 'CT2.CT2_VALR30' )
            IF @nCT2_VALR30  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP30
         ##FIELDP31( 'CT2.CT2_VALR31' )
            IF @nCT2_VALR31  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP31
         ##FIELDP32( 'CT2.CT2_VALR32' )
            IF @nCT2_VALR32  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP32
         ##FIELDP33( 'CT2.CT2_VALR33' )
            IF @nCT2_VALR33  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP33
         ##FIELDP34( 'CT2.CT2_VALR34' )
            IF @nCT2_VALR34  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP34
         ##FIELDP35( 'CT2.CT2_VALR35' )
            IF @nCT2_VALR35  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP35
         ##FIELDP36( 'CT2.CT2_VALR36' )
            IF @nCT2_VALR36  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP36
         ##FIELDP37( 'CT2.CT2_VALR37' )
            IF @nCT2_VALR37  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP37
         ##FIELDP38( 'CT2.CT2_VALR38' )
            IF @nCT2_VALR38  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP38
         ##FIELDP39( 'CT2.CT2_VALR39' )
            IF @nCT2_VALR39  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP39
         ##FIELDP40( 'CT2.CT2_VALR40' )
            IF @nCT2_VALR40  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP40
         ##FIELDP41( 'CT2.CT2_VALR41' )
            IF @nCT2_VALR41  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP41
         ##FIELDP42( 'CT2.CT2_VALR42' )
            IF @nCT2_VALR42  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP42
         ##FIELDP43( 'CT2.CT2_VALR43' )
            IF @nCT2_VALR43  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP43
         ##FIELDP44( 'CT2.CT2_VALR44' )
            IF @nCT2_VALR44  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP44
         ##FIELDP45( 'CT2.CT2_VALR45' )
            IF @nCT2_VALR45  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP45
         ##FIELDP46( 'CT2.CT2_VALR46' )
            IF @nCT2_VALR46  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP46
         ##FIELDP47( 'CT2.CT2_VALR47' )
            IF @nCT2_VALR47  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP47
         ##FIELDP48( 'CT2.CT2_VALR48' )
            IF @nCT2_VALR48  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP48
         ##FIELDP49( 'CT2.CT2_VALR49' )
            IF @nCT2_VALR49  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP49
         ##FIELDP50( 'CT2.CT2_VALR50' )
            IF @nCT2_VALR50  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP50
         ##FIELDP51( 'CT2.CT2_VALR51' )
            IF @nCT2_VALR51  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP51
         ##FIELDP52( 'CT2.CT2_VALR52' )
            IF @nCT2_VALR52  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP52
         ##FIELDP53( 'CT2.CT2_VALR53' )
            IF @nCT2_VALR53  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP53
         ##FIELDP54( 'CT2.CT2_VALR54' )
            IF @nCT2_VALR54  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP54
         ##FIELDP55( 'CT2.CT2_VALR55' )
            IF @nCT2_VALR55  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP55
         ##FIELDP56( 'CT2.CT2_VALR56' )
            IF @nCT2_VALR56  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP56
         ##FIELDP57( 'CT2.CT2_VALR57' )
            IF @nCT2_VALR57  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP57
         ##FIELDP58( 'CT2.CT2_VALR58' )
            IF @nCT2_VALR58  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP58
         ##FIELDP59( 'CT2.CT2_VALR59' )
            IF @nCT2_VALR59  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP59
         ##FIELDP60( 'CT2.CT2_VALR60' )
            IF @nCT2_VALR60  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP60
         ##FIELDP61( 'CT2.CT2_VALR61' )
            IF @nCT2_VALR61  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP61
         ##FIELDP62( 'CT2.CT2_VALR62' )
            IF @nCT2_VALR62  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP62
         ##FIELDP63( 'CT2.CT2_VALR63' )
            IF @nCT2_VALR63  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP63
         ##FIELDP64( 'CT2.CT2_VALR64' )
            IF @nCT2_VALR64  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP64
         ##FIELDP65( 'CT2.CT2_VALR65' )
            IF @nCT2_VALR65  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP65
         ##FIELDP66( 'CT2.CT2_VALR66' )
            IF @nCT2_VALR66  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP66
         ##FIELDP67( 'CT2.CT2_VALR67' )
            IF @nCT2_VALR67  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP67
         ##FIELDP68( 'CT2.CT2_VALR68' )
            IF @nCT2_VALR68  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP68
         ##FIELDP69( 'CT2.CT2_VALR69' )
            IF @nCT2_VALR69  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP69
         ##FIELDP70( 'CT2.CT2_VALR70' )
            IF @nCT2_VALR70  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP70
         ##FIELDP71( 'CT2.CT2_VALR71' )
            IF @nCT2_VALR71  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP71
         ##FIELDP72( 'CT2.CT2_VALR72' )
            IF @nCT2_VALR72  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP72
         ##FIELDP73( 'CT2.CT2_VALR73' )
            IF @nCT2_VALR73  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP73
         ##FIELDP74( 'CT2.CT2_VALR74' )
            IF @nCT2_VALR74  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP74
         ##FIELDP75( 'CT2.CT2_VALR75' )
            IF @nCT2_VALR75  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP75
         ##FIELDP76( 'CT2.CT2_VALR76' )
            IF @nCT2_VALR76  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP76
         ##FIELDP77( 'CT2.CT2_VALR77' )
            IF @nCT2_VALR77  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP77
         ##FIELDP78( 'CT2.CT2_VALR78' )
            IF @nCT2_VALR78  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP78
         ##FIELDP79( 'CT2.CT2_VALR79' )
            IF @nCT2_VALR79  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP79
         ##FIELDP80( 'CT2.CT2_VALR80' )
            IF @nCT2_VALR80  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP80
         ##FIELDP81( 'CT2.CT2_VALR81' )
            IF @nCT2_VALR81  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP81
         ##FIELDP82( 'CT2.CT2_VALR82' )
            IF @nCT2_VALR82  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP82
         ##FIELDP83( 'CT2.CT2_VALR83' )
            IF @nCT2_VALR83  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP83
         ##FIELDP84( 'CT2.CT2_VALR84' )
            IF @nCT2_VALR84  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP84
         ##FIELDP85( 'CT2.CT2_VALR85' )
            IF @nCT2_VALR85  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP85
         ##FIELDPD1( 'CT2.CT2_VALR86' )
            IF @nCT2_VALR86  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDPD1
         ##FIELDP87( 'CT2.CT2_VALR87' )
            IF @nCT2_VALR87  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP87
         ##FIELDPA8( 'CT2.CT2_VALR88' )
            IF @nCT2_VALR88  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDPA8
         ##FIELDP89( 'CT2.CT2_VALR89' )
            IF @nCT2_VALR89  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP89
         ##FIELDP90( 'CT2.CT2_VALR90' )
            IF @nCT2_VALR90  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP90
         ##FIELDP91( 'CT2.CT2_VALR91' )
            IF @nCT2_VALR91  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP91
         ##FIELDP92( 'CT2.CT2_VALR92' )
            IF @nCT2_VALR92  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP92
         ##FIELDP93( 'CT2.CT2_VALR93' )
            IF @nCT2_VALR93  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP93
         ##FIELDP94( 'CT2.CT2_VALR94' )
            IF @nCT2_VALR94  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP94
         ##FIELDP95( 'CT2.CT2_VALR95' )
            IF @nCT2_VALR95  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP95
         ##FIELDP96( 'CT2.CT2_VALR96' )
            IF @nCT2_VALR96  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP96
         ##FIELDP97( 'CT2.CT2_VALR97' )
            IF @nCT2_VALR97  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP97
         ##FIELDP98( 'CT2.CT2_VALR98' )
            IF @nCT2_VALR98  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP98
         ##FIELDP99( 'CT2.CT2_VALR99' )
            IF @nCT2_VALR99  > 0 
            BEGIN 
               SELECT @lOutrMoeda  = '1' 
            END 
         ##ENDFIELDP99
         SELECT @nContador  = 1 
         SELECT @cMoeda  = '  ' 
         WHILE (@IN_nMoedas  >= @nContador )
         BEGIN
            SELECT @lContinua  = 1 
            EXEC MSSTRZERO @nContador , 2 , @cMoeda output 
            IF @cMoeda = '01' 
            BEGIN 
                SELECT @nValor = @nCT2_VALOR 
            END 
            ELSE 
            BEGIN 
                IF @cMoeda = '02' 
                BEGIN 
                    SELECT @nValor = @nCT2_VALR02 
                END 
                ELSE 
                BEGIN 
                    IF @cMoeda = '03' 
                    BEGIN 
                        SELECT @nValor = @nCT2_VALR03 
                    END 
                    ELSE 
                    BEGIN 
                        IF @cMoeda = '04' 
                        BEGIN 
                            SELECT @nValor = @nCT2_VALR04 
                        END 
                        ELSE 
                        BEGIN 
                            IF @cMoeda = '05' 
                            BEGIN 
                                SELECT @nValor = @nCT2_VALR05 
                            END 
                            ELSE 
                            BEGIN 
                                IF @cMoeda = '06' 
                                BEGIN 
                                    SELECT @nValor = @nCT2_VALR06 
                                END 
                                ELSE 
                                BEGIN 
                                    IF @cMoeda = '07' 
                                    BEGIN 
                                        SELECT @nValor = @nCT2_VALR07 
                                    END                                     
                                END 
                            END 
                        END 
                    END 
                END 
            END
            IF  (@lCT2_FLAG  = 'T' )  or  (@cMoeda  <> '01'  and @cCT2_DC  = '4' )  or  (@cCT2_DC  != '4'  and @nValor  <= 0 
               and  (@cMoeda  <> '01'  or  (@cMoeda  = '01'  and @lOutrMoeda  = '0' ) ) ) 
            BEGIN 
               SELECT @lContinua  = 0 
            END 
            IF @lContinua  = 1 
            BEGIN 
               IF @IN_cManual  = '2' 
               BEGIN 
                  SELECT @cKey  = @cCT2_KEY 
               END 
               ELSE 
               BEGIN 
                  SELECT @cKey  = ' ' 
               END 
               IF @cMoeda  = '01' 
               BEGIN 
                  SELECT @cCT2LinAux  = COALESCE ( MAX ( CT2_LINHA ), '000' )
                    FROM CT2###
                    WHERE CT2_FILIAL  = @IN_cFilialCT2  and CT2_DATA  = @IN_cDataLanc  and CT2_LOTE  = @IN_cLote  and CT2_SBLOTE  = @IN_cSubLote 
                     and CT2_DOC  = @IN_cDoc  and CT2_FILORI  = @IN_cFilOri  and CT2_EMPORI  = @IN_cEmpOri  and D_E_L_E_T_  = ' ' 
                  EXEC MSSOMA1 @cCT2LinAux , '1' , @cCT2_LINHA output 
                  IF @IN_lCTBA101  = '1' 
                  BEGIN 
                     IF @cCT2_DC  != '4' 
                     BEGIN 
                        EXEC MSSOMA1 @cSeqLan , '0' , @cSeqLan output 
                        SELECT @cCT2_SEQHIS  = '001' 
                        SELECT @cCT2_SEQLAN  = @cSeqLan 
                        SELECT @nSeqHis  = 1 
                     END 
                     ELSE 
                     BEGIN 
                        IF @cCT2_DC  = '4' 
                        BEGIN 
                           SELECT @nSeqHis  = @nSeqHis  + 1 
                           SELECT @cCT2_SEQLAN  = @cSeqLan 
                           EXEC MSSTRZERO @nSeqHis , 3 , @cNewSeq output 
                           SELECT @cCT2_SEQHIS  = @cNewSeq 
                        END 
                        ELSE 
                        BEGIN 
                           IF @cCT2_LINHA  = '001' 
                           BEGIN 
                              SELECT @cSeqLan  = '001' 
                              SELECT @nSeqHis  = 1 
                              SELECT @cCT2_SEQLAN  = @cSeqLan 
                              EXEC MSSTRZERO @nSeqHis , 3 , @cNewSeq output 
                              SELECT @cCT2_SEQHIS  = @cNewSeq 
                           END 
                           ELSE 
                           BEGIN 
                              IF @cCT2_DC  != '4'  and @cCT2_LINHA  != '001' 
                              BEGIN 
                                 SELECT @cCT2_SEQHIS  = '001' 
                                 SELECT @nSeqHis  = 1 
                                 IF @cCT2_SEQLAN  != ' ' 
                                 BEGIN 
                                    SELECT @cSeqLan  = @cCT2_SEQLAN 
                                 END 
                                 ELSE 
                                 BEGIN 
                                    EXEC MSSOMA1 @cSeqLan , '0' , @cSeqLan output 
                                    SELECT @cCT2_SEQLAN  = @cSeqLan 
                                 END 
                              END 
                              ELSE 
                              BEGIN 
                                 IF @cCT2_DC  = '4'  and @cCT2_LINHA  != '001' 
                                 BEGIN 
                                    IF @cCT2_SEQLAN  = ' ' 
                                    BEGIN 
                                       SELECT @cCT2_SEQLAN  = @cSeqLan 
                                    END 
                                    ELSE 
                                    BEGIN 
                                       SELECT @cSeqLan  = @cCT2_SEQLAN 
                                    END 
                                    IF @cCT2_SEQHIS  = ' ' 
                                    BEGIN 
                                       SELECT @nSeqHis  = @nSeqHis  + 1 
                                       EXEC MSSTRZERO @nSeqHis , 3 , @cNewSeq output 
                                       SELECT @cCT2_SEQHIS  = @cNewSeq 
                                    END 
                                    ELSE 
                                    BEGIN 
                                       SELECT @nSeqHis  = CONVERT( Integer ,@cCT2_SEQHIS )
                                    END 
                                 END 
                              END 
                           END 
                        END 
                     END 
                  END 
                  SELECT @cCT2_CRCONV  = SUBSTRING ( @cCT2_CONVER , 1 , 1 )
               END 
               ELSE 
               BEGIN 
                  SELECT @cCT2_CRCONV  = SUBSTRING ( @cCT2_CONVER , @nContador , 1 )
                  SELECT @nCT2_VALOR  = @nValor 
               END 
               IF @IN_lSeqCorr  = '1' 
               BEGIN 
                  SELECT @cCT2_SEGOFI  = @IN_cSeqCorr 
                  SELECT @cCT2_NODIA  = @IN_cSeqCorr 
                  IF @IN_lCT2_DIACTB  = '1'  and @IN_lSeqCorr  != ' ' 
                  BEGIN 
                     SELECT @cCT2_DIACTB  = SUBSTRING ( @IN_cSeqCorr , 1 , 2 )
                  END 
               END 
               IF @IN_lCT2_MLTSLD  = '1'  and @IN_lCT2_CTLSLD  = '1' 
               BEGIN 
                  SELECT @cCT2_CTLSLD  = '0' 
               END 
               SELECT @cCT2_FILIAL  = @IN_cFilialCT2 
               SELECT @cCT2_DATA  = @IN_cDataLanc 
               SELECT @cCT2_LOTE  = @IN_cLote 
               SELECT @cCT2_SBLOTE  = @IN_cSubLote 
               SELECT @cCT2_DOC  = @IN_cDoc 
               SELECT @cCT2_FILORI  = @IN_cFilOri 
               SELECT @cCT2_EMPORI  = @IN_cEmpOri 
               SELECT @cCT2_SEQUEN  = @IN_cSequenc 
               SELECT @cCT2_ROTINA  = @IN_cProg 
               SELECT @cCT2_AGLUT  = @cAglut 
               SELECT @cCT2_MOEDLC  = @cMoeda 
               SELECT @cCT2_MANUAL  = '2' 
               
               ##FIELDP13( 'CT2.CT2_HORALC' )
                  SELECT @cCT2_HORALC  = @IN_cHoraLc 
               ##ENDFIELDP13
               
               select @iRecno = 0               
               ##UNIQUEKEY_START
               select @iRecno = Isnull(max(R_E_C_N_O_), 0)
                  From CT2###
                  Where CT2_FILIAL  = @IN_cFilialCT2
                  and CT2_DATA  = @IN_cDataLanc
                  and CT2_LOTE  = @IN_cLote
                  and CT2_SBLOTE  = @IN_cSubLote
                  and CT2_DOC  = @IN_cDoc
                  and CT2_LINHA  = @cCT2_LINHA   
                  and CT2_EMPORI  = @IN_cEmpOri
                  and CT2_FILORI  = @IN_cFilOri
                  and CT2_MOEDLC  = @cCT2_MOEDLC
                  and CT2_SEQIDX  = @cCT2_SEQIDX
                  and D_E_L_E_T_ = ' '
               ##UNIQUEKEY_END

               IF @iRecno = 0 BEGIN 

                  SELECT @iRecno = COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) FROM CT2###
                  SELECT @iRecno = @iRecno + 1 

                  ##TRATARECNO @iRecno\
                  ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                     INSERT INTO CT2### (CT2_FILIAL ) --ini insert into
                     VALUES (@cCT2_FILIAL )--ini values
                  ##CHECK_TRANSACTION_COMMIT
                  ##FIMTRATARECNO 
                  IF  (@IN_cProg  != 'CTBA101'  and @IN_cProg  != 'CTBA102'  and @IN_cProg  != 'CTBA103' )  and @IN_LSIMULA  = '0' 
                  BEGIN 
                     EXEC CT105CT2_## @IN_nMoedas , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @IN_lCusto , @IN_lItem , 
                           @IN_lCLVL , @IN_TOTINF , @IN_LATUBASE , @IN_LREPROC 
                  END 
                  
                  IF @IN_LSIMULA  = '0' 
                  BEGIN 
                     EXEC CTBGRV_## @IN_NOPC , @IN_cProg 
                  END 
                 ##FIELDP12( 'CT2.CT2_MSUIDT' )
                     -- Olhar sempre a moeda forte, pois posso ter mais de uma moeda e ficar diferente de quando rodo sem a procedure.
                     -- Na tabela CT2, grava N moedas, conforme o LP.
                     -- Na tabela CV3, grava somente o registro referente a moeda 01, portanto não há problema em fixar o campo CT2_MOEDLC igual a 01.
                     -- O parametro MV_CTBMFOR está sendo utilizado somente no fonte CTBA381.
                        SELECT  @CT2_MSUIDT = CT2_MSUIDT 
                           From CT2###
                           Where CT2_FILIAL  = @cCT2_FILIAL
                           and CT2_DATA  = @cCT2_DATA
                           and CT2_LOTE  = @cCT2_LOTE
                           and CT2_SBLOTE   = @cCT2_SBLOTE
                           AND CT2_DOC      = @cCT2_DOC
                           AND CT2_LINHA    = @cCT2_LINHA
                           AND CT2_MOEDLC   = '01'
                           AND CT2_DC   <> '4'
                           AND D_E_L_E_T_  = ' ' 
                  ##ENDFIELDP12       
               END 
                     SELECT @CT2_DTCV3  = CT2_DTCV3 , @CT2_KEY  = CT2_KEY  
                     ##FIELDP12( 'CT2.CT2_MSUIDT' )
                        , @CT2_MSUIDT  = CT2_MSUIDT 
                     ##ENDFIELDP12
                     FROM CT2###
                     WHERE R_E_C_N_O_  = @iRecno 
                     IF @CT2_KEY  = ' ' 
                     BEGIN 
                        SELECT @CT2_KEY  = @cCT2_KEY 
                     END 
                     IF @CT2_DTCV3  = ' ' 
                     BEGIN 
                        SELECT @CT2_DTCV3  = @cCT2_DTCV3 
                     END 
                     ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                     UPDATE CT2###
                     SET CT2_VALOR = CT2_VALOR + @nCT2_VALOR
                        ,CT2_TAXA = CT2_TAXA + @nCT2_TAXA
                        ,CT2_KEY = @CT2_KEY 
                        ,CT2_CRCONV	= @cCT2_CRCONV
                        ,CT2_DTCV3 = @CT2_DTCV3
                        ,CT2_VLR01 = CT2_VLR01 + @nCT2_VLR01
                        ,CT2_VLR02 = CT2_VLR02 + @nCT2_VLR02
                        ,CT2_VLR03 = CT2_VLR03 + @nCT2_VLR03
                        ,CT2_VLR04 = CT2_VLR04 + @nCT2_VLR04
                        ,CT2_VLR05 = CT2_VLR05 + @nCT2_VLR05 
                        ##FIELDP06( 'CT2.CT2_VLR06' )
                           ,CT2_VLR06 = CT2_VLR06 + @nCT2_VLR06 
                        ##ENDFIELDP06
                        ##FIELDP07( 'CT2.CT2_VLR07' )
                           ,CT2_VLR07 = CT2_VLR07 + @nCT2_VLR07 
                        ##ENDFIELDP07
                        ##FIELDP08( 'CT2.CT2_VLR08' )
                           ,CT2_VLR08 = CT2_VLR08 + @nCT2_VLR08 
                        ##ENDFIELDP08
                        ##FIELDP09( 'CT2.CT2_VLR09' )
                           ,CT2_VLR09 = CT2_VLR09 + @nCT2_VLR09 
                        ##ENDFIELDP09
                        ##FIELDP10( 'CT2.CT2_VLR10' )
                           ,CT2_VLR10 = CT2_VLR10 + @nCT2_VLR10 
                        ##ENDFIELDP10
                        ##FIELDP11( 'CT2.CT2_VLR11' )
                           ,CT2_VLR11 = CT2_VLR11 + @nCT2_VLR11 
                        ##ENDFIELDP11
                        ##FIELDP12( 'CT2.CT2_VLR12' )
                           ,CT2_VLR12 = CT2_VLR12 + @nCT2_VLR12 
                        ##ENDFIELDP12
                        ##FIELDP13( 'CT2.CT2_VLR13' )
                           ,CT2_VLR13 = CT2_VLR13 + @nCT2_VLR13 
                        ##ENDFIELDP13
                        ##FIELDP14( 'CT2.CT2_VLR14' )
                           ,CT2_VLR14 = CT2_VLR14 + @nCT2_VLR14 
                        ##ENDFIELDP14
                        ##FIELDP15( 'CT2.CT2_VLR15' )
                           ,CT2_VLR15 = CT2_VLR15 + @nCT2_VLR15 
                        ##ENDFIELDP15
                        ##FIELDP16( 'CT2.CT2_VLR16' )
                           ,CT2_VLR16 = CT2_VLR16 + @nCT2_VLR16 
                        ##ENDFIELDP16
                        ##FIELDP17( 'CT2.CT2_VLR17' )
                           ,CT2_VLR17 = CT2_VLR17 + @nCT2_VLR17 
                        ##ENDFIELDP17
                        ##FIELDP18( 'CT2.CT2_VLR18' )
                           ,CT2_VLR18 = CT2_VLR18 + @nCT2_VLR18 
                        ##ENDFIELDP18
                        ##FIELDP19( 'CT2.CT2_VLR19' )
                           ,CT2_VLR19 = CT2_VLR19 + @nCT2_VLR19 
                        ##ENDFIELDP19
                        ##FIELDP20( 'CT2.CT2_VLR20' )
                           ,CT2_VLR20 = CT2_VLR20 + @nCT2_VLR20 
                        ##ENDFIELDP20
                        ##FIELDP21( 'CT2.CT2_VLR21' )
                           ,CT2_VLR21 = CT2_VLR21 + @nCT2_VLR21 
                        ##ENDFIELDP21
                        ##FIELDP22( 'CT2.CT2_VLR22' )
                           ,CT2_VLR22 = CT2_VLR22 + @nCT2_VLR22 
                        ##ENDFIELDP22
                        ##FIELDP23( 'CT2.CT2_VLR23' )
                           ,CT2_VLR23 = CT2_VLR23 + @nCT2_VLR23 
                        ##ENDFIELDP23
                        ##FIELDP24( 'CT2.CT2_VLR24' )
                           ,CT2_VLR24 = CT2_VLR24 + @nCT2_VLR24 
                        ##ENDFIELDP24
                        ##FIELDP25( 'CT2.CT2_VLR25' )
                           ,CT2_VLR25 = CT2_VLR25 + @nCT2_VLR25 
                        ##ENDFIELDP25
                        ##FIELDP26( 'CT2.CT2_VLR26' )
                           ,CT2_VLR26 = CT2_VLR26 + @nCT2_VLR26 
                        ##ENDFIELDP26
                        ##FIELDP27( 'CT2.CT2_VLR27' )
                           ,CT2_VLR27 = CT2_VLR27 + @nCT2_VLR27 
                        ##ENDFIELDP27
                        ##FIELDP28( 'CT2.CT2_VLR28' )
                           ,CT2_VLR28 = CT2_VLR28 + @nCT2_VLR28 
                        ##ENDFIELDP28
                        ##FIELDP29( 'CT2.CT2_VLR29' )
                           ,CT2_VLR29 = CT2_VLR29 + @nCT2_VLR29 
                        ##ENDFIELDP29
                        ##FIELDP30( 'CT2.CT2_VLR30' )
                           ,CT2_VLR30 = CT2_VLR30 + @nCT2_VLR30 
                        ##ENDFIELDP30
                        ##FIELDP31( 'CT2.CT2_VLR31' )
                           ,CT2_VLR31 = CT2_VLR31 + @nCT2_VLR31 
                        ##ENDFIELDP31
                        ##FIELDP32( 'CT2.CT2_VLR32' )
                           ,CT2_VLR32 = CT2_VLR32 + @nCT2_VLR32 
                        ##ENDFIELDP32
                        ##FIELDP33( 'CT2.CT2_VLR33' )
                           ,CT2_VLR33 = CT2_VLR33 + @nCT2_VLR33
                        ##ENDFIELDP33
                        ##FIELDP34( 'CT2.CT2_VLR34' )
                           ,CT2_VLR34 = CT2_VLR34 + @nCT2_VLR34
                        ##ENDFIELDP34
                        ##FIELDP35( 'CT2.CT2_VLR35' )
                           ,CT2_VLR35 = CT2_VLR35 + @nCT2_VLR35
                        ##ENDFIELDP35
                        ##FIELDP36( 'CT2.CT2_VLR36' )
                           ,CT2_VLR36 = CT2_VLR36 + @nCT2_VLR36
                        ##ENDFIELDP36
                        ##FIELDP37( 'CT2.CT2_VLR37' )
                           ,CT2_VLR37 = CT2_VLR37 + @nCT2_VLR37
                        ##ENDFIELDP37
                        ##FIELDP38( 'CT2.CT2_VLR38' )
                           ,CT2_VLR38 = CT2_VLR38 + @nCT2_VLR38
                        ##ENDFIELDP38
                        ##FIELDP39( 'CT2.CT2_VLR39' )
                           ,CT2_VLR39 = CT2_VLR39 + @nCT2_VLR39
                        ##ENDFIELDP39
                        ##FIELDP40( 'CT2.CT2_VLR40' )
                           ,CT2_VLR40 = CT2_VLR40 + @nCT2_VLR40
                        ##ENDFIELDP40
                        ##FIELDP41( 'CT2.CT2_VLR41' )
                           ,CT2_VLR41 = CT2_VLR41 + @nCT2_VLR41
                        ##ENDFIELDP41
                        ##FIELDP42( 'CT2.CT2_VLR42' )
                           ,CT2_VLR42 = CT2_VLR42 + @nCT2_VLR42
                        ##ENDFIELDP42
                        ##FIELDP43( 'CT2.CT2_VLR43' )
                           ,CT2_VLR43 = CT2_VLR43 + @nCT2_VLR43
                        ##ENDFIELDP43
                        ##FIELDP44( 'CT2.CT2_VLR44' )
                           ,CT2_VLR44 = CT2_VLR44 + @nCT2_VLR44
                        ##ENDFIELDP44
                        ##FIELDP45( 'CT2.CT2_VLR45' )
                           ,CT2_VLR45 = CT2_VLR45 + @nCT2_VLR45
                        ##ENDFIELDP45
                        ##FIELDP46( 'CT2.CT2_VLR46' )
                           ,CT2_VLR46 = CT2_VLR46 + @nCT2_VLR46
                        ##ENDFIELDP46
                        ##FIELDP47( 'CT2.CT2_VLR47' )
                           ,CT2_VLR47 = CT2_VLR47 + @nCT2_VLR47
                        ##ENDFIELDP47
                        ##FIELDP48( 'CT2.CT2_VLR48' )
                           ,CT2_VLR48 = CT2_VLR48 + @nCT2_VLR48
                        ##ENDFIELDP48
                        ##FIELDP49( 'CT2.CT2_VLR49' )
                           ,CT2_VLR49 = CT2_VLR49 + @nCT2_VLR49
                        ##ENDFIELDP49
                        ##FIELDP50( 'CT2.CT2_VLR50' )
                           ,CT2_VLR50 = CT2_VLR50 + @nCT2_VLR50
                        ##ENDFIELDP50
                        ##FIELDP51( 'CT2.CT2_VLR51' )
                           ,CT2_VLR51 = CT2_VLR51 + @nCT2_VLR51
                        ##ENDFIELDP51
                        ##FIELDP52( 'CT2.CT2_VLR52' )
                           ,CT2_VLR52 = CT2_VLR52 + @nCT2_VLR52
                        ##ENDFIELDP52
                        ##FIELDP53( 'CT2.CT2_VLR53' )
                           ,CT2_VLR53 = CT2_VLR53 + @nCT2_VLR53
                        ##ENDFIELDP53
                        ##FIELDP54( 'CT2.CT2_VLR54' )
                           ,CT2_VLR54 = CT2_VLR54 + @nCT2_VLR54
                        ##ENDFIELDP54
                        ##FIELDP55( 'CT2.CT2_VLR55' )
                           ,CT2_VLR55 = CT2_VLR55 + @nCT2_VLR55
                        ##ENDFIELDP55
                        ##FIELDP56( 'CT2.CT2_VLR56' )
                           ,CT2_VLR56 = CT2_VLR56 + @nCT2_VLR56
                        ##ENDFIELDP56
                        ##FIELDP57( 'CT2.CT2_VLR57' )
                           ,CT2_VLR57 = CT2_VLR57 + @nCT2_VLR57
                        ##ENDFIELDP57
                        ##FIELDP58( 'CT2.CT2_VLR58' )
                           ,CT2_VLR58 = CT2_VLR58 + @nCT2_VLR58
                        ##ENDFIELDP58
                        ##FIELDP59( 'CT2.CT2_VLR59' )
                           ,CT2_VLR59 = CT2_VLR59 + @nCT2_VLR59
                        ##ENDFIELDP59
                        ##FIELDP60( 'CT2.CT2_VLR60' )
                           ,CT2_VLR60 = CT2_VLR60 + @nCT2_VLR60
                        ##ENDFIELDP60
                        ##FIELDP61( 'CT2.CT2_VLR61' )
                           ,CT2_VLR61 = CT2_VLR61 + @nCT2_VLR61
                        ##ENDFIELDP61
                        ##FIELDP62( 'CT2.CT2_VLR62' )
                           ,CT2_VLR62 = CT2_VLR62 + @nCT2_VLR62
                        ##ENDFIELDP62
                        ##FIELDP63( 'CT2.CT2_VLR63' )
                           ,CT2_VLR63 = CT2_VLR63 + @nCT2_VLR63
                        ##ENDFIELDP63
                        ##FIELDP64( 'CT2.CT2_VLR64' )
                           ,CT2_VLR64 = CT2_VLR64 + @nCT2_VLR64
                        ##ENDFIELDP64
                        ##FIELDP65( 'CT2.CT2_VLR65' )
                           ,CT2_VLR65 = CT2_VLR65 + @nCT2_VLR65 
                        ##ENDFIELDP65
                        ##FIELDP66( 'CT2.CT2_VLR66' )
                           ,CT2_VLR66 = CT2_VLR66 + @nCT2_VLR66
                        ##ENDFIELDP66
                        ##FIELDP67( 'CT2.CT2_VLR67' )
                           ,CT2_VLR67 = CT2_VLR67 + @nCT2_VLR67
                        ##ENDFIELDP67
                        ##FIELDP68( 'CT2.CT2_VLR68' )
                           ,CT2_VLR68 = CT2_VLR68 + @nCT2_VLR68
                        ##ENDFIELDP68
                        ##FIELDP69( 'CT2.CT2_VLR69' )
                           ,CT2_VLR69 = CT2_VLR69 + @nCT2_VLR69
                        ##ENDFIELDP69
                        ##FIELDP70( 'CT2.CT2_VLR70' )
                           ,CT2_VLR70 = CT2_VLR70 + @nCT2_VLR70
                        ##ENDFIELDP70
                        ##FIELDP71( 'CT2.CT2_VLR71' )
                           ,CT2_VLR71 = CT2_VLR71 + @nCT2_VLR71
                        ##ENDFIELDP71
                        ##FIELDP72( 'CT2.CT2_VLR72' )
                           ,CT2_VLR72 = CT2_VLR72 + @nCT2_VLR72
                        ##ENDFIELDP72
                        ##FIELDP73( 'CT2.CT2_VLR73' )
                           ,CT2_VLR73 = CT2_VLR73 + @nCT2_VLR73
                        ##ENDFIELDP73
                        ##FIELDP74( 'CT2.CT2_VLR74' )
                           ,CT2_VLR74 = CT2_VLR74 + @nCT2_VLR74
                        ##ENDFIELDP74
                        ##FIELDP75( 'CT2.CT2_VLR75' )
                           ,CT2_VLR75 = CT2_VLR75 + @nCT2_VLR75
                        ##ENDFIELDP75
                        ##FIELDP76( 'CT2.CT2_VLR76' )
                           ,CT2_VLR76 = CT2_VLR76 + @nCT2_VLR76
                        ##ENDFIELDP76
                        ##FIELDP77( 'CT2.CT2_VLR77' )
                           ,CT2_VLR77 = CT2_VLR77 + @nCT2_VLR77
                        ##ENDFIELDP77
                        ##FIELDP78( 'CT2.CT2_VLR78' )
                           ,CT2_VLR78 = CT2_VLR78 + @nCT2_VLR78
                        ##ENDFIELDP78
                        ##FIELDP79( 'CT2.CT2_VLR79' )
                           ,CT2_VLR79 = CT2_VLR79 + @nCT2_VLR79
                        ##ENDFIELDP79
                        ##FIELDP80( 'CT2.CT2_VLR80' )
                           ,CT2_VLR80 = CT2_VLR80 + @nCT2_VLR80
                        ##ENDFIELDP80
                        ##FIELDP81( 'CT2.CT2_VLR81' )
                           ,CT2_VLR81 = CT2_VLR81 + @nCT2_VLR81
                        ##ENDFIELDP81
                        ##FIELDP82( 'CT2.CT2_VLR82' )
                           ,CT2_VLR82 = CT2_VLR82 + @nCT2_VLR82
                        ##ENDFIELDP82
                        ##FIELDP83( 'CT2.CT2_VLR83' )
                           ,CT2_VLR83 = CT2_VLR83 + @nCT2_VLR83
                        ##ENDFIELDP83
                        ##FIELDP84( 'CT2.CT2_VLR84' )
                           ,CT2_VLR84 = CT2_VLR84 + @nCT2_VLR84
                        ##ENDFIELDP84
                        ##FIELDP85( 'CT2.CT2_VLR85' )
                           ,CT2_VLR85 = CT2_VLR85 + @nCT2_VLR85
                        ##ENDFIELDP85
                        ##FIELDP86( 'CT2.CT2_VLR86' )
                           ,CT2_VLR86 = CT2_VLR86 + @nCT2_VLR86
                        ##ENDFIELDP86
                        ##FIELDP87( 'CT2.CT2_VLR87' )
                           ,CT2_VLR87 = CT2_VLR87 + @nCT2_VLR87
                        ##ENDFIELDP87
                        ##FIELDP88( 'CT2.CT2_VLR88' )
                           ,CT2_VLR88 = CT2_VLR88 + @nCT2_VLR88
                        ##ENDFIELDP88
                        ##FIELDP89( 'CT2.CT2_VLR89' )
                           ,CT2_VLR89 = CT2_VLR89 + @nCT2_VLR89
                        ##ENDFIELDP89
                        ##FIELDP90( 'CT2.CT2_VLR90' )
                           ,CT2_VLR90 = CT2_VLR90 + @nCT2_VLR90
                        ##ENDFIELDP90
                        ##FIELDP91( 'CT2.CT2_VLR91' )
                           ,CT2_VLR91 = CT2_VLR91 + @nCT2_VLR91
                        ##ENDFIELDP91
                        ##FIELDP92( 'CT2.CT2_VLR92' )
                           ,CT2_VLR92 = CT2_VLR92 + @nCT2_VLR92
                        ##ENDFIELDP92
                        ##FIELDP93( 'CT2.CT2_VLR93' )
                           ,CT2_VLR93 = CT2_VLR93 + @nCT2_VLR93
                        ##ENDFIELDP93
                        ##FIELDP94( 'CT2.CT2_VLR94' )
                           ,CT2_VLR94 = CT2_VLR94 + @nCT2_VLR94
                        ##ENDFIELDP94
                        ##FIELDP95( 'CT2.CT2_VLR95' )
                           ,CT2_VLR95 = CT2_VLR95 + @nCT2_VLR95
                        ##ENDFIELDP95
                        ##FIELDP96( 'CT2.CT2_VLR96' )
                           ,CT2_VLR96 = CT2_VLR96 + @nCT2_VLR96
                        ##ENDFIELDP96
                        ##FIELDP97( 'CT2.CT2_VLR97' )
                           ,CT2_VLR97 = CT2_VLR97 + @nCT2_VLR97
                        ##ENDFIELDP97
                        ##FIELDP98( 'CT2.CT2_VLR98' )
                           ,CT2_VLR98 = CT2_VLR98 + @nCT2_VLR98
                        ##ENDFIELDP98
                        ##FIELDP99( 'CT2.CT2_VLR99' )
                           ,CT2_VLR99 = CT2_VLR99 + @nCT2_VLR99
                        ##ENDFIELDP99
                     WHERE R_E_C_N_O_ = @iRecno
                     ##CHECK_TRANSACTION_COMMIT
               --Tratamento para gravacao da CTK para contabilizacao aglutinada
               IF @cAglut = '1' 
               Begin
                  Declare cCurAglut insensitive cursor for
                  SELECT A.R_E_C_N_O_, ISNULL(RTRIM(A.CTK_RECCV3),'0') FROM CTK### A 
                     LEFT JOIN CTK### B ON
                     A.CTK_FILIAL = B.CTK_FILIAL AND
                     A.CTK_SEQUEN = B.CTK_SEQUEN AND 
                     A.CTK_DATA   = B.CTK_DATA AND
                     A.CTK_DC   = B.CTK_DC AND
                     A.CTK_DEBITO = B.CTK_DEBITO AND
                     A.CTK_CREDIT = B.CTK_CREDIT AND
                     A.CTK_CCD = B.CTK_CCD  AND
                     A.CTK_CCC = B.CTK_CCC  AND
                     A.CTK_ITEMD = B.CTK_ITEMD  AND 
                     A.CTK_ITEMC = B.CTK_ITEMC AND
                     A.CTK_CLVLDB = B.CTK_CLVLDB AND
                     A.CTK_CLVLCR = B.CTK_CLVLCR AND 
                     A.CTK_TPSALD = B.CTK_TPSALD AND 
                     A.CTK_LP = B.CTK_LP AND
                     ##IF_001({|| GetNewPar("MV_AGLHIST",.F.) })
                        A.CTK_HAGLUT = B.CTK_HAGLUT AND 
                     ##ENDIF_001
                     A.CTK_DC IN('1','2','3') AND
                     A.D_E_L_E_T_ = ' ' AND
                     B.D_E_L_E_T_ = ' ' 
                     WHERE B.R_E_C_N_O_ = @nCT2_RECCTK 
                     FOR READ ONLY
                  Open cCurAglut
                  Fetch cCurAglut into  @iRecAglCTK, @iRecAglCV3
                  While (@@FETCH_STATUS = 0) begin
                     IF @iRecAglCTK > 0 
                     BEGIN
                        begin tran
                           UPDATE CTK### SET CTK_RECDES =  @iRecno
                           ##FIELDP12( 'CT2.CT2_MSUIDT' )
                              , CTK_IDDEST = @CT2_MSUIDT
                           ##ENDFIELDP12
                           WHERE R_E_C_N_O_ = @iRecAglCTK AND CTK_RECDES = ' '
                        commit tran 
                     End
                     IF @iRecAglCV3 > 0
                     BEGIN
                        begin tran
                           UPDATE CV3### SET CV3_RECDES =  @iRecno
                           ##FIELDP12( 'CT2.CT2_MSUIDT' )
                              , CV3_IDDEST =  @CT2_MSUIDT
                           ##ENDFIELDP12
                           WHERE R_E_C_N_O_ = @iRecAglCV3 AND CV3_RECDES = ' '
                        commit tran 
                     End
                  Fetch cCurAglut into @iRecAglCTK, @iRecAglCV3
                  End
                  Close cCurAglut
                  Deallocate cCurAglut

               END ELSE BEGIN
               
                  SELECT @CTK_DATA  = CTK_DATA , @CTK_SEQUEN  = CTK_SEQUEN , @CTK_DC  = CTK_DC , @CTK_LP  = CTK_LP , @CTK_LPSEQ  = CTK_LPSEQ 
                  , @CTK_KEY  = CTK_KEY , @CTK_DEBITO  = CTK_DEBITO , @CTK_CREDIT  = CTK_CREDIT , @CTK_VLR01  = CTK_VLR01 
                  , @CTK_VLR02  = CTK_VLR02 , @CTK_VLR03  = CTK_VLR03 , @CTK_VLR04  = CTK_VLR04 , @CTK_VLR05  = CTK_VLR05 
                  , @CTK_HIST  = CTK_HIST , @CTK_CCC  = CTK_CCC , @CTK_CCD  = CTK_CCD , @CTK_ITEMC  = CTK_ITEMC , @CTK_ITEMD  = CTK_ITEMD 
                  , @CTK_CLVLDB  = CTK_CLVLDB , @CTK_CLVLCR  = CTK_CLVLCR , @CTK_MOEDLC  = CTK_MOEDLC , @CTK_RECCV3  = CTK_RECCV3 
                     ##FIELDP87( 'CTK.CTK_TABORI' )
                        ##FIELDP02( 'CV3.CV3_TABORI' )
                           , @CTK_TABORI  = CTK_TABORI 
                        ##ENDFIELDP02
                     ##ENDFIELDP87
                     ##FIELDP03( 'CV3.CV3_RECORI' )
                        ##FIELDP04( 'CTK.CTK_RECORI' )
                           , @CTK_RECORI  = CTK_RECORI  
                        ##ENDFIELDP04
                     ##ENDFIELDP03
                     ##FIELDP05( 'CV3.CV3_RECDES' )
                        ##FIELDP06( 'CTK.CTK_RECDES' )
                           , @CTK_RECDES  = CTK_RECDES  
                        ##ENDFIELDP06
                     ##ENDFIELDP05
                  FROM CTK###
                  WHERE R_E_C_N_O_  = @nCT2_RECCTK  and D_E_L_E_T_  = ' ' 
                  IF @CTK_RECCV3  = ' ' 
                  BEGIN       
                        SELECT @iRecCV3  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 )
                        FROM CV3###
                        SELECT @iRecCV3  = @iRecCV3  + 1 

                        ##TRATARECNO @iRecCV3\
                        ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                        INSERT INTO CV3###(CV3_FILIAL , CV3_DTSEQ , CV3_SEQUEN , CV3_DC , CV3_LP , CV3_LPSEQ , CV3_KEY , CV3_DEBITO , 
                                 CV3_CREDIT , CV3_VLR01 , CV3_VLR02 , CV3_VLR03 , CV3_VLR04 , CV3_VLR05 , CV3_HIST , CV3_CCC , CV3_CCD , 
                                 CV3_ITEMC , CV3_ITEMD , CV3_CLVLDB , CV3_CLVLCR , CV3_MOEDLC ,
                                 ##FIELDP87( 'CTK.CTK_TABORI' )
                                    ##FIELDP02( 'CV3.CV3_TABORI' )
                                       CV3_TABORI ,
                                    ##ENDFIELDP02
                                 ##ENDFIELDP87
                                 ##FIELDP03( 'CV3.CV3_RECORI' )
                                    ##FIELDP04( 'CTK.CTK_RECORI' )
                                       CV3_RECORI ,  
                                    ##ENDFIELDP04
                                 ##ENDFIELDP03
                                 ##FIELDP05( 'CV3.CV3_RECDES' )
                                    ##FIELDP06( 'CTK.CTK_RECDES' )
                                       CV3_RECDES , 
                                    ##ENDFIELDP06
                                 ##ENDFIELDP05
                                 R_E_C_N_O_ ) 
                        VALUES (@cFilCV3 , @CTK_DATA , @CTK_SEQUEN , @CTK_DC , @CTK_LP , @CTK_LPSEQ , @CTK_KEY , @CTK_DEBITO , 
                                 @CTK_CREDIT , @CTK_VLR01 , @CTK_VLR02 , @CTK_VLR03 , @CTK_VLR04 , @CTK_VLR05 , @CTK_HIST , @CTK_CCC , 
                                 @CTK_CCD , @CTK_ITEMC , @CTK_ITEMD , @CTK_CLVLDB , @CTK_CLVLCR , @CTK_MOEDLC ,
                                 ##FIELDP87( 'CTK.CTK_TABORI' )
                                    ##FIELDP02( 'CV3.CV3_TABORI' )
                                          @CTK_TABORI ,
                                    ##ENDFIELDP02
                                 ##ENDFIELDP87
                                 ##FIELDP03( 'CV3.CV3_RECORI' )
                                    ##FIELDP04( 'CTK.CTK_RECORI' )
                                       @CTK_RECORI ,  
                                    ##ENDFIELDP04
                                 ##ENDFIELDP03
                                 ##FIELDP05( 'CV3.CV3_RECDES' )
                                    ##FIELDP06( 'CTK.CTK_RECDES' )
                                       @iRecno , 
                                    ##ENDFIELDP06
                                 ##ENDFIELDP05
                                 @iRecCV3 )
                        ##CHECK_TRANSACTION_COMMIT
                        ##FIMTRATARECNO
                  END 
                  ELSE 
                  BEGIN 
                     UPDATE CV3###
                        SET CV3_RECDES  = @iRecno 
                        ##FIELDP12( 'CT2.CT2_MSUIDT' )
                           , CV3_IDDEST  = @CT2_MSUIDT
                        ##ENDFIELDP12 
                     WHERE R_E_C_N_O_  = CONVERT( Integer ,@CTK_RECCV3 ) AND CV3_RECDES = ' '
                  END 
                  SELECT @iNroRegs  = @iNroRegs  + 1 
                  UPDATE CTK###
                     SET CTK_RECDES  = @iRecno 
                     ##FIELDP12( 'CT2.CT2_MSUIDT' )
                        , CTK_IDDEST  = @CT2_MSUIDT 
                     ##ENDFIELDP12
                  WHERE R_E_C_N_O_  = @nCT2_RECCTK AND CTK_RECDES = ' '
               End
                  IF @IN_lGrvTRW  = '1' 
                  BEGIN 
                     SELECT @iRecTRW  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 )
                     FROM TRW###_SP 
                     SELECT @iRecTRW  = @iRecTRW  + 1 
                     SELECT @iLoop = 0
                              ##TRATARECNO @iRecTRW\ 
                              ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                              INSERT INTO 
                                 TRW###_SP
                              (CT2_FILIAL , CT2_DATA , CT2_LOTE , CT2_SBLOTE , CT2_DOC , CT2_MOEDLC , CT2_TPSALD , 
                                    CT2_SEQUEN , CT2_DC , CT2_DEBITO , CT2_CREDIT , CT2_VALOR , CT2_CCD , CT2_CCC , CT2_ITEMD , CT2_ITEMC , 
                                    CT2_CLVLDB , CT2_CLVLCR , CT2_EMPORI , CT2_FILORI , CT2_LINHA , CT2_ATIVDE , R_E_C_N_O_ 
                                    ##IF_003({|| IIF(FindFunction( 'CTBISCUBE' ), CTBISCUBE(), .F. )})
                                       ##FIELDPB7( 'CT2.CT2_EC05DB' )
                                          CT2_EC05DB 
                                       ##ENDFIELDPB7
                                       ##FIELDP03( 'CT2.CT2_EC05CR' )
                                          cCT2_EC05CR 
                                       ##ENDFIELDP03
                                       ##FIELDP04( 'CT2.CT2_EC06DB' )
                                       cCT2_EC06DB 
                                       ##ENDFIELDP04
                                       ##FIELDP05( 'CT2.CT2_EC06CR' )
                                       CT2_EC06CR ,
                                       ##ENDFIELDP05
                                       ##FIELDP06( 'CT2.CT2_EC07DB' )
                                       CT2_EC07DB 
                                       ##ENDFIELDP06
                                       ##FIELDP07( 'CT2.CT2_EC07CR' )
                                       CT2_EC07CR 
                                       ##ENDFIELDP07
                                       ##FIELDP08( 'CT2.CT2_EC08DB' )
                                       CT2_EC08DB 
                                       ##ENDFIELDP08
                                       ##FIELDP09( 'CT2.CT2_EC08CR' )
                                       CT2_EC08CR 
                                       ##ENDFIELDP09
                                       ##FIELDP10( 'CT2.CT2_EC09DB' )
                                       CT2_EC09DB 
                                       ##ENDFIELDP10
                                       ##FIELDP11( 'CT2.CT2_EC09CR' )
                                       CT2_EC09CR  
                                       ##ENDFIELDP11
                                    ##ENDIF_003
                                    )
                              VALUES (@cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_MOEDLC , @cCT2_TPSALD , 
                                    @cCT2_SEQUEN , @cCT2_DC , @cCT2_DEBITO , @cCT2_CREDIT , @nCT2_VALOR , @cCT2_CCD , @cCT2_CCC , @cCT2_ITEMD , 
                                    @cCT2_ITEMC , @cCT2_CLVLDB , @cCT2_CLVLCR , @cCT2_EMPORI , @cCT2_FILORI , @cCT2_LINHA , @IN_ThreadID , 
                                    @iRecTRW 
                                    ##IF_004({|| IIF(FindFunction( 'CTBISCUBE' ), CTBISCUBE(), .F. )})
                                       ##FIELDPB8( 'CT2.CT2_EC05DB' )
                                       , @cCT2_EC05DB 
                                       ##ENDFIELDPB8
                                       ##FIELDP03( 'CT2.CT2_EC05CR' )
                                          , @cCT2_EC05CR 
                                       ##ENDFIELDP03
                                       ##FIELDP04( 'CT2.CT2_EC06DB' )
                                       , @cCT2_EC06DB 
                                       ##ENDFIELDP04
                                       ##FIELDP05( 'CT2.CT2_EC06CR' )
                                       , @cCT2_EC06CR 
                                       ##ENDFIELDP05
                                       ##FIELDP06( 'CT2.CT2_EC07DB' )
                                       , @cCT2_EC07DB 
                                       ##ENDFIELDP06
                                       ##FIELDP07( 'CT2.CT2_EC07CR' )
                                       , @cCT2_EC07CR 
                                       ##ENDFIELDP07
                                       ##FIELDP08( 'CT2.CT2_EC08DB' )
                                       , @cCT2_EC08DB 
                                       ##ENDFIELDP08
                                       ##FIELDP09( 'CT2.CT2_EC08CR' )
                                       , @cCT2_EC08CR 
                                       ##ENDFIELDP09
                                       ##FIELDP10( 'CT2.CT2_EC09DB' )
                                       , @cCT2_EC09DB 
                                       ##ENDFIELDP10
                                       ##FIELDP11( 'CT2.CT2_EC09CR' )
                                       , @cCT2_EC09CR  
                                       ##ENDFIELDP11
                                    ##ENDIF_004
                                    )
                           ##CHECK_TRANSACTION_COMMIT
                           ##FIMTRATARECNO
                     SELECT @lNoMltSld  = '1' 
                  END 
               END
            SELECT @nContador  = @nContador  + 1 
         END 
      ##FIELDP04( 'CT2.CT2_CTRLSD' )
         END
      ##ENDFIELDP04            
      FETCH cCursorCTB 
       INTO @cCT2_FILIAL --recarrega cursor
   END 
   CLOSE cCursorCTB
   DEALLOCATE cCursorCTB
   SELECT @OUT_RET  = '1' 
END 