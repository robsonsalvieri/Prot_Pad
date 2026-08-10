Create Procedure MAT050_##
( 
 @IN_FILIALCOR    char('B1_FILIAL'),
 @IN_CODIGO       char('B1_COD'),
 @IN_MV_CUSFIL    char(01),
 @IN_MV_MOEDACM   char(05),
 @IN_TRANSACTION  char(01),
 @OUT_RESULTADO   char(01) OutPut
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Vers�o      -  <v> Protheus P12 </v>
    Programa    -  <s> B2AtuUnif (mata300.prx) </s>
    Descricao   -  <d> Atualiza o saldo atual do SB2 (VATU) Unificado </d>
    Assinatura  -  <a> 001 </a>
    Entrada     -  <ri> @IN_FILIALCOR  - Filial corrente
                   @IN_CODIGO     - Codigo do produto </ri>
                   
    Saida       -  <ro>  </ro>

    Responsavel :  <r> Marcelo Pimentel </r>
    Data        :  <dt> 19.11.2007 </dt>
--------------------------------------------------------------------------------------------------------------------- */
Declare @cFil_SB2        char('B2_FILIAL')
Declare @cAux            varchar(3)
Declare @nOUT_VLR1       float
Declare	@nOUT_VLR2       float
Declare	@nOUT_VLR3       float
Declare	@nOUT_VLR4       float
Declare	@nOUT_VLR5       float
Declare @iPos            integer
Declare @nOUT_QZERO      integer

Begin
   select @OUT_RESULTADO = '0'
   select @cAux = 'SB2'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB2 OutPut

   /* ------------------------------------------------------------------------------------------------------------------
      Inicializa as variaveis com ZERO
   ------------------------------------------------------------------------------------------------------------------ */
   select @nOUT_QZERO = 0
   select @nOUT_VLR1 = 0
   select @nOUT_VLR2 = 0
   select @nOUT_VLR3 = 0
   select @nOUT_VLR4 = 0
   select @nOUT_VLR5 = 0

   /* ------------------------------------------------------------------------------------------------------------------
      Retorna o custo medio unificado do produto
   ------------------------------------------------------------------------------------------------------------------ */
   exec MAT051_## @IN_FILIALCOR, @IN_CODIGO, @IN_MV_CUSFIL, @IN_MV_MOEDACM, @nOUT_VLR1 OutPut, @nOUT_VLR2 OutPut, @nOUT_VLR3 OutPut, @nOUT_VLR4 OutPut, @nOUT_VLR5 OutPut, @nOUT_QZERO OutPut

    if @IN_MV_CUSFIL = '1' begin
		if @nOUT_VLR1 > 0 begin	  
		  ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
		  if @nOUT_QZERO = 1 begin
            Update SB2### 
               set B2_CM1    =  @nOUT_VLR1
               where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @IN_CODIGO
               and D_E_L_E_T_ = ' '
         end else
         begin 
               Update SB2### 
               set B2_VATU1  = B2_QATU * @nOUT_VLR1,
                   B2_CM1    =  @nOUT_VLR1
               where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @IN_CODIGO
               and D_E_L_E_T_ = ' '
         end
		  ##CHECK_TRANSACTION_COMMIT
	    End		
      select @iPos = Charindex( '2', @IN_MV_MOEDACM )
      If @iPos > 0 and @nOUT_VLR2 > 0  begin    --Moeda 2
	    ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
		  if @nOUT_QZERO = 1 begin
            Update SB2### 
               set B2_CM2    =  @nOUT_VLR2
               where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @IN_CODIGO
               and D_E_L_E_T_ = ' '
         end else
         begin 
               Update SB2### 
               set B2_VATU2  = B2_QATU * @nOUT_VLR2,
                   B2_CM2    =  @nOUT_VLR2
               where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @IN_CODIGO
               and D_E_L_E_T_ = ' '
         end
		##CHECK_TRANSACTION_COMMIT
      End
      select @iPos = Charindex( '3', @IN_MV_MOEDACM )
      If @iPos > 0 and @nOUT_VLR3 > 0  begin    --Moeda 3
	    ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
		  if @nOUT_QZERO = 1 begin
            Update SB2### 
               set B2_CM3    =  @nOUT_VLR3
               where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @IN_CODIGO
               and D_E_L_E_T_ = ' '
         end else
         begin 
               Update SB2### 
               set B2_VATU3  = B2_QATU * @nOUT_VLR3,
                   B2_CM3    =  @nOUT_VLR3
               where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @IN_CODIGO
               and D_E_L_E_T_ = ' '
         end
		##CHECK_TRANSACTION_COMMIT
      End
      select @iPos = Charindex( '4', @IN_MV_MOEDACM )
      If @iPos > 0 and @nOUT_VLR4 > 0  begin    --Moeda 4
	    ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
		  if @nOUT_QZERO = 1 begin
            Update SB2### 
               set B2_CM4    =  @nOUT_VLR4
               where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @IN_CODIGO
               and D_E_L_E_T_ = ' '
         end else
         begin 
               Update SB2### 
               set B2_VATU4  = B2_QATU * @nOUT_VLR4,
                   B2_CM4    =  @nOUT_VLR4
               where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @IN_CODIGO
               and D_E_L_E_T_ = ' '
         end
		##CHECK_TRANSACTION_COMMIT
      End
      select @iPos = Charindex( '5', @IN_MV_MOEDACM )
      If @iPos > 0 and @nOUT_VLR5 > 0  begin    --Moeda 5
	    ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
		  if @nOUT_QZERO = 1 begin
            Update SB2### 
               set B2_CM5    =  @nOUT_VLR5
               where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @IN_CODIGO
               and D_E_L_E_T_ = ' '
         end else
         begin 
               Update SB2### 
               set B2_VATU5  = B2_QATU * @nOUT_VLR5,
                   B2_CM5    =  @nOUT_VLR5
               where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @IN_CODIGO
               and D_E_L_E_T_ = ' '
         end
		##CHECK_TRANSACTION_COMMIT
      End
    end else begin
		if @nOUT_VLR1 > 0 begin	  
		  ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
		  Update SB2### 
			 set B2_VATU1  =  (B2_QATU * @nOUT_VLR1),
				 B2_CM1    =  @nOUT_VLR1
		   where B2_COD    = @IN_CODIGO
			 and D_E_L_E_T_ = ' '
		  ##CHECK_TRANSACTION_COMMIT
		End
      select @iPos = Charindex( '2', @IN_MV_MOEDACM )
      If @iPos > 0 and @nOUT_VLR2 > 0  begin    --Moeda 2
	    ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        Update SB2### 
           set B2_VATU2  =  (B2_QATU * @nOUT_VLR2),
               B2_CM2    =  @nOUT_VLR2
         where B2_COD    = @IN_CODIGO
           and D_E_L_E_T_ = ' '
		##CHECK_TRANSACTION_COMMIT
      End
      select @iPos = Charindex( '3', @IN_MV_MOEDACM )
      If @iPos > 0 and @nOUT_VLR3 > 0  begin    --Moeda 3
	    ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        Update SB2### 
           set B2_VATU3  =  (B2_QATU * @nOUT_VLR3),
               B2_CM3    =  @nOUT_VLR3
         where B2_COD    = @IN_CODIGO
           and D_E_L_E_T_ = ' '
		##CHECK_TRANSACTION_COMMIT
      End
      select @iPos = Charindex( '4', @IN_MV_MOEDACM )
      If @iPos > 0 and @nOUT_VLR4 > 0  begin    --Moeda 4
	    ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        Update SB2### 
           set B2_VATU4  =  (B2_QATU * @nOUT_VLR4),
               B2_CM4    =  @nOUT_VLR4
         where B2_COD    = @IN_CODIGO
           and D_E_L_E_T_ = ' '
		##CHECK_TRANSACTION_COMMIT
      End
      select @iPos = Charindex( '5', @IN_MV_MOEDACM )
      If @iPos > 0 and @nOUT_VLR5 > 0  begin    --Moeda 5
	    ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
        Update SB2### 
           set B2_VATU5  =  (B2_QATU * @nOUT_VLR5),
               B2_CM5    =  @nOUT_VLR5
         where B2_COD    = @IN_CODIGO
           and D_E_L_E_T_ = ' '
		##CHECK_TRANSACTION_COMMIT
      End
    end
    select @OUT_RESULTADO = '1'
End
