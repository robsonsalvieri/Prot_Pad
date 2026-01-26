#INCLUDE "AGDA010.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE VENDA_PERDIDA_REPOSITORY agd.vendaPerdidaRepository.agdVendaPerdidaRepository
#DEFINE NEGOCIO_INSUMO_SERVICE agd.negocioInsumoService.agdNegocioInsumoService
#DEFINE NEGOCIO_SERVICE agd.negocioService.agdNegocioService
#DEFINE REPOSITORY_UTILS agd.repositoryUtils.agdRepositoryUtils
#DEFINE HISTORICO_SERVICE agd.historicoService.agdHistoricoService
#DEFINE NEGOCIO_TOTALIZADOR_SERVICE agd.negocioTotalizadorService.agdNegocioTotalizadorService

Static __lDataAlterada := .F.

/*/{Protheus.doc} AGDA010
Rotina para Cadastro de negociação de troca (Barter)
@type function
@version P12
@author claudineia.reinert
@since 12/11/2024
/*/
Function AGDA010()
	Local oMBrowse := Nil
	Local cFiltroDef := "NEA_STATUS != '6' " //6=VERSIONADO

	If .Not. TableInDic('NEA')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NEA" )
	oMBrowse:SetDescription( STR0005 ) //#"Negociação"
	oMBrowse:SetFilterDefault( cFiltroDef )
	oMBrowse:DisableDetails()
	oMBrowse:SetAttach( .T. )
	oMBrowse:Activate()

Return Nil

Static Function MenuDef()
Return AGDA10MNU()

Static Function ModelDef()
	Local oModel		:= Nil
	Local oStruNEA		:= FwFormStruct( 1, "NEA" )
	Local oStruNEB		:= FwFormStruct( 1, "NEB" )
	Local oStruNEE		:= FwFormStruct( 1, "NEE" )
	Local oStruNEN		:= FwFormStruct( 1, "NEN" )
	Local oEvent        := AGDA010EVT():New()
	Local isOptional 	:=  SUPERGETMV("MV_AGDCTCC", .F., .F.)

	oModel := MpFormModel():New( "AGDA010")
	oModel:SetDescription( STR0005 ) //##"Negociação"

	oStruNEB:RemoveField( "NEB_CODBRT" ) //Remove para setar vinculo do relacionamento da tabela
	oStruNEE:RemoveField( "NEE_CODBRT" ) //Remove para setar vinculo do relacionamento da tabela
	oStruNEN:RemoveField( "NEN_CODNEG" ) //Remove para setar vinculo do relacionamento da tabela
	oStruNEN:SetProperty('NEN_FILIAL', MODEL_FIELD_OBRIGAT, .f.) //indica que não é obrigatorio

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA010_NEA", , oStruNEA)
	oModel:GetModel( "AGDA010_NEA" ):SetDescription( STR0006 ) //#"Dados da Negociação"
	oModel:SetPrimaryKey( { "NEA_FILIAL", "NEA_CODIGO", "NEA_VERSAO" } )

	oModel:AddGrid( "AGDA010_NEB", "AGDA010_NEA", oStruNEB )
	oModel:GetModel( "AGDA010_NEB" ):SetDescription( STR0007 ) //#"Insumos para Venda"

	oModel:AddGrid( "AGDA010_NEE", "AGDA010_NEA", oStruNEE)
	oModel:GetModel( "AGDA010_NEE" ):SetDescription( STR0029 ) //#"Dados Contrato"
	
	oModel:AddGrid( "AGDA010_NEN", "AGDA010_NEA", oStruNEN )
	oModel:GetModel("AGDA010_NEN" ):SetDescription( STR0007 ) //#"Taxas"

	//Atribui um relacionamento de Pai X Filho
	oModel:SetRelation( 'AGDA010_NEB', {{'NEB_FILIAL', 'xFilial("NEB")'},{ 'NEB_CODBRT', 'NEA_CODIGO' }, { 'NEB_VERSAO', 'NEA_VERSAO' }}, NEB->(IndexKey( 1 ) ) )
	oModel:SetRelation( 'AGDA010_NEE', {{'NEE_FILIAL', 'xFilial("NEE")'},{ 'NEE_CODBRT', 'NEA_CODIGO' }, { 'NEE_VERSAO', 'NEA_VERSAO' }}, NEE->(IndexKey( 1 ) ) )
	oModel:SetRelation( 'AGDA010_NEN', {{'NEN_FILIAL', 'xFilial("NEN")'},{ 'NEN_CODNEG', 'NEA_CODIGO' }}, NEN->(IndexKey( 1 ) ) )

	oModel:GetModel("AGDA010_NEB" ):SetUniqueLine( { 'NEB_ITEM' } )
	oModel:GetModel("AGDA010_NEB" ):SetOptional( .F. )
	oModel:GetModel('AGDA010_NEB'):SetUseOldGrid(.T.)

	oModel:GetModel("AGDA010_NEE" ):SetOptional( !isOptional )
	oModel:GetModel('AGDA010_NEE'):SetUseOldGrid(.T.)

	oModel:GetModel("AGDA010_NEN"):SetOptional( .T.)
	oModel:GetModel('AGDA010_NEN'):SetUseOldGrid(.T.)

	//regra de dependencia
	oModel:AddRules( 'AGDA010_NEB', 'NEB_CLIENT', 'AGDA010_NEA', 'NEA_TABPRC', 3)
	oModel:AddRules( 'AGDA010_NEB', 'NEB_CODPRO', 'AGDA010_NEA', 'NEA_TABPRC', 3)
	oModel:AddRules( 'AGDA010_NEB', 'NEB_PRCUNI', 'AGDA010_NEB', 'NEB_CODPRO', 3)
	oModel:AddRules( 'AGDA010_NEB', 'NEB_QTDVEN', 'AGDA010_NEB', 'NEB_CODPRO', 3)

	// Cria os campos de totalizadores
	oModel:AddCalc( 'AGDA010_TOTAL', 'AGDA010_NEA', 'AGDA010_NEB', 'NEB_VALOR'   , 'TOTVALOR'  		,'FORMULA',{||.t.}/*{||fxxxx() }*/,,STR0017,{|oModel|CalcTotVen(oModel) }) //'Vlr.Total Venda'
	oModel:AddCalc( 'AGDA010_TOTAL', 'AGDA010_NEA', 'AGDA010_NEB', 'NEB_VALM2'   , 'TOTVALM2'  		,'FORMULA',{||.t.}/*{||fxxxx() }*/,,STR0053,{|oModel|CalcTotM2(oModel) })
	oModel:AddCalc( 'AGDA010_TOTAL', 'AGDA010_NEA', 'AGDA010_NEB', 'NEB_PARID'   , 'TOTPARID'  	    ,'SUM',{||.T.},,STR0018,/*{||fxxxx() }*/) 	//'Total Paridade'

	oModel:InstallEvent("AGDA010EVT", /*cOwner*/, oEvent)

Return oModel

Static Function ViewDef()
	Local oModel	:= FwLoadModel( "AGDA010" )
	Local oStruNEA  := FwFormStruct( 2, "NEA" )
	Local oStruNEB  := FwFormStruct( 2, "NEB" )
	Local oStruNEE  := FwFormStruct( 2, "NEE" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oStruNEB:RemoveField( "NEB_CODBRT" )
	oStruNEE:RemoveField( "NEE_CODBRT" )
	oStruNEB:RemoveField( "NEB_VERSAO" )
	oStruNEE:RemoveField( "NEE_VERSAO" )

	If !SUPERGETMV("MV_AGRO002", .F., .F.) //SIGAAGR - CONTRATO NOVA COMERCIALIZAÇÃO
		oStruNEE:RemoveField( "NEE_CODFIN" )
	EndIf

	oCalc := FWCalcStruct( oModel:GetModel( 'AGDA010_TOTAL') )

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NEA', oStruNEA, 'AGDA010_NEA' )

	oView:AddField( 'VIEW_CALC', oCalc , 'AGDA010_TOTAL' )

	oView:AddGrid( 'VIEW_NEB', oStruNEB, 'AGDA010_NEB' )
	oView:AddGrid( 'VIEW_NEE', oStruNEE, 'AGDA010_NEE' )

	oView:AddIncrementField( 'VIEW_NEB', 'NEB_ITEM' )
	oView:AddIncrementField( 'VIEW_NEE', 'NEE_ITEM' )

	oView:CreateHorizontalBox( 'CABEC', 45 )
	oView:CreateHorizontalBox( 'GRID', 40 )
	oView:CreateHorizontalBox( 'RODAPE', 15	)

	oView:CreateFolder( "GRADES", "GRID")
	oView:AddSheet( "GRADES", "PASTA01", STR0027) //"Insumos para Venda"
	oView:AddSheet( "GRADES", "PASTA02", STR0028) //"Dados Contrato"

	oView:CreateHorizontalBox( "PASTA_NEB", 100, , , "GRADES", "PASTA01" )
	oView:CreateHorizontalBox( "PASTA_NEE", 100, , , "GRADES", "PASTA02" )

	oView:SetOwnerView( 'VIEW_NEA', 'CABEC' )
	oView:SetOwnerView( 'VIEW_NEB', 'PASTA_NEB' )
	oView:SetOwnerView( 'VIEW_NEE', 'PASTA_NEE' )
	oView:SetOwnerView( 'VIEW_CALC','RODAPE' )

	oView:EnableTitleView("VIEW_NEA")
	oView:EnableTitleView("VIEW_NEB")
	oView:EnableTitleView("VIEW_NEE")

	oView:AddUserButton(STR0036,"",{ |oView | AGDA010MIV( oView:GetValue('AGDA010_NEB', 'NEB_ITEM', oView:GetModel('AGDA010_NEB'):GetLine())) },,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE}  )//"Venda Perdida"
	oView:AddUserButton(STR0068,"",{ |oView | fGetTaxas(oView) },,, {MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE,MODEL_OPERATION_INSERT}) //Impostos Retidos/Recolhidos

	oView:SetCloseOnOk({||.T.})

