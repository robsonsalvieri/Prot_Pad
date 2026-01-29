#INCLUDE "AGDA060.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE NEGOCIO_SERVICE agd.negocioService.agdNegocioService

#DEFINE TITULO_FINANCEIRO_REPOSITORY agd.tituloFinanceiroRepository.agdTituloFinanceiroRepository
#DEFINE FECHAMENTO_STATUS_SERVICE agd.fechamentoFinanceiroStatusService.agdFechamentoFinanceiroStatusService


/*/{Protheus.doc} AGDA060
Rotina para Fechamento Financeiro
@type function
@version P12
@author Gilson.Venturi
@since 25/02/2025
/*/
Function AGDA060()
	Local oMBrowse as object
	Local oStatus  as object

	If .Not. TableInDic('NEJ')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oStatus  := FECHAMENTO_STATUS_SERVICE():new()
	oMBrowse := oStatus:getBrowserLegenda()
	oMBrowse:SetDescription( STR0001 ) //#"Fechamento Financeiro"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

	FreeObj(oStatus)

Return Nil

/*/{Protheus.doc} MenuDef
Definicao Menu
@type function
@version 12
@author jean.schulze
@since 19/03/2025
@return variant, nil
/*/
Static Function MenuDef()
Return AGDA60MNU()

/*/{Protheus.doc} ModelDef
Definição Model
@type function
@version 12
@author jean.schulze
@since 19/03/2025
@return object, model
/*/
Static Function ModelDef()
	Local oModel	 := Nil
	Local oStruNEJ	 := FwFormStruct( 1, "NEJ" )
	Local oStruCOMPR := FwFormStruct( 1, "NEK" )
	Local oStruVENDA := FwFormStruct( 1, "NEK" )
	Local oEvent     := AGDA060EVT():New()
	Local cCodCmp    := "1"
	Local cCodVda	 := "2"

	oModel := MpFormModel():New( "AGDA060")
	oModel:SetDescription( STR0001 ) //##"Fechamento Financeiro"

	oStruCOMPR:SetProperty( "NEK_CODBRT" 	, MODEL_FIELD_INIT 	, {| | M->NEJ_CODBRT } )
	oStruVENDA:SetProperty( "NEK_CODBRT" 	, MODEL_FIELD_INIT 	, {| | M->NEJ_CODBRT } )

	//adiciona campo de check na grid para seleção
	oStruCOMPR:AddField('', '', 'CHECK', 'L', 1, 0,{|| AGDA060CAL(oModel)},, {}, .F.,, .F., .F., .F.,,)
	oStruVENDA:AddField('', '', 'CHECK', 'L', 1, 0,{|| AGDA060CAL(oModel)},, {}, .F.,, .F., .F., .F.,,)

	oStruCOMPR:AddField('', '', 'VALID', 'L', 1, 0,,, {}, .F.,, .F., .F., .F.,,)
	oStruVENDA:AddField('', '', 'VALID', 'L', 1, 0,,, {}, .F.,, .F., .F., .F.,,)

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA060_NEJ", , oStruNEJ)
	oModel:GetModel( "AGDA060_NEJ" ):SetDescription( STR0006 ) //#"Dados Fechamento Financeiro"
	oModel:SetPrimaryKey( { "NEJ_FILIAL", "NEJ_CODIGO" } )

	oModel:AddGrid( "COMPR_NEK", "AGDA060_NEJ", oStruCOMPR)
	oModel:AddGrid( "VENDA_NEK", "AGDA060_NEJ", oStruVENDA)
	oModel:GetModel( "COMPR_NEK" ):SetDescription( STR0006 ) //#"Dados Fechamento Financeiro"
	oModel:GetModel( "VENDA_NEK" ):SetDescription( STR0006 ) //#"Dados Fechamento Financeiro"

	//Atribui um relacionamento de Pai X Filho
	oModel:SetRelation( 'COMPR_NEK', {{'NEK_FILIAL', 'xFilial("NEK")'},{ 'NEK_CODFEC', 'NEJ_CODIGO' },{'NEK_CODMOD', "'"+cCodCmp+"'"}}, NEK->(IndexKey( 2 ) ) )
	oModel:SetRelation( 'VENDA_NEK', {{'NEK_FILIAL', 'xFilial("NEK")'},{ 'NEK_CODFEC', 'NEJ_CODIGO' },{'NEK_CODMOD', "'"+cCodVda+"'"}}, NEK->(IndexKey( 2 ) ) )

	oModel:GetModel( "COMPR_NEK" ):SetUniqueLine( { 'NEK_ITEM' } )
	oModel:GetModel( "COMPR_NEK" ):SetOptional( .T. )
	oModel:GetModel( "COMPR_NEK" ):SetUseOldGrid(.T.)

	oModel:GetModel( "VENDA_NEK" ):SetUniqueLine( { 'NEK_ITEM' } )
	oModel:GetModel( "VENDA_NEK" ):SetOptional( .T. )
	oModel:GetModel( "VENDA_NEK" ):SetUseOldGrid(.T.)

	// Cria os campos de totalizadores
	oModel:AddCalc( 'AGDA060_TOTAL', 'AGDA060_NEJ', 'COMPR_NEK', 'NEK_LIQUID', 'TOTVALPG' ,'FORMULA',,,STR0009,{|| CalcSalCP(oModel)}) //'Total Contas Pagar'
	oModel:AddCalc( 'AGDA060_TOTAL', 'AGDA060_NEJ', 'VENDA_NEK', 'NEK_LIQUID', 'TOTVALVD' ,'FORMULA',,,STR0010,{|| CalcSalVD(oModel)}) //'Total Contas Receber liquido'
	oModel:AddCalc( 'AGDA060_TOTAL', 'AGDA060_NEJ', 'VENDA_NEK', 'NEK_LIQUID', 'TOTVALDF' ,'FORMULA',,,STR0011,{|| AGDA060DIF(oModel)} )

	oModel:InstallEvent("AGDA060EVT", /*cOwner*/, oEvent)
