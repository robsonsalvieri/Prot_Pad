#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออฑฑ
ฑฑบPrograma    ณAjSXACSA   บAutor    ณInova็ใo - RH       บ Data ณ  29/06/2015 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.       ณ Fonte responsแvels pelos ajustas na versใo p12.               บฑฑ
ฑฑบ            ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ DATA      ณ Chamado     ณ  MOTIVO DA ALTERACAO                ณฑฑ
ฑฑณGabriel A.  ณ10/08/2016 ณTVTQ84       ณAjuste no inicializador padrใo do    ณฑฑ
ฑฑณ            ณ           ณ             ณcampo RBH_DIMPOR.                    ณฑฑ
ฑฑณEsther V.   ณ30/10/2016 ณTVOH80       ณAjuste no usado dos campos RBD_FILIALณฑฑ
ฑฑณ            ณ           ณ             ณe RB8_FILIAL.                        ณฑฑ
ฑฑณOswaldo L   ณ27-04-17   ณDRHPONTP300  ณEntre os dias 24-04-17 e 26-04-17    ณฑฑ
ฑฑณ            ณ           ณ             ณbaixamos os fontes do TFS das pastas ณฑฑ
ฑฑณ            ณ           ณ             ณMAIN, 12.1.14 e 12.1.16. Conforme    ณฑฑ
ฑฑณ            ณ           ณ             ณsolicitado fizemos merge delas,depoisณฑฑ
ฑฑณ            ณ           ณ             ณremovemos alteracoes em SX           ณฑฑ
ฑฑณEsther V.   ณ08/05/2017 ณDRHPONTP-330 ณIncluida validacao de compartilhamen-ณฑฑ
ฑฑณ            ณ           ณ             ณto p/ tabelas envolvendo campo _MAT. ณฑฑ
ฑฑณM. Silveira ณ09/05/2017 ณDRHPONTP-444 ณAjuste p/ permitir alterar o tamanho ณฑฑ
ฑฑณ            ณ           ณ             ณdo campo RB6_COEFIC.                 ณฑฑ
ฑฑอออออออออออฯออออฯอออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Main function CSALoad()

	Local lRet		:= .T.

	lRet := fChkConv12()
	If !lRet
		Return
	EndIf

Return (.T.)