Return oView


/*/{Protheus.doc} AGD10MOEDA
Função para criar dinamicamente ComboBox de moedas para campo virtual
@type function
@version P12.1.2410
@author lindembergson.pacheco
@since 08/07/2025
@param oModel, object, objeto do modelo de dados
@param oView, object, objeto da view de dados
@return Logical, Valor logico
/*/
Function AGD10MOEDA()

	Local nX		:= 0
	Local aMoeda	:= {}
	Local cMvMoeda  := "MV_MOEDA"

	For nX := 1 To MoedFin()
		aAdd( aMoeda,  AllTrim( Str( nX ) ) +"="+ AGDMOEDesc( cMvMoeda + AllTrim( Str( nX ) ) ) )
	Next

Return CenArr2Str(aMoeda, ";")


/*/{Protheus.doc} AGDMOEDesc
Função para executar o get da moeda passada por para
@type function
@author carlos.augusto
@since 29/07/2025
@param cMoeda, character, MV_MOEDA + numero da moeda
@return character, descricao da moeda
/*/
Function AGDMOEDesc( cMoeda )
Return SuperGetMv( cMoeda, .F., "" )


/*/{Protheus.doc} AGD10VDNEA
Validação de campos da tabela NEA via dicionario de dados SX3
@type function
@version P12.1.2410
@author claudineia.reinert
@since 21/11/2024
@return Logical, Valor logico da validação, verdadeiro(.T.) ou Falso(.F.)
/*/
Function AGD10VDNEA()
	Local lRet 		:= .T.
	Local cReadVar  := ReadVar()

	Local cUmPreco  := ""
	Local oModel    := FwModelActive()
	Local oNEB		:= oModel:GetModel("AGDA010_NEB")
	Local nLinha 	:= 0
	Local nX 	    := 0
	Local oView      := FwViewActive()

	If "NEA_CODPRO" $ cReadVar .and. !Empty(M->NEA_CODPRO)
		If !ExistCpo("SB1")
			lRet := .F. //Mensagem padrão sistema
		Else
			cUmPreco  := AGDXSB5(M->NEA_CODPRO,'B5_UMPRC')
			If ExistCpo('SB1', M->NEA_CODPRO ) .AND. Empty(cUmPreco)
				AGDHELP(STR0008,STR0009,STR0010 ) //#"Ajuda","Produto não possui unidade de preço informado.","Acesse o cadastro de produtos e informe o campo referente a unidade de preço(B5_UMPRC)." )
				lRet := .F.
			EndIf
		EndIf
	ElseIf "NEA_TABPRC" $ cReadVar
		nLinha := oNEB:GetLine()
		For nX := 1 to oNEB:Length()
			oNEB:GoLine( nX )
			If !oNEB:IsDeleted() .and. !Empty(oNEB:GetValue("NEB_CODPRO"))
				lRet := .F.
				AGDHELP(STR0008,STR0011, STR0012) //##"Não é possivel alterar a tabela de preço pois existe insumos para venda vinculados.","Para alterar a tabela de preço é necessario deletar todos os registros da grid de insumos para venda." ) //#"Ajuda",
				exit
			EndIf
		Next nX
		oNEB:GoLine( nLinha )

		If lRet .and. !Empty(M->NEA_TABPRC) .and. !ExistCpo("DA0")
			lRet := .F. //Mensagem padrão sistema
		EndIf
	ElseIf "NEA_VLRRTL" $ cReadVar
		lRet := FATNEBPARID()
		If lRet
			lRet := AGDA010UPQT()
		EndIf
	ElseIf "NEA_MOEDRT" $ cReadVar
		If M->NEA_MOEDRT <= 0 .OR. M->NEA_MOEDRT > MoedFin()
			lRet := .F.
		ELSEIF  !(lRet := FNEAMOEDA())
			AGDHELP(STR0008, STRTRAN(STR0061, "*", M->NEA_MOEDA) , STRTRAN(STR0062, "*", M->NEA_MOEDA)) //#Não houve alteração de moeda, porém é necessário informar a moeda * novamente.//#Por favor informe novamente a moeda * .
		EndIf
	ElseIf "NEA_PARIDA" $ cReadVar
		If !ExistCpo("NEG")
			lRet := .F. //Mensagem padrão sistema
		ElseIf Posicione("NEG", 1 , FWxFilial("NEG") + M->NEA_PARIDA, "NEG->NEG_VENCTO") < dDataBase
			AGDHELP(STR0008, STR0037, STR0038) //#"Ajuda","Programa de Paridade vencido.",""Informe um programa de paridade válido." )
			lRet := .F.
		EndIf
	ElseIf "NEA_TPFRET" $ cReadVar
		IF  M->NEA_TPFRET == 'S'
			For nX := 1 to oNEB:Length()
				oNEB:GoLine( nX )
				If !oNEB:IsDeleted() .and. (!Empty(oNEB:GetValue("NEB_FRETE")) .or.!Empty(oNEB:GetValue("NEB_FRETM2")))
					oNEB:LoadValue("NEB_FRETE" ,0)//Utilizado load pois o campo é bloqueado para alteração
					oNEB:setValue("NEB_FRETM2" ,0)
				endif
			Next nX
			FATNEBPARID()
			oNEB:GoLine(1)
			If valType(oView) == 'O' .AND. oView:GetModel():GetId() == "AGDA010"
				oView:Refresh("VIEW_NEB")
				oView:Refresh("VIEW_NEA")
			ENDIF
		ENDIF
	elseIf 'NEA_TXMOED' $ cReadVar
		FNEBMOEDA()
	elseIf 'NEA_FORMLU' $ cReadVar
		lRet := FNEBMLUCRO()
	elseIf 'NEA_DTMOED' $ cReadVar
		lRet := FNEAMOEDA()
	endif


Return lRet

/*/{Protheus.doc} AGD10VDNEB
Validação de campos da tabela NEB via dicionario de dados SX3
@type function
@version P12.1.2410
@author claudineia.reinert
@since 26/11/2024
@return Logical, Valor .T. ou .F.
/*/
Function AGD10VDNEB()
	Local lRet 		:= .T.
	Local cReadVar  := ReadVar()
	Local nValor  	:= 0
	Local oModel    := FwModelActive()
	Local oModelNEB	:= oModel:GetModel("AGDA010_NEB")

	If "NEB_CODPRO" $ cReadVar .and. !Empty(&cReadVar)
		lRet := AGDA010VPTB()
		if lRet
			lRet := AGD10PRCST()
		endif
	ElseIf "NEB_LOCAL" $ cReadVar
		lRet := AGD10PRCST()
	ElseIf "NEB_QTDVEN" $ cReadVar
		lRet := FNEBQTDVEN()
	ElseIf "NEB_PRCUNI" $ cReadVar
		lRet := AGDA010UNEB()
		If lRet
			lRet := AGDA010UPQT()
		EndIf
	ElseIf "NEB_PDESAC" $ cReadVar
		lRet := AGDA010UNEB()
		If lRet
			lRet := AGDA010UPQT()
		EndIf
	ElseIf "NEB_VDESAC" $ cReadVar
		lRet := AGDA010UNEB()
		If lRet
			lRet := AGDA010UPQT()
		EndIf
	ElseIf "NEB_LOTCTL" $ cReadVar
		If !AGDX030(oModelNEB:GetValue('NEB_TES'))
			AGDHELP(STR0008,STR0059,STR0060)//"Ajuda","Para o preenchimento deste campo é necessário que o TES movimente estoque.","Escolha uma TES adequada ou crie uma nova no cadastro de Entrada e Saida"
			lRet := .F.
		elseIf Empty(oModelNEB:GetValue('NEB_LOCAL')) .and. ExistCpo('SB8',oModelNEB:GetValue('NEB_CODPRO')+oModelNEB:GetValue('NEB_LOTCTL'),5)
			lRet := .T.
			oModelNEB:SetValue("NEB_LOCAL", SB8->B8_LOCAL) //seta o local conforme lote
		elseIf !Empty(oModelNEB:GetValue('NEB_LOCAL')) .and. ExistCpo('SB8',oModelNEB:GetValue('NEB_CODPRO')+oModelNEB:GetValue('NEB_LOCAL')+oModelNEB:GetValue('NEB_LOTCTL'),3)
			lRet := .T.
		else
			AGDHELP(STR0008,STR0013,STR0014) //##"Lote inválido.","Informe um lote com saldo conforme produto e local de estoque informados." )
			lRet := .F.
		EndIf
	ElseIf "NEB_VALOR" $ cReadVar
		nValor := ROUND((oModelNEB:GetValue("NEB_QTDVEN") * oModelNEB:GetValue("NEB_PRCUNI")), TAMSX3("NEB_VALOR")[2])
		If oModelNEB:GetValue("NEB_VALOR") != nValor
			lRet := .F.
		EndIf
	ElseIf "NEB_FRETE" $ cReadVar
		lRet:= AGDA010UNEB()//FATNEBPARID()
	Endif