Return oModel

/*/{Protheus.doc} ViewDef
Definição Interface Visual
@type function
@version 12
@author jean.schulze
@since 19/03/2025
@return object, view 
/*/
Static Function ViewDef()
	Local oModel		:= FwLoadModel( "AGDA060" )
	Local oStruNEJ		:= FwFormStruct( 2, "NEJ" )
	Local oStruCOMPR	:= FwFormStruct( 2, "NEK" )
	Local oStruVENDA	:= FwFormStruct( 2, "NEK" )
	Local oView			:= FwFormView():New() // Instancia o modelo de dados

	//adiciona campo de check na grid para seleção
	oStruCOMPR:AddField( 'CHECK' ,'01',''  ,'' ,, 'CHECK' ,,,,.T.,,,,,,,, )
	oStruVENDA:AddField( 'CHECK' ,'01',''  ,'' ,, 'CHECK' ,,,,.T.,,,,,,,, )

	oStruCOMPR:RemoveField( "NEK_CODFEC" )
	oStruCOMPR:RemoveField( "NEK_CODBRT" )
	oStruCOMPR:RemoveField( "NEK_CODMOD" )
	oStruCOMPR:RemoveField( "NEK_LIQUID" )
	oStruCOMPR:RemoveField( "NEK_RETENC" )
	oStruVENDA:RemoveField( "NEK_CODFEC" )
	oStruVENDA:RemoveField( "NEK_CODBRT" )
	oStruVENDA:RemoveField( "NEK_CODMOD" )

	If IsInCallStack( "AGDA010F" )
		oStruNEJ:SetProperty("NEJ_CODBRT", MVC_VIEW_CANCHANGE, .F.)
	EndIf

	oCalc := FWCalcStruct( oModel:GetModel( 'AGDA060_TOTAL') )

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NEJ', oStruNEJ, 'AGDA060_NEJ' )

	oView:AddField( 'VIEW_CALC', oCalc , 'AGDA060_TOTAL' )

	oView:AddGrid( 'VIEWCP_NEK', oStruCOMPR, 'COMPR_NEK' )
	oView:AddGrid( 'VIEWVD_NEK', oStruVENDA, 'VENDA_NEK' )

	oView:AddIncrementField( 'VIEWCP_NEK', 'NEK_ITEM' )
	oView:AddIncrementField( 'VIEWVD_NEK', 'NEK_ITEM' )

	oView:CreateHorizontalBox( 'CABEC', 40 )
	oView:CreateHorizontalBox( 'GRID', 45 )
	oView:CreateHorizontalBox( 'RODAPE', 15	)

	oView:CreateFolder( "GRADES", "GRID")
	oView:AddSheet( "GRADES", "PASTA01", STR0007) //"NF Compra"
	oView:AddSheet( "GRADES", "PASTA02", STR0008) //"NF Venda"

	oView:CreateHorizontalBox( "PASTACP_NEK", 100, , , "GRADES", "PASTA01" )
	oView:CreateHorizontalBox( "PASTAVD_NEK", 100, , , "GRADES", "PASTA02" )

	oView:SetOwnerView( 'VIEW_NEJ',		'CABEC' )
	oView:SetOwnerView( 'VIEWCP_NEK',	'PASTACP_NEK' )
	oView:SetOwnerView( 'VIEWVD_NEK',	'PASTAVD_NEK' )
	oView:SetOwnerView( 'VIEW_CALC',	'RODAPE' )

	oView:EnableTitleView("VIEW_NEJ")
	oView:EnableTitleView("VIEWCP_NEK")
	oView:EnableTitleView("VIEWVD_NEK")

	oView:SetCloseOnOk({||.T.})
