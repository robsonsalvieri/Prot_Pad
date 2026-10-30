#include "protheus.ch"

/*/{Protheus.doc} AGENTFAT.PRW
Funções Genéricas utilizadas no Agent Vendas ( Faturamento )
@since 07/2026
/*/


//------------------------------------------------------------------
/*/{Protheus.doc} getCredData
 Função que organiza dados calculados de credito no mata450 (a450tela)
 @return jDados, json
 @author Leandro Fini
  @since  07/2026
  @version 1.0
/*/
//-------------------------------------------------------------------
Function getCredData(jDados,aSaldos)

	Default aSaldos := {}
	Default jDados  := JsonObject():New()

	jDados['RiscoCliente']  := SA1->A1_RISCO
	jDados["LimiteCredito"] := aSaldos[1,2]//_LIMCRED
	jDados["QuantidadeTitulosProtestados"] := SA1->A1_TITPROT
	jDados["DataUltimoTituloProtestado"]   := DtoC(SA1->A1_DTULTIT)
	jDados["SaldoTitulos"] := aSaldos[2,2]//_SALDUP
	jDados["ChequesDevolvidos"] := SA1->A1_CHQDEVO
	jDados["DataUltimoChequeDevolvido"] := DtoC(SA1->A1_DTULCHQ)
	jDados["PedidosLiberados"] := aSaldos[3,2]//_SALPEDL
	jDados["MaiorCompra"] := SA1->A1_MCOMPRA
	jDados["SaldoLimiteCredito"] := aSaldos[5,2]//_SALDOLC
	jDados["MaiorDuplicata"] := SA1->A1_MAIDUPL
	jDados["ItemPedidoAtual"] := aSaldos[7,2]//_ITATU
	jDados["MediaAtraso"] := SA1->A1_MAIDUPL
	jDados["VencimentoLimiteCredito"] := DtoC(SA1->A1_VENCLC)
	jDados["SaldoDePedidos"] := aSaldos[9,2]//_SALPED
	jDados["AtrasoAtual"] := aSaldos[10,2]//VALATR
	jDados["LimiteCreditoSecundario"] := aSaldos[11,2]//_LCFIN
	jDados["SaldoLimiteCreditoSecundario"] := aSaldos[12,2]//SALFIN

Return jDados
