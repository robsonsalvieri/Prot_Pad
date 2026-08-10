#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDI072.CH"

/*/{Protheus.doc} AGDI072
Função chamada na criação de botão da ViewDef do cad. cliente
@type function
@version 12
@author rodrigo.nsoledade
@since 25/09/2025
@param oView
/*/
Function AGDI072(oView)
	Default oView := Nil

	//Adiciona na view se o parametro MV_SIGAAGD estiver ativo
	If ValType(oView) == "O" .And. Type("SA1->A1_COD") == "C"
		oView:AddUserButton(STR0001,"",{|| AGDP060CRM(SA1->A1_COD,SA1->A1_LOJA)},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} ) //"Dados Agronegócio"
	EndIf

Return oView