Return oView



/*/{Protheus.doc} AGDA060LAT
Verifica se a grid possui pelo menos uma linha ativa (não deletada)
@type function
@version 1.0
@author rodrigo.nsoledade
@since 06/06/2025
@param oGrid, object, Grid a ser analisada
@return logical, .T. se houver ao menos uma linha ativa
/*/
Function AGDA060LAT(oGrid)
    Local nX     := 0
    Local lExist := .F.

    For nX := 1 To oGrid:Length()
        oGrid:GoLine(nX)
        If !oGrid:IsDeleted() .And. !Empty(oGrid:GetValue('NEK_CODNF'))
            lExist := .T.
            Exit
        EndIf
    Next

Return lExist

/*/{Protheus.doc} AGDA060Brw
Função de carregamento de dados para campos virtuais X3_RELAÇÃO e X3_INIBRW
@type function
@version P12
@author Gilson.Venturi
@since 25/02/2025
/*/
Function AGDA060Brw()
	Local xRet 		:= nil
	Local cReadVar  := ReadVar()

	If "NEK_NOME" $ cReadVar
		IF NEK->NEK_CODMOD == '1' //Pagar
			xRet := Posicione("SA1",1,xFilial("SA1")+NEK->NEK_CODFOR+NEK->NEK_LOJA,"A1_NOME")
		else //Receber
			xRet := Posicione("SA2",1,xFilial("SA2")+NEK->NEK_CODFOR+NEK->NEK_LOJA,"A2_NOME")
		EndIf
	Endif
Return xRet

/*/{Protheus.doc} AGDA060CAL
Função para totalizar os registros selecionados
@type Function
@author Gilson.Venturi
@since 25/02/2025
@version P12
@param oModel, object, objeto do modelo de dados
@return Logical, Valor logico
/*/
Function AGDA060CAL(oModel)

	Local aLinhas		:= FWSaveRows()

	If  oModel:GetOperation() != MODEL_OPERATION_DELETE

		oModel:GetModel('AGDA060_TOTAL'):LoadValue('TOTVALPG', CalcSalCP(oModel))
		oModel:GetModel('AGDA060_TOTAL'):LoadValue('TOTVALVD', CalcSalVD(oModel))
		oModel:GetModel('AGDA060_TOTAL'):LoadValue('TOTVALDF', AGDA060DIF(oModel))
	Endif

	FWRestRows(aLinhas)

Return .T.

/*/{Protheus.doc} CalcSalCP
Calcula saldo de Notas Fiscais de Compra
@type function
P12
@author scheronlini.martins
@since 31/03/2025
@param oModel, object, objeto do modelo de dados
@return numeric, valor total de Notas Fiscais de Compra
/*/
Static Function CalcSalCP(oModel)
	Local oGridNEKCP	:= oModel:GetModel("COMPR_NEK")
	Local aLinhas		:= FWSaveRows()
	Local nX			:= 0
	Local nTotalCP		:= 0

	If  oModel:GetOperation() != MODEL_OPERATION_DELETE

		For nX := 1 To oGridNEKCP:Length()
			oGridNEKCP:GoLine(nX)
			If oModel:GetOperation() == MODEL_OPERATION_VIEW .Or. oGridNEKCP:GetValue('CHECK')
				nTotalCP += oGridNEKCP:GetValue('NEK_LIQUID',nX)
			Endif
		Next

	Endif

	FWRestRows(aLinhas)

