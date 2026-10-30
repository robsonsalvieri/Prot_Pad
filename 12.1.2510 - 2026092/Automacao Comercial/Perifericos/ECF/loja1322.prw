#INCLUDE "MSOBJECT.CH"

Function LOJA1322 ; Return 	 // "dummy" function - Internal Use 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบClasse    ณLJCDadosReducaoZ    บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em armazenar os dados da reducaoZ				            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		    บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Class LJCDadosReducaoZ
   	
   	Data dDataMov											//Data do movimento
   	Data cNumEcf											//Numero do ecf / caixa
   	Data cNrSerie											//Numero de serie
   	Data cNumRedZ											//Numero de reducoesZ
   	Data nGranTotal											//Grande total   	
   	Data cNumCupFim											//Numero do ultimo cupom emitido antes da reducaoZ
   	Data nTotCancel											//Total cancelados acumulado ISS + ICMS
   	Data nTotCanISS											//Total Cancelado de ISS
   	Data nTotDesc											//Total de descontos acumulado ISS + ICMS
   	Data nTotDesISS										//total de desconto de ISS
   	Data nTotIsent											//Total de isentos
   	Data nTotNTrib											//Total de nao tributado
   	Data nTotIss											//Total de ISS
	Data nVendaLiq											//Venda liquida
	Data nVendaBrut											//Venda Bruta
	Data oImpostos											//Objeto do tipo LJCImpostosEcf
	Data nTotSubst											//Total de substituicao
	Data dDataRed											//Data da reducao
	Data cCoo												//Numero do cupom da reducaoZ
	Data cCro												//Numero do contador de reinicio de operacao
   	Data cNumCupIni											//Numero do cupom inicial do dia   	   			
   	Data oImpISS											//Objeto do que retorna as aliquotas de ISS do tipo LJCImpostosEcf
   	Data nTotIssIse
   	Data nTotIssNTr
   	Data nTotIssSub   	

	Method New()											//Metodo construtor
	Method AdicImp(nAliquota, nBase, nImposto,cTipo)		//Adiciona o imposto
	
EndClass

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณNew   	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJCDadosReducaoZ. 		    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method New() Class LJCDadosReducaoZ

   	::dDataMov 		:= Nil
   	::cNumEcf		:= ""
   	::cNrSerie		:= ""
   	::cNumRedZ		:= ""
   	::nGranTotal	:= 0
   	::cNumCupFim	:= ""
   	::nTotCancel	:= 0
   	::nTotCanISS	:= 0
   	::nTotDesc		:= 0
   	::nTotDesISS	:= 0
   	::nTotIsent		:= 0
   	::nTotNTrib		:= 0
   	::nTotIss		:= 0
	::nVendaLiq		:= 0
	::nVendaBrut	:= 0
	::oImpostos		:= LJCImpostosEcf():New()
	::nTotSubst		:= 0
	::dDataRed		:= Nil
	::cCoo			:= ""
	::cCro			:= ""
	::cNumCupIni	:= ""
	::oImpISS		:= LJCImpostosEcf():New()
	::nTotIssIse	:= 0
   	::nTotIssNTr	:= 0
   	::nTotIssSub 	:= 0
	
Return Self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบMetodo    ณAdicImp  	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em adicionar um imposto ao objeto oImpostos.    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1 (1 - nAliquota) - Valor da aliquota.		   				 บฑฑ
ฑฑบ			 ณEXPN2 (2 - nBase) - Base de calculo.								 บฑฑ
ฑฑบ			 ณEXPN3 (3 - nImposto) - Valor do imposto.			   				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method AdicImp(nAliquota, nBase, nImposto, cTipo) Class LJCDadosReducaoZ
Local oImposto := Nil					//Objeto do tipo LJCImpostoEcf

DEFAULT cTipo  := 'T'	

oImposto := LJCImpostoEcf():New(nAliquota, nBase, nImposto)

If cTipo == 'T'		// Alํquota de ICMS	
	::oImpostos:ADD(nAliquota, oImposto, .T.)
ElseIf cTipo == 'S'	// Alํquota de ISS	
	::oImpISS:ADD(nAliquota, oImposto, .T.)
EndIf
	
Return Self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบFunction  ณLj22ImpISS	   บAutor  ณVendas Clientes     บ Data ณ  07/02/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSinaliza se possui o Objeto oImpIss.					    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Lj22ImpISS
Return .T.
