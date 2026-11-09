Create procedure MAT005_##
  (
    @IN_FILIALCOR  Char('B2_FILIAL'),
    @IN_ARQUIVO    Char(01),
	@IN_FILIALPROC Char('B2_FILIAL'),
    @OUT_RESULTADO Char(01)  OUTPUT
  )

as
/* ------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> MTA3201 </s>
    Assinatura  -  <a> 003 </a>
    Descricao   -  <d> Atualiza a coluna G1_NIV e G1_NIVINV </d>
    Entrada     -  <ri>
                   @IN_FILIALCOR  - Filial Corrente
                   @IN_ARQUIVO    - Arquivo que será atualizado '0' SG1010 '1' SG1TRB010
                   </ri>

                   <ro> @OUT_RESULTADO - Retorna o status do Resultado </ro>
    Responsavel :  <r> Vicente Sementilli </r>
    Data        :  <dt> 20/07/98 </dt>
    <o> Uso         :  MATA330 </o>
----------------------------------------------------------------------------- */
Declare @vNivel       Integer
Declare @vNivInv      Integer
Declare @vProduto     char('G1_COD')
Declare @cNivel       varchar('G1_NIV;D3_NIVEL')
Declare @cNivelAux    varchar('G1_NIV;D3_NIVEL')
Declare @cNivelInv    varchar('G1_NIVINV;D3_NIVEL')
Declare @cNiv01       varchar('G1_NIV;D3_NIVEL')
declare @cFil_SG1     char('G1_FILIAL')
declare @nCount       Integer
declare @nContador    Integer
declare @nRecno       Integer
declare @nRecIni      Integer
declare @nRecFim      Integer
declare @nStep        Integer
declare @cTipo        VarChar(2)
declare @cAux         Varchar(3)
declare @iTranCount   Integer --Var.de ajuste para SQLServer e Sybase.
                              -- Será trocada por Commit no CFGX051 após passar pelo Parse
declare @cFILIALCOR   Char('B2_FILIAL')
declare @cFILIALPROC  Char('B2_FILIAL')
declare @cARQUIVO     Char(01)
declare @cSPACE       Char(01)

/* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */
select @cFILIALCOR = @IN_FILIALCOR
select @cFILIALPROC = @IN_FILIALPROC
select @cARQUIVO = @IN_ARQUIVO
select @cSPACE      = ' '

Select @OUT_RESULTADO = '0'

