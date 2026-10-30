#Include "TOTVS.CH"
#Include "FWBROWSE.CH"
#Include "FWMVCDEF.CH"
#Include "COMNF3ADIC.CH"

Static _lVisual := .T. 					as logical
Static _oJsDesc := JsonObject():New() 	as object //Objeto para cache de descrições dos produtos.

//-------------------------------------------------------------------
/*/{Protheus.doc} COMNF3ADIC
	Apresenta os dados adicionais que devem ser inseridos, para uma Nota Fiscal de Eletricidade - NF3E.
	Será possível adicionar valores negativos e positivos, bem como produtos sem unidade de medida.
	@type function
	@author renan.martins
	@since 05/2026
	@version 1.0
/*/
//-------------------------------------------------------------------
Function COMNF3ADIC()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Model da tela
	@type static
	@author renan.martins
	@since 05/2026
	@version 1.0
	@return oModel, object, objeto do modelo de dados MVC (MPFormModel)
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStrCab 	:= CABMODEL() 	as object
	Local cCampos 	:= "DKO_ITEM|DKO_COD|DKO_UM|DKO_QUANT|DKO_VUNIT|DKO_TOTAL|DKO_EMISSA" as character
	Local oStrIte 	:= Nil 			as object
	Local oModel  	:= Nil 			as object
	Local xAux		:= {}			as array
	Private aNfSped := {"", "", ""} as array //O campo DKO_UMED chama essa variável, que não existe no contexto aqui, Assim, é necessário passá-la vazia, para nçao ocorre erro.

	oStrIte := FWFormStruct(1, 'DKO', { |x| AllTrim(x) $ cCampos } )
	_oJsDesc := JsonObject():New() //Objeto para cache de descrições dos produtos.

	oStrIte:AddField(STR0001,;									// 	[01]  C   Titulo do campo  - "Descrição"
					 STR0001,;									// 	[02]  C   ToolTip do campo - "Descrição"
					 "DESC",;								// 	[03]  C   Id do Field
					 "C",;										// 	[04]  C   Tipo do campo
					 TamSX3("B1_DESC")[1],;					// 	[05]  N   Tamanho do campo
					 0,;										// 	[06]  N   Decimal do campo
					 NIL,;										//	[07]  B   Code-block de validação do campo
					 NIL,;										// 	[08]  B   Code-block de validação When do campo
					 NIL,;										//	[09]  A   Lista de valores permitido do campo
					 .F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL,;						//	[11]  B   Code-block de inicializacao do campo
					 .F.,;										//	[12]  L   Indica se trata-se de um campo chave
					 .F.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.)										// 	[14]  L   Indica se o campo é virtual	
	
	oModel := MPFormModel():New('COMNF3ADIC',/*bPreVld*/, /*{|oModel| PosValid(oModel)}*/, {|oModel| NF3Commit(oModel)}) 

	oModel:SetDescription(STR0007) //Dados adicionais da NF de Energia

	oModel:AddFields( 'CABMASTER', , oStrCab,,,)
	oModel:GetModel( 'CABMASTER' ):SetDescription(STR0002)//Dados cabeçalho

	oModel:AddGrid( 'ITENSDETAIL', 'CABMASTER', oStrIte)
	oModel:GetModel( 'ITENSDETAIL' ):SetDescription(STR0003) //"Dados Itens"
	
	//Campos de cálculo, para somar os valores positivos e negativos, e apresentar um total
	oModel:AddCalc( 'CALC', 'CABMASTER', 'ITENSDETAIL', 'DKO_TOTAL', 'VLNEGATIVO', 'SUM', { |oModel| oModel:getModel("ITENSDETAIL"):getvalue("DKO_TOTAL") < 0 } , , STR0004) //Débito
	oModel:AddCalc( 'CALC', 'CABMASTER', 'ITENSDETAIL', 'DKO_TOTAL', 'VLPOSITIVO', 'SUM', { |oModel| oModel:getModel("ITENSDETAIL"):getvalue("DKO_TOTAL") >= 0} , , STR0005) //Crédito
	oModel:AddCalc( 'CALC', 'CABMASTER', 'ITENSDETAIL', 'DKO_TOTAL', 'VLTOTAL'	 , 'SUM', { ||.T.} , , STR0006) //Total 

	oModel:SetPrimaryKey({'DOC', 'SERIE','FORNECLI','LOJA', 'DKO_ITEM', 'DKO_COD'})

	//Definição de propriedades dos campos
	oStrIte:SetProperty( "DKO_COD"	, MODEL_FIELD_OBRIGAT, .T. )
	oStrIte:SetProperty( "DKO_TOTAL", MODEL_FIELD_OBRIGAT, .T. )
	oStrIte:SetProperty( "DKO_QUANT", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "POSITIVO()") )
		
	//gatilhos
	xAux := FwStruTrigger( 'DKO_VUNIT', 'DKO_TOTAL', 'NF3CalcIt()',.F.)
	oStrIte:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger( 'DKO_QUANT', 'DKO_TOTAL', 'NF3CalcIt()',.F.)
	oStrIte:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger ('DKO_COD', 'DKO_UM', "SB1->B1_UM", .T., "SB1", 1, 'xFilial("SB1") + FwFldGet("DKO_COD")' )
	oStrIte:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	xAux := FwStruTrigger ('DKO_COD', 'DESC', "SB1->B1_DESC", .T., "SB1", 1, 'xFilial("SB1") + FwFldGet("DKO_COD")' )
	oStrIte:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	
	//Carregar conforme demanda, para evitar lentidão na abertura da tela, caso haja muitos itens.
	oModel:SetOnDemand(.t.)
	oModel:GetModel('ITENSDETAIL'):SetOptional(.T.)

	oModel:SetVldActivate( {|| .T. } )
	oModel:SetActivate( { |oModel| NF3GetData( oModel ) } )

	FwFreeArray(xAux)
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
	Menu Funcional da Rotina 
	@type static
	@author renan.martins
	@since 05/2026
	@version 1.0
	@return aRotina, array, array de opcoes do menu funcional
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   
	Local aRotina := {} as array

	ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.COMNF3ADIC' OPERATION 3 ACCESS 0 //-- Incluir
