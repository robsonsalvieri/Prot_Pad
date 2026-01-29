#Include "agda060mnu.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE STATUS_SERVICE agd.fechamentoFinanceiroStatusService.agdFechamentoFinanceiroStatusService

/*/{Protheus.doc} AGDA60MNU
Lista de rotinas de menu
@type function
@version 12
@author jean.schulze
@since 19/03/2025
@return array, lista de menu
/*/
Function AGDA60MNU()
	Local aRotina := {}

	/**************************************************************************************
    Nao Mudar a Ordem do Menu -	Impacto no Cockpit Barter - Permissão de acesso das rotinas
	***************************************************************************************/	

	ADD OPTION aRotina Title STR0001 Action 'VIEWDEF.AGDA060' OPERATION 2 ACCESS 0  //"Visualizar"
	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGDA060' OPERATION 3 ACCESS 0  //"Incluir"
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.AGDA060' OPERATION 4 ACCESS 0  //"Alterar"
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.AGDA060' OPERATION 5 ACCESS 0  //"Excluir"
	ADD OPTION aRotina Title STR0005 Action 'AGDA060MNS(1)'   OPERATION 4 ACCESS 0  //"Confirmar Conferência"
	ADD OPTION aRotina Title STR0006 Action 'AGDA060MNS(2)'   OPERATION 6 ACCESS 0  //"Cancelar"
	ADD OPTION aRotina Title STR0007 Action 'AGDA060MHT()'    OPERATION 2 ACCESS 0  //"Histórico"
	ADD OPTION aRotina Title STR0009 Action 'AGDR060(.F.)'       OPERATION 2 ACCESS 0 //#"STR0009" //"Imprimir Docto"

return aRotina

/*/{Protheus.doc} AGDA060MNS
Funcao para acionar funcoes da máquina de estado
@type function
@version 12
@author jean.schulze
@since 19/03/2025
@param nAcao, numeric, nAcao
@return variant, true
/*/
Function AGDA060MNS(nAcao)
	Local oStatus as Object 

	oStatus := STATUS_SERVICE():New(NEJ->(NEJ_FILIAL+NEJ_CODIGO))
	
	/*Ações a serem selecionadas na maquina de estado*/
	if nAcao == 1
		oStatus:confirmar()	
	elseif nAcao == 2
		oStatus:cancelar()	
	endif

	if !oStatus:isSuccess()
		AGDHELP(STR0008, oStatus:getMessageError() ) //"Ajuda"
	endif

	FreeObj(oStatus)
Return .T.

/*/{Protheus.doc} AGDA060MHT
Visualiza Histórico
@type function
@version 12
@author jean.schulze
@since 19/03/2025
@return variant, nil
/*/
Function AGDA060MHT()
	Local cChaveI := ""
	Local cChaveA := ""

	cChaveI := "NEJ->("+Alltrim(AGDXSIXCHV("NEJ", 1))+")"
	cChaveA := &(cChaveI)+Space(Len(NE0->NE0_CHAVE)-Len(&cChaveI))

	AGDXHIST("NEJ",cChaveA)

Return

