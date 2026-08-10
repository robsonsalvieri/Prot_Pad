Create procedure PCP001_## 
  (
    @IN_FILIALSG1  Char('G1_FILIAL'),
    @OUT_RESULTADO Char(01)  OUTPUT
  )
As
/* ------------------------------------------------------------------------------
    Versùo      -  <v> Protheus P12 </v>
    Programa    -  <s> PCPA200NIV.PRW </s>
    Assinatura  -  <a> 003 </a>
    Descricao   -  <d> Atualiza a coluna B1_NIVEL de acordo com a SG1 </d>
    Entrada     -  <ri> 
				   @IN_FILIALSG1  - Filial Tabela SG1
	               </ri>
    Saida       -  <ro> @OUT_RESULTADO - Retorna o status do Resultado </ro>
    Responsavel :  <r> Vivian Beatriz de Almeida  </r>
    Data        :  <dt> 28/04/2023 </dt> 
----------------------------------------------------------------------------- */
Declare @cNivel       VarChar('G1_NIV')
Declare @cNivelAnt    VarChar('G1_NIV')
Declare @cNivelInv    VarChar('G1_NIVINV')
Declare @iCount       Integer
Declare @iNivel       Integer
Declare @iNivelInv    Integer 

Select @OUT_RESULTADO = '0'

Begin Tran
/* -----------------------------------------
  Atualiza todos os produtos para nivel 02
----------------------------------------- */
Update SG1###
   Set G1_NIV     = '02',
       G1_NIVINV  = '98'
 Where G1_FILIAL  = @IN_FILIALSG1
   And D_E_L_E_T_ = ' ' 

/* -----------------------------------------
  Atualiza os PAs com o nivel 01
----------------------------------------- */
Update SG1###
   Set G1_NIV     = '01', 
       G1_NIVINV  = '99'
 Where G1_FILIAL  = @IN_FILIALSG1 
   And D_E_L_E_T_ = ' ' 
   And Not Exists (Select 1
                     From SG1### SG1A (nolock)
                    Where SG1A.G1_FILIAL  = @IN_FILIALSG1 
                      And SG1A.G1_COMP    = SG1###.G1_COD
                      And SG1A.D_E_L_E_T_ = ' ')

Commit Tran

/* -----------------------------------------
  Inicializa o nivel da Atualizacao 
----------------------------------------- */
Select @iNivel = 2
Select @cNivel = '02'

/* --------------------------------------------------
  Loop ate o ultimo nivel possivel das estruturas
-------------------------------------------------- */
While 1=1 Begin
	/* --------------------------------------------------------
	  Verifica se existem produtos no nivel corrente
	-------------------------------------------------------- */
	Select @iCount = Count(*)
	  From SG1### (nolock)
	 Where G1_FILIAL = @IN_FILIALSG1
	   And G1_NIV = @cNivel
	   And D_E_L_E_T_ = ' '
 
	If (@iCount = 0)  Break

	/* --------------------------------------------------------
	  Salva o ultimo nivel atualizado
	-------------------------------------------------------- */
	Select @cNivelAnt = @cNivel

	/* --------------------------------------------------------
	  Ajusta o tipo do Nivel para Caracter
	-------------------------------------------------------- */
	Select @iNivel = @iNivel + 1
	Select @cNivel = Convert(VarChar(2),@iNivel)
	Select @iNivelInv = 100 - @iNivel
	Select @cNivelInv = Convert(VarChar(2),@iNivelInv)

	If @iNivel <= 9  Select @cNivel = '0' || @cNivel 
	If @iNivelInv <= 9  Select @cNivelInv = '0' || @cNivelInv

	/* -------------------------------------------------------------------
	  Adiciona nivel no componente em que seu pai esta no nivel anterior
	------------------------------------------------------------------- */

	Begin Tran
	Update SG1###
	   Set G1_NIV     = @cNivel,
	       G1_NIVINV  = @cNivelInv 
	 Where G1_FILIAL  = @IN_FILIALSG1
	   And D_E_L_E_T_ = ' ' 
	   And Exists (Select 1
	                 From SG1### SG1A (nolock)
	                Where SG1A.G1_FILIAL  = @IN_FILIALSG1
	                  And SG1A.G1_COMP    = SG1###.G1_COD
	                  And SG1A.D_E_L_E_T_ = ' '
	                  And Exists (Select 1
	                                From SG1### PAI (nolock)
	                               Where PAI.G1_FILIAL = @IN_FILIALSG1
	                                 And PAI.G1_COD    = SG1A.G1_COD
	                                 And PAI.G1_NIV    = @cNivelAnt))
	Commit Tran

End

Select @OUT_RESULTADO = '1'