Return lRet


/*/{Protheus.doc} AGD10VDNEE
Validação de campos da tabela NEE via dicionario de dados SX3
@type function
@version P12.1.2410
@author lindembergson.pacheco
@since 24/02/2024
@return Logical, Valor .T. ou .F.
/*/
Function AGD10VDNEE()
	Local lRet 		:= .T.
	Local cReadVar  := ReadVar()
	Local nValor  	:= 0

	If "NEE_QTDSAC" $ cReadVar .and. !Empty(&cReadVar)
		lRet := FNEEQTDSAC()
	Endif

Return lRet

/*/{Protheus.doc} FNEEQTDSAC
Validação para o campo de quantidade de venda NEE_QTDSAC
Irá atualizar o valor do campo de preço da tabela de preço
@type function
@version P12.1.2410
@author lindembergson.pacheco
@since 24/02/2025
@return Logical, Valor .T. ou .F.
/*/
Static Function FNEEQTDSAC() 
	Local lRet 		:= .T.
	Local oModel    := FwModelActive()
	Local oNEE		:= nil
	Local oNEA		:= nil
	Local nLinha 	:= 0
	Local nX 		:= 0
	Local nTotParid := 0 //NEA_QTTNEG
	Local nTotal	:= 0 //Soma das linha para o campo NEE_QTDSAC
	Local nParidConv:= 0 //NEA_QTCONV
	Local nTotConv  := 0 //som das linhas para o campo NEE_QTCONV
	Local nQtdConv  := 0
	Local nRestParid:= 0
	Local cCodProd  := ""
	Local cUMPreco  := ""

	If oModel:GetId() == "AGDA010"
		oNEE		:= oModel:GetModel("AGDA010_NEE")
		oNEA		:= oModel:GetModel("AGDA010_NEA")
		nTotParid   := oNEA:GetValue("NEA_QTTNEG")
		cCodProd    := oNEA:GetValue("NEA_CODPRO")
    	cUMPreco    := oNEA:GetValue("NEA_UMPRC")
		cUMProd     := POSICIONE( "SB1", 1, xFilial("SB1") + cCodProd, "B1_UM" )
		nParidConv  := oNEA:GetValue("NEA_QTCONV")
		nTotal      := oNEE:GetValue("NEE_QTDSAC")	// inicia com o valor da linha
		nQtdConv := AGD010ConvUM(cCodProd, cUMPreco, oNEE:GetValue("NEE_QTDSAC"))
		nLinha := oNEE:GetLine()
		For nX := 1 to oNEE:Length()
			oNEE:GoLine( nX )
			If !oNEE:IsDeleted() .and. nLinha <> nX
				nTotal   += oNEE:GetValue("NEE_QTDSAC")
				nTotConv += oNEE:GetValue("NEE_QTCONV")
			EndIf
		Next nX
		oNEE:GoLine(nLinha)

		If nTotal <= nTotParid			
		//Caso a Qtd preenchida no NEE_QTDSAC complete o saldo da Qtd Negociada
		If nTotal == nTotParid
			nRestParid := nParidConv - nTotConv
			//completa o valor se esta diferente da UM do Produto do barter
			If nQtdConv <> nRestParid
				nQtdConv := nRestParid
			EndIf
		EndIf
		oNEE:loadValue("NEE_QTCONV", nQtdConv)
	EndIf	

	ElseIf oModel:GetId() == "AGDA011"
		oNEE := oModel:GetModel("AGDA011_NEE")
		oNegocioService := NEGOCIO_SERVICE():New()
		oNegocioService:buscarPorId(oNEE:GetValue("NEE_CODBRT"),oNEE:GetValue("NEE_VERSAO"))
		nTotParid := oNegocioService:getResponse()['quantidadenegociada']
		IF oModel:GetOperation() == MODEL_OPERATION_INSERT
			nTotal := oNegocioService:getTotalParidadeNEE(oNEE:GetValue("NEE_CODBRT"),oNEE:GetValue("NEE_VERSAO")) + oNEE:GetValue("NEE_QTDSAC")
		Else
			nTotal := oNegocioService:getTotalParidadeNEE(oNEE:GetValue("NEE_CODBRT"),oNEE:GetValue("NEE_VERSAO")) - (NEE->NEE_QTDSAC - oNEE:GetValue("NEE_QTDSAC"))
		EndIf
	EndIf	

	If nTotal > nTotParid
		lRet := .F.
		AGDHELP(STR0008,STR0046 +; //#"A soma das quantidades em sacas a entregar informado por propriedade é maior do que a quantidade total negociada da commodity, favor verificar!"
		CRLF + CRLF + STR0047 + Alltrim(TRANSFORM(nTotal, "@E 999,999.99" )) +; //#"Total Quantidade por propriedade lançada : "+
		CRLF + CRLF + STR0048 + Alltrim(TRANSFORM(nTotParid, "@E 999,999.99")) ) //#"Total Negociado : "
	ENDIF

Return lRet


/*/{Protheus.doc} AGD10CPFPRO
Filtro da consulta padrão(SXB) NEBSB1 - filtra os dados para o campo produto NEB_CODPRO 
@type function
@version P12.1.2410
@author claudineia.reinert
@since 21/11/2024
@return character, filtro SQL com as condições para retorno
/*/
Function AGD10CPFPRO()  //REF MAT311SB1
	Local cQry	:=	""
	Local oModel    := FwModelActive()
	Local oModelNEA	:= oModel:GetModel("AGDA010_NEA")

	cQry  += "@D_E_L_E_T_ = ' ' "
	cQry  += 	" AND ( "
	cQry  += 		" B1_COD IN ( SELECT DA1_CODPRO FROM "+ retSqlName('DA1') +" DA1"
	cQry  += 			" INNER JOIN "+ retSqlName('DA0')+" DA0 ON DA0_FILIAL = DA1_FILIAL AND  DA0.D_E_L_E_T_ = ' ' AND DA0_CODTAB = DA1_CODTAB AND DA0_ATIVO = '1' AND (DA0_DATATE = ' ' OR DA0_DATATE >= '"+DTOS(DDATABASE)+"')  "
	cQry  += 			" WHERE DA1.D_E_L_E_T_ = ' ' AND DA1_ATIVO = '1' AND DA1_DATVIG <= '"+DTOS(DDATABASE)+"'  "
	cQry  += 			" AND DA1_CODTAB = '"+oModelNEA:GetValue("NEA_TABPRC")+"' AND DA1_FILIAL = '"+FwxFilial("DA1",FWxFilial("SB1"))+"' "
	IF oModelNEA:GetValue("NEA_MOEDRT") == 1
		cQry  += 			" AND DA1_MOEDA = '"+ALLTRIM(STR(oModelNEA:GetValue("NEA_MOEDRT")))+"' ) "
	ELSE
		cQry  += 			" AND DA1_MOEDA IN ('1', '"+ALLTRIM(STR(oModelNEA:GetValue("NEA_MOEDRT")))+"' ) ) "
	ENDIF
	cQry  += 		" OR ( "
	cQry  += 			" B1_GRUPO <> '' AND  B1_GRUPO IN ( SELECT DA1_GRUPO FROM "+ retSqlName('DA1') +" DA1"
	cQry  += 				" INNER JOIN "+ retSqlName('DA0')+" DA0 ON DA0_FILIAL = DA1_FILIAL AND  DA0.D_E_L_E_T_ = ' ' AND DA0_CODTAB = DA1_CODTAB AND DA0_ATIVO = '1' AND (DA0_DATATE = ' ' OR DA0_DATATE >= '"+DTOS(DDATABASE)+"')  "
	cQry  += 				" WHERE DA1.D_E_L_E_T_ = ' ' AND DA1_ATIVO = '1' AND DA1_DATVIG <= '"+DTOS(DDATABASE)+"'  "
	cQry  += 				" AND DA1_CODTAB = '"+oModelNEA:GetValue("NEA_TABPRC")+"' AND DA1_FILIAL = '"+FwxFilial("DA1",FWxFilial("SB1"))+"' "
	IF oModelNEA:GetValue("NEA_MOEDRT") == 1
		cQry  += 			" AND DA1_MOEDA = '"+ALLTRIM(STR(oModelNEA:GetValue("NEA_MOEDRT")))+"' ) "
	ELSE
		cQry  += 			" AND DA1_MOEDA IN ('1', '"+ALLTRIM(STR(oModelNEA:GetValue("NEA_MOEDRT")))+"' ) ) "
	ENDIF
	cQry  += 		" )"
	cQry  += 	" )"
