-- =============================================
-- Author:		Thiago Alves Bussolin
-- Create date: 14/11/2025
-- Description:	Conversao de Moedas - Converter o valor da Moeda de acordo com o Criterio de conversao
-- =============================================


/* -------------------------------------------------------------------------------------------------------------------------------- 
   Versão          - <v>  Protheus 9.12 </v>
   Assinatura      - <a>  001 </a>
   Fonte Microsiga - <s>  CTBA370.PRW </s>
   Descricao       - <d>  Conversao de Moedas </d>
   Procedure       -      Converter o valor da Moeda de acordo com o Criterio de conversao
   Funcao do Siga  -      CtbConv()
   Entrada         - <ri> @IN_FILIAL     - Filial Corrente
                          @IN_DATA       - Data       
                          @IN_VALOR      - Valor a Converter
                          @IN_MOEDA      - Moeda a converter
                          @IN_CRITER     - Criterio de conversao  </ri>
   Saida           - <o>  @OUT_VALOR     - Valor Convertido </ro>
   
   @IN_CRITER  IN ( '1','9') -> Diario
                  ( '2','8') -> Mensal
                  ( '3','7') -> Ultimo Dia
                        '4'  -> Informado    -> Retorna valor 0
                        '5'  -> Nao Converte -> Retorna valor 0
                        'A'  -> Nao Ajusta   -> Retorna valor 0
   -------------------------------------------------------------------------------------------------------------------------------- */

CREATE PROCEDURE CTBA370B_## (
    @IN_FILIAL Char( 'CT2_FILIAL' ) , 
    @IN_DATA Char( 08 ) , 
    @IN_VALOR Float , 
    @IN_MOEDA Char( 02 ) , 
    @IN_CRITER Char( 01 ) , 
    @OUT_VALOR Float  output ) AS
 
-- Declaration of variables
DECLARE @cFil_CTO Char( 'CT2_FILIAL' )
DECLARE @cFil_CTP Char( 'CT2_FILIAL' )
DECLARE @cFil_CTG Char( 'CT2_FILIAL' )
DECLARE @cAux Char( 03 )
DECLARE @nTaxa Float
DECLARE @nValor Float
DECLARE @nDecimal Integer
DECLARE @cDataIni Char( 08 )
DECLARE @cDataFim Char( 08 )
DECLARE @iDias Integer
BEGIN
   SELECT @OUT_VALOR  = 0 
   SELECT @nValor  = 0 
   SELECT @nDecimal  = 2 
   SELECT @cDataIni  = ' ' 
   SELECT @cDataFim  = ' ' 
   SELECT @iDias  = 0 
   SELECT @nTaxa  = 0 
   SELECT @cAux  = 'CTO' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CTO output 
   SELECT @cAux  = 'CTP' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CTP output 
   SELECT @cAux  = 'CTG' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CTG output 

   SELECT @nDecimal  = COALESCE ( CTO_DECIM , 2 )
     FROM CTO### 
     WHERE CTO_FILIAL  = @cFil_CTO  and CTO_MOEDA  = @IN_MOEDA  and D_E_L_E_T_  = ' ' 
   IF  (@IN_CRITER  = '1'  or @IN_CRITER  = '9' ) 
   BEGIN 
      SELECT @nTaxa  = COALESCE ( CTP_TAXA , 0 )
        FROM CTP### 
        WHERE CTP_FILIAL  = @cFil_CTP  and CTP_DATA  = @IN_DATA  and CTP_MOEDA  = @IN_MOEDA  and D_E_L_E_T_  = ' ' 
      IF @nTaxa  != 0 
      BEGIN 
         SELECT @nValor  = ROUND (  (@IN_VALOR  / @nTaxa ) , @nDecimal )
      END 
   END 
   IF  (@IN_CRITER  = '2'  or @IN_CRITER  = '8' ) 
   BEGIN 
      SELECT @cDataIni  = COALESCE ( CTG_DTINI , ' ' ), @cDataFim  = COALESCE ( CTG_DTFIM , ' ' )
        FROM CTG### 
        WHERE CTG_FILIAL  = @cFil_CTG  and @IN_DATA  between CTG_DTINI and CTG_DTFIM  and D_E_L_E_T_  = ' ' 
         ##IF_001({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})      
            AND ROWNUM = 1
         ##ENDIF_001
      SELECT @iDias  = COUNT ( * ), @nTaxa  = SUM(CTP_TAXA )
        FROM CTP### 
        WHERE CTP_FILIAL  = @cFil_CTP  and CTP_MOEDA  = @IN_MOEDA  and CTP_DATA  between @cDataIni and @cDataFim  and D_E_L_E_T_  = ' ' 
        
      IF @iDias  > 0 
      BEGIN 
         SELECT @nTaxa  = @nTaxa  / @iDias 
      END 
      IF @nTaxa  != 0 
      BEGIN 
         SELECT @nValor  = ROUND (  (@IN_VALOR  / @nTaxa ) , @nDecimal )
      END 
   END 
   IF  (@IN_CRITER  = '3'  or @IN_CRITER  = '7' ) 
   BEGIN 
      SELECT @cDataFim  = COALESCE ( CTG_DTFIM , ' ' )
        FROM CTG### 
        WHERE CTG_FILIAL  = @cFil_CTG  and @IN_DATA  between CTG_DTINI and CTG_DTFIM  and D_E_L_E_T_  = ' ' 
         ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})      
            AND ROWNUM = 1
         ##ENDIF_002
      SELECT @nTaxa  = COALESCE ( CTP_TAXA , 0 )
        FROM CTP### 
        WHERE CTP_FILIAL  = @cFil_CTP  and CTP_MOEDA  = @IN_MOEDA  and CTP_DATA  = @cDataFim  and D_E_L_E_T_  = ' ' 
      IF @nTaxa  != 0 
      BEGIN 
         SELECT @nValor  = ROUND (  (@IN_VALOR  / @nTaxa ) , @nDecimal )
      END 
   END 
   SELECT @OUT_VALOR  = @nValor 
END 
