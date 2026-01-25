##IF_999({|| AliasInDic('QLJ') })
Create procedure CTB965B_## 
 ( 
  @IN_FILIAL       Char('CT2_FILIAL'),
  @IN_DATA         Char(08),
  @IN_DATAMES      Char(08),
  @IN_IDENT        Char(03),
  @IN_CODIGO       Char('CQ9_CODIGO'),
  @IN_MOEDA        Char('CT2_MOEDLC'),
  @IN_TPSALDO      Char('CT2_TPSALD'),
  @IN_LP           Char(01),
  @IN_TIPO         Char(01),
  @IN_VALOR        Float,
  @IN_TRANSACTION  Char(01),
  @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P12 </v>    
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Zera os arquivos a serem posteriormente reprocessados </d>
    Fonte Microsiga - <s> CTBA190.PRW </s>
    Entrada         - <ri> @IN_FILIAL       - Filial do registro
                           @IN_DATA         - Data do registro
                           @IN_IDENT        - Identificador do tipo de Registro
                           @IN_CODIGO       - Código da entidade                           
                           @IN_MOEDA        - Código da Moeda específica
                           @IN_TPSALDO      - Tipo de saldo                           
                           @IN_LP           - Indica se é registro de lucros e perdas
                           @IN_TIPO         - 1 = Débito, 2 = Crédito
                           @IN_VALOR        - Valor a ser subtraído do saldo
                           @IN_TRANSACTION  - '1' em transação - '0' fora de transação  </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Data        :     08/11/2023
-------------------------------------------------------------------------------------- */
declare @nSaldo     Float
declare @nRecno     Float

begin  
    select @OUT_RESULTADO = '0'   
    
    Select @nRecno = 0
    Select @nSaldo = 0
    
    If @IN_TIPO = '1' Begin        
        SELECT @nSaldo = ROUND((CQ9_DEBITO+CQ9_CREDIT)-@IN_VALOR,2), @nRecno = R_E_C_N_O_
        FROM CQ9### 
        WHERE CQ9_FILIAL = @IN_FILIAL AND
            CQ9_DATA     = @IN_DATA AND
            CQ9_IDENT    = @IN_IDENT AND
            CQ9_CODIGO   = @IN_CODIGO AND
            CQ9_MOEDA    = @IN_MOEDA AND
            CQ9_TPSALD   = @IN_TPSALDO AND
            CQ9_LP       = @IN_LP AND
            D_E_L_E_T_   = ' '        
        
        If @nSaldo > 0 Begin
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                UPDATE CQ9### SET CQ9_DEBITO = 0 WHERE R_E_C_N_O_ = @nRecno        
            ##CHECK_TRANSACTION_COMMIT
        End Else Begin
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                DELETE FROM CQ9### WHERE R_E_C_N_O_ = @nRecno
            ##CHECK_TRANSACTION_COMMIT
        End

        /*Saldos mensais*/
        Select @nRecno = 0
        Select @nSaldo = 0

        SELECT @nSaldo = ROUND((CQ8_DEBITO+CQ8_CREDIT)-@IN_VALOR,2), @nRecno = R_E_C_N_O_
        FROM CQ8###
        WHERE CQ8_FILIAL = @IN_FILIAL AND
            CQ8_DATA     = @IN_DATAMES AND
            CQ8_IDENT    = @IN_IDENT AND
            CQ8_CODIGO   = @IN_CODIGO AND
            CQ8_MOEDA    = @IN_MOEDA AND
            CQ8_TPSALD   = @IN_TPSALDO AND
            CQ8_LP       = @IN_LP AND
            D_E_L_E_T_   = ' '

        IF @nSaldo > 0 Begin
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                UPDATE CQ8### SET CQ8_DEBITO = ROUND(CQ8_DEBITO-@IN_VALOR,2) WHERE R_E_C_N_O_ = @nRecno
            ##CHECK_TRANSACTION_COMMIT
        End Else Begin
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                DELETE FROM CQ8### WHERE R_E_C_N_O_ = @nRecno
            ##CHECK_TRANSACTION_COMMIT
        End
    End else Begin        
        SELECT @nSaldo = ROUND((CQ9_DEBITO+CQ9_CREDIT)-@IN_VALOR,2), @nRecno = R_E_C_N_O_
        FROM CQ9### 
        WHERE CQ9_FILIAL = @IN_FILIAL AND
            CQ9_DATA     = @IN_DATA AND
            CQ9_IDENT    = @IN_IDENT AND
            CQ9_CODIGO   = @IN_CODIGO AND
            CQ9_MOEDA    = @IN_MOEDA AND
            CQ9_TPSALD   = @IN_TPSALDO AND
            CQ9_LP       = @IN_LP AND
            D_E_L_E_T_   = ' '        
        
        If @nSaldo > 0 Begin
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                UPDATE CQ9### SET CQ9_CREDIT = 0 WHERE R_E_C_N_O_ = @nRecno        
            ##CHECK_TRANSACTION_COMMIT
        End Else Begin
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                DELETE FROM CQ9### WHERE R_E_C_N_O_ = @nRecno
            ##CHECK_TRANSACTION_COMMIT
        End

        /*Saldos mensais*/
        Select @nRecno = 0
        Select @nSaldo = 0

        SELECT @nSaldo = ROUND((CQ8_DEBITO+CQ8_CREDIT)-@IN_VALOR,2), @nRecno = R_E_C_N_O_
        FROM CQ8###
        WHERE CQ8_FILIAL = @IN_FILIAL AND
            CQ8_DATA     = @IN_DATAMES AND
            CQ8_IDENT    = @IN_IDENT AND
            CQ8_CODIGO   = @IN_CODIGO AND
            CQ8_MOEDA    = @IN_MOEDA AND
            CQ8_TPSALD   = @IN_TPSALDO AND
            CQ8_LP       = @IN_LP AND
            D_E_L_E_T_   = ' '

        IF @nSaldo > 0 Begin
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                UPDATE CQ8### SET CQ8_CREDIT = ROUND(CQ8_CREDIT-@IN_VALOR,2) WHERE R_E_C_N_O_ = @nRecno
            ##CHECK_TRANSACTION_COMMIT
        End Else Begin
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                DELETE FROM CQ8### WHERE R_E_C_N_O_ = @nRecno
            ##CHECK_TRANSACTION_COMMIT
        End
    End   

    select @OUT_RESULTADO = '1'
end
##ENDIF_999