Return nTotalCP


/*/{Protheus.doc} CalcSalVD
Calcula saldo de Notas Fiscais de Vendas
@type function
P12
@author scheronlini.martins
@since 31/03/2025
@param oModel, object, objeto modelo de dados
@return numeric, Total de Notas fiscais de Vendas
/*/
Static Function CalcSalVD(oModel)
	Local oGridNEKVD	:= oModel:GetModel("VENDA_NEK")
	Local aLinhas		:= FWSaveRows()
	Local nX			:= 0
	Local nTotalVD		:= 0

	If  oModel:GetOperation() != MODEL_OPERATION_DELETE

		For nX := 1 To oGridNEKVD:Length()
			oGridNEKVD:GoLine(nX)
			If oModel:GetOperation() == MODEL_OPERATION_VIEW .or. oGridNEKVD:GetValue('CHECK')
				nTotalVD += oGridNEKVD:GetValue('NEK_LIQUID',nX)
			Endif
		Next

	Endif

	FWRestRows(aLinhas)

Return nTotalVD

/*/{Protheus.doc} AGDA060DIF
Retorna a diferenca entre Total a Pagar e Total a Receber
@type function
@version 12
@author Gilson.Venturi
@since 25/02/2025
@param pcCodBarter, character, Codigo da Negociação - Barter
@return character, alias da consulta
/*/
Static Function AGDA060DIF(oModel)
	Local nRet := 0
	nRet = oModel:GetModel('AGDA060_TOTAL'):GetValue('TOTVALPG') - oModel:GetModel('AGDA060_TOTAL'):GetValue('TOTVALVD')
Return nRet

