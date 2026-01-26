#include "protheus.ch"

Function OFCNH0004();Return

/*/{Protheus.doc} OFCNHPrimCanalVenda
	Canais de venda 

	@author       Vinicius Gati
	@since        05/02/2018
	@description  Canais de Venda

/*/
Class OFCNHPrimCanalVenda from LongNameClass
	Method New() CONSTRUCTOR
	Method CanalOficina()
	Method CanalBalcao()
	Method CanalAjuste()
	Method CanalDescarte()
	Method CanalVendaPerdida()
	Method CanalEcommerce()
	Method CanalServicos()
	Method CanalRecompra()
	Method CanalTransf()
	Method CanalDiversos()
	Method retCanal()
ENDCLASS

Method New() Class OFCNHPrimCanalVenda
Return SELF

/*/{Protheus.doc} CanalOficina
	Canal padrao de oficina
	
	@type function
	@author Vinicius Gati
	@since 23/02/2018
/*/
Method CanalOficina() Class OFCNHPrimCanalVenda
Return 'A'

/*/{Protheus.doc} CanalBalcao
	Retorna o canal padrão para devoluções de peças
	
	@type function
	@author Vinicius Gati
	@since 23/02/2018
/*/
Method CanalBalcao() Class OFCNHPrimCanalVenda	
Return 'B'

/*/{Protheus.doc} CanalTransf()
	Canal de venda de transferencias

	@type function
	@author Vinicius Gati
	@since 12/04/2018
/*/
Method CanalAjuste() Class OFCNHPrimCanalVenda
Return 'C'

/*/{Protheus.doc} CanalDescarte
	
	@type function
	@author Vinicius Gati
	@since 22/04/2024
/*/
Method CanalDescarte() Class OFCNHPrimCanalVenda
Return 'D'

/*/{Protheus.doc} CanalVendaPerdida
	
	@type function
	@author Vinicius Gati
	@since 22/04/2024
/*/
Method CanalVendaPerdida() Class OFCNHPrimCanalVenda
Return 'E'

/*/{Protheus.doc} CanalEcommerce

	@type method
	@author Vinicius Gati
	@since 22/04/2024
/*/
Method CanalEcommerce() Class OFCNHPrimCanalVenda
Return 'F'

/*/{Protheus.doc} CanalServicos

	@type method
	@author Vinicius Gati
	@since 22/04/2024
/*/
Method CanalServicos() Class OFCNHPrimCanalVenda
Return 'G'

/*/{Protheus.doc} CanalRecompra
	canal de recompra
	
	@type function
	@author Vinicius Gati
	@since 12/04/2018
/*/
Method CanalRecompra() Class OFCNHPrimCanalVenda
Return '3'

/*/{Protheus.doc} CanalTransf()
	Canal de venda de transferencias

	@type function
	@author Vinicius Gati
	@since 12/04/2018
/*/
Method CanalTransf() Class OFCNHPrimCanalVenda
Return '4'

/*/{Protheus.doc} CanalDiversos()
	Canal de venda CanalDiversos - Excessões

	@type function
	@author Cristiam Rossi
	@since 17/04/2025
/*/
Method CanalDiversos() Class OFCNHPrimCanalVenda
Return 'V'

/*/{Protheus.doc} CanalDiversos()
	Método que retorna o Canal de venda

	@type function
	@author Cristiam Rossi
	@since 17/04/2025
/*/
Method retCanal( cOrigem, cOpeMov, cCodSit, cIndPre, cCodCli, cLojCli ) Class OFCNHPrimCanalVenda
local   cRetorno := ::CanalDiversos()
default cOrigem  := ""
default cOpeMov  := ""
default cCodSit  := ""
default cIndPre  := ""
default cCodCli  := ""
default cLojCli  := ""

/*
		Avaliar a questão de precedência, mudança da ordem dos IFs para atender melhor a questão do negócio			!!!!!!!!!!!!!
*/

	if cOrigem == "OFI";	cRetorno := ::CanalOficina();	endif

	if cOrigem == "BAL";	cRetorno := ::CanalBalcao();	endif

	if cOrigem == "SRV";	cRetorno := ::CanalServicos();	endif		// ver aqui

	if cOpeMov $ "12,15";	cRetorno := ::CanalAjuste();	endif

	if cOpeMov == "03";		cRetorno := ::CanalTransf();	endif

	if cCodSit == "03" .and. posicione("V09",1,xFilial("V09")+cCodSit,"V09_LEVDEM")=="0";	cRetorno := ::CanalDescarte();	endif

	if cIndPre $ "2,3";		cRetorno := ::CanalEcommerce();	endif

	if ! empty( cCodCli ) .and. ! empty( cLojCli ) .and. type("oConf") == "O" .and. oConf:CCODCLIRECOMP == cCodCli .and. oConf:CLOJCLIRECOMP == cLojCli
		cRetorno := ::CanalRecompra()
	endif

return cRetorno