if ( @cARQUIVO = '0' ) begin
   Select @cAux = 'SG1'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SG1 OutPut
   /*----------------------------------------------------------------------*/
   /* Cursor identificando os itens que sao somente PAS                    */
   /*----------------------------------------------------------------------*/
   select @nContador = 0
   Declare LISTA_SG1 INSENSITIVE Cursor For
	SELECT * FROM (
       Select G1.R_E_C_N_O_, 'PA' TIPO
        From SG1### G1 (nolock)
       Where G1.G1_FILIAL   = @cFil_SG1
         and G1.D_E_L_E_T_  = @cSPACE
         and G1.G1_COD NOT IN ( Select DISTINCT A.G1_COMP
                                  From SG1### A (nolock)
                                 Where A.G1_FILIAL   = @cFil_SG1
                                   and A.D_E_L_E_T_  = @cSPACE
                              )
      Union
       Select G1.R_E_C_N_O_, 'PI' TIPO
        From SG1### G1 (nolock)
       Where G1.G1_FILIAL   = @cFil_SG1
         and G1.D_E_L_E_T_  = @cSPACE
         and G1.G1_COD IN ( Select DISTINCT A.G1_COMP
                              From SG1### A (nolock)
                             Where A.G1_FILIAL   = @cFil_SG1
                               and A.D_E_L_E_T_  = @cSPACE
                          )) TMP
   For Read Only
   Open  LISTA_SG1
   Fetch LISTA_SG1 into @nRecno, @cTipo
   While @@Fetch_Status = 0 begin
      /*----------------------------------------------------------------------*/
      /* Coloca Nivel = '01' para todas linhas de estrutura o qual o produto  */
      /* nao existe na coluna componente, ou seja, sao Prod.Acabados e deixa  */
      /* em branco os itens que são PI's                                      */
      /*----------------------------------------------------------------------*/
      select @nContador = @nContador + 1
      If @nContador = 1 begin
         Begin tran
         select @nContador = @nContador
      End

      if @cTipo = 'PA' begin
         Update SG1###  SET G1_NIV = '01', G1_NIVINV = '99' Where R_E_C_N_O_ = @nRecno
      end else begin
         Update SG1###  SET G1_NIV = '  ', G1_NIVINV = '  ' Where R_E_C_N_O_ = @nRecno
      end
      Fetch LISTA_SG1 into @nRecno, @cTipo

      if ( @nContador > 1023 ) begin
         Commit Tran
         select @nContador = 0
      end
   end
   Close      LISTA_SG1
   deallocate LISTA_SG1
   if ( @nContador > 0 ) begin
      select @iTranCount = 0
      Commit Tran
   end
   /*-------------------------------------------------------*/
   /* Inicializa o nivel da Atualizacao                     */
   /*-------------------------------------------------------*/
   Select @vNivel    = 1
   Select @cNivel    = '01'

   /*-------------------------------------------------------*/
   /* Loop ate o ultimo nivel possivel das estruturas       */
   /*-------------------------------------------------------*/
   While 1=1 Begin
      /*-------------------------------------------------------*/
      /* Ajusta Variavel auxiliar para uso em cursor dinamico  */
      /*-------------------------------------------------------*/
      Select @cNivelAux = @cNivel

      /*-------------------------------------------------------*/
      /* Declara cursor para a Select de Pai do Nivel corrente */
      /*-------------------------------------------------------*/
      Select @nCount = Count(*)
        From SG1### (nolock)
       Where G1_FILIAL   = @cFil_SG1
         and G1_NIV      = @cNivelAux
         and D_E_L_E_T_  = @cSPACE
      If ( @nCount = 0 ) Break
      If ( @cNivelAux = '99' ) Break
      /*------------------------------------------*/
      /* Ajusta o Nivel p/Caracter                */
      /*------------------------------------------*/
      Select @vNivel = @vNivel + 1
      Select @cNivel = CONVERT(VarChar(2),@vNivel)
      if @vNivel <= 9  Select @cNivel = '0' || @cNivel
      Select @cNivelInv = CONVERT(VarChar(02),100 - @vNivel)
      /*------------------------------------------------*/
      /* Ajusta os componentes do Pai com o Nivel Atual */
      /*------------------------------------------------*/
      select @nContador = 0
      Declare LISTA_DE_PAS INSENSITIVE Cursor For
         Select DISTINCT A.G1_COMP
           From SG1### A (nolock), SG1### B (nolock)
          Where A.G1_FILIAL   = @cFil_SG1
            and B.G1_FILIAL   = @cFil_SG1
            and A.G1_NIV      = @cNivelAux
            and A.D_E_L_E_T_  = @cSPACE
            and B.D_E_L_E_T_  = @cSPACE
            and A.G1_COMP = B.G1_COD
      For Read Only
      Open  LISTA_DE_PAS
      Fetch LISTA_DE_PAS into @vProduto
      While @@Fetch_Status = 0  begin
         /* ----------------------------------------------------------------------------------------------------------
            Atualiza o Nivel na Tabela
         ---------------------------------------------------------------------------------------------------------- */
         select @nContador = @nContador + 1
         If @nContador = 1 begin
            Begin tran
            select @nContador = @nContador
         End
         Update SG1###  SET G1_NIV = substring(@cNivel, 1, 2), G1_NIVINV = Substring(@cNivelInv, 1, 2)
          Where G1_FILIAL  =  @cFil_SG1
            and G1_COD     =  @vProduto
            and D_E_L_E_T_ = @cSPACE
         Fetch LISTA_DE_PAS into @vProduto
         if ( @nContador > 1023 ) begin
            Commit Tran
            select @nContador = 0
         end
      end
      Close LISTA_DE_PAS
      Deallocate LISTA_DE_PAS
      if ( @nContador > 0 ) begin
         Commit Tran
         select @iTranCount = 0
      end
   end