Return(aRotina) 


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Interface com usuário
	@type static
	@author renan.martins
	@since 05/2026
	@version 1.0
	@return oView, object, objeto da view MVC (FWFormView)
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   	:= FWLoadModel("COMNF3ADIC") 	as object
	Local oView    	:= FWFormView():New() 			as object
	Local oStrCab  	:= CABVIEW() 					as object
	Local cCampos 	:= "DKO_ITEM|DKO_COD|DKO_UM|DKO_QUANT|DKO_VUNIT|DKO_TOTAL|DKO_EMISSA" 	as character
	Local oStrIte  	:= FWFormStruct(2, 'DKO', {|cCampo| AllTrim(cCampo) $ cCampos })		as object
	Local oCalc		:= Nil							as object

	oStrIte:AddField( ;									// Ord. Tipo Desc.
						"DESC",;						// [01] C Nome do Campo
						"01",;							// [02] C Ordem
						STR0001,;						// [03] C Titulo do campo 	 //"Descrição"
						STR0001,;						// [04] C Descrição do campo //"Descrição"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						PesqPict("SB1", "B1_DESC"),;	// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"",;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

	oStrCab:SetProperty("*"			, MVC_VIEW_CANCHANGE, .F.)
	oStrIte:SetProperty("DKO_ITEM"	, MVC_VIEW_CANCHANGE, .F.)

	oView:SetModel(oModel)
	oView:AddField('VIEW_CAB', oStrCab, 'CABMASTER')

	//View dos cálculos
	oCalc  := FWCalcStruct( oModel:GetModel( 'CALC') )
	oView:AddField( 'VIEW_CALC', oCalc , 'CALC' )

	oView:CreateHorizontalBox( 'SUPERIOR'   , 020 )   
	oView:CreateHorizontalBox( 'INFERIOR'   , 065 )
	oView:CreateHorizontalBox( 'RODAPE'   	, 015 )

	oView:AddGrid( 'VIEW_ITENS', oStrIte, 'ITENSDETAIL' )
	oView:SetOwnerView( 'VIEW_ITENS', 'INFERIOR')
	oView:EnableTitleView('VIEW_ITENS','Itens'	)

	oView:SetOwnerView( 'VIEW_CAB'	, 'SUPERIOR')
	oView:SetOwnerView( 'VIEW_CALC', 'RODAPE' )
	oView:EnableTitleView( "VIEW_CALC" )

	oStrIte:SetProperty('DKO_ITEM'	, MVC_VIEW_ORDEM	, '01')
	oStrIte:SetProperty('DKO_COD'	, MVC_VIEW_ORDEM	, '02')
	oStrIte:SetProperty('DESC'		, MVC_VIEW_ORDEM	, '03')
	oStrIte:SetProperty('DKO_UM'	, MVC_VIEW_ORDEM	, '04')
	oStrIte:SetProperty('DKO_QUANT'	, MVC_VIEW_ORDEM	, '05')
	oStrIte:SetProperty('DKO_VUNIT'	, MVC_VIEW_ORDEM	, '06')
	oStrIte:SetProperty('DKO_TOTAL'	, MVC_VIEW_ORDEM	, '07')
	oStrIte:SetProperty('DKO_EMISSA', MVC_VIEW_ORDEM	, '08')
	oStrIte:SetProperty('DKO_EMISSA', MVC_VIEW_TITULO	, STR0009) //Competência
	oStrIte:SetProperty('DKO_UM'	, MVC_VIEW_TITULO	, STR0010) //Unidade de Medida
	oStrIte:SetProperty('DKO_COD'	, MVC_VIEW_LOOKUP	, 'SB1')
	oView:AddIncrementField('VIEW_ITENS', 'DKO_ITEM' )

	oView:showInsertMsg(.F.) // -- Desativa a mensagem registro inserido.
	oView:SetViewAction('ASKONCANCELSHOW', {|oView| .F.}) // -- Desativa mensagem de "há alterações não salvas"

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} CABMODEL
	Monta Campos do modelo de dados.
	@type static
	@author renan.martins
	@since 05/2026
	@version 1.0
	@return oStructMn, object, estrutura do modelo de dados do cabecalho (FWFormModelStruct)