/*/{Protheus.doc} AGDA060GTIT
Carregar Titulos disponíveis
@type function
@version 12
@author jean.schulze
@since 03/09/2025
@param oModel, object, modelo
@return variant, retorno
/*/
Static Function AGDA060GTIT(oModel)
	Local oGridNEKCP	  := oModel:GetModel("COMPR_NEK")
	Local oGridNEKVD	  := oModel:GetModel("VENDA_NEK")
	Local cCodFechto	  := oModel:GetValue("AGDA060_NEJ", "NEJ_CODIGO")
	Local cCodBarter	  := oModel:GetValue("AGDA060_NEJ", "NEJ_CODBRT")
	Local cSeqItem		  := STRZERO(0,TAMSX3("NEK_ITEM")[1])
	Local lCriaLine		  := .F.
	Local aTitCompra      As object
	Local aTitVenda       As object
	Local nX              := 0
	Local oJsonQuery      := JsonObject():new()
	Local oTituloRepos    := Nil

	oGridNEKCP:SetNoInsertLine(.F.)
	oGridNEKVD:SetNoInsertLine(.F.)

	lCriaLine := AGDA060LAT(oGridNEKCP)

	oJsonQuery['modulo']     := '1'  //ContasAPagar
	oJsonQuery['codNegocio'] := cCodBarter
	
	oTituloRepos := TITULO_FINANCEIRO_REPOSITORY():New()
	oTituloRepos:findByTitulosFinanceiroDisponiveisFechamento(1, 999, oJsonQuery)
	if oTituloRepos:isSuccess()
		aTitCompra := oTituloRepos:getResponse()
	endif

	For nX:= 1 to Len(aTitCompra['items'])

		if lCriaLine // já passou 1
			oGridNEKCP:AddLine()
		Endif

		cSeqitem := Soma1(cSeqItem)
		cNome	:= Posicione("SA1",1,xFilial("SA1")+aTitCompra['items'][nX]['codFornecedor']+aTitCompra['items'][nX]['loja'],"A1_NOME")
		cNome	:= Padr(cNome, TamSX3("NEK_NOME")[1])
		oGridNEKCP:LoadValue("CHECK"	 , .T.)
		oGridNEKCP:LoadValue("VALID"	 , .T.)
		oGridNEKCP:LoadValue("NEK_CODFEC", cCodFechto)
		oGridNEKCP:LoadValue("NEK_ITEM"  , cSeqItem)
		oGridNEKCP:LoadValue("NEK_CODBRT", cCodBarter)
		oGridNEKCP:LoadValue("NEK_CODMOD", '1') //Compra
		oGridNEKCP:LoadValue("NEK_FILIAL", aTitCompra['items'][nX]['filial'])
		oGridNEKCP:LoadValue("NEK_CODNF",  aTitCompra['items'][nX]['codNota'])
		oGridNEKCP:LoadValue("NEK_SERNF",  aTitCompra['items'][nX]['serieNota'])
		oGridNEKCP:LoadValue("NEK_FILTIT"  , aTitCompra['items'][nX]['filialTitulo'])
		oGridNEKCP:LoadValue("NEK_TIPO"  , aTitCompra['items'][nX]['tipoTitulo'])
		oGridNEKCP:LoadValue("NEK_PREFIX", aTitCompra['items'][nX]['prefixo'])
		oGridNEKCP:LoadValue("NEK_CODTIT", aTitCompra['items'][nX]['codTitulo'])
		oGridNEKCP:LoadValue("NEK_PARCEL", aTitCompra['items'][nX]['parcela'])
		oGridNEKCP:LoadValue("NEK_CODFOR", aTitCompra['items'][nX]['codFornecedor'])
		oGridNEKCP:LoadValue("NEK_LOJA"  , aTitCompra['items'][nX]['loja'])
		oGridNEKCP:LoadValue("NEK_DTEMIS", Fw8601ToDate(aTitCompra['items'][nX]['dataEmissao']))
		oGridNEKCP:LoadValue("NEK_DTVENC", Fw8601ToDate(aTitCompra['items'][nX]['dataVencimento']))
		oGridNEKCP:LoadValue("NEK_VALOR" , IIF(aTitCompra['items'][nX]['tipoTitulo']=="NDF",aTitCompra['items'][nX]['saldo']*(-1),aTitCompra['items'][nX]['saldo']))
		oGridNEKCP:LoadValue("NEK_LIQUID", IIF(aTitCompra['items'][nX]['tipoTitulo']=="NDF",aTitCompra['items'][nX]['saldo']*(-1),aTitCompra['items'][nX]['saldo']))
		oGridNEKCP:LoadValue("NEK_NOME"  , cNome)

		lCriaLine := .T.
	Next

	lCriaLine := AGDA060LAT(oGridNEKVD)
	
	oJsonQuery['modulo']     := '2'  //ContasAReceber
	oJsonQuery['codNegocio'] := cCodBarter

	FreeObj(oTituloRepos)

	oTituloRepos := TITULO_FINANCEIRO_REPOSITORY():New()
	oTituloRepos:findByTitulosFinanceiroDisponiveisFechamento(1, 999, oJsonQuery)
	if oTituloRepos:isSuccess()
		aTitVenda := oTituloRepos:getResponse()
	endif

	For nX:= 1 to Len(aTitVenda['items'])
		if lCriaLine // já passou
			oGridNEKVD:AddLine()
		Endif

		cSeqItem := Soma1(cSeqItem)
		cNome	 := Posicione("SA1",1,xFilial("SA1")+aTitVenda['items'][nX]['codCliente']+aTitVenda['items'][nX]['loja'],"A1_NOME")
		cNome	 := Padr(cNome, TamSX3("NEK_NOME")[1])
		oGridNEKVD:LoadValue("CHECK"	 , .T.)
		oGridNEKVD:LoadValue("VALID"	 , .T.)
		oGridNEKVD:LoadValue("NEK_CODFEC", cCodFechto)
		oGridNEKVD:LoadValue("NEK_ITEM"  , cSeqItem)
		oGridNEKVD:LoadValue("NEK_CODBRT", cCodBarter)
		oGridNEKVD:LoadValue("NEK_CODMOD", '2')  // Venda
		oGridNEKVD:LoadValue("NEK_FILIAL", aTitVenda['items'][nX]['filial'])
		oGridNEKVD:LoadValue("NEK_CODNF",  aTitVenda['items'][nX]['codNota'])
		oGridNEKVD:LoadValue("NEK_SERNF",  aTitVenda['items'][nX]['serieNota'])
		oGridNEKVD:LoadValue("NEK_FILTIT", aTitVenda['items'][nX]['filialTitulo'])
		oGridNEKVD:LoadValue("NEK_TIPO"  , aTitVenda['items'][nX]['tipoTitulo'])
		oGridNEKVD:LoadValue("NEK_PREFIX", aTitVenda['items'][nX]['prefixo'])
		oGridNEKVD:LoadValue("NEK_CODTIT", aTitVenda['items'][nX]['codTitulo'])
		oGridNEKVD:LoadValue("NEK_SERTIT", aTitVenda['items'][nX]['serieTitulo'])
		oGridNEKVD:LoadValue("NEK_PARCEL", aTitVenda['items'][nX]['parcela'])
		oGridNEKVD:LoadValue("NEK_CODFOR", aTitVenda['items'][nX]['codCliente'])
		oGridNEKVD:LoadValue("NEK_LOJA"  , aTitVenda['items'][nX]['loja'])
		oGridNEKVD:LoadValue("NEK_DTEMIS", Fw8601ToDate(aTitVenda['items'][nX]['dataEmissao']))
		oGridNEKVD:LoadValue("NEK_DTVENC", Fw8601ToDate(aTitVenda['items'][nX]['dataVencimento']))
		oGridNEKVD:LoadValue("NEK_VALOR" , IIF(aTitVenda['items'][nX]['tipoTitulo']=="NCC",aTitVenda['items'][nX]['saldo']*(-1),aTitVenda['items'][nX]['saldo']))
		oGridNEKVD:LoadValue("NEK_LIQUID", IIF(aTitVenda['items'][nX]['tipoTitulo']=="NCC",aTitVenda['items'][nX]['saldo']*(-1),aTitVenda['items'][nX]['saldo']))
		oGridNEKVD:LoadValue("NEK_NOME"  , cNome)
		lCriaLine := .T.

	Next

	oGridNEKCP:SetNoInsertLine(.T.)
	oGridNEKVD:SetNoInsertLine(.T.)

	oGridNEKCP:GoLine(1)
	oGridNEKVD:GoLine(1)

	AGDA060CAL(oModel)

	FreeObj(oTituloRepos)
