-- Procedure creation CT105LOKPR_
CREATE PROCEDURE CTBA105B_## (
    @IN_DATALANC Char( 8 ) , 
    @IN_FILIAL Char( 'CT2_FILIAL' ) , 
    @IN_cAmarracao Char( 1 ),
    @IN_lDcdcuso Char( 1 ),
    @IN_cTmpName char (20),
    @OUT_RET Char( 1 )  output,
    @OUT_ERROR Char( 1000 )  output ) AS
 
DECLARE @nMoedaInUse Integer -- Declaration of variables
DECLARE @nMoedDtUse Integer
DECLARE @nContador Integer
DECLARE @nContador1 Integer
DECLARE @cDigConta VarChar( 'CT1_DC' )
DECLARE @cCT1_CCOBRG VarChar( 'CT1_CCOBRG' )
DECLARE @cCT1_ITOBRG VarChar( 'CT1_ITOBRG' )
DECLARE @cCT1_CLOBRG VarChar( 'CT1_CLOBRG' )
DECLARE @cCT1_ACITEM VarChar( 'CT1_ACITEM' )
DECLARE @cCT1_ACCLVL VarChar( 'CT1_ACCLVL' )
DECLARE @cCT1_ACCUST VarChar( 'CT1_ACCUST' )
##FIELDPC5( 'CT1.CT1_05OBRG' )
   DECLARE @cCT1_05OBRG VarChar( 'CT1_05OBRG' )
   DECLARE @cCT1_ACET05 VarChar( 'CT1_ACET05' )
##ENDFIELDPC5
##FIELDPC6( 'CT1.CT1_06OBRG' )
   DECLARE @cCT1_06OBRG VarChar( 'CT1_06OBRG' )
   DECLARE @cCT1_ACET06 VarChar( 'CT1_ACET06' )   
##ENDFIELDPC6
##FIELDPC7( 'CT1.CT1_07OBRG' )
   DECLARE @cCT1_07OBRG VarChar( 'CT1_07OBRG' )
   DECLARE @cCT1_ACET07 VarChar( 'CT1_ACET07' )
##ENDFIELDPC7
##FIELDPC8( 'CT1.CT1_08OBRG' )
   DECLARE @cCT1_08OBRG VarChar( 'CT1_08OBRG' )
   DECLARE @cCT1_ACET08 VarChar( 'CT1_ACET08' )     
##ENDFIELDPC8
##FIELDPC9( 'CT1.CT1_09OBRG' )
   DECLARE @cCT1_09OBRG VarChar( 'CT1_09OBRG ' )
   DECLARE @cCT1_ACET09 VarChar( 'CT1_ACET09' )
##ENDFIELDPC9
DECLARE @cCTT_ITOBRG VarChar( 'CTT_ITOBRG' )
DECLARE @cCTT_CLOBRG VarChar( 'CTT_CLOBRG' )
DECLARE @cCTD_CLOBRG VarChar( 'CTD_CLOBRG' )
DECLARE @cRetRegra VarChar( 1 )
DECLARE @cFilCT1 Char( 'CT1_FILIAL' )
DECLARE @cFilCTT Char( 'CT1_FILIAL' )
DECLARE @cFilCTD Char( 'CT1_FILIAL'  )
DECLARE @cFilCTH Char( 'CT1_FILIAL'  )
DECLARE @cFilCTO Char( 'CT1_FILIAL'  )
DECLARE @cFilCTP Char( 'CT1_FILIAL'  )
DECLARE @cFilCTE Char( 'CT1_FILIAL'  )
DECLARE @cFilCTG Char( 'CT1_FILIAL'  )
DECLARE @cFilCTA Char( 'CT1_FILIAL'  )
DECLARE @cAux Char( 03 )
DECLARE @cExecSql nvarchar(MAX)

##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
   DECLARE @cCursorCTB Char( 2 )
   DECLARE @nfim_CUR FLOAT 
##ENDIF_003

##IF_005({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})      
   DECLARE @cCursorCTB CHAR(1)
##ENDIF_005

BEGIN
   SELECT @OUT_RET  = '0' 
   SELECT @OUT_ERROR  = ''
   SELECT @cAux  = 'CT1' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCT1 output 
   SELECT @cAux  = 'CTT' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCTT output 
   SELECT @cAux  = 'CTD' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCTD output 
   SELECT @cAux  = 'CTH' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCTH output 
   SELECT @cAux  = 'CTO' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCTO output 
   SELECT @cAux  = 'CTP' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCTP output 
   SELECT @cAux  = 'CTE' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCTE output 
   SELECT @cAux  = 'CTG' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCTG output 
   SELECT @cAux  = 'CTA' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCTA output 
   SELECT @cCT2_FILIAL  = ' ' --sobreescreve cvarini
   SELECT @nCT2_RECCTK  = 0 
   SELECT @nCT2_REC_WT  = 0 
   SELECT @cCT2_ALI_WT  = ' ' 
   SELECT @nCT2_RECNO  = 0 
   SELECT @nMODIFIED  = 0 
   SELECT @nATUSALDO  = 0 
   SELECT @lCT2_FLAG  = '0' 
   SELECT @iRecno  = 0 

   SELECT @cCT2_INCONS  = '2'