Return cQry


/*/{Protheus.doc} AGD10NEBVP
Inicio Padrão Informando a quantidade de Venda Perdida
@type function
@version 12
@author jean.schulze
@since 07/02/2025
@param pcCodBrt, variant, Codigo Do Negocio
@param pcInsumo, variant, Codigo Do Insumo
@return variant, valor total
/*/
Function AGD10NEBVP(pcCodBrt, pcInsumo)
	Local nTotal := 0
	Local oRepository := nil

	oRepository := VENDA_PERDIDA_REPOSITORY():New()

	nTotal := oRepository:sumByNegocioInsumo(pcCodBrt, pcInsumo)

	oRepository:DeActivate()

	FreeObj(oRepository)
Return nTotal

/*/{Protheus.doc} AGDA010VPTB
Validação para o valor do campo de produto NEB_CODPRO
@type function
@version P12.1.2410
@author claudineia.reinert
@since 26/11/2024
@return Logical, Valor .T. ou .F.
/*/
Function AGDA010VPTB()
	Local lRet := .T.
	Local cAliPrcTab:= GetNextAlias()
	Local oModel    := FwModelActive()
	Local oModelNEB	:= oModel:GetModel("AGDA010_NEB")
	Local oNEA		:= oModel:GetModel("AGDA010_NEA")

	IF oNEA:GetValue("NEA_MOEDRT") != 1

		IF Empty(DTOS((oNEA:GetValue("NEA_DTMOED"))))
			lRet := .F.
			AGDHELP(STR0008, STR0055, STR0056)
			Return lRet
		ENDIF

		IF (oNEA:GetValue("NEA_TXMOED") == 0)
			lRet := .F.
			AGDHELP(STR0008, STR0057, STR0058)
			Return lRet
		ENDIF
	ENDIF

	AGDA010QYTP(@cAliPrcTab)
	If (cAliPrcTab)->(!Eof())
		oModelNEB:SetValue("NEB_PRCTAB", (cAliPrcTab)->(DA1_PRCVEN))
		oModelNEB:SetValue("NEB_PRCUNI",(cAliPrcTab)->(DA1_PRCVEN))
		oModelNEB:SetValue("NEB_QTDVEN", 0)
		oModelNEB:SetValue("NEB_VDESAC", 0)
		oModelNEB:SetValue("NEB_PDESAC", 0)
	Else
		AGDHELP(STR0008, STR0015, STR0016) //###"Produto informado não existe ou esta inativo na tabela de preço informada.","Informe um produto que esteja cadastrado na tabela de preço informada e esteja ativo." )
		lRet := .F.
	EndIf
	(cAliPrcTab)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} FNEBQTDVEN
Validação para o campo de quantidade de venda NEB_QTDVEN
Irá atualizar o valor do campo de preço da tabela de preço
@type function
@version P12.1.2410
@author claudineia.reinert
@since 26/11/2024
@return Logical, Valor .T. ou .F.
/*/
Static Function FNEBQTDVEN()
	Local lRet := .T.
	Local cAliPrcTab:= GetNextAlias()
	Local oModel    := FwModelActive()
	Local oModelNEB	:= oModel:GetModel("AGDA010_NEB")
	Local oModelNEA	:= oModel:GetModel("AGDA010_NEA")
	Local oNegocioInsumoServive := nil
	Local nQtdAlocada := 0

	If oModelNEB:GetValue("NEB_QTDVEN") > 0
		oNegocioInsumoServive := NEGOCIO_INSUMO_SERVICE():New(oModelNEA:GetValue("NEA_CODIGO"), oModelNEB:GetValue("NEB_VERSAO"), oModelNEB:GetValue("NEB_ITEM"))
		nQtdAlocada := oNegocioInsumoServive:getQtdAlocada()
		If 	nQtdAlocada > 0 .AND. oModelNEB:GetValue("NEB_QTDVEN") < nQtdAlocada
			AGDHELP("NEB_QTDVEN",STR0044,STR0045+cValToChar(nQtdAlocada)) //#"Quantidade informada não pode ser menor que a quantidade alocada." #"Informe uma quantidade maior ou igual a "
			Return .F.
		EndIf
		AGDA010QYTP(@cAliPrcTab)
		If (cAliPrcTab)->(!Eof()) //atualiza tabela de preço conforme qtd pois pode ter faixa
			oModelNEB:SetValue("NEB_PRCTAB", (cAliPrcTab)->(DA1_PRCVEN))
		EndIf
		(cAliPrcTab)->(dbCloseArea())
		lRet := AGDA010UNEB()
		AGDA010UPQT()
	Else
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} AGDA010UPQT
Função para atualização do campo de quantidade da negociação da commodity - NEA_QTTNEG
@type function
@version P12.1.2410
@author claudineia.reinert
@since 28/11/2024
@param nLinDel, numeric, numero da linha deletada para não considerar, uso qdo via validação de modelo
@return Logical, Valor .T. ou .F.
/*/
Function AGDA010UPQT(nLinDel)
	Local lRet 		:= .T.
	Local nQtd 		:= 0
	Local oModel    := FwModelActive()
	Local oModelNEA	:= oModel:GetModel("AGDA010_NEA")

	Local oJsonDados as Json
	Local oNegocioService := nil
	Local oNegocioTotalizadorService := nil
	Local aLinhas		:= FWSaveRows()
	Local cCodProduto   := ""
	Local cUMPreco      := ""
	Local nQtdConv      := 0
	Default nLinDel := 0

	oNegocioService := NEGOCIO_SERVICE():New()
	oJsonDados := oNegocioService:getJSONFromModel(oModel, nLinDel)
	oNegocioTotalizadorService := NEGOCIO_TOTALIZADOR_SERVICE():New(oJsonDados)
	nQtd := oNegocioTotalizadorService:getTotalParidade()
	FreeObj(oNegocioService)
	FreeObj(oNegocioTotalizadorService)

    cCodProduto := oModelNEA:GetValue("NEA_CODPRO")
	cUMPreco    := oModelNEA:GetValue("NEA_UMPRC")

	If nQtd > 0
		nQtdConv := AGD010ConvUM(cCodProduto, cUMPreco, nQtd)
	EndIf

	oModelNEA:loadValue("NEA_QTTNEG", nQtd)
	oModelNEA:loadValue("NEA_QTCONV", nQtdConv)
	FWRestRows(aLinhas)

Return lRet

