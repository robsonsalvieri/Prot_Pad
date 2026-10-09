#include 'protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} RBE_COM

Funções de compatibilização e/ou conversão de dados para as tabelas do sistema.

@param cVersion   - Versão do Protheus
@param cMode      - Modo de execução   - "1" = Por grupo de empresas / "2" = Por grupo de empresas + filial (filial completa)
@param cRelStart  - Release de partida - (Este seria o Release no qual o cliente está)
@param cRelFinish - Release de chegada - (Este seria o Release ao final da atualização)
@param cLocaliz   - Localização (país) - Ex. "BRA"

@Return lRet

@author TOTVS - SIGACOM
@since 17/11/23
@version P12
/*/
//-------------------------------------------------------------------
Function RBE_COM( cVersion as Char, cMode as Char, cRelStart as Char, cRelFinish as Char, cLocaliz as Char )

Local lRet    as Logical

Default cVersion   := ''
Default cMode      := ''
Default cRelStart  := ''
Default cRelFinish := ''
Default cLocaliz   := ''

lRet := .T.

If cMode == '1'  // Nivel do grupo de empresas
	//--------------------------------------------------------------
	//- Avalia ajuste do grupo de campos 177 Nome do Fornecedor
	//- Será avaliado da release de saída cliente para qualquer
	//- release final.
	//--------------------------------------------------------------
	If cRelStart < '2410' .AND. cRelFinish >= '2410'
		lRet := totvs.pt.engineering.update.preprocess.RBESXG('177', cRelStart, cRelFinish)
	EndIf
EndIf

Return lRet