/*/
//-------------------------------------------------------------------
static function CABMODEL()
	Local oStructMn	:= FWFormModelStruct():New() 	as object
	Local aTamSX3	:= {} 							as array
	Local cTitle    := "" 							as character

	aTamSX3	:= TamSX3("DKO_FORNEC")
	cTitle := GetSX3Cache('DKO_FORNEC', 'X3_TITULO')
	oStructMn:AddField(cTitle, cTitle, 'FORNECLI', 'C', aTamSX3[1]  , aTamSX3[2]  ,  , {|| .T.}, {}, .F., , .F., .T., .T.) 

	aTamSX3	:= TamSX3("DKO_LOJA")
	cTitle := GetSX3Cache('DKO_LOJA', 'X3_TITULO')
	oStructMn:AddField(cTitle, cTitle, 'LOJA', 'C', aTamSX3[1]  , aTamSX3[2]  ,  , {|| .T.}, {}, .F., , .F., .T., .T.)

	aTamSX3	:= TamSX3("DKO_DOC")
	cTitle := GetSX3Cache('DKO_DOC', 'X3_TITULO')
	oStructMn:AddField(cTitle , cTitle , 'DOC'  , 'C', aTamSX3[1]    , aTamSX3[2]    ,  , {|| .T.}, {}, .F., , .F., .T., .T.) 

	aTamSX3	:= TamSX3("DKO_SERIE")
	cTitle := GetSX3Cache('DKO_SERIE', 'X3_TITULO')
	oStructMn:AddField(cTitle , cTitle , 'SERIE' , 'C', aTamSX3[1], aTamSX3[2],  , {|| .T.}, {}, .F., , .F., .T., .T.)

	FwFreeArray(aTamSX3)
return oStructMn


//-------------------------------------------------------------------
/*/{Protheus.doc} CABVIEW
	Monta campos da view.
	@type static
	@author renan.martins
	@since 05/2026
	@version 1.0
	@return oStructMn, object, estrutura da view do cabecalho (FWFormViewStruct)
/*/
//-------------------------------------------------------------------
static function CABVIEW()
	Local oStructMn	:= FWFormViewStruct():New() as object
	Local cTitle    := ""						as character

	cTitle := GetSX3Cache("DKO_FORNEC", 'X3_TITULO')
	oStructMn:AddField('FORNECLI', '01', cTitle, cTitle,, 'C' , PesqPict("SF1", "F1_FORNECE") , , , .T., , , , , , .T., , ) 

	cTitle := GetSX3Cache('DKO_LOJA', 'X3_TITULO')
	oStructMn:AddField('LOJA'  , '02', cTitle , cTitle ,, 'C' , PesqPict("SF1","F1_LOJA"    ) , , , .T., , , , , , .T., , )

	cTitle := GetSX3Cache('DKO_DOC', 'X3_TITULO')
	oStructMn:AddField('DOC'  , '03', cTitle , cTitle ,, 'C' , PesqPict("SF1","F1_DOC"    ) , , , .T., , , , , , .T., , )

	cTitle := GetSX3Cache('DKO_SERIE', 'X3_TITULO')
	oStructMn:AddField('SERIE' , '04', cTitle , cTitle ,, 'C' , PesqPict("SF1","F1_SERIE"   ) , , , .T., , , , , , .T., , )
return oStructMn


//--------------------------------------------------------------------
/*/{Protheus.doc} NF3GetData()
	Realiza a carga de dados de acordo com a operação
	@type static
	@author renan.martins
	@since 05/2026

	@param oModel, object, objeto do modelo de dados da tela, para setar os valores nos campos.
	@return Nil
	@obs Depende de variaveis Private externas: oJsDKOInf, cNFiscal, cSerie, cA100for, cLoja, cEspecie