/*/{Protheus.doc} AGDA010QYTP
Query da tabela de preço conforme tabela, produto e quantidade
@type function
@version P12.1.2410
@author claudineia.reinert
@since 26/11/2024
@param cAliQry, character, Alias da tabela para gerar a consulta
@return Character, string com o nome do alias da tabela gerada pela consulta
/*/
Function AGDA010QYTP(cAliQry)
	Local cQuery	:= ""
	Local oModel    := FwModelActive()
	Local oModelNEA	:= oModel:GetModel("AGDA010_NEA")
	Local oModelNEB	:= oModel:GetModel("AGDA010_NEB")
	Local oStatement	:= nil

	//QUERY seguindo padrão filtro consulta do campo NEB_CODPRO
	cQuery := " SELECT DA1_PRCVEN "
	cQuery += " FROM "+ RetSQLName("SB1") +" SB1 "
	cQuery += " INNER JOIN "+ RetSQLName("DA1") +" DA1 "
	cQuery += "     ON DA1_FILIAL = ? "
	cQuery += "        AND DA1_CODTAB = ? "
	cQuery += "        AND DA1_QTDLOT >= ? "
	cQuery += "        AND DA1.D_E_L_E_T_ = ' ' "
	cQuery += "        AND ( "
	cQuery += "                ( "
	cQuery += "                    DA1_CODPRO <> ' ' "
	cQuery += "                    AND DA1_CODPRO = B1_COD "
	cQuery += "                )
	cQuery += "                OR ( "
	cQuery += "                       DA1_CODPRO = ' ' "
	cQuery += "                       AND DA1_GRUPO <> ' ' "
	cQuery += "                       AND DA1_GRUPO = B1_GRUPO "
	cQuery += "                   ) "
	cQuery += "            ) "
	cQuery += " INNER JOIN "+ RetSQLName("DA0") +" DA0 "
	cQuery += "     ON DA0_FILIAL = DA1_FILIAL "
	cQuery += "        AND DA0.D_E_L_E_T_ = ' ' "
	cQuery += "        AND DA0_CODTAB = DA1_CODTAB "
	cQuery += "        AND DA0_ATIVO = '1' "
	cQuery += "        AND ( "
	cQuery += "                DA0_DATATE = ' ' "
	cQuery += "                OR DA0_DATATE >= ? "
	cQuery += "            ) "
	cQuery += " WHERE B1_FILIAL = ? "
	cQuery += "   AND SB1.B1_COD = ? "
	cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "   AND B1_MSBLQL = '2' "

	cQuery := ChangeQuery( cQuery )

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	oStatement:SetString( 	1, FWxFilial('DA1'))
	oStatement:SetString( 	2, oModelNEA:GetValue("NEA_TABPRC"))
	oStatement:setNumeric( 	3, STR(oModelNEB:GetValue("NEB_QTDVEN")))
	oStatement:setDate( 	4, DDATABASE)
	oStatement:SetString( 	5, FWxFilial("SB1"))
	oStatement:SetString( 	6, oModelNEB:GetValue("NEB_CODPRO"))
	cQuery := oStatement:GetFixQuery()
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliQry,.T.,.T.)

Return cAliQry

/*/{Protheus.doc} AGDA010UNEB
Atualiza valores de alguns campos na tabela/grid NEB
@type function
@version P12.1.2410 
@author claudineia.reinert
@since 26/11/2024
@param cReadVar, character, campo que disparou a ação
@return Logical, Valor .T.
/*/
Function AGDA010UNEB(cReadVar)
	Local oModel    := FwModelActive()
	Local oModelNEB	:= oModel:GetModel("AGDA010_NEB")
	Local oModelNEA	:= oModel:GetModel("AGDA010_NEA")

	Local nPrcTab := oModelNEB:GetValue("NEB_PRCTAB")
	Local nPrcUni := oModelNEB:GetValue("NEB_PRCUNI")
	Local nPerDes := oModelNEB:GetValue("NEB_PDESAC")
	Local nValDes := oModelNEB:GetValue("NEB_VDESAC")
	Local nQtdVenda := oModelNEB:GetValue("NEB_QTDVEN")

	Local nPCusto 	:= oModelNEB:GetValue("NEB_PRCCUS")
	Local nFrete 	:= oModelNEB:GetValue("NEB_FRETE")
	Local nTotal	:= 0
	Local nPCustoM2 := 0
	Local nPrcTabM2 := 0
	Local nPrcUniM2 := 0
	Local nPerDesM2 := 0
	Local nValDesM2 := 0
	Local nTotalM2	:= 0
	Local nProdMoed	:= 0
	Local nFreteM2 	:= 0

	Default cReadVar  := ReadVar()

	IF !Empty(oModelNEA:GetValue("NEA_TABPRC"))
		nProdMoed	:= Posicione("DA1", 2 , FWxFilial("DA1") + oModelNEB:GetValue("NEB_CODPRO") + oModelNEA:GetValue("NEA_TABPRC"), "DA1_MOEDA")
		IF nProdMoed != 1
			//mantendo integridade de preco de tabela
			nPrcTab 	:= Posicione("DA1", 2 , FWxFilial("DA1") + oModelNEB:GetValue("NEB_CODPRO") + oModelNEA:GetValue("NEA_TABPRC"), "DA1_PRCVEN")

			nPCusto 	:= xMoeda(nPCusto,nProdMoed,1,,5,oModelNEA:GetValue("NEA_TXMOED"), )
			nPrcTab 	:= xMoeda(nPrcTab,nProdMoed,1,,5,oModelNEA:GetValue("NEA_TXMOED"), )
			nPrcUni 	:= nPrcTab

			oModelNEB:SetValue("NEB_PRCTAB" , ROUND(nPrcTab, TAMSX3("NEB_PRCTAB")[2]))
			oModelNEB:SetValue("NEB_PRCUNI" , ROUND(nPrcUni, TAMSX3("NEB_PRCUNI")[2]))
		ENDIF
	ENDIF

	//calcula os valores
	If "NEB_VDESAC" $ cReadVar
		nPrcUni := ( nPrcTab + nValDes)
	EndIf
	If "NEB_PDESAC" $ cReadVar
		nPrcUni := ( nPrcTab + (nPrcTab * (nPerDes / 100)) )
	EndIf

	If !("NEB_PDESAC" $ cReadVar)
		nPerDes := ((( nPrcUni / nPrcTab ) * 100) - 100)
	EndIf
	If !("NEB_VDESAC" $ cReadVar )
		nValDes := ( nPrcUni - nPrcTab )
	EndIf

	nTotal := nQtdVenda * nPrcUni

	//##############################################################################################
	///carrega valores nos campos, usando loadValue para não passar pela validação novamente
	If !("NEB_PRCUNI" $ cReadVar)
		oModelNEB:LoadValue("NEB_PRCUNI", ROUND(nPrcUni, TAMSX3("NEB_PRCUNI")[2]))
	EndIf
	If !("NEB_VDESAC" $ cReadVar)
		oModelNEB:LoadValue("NEB_VDESAC", ROUND(nValDes, TAMSX3("NEB_VDESAC")[2]))
	EndIf
	If !("NEB_PDESAC" $ cReadVar)
		oModelNEB:LoadValue("NEB_PDESAC", ROUND(nPerDes, TAMSX3("NEB_PDESAC")[2]))
	EndIf

	oModelNEB:SetValue("NEB_VALOR" , ROUND(nTotal, TAMSX3("NEB_VALOR")[2]))

	if oModelNEA:GetValue("NEA_MOEDRT") != 1
		nPCustoM2 	:= xMoeda(nPCusto		,1,oModelNEA:GetValue("NEA_MOEDRT"),,5,, oModelNEA:GetValue("NEA_TXMOED"))
		nPrcTabM2 	:= xMoeda(nPrcTab		,1,oModelNEA:GetValue("NEA_MOEDRT"),,5,, oModelNEA:GetValue("NEA_TXMOED"))
		nPrcUniM2 	:= xMoeda(nPrcUni		,1,oModelNEA:GetValue("NEA_MOEDRT"),,5,, oModelNEA:GetValue("NEA_TXMOED"))
		nTotalM2	:= xMoeda(nTotal		,1,oModelNEA:GetValue("NEA_MOEDRT"),,5,, oModelNEA:GetValue("NEA_TXMOED"))
		nPerDesM2 	:= xMoeda(nPerDes		,1,oModelNEA:GetValue("NEA_MOEDRT"),,5,, oModelNEA:GetValue("NEA_TXMOED"))
		nValDesM2 	:= xMoeda(nValDes		,1,oModelNEA:GetValue("NEA_MOEDRT"),,5,, oModelNEA:GetValue("NEA_TXMOED"))
		nFreteM2 	:= xMoeda(nFrete		,1,oModelNEA:GetValue("NEA_MOEDRT"),,5,, oModelNEA:GetValue("NEA_TXMOED"))
	endif

	oModelNEB:SetValue("NEB_PCUSM2" , ROUND(nPCustoM2, TAMSX3("NEB_PCUSM2")[2]))
	oModelNEB:SetValue("NEB_PTABM2" , ROUND(nPrcTabM2, TAMSX3("NEB_PTABM2")[2]))
	oModelNEB:SetValue("NEB_PUNIM2" , ROUND(nPrcUniM2, TAMSX3("NEB_PUNIM2")[2]))
	oModelNEB:SetValue("NEB_VALM2" 	, ROUND(nTotalM2 , TAMSX3("NEB_VALM2")[2]))
	oModelNEB:SetValue("NEB_PDAM2" 	, ROUND(nPerDesM2, TAMSX3("NEB_PDAM2")[2]))
	oModelNEB:SetValue("NEB_VDAM2" 	, ROUND(nValDesM2, TAMSX3("NEB_VDAM2")[2]))
	oModelNEB:SetValue("NEB_FRETM2" , ROUND(nFreteM2 , TAMSX3("NEB_FRETM2")[2]))

	FATNEBPARID()

Return .T.

