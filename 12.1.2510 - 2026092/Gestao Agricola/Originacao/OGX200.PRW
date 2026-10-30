#Include 'totvs.ch'
#Include 'OGX200.ch'

/**{Protheus.doc} OGX200
Ponto de Entrada na Importação de Pedidos de Compra
na Entrada de Documentos
@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	20/08/2013
@Uso: 		SIGAAGR - Originação de Grãos
@Alterado Por: Marcelo R. Ferrari
@Alterado em: 21/08/2014
**/

//Programa Original: ARMXPE21
Function OGX200()
	Local 	_aCampos	:= {}
	
	// Retirado em 04/01/2016 - Pois veio do Template e não é utilizado para nada
	// e estes cpos n. seram criados ( Emerson / Fernanda)
	
/*	aAdd( _aCampos, SC7->C7_CTROG )
	aAdd( _aCampos, SC7->C7_CODSAF )
*/	
Return(_aCampos)

/*/{Protheus.doc} OGX200E
Bloqueia estorno de classificação da Pré-Nota Entrada relacionada ao Agro.
@return _lretorno, Logical, .F. para barrar a alteração na MATA140.
@author: Giovana Becheli
@since: 17/06/2026
/*/
Function OGX200E()
    Local _lretorno  := .T.
     
    If !Empty(SF1->F1_CODROM)
        Agrhelp(STR0001, STR0002)
        //""Pré-nota de Origem Agro. Esta pré-nota foi gerada pelo módulo SIGAAGR e não pode ser estornada.
        //"Para corrigir os dados do produto ou do contrato, exclua o documento de entrada."                                                                                                             
        _lretorno := .F.

    EndIf

Return(_lretorno)

/** {Protheus.doc} OGBLOC
Verifica  se permite alterar registro fora do SIGAAGR 
@param: 	Nil
@return: .t. - verdadeiro / .f. - falso
@author: 	Giovana Becheli
@since: 	17/06/2026
@Uso: 		SIGAAGR - Originação de Grãos */

Function OGBLOC()
Return SuperGetMv("MV_AGRO216",,.F.)