/*/
//--------------------------------------------------------------------
Static Function NF3GetData(oModel as object)
	Local oMdlCab  	:= nil				as object
	Local oMdlItens	:= nil				as object
	Local aDados  	:= {}				as array
	Local lBlocked	:= .F. 				as logical
	Local nSize		:= 0				as numeric
	Local lLoadJson	:= (oJsDKOInf != nil .and. type("oJsDKOInf") == "J") .and. oJsDKOInf:hasproperty('itens') .and. (len(oJsDKOInf['itens']) > 0) as logical 
	Local aRetFun	:= {}				as array
	Default oModel  := FwModelActive()

	oMdlCab 	:= oModel:GetModel('CABMASTER')
	oMdlItens 	:= oModel:GetModel('ITENSDETAIL')		

	//Indica que os itens estão na "memória" ou salvos na base.
	if (lLoadJson)
		aDados := oJsDKOInf["itens"]
	else 
		aRetFun := NF3QryDKO(cNFiscal, cSerie, cA100for, cLoja, cEspecie)
		if (aRetFun[1]) //Verifica se há DKO
			aDados := aRetFun[2]['itens']
		endif
	endif

	nSize := len(aDados)
	oMdlCab:GetStruct():SetProperty("*"	, MVC_VIEW_CANCHANGE, .T.)
	if (lLoadJson)
		oMdlCab:SetValue('FORNECLI'	, oJsDKOInf['supplier'])
		oMdlCab:SetValue('LOJA'		, oJsDKOInf['store'])
		oMdlCab:SetValue('DOC'		, oJsDKOInf['document'])
		oMdlCab:SetValue('SERIE'	, oJsDKOInf['serie'])		
	else
		oMdlCab:LoadValue('FORNECLI', Alltrim(cA100For))
		oMdlCab:LoadValue('LOJA'	, Alltrim(cLoja))
		oMdlCab:LoadValue('DOC'		, Alltrim(cNFiscal))
		oMdlCab:LoadValue('SERIE'	, Alltrim(cSerie))
	endif
	lBlocked := _lVisual
	oMdlCab:GetStruct():SetProperty("*"	, MVC_VIEW_CANCHANGE, .F.)

	if ( nSize > 0 )
		oMdlItens:GetStruct():SetProperty("DKO_ITEM"	, MVC_VIEW_CANCHANGE, .T.)
		NF3CentModel(@oMdlItens, aDados, .F.)
		oMdlItens:GetStruct():SetProperty("DKO_ITEM"	, MVC_VIEW_CANCHANGE, .F.)
	endif

	if (lBlocked) //visualização apenas, sem possibilidade de alteração
		oModel:GetModel("ITENSDETAIL"):GetStruct():SetProperty('*', MODEL_FIELD_WHEN,{||.f.})
		oMdlItens:SetNoInsertLine(.T.)	
	endif
	//Caso sejam eliminados com FwFreeArray o elemento pai (oJsDKOInf) será limpo e perde os dados em tela.
	aDados  := {}
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} NF3Commit
	Função de commit do modelo
	@type static
	@author renan.martins
	@since 06/2026
	@version 1.0

	@param oModel, object, objeto do modelo de dados da tela, para obter os valores dos campos.
	@return lRetFun, logical, indicando se o commit foi realizado com sucesso ou nao.
/*/
//-------------------------------------------------------------------
Static Function NF3Commit(oModel as object)
	Local oMdlCab  		:= nil					as object
	Local oMdlIte  		:= nil					as object
	Local aItemVinc 	:= {}					as array
	Local nFor 	   		:= 0					as numeric
	Local lRetFun		:= .T. 					as logical
	Local cEspecNF		:= Alltrim(cEspecie) 	as character
	Local lExsJson		:= (oJsDKOInf != nil .and. type("oJsDKOInf") == "J") .and. oJsDKOInf:hasproperty('bkp_totals') as logical
	Local nBkpTotals	:= 0					as numeric
	Default oModel  	:= FwModelActive()

	if (lExsJson)
		nBkpTotals := oJsDKOInf['bkp_totals']
	endif

	oJsDKOInf := NIL
	oJsDKOInf := JsonObject():New()

	oMdlCab  := oModel:GetModel("CABMASTER")
	oMdlIte  := oModel:GetModel("ITENSDETAIL")

	oJsDKOInf['document'] 	:= oMdlCab:GetValue("DOC")
	oJsDKOInf['serie'] 		:= oMdlCab:GetValue("SERIE")
	oJsDKOInf['supplier'] 	:= oMdlCab:GetValue("FORNECLI")
	oJsDKOInf['store'] 		:= oMdlCab:GetValue("LOJA")

	For nFor := 1 to oMdlIte:Length()
		oMdlIte:GoLine(nFor)

		if (!oMdlIte:IsDeleted() .and. !empty(oMdlIte:GetValue('DKO_COD')))

			NF3CentObjJs(@aItemVinc, oMdlCab:GetValue("DOC"), oMdlCab:GetValue("SERIE"), oMdlCab:GetValue("FORNECLI"), oMdlCab:GetValue("LOJA"), cEspecNF,;
			 	oMdlIte:GetValue('DKO_ITEM'), oMdlIte:GetValue('DKO_COD'), oMdlIte:GetValue('DKO_UM'), oMdlIte:GetValue('DKO_QUANT'), oMdlIte:GetValue('DKO_VUNIT'),;
				oMdlIte:GetValue('DKO_TOTAL'), oMdlIte:GetValue('DKO_EMISSA'), 0, oMdlIte:GetValue('DESC') )

		endif

	Next nFor

	//Coloca os itens e valor total no JSON, para consulta
	oJsDKOInf['totals'] 	:= oModel:GetModel("CALC"):getValue("VLTOTAL")
	oJsDKOInf['itens'] 		:= aClone(aItemVinc)
	oJsDKOInf['bkp_totals']	:= nBkpTotals

	FwFreeArray(aItemVinc)
	FwFreeObj(_oJsDesc)
    