/*/{Protheus.doc} FATNEBPARID
Atualiza todos os campos de paridade da grid NEB
@type function
@version P12
@author claudineia.reinert
@since 26/11/2024
@return Logical, Valor .T. 
/*/
Static Function FATNEBPARID()
	Local oModel    := FwModelActive()
	Local oNEA		:= oModel:GetModel("AGDA010_NEA")
	Local oNEB		:= oModel:GetModel("AGDA010_NEB")
	Local nLinha 	:= 0
	Local nX 	:= 0
	Local nVlrParid	:= 0

	nLinha := oNEB:GetLine()
	For nX := 1 to oNEB:Length()
		oNEB:GoLine( nX )
		If !oNEB:IsDeleted() .and. oNEB:GetValue("NEB_VALOR") > 0
			if oNEA:GetValue("NEA_MOEDRT") != 1
				nVlrParid := CALCPARID( oNEB:GetValue("NEB_FRETM2"),oNEB:GetValue("NEB_VALM2"),oNEA:GetValue("NEA_VLRRTL"))
			ELSE
				nVlrParid := CALCPARID(oNEB:GetValue("NEB_FRETE"),oNEB:GetValue("NEB_VALOR"),oNEA:GetValue("NEA_VLRRTL"))
			ENDIF
			oNEB:SetValue("NEB_PARID" , ROUND(nVlrParid, TAMSX3("NEB_PARID")[2]))
		EndIf
	Next nX
	oNEB:GoLine( nLinha )
	AGDA010UPQT()
	FNEBMLUCRO()

Return .T.

/*/{Protheus.doc} AGD10VSNGC
Retorna versao da negociação valida/ativa. 
Função chamada via fonte ou dicionario(valid, consultas)
@type function
@version P12
@author claudineia.reinert
@since 03/03/2025
@param cCodNegocio, character, Código da Negociação
@return Character, versão da negociação
/*/
Function AGD10VSNGC(cCodNegocio)
	Local cVersao := ""
	Local aAreaNEA := NEA->(GetArea())
	Local aAreaAtu := GetArea()
	Local oNegocioService := NEGOCIO_SERVICE():New()

	cVersao := oNegocioService:buscarVersaoAtualValida(cCodNegocio)

	RestArea(aAreaNEA)
	RestArea(aAreaAtu)
Return cVersao

/*/{Protheus.doc} AGD10NNIPRO
Filtro da consulta padrão(SXB) NNINEE - filtra os dados para o campo produto NEA_CODPRO 
@type function
@version P12.1.2410
@author rodrigo.nsoledade
@since 13/03/2025
@return character, filtro SQL com as condições para retorno
/*/
Function AGD10NNIPRO(cCodProd)
	Local cQry	:=	""
	Local oModel	:=	FwModelActive()
	Default cCodProd := ""

	If ValType(oModel) == "O" .and. oModel:GetId() == "AGDA010"
		cCodProd := oModel:GetModel("AGDA010_NEA"):GetValue("NEA_CODPRO")
	EndIf

	// Construção do filtro, garantindo a conexão com NNI_CODIGO
	cQry += "@ D_E_L_E_T_ = ' ' "
	cQry += " AND NNI_FILIAL = '" + FWxFilial("NNI") + "' "
	cQry += " AND (NNI_CODPRO = '" + cCodProd + "' OR NNI_CODPRO = ' ') "

Return cQry

/*/{Protheus.doc} AGD10VALNNI
Valida se o código informado no campo NEE_TABELA está dentro do filtro do SXB NNINEE.
@type function
@version P12.1.2410
@author rodrigo.nsoledade
@since 18/03/2025
@return logical, retorno .T. ou .F.
/*/
Function AGD10VALNNI()
	Local oModel     := FwModelActive()
	Local cCodTabela := AllTrim(FwFldGet("NEE_TABELA")) // Código digitado pelo usuário
	Local cCodProd   := " " // Código do produto no negocio
	Local cFiltroSQL := ""  // Resgata o filtro do SXB
	Local cQuery     := ""
	Local lRet       := .T.
	Local oNegServ   := Nil

	If oModel:GetId() == "AGDA010"
		cCodProd := FwFldGet("NEA_CODPRO")
	ElseIf oModel:GetId() == "AGDA011"       //servico vincularContratoNEE
		oNegServ := NEGOCIO_SERVICE():New()
		oNegServ:buscarPorId(FwFldGet("NEE_CODBRT"), FwFldGet("NEE_VERSAO"))
		cCodProd := oNegServ:getResponse()['codigoproduto']
		FreeObj(oNegServ)
	EndIf

	cFiltroSQL := AGD10NNIPRO(cCodProd)
	cFiltroSQL := StrTran(cFiltroSQL, "@", "") // Remove o '@' do filtro SXB

	// Caso o campo esteja vazio, não precisa validar
	If Empty(cCodTabela)
		Return .T.
	EndIf

	// Monta a query para verificar se o código informado pelo usuário está dentro do filtro do SXB
	cQuery := " SELECT COUNT(NNI_CODIGO) AS REG "
	cQuery += " FROM " + RetSQLName("NNI") + " (NOLOCK) "
	cQuery += " WHERE "
	cQuery += " ? "
	cQuery += " AND NNI_CODIGO = ? "
	cQuery := ChangeQuery( cQuery )

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	oStatement:setUnsafe( 1, cFiltroSQL)
	oStatement:SetString( 2, cCodTabela)
	cQuery := oStatement:GetFixQuery()

	// Executa a query e armazena o resultado na variável
	nRegNNI := MPSysExecScalar(cQuery,"REG")

	// Se não encontrou registros, exibe mensagem e impede a inserção
	If nRegNNI == 0
		AGDHELP(STR0008, STR0049) //"Ajuda"#"Tabela não cadastrada para esse produto."
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} AGD10STREC
Retorna o status de recebimento para campo virtual NEE_STSREC - DESCONTINUADO
@type function
@version P12
@author rodrigo.nsoledade
@since 25/03/2025
@return Character, "1","2","3"
/*/
Function AGD10STREC(cCodBarter,cCodVersao,lTexto)
	Local cStatus := ""
Return cStatus

/*/{Protheus.doc} AGD10TESINT
Sugere TES utilizando a função MaTesInt() e preenche automaticamente na grid
@type function
@version P12
@author rodrigo.nsoledade
@since 31/03/2025
@return Character, retornando TES
*/
Function AGD10TESIN()
	Local oModel    := FwModelActive()
	Local oModelNEB	:= oModel:GetModel("AGDA010_NEB")
	Local oModelNEE	:= oModel:GetModel("AGDA010_NEE")
	Local nLineMdl  := 0
	Local cTES      := ""
	Local cReadVar  := ReadVar() 
	
	If "NEB_OPER" $ cReadVar

		nLineMdl := oModelNEB:GetLine()
		// Chamada da função de TES Inteligente
		cTES := MaTesInt(2,, M->NEA_CODCLI, M->NEA_LOJCLI, "C", M->NEB_CODPRO, "NEB_TES")

		// Se a TES foi encontrada, atualiza na grid
		If !Empty(cTES)
			oModelNEB:LoadValue("NEB_TES", cTES )
		EndIf

		oModelNEB:GoLine(nLineMdl)

	ElseIf "NEE_OPEFIS" $ cReadVar

		nLineMdl := oModelNEE:GetLine()
		// Chamada da função de TES Inteligente
		cTES := MaTesInt(1,ALLTRIM(M->NEE_OPEFIS),M->NEA_CODCLI,M->NEA_LOJCLI, "F", M->NEA_CODPRO, "NEE_TESCTR")

		// Se a TES foi encontrada, atualiza na grid
		If !Empty(cTES)
			oModelNEE:LoadValue("NEE_TESCTR", cTES )
		EndIf
		oModelNEE:GoLine(nLineMdl)
	EndIf

Return cTES

/*/{Protheus.doc} AGD10STEXP
Retornar o status de expedição da negociação - DESCONTINUADO
@type method
@version  P12
@author Gilson.Venturi
@since 31/03/2025
@param cCodNegocio, character, Código da Negociação
@param cCodVersao,  character, versão da Negociação
@param lTexto,  logical, converter para texto
@return character, return cStatus
/*/
Function AGD10STEXP(cCodBarter,cCodVersao,lTexto)
	Local cStatus := ""
return cStatus


/*/{Protheus.doc} CalcTotVen
Calcula o Total de Vendas
@type function
@version P12
@author scheronlini.martins
@since 11/04/2025
@param oModel, object, oModel
@return numeric, return_Total de Vendas
/*/
Static Function CalcTotVen(oModel)
	Local oJsonDados as Json
	Local oNegocioService := nil
	Local oNegocioTotalizadorService := nil
	Local nTotal := 0

	If  oModel:GetOperation() != MODEL_OPERATION_DELETE
		oNegocioService := NEGOCIO_SERVICE():New()
		oJsonDados := oNegocioService:getJSONFromModel(oModel)
		oNegocioTotalizadorService := NEGOCIO_TOTALIZADOR_SERVICE():New(oJsonDados)

		nTotal := oNegocioTotalizadorService:getTotalVenda()

		FreeObj(oNegocioService)
		FreeObj(oNegocioTotalizadorService)
	Endif