end else begin
   Select @cFil_SG1 = ##TAMSX3DIC_001('G1_FILIAL')##ENDTAMSX3DIC_001
   select @nContador = 0
   select @cNiv01    = '01'
   select @nStep     = 20000

   /*----------------------------------------------------------------------*/
   /* A tabela é recriada a cada execução no MA330NivCD                    */
   /*        NÃO É NECESSÁRIO FILTRAR DELETADOS                            */
   /*----------------------------------------------------------------------*/
   Select @nRecIni = Min(G1.R_E_C_N_O_), @nRecFim = Max(G1.R_E_C_N_O_)
        From TRB###SG1 G1 (nolock)
       Where G1.G1_FILPROC  = @cFILIALPROC
         and G1.G1_FILIAL   = @cFil_SG1

   /*-----------------------------------------------------------------------*/
   /* Na função MA330NivCD a tabela é criada com NIV = '01' e NIVINV = '99' */
   /* Basta então limpar o conteúdo dos produtos que não são Produtos       */
   /* Acabados                                                              */
   /*-----------------------------------------------------------------------*/
   While @nRecIni <= @nRecFim Begin
      Update TRB###SG1  
      SET G1_NIV    = '  ', 
          G1_NIVINV = '  ' 
      Where
          G1_FILPROC = @cFILIALPROC
      And G1_FILIAL  = @cFil_SG1
      And G1_NIV     = @cNiv01
      And R_E_C_N_O_ >= @nRecIni
      And R_E_C_N_O_ < (@nRecIni+@nStep)
      And Exists ( Select 1 
                   From TRB###SG1 A (nolock) 
                   Where 
                       A.G1_FILPROC  = @cFILIALPROC
                   And A.G1_FILIAL   = @cFil_SG1
                   And A.G1_COMP     = TRB###SG1.G1_COD
      )

      Select @nRecIni = @nRecIni + @nStep
   End
   
   /*-------------------------------------------------------*/
   /* Inicializa o nivel da Atualizacao                     */
   /*-------------------------------------------------------*/
   Select @vNivel    = 1
   Select @cNivel    = '01'

   /*-------------------------------------------------------*/
   /* Loop ate o ultimo nivel possivel das estruturas       */
   /*-------------------------------------------------------*/
   While 1=1 Begin
      /*-------------------------------------------------------*/
      /* Ajusta Variavel auxiliar para uso em cursor dinamico  */
      /*-------------------------------------------------------*/
      Select @cNivelAux = @cNivel

      /*-------------------------------------------------------*/
      /* Declara cursor para a Select de Pai do Nivel corrente */
      /*-------------------------------------------------------*/
      Select @nCount = Count(*)
        From TRB###SG1 (nolock)
       Where G1_FILPROC  = @cFILIALPROC
         and G1_FILIAL   = @cFil_SG1
         and G1_NIV      = @cNivelAux
      If ( @nCount = 0 ) Break
      If ( @cNivelAux = '99' ) Break

      /*------------------------------------------*/
      /* Ajusta o Nivel p/Caracter                */
      /*------------------------------------------*/
      Select @vNivel = @vNivel + 1
      Select @cNivel  = CONVERT(VarChar(2), @vNivel)
      Select @vNivInv = 100 - @vNivel
      Select @cNivelInv = CONVERT(VarChar(2), @vNivInv)

      if @vNivel <= 9  Select @cNivel = '0' || @cNivel
      if @vNivInv <= 9  Select @cNivelInv = '0' || @cNivelInv
      /*------------------------------------------------*/
      /* Ajusta os componentes do Pai com o Nivel Atual */
      /*------------------------------------------------*/
      Update TRB###SG1 
         SET G1_NIV     = Substring(@cNivel, 1, 2), 
             G1_NIVINV  = Substring(@cNivelInv, 1, 2)
       Where G1_FILPROC = @cFILIALPROC
         And G1_FILIAL  = @cFil_SG1  
         And EXISTS (
                SELECT 1
                  FROM TRB###SG1 A (nolock)
                 WHERE A.G1_FILPROC = @cFILIALPROC
                   And A.G1_FILIAL  = @cFil_SG1  
                   And A.G1_NIV     = @cNivelAux -- Encontra os pais no nível atual
                   And A.G1_COMP    = TRB###SG1.G1_COD -- Liga o componente ao Produto que está sendo atualizado
             )
   end
end
Select @OUT_RESULTADO = '1'