return lRetFun


//-------------------------------------------------------------------
/*/{Protheus.doc} NF3QryDKO
	Função que consulta os registros na tabela DKO, e retorna em formato de JSON.
	@type function
	@author renan.martins
	@since 05/2026
	@version 1.0

	@param cNumDoc, character, numero do documento
	@param cNumSerie, character, serie do documento
	@param cCodFor, character, codigo do fornecedor
	@param cCodLoja, character, codigo da loja
	@param cEspDoc, character, especie do documento
	@return array, contendo um boolean indicando se ha registros e um objeto JSON com os dados dos itens
/*/
//-------------------------------------------------------------------
function NF3QryDKO(cNumDoc as character, cNumSerie as character, cCodFor as character, cCodLoja as character, cEspDoc as character)
	Local cAliasTmp 	:= ""	as character
	Local cQuery		:= ""	as character
	Local oObjQry		:= Nil	as object
	Local oRetDKO		:= Nil	as object
	Local aItemVinc		:= {}	as array
	Local lHasDKO		:= .F. 	as logical
	Local nSumTotal		:= 0 	as numeric
	Default cNumDoc 	:= ""
	Default cNumSerie 	:= ""
	Default cCodFor 	:= ""
	Default cCodLoja 	:= ""
	Default cEspDoc 	:= ""

	cQuery := " SELECT DKO_ITEM, DKO_COD, DKO_UM, DKO_QUANT, DKO_VUNIT, DKO_TOTAL, DKO_EMISSA, R_E_C_N_O_ REC "
	cQuery += " FROM " + RetSqlName("DKO") + " DKO "
	cQuery += " WHERE DKO_FILIAL = ? "
	cQuery += " AND DKO_DOC = ? "
	cQuery += " AND DKO_SERIE = ? "
	cQuery += " AND DKO_FORNEC = ? "
	cQuery += " AND DKO_LOJA = ? "
	cQuery += " AND DKO_ESPECI = ? "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY DKO_ITEM "

	oObjQry := FwExecStatement():New(ChangeQuery(cQuery))

	oObjQry:SetString(1, FWxFilial("DKO"))
	oObjQry:SetString(2, cNumDoc)
	oObjQry:SetString(3, cNumSerie)
	oObjQry:SetString(4, cCodFor)
	oObjQry:SetString(5, cCodLoja)
	oObjQry:SetString(6, cEspDoc)

	cAliasTmp := oObjQry:OpenAlias()

	oRetDKO := JsonObject():New()

	if ( !(cAliasTmp)->(Eof()) )
		lHasDKO := .T.
		
		while !(cAliasTmp)->(Eof())

			NF3CentObjJs(@aItemVinc, cNumDoc, cNumSerie, cCodFor, cCodLoja, cEspDoc, (cAliasTmp)->DKO_ITEM, (cAliasTmp)->DKO_COD, (cAliasTmp)->DKO_UM,;
				(cAliasTmp)->DKO_QUANT, (cAliasTmp)->DKO_VUNIT, (cAliasTmp)->DKO_TOTAL, stod((cAliasTmp)->DKO_EMISSA), (cAliasTmp)->REC, NF3DescProd((cAliasTmp)->DKO_COD))
			nSumTotal += (cAliasTmp)->DKO_TOTAL
			(cAliasTmp)->(DbSkip())

		enddo

		oRetDKO['itens'] := aClone(aItemVinc)
	endif

	(cAliasTmp)->(dbCloseArea())

	FwFreeObj(oObjQry)
	FwFreeArray(aItemVinc)
	
