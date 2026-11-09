#Include "agda130mnu.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} AGDA130MNU
Menu do AGDA130
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Function AGDA130MNU()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0001 Action 'VIEWDEF.AGDA130' OPERATION 2 ACCESS 0  //"Visualizar" //"Detalhe"
	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGDA130' OPERATION 3 ACCESS 0 //#"Incluir" //"Nova Conta Cooperado"
	ADD OPTION aRotina Title STR0003 Action 'AGDA130T(NF3->NF3_CODCOO, NF3->NF3_LOJCOO)' OPERATION 3 ACCESS 0 //#"Incluir" //"Transferência de Cotas e Valores Cooperado"
	ADD OPTION aRotina Title STR0004 Action 'AGDA141()' OPERATION 4 ACCESS 0 //#STR0004 //"Informar Movimento Avulso"
	ADD OPTION aRotina Title STR0005 Action 'AGDA142()' OPERATION 4 ACCESS 0 //#STR0005 //"Encerramento de Conta Cooperado"
	ADD OPTION aRotina Title STR0006 Action 'AGDC130(NF3->NF3_CODCOO, NF3->NF3_LOJCOO)' OPERATION 2 ACCESS 0 //"Evolução de Capital"
	ADD OPTION aRotina Title STR0007 Action 'AGDA143()' OPERATION 4 ACCESS 0 //#"Reativar Conta"
	ADD OPTION aRotina Title STR0008 Action 'AGDA130HT()' OPERATION 7 ACCESS 0 //#"Histórico"
	

Return aRotina

/*/{Protheus.doc} AGDA130HT
Lista o histórico de ativação e inativação de cooperado
@type function
@version 12
@author thomaz.coelho
@since 02/07/2026
/*/
Function AGDA130HT()
	AGDXHIST("NF3", NF3->NF3_FILIAL + NF3->NF3_CODCOO + NF3->NF3_LOJCOO)
return