return nil


/*/{Protheus.doc} AGDA060PR
Função executada para carregar NF compra e venda
@type function
@version P12  
@author Gilson.Venturi
@since 25/02/2025
@param oModel, object, objeto do modelo de dados
@return Logical, Valor logico
/*/
Function AGDA060PR()
	Local lRet			  := .T.
	Local aArea			  := FWgetArea()
	Local cReadVar		  := ReadVar()
	Local oModel		  := FwModelActive()
	Local oGridNEKCP	  := oModel:GetModel("COMPR_NEK")
	Local oGridNEKVD	  := oModel:GetModel("VENDA_NEK")	
	Local cCodBarter	  := oModel:GetValue("AGDA060_NEJ", "NEJ_CODBRT")
	Local cVersaoNegocio  := ""
	Local oNegocioService := NEGOCIO_SERVICE():New()

	If "NEJ_CODBRT" $ cReadVar
		If !Empty(cCodBarter) .and. !ExistCpo("NEA",cCodBarter)
			lRet := .F. //Mensagem padrão sistema
		Else
			cVersaoNegocio  := oNegocioService:buscarVersaoAtualValida(cCodBarter)
			If !Posicione("NEA", 1, xFilial("NEA") + cCodBarter + cVersaoNegocio , "NEA_STSAUT") == '2' //1=Nao liberado / 2=Liberado
				lRet := .F.
				AGDHELP( STR0012, STR0013, STR0014 )
			Else
				oGridNEKCP:DelAllLine()
				oGridNEKVD:DelAllLine()
				oGridNEKCP:ClearData(.T. , .T. )
				oGridNEKVD:ClearData(.T. , .T. )		

				//carrega os titulos disponiveis
				If !IsInCallStack('SAVE') //repositorio fechamento financeiro
					AGDA060GTIT(oModel)
				EndIf

			EndIf
		Endif
	Endif

	FwRestArea(aArea)

Return lRet 