return {lHasDKO, oRetDKO, nSumTotal}


//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NF3DescProd
  	Retorna a descrição do produto selecionado pelo usuário no grid
	@type static
	@author renan.martins
	@since 05/2026
	@param cCodProd, character, codigo do produto
	@return cDescProd, character, descricao do produto
/*/
//-----------------------------------------------------------------------------------------------------------------------------------
static function NF3DescProd(cCodProd as character)
	Local cDescProd 	:= "" 				as character
	Local cFilSB1		:= fwxFilial("SB1") as character
	Default cCodProd 	:= ""

	if !empty(cCodProd)
		if (_oJsDesc[cCodProd] != Nil)
			cDescProd := _oJsDesc[cCodProd]
		else
			cDescProd := Alltrim(getAdvFval("SB1", "B1_DESC", cFilSB1 + cCodProd, 1))
			_oJsDesc[cCodProd] := cDescProd
		endif
	endif
return cDescProd


//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NF3CalcIt
  	Retorna o valor total do item, caso informe quantidade e valor. Se informar apenas valor, e replicado para o total, mas pode alterar.
	@type function
	@author renan.martins
	@since 05/2026
	@return nTotal, numeric, valor total do item
/*/
//-----------------------------------------------------------------------------------------------------------------------------------
function NF3CalcIt()
	Local nQuant 		:= 0 	as numeric
	Local nVUnit 		:= 0 	as numeric
	Local nTotal 		:= 0 	as numeric
	Local oModel 		:= Nil 	as object
	Local oMdlItens 	:= Nil 	as object

	oModel := FwModelActive()
	oMdlItens := oModel:GetModel("ITENSDETAIL")
	nQuant := oMdlItens:GetValue("DKO_QUANT")
	nVUnit := oMdlItens:GetValue("DKO_VUNIT")

	if (nQuant != 0 .and. nVUnit != 0)
		nTotal := nQuant * nVUnit
	elseif (nQuant == 0 .and. nVUnit != 0)
		nTotal := nVUnit
	endif

return nTotal


//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NF3GRVDKO
  	Grava a tabela DKO, por meio da model COMNF3MDL, construída para esse fim.
	@type function
	@author renan.martins
	@since 05/2026
	@obs Depende da variável Private externa oJsDKOInf (MATA103) contendo os dados dos itens a gravar.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------
function NF3GRVDKO()
	Local aDados  	:= {} 	as array
	Local aErro		:= {} 	as array
	Local nSize		:= 0 	as numeric
	Local oMdlGrv 	:= FWLoadModel('COMNF3MDL') 		as object
	Local oMdlItens	:= oMdlGrv:GetModel('ITENSDETAIL') 	as object

	aDados := oJsDKOInf["itens"]
	oMdlGrv:SetOperation( MODEL_OPERATION_INSERT )
	oMdlGrv:Activate()

	nSize := len(aDados)
	if ( nSize > 0 )
		NF3CentModel(@oMdlItens, aDados, .T.)	
	endif

	if (oMdlGrv:VldData() )
        oMdlGrv:CommitData()
    else
		aErro := oMdlGrv:GetErrorMessage()
		Help(nil, nil , "DKOGRAV", nil, aErro[6], 1, 0, nil, nil, nil, nil, nil, {aErro[7]} ) 
	endif

	oMdlGrv:DeActivate()
    oMdlGrv:Destroy()
	FwFreeArray(aDados)
	FwFreeArray(aErro)
	FwFreeObj(oMdlGrv)