Return nTotal


/*/{Protheus.doc} CalcTotM2
Calcula o Total de Vendas para outras Moeads
@type function
@version P12
@author lindembergson.pacheco
@since 15/04/2025
@param oModel, object, oModel
@return numeric, return_Total de Vendas
/*/
Static Function CalcTotM2(oModel)
	Local oJsonDados as Json
	Local oNegocioService := nil
	Local oNegocioTotalizadorService := nil
	Local nTotal := 0

	If  oModel:GetOperation() != MODEL_OPERATION_DELETE
		oNegocioService := NEGOCIO_SERVICE():New()
		oJsonDados := oNegocioService:getJSONFromModel(oModel)
		oNegocioTotalizadorService := NEGOCIO_TOTALIZADOR_SERVICE():New(oJsonDados)
		nTotal := oNegocioTotalizadorService:getTotalVendaOMoeda()
		FreeObj(oNegocioService)
		FreeObj(oNegocioTotalizadorService)
	Endif

Return nTotal

/*/{Protheus.doc} FNEAMOEDA
Preenche dados de moeda
@type function
@version P12
@author lindembergson.pacheco
@since 31/03/2025
@return Logical, .T. or .F.
*/
Function FNEAMOEDA()
    Local oModel    := FwModelActive()
    Local oNEA      := oModel:GetModel("AGDA010_NEA")
    Local oNEB      := oModel:GetModel("AGDA010_NEB")
    Local nLineNBE  := oNEB:GetLine()
    Local nTxMoeda  := 0
    Local lRet      := .T.

    oNEB:GoLine(nLineNBE)

    // --- Quando a MOEDA RT é alterada ---
    If oNEA:IsFieldUpdated("NEA_MOEDRT")
        If !Empty(oNEB:GetValue("NEB_CODPRO"))
            If FWAlertYesNo(STR0054, "") // #Deseja seguir com a mudança de moeda da negociação?
                oNEB:DelAllLine()
                oNEB:ClearData()
                oNEA:LoadValue("NEA_MOEDA", AllTrim(Str(oNEA:GetValue("NEA_MOEDRT"))))
            Else
				M->NEA_MOEDRT := VAL(ALLTRIM(oNEA:GetValue("NEA_MOEDA")))
                oNEA:LoadValue("NEA_MOEDRT", Val(oNEA:GetValue("NEA_MOEDA")))
                lRet := .F.
            EndIf
        Else
            If oNEA:GetValue("NEA_MOEDRT") != Val(oNEA:GetValue("NEA_MOEDA"))
                oNEA:LoadValue("NEA_MOEDA", AllTrim(Str(oNEA:GetValue("NEA_MOEDRT"))))
            EndIf
        EndIf

        If oNEA:GetValue("NEA_MOEDRT") != 1
            // Preenche data base apenas se o usuário NÃO alterou a data manualmente
            If Empty(oNEA:GetValue("NEA_DTMOED")) .And. !__lDataAlterada
                oNEA:SetValue("NEA_DTMOED", dDataBase)
            EndIf

            If !Empty(oNEA:GetValue("NEA_DTMOED"))
                nTxMoeda := RecMoeda(oNEA:GetValue("NEA_DTMOED"), oNEA:GetValue("NEA_MOEDRT"))
                oNEA:SetValue("NEA_TXMOED", nTxMoeda)
            Else
                oNEA:SetValue("NEA_TXMOED", 0)
            EndIf
        EndIf
    EndIf

    // --- Quando a DATA de cotação é alterada ---
    If oNEA:IsFieldUpdated("NEA_DTMOED")
        __lDataAlterada := .T.  // Marca que o usuário alterou a data

        If oNEA:GetValue("NEA_MOEDRT") != 1
            If Empty(oNEA:GetValue("NEA_DTMOED"))
                oNEA:SetValue("NEA_TXMOED", 0)  // Zera cotação
            Else
                nTxMoeda := RecMoeda(oNEA:GetValue("NEA_DTMOED"), oNEA:GetValue("NEA_MOEDRT"))
                oNEA:SetValue("NEA_TXMOED", nTxMoeda)
            EndIf
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} FNEBMOEDA
Atualiza todos os campos de valores de moeda estrangeira da grid NEB
@type function
@version P12
@author lindembergson.pacheco
@since 06/07/2025
@return Logical, Valor .T. 
/*/
Function FNEBMOEDA()
	Local oModel    := FwModelActive()
	Local oNEB		:= oModel:GetModel("AGDA010_NEB")
	Local oView		:= FwViewActive()
	Local nLinha 	:= 0
	Local nX 		:= 0

	nLinha := oNEB:GetLine()
	For nX := 1 to oNEB:Length()
		oNEB:GoLine( nX )
		If !oNEB:IsDeleted() .and. oNEB:GetValue("NEB_VALOR") > 0
			AGDA010UNEB()
		EndIf
	Next nX
	oNEB:GoLine(1)
	
	If ValType(oView) == "O" .AND. oView:oModel:getId() == "AGDA010"
        oView:Refresh("AGDA010_NEB")
    EndIf


Return .T.


/*/{Protheus.doc} AGD10PRCST
Atualiza Preço de Custo da Negociação
@type method
@version  P12
@author Gilson.Venturi
@since 05/05/2025
@return Logical, Valor .T.
/*/
Function AGD10PRCST()
	Local oModel			:= FwModelActive()
	Local oModelNEA			:= oModel:GetModel("AGDA010_NEA")
	Local oModelNEB			:= oModel:GetModel("AGDA010_NEB")
	Local nLineNEB			:= oModelNEB:GetLine()
	Local oNegocioService	:= NEGOCIO_SERVICE():New()
	Local nPrCusto			:= Nil

	nPrCusto := oNegocioService:getPrecoCustoProdut(oModelNEB:GetValue('NEB_CODPRO'), oModelNEB:GetValue('NEB_LOCAL'))

	oModelNEB:LoadValue("NEB_PRCCUS" , ROUND(nPrCusto[1], TAMSX3("NEB_PRCCUS")[2]))

	if oModelNEA:GetValue("NEA_MOEDRT") != 1
		oModelNEB:LoadValue("NEB_PCUSM2" , ROUND(nPrCusto[oModelNEA:GetValue("NEA_MOEDRT")], TAMSX3("NEB_PRCCUS")[2]))
	endif

	oModelNEB:GoLine(nLineNEB)

	FNEBMLUCRO()

return .T.


/*/{Protheus.doc} FNEBMLUCRO
Calcula Margem de Lucro
@type function
@version P12
@author lindembergson.pacheco
@since 05/105/2025
@return Logical, Valor .T. 
/*/
Function FNEBMLUCRO()
	Local oModel := FwModelActive()
	Local oNEA := oModel:GetModel("AGDA010_NEA")
	Local oJsonDados as Json
	Local oNegocioService := nil
	Local oNegocioTotalizadorService := nil
	Local lRet := .T.

	oNegocioService := NEGOCIO_SERVICE():New()
	oJsonDados := oNegocioService:getJSONFromModel(oModel)
	oNegocioTotalizadorService := NEGOCIO_TOTALIZADOR_SERVICE():New(oJsonDados)
	oNEA:SetValue("NEA_MRGLUC", ROUND( oNegocioTotalizadorService:getMargemLucro() , TAMSX3("NEA_MRGLUC")[2]))

	if !Empty(oNegocioTotalizadorService:getMessageError())
		AGDHELP(STR0008, STR0064, oNegocioTotalizadorService:getMessageError()) // 8-Ajuda.  64-Fórmula inválida
		lRet := .F.
	EndIf

	FreeObj(oNegocioService)
	FreeObj(oNegocioTotalizadorService)

Return lRet

/*/{Protheus.doc} fTaxas
Função responsavel por instanciar o modelo AGDA010T (Consulta de Impostos Recolhidos/Retidos da Negociação)
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
@param oView, object, View
/*/
Static Function fGetTaxas(oView)
	Local aArea      := FwGetArea()
	Local oModel     := oView:getModel()
	Local nOperation := 0
	Local oGridNEE   := oModel:GetModel("AGDA010_NEE")
	Local oGridNEN   := oModel:GetModel("AGDA010_NEN")	
	Local nLinNEE    := oGridNEE:GetLine()
	Local nX         := 0
	Local cCodNeg    := ""
	Local cCodCli    := ""
	Local cLojCli    := ""
	Local cMoedRT    := ""
	Local nTxMoeda   := 0
	Local cCodPro    := ""
	Local nVlrRT     := 0
	Local cTes       := criaVar("NEE_TESCTR")
	Local cNaturez   := criaVar("NEE_NATURE")
	Local cCGC       := ""
	Local aTaxes     := {}
	LOcal nY         := 0
	Local cFldSkip   := "NEN_FILIAL|NEN_CODNEG"
	
	if oModel:getOperation() == MODEL_OPERATION_INSERT .Or. oModel:getOperation() == MODEL_OPERATION_UPDATE
		nOperation := MODEL_OPERATION_INSERT
	else
		nOperation := MODEL_OPERATION_VIEW
	endif

	cCodNeg  := oModel:GetValue("AGDA010_NEA", "NEA_CODIGO")
	cCodCli  := oModel:GetValue("AGDA010_NEA", "NEA_CODCLI")
	cLojCli  := oModel:GetValue("AGDA010_NEA", "NEA_LOJCLI")
	cMoedRT  := oModel:GetValue("AGDA010_NEA", "NEA_MOEDRT")
	nTxMoeda := oModel:GetValue("AGDA010_NEA", "NEA_TXMOED")
	cCodPro  := oModel:GetValue("AGDA010_NEA", "NEA_CODPRO")
	nVlrRT   := oModel:GetValue("AGDA010_NEA", "NEA_VLRRT")

	For nX := 1 to oGridNEE:Length()
		oGridNEE:GoLine(nX)
		If !oGridNEE:IsDeleted()
			if !empty(oGridNEE:GetValue("NEE_TESCTR", nX))
				cTes := oGridNEE:GetValue("NEE_TESCTR", nX)
			endIf

			if !empty(oGridNEE:GetValue("NEE_NATURE"))
				cNaturez := oGridNEE:GetValue("NEE_NATURE", nX)
			endIf

			exit
		EndIf
	Next nX

	if Empty(cNaturez)
		cCGC := Posicione("SA1", 1, FWxFilial("SA1") + cCodCli + cLojCli, "SA1->A1_CGC")

		dbSelectArea("SA2")
		SA2->(dbSetOrder(retOrdem("SA2", "A2_FILIAL+A2_CGC")))
		if SA2->(dbSeek(FwxFilial("SA2") + cCGC));
				.And. !empty(SA2->A2_NATUREZ)
			cNaturez := SA2->A2_NATUREZ
		endif
	endif

	oGridNEE:GoLine(nLinNEE)

	aTaxes := AGDA010T(nOperation, {}, cCodNeg, cMoedRT, nTxMoeda, cCodPro, nVlrRT, cTes, cNaturez)
	//todo:verificar como aplicar e ajustar quando for para limpar
	if nOperation == MODEL_OPERATION_INSERT .ANd. !empty(aTaxes) .And. aTaxes[3] > 0

		oModel:getModel("AGDA010_NEA"):setValue("NEA_IMPOST", aTaxes[3])

		oGridNEN:DelAllLine()

		//equaliza para updates e insert
		if oGridNEN:Length(.T.) < 1
			oGridNEN:AddLine()
		endif

		For nX := 1 to Len(aTaxes[2/*aAcols*/])
			if nX != 1
				oGridNEN:AddLine()
			endif
			For nY := 1 to Len(aTaxes[1/*aHeader*/])
				if ! aTaxes[1, nY, 2] $ cFldSkip
					oGridNEN:SetValue(aTaxes[1, nY, 2], aTaxes[2, nX, nY])
				endif
			Next nY
		Next nX
	endif

	FWrestArea(aArea)
