#INCLUDE "TOTVS.CH"
#INCLUDE "AGDC010.CH"

#DEFINE NEGOCIO_REPOSITORIO agd.negocioRepository.agdNegocioRepository
#DEFINE NEGOCIO_HIST_VER agd.negocioHistoricoVersionamentoService.agdNegocioHistoricoVersionamento

/*/{Protheus.doc} AGDC010
Tela para visualização do historico de versionamento do negócio.
@type function
@version 12
@author jc.maldonado
@since 24/03/2025
/*/
Function AGDC010()
	Local aArea := FwGetArea()
	Local cFilNeg := NEA->NEA_FILIAL
	Local cCodNeg := NEA->NEA_CODIGO
	Local oNegRepo
	Local cUltVers
	Local oSize
	Local oHistorico
	Local aNodes
	Local oDlg
	Local oBtnSair
	Local oDBTree

	oNegRepo := NEGOCIO_REPOSITORIO():New(cCodNeg)
	cUltVers := oNegRepo:findLastVersion(cCodNeg)
	FreeObj(oNegRepo)

	if cUltVers <= '001'
		FWRestArea(aArea)
		AGDHELP(STR0002, STR0003, STR0004) //"AJUDA", "Negócio possui apenas uma versão.", "Selecione um negocio com mais de uma versão."
		Return
	endif

	oSize          := FwDefSize():New(.F. /*lEnchoiceBar*/)
	oSize:lLateral := .T.
	oSize:addObject("LEFT_SIDE", 150, 100, .T., .T.)
	oSize:addObject("RIGHT_SIDE", 80, 100, .F., .T.)
	oSize:Process()

	oHistorico := NEGOCIO_HIST_VER():new(cFilNeg, cCodNeg)
	aNodes     := oHistorico:getHistoryForDBTree()
	FreeObj(oHistorico)

	DEFINE MSDIALOG oDlg TITLE STR0001 ; // "Histórico de Versionamento da Negociação
	FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] PIXEL

	oDBTree := createTree(oDlg, oSize, aNodes, cCodNeg)

	FwFreeArray(aNodes)

	@ oSize:GetDimension("RIGHT_SIDE","LININI"), oSize:GetDimension("RIGHT_SIDE","COLINI") + 20 ;
		BUTTON oBtnSair PROMPT STR0005 SIZE 40, 12 ACTION oDlg:End() OF oDlg PIXEL //"Fechar"

	FreeObj(oSize)
	ACTIVATE MSDIALOG oDlg

	FWFreeObj(oDBTree)
	FWRestArea(aArea)
Return

Static Function createTree(oDlg, oSize, aNodes, cCodNeg)
	Local oDBTree
	Local cColunas := FWSX3Util():GetDescription("NEA_CODIGO") + " " + cCodNeg + ";" + STR0006 + ";" + STR0007

	oDBTree := DbTree():New(oSize:GetDimension("LEFT_SIDE","LININI"), oSize:GetDimension("LEFT_SIDE","COLINI"),;
		oSize:GetDimension("LEFT_SIDE","LINEND"), oSize:GetDimension("LEFT_SIDE","COLEND"),;
		oDlg,,,.T.,.T.,,cColunas)
	oDBTree:SetScroll(1, .T./*lHorizontal*/)
	oDBTree:SetScroll(2, .T./*lVertical*/)
	oDBTree:BeginUpdate()
	oDBTree:PTSendTree(aNodes)
	oDBTree:EndUpdate()
	oDBTree:SetEnable()
Return oDBTree