return


//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NF3DELDKO
  	Deleta os dados da tabela DKO, por meio da model COMNF3DEL, construída para esse fim.
	Como a tabela é o próprio cabeçalho e item, é necessário abrir em cada registro e efetuar sua deleção, via MVC 
	@type function
	@author renan.martins
	@since 05/2026
	@param cNumDoc, string, número do documento
	@param cNumSerie, string, série do documento
	@param cCodFor, string, código do fornecedor
	@param cCodLoja, string, código da loja
	@param cEspDoc, string, espécie do documento
	@return Nil, 	 Nil, 	 Nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------
function NF3DELDKO(cNumDoc as character, cNumSerie as character, cCodFor as character, cCodLoja as character, cEspDoc as character)
	Local aDados  		:= {} 	as array
	Local aDadTmp		:= {} 	as array
	Local aErro			:= {} 	as array
	Local nFor			:= 0 	as numeric
	Local nSize			:= 0 	as numeric
	Local oMdlGrv 		:= Nil 	as object
	Default cNumDoc 	:= ""
	Default cNumSerie 	:= ""
	Default cCodFor 	:= ""
	Default cCodLoja 	:= ""
	Default cEspDoc 	:= ""

	aDadTmp := NF3QryDKO(cNumDoc, cNumSerie, cCodFor, cCodLoja, cEspDoc)
	if (aDadTmp[1]) //Verifica se há registros na DKO 
		aDados := aDadTmp[2]['itens']
		nSize  := len(aDados)
		
		if (nSize > 0)
			for nFor := 1 to nSize
				DKO->(DBGOTO( aDados[nFor]["recno"] ))
				oMdlGrv := FWLoadModel('COMNF3DEL')
				oMdlGrv:SetOperation( MODEL_OPERATION_DELETE )
				oMdlGrv:Activate()
				if (oMdlGrv:VldData() )
					oMdlGrv:CommitData()
				else
					aErro := oMdlGrv:GetErrorMessage()
					Help(nil, nil , "DKODELET", nil, aErro[6], 1, 0, nil, nil, nil, nil, nil, {aErro[7]} ) 
				endif
				oMdlGrv:DeActivate()
				oMdlGrv:Destroy()
			next nFor
		endif
	endif

	FwFreeArray(aDados)
	FwFreeArray(aDadTmp)
	FwFreeArray(aErro)
	FwFreeObj(oMdlGrv)
return


//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NF3IniLoad
  	Realiza a configuração de visualização da tela - via stática _lVisual - indicando se deve ou não bloquear os campos do grid.
	@type function
	@author renan.martins
	@since 05/2026
	@param lInclu, logical, se e inclusao ou nao.
	@return Nil, Nil, Nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------
function NF3IniLoad(lInclu as logical)
	Default lInclu := .T.
	_lVisual := !lInclu
return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} NF3CentModel
	Centraliza a rotina de preencher o model de itens com os dados do JSON ou do BD, em unico local, para facilitar manutencoes futuras
	@type static
	@author renan.martins
	@since 06/2026
	@version 1.0

	@param oMdlIt, object, objeto do modelo de dados da tela, para inputar os valores dos campos.
	@param aDadosPrinc, array, array de objetos JSON, contendo os dados dos itens, seja JSON ou BD.
	@param lInput, logical, indicando se e gravacao (para preencher mais dados da model) ou apenas visualizacao da tela.
	@return Nil, Nil, Nil