return


/*/{Protheus.doc} AGDA010TRG
Limpa os campos NEE_TABELA e NEE_DESTAB da grid Contratos
Funcao utilizada no gatilho do campo NEA_CODPRO
@type function
@version 12
@author jc.maldonado
@since 04/06/2025
/*/
Function AGDA010TRG()
	Local oModel   := nil
	Local nX       := 0
	Local oView	   := nil
	Local oGridNEE := nil
	Local nLine    := 0

	If (oModel := FwModelActive()) != Nil;
			.AND. ValType(oModel) == "O";
			.AND. oModel:GetId() == "AGDA010"

		oGridNEE := oModel:GetModel("AGDA010_NEE")

		nLine := oGridNEE:GetLine()

		For nX := 1 To oGridNEE:Length()
			oGridNEE:GoLine(nX)

			If oGridNEE:IsDeleted()
				oGridNEE:LoadValue("NEE_TABELA", criaVar("NEE_TABELA"))
				oGridNEE:LoadValue("NEE_DESTAB", criaVar("NEE_DESTAB"))
			Else
				oGridNEE:SetValue("NEE_TABELA", criaVar("NEE_TABELA"))
			EndIf
		Next nX

		oGridNEE:GoLine(nLine)

		If (oView := FwViewActive()) != Nil;
				.AND. ValType(oView) == "O";
				.AND. oView:oModel:getId() == "AGDA010"
			oView:Refresh("VIEW_NEE")
		EndIf
	EndIf
Return

/*/{Protheus.doc} AGD10VERS
Função não permite alteração quando negociação encontra-se versionada.
@type function
@version P12 
@author scheronlini.martins
@since 09/06/2025
@return variant, return_lRet
/*/
Function AGD10VERS()
	Local lRet 		:= .T.
	Local oNegocioService	:= nil
	Local cReadVar := ReadVar()
	Local oModel   := FwModelActive()
	Local oNEA   := oModel:GetModel("AGDA010_NEA")

	If !(cReadVar $ "NEA_QTTNEG|NEA_DTVALI|NEA_OBS") .AND. !INCLUI
		oNegocioService := NEGOCIO_SERVICE():New()
		If oNEA:GetValue("NEA_STSAUT") == "1" .AND. oNegocioService:validarSeTemVersionamento(oNEA:GetValue("NEA_CODIGO"))
			lRet := .F.
		EndIF
	EndIf

Return lRet

/*/{Protheus.doc} CALCPARID
Calculo da Paridade
@type function
@version P12 
@author scheronlini.martins
@since 30/06/2025
@param nFrete, numeric, valor do frete
@param nVlrInsumo, numeric, Valor do insumo
@param nVlrCommodity, numeric, valor da Commodity
@return variant, valor da paridade
/*/
Function CALCPARID(nFrete,nVlrInsumo,nVlrCommodity)
	Local nParidade

	nParidade := (nFrete + nVlrInsumo) / nVlrCommodity

return nParidade

/*/{Protheus.doc} AGDConvQtdUMPreco
Converte a quantidade negociada para a UM de preço do negócio (NEA_UMPRC),
aplicando a regra de arredondamento do MV_AGD0003.
@type function
@version 12
@author rodrigo.nsoledade
@since 15/08/2025
@param cCodProduto, character, código do produto (SB1)
@param cUMPreco, character, UM de preço do negócio (NEA_UMPRC)
@param nQtd, numeric, quantidade base (paridade) calculada
@return numeric, quantidade convertida e arredondada
/*/
Static Function AGD010ConvUM(cCodProduto, cUMPreco, nQtd)
    Local aAreaSB1 := SB1->(GetArea())
    Local nQtdConv := nQtd
    Local cUMProd  := ""

    Default cCodProduto := ""
    Default cUMPreco    := ""
    Default nQtd        := 0

    If nQtd <= 0 .Or. Empty(cCodProduto) .Or. Empty(cUMPreco)
        Return nQtdConv
    EndIf

    dbSelectArea("SB1")
    SB1->(dbSetOrder(1))
    If SB1->(dbSeek(xFilial("SB1") + cCodProduto))
        cUMProd := SB1->B1_UM
        // Somente converte se UM do produto for diferente da UM de preço
        If !Empty(cUMProd) .And. cUMProd != cUMPreco
			nQtdConv := AGRX001(cUMPreco, cUMProd, nQtd, cCodProduto)
        EndIf
    EndIf

    // Aplica a regra de arredondamento (MV_AGD0003)
    nQtdConv := AGD010Round(nQtdConv)

    RestArea(aAreaSB1)

Return nQtdConv

/*/{Protheus.doc} Agd010Round
Aplica arredondamento configurado no parâmetro MV_AGD0003
@type function
@version 12
@author rodrigo.nsoledade
@since 19/08/2025
@param nValor, numeric, valor a ser arredondado
@return numeric, valor após arredondamento
/*/
Static Function AGD010Round(nValor)
    Local cTpRound := SUPERGETMV("MV_AGD0003", .F., '4') // Default = 4 (Aritmético)
    Local nRet     := nValor

    Do Case
        // 1 - Não arredonda (mantém casas decimais)
        Case cTpRound == '1'
            nRet := nValor

        // 2 - Arredonda para cima (sempre joga para cima se tiver decimal)
        Case cTpRound == '2'
            nRet := Int(nValor)
            If nRet < nValor
                nRet++
            EndIf

        // 3 - Arredonda para baixo (descarta decimal)
        Case cTpRound == '3'
            nRet := Int(nValor)

        // 4 - Aritmético (default) - 0..4 para baixo, 5..9 para cima
        Otherwise
            nRet := Round(nValor, 0)
    EndCase

Return nRet