-- Cursor declaration cCursorCTB
   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
       SELECT @cExecSql = ' DECLARE cCursorCTB insensitive CURSOR FOR '  
   ##ENDIF_001

   SELECT @cExecSql = @cExecSql || ' SELECT CT2_FILIAL --sobreescreve cCpoCursor '
   SELECT @cExecSql = @cExecSql || ' FROM ' 
   SELECT @cExecSql = @cExecSql || @IN_cTmpName || " WHERE D_E_L_E_T_ = ''"
   SELECT @cExecSql = @cExecSql || ' ' 
   SELECT @cExecSql = @cExecSql || "'' " 
   SELECT @cExecSql = @cExecSql || " AND CT2_FLAG = ''"
   SELECT @cExecSql = @cExecSql || 'F' 
   SELECT @cExecSql = @cExecSql || "'' " 

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = @cExecSql || " FOR READ ONLY "
      exec sp_executesql @cExecSql
      OPEN cCursorCTB
   ##ENDIF_001     

   ##IF_002({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})   
      OPEN cCursorCTB
   ##ENDIF_002

   ##IF_003({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
      OPEN cCursorCTB --Nao tirar de dentro do IF - sera substituido no pos compile
   ##ENDIF_003   

   FETCH cCursorCTB 
    INTO @cCT2_FILIAL --sobreescreve cVarProc 1
   WHILE ( (@@FETCH_STATUS  = 0 ) )
   BEGIN

   SELECT @cCT2_VLD01  = ' ' 
   SELECT @cCT2_VLD02  = ' ' 
   SELECT @cCT2_VLD03  = ' ' 
   SELECT @cCT2_VLD04  = ' ' 
   SELECT @cCT2_VLD05  = ' ' 
   SELECT @cCT2_VLD06  = ' ' 
   SELECT @cCT2_VLD07  = ' ' 
   SELECT @cCT2_VLD08  = ' ' 
   SELECT @cCT2_VLD09  = ' ' 
   SELECT @cCT2_VLD10  = ' ' 
   SELECT @cCT2_VLD11  = ' ' 
   SELECT @cCT2_VLD12  = ' ' 
   SELECT @cCT2_VLD13  = ' ' 
   SELECT @cCT2_VLD14  = ' ' 
   SELECT @cCT2_VLD15  = ' ' 
   SELECT @cCT2_VLD16  = ' ' 
   SELECT @cCT2_VLD17  = ' ' 
   SELECT @cCT2_VLD18  = ' ' 
   SELECT @cCT2_VLD19  = ' ' 
   SELECT @cCT2_VLD20  = ' ' 
   SELECT @cCT2_VLD21  = ' ' 
   SELECT @cCT2_VLD22  = ' ' 
   SELECT @cCT2_VLD23  = ' ' 
   SELECT @cCT2_VLD24  = ' ' 
   SELECT @cCT2_VLD25  = ' ' 
   SELECT @cCT2_INCONS = ' ' 
   SELECT @mCT2_INCDET = '' 
   SELECT @cExecSql = ' '
  
   
      -- VALIDACAO 01  - Indicador deb/cred/part.dobrada/contin. historico esta preenchido
      IF @cCT2_DC  = ' ' 
      BEGIN 
         SELECT @cCT2_VLD01  = '1' 
         SELECT @cCT2_INCONS  = '1' 
         SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO01' || ' | '
      END 
      IF @cCT2_DC  != '4' 
      BEGIN 
         -- VALIDACAO 02  -- verificar criterio de conversao=5 e valor diferente de zero a partir da moeda 2
         ##FIELDP02( 'CT2.CT2_VLR02' )
            IF @nCT2_VALR02 <> 0 and SUBSTRING(@cCT2_CONVER, 02, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR03' )
            IF @nCT2_VALR03 <> 0 and SUBSTRING(@cCT2_CONVER, 03, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR04' )
            IF @nCT2_VALR04 <> 0 and SUBSTRING(@cCT2_CONVER, 04, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR05' )
            IF @nCT2_VALR05 <> 0 and SUBSTRING(@cCT2_CONVER, 05, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR06' )
            IF @nCT2_VALR06 <> 0 and SUBSTRING(@cCT2_CONVER, 06, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR07' )
            IF @nCT2_VALR07 <> 0 and SUBSTRING(@cCT2_CONVER, 07, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR08' )
            IF @nCT2_VALR08 <> 0 and SUBSTRING(@cCT2_CONVER, 08, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR09' )
            IF @nCT2_VALR09 <> 0 and SUBSTRING(@cCT2_CONVER, 09, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR10' )
            IF @nCT2_VALR10 <> 0 and SUBSTRING(@cCT2_CONVER, 10, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR11' )
            IF @nCT2_VALR11 <> 0 and SUBSTRING(@cCT2_CONVER, 11, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR12' )
            IF @nCT2_VALR12 <> 0 and SUBSTRING(@cCT2_CONVER, 12, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR13' )
            IF @nCT2_VALR13 <> 0 and SUBSTRING(@cCT2_CONVER, 13, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR14' )
            IF @nCT2_VALR14 <> 0 and SUBSTRING(@cCT2_CONVER, 14, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR15' )
            IF @nCT2_VALR15 <> 0 and SUBSTRING(@cCT2_CONVER, 15, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR16' )
            IF @nCT2_VALR16 <> 0 and SUBSTRING(@cCT2_CONVER, 16, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR17' )
            IF @nCT2_VALR17 <> 0 and SUBSTRING(@cCT2_CONVER, 17, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR18' )
            IF @nCT2_VALR18 <> 0 and SUBSTRING(@cCT2_CONVER, 18, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR19' )
            IF @nCT2_VALR19 <> 0 and SUBSTRING(@cCT2_CONVER, 19, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR20' )
            IF @nCT2_VALR20 <> 0 and SUBSTRING(@cCT2_CONVER, 20, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR21' )
            IF @nCT2_VALR21 <> 0 and SUBSTRING(@cCT2_CONVER, 21, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR22' )
            IF @nCT2_VALR22 <> 0 and SUBSTRING(@cCT2_CONVER, 22, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR23' )
            IF @nCT2_VALR23 <> 0 and SUBSTRING(@cCT2_CONVER, 23, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR24' )
            IF @nCT2_VALR24 <> 0 and SUBSTRING(@cCT2_CONVER, 24, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR25' )
            IF @nCT2_VALR25 <> 0 and SUBSTRING(@cCT2_CONVER, 25, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR26' )
            IF @nCT2_VALR26 <> 0 and SUBSTRING(@cCT2_CONVER, 26, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR27' )
            IF @nCT2_VALR27 <> 0 and SUBSTRING(@cCT2_CONVER, 27, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR28' )
            IF @nCT2_VALR28 <> 0 and SUBSTRING(@cCT2_CONVER, 28, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR29' )
            IF @nCT2_VALR29 <> 0 and SUBSTRING(@cCT2_CONVER, 29, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR30' )
            IF @nCT2_VALR30 <> 0 and SUBSTRING(@cCT2_CONVER, 30, 1) = '5'
            BEGIN
               SELECT @cCT2_VLD02 = '2'
            END
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR31' )
            IF @nCT2_VALR31  <> 0  and SUBSTRING ( @cCT2_CONVER , 31 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR32' )
            IF @nCT2_VALR32  <> 0  and SUBSTRING ( @cCT2_CONVER , 32 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR33' )
            IF @nCT2_VALR33  <> 0  and SUBSTRING ( @cCT2_CONVER , 33 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR34' )
            IF @nCT2_VALR34  <> 0  and SUBSTRING ( @cCT2_CONVER , 34 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR35' )
            IF @nCT2_VALR35  <> 0  and SUBSTRING ( @cCT2_CONVER , 35 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR36' )
            IF @nCT2_VALR36  <> 0  and SUBSTRING ( @cCT2_CONVER , 36 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR37' )
            IF @nCT2_VALR37  <> 0  and SUBSTRING ( @cCT2_CONVER , 37 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR38' )
            IF @nCT2_VALR38  <> 0  and SUBSTRING ( @cCT2_CONVER , 38 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR39' )
            IF @nCT2_VALR39  <> 0  and SUBSTRING ( @cCT2_CONVER , 39 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR40' )
            IF @nCT2_VALR40  <> 0  and SUBSTRING ( @cCT2_CONVER , 40 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR41' )
            IF @nCT2_VALR41  <> 0  and SUBSTRING ( @cCT2_CONVER , 41 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR42' )
            IF @nCT2_VALR42  <> 0  and SUBSTRING ( @cCT2_CONVER , 42 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR43' )
            IF @nCT2_VALR43  <> 0  and SUBSTRING ( @cCT2_CONVER , 43 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR44' )
            IF @nCT2_VALR44  <> 0  and SUBSTRING ( @cCT2_CONVER , 44 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR45' )
            IF @nCT2_VALR45  <> 0  and SUBSTRING ( @cCT2_CONVER , 45 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR46' )
            IF @nCT2_VALR46  <> 0  and SUBSTRING ( @cCT2_CONVER , 46 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR47' )
            IF @nCT2_VALR47  <> 0  and SUBSTRING ( @cCT2_CONVER , 47 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR48' )
            IF @nCT2_VALR48  <> 0  and SUBSTRING ( @cCT2_CONVER , 48 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR49' )
            IF @nCT2_VALR49  <> 0  and SUBSTRING ( @cCT2_CONVER , 49 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR50' )
            IF @nCT2_VALR50  <> 0  and SUBSTRING ( @cCT2_CONVER , 50 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR51' )
            IF @nCT2_VALR51  <> 0  and SUBSTRING ( @cCT2_CONVER , 51 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR52' )
            IF @nCT2_VALR52  <> 0  and SUBSTRING ( @cCT2_CONVER , 52 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR53' )
            IF @nCT2_VALR53  <> 0  and SUBSTRING ( @cCT2_CONVER , 53 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR54' )
            IF @nCT2_VALR54  <> 0  and SUBSTRING ( @cCT2_CONVER , 54 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR55' )
            IF @nCT2_VALR55  <> 0  and SUBSTRING ( @cCT2_CONVER , 55 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR56' )
            IF @nCT2_VALR56  <> 0  and SUBSTRING ( @cCT2_CONVER , 56 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR57' )
            IF @nCT2_VALR57  <> 0  and SUBSTRING ( @cCT2_CONVER , 57 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR58' )
            IF @nCT2_VALR58  <> 0  and SUBSTRING ( @cCT2_CONVER , 58 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR59' )
            IF @nCT2_VALR59  <> 0  and SUBSTRING ( @cCT2_CONVER , 59 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR60' )
            IF @nCT2_VALR60  <> 0  and SUBSTRING ( @cCT2_CONVER , 60 , 1 ) = '5' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR61' )
            IF @nCT2_VALR61  <> 0  and SUBSTRING ( @cCT2_CONVER , 61 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR62' )
            IF @nCT2_VALR62  <> 0  and SUBSTRING ( @cCT2_CONVER , 62 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR63' )
            IF @nCT2_VALR63  <> 0  and SUBSTRING ( @cCT2_CONVER , 63 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR64' )
            IF @nCT2_VALR64  <> 0  and SUBSTRING ( @cCT2_CONVER , 64 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR65' )
            IF @nCT2_VALR65  <> 0  and SUBSTRING ( @cCT2_CONVER , 65 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR66' )
            IF @nCT2_VALR66  <> 0  and SUBSTRING ( @cCT2_CONVER , 66 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR67' )
            IF @nCT2_VALR67  <> 0  and SUBSTRING ( @cCT2_CONVER , 67 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR68' )
            IF @nCT2_VALR68  <> 0  and SUBSTRING ( @cCT2_CONVER , 68 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR69' )
            IF @nCT2_VALR69  <> 0  and SUBSTRING ( @cCT2_CONVER , 69 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR70' )
            IF @nCT2_VALR70  <> 0  and SUBSTRING ( @cCT2_CONVER , 70 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR71' )
            IF @nCT2_VALR71  <> 0  and SUBSTRING ( @cCT2_CONVER , 71 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR72' )
            IF @nCT2_VALR72  <> 0  and SUBSTRING ( @cCT2_CONVER , 72 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR73' )
            IF @nCT2_VALR73  <> 0  and SUBSTRING ( @cCT2_CONVER , 73 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR74' )
            IF @nCT2_VALR74  <> 0  and SUBSTRING ( @cCT2_CONVER , 74 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR75' )
            IF @nCT2_VALR75  <> 0  and SUBSTRING ( @cCT2_CONVER , 75 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR76' )
            IF @nCT2_VALR76  <> 0  and SUBSTRING ( @cCT2_CONVER , 76 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR77' )
            IF @nCT2_VALR77  <> 0  and SUBSTRING ( @cCT2_CONVER , 77 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR78' )
            IF @nCT2_VALR78  <> 0  and SUBSTRING ( @cCT2_CONVER , 78 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR79' )
            IF @nCT2_VALR79  <> 0  and SUBSTRING ( @cCT2_CONVER , 79 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR80' )
            IF @nCT2_VALR80  <> 0  and SUBSTRING ( @cCT2_CONVER , 80 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR81' )
            IF @nCT2_VALR81  <> 0  and SUBSTRING ( @cCT2_CONVER , 81 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR82' )
            IF @nCT2_VALR82  <> 0  and SUBSTRING ( @cCT2_CONVER , 82 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR83' )
            IF @nCT2_VALR83  <> 0  and SUBSTRING ( @cCT2_CONVER , 83 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR84' )
            IF @nCT2_VALR84  <> 0  and SUBSTRING ( @cCT2_CONVER , 84 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR85' )
            IF @nCT2_VALR85  <> 0  and SUBSTRING ( @cCT2_CONVER , 85 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR86' )
            IF @nCT2_VALR86  <> 0  and SUBSTRING ( @cCT2_CONVER , 86 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR87' )
            IF @nCT2_VALR87  <> 0  and SUBSTRING ( @cCT2_CONVER , 87 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR88' )
            IF @nCT2_VALR88  <> 0  and SUBSTRING ( @cCT2_CONVER , 88 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR89' )
            IF @nCT2_VALR89  <> 0  and SUBSTRING ( @cCT2_CONVER , 89 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR90' )
            IF @nCT2_VALR90  <> 0  and SUBSTRING ( @cCT2_CONVER , 90 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR91' )
            IF @nCT2_VALR91  <> 0  and SUBSTRING ( @cCT2_CONVER , 91 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR92' )
            IF @nCT2_VALR92  <> 0  and SUBSTRING ( @cCT2_CONVER , 92 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR93' )
            IF @nCT2_VALR93  <> 0  and SUBSTRING ( @cCT2_CONVER , 93 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR94' )
            IF @nCT2_VALR94  <> 0  and SUBSTRING ( @cCT2_CONVER , 94 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR95' )
            IF @nCT2_VALR95  <> 0  and SUBSTRING ( @cCT2_CONVER , 95 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR96' )
            IF @nCT2_VALR96  <> 0  and SUBSTRING ( @cCT2_CONVER , 96 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR97' )
            IF @nCT2_VALR97  <> 0  and SUBSTRING ( @cCT2_CONVER , 97 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR98' )
            IF @nCT2_VALR98  <> 0  and SUBSTRING ( @cCT2_CONVER , 98 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         ##FIELDP02( 'CT2.CT2_VLR99' )
            IF @nCT2_VALR99  <> 0  and SUBSTRING ( @cCT2_CONVER , 99 , 1 ) = '5' 
            BEGIN 
               SELECT @cCT2_VLD02  = '2' 
            END 
         ##ENDFIELDP02
         IF @cCT2_VLD02  = ' '  and @nCT2_VALOR  = 0 
         BEGIN 
            SELECT @cCT2_VLD02  = '2' 
         END 
         IF @cCT2_VLD02  = '2' 
         BEGIN 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO02' || ' | '
         END 
         --VALIDACAO 03 -- primeiro verificar se todas as moedas estao em uso - CTBMInUse(cCoin4)
         --VALIDACAO 03.1 -- depois moeda na data esta liberada - CtbDtInUse(cCoin4,dDataLanc)
         --VALIDACAO 03.2 -- Verifica CTG ausencia ou bloqueio de calendario. -- CtbDtComp(3,dDataLanc,cCoin4,,cTpSald)
         -- COMECO FOR MOEDAS 02
         EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALOR , '01', @cCT2_VLD03 , @cCT2_VLD03 output 
         ##FIELDP02( 'CT2.CT2_VLR02' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR02 , '02' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP02
         ##FIELDP03( 'CT2.CT2_VLR03' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR03 , '03' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP03
         ##FIELDP04( 'CT2.CT2_VLR04' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR04 , '04' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP04
         ##FIELDP05( 'CT2.CT2_VLR05' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR05 , '05' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP05
         ##FIELDP06( 'CT2.CT2_VLR06' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR06 , '06' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP06
         ##FIELDP07( 'CT2.CT2_VLR07' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR07 , '07' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP07
         ##FIELDP08( 'CT2.CT2_VLR08' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR08 , '08' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP08
         ##FIELDP09( 'CT2.CT2_VLR09' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR09 , '09' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP09
         ##FIELDP10( 'CT2.CT2_VLR10' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR10 , '10' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP10
         ##FIELDP11( 'CT2.CT2_VLR11' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR11 , '11' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP11
         ##FIELDP12( 'CT2.CT2_VLR12' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR12 , '12' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP12
         ##FIELDP13( 'CT2.CT2_VLR13' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR13 , '13' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP13
         ##FIELDP14( 'CT2.CT2_VLR14' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR14 , '14' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP14
         ##FIELDP15( 'CT2.CT2_VLR15' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR15 , '15' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP15
         ##FIELDP16( 'CT2.CT2_VLR16' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR16 , '16' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP16
         ##FIELDP17( 'CT2.CT2_VLR17' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR17 , '17' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP17
         ##FIELDP18( 'CT2.CT2_VLR18' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR18 , '18' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP18
         ##FIELDP19( 'CT2.CT2_VLR19' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR19 , '19' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP19
         ##FIELDP20( 'CT2.CT2_VLR20' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR20 , '20' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP20
         ##FIELDP21( 'CT2.CT2_VLR21' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR21 , '21' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP21
         ##FIELDP22( 'CT2.CT2_VLR22' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR22 , '22' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP22
         ##FIELDP23( 'CT2.CT2_VLR23' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR23 , '23' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP23
         ##FIELDP24( 'CT2.CT2_VLR24' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR24 , '24' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP24
         ##FIELDP25( 'CT2.CT2_VLR25' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR25 , '25' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP25
         ##FIELDP26( 'CT2.CT2_VLR26' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR26 , '26' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP26
         ##FIELDP27( 'CT2.CT2_VLR27' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR27 , '27' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP27
         ##FIELDP28( 'CT2.CT2_VLR28' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR28 , '28' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP28
         ##FIELDP29( 'CT2.CT2_VLR29' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR29 , '29' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP29
         ##FIELDP30( 'CT2.CT2_VLR30' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR30 , '30' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP30
         ##FIELDP31( 'CT2.CT2_VLR31' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR31 , '31' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP31
         ##FIELDP32( 'CT2.CT2_VLR32' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR32 , '32' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP32
         ##FIELDP33( 'CT2.CT2_VLR33' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR33 , '33' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP33
         ##FIELDP34( 'CT2.CT2_VLR34' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR34 , '34' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP34
         ##FIELDP35( 'CT2.CT2_VLR35' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR35 , '35' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP35
         ##FIELDP36( 'CT2.CT2_VLR36' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR36 , '36' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP36
         ##FIELDP37( 'CT2.CT2_VLR37' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR37 , '37' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP37
         ##FIELDP38( 'CT2.CT2_VLR38' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR38 , '38' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP38
         ##FIELDP39( 'CT2.CT2_VLR39' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR39 , '39' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP39
         ##FIELDP40( 'CT2.CT2_VLR40' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR40 , '40' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP40
         ##FIELDP41( 'CT2.CT2_VLR41' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR41 , '41' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP41
         ##FIELDP42( 'CT2.CT2_VLR42' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR42 , '42' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP42
         ##FIELDP43( 'CT2.CT2_VLR43' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR43 , '43' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP43
         ##FIELDP44( 'CT2.CT2_VLR44' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR44 , '44' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP44
         ##FIELDP45( 'CT2.CT2_VLR45' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR45 , '45' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP45
         ##FIELDP46( 'CT2.CT2_VLR46' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR46 , '46' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP46
         ##FIELDP47( 'CT2.CT2_VLR47' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR47 , '47' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP47
         ##FIELDP48( 'CT2.CT2_VLR48' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR48 , '48' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP48
         ##FIELDP49( 'CT2.CT2_VLR49' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR49 , '49' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP49
         ##FIELDP50( 'CT2.CT2_VLR50' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR50 , '50' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP50
         ##FIELDP51( 'CT2.CT2_VLR51' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR51 , '51' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP51
         ##FIELDP52( 'CT2.CT2_VLR52' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR52 , '52' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP52
         ##FIELDP53( 'CT2.CT2_VLR53' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR53 , '53' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP53
         ##FIELDP54( 'CT2.CT2_VLR54' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR54 , '54' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP54
         ##FIELDP55( 'CT2.CT2_VLR55' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR55 , '55' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP55
         ##FIELDP56( 'CT2.CT2_VLR56' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR56 , '56' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP56
         ##FIELDP57( 'CT2.CT2_VLR57' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR57 , '57' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP57
         ##FIELDP58( 'CT2.CT2_VLR58' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR58 , '58' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP58
         ##FIELDP59( 'CT2.CT2_VLR59' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR59 , '59' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP59
         ##FIELDP60( 'CT2.CT2_VLR60' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR60 , '60' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP60
         ##FIELDP61( 'CT2.CT2_VLR61' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR61 , '61' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP61
         ##FIELDP62( 'CT2.CT2_VLR62' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR62 , '62' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP62
         ##FIELDP63( 'CT2.CT2_VLR63' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR63 , '63' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP63
         ##FIELDP64( 'CT2.CT2_VLR64' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR64 , '64' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP64
         ##FIELDP65( 'CT2.CT2_VLR65' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR65 , '65' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP65
         ##FIELDP66( 'CT2.CT2_VLR66' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR66 , '66' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP66
         ##FIELDP67( 'CT2.CT2_VLR67' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR67 , '67' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP67
         ##FIELDP68( 'CT2.CT2_VLR68' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR68 , '68' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP68
         ##FIELDP69( 'CT2.CT2_VLR69' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR69 , '69' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP69
         ##FIELDP70( 'CT2.CT2_VLR70' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR70 , '70' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP70
         ##FIELDP71( 'CT2.CT2_VLR71' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR71 , '71' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP71
         ##FIELDP72( 'CT2.CT2_VLR72' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR72 , '72' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP72
         ##FIELDP73( 'CT2.CT2_VLR73' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR73 , '73' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP73
         ##FIELDP74( 'CT2.CT2_VLR74' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR74 , '74' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP74
         ##FIELDP75( 'CT2.CT2_VLR75' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR75 , '75' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP75
         ##FIELDP76( 'CT2.CT2_VLR76' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR76 , '76' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP76
         ##FIELDP77( 'CT2.CT2_VLR77' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR77 , '77' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP77
         ##FIELDP78( 'CT2.CT2_VLR78' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR78 , '78' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP78
         ##FIELDP79( 'CT2.CT2_VLR79' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR79 , '79' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP79
         ##FIELDP80( 'CT2.CT2_VLR80' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR80 , '80' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP80
         ##FIELDP81( 'CT2.CT2_VLR81' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR81 , '81' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP81
         ##FIELDP82( 'CT2.CT2_VLR82' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR82 , '82' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP82
         ##FIELDP83( 'CT2.CT2_VLR83' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR83 , '83' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP83
         ##FIELDP84( 'CT2.CT2_VLR84' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR84 , '84' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP84
         ##FIELDP85( 'CT2.CT2_VLR85' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR85 , '85' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP85
         ##FIELDP86( 'CT2.CT2_VLR86' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR86 , '86' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP86
         ##FIELDP87( 'CT2.CT2_VLR87' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR87 , '87' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP87
         ##FIELDP88( 'CT2.CT2_VLR88' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR88 , '88' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP88
         ##FIELDP89( 'CT2.CT2_VLR89' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR89 , '89' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP89
         ##FIELDP90( 'CT2.CT2_VLR90' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR90 , '90' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP90
         ##FIELDP91( 'CT2.CT2_VLR91' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR91 , '91' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP91
         ##FIELDP92( 'CT2.CT2_VLR92' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR92 , '92' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP92
         ##FIELDP93( 'CT2.CT2_VLR93' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR93 , '93' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP93
         ##FIELDP94( 'CT2.CT2_VLR94' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR94 , '94' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP94
         ##FIELDP95( 'CT2.CT2_VLR95' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR95 , '95' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP95
         ##FIELDP96( 'CT2.CT2_VLR96' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR96 , '96' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP96
         ##FIELDP97( 'CT2.CT2_VLR97' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR97 , '97' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP97
         ##FIELDP98( 'CT2.CT2_VLR98' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR98 , '98' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP98
         ##FIELDP99( 'CT2.CT2_VLR99' )
            EXEC CTBA105E_## @IN_DATALANC , @cFilCTO  , @cFilCTP, @cFilCTG, @cFilCTE , @nCT2_VALR99 , '99' , @cCT2_VLD03 , @cCT2_VLD03 output 
         ##ENDFIELDP99
         IF @cCT2_VLD03  = '19' 
         BEGIN 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO19' || ' | '
         END 
         
      -- FIM FOR
      END 
      --VALIDACAO 04 - Historico nao preenchido
      IF @cCT2_VLD04  = ' '  and @cCT2_HIST  = ' ' 
      BEGIN 
         SELECT @cCT2_VLD04  = '3' 
         SELECT @cCT2_INCONS  = '1' 
         SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO03' || ' | '
      END 
      --VALIDACAO 05 - Se eh lancamento de historico complementar, nao pode ter valor
      IF @cCT2_VLD05  = ' '  and @cCT2_DC  = '4'  and @nCT2_VALOR  != 0 
      BEGIN 
         SELECT @cCT2_VLD05  = '4' 
         SELECT @cCT2_INCONS  = '1' 
         SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO04' || ' | '
      END 
      --VALIDACAO 06 - Se eh lancamento de historico complementar, nao pode ter conta prenchida.
      IF @cCT2_VLD06  = ' '  and @cCT2_DC  = '4'  and  (@cCT2_DEBITO  != ' '  or @cCT2_CREDIT  != ' '  or @cCT2_CCD  != ' ' 
         or @cCT2_CCC  != ' '  or @cCT2_ITEMD  != ' '  or @cCT2_ITEMC  != ' '  or @cCT2_CLVLDB  != ' '  or @cCT2_CLVLCR  != ' ' ) 
      BEGIN 
         SELECT @cCT2_VLD06  = '5' 
         SELECT @cCT2_INCONS  = '1' 
         SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO05' || ' | '
      END 
      -------------------------------------D E B I T O-------------------------------------------------------------
      --VALIDACAO 07 - DEBITO - Verifica se a conta foi preenchida
      IF @cCT2_VLD07  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' )  and @cCT2_DEBITO  = ' ' 
      BEGIN 
         SELECT @cCT2_VLD07  = '6' 
         SELECT @cCT2_INCONS  = '1' 
         SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO06' || ' | '
      END 
      -- VALIDACAO 08 - DEBITO - -- Verifica se a conta existe e nao e sintetica
      IF @cCT2_VLD08  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' )  and @cCT2_DEBITO  != ' '  
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
         FROM CT1### 
         WHERE CT1_FILIAL  = @cFilCT1  and CT1_CONTA  = @cCT2_DEBITO  and D_E_L_E_T_  = ' ' 
         IF @nContador  = 0  
         BEGIN 
            SELECT @cCT2_VLD08  = '20' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO20' || ' | '
         END 
      END
      -- se encontrou a conta e classe for diferente de 2 atribue 7
      IF @cCT2_VLD08  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' )  and @cCT2_DEBITO  != ' '
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
         FROM CT1### 
         WHERE CT1_FILIAL  = @cFilCT1  and CT1_CONTA  = @cCT2_DEBITO  and CT1_CLASSE  != '2'  and D_E_L_E_T_  = ' ' 
         IF @nContador  > 0  
         BEGIN 
            SELECT @cCT2_VLD08  = '7' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO07' || ' | '
         END 
      END
      -- VALIDACAO 08.1 - DEBITO -- verifica se conta nao esta bloqueada
      IF @cCT2_VLD08  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' )  and @cCT2_DEBITO  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
         FROM CT1### 
         WHERE CT1_FILIAL  = @cFilCT1  and CT1_CONTA  = @cCT2_DEBITO  and D_E_L_E_T_  = ' '  and  (CT1_BLOQ  = '1'  or  (CT1_DTBLIN  <> ' ' 
            and CT1_DTBLFI  <> ' '  and @IN_DATALANC  between CT1_DTBLIN and CT1_DTBLFI )  or  ( (CT1_DTEXIS  <> ' '  and @IN_DATALANC  < CT1_DTEXIS 
         )  or  (CT1_DTEXSF  <> ' '  and @IN_DATALANC  > CT1_DTEXSF ) ) ) 
         IF @nContador  > 0 
         BEGIN 
            SELECT @cCT2_VLD08  = '7' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO07' || ' | '
         END 
      END
      -- VALIDACAO 09 - verifica digito de controle
      IF @IN_lDcdcuso = '1'
      BEGIN
         IF @cCT2_VLD09 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_DCD = ' '
         BEGIN
            SELECT @cCT2_VLD09 = '8' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO08' || ' | '
         END
         IF @cCT2_VLD09 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) AND  @cCT2_DEBITO != ' '
         BEGIN 
            SELECT @cDigConta = CT1_DC 
               FROM CT1### 
               WHERE CT1_FILIAL = @cFilCT1 AND CT1_CONTA = @cCT2_DEBITO  AND D_E_L_E_T_ = ' ' 
            IF @cDigConta != @cCT2_DCD
            BEGIN 
               SELECT @cCT2_VLD09 = '9'
               SELECT @cCT2_INCONS  = '1' 
               SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO09' || ' | '
            END 
         END
      END
      -- VALIDACAO 10 - DEBITO -- Valida CENTRO DE CUSTO e bloqueio
      SELECT @nContador  = 0 
      IF @cCT2_VLD10  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' )  and @cCT2_CCD  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
            FROM CTT### 
            WHERE CTT_FILIAL  = @cFilCTT  and CTT_CUSTO  = @cCT2_CCD  and D_E_L_E_T_  = ' ' 
         IF @nContador  = 0 
         BEGIN 
            SELECT @cCT2_VLD10  = '20' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO20' || ' | '
         END 
      END 
      -- VALIDACAO 10.1 -- bloqueio de centro de custo
      SELECT @nContador  = 0 
      IF @cCT2_VLD10  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' )  and @cCT2_CCD  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
           FROM CTT### 
           WHERE CTT_FILIAL  = @cFilCTT  and CTT_CUSTO  = @cCT2_CCD  and D_E_L_E_T_  = ' '  and  (CTT_BLOQ  = '1'  or  (CTT_DTBLIN  <> ' ' 
            and CTT_DTBLFI  <> ' '  and @IN_DATALANC  between CTT_DTBLIN and CTT_DTBLFI )  or  ( (CTT_DTEXIS  <> ' '  and @IN_DATALANC  < CTT_DTEXIS 
           )  or  (CTT_DTEXSF  <> ' '  and @IN_DATALANC  > CTT_DTEXSF ) ) ) 
         IF  @nContador  > 0 
         BEGIN 
            SELECT @cCT2_VLD10  = '7' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO07' || ' | '
         END 
      END 
      
      -- VALIDACAO 11 - DEBITO - Valida ITEM CONTABIL e bloqueio
      SELECT @nContador  = 0 
      IF @cCT2_VLD11  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' )  and @cCT2_ITEMD  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
           FROM CTD### 
           WHERE CTD_FILIAL  = @cFilCTD  and CTD_ITEM  = @cCT2_ITEMD  and D_E_L_E_T_  = ' ' 
         IF  @nContador  = 0 
         BEGIN 
            SELECT @cCT2_VLD11  = '20' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO20' || ' | '
         END 
      END 
      
      -- VALIDACAO 11.1 -- bloqueio de centro de custo
      SELECT @nContador  = 0 
      IF @cCT2_VLD11  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' )  and @cCT2_ITEMD  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
           FROM CTD### 
           WHERE CTD_FILIAL  = @cFilCTD  and CTD_ITEM  = @cCT2_ITEMD  and D_E_L_E_T_  = ' '  and  (CTD_BLOQ  = '1'  or  (CTD_DTBLIN  <> ' ' 
            and CTD_DTBLFI  <> ' '  and @IN_DATALANC  between CTD_DTBLIN and CTD_DTBLFI )  or  ( (CTD_DTEXIS  <> ' '  and @IN_DATALANC  < CTD_DTEXIS 
           )  or  (CTD_DTEXSF  <> ' '  and @IN_DATALANC  > CTD_DTEXSF ) ) ) 
         IF @nContador  > 0 
         BEGIN 
            SELECT @cCT2_VLD11  = '7' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO07' || ' | '
         END 
      END 
      
      -- VALIDACAO 12 - DEBITO - Valida CLASSE DE VALOR e bloqueio
      SELECT @nContador  = 0 
      IF @cCT2_VLD12  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' )  and @cCT2_CLVLDB  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
           FROM CTH### 
           WHERE CTH_FILIAL  = @cFilCTH  and CTH_CLVL  = @cCT2_CLVLDB  and D_E_L_E_T_  = ' ' 
         IF @nContador  = 0 
         BEGIN 
            SELECT @cCT2_VLD12  = '20'
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO20' || ' | '
         END 
      END 
      
      -- VALIDACAO 12.1 -- bloqueio de classe de valor
      SELECT @nContador  = 0 
      IF @cCT2_VLD12  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' )  and @cCT2_CLVLDB  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
           FROM CTH### 
           WHERE CTH_FILIAL  = @cFilCTH  and CTH_CLVL  = @cCT2_CLVLDB  and D_E_L_E_T_  = ' '  and  (CTH_BLOQ  = '1'  or  (CTH_DTBLIN  <> ' ' 
            and CTH_DTBLFI  <> ' '  and @IN_DATALANC  between CTH_DTBLIN and CTH_DTBLFI )  or  ( (CTH_DTEXIS  <> ' '  and @IN_DATALANC  < CTH_DTEXIS 
           )  or  (CTH_DTEXSF  <> ' '  and @IN_DATALANC  > CTH_DTEXSF ) ) ) 
         IF @nContador  > 0 
         BEGIN 
            SELECT @cCT2_VLD12  = '7' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO17' || ' | '
         END 
      END 
      
      --13A. VALIDACAO - DEBITO - AMARRACAO
      -- Verifica se as amarracoes estao corretas
      --_CtbAmarr(.T., cDebito,cContCCD,cItemD,cCLVLD,.T.,lRpc,.T.)
      IF @IN_cAmarracao = '1'
      BEGIN
         IF @cCT2_VLD13  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' )
         BEGIN 
            SELECT @cRetRegra  = '0'
            EXEC CTBA105C_## @IN_FILIAL , @cCT2_DEBITO , @cCT2_CCD , @cCT2_ITEMD , @cCT2_CLVLDB , @cRetRegra output 
            IF  @cRetRegra  = '0' 
            BEGIN 
               SELECT @cCT2_VLD13  = '10' 
               SELECT @cCT2_INCONS  = '1' 
               SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO10' || ' | '
            END 
         END
      END
      IF @IN_cAmarracao = '2'
      BEGIN
         IF @cCT2_VLD13 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) 
         BEGIN 
            SELECT @nContador = 0 
            SELECT @nContador1 = 0 
            SELECT @nContador1 = COUNT(R_E_C_N_O_) 
               FROM CTA###
               WHERE CTA_FILIAL = @cFilCTA AND CTA_ITREGR != ' ' AND 
                  ( CTA_CONTA = ' ' OR CTA_CONTA = @cCT2_DEBITO ) AND 
                  ( CTA_CUSTO = ' ' OR CTA_CUSTO = @cCT2_CCD ) AND 
                  ( CTA_ITEM  = ' ' OR CTA_ITEM = @cCT2_ITEMD ) AND 
                  ( CTA_CLVL = ' ' OR CTA_CLVL = @cCT2_CLVLDB ) AND 
                  ##FIELDP05( 'CT2.CT2_EC05DB' )
                     ( CTA_ENTI05 = ' ' OR CTA_ENTI05 = @cCT2_EC05DB ) AND 
                  ##ENDFIELDP05
                  ##FIELDP06( 'CT2.CT2_EC06DB' )
                     ( CTA_ENTI06 = ' ' OR CTA_ENTI06 = @cCT2_EC06DB ) AND 
                  ##ENDFIELDP06
                  ##FIELDP07( 'CT2.CT2_EC07DB' )
                     ( CTA_ENTI07 = ' ' OR CTA_ENTI07 = @cCT2_EC07DB ) AND
                  ##ENDFIELDP07
                  ##FIELDP08( 'CT2.CT2_EC08DB' )
                     ( CTA_ENTI08 = ' '  OR CTA_ENTI08 = @cCT2_EC08DB ) AND  
                  ##ENDFIELDP08
                  ##FIELDP09( 'CT2.CT2_EC09DB' )
                     ( CTA_ENTI09 = ' ' OR CTA_ENTI09 = @cCT2_EC09DB )AND 
                  ##ENDFIELDP09
                  D_E_L_E_T_ = ' '  
            SELECT @nContador = COUNT(R_E_C_N_O_) 
               FROM CTA###
               WHERE CTA_FILIAL = @cFilCTA AND CTA_ITREGR != ' ' AND 
               ( @cCT2_DEBITO = ' ' OR CTA_CONTA = ' ' OR CTA_CONTA = @cCT2_DEBITO ) AND 
               ( @cCT2_CCD = ' '  OR CTA_CUSTO = ' ' OR CTA_CUSTO = @cCT2_CCD ) AND 
               ( @cCT2_ITEMD  = ' ' OR CTA_ITEM  = ' ' OR CTA_ITEM = @cCT2_ITEMD ) AND 
               ( @cCT2_CLVLDB  = ' '  OR CTA_CLVL = ' ' OR CTA_CLVL = @cCT2_CLVLDB ) AND 
               ##FIELDP05( 'CT2.CT2_EC05DB' )
                  ( @cCT2_EC05DB = ' ' OR CTA_ENTI05 = ' ' OR CTA_ENTI05 = @cCT2_EC05DB ) AND  
               ##ENDFIELDP05
               ##FIELDP06( 'CT2.CT2_EC06DB' )
                  ( @cCT2_EC06DB = ' ' OR CTA_ENTI06 = ' ' OR CTA_ENTI06 = @cCT2_EC06DB ) AND 
               ##ENDFIELDP06
               ##FIELDP07( 'CT2.CT2_EC07DB' )
                  ( @cCT2_EC07DB = ' ' OR CTA_ENTI07 = ' ' OR CTA_ENTI07 = @cCT2_EC07DB ) AND
               ##ENDFIELDP07
               ##FIELDP08( 'CT2.CT2_EC08DB' )
                  ( @cCT2_EC08DB = ' ' OR CTA_ENTI08 = ' '  OR CTA_ENTI08 = @cCT2_EC08DB ) AND
               ##ENDFIELDP08
               ##FIELDP09( 'CT2.CT2_EC09DB' )
                  ( @cCT2_EC09DB = ' '  OR CTA_ENTI09 = ' ' OR CTA_ENTI09 = @cCT2_EC09DB )AND
               ##ENDFIELDP09
               D_E_L_E_T_ = ' '  
            IF @nContador1 != 0 AND @nContador = 0 
            BEGIN 
               SELECT @cCT2_VLD13 = '10' 
               SELECT @cCT2_INCONS  = '1' 
               SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO10' || ' | '
            END
         END
      END
      IF @IN_cAmarracao = '3'
      BEGIN
         IF @cCT2_VLD13 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' ) 
         BEGIN
            SELECT @nContador = 0 
            SELECT @nContador = COUNT( R_E_C_N_O_ )
               FROM CTA###
               WHERE
                  CTA_FILIAL = @cFilCTA AND 
                  CTA_CONTA = @cCT2_DEBITO AND 
                  CTA_CUSTO = @cCT2_CCD AND 
                  CTA_ITEM = @cCT2_ITEMD AND 
                  CTA_CLVL = @cCT2_CLVLDB AND 
                  ##FIELDP05( 'CT2.CT2_EC05DB' )
                     CTA_ENTI05 = @cCT2_EC05DB AND
                  ##ENDFIELDP05
                  ##FIELDP06( 'CT2.CT2_EC06DB' )
                     CTA_ENTI06 = @cCT2_EC06DB AND
                  ##ENDFIELDP06
                  ##FIELDP07( 'CT2.CT2_EC07DB' )
                     CTA_ENTI07 = @cCT2_EC07DB AND
                  ##ENDFIELDP07
                  ##FIELDP08( 'CT2.CT2_EC08DB' )
                     CTA_ENTI08 = @cCT2_EC08DB AND
                  ##ENDFIELDP08
                  ##FIELDP09( 'CT2.CT2_EC09DB' )
                     CTA_ENTI09 = @cCT2_EC09DB AND 
                  ##ENDFIELDP09
                  D_E_L_E_T_ = ' ' 
            IF @nContador > 0  
            BEGIN
               SELECT @cCT2_VLD13 = '10' 
               SELECT @cCT2_INCONS  = '1' 
               SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO10' || ' | '
            END
         END
      END
      --14a. VALIDACAO
      --Valida informacoes complementares
      --If ( lVAt ) .And. ( lRet )
      --	lRet := CTBValidAt( "DB", 2, cDebito, cContCCD, cItemD, cCLVLD )	--Funcao do CTBXFUNC.PRW
      --Endif

      --15A. VALIDACAO - DEBITO - OBRIGATORIEDADE DOS CAMPOS E ACEITE
      IF @cCT2_VLD15  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' ) 
      BEGIN 
         SELECT @cCT1_CCOBRG  = ' ' 
         SELECT @cCT1_ITOBRG  = ' ' 
         SELECT @cCT1_CLOBRG  = ' ' 
         SELECT @cCT1_ACCUST  = ' ' 
         SELECT @cCT1_ACITEM  = ' ' 
         SELECT @cCT1_ACCLVL  = ' ' 
         ##FIELDP05( 'CT1.CT1_05OBRG' )
            SELECT @cCT1_05OBRG  = ' ' 
            SELECT @cCT1_ACET05  = ' ' 
         ##ENDFIELDP05
         ##FIELDP06( 'CT1.CT1_06OBRG' )
            SELECT @cCT1_06OBRG  = ' ' 
            SELECT @cCT1_ACET06  = ' ' 
         ##ENDFIELDP06
         ##FIELDP07( 'CT1.CT1_07OBRG' )
            SELECT @cCT1_07OBRG  = ' ' 
            SELECT @cCT1_ACET07  = ' ' 
         ##ENDFIELDP07
         ##FIELDP08( 'CT1.CT1_08OBRG' )
            SELECT @cCT1_08OBRG  = ' ' 
            SELECT @cCT1_ACET08  = ' ' 
         ##ENDFIELDP08
         ##FIELDP09( 'CT1.CT1_09OBRG' )
            SELECT @cCT1_09OBRG  = ' ' 
            SELECT @cCT1_ACET09  = ' '
         ##ENDFIELDP09
         SELECT @cCT1_CCOBRG  = CT1_CCOBRG , @cCT1_ITOBRG  = CT1_ITOBRG , @cCT1_CLOBRG  = CT1_CLOBRG , @cCT1_ACCUST  = CT1_ACCUST 
           , @cCT1_ACITEM  = CT1_ACITEM , @cCT1_ACCLVL  = CT1_ACCLVL 
            ##FIELDP05( 'CT1.CT1_05OBRG' )
               , @cCT1_05OBRG  = CT1_05OBRG , @cCT1_ACET05  = CT1_ACET05
            ##ENDFIELDP05
            ##FIELDP06( 'CT1.CT1_06OBRG' )
               , @cCT1_06OBRG  = CT1_06OBRG , @cCT1_ACET06  = CT1_ACET06
            ##ENDFIELDP06
            ##FIELDP07( 'CT1.CT1_07OBRG' )
               , @cCT1_07OBRG  = CT1_07OBRG , @cCT1_ACET07  = CT1_ACET07
            ##ENDFIELDP07
            ##FIELDP08( 'CT1.CT1_08OBRG' )
               , @cCT1_08OBRG  = CT1_08OBRG , @cCT1_ACET08  = CT1_ACET08
            ##ENDFIELDP08
            ##FIELDP09( 'CT1.CT1_09OBRG' )
               , @cCT1_09OBRG  = CT1_09OBRG , @cCT1_ACET09  = CT1_ACET09
            ##ENDFIELDP09
           FROM CT1### 
           WHERE CT1_FILIAL  = @cFilCT1  and CT1_CONTA  = @cCT2_DEBITO  and D_E_L_E_T_  = ' ' 
         -- valida OBRIGATORIEDADE por plano de conta
         IF @cCT2_VLD15  = ' '  and @cCT1_CCOBRG  = '1'  and @cCT2_CCD  = ' ' 
         BEGIN 
            SELECT @cCT2_VLD15  = '11' 
         END 
         IF @cCT2_VLD15  = ' '  and @cCT1_ITOBRG  = '1'  and @cCT2_ITEMD  = ' ' 
         BEGIN 
            SELECT @cCT2_VLD15  = '11' 
         END 
         IF @cCT2_VLD15  = ' '  and @cCT1_CLOBRG  = '1'  and @cCT2_CLVLDB  = ' ' 
         BEGIN 
            SELECT @cCT2_VLD15  = '11' 
         END 
         ##FIELDP05( 'CT1.CT1_05OBRG' )
            ##FIELDP06( 'CT2.CT2_EC05DB' )
               IF @cCT2_VLD15  = ' '  and @cCT1_05OBRG  = '1'  and @cCT2_EC05DB  = ' ' 
               BEGIN 
                  SELECT @cCT2_VLD15  = '11' 
               END 
            ##ENDFIELDP06
         ##ENDFIELDP05
         ##FIELDP06( 'CT1.CT1_06OBRG' )
            ##FIELDP07( 'CT2.CT2_EC06DB' )
               IF @cCT2_VLD15  = ' '  and @cCT1_06OBRG  = '1'  and @cCT2_EC06DB  = ' ' 
               BEGIN 
                  SELECT @cCT2_VLD15  = '11' 
               END 
            ##ENDFIELDP07
         ##ENDFIELDP06
         ##FIELDP07( 'CT1.CT1_07OBRG' )
            ##FIELDP08( 'CT2.CT2_EC07DB' )
               IF @cCT2_VLD15  = ' '  and @cCT1_07OBRG  = '1'  and @cCT2_EC07DB  = ' ' 
               BEGIN 
                  SELECT @cCT2_VLD15  = '11' 
               END 
            ##ENDFIELDP08
         ##ENDFIELDP07
         ##FIELDP08( 'CT1.CT1_08OBRG' )
            ##FIELDP09( 'CT2.CT2_EC08DB' )
               IF @cCT2_VLD15  = ' '  and @cCT1_08OBRG  = '1'  and @cCT2_EC08DB  = ' ' 
               BEGIN 
                  SELECT @cCT2_VLD15  = '11' 
               END 
            ##ENDFIELDP09
         ##ENDFIELDP08
         ##FIELDP09( 'CT1.CT1_09OBRG' )
            ##FIELDP10( 'CT2.CT2_EC09DB' )
               IF @cCT2_VLD15  = ' '  and @cCT1_09OBRG  = '1'  and @cCT2_EC09DB  = ' ' 
               BEGIN 
                  SELECT @cCT2_VLD15  = '11' 
               END 
            ##ENDFIELDP10
         ##ENDFIELDP09
         -- valida OBRIGATORIEDADE por centro de custo
         SELECT @cCTT_ITOBRG  = ' ' 
         SELECT @cCTT_CLOBRG  = ' ' 
         SELECT @cCTT_ITOBRG  = CTT_ITOBRG , @cCTT_CLOBRG  = CTT_CLOBRG 
           FROM CTT### 
           WHERE CTT_FILIAL  = @cFilCTT  and CTT_CUSTO  = @cCT2_CCD  and D_E_L_E_T_  = ' ' 
         IF @cCT2_VLD15  = ' '  and @cCTT_ITOBRG  = '1'  and @cCT2_ITEMD  = ' ' 
         BEGIN 
            SELECT @cCT2_VLD15  = '11' 
         END 
         IF @cCT2_VLD15  = ' '  and @cCTT_CLOBRG  = '1'  and @cCT2_CLVLDB  = ' ' 
         BEGIN 
            SELECT @cCT2_VLD15  = '11' 
         END 
         -- valida OBRIGATORIEDADE por item
         SELECT @cCTD_CLOBRG  = ' ' 
         SELECT @cCTD_CLOBRG  = CTD_CLOBRG 
           FROM CTD### 
           WHERE CTD_FILIAL  = @cFilCTD  and CTD_ITEM  = @cCT2_ITEMD  and D_E_L_E_T_  = ' ' 
         IF @cCT2_VLD15  = ' '  and @cCTD_CLOBRG  = '1'  and @cCT2_CLVLDB  = ' ' 
         BEGIN 
            SELECT @cCT2_VLD15  = '11' 
         END 
         --Valida ACEITE por plano de contas    
         IF @cCT2_VLD15  = ' '  and @cCT1_ACCUST  = '2'  and @cCT2_CCD  != ' ' 
         BEGIN 
            SELECT @cCT2_VLD15  = '11' 
         END 
         IF @cCT2_VLD15  = ' '  and @cCT1_ACITEM  = '2'  and @cCT2_ITEMD  != ' ' 
         BEGIN 
            SELECT @cCT2_VLD15  = '11' 
         END 
         IF @cCT2_VLD15  = ' '  and @cCT1_ACCLVL  = '2'  and @cCT2_CLVLDB  != ' ' 
         BEGIN 
            SELECT @cCT2_VLD15  = '11' 
         END 
         ##FIELDP05( 'CT2.CT2_EC05DB' )
            ##FIELDP06( 'CT1_05OBRG' )
               IF @cCT2_VLD15  = ' '  and @cCT1_ACET05  = '2'  and @cCT2_EC05DB  != ' ' 
               BEGIN 
                  SELECT @cCT2_VLD15  = '11' 
               END 
            ##ENDFIELDP06
         ##ENDFIELDP05
         ##FIELDP06( 'CT1.CT1_06OBRG' )
            ##FIELDP07( 'CT2.CT2_EC06DB' )
               IF @cCT2_VLD15  = ' '  and @cCT1_ACET06  = '2'  and @cCT2_EC06DB  != ' ' 
               BEGIN 
                  SELECT @cCT2_VLD15  = '11' 
               END 
            ##ENDFIELDP07
         ##ENDFIELDP06
         ##FIELDP07( 'CT1.CT1_07OBRG' )
            ##FIELDP08( 'CT2.CT2_EC07DB' )
               IF @cCT2_VLD15  = ' '  and @cCT1_ACET07  = '2'  and @cCT2_EC07DB  != ' ' 
               BEGIN 
                  SELECT @cCT2_VLD15  = '11' 
               END 
            ##ENDFIELDP08
         ##ENDFIELDP07
         ##FIELDP08( 'CT1.CT1_08OBRG' )
            ##FIELDP09( 'CT2.CT2_EC08DB' )
               IF @cCT2_VLD15  = ' '  and @cCT1_ACET08  = '2'  and @cCT2_EC08DB  != ' ' 
               BEGIN 
                  SELECT @cCT2_VLD15  = '11' 
               END 
            ##ENDFIELDP09
         ##ENDFIELDP08
         ##FIELDP09( 'CT1.CT1_09OBRG' )
            ##FIELDP10( 'CT2.CT2_EC09DB' )
               IF @cCT2_VLD15  = ' '  and @cCT1_ACET09  = '2'  and @cCT2_EC09DB  != ' ' 
               BEGIN 
                  SELECT @cCT2_VLD15  = '11' 
               END
            ##ENDFIELDP10
         ##ENDFIELDP09
      END 
      IF @cCT2_VLD15  = '11' 
      BEGIN 
         SELECT @cCT2_INCONS  = '1' 
         SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO11' || ' | '
      END 
      -- final do if obrigatoriedade/aceite
      -----------------------------------C R E D I T O----------------------------------------------------------

      -- VALIDACAO 16 - CREDITO - Verifica se a conta foi preenchida
      IF @cCT2_VLD16  = ' '  and  (@cCT2_DC  = '2'  or @cCT2_DC  = '3' )  and @cCT2_CREDIT  = ' ' 
      BEGIN 
         SELECT @cCT2_VLD16  = '12' 
         SELECT @cCT2_INCONS  = '1' 
         SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO12' || ' | ' 
      END 
      -- VALIDACAO 17 - CREDITO - -- Verifica se a conta existe e nao e sintetica
      IF @cCT2_VLD17  = ' '  and  (@cCT2_DC  = '2'  or @cCT2_DC  = '3' )  and @cCT2_CREDIT  != ' '  
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
         FROM CT1### 
         WHERE CT1_FILIAL  = @cFilCT1  and CT1_CONTA  = @cCT2_CREDIT  and D_E_L_E_T_  = ' ' 
         -- se nao encontrou a conta atribue 7
         IF  @nContador  = 0 
         BEGIN 
            SELECT @cCT2_VLD17  = '20' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO20' || ' | '
         END 
      END
      IF @cCT2_VLD17  = ' '  and  (@cCT2_DC  = '2'  or @cCT2_DC  = '3' )  and @cCT2_CREDIT  != ' '
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
         FROM CT1### 
         WHERE CT1_FILIAL  = @cFilCT1  and CT1_CONTA  = @cCT2_CREDIT  and CT1_CLASSE  != '2'  and D_E_L_E_T_  = ' ' 
         IF @nContador  > 0 
         BEGIN 
            SELECT @cCT2_VLD17  = '7' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO07' || ' | '
         END 
      END
      --VALIDACAO 17.1 - CREDITO -- verifica se conta nao esta bloqueada
      IF @cCT2_VLD17  = ' '  and  (@cCT2_DC  = '2'  or @cCT2_DC  = '3' )  and @cCT2_CREDIT  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
         FROM CT1### 
         WHERE CT1_FILIAL  = @cFilCT1  and CT1_CONTA  = @cCT2_CREDIT  and D_E_L_E_T_  = ' '  and  (CT1_BLOQ  = '1'  or  (CT1_DTBLIN  <> ' ' 
            and CT1_DTBLFI  <> ' '  and @IN_DATALANC  between CT1_DTBLIN and CT1_DTBLFI )  or  ( (CT1_DTEXIS  <> ' '  and @IN_DATALANC  < CT1_DTEXIS 
         )  or  (CT1_DTEXSF  <> ' '  and @IN_DATALANC  > CT1_DTEXSF ) ) ) 
         IF @nContador  > 0 
         BEGIN 
            SELECT @cCT2_VLD17  = '7' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO07' || ' | '
         END 
      END
      --VALIDACAO 18 - verifica digito de controle
      IF @IN_lDcdcuso = '1'
      BEGIN
         -- Se lançamento e devedor e digito da conta nao preenchido
         IF @cCT2_VLD18 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_DCC = ' '
         BEGIN
            SELECT @cCT2_VLD18 = '13' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO13' || ' | '
         END
         IF @cCT2_VLD18 = ' ' AND ( @cCT2_DC = '2' OR @cCT2_DC = '3' ) AND  @cCT2_CREDIT != ' '
         BEGIN
            SELECT @cDigConta = CT1_DC From CT1### 
            Where CT1_FILIAL = @cFilCT1 AND CT1_CONTA = @cCT2_CREDIT  AND D_E_L_E_T_ = ' ' 
            IF @cDigConta != @cCT2_DCD 
            BEGIN
               select @cCT2_VLD18 = '9' 
               SELECT @cCT2_INCONS  = '1' 
               SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO09' || ' | '
            END
         END
      END
      -- VALIDACAO 19 - CREDITO -- Valida CENTRO DE CUSTO e bloqueio
      SELECT @nContador  = 0 
      IF @cCT2_VLD19  = ' '  and  (@cCT2_DC  = '2'  or @cCT2_DC  = '3' )  and @cCT2_CCD  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
           FROM CTT### 
           WHERE CTT_FILIAL  = @cFilCTT  and CTT_CUSTO  = @cCT2_CCD  and D_E_L_E_T_  = ' ' 
         IF @nContador  = 0 
         BEGIN 
            SELECT @cCT2_VLD19  = '20' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO20' || ' | '
         END 
      END 
      
      --VALIDACAO 19.1 -- bloqueio de centro de custo
      SELECT @nContador  = 0 
      IF @cCT2_VLD19  = ' '  and  (@cCT2_DC  = '2'  or @cCT2_DC  = '3' )  and @cCT2_CCD  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
           FROM CTT### 
           WHERE CTT_FILIAL  = @cFilCTT  and CTT_CUSTO  = @cCT2_CCD  and D_E_L_E_T_  = ' '  and  (CTT_BLOQ  = '1'  or  (CTT_DTBLIN  <> ' ' 
            and CTT_DTBLFI  <> ' '  and @IN_DATALANC  between CTT_DTBLIN and CTT_DTBLFI )  or  ( (CTT_DTEXIS  <> ' '  and @IN_DATALANC  < CTT_DTEXIS 
           )  or  (CTT_DTEXSF  <> ' '  and @IN_DATALANC  > CTT_DTEXSF ) ) ) 
         IF  @nContador  > 0 
         BEGIN 
            SELECT @cCT2_VLD19  = '7' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO07' || ' | '
         END 
      END 
      
      -- VALIDACAO 20 - CREDITO - Valida ITEM CONTABIL e bloqueio
      SELECT @nContador  = 0 
      IF @cCT2_VLD20  = ' '  and  (@cCT2_DC  = '2'  or @cCT2_DC  = '3' )  and @cCT2_ITEMC  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
           FROM CTD### 
           WHERE CTD_FILIAL  = @cFilCTD  and CTD_ITEM  = @cCT2_ITEMC  and D_E_L_E_T_  = ' ' 
         -- se nao encontrou atribue 7
         IF @nContador  = 0 
         BEGIN 
            SELECT @cCT2_VLD20  = '20'
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO20' || ' | ' 
         END 
      END 
      
      -- VALIDACAO 20.1 -- bloqueio de centro de custo
      SELECT @nContador  = 0 
      IF @cCT2_VLD20  = ' '  and  (@cCT2_DC  = '2'  or @cCT2_DC  = '3' )  and @cCT2_ITEMC  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
           FROM CTD### 
           WHERE CTD_FILIAL  = @cFilCTD  and CTD_ITEM  = @cCT2_ITEMC  and D_E_L_E_T_  = ' '  and  (CTD_BLOQ  = '1'  or  (CTD_DTBLIN  <> ' ' 
            and CTD_DTBLFI  <> ' '  and @IN_DATALANC  between CTD_DTBLIN and CTD_DTBLFI )  or  ( (CTD_DTEXIS  <> ' '  and @IN_DATALANC  < CTD_DTEXIS 
           )  or  (CTD_DTEXSF  <> ' '  and @IN_DATALANC  > CTD_DTEXSF ) ) ) 
         IF @nContador  > 0 
         BEGIN 
            SELECT @cCT2_VLD20  = '7' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO07' || ' | ' 
         END 
      END 
      
      -- VALIDACAO 21 - CREDITO - Valida CLASSE DE VALOR e bloqueio
      SELECT @nContador  = 0 
      IF @cCT2_VLD21  = ' '  and  (@cCT2_DC  = '2'  or @cCT2_DC  = '3' )  and @cCT2_CLVLCR  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
           FROM CTH### 
           WHERE CTH_FILIAL  = @cFilCTH  and CTH_CLVL  = @cCT2_CLVLCR  and D_E_L_E_T_  = ' ' 
           -- se nao encontrou atribue 7
         IF  @nContador  = 0 
         BEGIN 
            SELECT @cCT2_VLD21  = '20' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO20' || ' | ' 
         END 
      END 
      
      --VALIDACAO 21.1 -- bloqueio de classe de valor
      SELECT @nContador  = 0 
      IF @cCT2_VLD21  = ' '  and  (@cCT2_DC  = '2'  or @cCT2_DC  = '3' )  and @cCT2_CLVLCR  != ' ' 
      BEGIN 
         SELECT @nContador  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
           FROM CTH### 
           WHERE CTH_FILIAL  = @cFilCTH  and CTH_CLVL  = @cCT2_CLVLCR  and D_E_L_E_T_  = ' '  and  (CTH_BLOQ  = '1'  or  (CTH_DTBLIN  <> ' ' 
            and CTH_DTBLFI  <> ' '  and @IN_DATALANC  between CTH_DTBLIN and CTH_DTBLFI )  or  ( (CTH_DTEXIS  <> ' '  and @IN_DATALANC  < CTH_DTEXIS 
           )  or  (CTH_DTEXSF  <> ' '  and @IN_DATALANC  > CTH_DTEXSF ) ) ) 
           -- se nao encontrou  atribue 7
         IF @nContador  > 0 
         BEGIN 
            SELECT @cCT2_VLD21  = '7' 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO07' || ' | '
         END 
      END 
      
      -- 22A. VALIDACAO - CREDITO - AMARRACAO
      -- Verifica se as amarracoes estao corretas
      --_CtbAmarr(.T., cCREDITO,cContCCD,cITEMC,cCLVLC,.T.,lRpc,.T.)
      IF @IN_cAmarracao = '1'
      BEGIN
         IF @cCT2_VLD13  = ' '  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' ) 
         BEGIN 
            SELECT @cRetRegra  = '0' 
            EXEC CTBA105C_## @IN_FILIAL , @cCT2_CREDIT , @cCT2_CCC , @cCT2_ITEMC , @cCT2_CLVLCR , @cRetRegra output 
            IF @cRetRegra  = '0' 
            BEGIN 
               SELECT @cCT2_VLD13  = '10' 
               SELECT @cCT2_INCONS  = '1' 
               SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO10' || ' | '
            END 
         END
      END
      IF @IN_cAmarracao = '2'
      BEGIN
         IF @cCT2_VLD22 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' )
         BEGIN
            SELECT @nContador = 0 
            SELECT @nContador1 = 0 
            SELECT @nContador1 = COUNT(R_E_C_N_O_) 
               FROM CTA###
               WHERE
                  CTA_FILIAL = @cFilCTA AND CTA_ITREGR != ' ' AND 
                  ( CTA_CONTA  = ' ' OR CTA_CONTA  = @cCT2_CREDIT ) AND  
                  ( CTA_CUSTO  = ' ' OR CTA_CUSTO  = @cCT2_CCC ) AND  
                  ( CTA_ITEM   = ' ' OR CTA_ITEM   = @cCT2_ITEMC ) AND  
                  ( CTA_CLVL   = ' ' OR CTA_CLVL   = @cCT2_CLVLCR ) AND 
                  ##FIELDP05( 'CT2.CT2_EC05CR' )
                     ( CTA_ENTI05 = ' ' OR CTA_ENTI05 = @cCT2_EC05CR ) AND 
                  ##ENDFIELDP05
                  ##FIELDP06( 'CT2.CT2_EC06CR' )
                     ( CTA_ENTI06 = ' ' OR CTA_ENTI06 = @cCT2_EC06CR ) AND  
                  ##ENDFIELDP06
                  ##FIELDP07( 'CT2.CT2_EC07CR' )
                     ( CTA_ENTI07 = ' ' OR CTA_ENTI07 = @cCT2_EC07CR ) AND 
                  ##ENDFIELDP07
                  ##FIELDP08( 'CT2.CT2_EC08CR' )
                     ( CTA_ENTI08 = ' ' OR CTA_ENTI08 = @cCT2_EC08CR ) AND 
                  ##ENDFIELDP08
                  ##FIELDP09( 'CT2.CT2_EC09CR' )
                     ( CTA_ENTI09 = ' ' OR CTA_ENTI09 = @cCT2_EC09CR ) AND 
                  ##ENDFIELDP09
                  D_E_L_E_T_ = ' '  
            SELECT @nContador = COUNT(R_E_C_N_O_) 
               FROM CTA###
               WHERE
                  CTA_FILIAL = @cFilCTA AND CTA_ITREGR != ' ' AND 
                  ( @cCT2_CREDIT = ' '  OR CTA_CONTA  = ' ' OR CTA_CONTA  = @cCT2_CREDIT ) AND  
                  ( @cCT2_CCC = ' '  OR CTA_CUSTO  = ' ' OR CTA_CUSTO  = @cCT2_CCC ) AND  
                  ( @cCT2_ITEMC  = ' ' OR CTA_ITEM   = ' ' OR CTA_ITEM   = @cCT2_ITEMC ) AND  
                  ( @cCT2_CLVLCR  = ' ' OR CTA_CLVL   = ' ' OR CTA_CLVL   = @cCT2_CLVLCR ) AND 
                  ##FIELDP05( 'CT2.CT2_EC05CR' )
                     ( @cCT2_EC05CR = ' ' OR CTA_ENTI05 = ' ' OR CTA_ENTI05 = @cCT2_EC05CR ) AND  
                  ##ENDFIELDP05
                  ##FIELDP06( 'CT2.CT2_EC06CR' )
                     ( @cCT2_EC06CR = ' ' OR CTA_ENTI06 = ' ' OR CTA_ENTI06 = @cCT2_EC06CR ) AND
                  ##ENDFIELDP06
                  ##FIELDP07( 'CT2.CT2_EC07CR' )
                     ( @cCT2_EC07CR = ' ' OR CTA_ENTI07 = ' ' OR CTA_ENTI07 = @cCT2_EC07CR ) AND  
                  ##ENDFIELDP07
                  ##FIELDP08( 'CT2.CT2_EC08CR' )
                     ( @cCT2_EC08CR = ' ' OR CTA_ENTI08 = ' ' OR CTA_ENTI08 = @cCT2_EC08CR ) AND  
                  ##ENDFIELDP08
                  ##FIELDP09( 'CT2.CT2_EC09CR' )
                     ( @cCT2_EC09CR = ' ' OR CTA_ENTI09 = ' ' OR CTA_ENTI09 = @cCT2_EC09CR ) AND 
                  ##ENDFIELDP09
                  D_E_L_E_T_ = ' '  
            IF  @nContador1 != 0 AND @nContador = 0  
            BEGIN
               SELECT @cCT2_VLD22 = '10'
               SELECT @cCT2_INCONS  = '1' 
               SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO10' || ' | '
            END
         END
      END
      IF @IN_cAmarracao = '3'
      BEGIN
         IF @cCT2_VLD22 = ' ' AND ( @cCT2_DC = '1' OR @cCT2_DC = '3' )  
         BEGIN
            SELECT @nContador = 0 
            SELECT @nContador = COUNT( R_E_C_N_O_ )
               FROM CTA###
               WHERE
                  CTA_FILIAL = @cFilCTA AND 
                  CTA_CONTA = @cCT2_CREDIT AND 
                  CTA_CUSTO = @cCT2_CCC AND 
                  CTA_ITEM  = @cCT2_ITEMC AND 
                  CTA_CLVL  = @cCT2_CLVLCR AND 
                  ##FIELDP05( 'CT2.CT2_EC05CR' )
                     CTA_ENTI05 = @cCT2_EC05CR AND 
                  ##ENDFIELDP05
                  ##FIELDP06( 'CT2.CT2_EC06CR' )
                     CTA_ENTI06 = @cCT2_EC06CR AND 
                  ##ENDFIELDP06
                  ##FIELDP07( 'CT2.CT2_EC07CR' )
                     CTA_ENTI07 = @cCT2_EC07CR AND 
                  ##ENDFIELDP07
                  ##FIELDP08( 'CT2.CT2_EC08CR' )
                     CTA_ENTI08 = @cCT2_EC08CR AND 
                  ##ENDFIELDP08
                  ##FIELDP09( 'CT2.CT2_EC09CR' )
                     CTA_ENTI09 = @cCT2_EC09CR AND  
                  ##ENDFIELDP09
                  D_E_L_E_T_ = ' ' 
            IF @nContador > 0  
            BEGIN
               SELECT @cCT2_VLD22 = '10' 
               SELECT @cCT2_INCONS  = '1' 
               SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO10' || ' | '
            END
         END
      END
      --23a. VALIDACAO
      --Valida informacoes complementares
      --If ( lVAt ) .And. ( lRet )
      --	lRet := CTBValidAt( "CR", 2, cCREDITO, cContCCD, cITEMC, cCLVLC )	--Funcao do CTBXFUNC.PRW
      --Endif

      --24A. VALIDACAO - CREDITO - OBRIGATORIEDADE DOS CAMPOS E ACEITE
      IF @cCT2_VLD24  = ' '  and  (@cCT2_DC  = '2'  or @cCT2_DC  = '3' ) 
      BEGIN 
         SELECT @cCT1_CCOBRG  = ' ' 
         SELECT @cCT1_ITOBRG  = ' ' 
         SELECT @cCT1_CLOBRG  = ' ' 
         SELECT @cCT1_ACCUST  = ' ' 
         SELECT @cCT1_ACITEM  = ' ' 
         SELECT @cCT1_ACCLVL  = ' ' 
         ##FIELDP05( 'CT1.CT1_05OBRG' )
            SELECT @cCT1_05OBRG  = ' ' 
            SELECT @cCT1_ACET05  = ' ' 
         ##ENDFIELDP05
         ##FIELDP06( 'CT1.CT1_06OBRG' )
            SELECT @cCT1_06OBRG  = ' ' 
            SELECT @cCT1_ACET06  = ' '
         ##ENDFIELDP06
         ##FIELDP07( 'CT1.CT1_07OBRG' )
            SELECT @cCT1_07OBRG  = ' ' 
            SELECT @cCT1_ACET07  = ' '
         ##ENDFIELDP07
         ##FIELDP08( 'CT1.CT1_08OBRG' )
            SELECT @cCT1_08OBRG  = ' ' 
            SELECT @cCT1_ACET08  = ' ' 
         ##ENDFIELDP08
         ##FIELDP09( 'CT1.CT1_09OBRG' )
            SELECT @cCT1_09OBRG  = ' ' 
            SELECT @cCT1_ACET09  = ' ' 
         ##ENDFIELDP09
         SELECT @cCT1_CCOBRG  = CT1_CCOBRG , @cCT1_ITOBRG  = CT1_ITOBRG , @cCT1_CLOBRG  = CT1_CLOBRG , @cCT1_ACCUST  = CT1_ACCUST 
           , @cCT1_ACITEM  = CT1_ACITEM , @cCT1_ACCLVL  = CT1_ACCLVL  
            ##FIELDP05( 'CT1.CT1_05OBRG' )
               , @cCT1_05OBRG  = CT1_05OBRG , @cCT1_ACET05  = CT1_ACET05
            ##ENDFIELDP05
            ##FIELDP06( 'CT1.CT1_06OBRG' )
               , @cCT1_06OBRG  = CT1_06OBRG , @cCT1_ACET06  = CT1_ACET06
            ##ENDFIELDP06
            ##FIELDP07( 'CT1.CT1_07OBRG' )
               , @cCT1_07OBRG  = CT1_07OBRG , @cCT1_ACET07  = CT1_ACET07
            ##ENDFIELDP07
            ##FIELDP08( 'CT1.CT1_08OBRG' )
               , @cCT1_08OBRG  = CT1_08OBRG , @cCT1_ACET08  = CT1_ACET08
            ##ENDFIELDP08
            ##FIELDP09( 'CT1.CT1_09OBRG' )
               , @cCT1_09OBRG  = CT1_09OBRG , @cCT1_ACET09  = CT1_ACET09
            ##ENDFIELDP09
           FROM CT1### 
           WHERE CT1_FILIAL  = @cFilCT1  and CT1_CONTA  = @cCT2_CREDIT  and D_E_L_E_T_  = ' ' 
         -- valida OBRIGATORIEDADE por plano de conta
         IF @cCT2_VLD24  = ' '  and @cCT1_CCOBRG  = '1'  and @cCT2_CCC  = ' ' 
         BEGIN 
            SELECT @cCT2_VLD24  = '11' 
         END 
         IF @cCT2_VLD24  = ' '  and @cCT1_ITOBRG  = '1'  and @cCT2_ITEMC  = ' ' 
         BEGIN 
            SELECT @cCT2_VLD24  = '11' 
         END 
         IF @cCT2_VLD24  = ' '  and @cCT1_CLOBRG  = '1'  and @cCT2_CLVLCR  = ' ' 
         BEGIN 
            SELECT @cCT2_VLD24  = '11' 
         END 
         ##FIELDP05( 'CT1.CT1_05OBRG' )
            ##FIELDP06( 'CT2.CT2_EC05CR' )
               IF @cCT2_VLD24  = ' '  and @cCT1_05OBRG  = '1'  and @cCT2_EC05CR  = ' ' 
               BEGIN 
                  SELECT @cCT2_VLD24  = '11' 
               END 
            ##ENDFIELDP06
         ##ENDFIELDP05
         ##FIELDP06( 'CT1.CT1_06OBRG' )
            ##FIELDP07( 'CT2.CT2_EC06CR' )
               IF @cCT2_VLD24  = ' '  and @cCT1_06OBRG  = '1'  and @cCT2_EC06CR  = ' ' 
               BEGIN 
                  SELECT @cCT2_VLD24  = '11' 
               END 
            ##ENDFIELDP07
         ##ENDFIELDP06
         ##FIELDP07( 'CT1.CT1_07OBRG' )
            ##FIELDP08( 'CT2.CT2_EC07CR' )
               IF @cCT2_VLD24  = ' '  and @cCT1_07OBRG  = '1'  and @cCT2_EC07CR  = ' ' 
               BEGIN 
                  SELECT @cCT2_VLD24  = '11' 
               END 
            ##ENDFIELDP08
         ##ENDFIELDP07
         ##FIELDP08( 'CT1.CT1_08OBRG' )
            ##FIELDP09( 'CT2.CT2_EC08CR' )
               IF @cCT2_VLD24  = ' '  and @cCT1_08OBRG  = '1'  and @cCT2_EC08CR  = ' ' 
               BEGIN 
                  SELECT @cCT2_VLD24  = '11' 
               END 
            ##ENDFIELDP09
         ##ENDFIELDP08
         ##FIELDP09( 'CT1.CT1_09OBRG' )
            ##FIELDP10( 'CT2.CT2_EC09CR' )
               IF @cCT2_VLD24  = ' '  and @cCT1_09OBRG  = '1'  and @cCT2_EC09CR  = ' ' 
               BEGIN 
                  SELECT @cCT2_VLD24  = '11' 
               END 
            ##ENDFIELDP10
         ##ENDFIELDP09
         --valida OBRIGATORIEDADE por centro de custo
         SELECT @cCTT_ITOBRG  = ' ' 
         SELECT @cCTT_CLOBRG  = ' ' 
         SELECT @cCTT_ITOBRG  = CTT_ITOBRG , @cCTT_CLOBRG  = CTT_CLOBRG 
           FROM CTT### 
           WHERE CTT_FILIAL  = @cFilCTT  and CTT_CUSTO  = @cCT2_CCC  and D_E_L_E_T_  = ' ' 
         IF @cCT2_VLD24  = ' '  and @cCTT_ITOBRG  = '1'  and @cCT2_ITEMC  = ' ' 
         BEGIN 
            SELECT @cCT2_VLD24  = '11' 
         END 
         IF @cCT2_VLD24  = ' '  and @cCTT_CLOBRG  = '1'  and @cCT2_CLVLCR  = ' ' 
         BEGIN 
            SELECT @cCT2_VLD24  = '11' 
         END 
         -- valida OBRIGATORIEDADE por item
         SELECT @cCTD_CLOBRG  = ' ' 
         SELECT @cCTD_CLOBRG  = CTD_CLOBRG 
           FROM CTD### 
           WHERE CTD_FILIAL  = @cFilCTD  and CTD_ITEM  = @cCT2_ITEMC  and D_E_L_E_T_  = ' ' 
         IF @cCT2_VLD24  = ' '  and @cCTD_CLOBRG  = '1'  and @cCT2_CLVLCR  = ' ' 
         BEGIN 
            SELECT @cCT2_VLD24  = '11' 
         END 
         -- Valida ACEITE por plano de contas
         IF @cCT2_VLD24  = ' '  and @cCT1_ACCUST  = '2'  and @cCT2_CCC  != ' ' 
         BEGIN 
            SELECT @cCT2_VLD24  = '11' 
         END 
         IF @cCT2_VLD24  = ' '  and @cCT1_ACITEM  = '2'  and @cCT2_ITEMC  != ' ' 
         BEGIN 
            SELECT @cCT2_VLD24  = '11' 
         END 
         IF @cCT2_VLD24  = ' '  and @cCT1_ACCLVL  = '2'  and @cCT2_CLVLCR  != ' ' 
         BEGIN 
            SELECT @cCT2_VLD24  = '11' 
         END 
         ##FIELDP05( 'CT1.CT1_05OBRG' )
            ##FIELDP06( 'CT2.CT2_EC05CR' )
               IF @cCT2_VLD24  = ' '  and @cCT1_ACET05  = '2'  and @cCT2_EC05CR  != ' ' 
               BEGIN 
                  SELECT @cCT2_VLD24  = '11' 
               END 
            ##ENDFIELDP06
         ##ENDFIELDP05
         ##FIELDP06( 'CT1.CT1_06OBRG' )
            ##FIELDP07( 'CT2.CT2_EC06CR' )
               IF @cCT2_VLD24  = ' '  and @cCT1_ACET06  = '2'  and @cCT2_EC06CR  != ' ' 
               BEGIN 
                  SELECT @cCT2_VLD24  = '11' 
               END 
            ##ENDFIELDP07
         ##ENDFIELDP06
         ##FIELDP07( 'CT1.CT1_07OBRG' )
            ##FIELDP08( 'CT2.CT2_EC07CR' )
               IF @cCT2_VLD24  = ' '  and @cCT1_ACET07  = '2'  and @cCT2_EC07CR  != ' ' 
               BEGIN 
                  SELECT @cCT2_VLD24  = '11' 
               END 
            ##ENDFIELDP08
         ##ENDFIELDP07
         ##FIELDP08( 'CT1.CT1_08OBRG' )
            ##FIELDP09( 'CT2.CT2_EC08CR' )
               IF @cCT2_VLD24  = ' '  and @cCT1_ACET08  = '2'  and @cCT2_EC08CR  != ' ' 
               BEGIN 
                  SELECT @cCT2_VLD24  = '11' 
               END 
            ##ENDFIELDP09
         ##ENDFIELDP08
         ##FIELDP09( 'CT1.CT1_09OBRG' )
            ##FIELDP10( 'CT2.CT2_EC09CR' )
               IF @cCT2_VLD24  = ' '  and @cCT1_ACET09  = '2'  and @cCT2_EC09CR  != ' ' 
               BEGIN 
                  SELECT @cCT2_VLD24  = '11' 
               END 
            ##ENDFIELDP10
         ##ENDFIELDP09
         IF @cCT2_VLD24  = '11' 
         BEGIN 
            SELECT @cCT2_INCONS  = '1' 
            SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO11' || ' | '
         END 
         -- final do if obrigatoriedade/aceite
      END 
      --VALIDACAO 25 - Nao pode haver lancamento contábil com conta credito igual a debito.   
      IF @cCT2_DC = '3' AND @cCT2_VLD25 = ' '
      BEGIN
         IF  @cCT2_DEBITO <> @cCT2_CREDIT 
         BEGIN
            select @cCT2_VLD25 = ' '
         END 
         ELSE 
         BEGIN 
            IF  @cCT2_CCD <> @cCT2_CCC 
            BEGIN
               select @cCT2_VLD25 = ' '
            END 
            ELSE 
            BEGIN
               IF @cCT2_ITEMD <> @cCT2_ITEMC
               BEGIN
                  select @cCT2_VLD25 = ' '
               END 
               ELSE 
               BEGIN
                  IF @cCT2_CLVLDB <> @cCT2_CLVLCR
                  BEGIN
                     select @cCT2_VLD25 = ' '
                  END 
                  ELSE 
                  BEGIN
                     select @cCT2_VLD25 = '15'
                     ##FIELDP05( 'CT2.CT2_EC05CR' )
                        IF  @cCT2_EC05DB <> @cCT2_EC05CR 
                        BEGIN
                           select @cCT2_VLD25 = ' '
                        END
                        ELSE
                        BEGIN
                           select @cCT2_VLD25 = '15'
                           ##FIELDP06( 'CT2.CT2_EC06CR' )
                              IF  @cCT2_EC06DB <> @cCT2_EC06CR 
                              BEGIN
                                 select @cCT2_VLD25 = ' '
                              END
                              ELSE
                              BEGIN
                                 select @cCT2_VLD25 = '15'
                                 ##FIELDP07( 'CT2.CT2_EC07CR' )
                                    IF  @cCT2_EC07DB <> @cCT2_EC07CR 
                                    BEGIN
                                       select @cCT2_VLD25 = ' '
                                    END
                                    ELSE
                                    BEGIN
                                       select @cCT2_VLD25 = '15'
                                       ##FIELDP08( 'CT2.CT2_EC08CR' )
                                          IF  @cCT2_EC08DB <> @cCT2_EC08CR 
                                          BEGIN
                                             select @cCT2_VLD25 = ' '
                                          END
                                          ELSE
                                          BEGIN
                                             select @cCT2_VLD25 = '15'
                                             ##FIELDP09( 'CT2.CT2_EC09CR' )
                                                IF  @cCT2_EC09DB <> @cCT2_EC09CR 
                                                BEGIN
                                                   select @cCT2_VLD25 = ' '
                                                END
                                                ELSE
                                                BEGIN
                                                   select @cCT2_VLD25 = '15'
                                                END
                                             ##ENDFIELDP09
                                          END
                                       ##ENDFIELDP08
                                    END
                                 ##ENDFIELDP07
                              END
                           ##ENDFIELDP06
                        END
                     ##ENDFIELDP05
                  END
               END
            END
         END 
      END 
      IF @cCT2_VLD25  = '15' 
      BEGIN 
         SELECT @cCT2_INCONS  = '1' 
         SELECT @mCT2_INCDET  = RTRIM(@mCT2_INCDET) || '#ERRO15' || ' | '
      END 
      -- UPDADE DOS CAMPOS CT2_VLDnn COM CONTEUDO DAS VARIAVEIS
      SELECT @cExecSql = ' UPDATE '
      SELECT @cExecSql = @cExecSql || @IN_cTmpName
      SELECT @cExecSql = @cExecSql || " SET CT2_VLD01  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD01
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD02  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD02 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD03  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD03 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD04  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD04 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD05  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD05 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD06  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD06 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD07  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD07 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD08  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD08 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD09  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD09 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD10  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD10 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD11  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD11 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD12  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD12 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD13  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD13 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD14  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD14 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD15  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD15 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD16  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD16 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD17  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD17 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD18  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD18 
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD19  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD19
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD20  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD20  
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD21  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD21  
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD22  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD22  
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD23  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD23  
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD24  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD24  
      SELECT @cExecSql = @cExecSql || "'' , CT2_VLD25  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_VLD25  
      SELECT @cExecSql = @cExecSql || "'' , CT2_INCONS  = ''" 
      SELECT @cExecSql = @cExecSql || @cCT2_INCONS  
      ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
         IF (RTRIM(LTRIM(@OUT_ERROR)) IS NULL OR RTRIM(LTRIM(@OUT_ERROR)) = '')  AND @cCT2_INCONS = '1'
            BEGIN
               SELECT @OUT_ERROR = RTRIM(@mCT2_INCDET);
               SELECT @cExecSql = @cExecSql || "'' , CT2_INCDET  = $1"
               SELECT @cExecSql = @cExecSql ||" WHERE R_E_C_N_O_  = " || CONVERT(VARCHAR(10), @iRecno) 
               SELECT @cExecSql = '#EXECUTE'
            END 
         ELSE
            BEGIN
               SELECT @cExecSql = @cExecSql || "'' , CT2_INCDET  = NULL"
               SELECT @cExecSql = @cExecSql || " WHERE R_E_C_N_O_  = " || CONVERT(VARCHAR(10), @iRecno)
               EXECUTE @cExecSql
            END        
      ##ENDIF_003
      ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/ORACLE"})
         IF (RTRIM(LTRIM(@OUT_ERROR)) IS NULL OR RTRIM(LTRIM(@OUT_ERROR)) = '')  AND @cCT2_INCONS = '1'
            BEGIN
               SELECT @OUT_ERROR = RTRIM(@mCT2_INCDET);
               SELECT @cExecSql = @cExecSql || "'' , CT2_INCDET  = #INICONVERT ''"
               SELECT @cExecSql = @cExecSql || @mCT2_INCDET 
               SELECT @cExecSql = @cExecSql || "'' "
               SELECT @cExecSql = @cExecSql || "#FIMCONVERT"
            END 
         ELSE
            BEGIN
               SELECT @cExecSql = @cExecSql || "'' , CT2_INCDET  = NULL"
               SELECT @cExecSql = @cExecSql ||" WHERE R_E_C_N_O_  = " || CONVERT(VARCHAR(10), @iRecno) 
            END          
      ##ENDIF_004
      
      ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})         
         exec sp_executesql @cExecSql
      ##ENDIF_001

      ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})         
         SELECT @cExecSql = 'IMMEDIATE'
      ##ENDIF_002

      FETCH cCursorCTB 
       INTO @cCT2_FILIAL --sobreescreve cVarProc 2
   END 
   CLOSE cCursorCTB
   DEALLOCATE cCursorCTB
   SELECT @OUT_RET  = '1' 
END 