/*/
//-------------------------------------------------------------------
static function NF3CentModel(oMdlIt as object, aDadosPrinc as array, lInput as logical)
	Local nSize			:= 0 				as numeric
	Local nFor			:= 0 				as numeric
	Local cFilDKO		:= fwxFilial("DKO")	as character
	Default oMdlIt 		:= Nil
	Default aDadosPrinc := {}
	Default lInput 		:= .F.

	nSize := len(aDadosPrinc)
	if (oMdlIt != Nil .and. nSize > 0)
		
		for nFor := 1 to nSize
			if nFor > 1
				oMdlIt:AddLine()
			endif

			if (lInput)
				oMdlIt:LoadValue('DKO_FILIAL'	, cFilDKO						)
				oMdlIt:LoadValue('DKO_DOC'		, aDadosPrinc[nFor]["document"]	)
				oMdlIt:LoadValue('DKO_SERIE'	, aDadosPrinc[nFor]["serie"]	)
				oMdlIt:LoadValue('DKO_FORNEC'	, aDadosPrinc[nFor]["supplier"]	)
				oMdlIt:LoadValue('DKO_LOJA'		, aDadosPrinc[nFor]["store"]	)
				oMdlIt:LoadValue('DKO_ESPECI'	, aDadosPrinc[nFor]["specie"]	)
			endif
			oMdlIt:LoadValue('DKO_ITEM'			, aDadosPrinc[nFor]["item"]   	)
			oMdlIt:LoadValue('DKO_COD'			, aDadosPrinc[nFor]["product"]	) 	
			oMdlIt:LoadValue('DKO_UM'			, aDadosPrinc[nFor]["measure"]	)	
			oMdlIt:LoadValue('DKO_QUANT'		, aDadosPrinc[nFor]["quantity"]	)
			oMdlIt:LoadValue('DKO_VUNIT'		, aDadosPrinc[nFor]["unitary"]	)
			oMdlIt:LoadValue('DKO_TOTAL'		, aDadosPrinc[nFor]["total"]	)
			oMdlIt:LoadValue('DKO_EMISSA'		, aDadosPrinc[nFor]["emission"]	)
			if ( oMdlIt:HasField("DESC") )
				oMdlIt:LoadValue('DESC'			, aDadosPrinc[nFor]["description"]	)
			endif
		next nFor
	endif
return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} NF3CentObjJs
	Centraliza a rotina de preencher o objeto JSON com os dados, vindo do model ou BD, em unico local, para facilitar manutencoes futuras
	@type static
	@author renan.martins
	@since 06/2026
	@version 1.0

	@param aInput, array, array de objetos JSON onde o novo item sera adicionado (passado por referencia).
	@param cNumDoc, character, numero do documento.
	@param cNumSerie, character, serie do documento.
	@param cCodFor, character, codigo do fornecedor.
	@param cCodLoja, character, codigo da loja.
	@param cEspDoc, character, especie do documento.
	@param cItem, character, numero do item.
	@param cProduct, character, codigo do produto.
	@param cMeasure, character, unidade de medida.
	@param nQuantity, numeric, quantidade.
	@param nUnitary, numeric, valor unitario.
	@param nTotal, numeric, valor total.
	@param dEmission, date, data de emissao/competencia.
	@param nRecno, numeric, RECNO do registro na DKO (0 se novo).
	@param cDescription, character, descricao do produto.
	@return Nil, Nil, Nil
/*/
//-------------------------------------------------------------------
static function NF3CentObjJs(aInput as array, cNumDoc as character, cNumSerie as character, cCodFor as character, cCodLoja as character, cEspDoc as character,;
							  cItem as character, cProduct as character, cMeasure as character, nQuantity as numeric, nUnitary as numeric, nTotal as numeric,;
							  dEmission as date, nRecno as numeric, cDescription as character)
	Local nPosic			:= 0	as numeric
	Default aInput 			:= {}
	Default cNumDoc 		:= "" 
	Default cNumSerie 		:= ""
	Default cCodFor 		:= ""
	Default cCodLoja 		:= ""
	Default cEspDoc 		:= ""
	Default cItem 			:= ""
	Default cProduct 		:= ""
	Default cMeasure 		:= ""
	Default nQuantity 		:= 0
	Default nUnitary 		:= 0
	Default nTotal 			:= 0
	Default dEmission 		:= date()
	Default nRecno 			:= 0
	Default cDescription 	:= ""

	aAdd(aInput, JsonObject():New())
	nPosic := len(aInput)

	aInput[nPosic]['document'] 		:= cNumDoc
	aInput[nPosic]['serie'] 		:= cNumSerie
	aInput[nPosic]['supplier'] 		:= cCodFor
	aInput[nPosic]['store'] 		:= cCodLoja
	aInput[nPosic]['specie'] 		:= cEspDoc
	aInput[nPosic]["item"]   		:= cItem
	aInput[nPosic]["product"]   	:= cProduct
	aInput[nPosic]["measure"]   	:= cMeasure
	aInput[nPosic]["quantity"]		:= nQuantity
	aInput[nPosic]["unitary"]  		:= nUnitary
	aInput[nPosic]["total"]   		:= nTotal
	aInput[nPosic]["emission"] 		:= dEmission
	aInput[nPosic]["recno"] 		:= nRecno
	aInput[nPosic]["description"] 	:= cDescription

return Nil
