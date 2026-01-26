#Include "agda010mnu.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CONTRATO_ACL_SERVICE agd.contratoAclService.agdContratoAclService
#DEFINE NEGOCIO_STATUS_SERVICE agd.negocioStatusService.agdNegocioStatusService
#DEFINE NEGOCIO_SERVICE agd.negocioService.agdNegocioService

/*/{Protheus.doc} AGDA10MNU
Retorna a lista de Menu
@type function
@version 12
@author jean.schulze
@since 31/01/2025
@return variant, array rotinas
/*/
Function AGDA10MNU()
	Local aRotina := {}

	/**************************************************************************************
    Nao Mudar a Ordem do Menu -	Impacto no Cockpit Barter - Permissão de acesso das rotinas
	***************************************************************************************/	

	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.AGDA010'	OPERATION 2 ACCESS 0 //#STR0007 //"Visualizar"
	ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.AGDA010'	OPERATION 3 ACCESS 0 //#STR0008 //"Incluir"
	ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.AGDA010'	OPERATION 4 ACCESS 0 //#STR0009 //"Alterar"
	ADD OPTION aRotina Title STR0010 Action 'VIEWDEF.AGDA010'	OPERATION 5 ACCESS 0 //#STR0010 //"Excluir"
	ADD OPTION aRotina Title STR0011 Action 'AGDA010MIE()'		OPERATION 3 ACCESS 0 //#STR0011 //"Gerar Instr. Embarque"
	ADD OPTION aRotina Title STR0001 Action 'AGDA010MAP("2")' 	OPERATION 6 ACCESS 0 //#STR0001 //"Aprovar"
	ADD OPTION aRotina Title STR0002 Action 'AGDA010MAP("1")' 	OPERATION 6 ACCESS 0 //#STR0002	 //"Reprovar"
	ADD OPTION aRotina Title STR0013 Action 'AGDA010MCV'		OPERATION 2 ACCESS 0 //#STR0013	 //"Contratos de Compra"
	ADD OPTION aRotina Title STR0005 Action 'AGDA010MIV()'   	OPERATION 4 ACCESS 0 //#"Informar Contratos Compra" //"Informar Venda Perdida"
	ADD OPTION aRotina Title STR0006 Action 'AGDA010MVP()'	    OPERATION 2 ACCESS 0 //#"Visualizar Contratos" //"Visualizar Vendas Perdidas"
	ADD OPTION aRotina Title STR0026 Action 'AGDA010F'  		OPERATION 3 ACCESS 0 //#"Fechamento Financeiro"
	ADD OPTION aRotina Title STR0035 Action 'AGDA010N()'		OPERATION 3 ACCESS 0 //#STR0035  //"Rateio de Entregas"
	ADD OPTION aRotina Title STR0027 Action 'AGDA010MVS'		OPERATION 9 ACCESS 0 //"Versionar Negociação"
	ADD OPTION aRotina Title STR0015 Action 'AGDA010MHT()'   	OPERATION 2 ACCESS 0 //#STR0015 "Histórico"
	ADD OPTION aRotina Title STR0031 Action 'AGDC010()'	        OPERATION 2 ACCESS 0 //#STR0031 "Histórico de Versionamento"
	ADD OPTION aRotina Title STR0020 Action 'AGDA010MAP("3")' 	OPERATION 6 ACCESS 0 //#"STR0020" //"Cancelar Negociacao"
	ADD OPTION aRotina Title STR0032 Action 'AGDR010()' 	  	OPERATION 2 ACCESS 0 //#"STR0032" //"Imprimir word"

return aRotina

/*/{Protheus.doc} AGDA010MAP
Chama função para aprovação e recusa da negociação
@type function
@version P12.1.2510 
@author gilson.venturi
@since 16/12/2024
/*/
Function AGDA010MAP(iAcao)
	Local lRet		:= .F.
	Local oNegocioStatus := NEGOCIO_STATUS_SERVICE():New(NEA->(NEA_FILIAL+NEA_CODIGO+NEA_VERSAO))

	if iAcao == '1'
		oNegocioStatus:recusar()
		if !oNegocioStatus:isSuccess()
			AGDHELP(STR0017, oNegocioStatus:getMessageError(), ) // "Ajuda"
		endif
	elseif iAcao == '2'
		oNegocioStatus:liberar()
		if !oNegocioStatus:isSuccess()
			AGDHELP(STR0017, oNegocioStatus:getMessageError(), ) // "Ajuda"
		endif
	elseif iAcao == '3'
		oNegocioStatus:cancelar()
		if !Empty(oNegocioStatus:getMessageError())
			AGDHELP(STR0017, STR0021, oNegocioStatus:getMessageError())
		endif
	endif

	lRet := oNegocioStatus:isSuccess()
	
	If lRet
		FWAlertSuccess( oNegocioStatus:getResponse() ) 
	EndIf

	//Evitar loop na reprovação
	if iAcao == '1'
		lRet := .F.
	EndIf

	FreeObj(oNegocioStatus)
Return lRet

/*/{Protheus.doc} AGDA010MHT
Chama função para exibir o historico de ações realizadas em um registro posicionado em tela/tabela.
O historio para a negociação irá trazer na tela todos os  registro de todas as versões da negociação.
@type function
@version P12.1.2510
@author Gilson.Venturi
@since 06/01/2025
/*/
Function AGDA010MHT()
	Local cChaveTemp := ""
	Local cChaveI := Alltrim(AGDXSIXCHV("NEA", 1))
	Local cChaveP := ""
	Local cChaveA := ""
	Local nSubstr:= 0
	Local nSubChv:= 0

	/** NÃO SERÁ CONSIDERADO A VERSAO NO RETORNO DOS REGISTROS DE HISTORICO **/
	nSubChv:= At("+NEA_VERSAO",cChaveI) -1
	cChaveI := SubStr(cChaveI,1,nSubChv)
	cChaveI := "NEA->("+Alltrim(cChaveI)+")"
	cChaveA := &(cChaveI)+Space(Len(NE0->NE0_CHAVE)-Len(&cChaveI))

	nSubstr := LEN(Alltrim(&cChaveI))
	AGDXHIST("NEA",cChaveA,nSubstr)

Return

/*/{Protheus.doc} AGDA010MCV
Chamada de Menu para Abrir Listagem de Contratos do Negócio
@type function
@version 12
@author jean.schulze
@since 13/01/2025
@return variant, nil
/*/
Function  AGDA010MCV()
	SetFunName("AGDA030")
	AGDA030("NEF->NEF_CODBRT == '"+ NEA->NEA_CODIGO +"'" )
	SetFunName("AGDA010")
return nil

/*/{Protheus.doc} AGDA010MCT 
Chamada de Menu para Geração de Contratos
@type function
@version 12
@author jean.schulze
@since 13/01/2025
@return variant, nil
/*/
Function AGDA010MCT()
	Local oContratoACLService := nil

	oContratoACLService := CONTRATO_ACL_SERVICE():New(NEA->NEA_CODIGO)
	FWMsgRun(, {|| oContratoACLService:gerarContratos()}, STR0033, STR0034 ) //"Aguarde!","Gerando Contrato... "
	if oContratoACLService:isSuccess()
		MsgInfo(oContratoACLService:getResponse(), STR0016 ) //"Gerar Contratos de Compra"
	else
		AGDHELP(STR0017, oContratoACLService:getMessageError(), oContratoACLService:getSolutionError()) //"Ajuda"
	endif

	FreeObj(oContratoACLService)

return nil

/*/{Protheus.doc} AGDA010MVP
Visualizar Vendas Perdidas
@type function
@version 12
@author jean.schulze
@since 03/02/2025
@return variant, nil
/*/
Function AGDA010MVP()
	SetFunName("AGDA050")
	AGDA050("NEL->NEL_CODBRT == '"+ NEA->NEA_CODIGO +"'" )
	SetFunName("AGDA010")
return nil

/*/{Protheus.doc} AGDA010MIV
Informar Venda Perdida
@type function
@version 12
@author jean.schulze
@since 03/02/2025
@return variant, nil
/*/
Function AGDA010MIV(cInsumo)
	Local aAreaNEA  := NEA->(GetArea())
	Local oModel    := nil

	oModel := FwLoadModel('AGDA050')
	oModelNEC := oModel:GetModel("AGDA050_NEL")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	If oModel:Activate()
		oModelNEC:SetValue('NEL_FILIAL', NEA->NEA_FILIAL)
		oModelNEC:SetValue('NEL_CODBRT', NEA->NEA_CODIGO)

		if !Empty(cInsumo)
			oModelNEC:SetValue('NEL_ITEBRT', cInsumo)
		endif

		FWExecView(oModel:GetDescription(), "AGDA050", MODEL_OPERATION_INSERT, , , ,0, , , , , oModel)

	Endif

	RestArea(aAreaNEA)

Return .T.

/*/{Protheus.doc} AGDA010MVS
Realiza o versionamento da negociação
@type function
@version P12 
@author claudineia.reinert
@since 18/02/2025
/*/
Function AGDA010MVS()
	Local oNegocioService := nil

	BEGIN TRANSACTION

		oNegocioService := NEGOCIO_SERVICE():New()

		oNegocioService:gerarVersionamento(NEA->NEA_FILIAL+NEA->NEA_CODIGO+NEA->NEA_VERSAO, .T.)

		If oNegocioService:isSuccess()
			FWAlertSuccess( STR0028 + oNegocioService:getResponse(), STR0027 ) //#"Nova versão gerada com sucesso! "#"Versionar Negociação"
		Else
			FWAlertError( oNegocioService:getMessageError(), STR0027 ) //#"Versionar Negociação"
		EndIf

		if !oNegocioService:isSuccess()
			DisarmTransaction()
		endif

	END TRANSACTION
	FreeObj(oNegocioService)

Return .T.
