#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CNTA340.CH"
#INCLUDE "GCTXDEF.CH"

Static _oModelCTR := Nil

PUBLISH MODEL REST NAME CNTA340 SOURCE CNTA340

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTA340
Função principal da rotina Rateio De Serviço
@author ivan.magno
@since 18/03/2024
/*/
//-------------------------------------------------------------------
Function CNTA340()


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Montagem do modelo dados para a rotina Rateio de Serviço

@return oModel - Objeto do modelo de dados
@author ivan.magno
@since 18/03/2024
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel 	 := FWModelActive()
	Local oStrField  := FWFormStruct( 1, "CN9" )
	Local oStruCNA 	 := FWFormStruct( 1, "CNA" )
	Local oStruCXS 	 := FWFormStruct( 1, "CXS" )
	Local oStruCXT 	 := FWFormStruct( 1, "CXT" )
	Local aRelCNA 	 := {}
	Local aRelCXS 	 := {}
	Local aRelCXT 	 := {}
	Local bPosCXS 	 := {|oModelCXS| PosVldCXS( oModelCXS ) }
	Local bCommit 	 := {|| RetCNC( oModel ) }
	Local aTriggers  := {}
	Local aDisableTrig := {}
	Local nX		 := 0	
	Local bVldCXSVal := FwBuildFeature( STRUCT_FEATURE_VALID	,"FwFldGet('CXS_VLTOT') > 0") 
	Local bVldCXTPer := FwBuildFeature( STRUCT_FEATURE_VALID	,"FwFldGet('CXT_PERC') > 0 .AND. FwFldGet('CXT_PERC') <= 100" )
	Local bVldCNAPla := MTBlcVld( 'CNA', 'CNA_TIPPLA', 'CNIsTpServ()', .T. ,, .T. )
	Local bVldCode   := FwBuildFeature( STRUCT_FEATURE_VALID	, "CN340Code()" )
	Local bPreCXT	 := {|oModelCXT, nLin, cAction, cField, xOldValue, xNewValue| PreLinCXT( oModelCXT, nLin, cAction, cField, xNewValue, xOldValue ) }

	oStruCXS:AddTrigger( "CXS_PRODUT", "CXS_DESCRI"	, {|| .T. }, {|| RetDescPro() })
	oStruCXT:AddTrigger( "CXT_PERC"	 , "CXT_VALOR"	, {|| .T. }, {|| RetVlrTot() } )
	oStruCXT:AddTrigger( "CXT_FORNEC", "CXT_LOJA"	, {|| .T. }, {|| RetStore( ) } )
	oStruCXT:AddTrigger( "CXT_FORNEC", "CXT_NOME"	, {|| .T. }, {|| RetName( )  } )
	oStruCXT:AddTrigger( "CXT_LOJA"	 , "CXT_NOME"	, {|| .T. }, {|| RetName( )  } )
	oStruCXT:AddTrigger( "CXT_CLIENT", "CXT_LOJACL"	, {|| .T. }, {|| RetStore( 'SA1' ) } )  
	oStruCXT:AddTrigger( "CXT_CLIENT", "CXT_NOMECL"	, {|| .T. }, {|| RetName( 'SA1' ) } )
	oStruCXT:AddTrigger( "CXT_LOJACL", "CXT_NOMECL"	, {|| .T. }, {|| RetName( 'SA1' ) } ) 

	oStrField:SetProperty( '*'			, MODEL_FIELD_OBRIGAT, .F. )
	oStrField:SetProperty( 'CN9_NUMERO'	, MODEL_FIELD_INIT	 , FwBuildFeature(STRUCT_FEATURE_INIPAD , '' ) )

	oStruCNA:SetProperty( '*'			, MODEL_FIELD_OBRIGAT, .F. )
	oStruCNA:SetProperty( 'CNA_TIPPLA'	, MODEL_FIELD_OBRIGAT, .T. )
	oStruCNA:SetProperty( 'CNA_RATEIO'	, MODEL_FIELD_INIT	 , FwBuildFeature(STRUCT_FEATURE_INIPAD," '1' ") )
	oStruCNA:SetProperty( 'CNA_TIPPLA'	, MODEL_FIELD_VALID	 , bVldCNAPla )
	oStruCXS:SetProperty( 'CXS_VLTOT'	, MODEL_FIELD_VALID	 , bVldCXSVal )
	oStruCXT:SetProperty( 'CXT_CLIENT'	, MODEL_FIELD_VALID	 , bVldCode )
	oStruCXT:SetProperty( 'CXT_FORNEC'	, MODEL_FIELD_VALID	 , bVldCode )
	oStruCXT:SetProperty( 'CXT_LOJA'	, MODEL_FIELD_VALID	 , bVldCode )
	oStruCXT:SetProperty( 'CXT_LOJACL'	, MODEL_FIELD_VALID	 , bVldCode )
	oStruCXT:SetProperty( 'CXT_PERC'	, MODEL_FIELD_VALID	 , bVldCXTPer )

	oModel := MPFormModel():New( "CNTA340", /*bPre*/, /*bPos*/, bCommit,/* bCancel*/)

	oModel:addFields( "CN9MASTER"  , /*cOwner*/	, oStrField, /*bPre*/	,/*bPost*/ ,/*bPost*/ , /*bload*/)
	oModel:AddGrid( "CNADETAIL", "CN9MASTER"	, oStruCNA ,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/, {| oModelCNA| LoadCNA( oModelCNA ) } ) 
	oModel:AddGrid( "CXSDETAIL", "CNADETAIL", oStruCXS ,/*bLinePre*/, bPosCXS ,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/, {| oModelCXS| LoadCXS( oModelCXS ) } ) 
	oModel:AddGrid( "CXTDETAIL", "CXSDETAIL", oStruCXT , bPreCXT,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/, {| oModelCXT| LoadCXT( oModelCXT ) } ) 

	oModel:SetPrimaryKey( {} )

	oModel:GetModel( 'CXTDETAIL' ):SetUniqueLine( { "CXT_CLIENT","CXT_LOJACL","CXT_FORNEC","CXT_LOJA"} )

	aAdd( aRelCNA, { 'CNA_FILIAL', 'FWxFilial("CNA")' } )
	aAdd( aRelCNA, { 'CNA_CONTRA', 'CN9_NUMERO' } )
	aAdd( aRelCNA, {' CNA_REVISA', 'CN9_REVISA' } )
	oModel:SetRelation( 'CNADETAIL', aRelCNA, CNA->( IndexKey( 1 ) ) )

	aAdd( aRelCXS, { 'CXS_FILIAL', 'FWxFilial("CXS")' } )
	aAdd( aRelCXS, { 'CXS_CONTRA', 'CNA_CONTRA' } )
	aAdd( aRelCXS, { 'CXS_REVISA', 'CNA_REVISA' } )
	aAdd( aRelCXS, { 'CXS_NUMPLA', 'CNA_NUMERO'} )
	oModel:SetRelation( 'CXSDETAIL', aRelCXS, CXS->( IndexKey( 1 ) ) )

	aAdd( aRelCXT, { "CXT_FILIAL"	, "FWxFilial('CXT')" } )
	aAdd( aRelCXT, { 'CXT_CONTRA'	, 'CXS_CONTRA'} )
	aAdd( aRelCXT, { 'CXT_REVISA'	, 'CXS_REVISA'} )
	aAdd( aRelCXT, { 'CXT_NUMPLA'	, 'CXS_NUMPLA' } )	
	aAdd( aRelCXT, { 'CXT_ITEM'		, 'CXS_ITEM' } )	
	oModel:SetRelation( "CXTDETAIL", aRelCXT, CXT->( IndexKey( 1 )  ) )

	aTriggers := oModel:GetModel( 'CNADETAIL' ):GetStruct():GetTriggers()
	aDisableTrig := { aScan( aTriggers, { |x| AllTrim( x[ 1 ] ) == "CNA_FORNEC" .And. AllTrim(x[ 2 ] ) == "CNA_LJFORN" } ),;
					  aScan( aTriggers, { |x| AllTrim(x[1] ) == "CNA_CLIENT" .And. AllTrim( x[2] ) == "CNA_LOJACL" } ) ,;
					  aScan( aTriggers, { |x| AllTrim( x[1] ) == "CNA_TIPPLA" .And. AllTrim( x[2] ) == "CNA_TIPPLA" } )	}

	For nX := 1 to Len( aDisableTrig )
		If aDisableTrig[nX] > 0
			aTriggers[ aDisableTrig[nX] ][ 3 ] := {|| .F. }
		Endif
	Next

	oModel:SetVldActivate( {| oModel | CN340VlAct( oModel) } )
	oModel:SetActivate( {| oModel | CN340Activ( oModel ) } )
	oModel:SetDeActivate( {| oModel | CN340DeAct( oModel ) } )
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} CN340Activ
	Função estática para o activate do model do CNTA340
@param oModel - Objeto do modelo de dados
@author ivan.magno
@since 18/03/2024
/*/
//-------------------------------------------------------------------
Static Function CN340Activ( oModel )
	Local cPlaOri := _oModelCTR:Getvalue('CNADETAIL', 'CNA_PLAORI')
	
//Só efetua a alteração do campo para inserção
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
			oModel:GetModel( 'CN9MASTER' ):SetValue( 'CN9_FILCTR', _oModelCTR:GetValue( "CN9MASTER", "CN9_FILCTR" ) )
			oModel:GetModel( 'CN9MASTER' ):SetValue( 'CN9_NUMERO' , _oModelCTR:GetValue( "CN9MASTER", "CN9_NUMERO" ) )
			oModel:GetModel( 'CN9MASTER' ):SetValue( 'CN9_REVATU', _oModelCTR:GetValue( "CN9MASTER", "CN9_REVATU" ) )
	Endif

	If Empty(cPlaOri)
		RetGridGs( oModel )
	Else
		RetGrid( oModel )	
	EndiF


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Função estática do ViewDef montagem da tela de Rateio de Serviços

@return oView - Objeto da view, interface do CNTA340
@author ivan.magno
@since 18/03/2024
/*/
//-------------------------------------------------------------------
Static Function viewDef()
	Local cFieldCNA := "CNA_PLAORI|CNA_TIPPLA|CNA_DESCRI|CNA_RATEIO|"
    Local cFieldCXS := "CXS_ITEM|CXS_PRODUT|CXS_DESCRI|CXS_VLTOT|"
	Local cFieldCXT := ""
	Local oStrCab := FWFormStruct( 2, 'CN9' )
    Local oStruCNA 	:= FWFormStruct( 2, 'CNA', {| cField| AllTrim( cField ) + '|' $ cFieldCNA } )
    Local oStruCXS 	:= FWFormStruct( 2, 'CXS', {| cField| AllTrim( cField ) + '|' $ cFieldCXS } )
	Local oStruCXT 	:= FWFormStruct( 2, 'CXT' )
    Local oView 
    Local oModel    

	If !( CNTGetFun() == 'CNTA301' )
		cFieldCXT := "CXT_FORNEC|CXT_LOJA|CXT_NOME|CXT_PERC|CXT_VALOR|"
		oStruCXT := FWFormStruct( 2, 'CXT', {| cField| AllTrim( cField ) + '|' $ cFieldCXT } )
		oStruCXT:SetProperty( 'CXT_FORNEC', MVC_VIEW_ORDEM , '01' )
		oStruCXT:SetProperty( 'CXT_LOJA'  , MVC_VIEW_ORDEM , '02' )
		oStruCXT:SetProperty( 'CXT_NOME' , MVC_VIEW_ORDEM  , '03' )
	Else
		cFieldCXT := "CXT_CLIENT|CXT_LOJACL|CXT_NOMECL|CXT_PERC|CXT_VALOR|"
		oStruCXT := FWFormStruct( 2, 'CXT', {| cField| AllTrim( cField ) + '|' $ cFieldCXT } )
		oStruCXT:SetProperty( 'CXT_CLIENT', MVC_VIEW_ORDEM , '01' )
		oStruCXT:SetProperty( 'CXT_LOJACL', MVC_VIEW_ORDEM , '02' )
		oStruCXT:SetProperty( 'CXT_NOMECL' ,MVC_VIEW_ORDEM , '03' )
	Endif

	oStruCNA:SetProperty( 'CNA_PLAORI',MVC_VIEW_ORDEM , '01' )

	oStruCNA:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
	oStruCNA:SetProperty('CNA_TIPPLA', MVC_VIEW_CANCHANGE, .T.)

	oStruCXS:SetProperty('CXS_ITEM', MVC_VIEW_CANCHANGE, .F.)

	oStruCXT:SetProperty( 'CXT_PERC' ,MVC_VIEW_ORDEM , '04' )
	oStruCXT:SetProperty( 'CXT_VALOR',MVC_VIEW_ORDEM , '05' )

    //Estrutura de Grid
    oModel := FWLoadModel( "CNTA340" )

    oView := FwFormView():New()

    oView:setModel( oModel )
    oView:addField( "VIEW_CN9", oStrCab , "CN9MASTER" )
    oView:AddGrid( "VIEW_CNA", oStruCNA, "CNADETAIL" )
	oView:AddGrid( "VIEW_CXS", oStruCXS, "CXSDETAIL" )
	oView:AddGrid( "VIEW_CXT", oStruCXT, "CXTDETAIL" )
    oView:createHorizontalBox( "CABE_CN9", 0)
    oView:CreateHorizontalBox( "GRID_CNA", 25 )
	oView:CreateHorizontalBox( "GRID_CXS", 30 )
	oView:CreateHorizontalBox( "GRID_CXT", 45 )
	oView:setOwnerView( "VIEW_CN9", "CABE_CN9" )
	oView:SetOwnerView( "VIEW_CNA", "GRID_CNA" )
	oView:SetOwnerView( "VIEW_CXS", "GRID_CXS" )
	oView:SetOwnerView( "VIEW_CXT", "GRID_CXT" )

    oView:EnableTitleView( "VIEW_CNA", STR0020 ) // Planilha
	oView:EnableTitleView( "VIEW_CXS", STR0021 ) // Produtos
	oView:EnableTitleView( "VIEW_CXT", STR0022 ) // Rateio

	oView:AddIncrementField( "VIEW_CNA", "CNA_NUMERO" )
	oView:AddIncrementField( "VIEW_CNA", "CNA_PLAORI" )
	oView:AddIncrementField( "VIEW_CXS", "CXS_ITEM" )

	//Definindo que não irá usar o " Salvar e Criar Novo "
    oView:SetCloseOnOk( {|| .T.} )
	//Desativa mensagem de Inserção
	oView:showInsertMsg( .F. )
	//Definindo para que não seja exibido aquela pergunta de confirmar realmente ao clicar no Fechar
    oView:SetViewAction('ASKONCANCELSHOW', {|oView| .F.})
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} RetVlrTot
	Responsável por atualizar o valor  do campo CXT_VALOR de acordo com o percentual preenchido
	no campo CXT_PERC

@return nVltot, numerico, retorna o valor total de acordo com o percentual
@author ivan.magno
@since 09/04/2024

/*/
//-------------------------------------------------------------------
Static Function RetVlrTot()
    Local oModel := FWModelActive()
    Local oProduct := oModel:GetModel( "CXSDETAIL" )
	Local oCode := oModel:GetModel( "CXTDETAIL" )
	Local nDecimal := GetSx3Cache( "CXT_VALOR" , "X3_DECIMAL" )
    Local nCalcVlr := 0
	Local nVltot := 0

	nCalcVlr := ( oProduct:GetValue( "CXS_VLTOT" ) * oCode:GetValue( "CXT_PERC" ) ) /100
	nVltot	:= Round( nCalcVlr, nDecimal )

Return nVltot

//-------------------------------------------------------------------
/*/{Protheus.doc} RetName
	Responsável por atualizar o nome do fornecedor e cliente

@param cAliasSeek,caracter, Alias que será utilizado na consulta

@return cName, character, retorna o nome do Cliente/fornecedor

@author ivan.magno
@since 09/04/2024
/*/
//-------------------------------------------------------------------
Static Function RetName( cAliasSeek )
    Local oModel := FWModelActive()
	Local oCode := oModel:GetModel( "CXTDETAIL" )
	Local aArea := GetArea()
	Local cCpoSeek := 'CXT_FORNEC' 
	Local cStoreSeek := 'CXT_LOJA'
	Local cPrefix := ""
	Local cName := ""
	Local cStore := ""

	Default cAliasSeek := 'SA2'

	If  cAliasSeek == 'SA1'
		cCpoSeek	:= 'CXT_CLIENT'
		cStoreSeek := 'CXT_LOJACL'
	Endif

	cPrefix	:= PrefixoCpo( cAliasSeek )

	If Empty( oCode:GetValue( cStoreSeek ) )
	  cStore := RetStore( cAliasSeek )
	  oCode:LoadValue( cStoreSeek,cStore )
	Endif

	cName := Posicione(cAliasSeek, 1, xFilial( cAliasSeek ) + ( oCode:GetValue( cCpoSeek ) + oCode:GetValue( cStoreSeek ) ), cPrefix + "_NOME" )

	RestArea( aArea )
	FwFreeArray( aArea )

Return cName

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCNC
 	Responsavel pelo inicio do retorno da CNC no modelo do CNTA300/301

@param oModel, object, recebe o modelo de dados

@return lRet,boolean, retorna .T. caso não encontre nenhum erro	
@author ivan.magno
@since 09/04/2024

/*/
//-------------------------------------------------------------------
static function RetCNC( oModel )
	local aArea := GetArea()
	Local nX := 0
	Local nZ := 0
	Local nY := 0
	Local nW := 0
	Local lRet := .F.
	Local nOperation := oModel:GetOperation()
	Local lModelUpd := .F.
	Local lGS := FunName() $ "TECA850*TECA870*TECA745"
	Local lHasClient := .F.
	Local oMdlCNC := Nil
	Local oMdlCNA := Nil
	Local oMdlCXS := Nil
	Local oMdlCXT := Nil
	Local oSpreadsheet := oModel:GetModel( 'CNADETAIL' )
	Local oProduct := oModel:GetModel( 'CXSDETAIL' )
	Local oCode := oModel:GetModel( 'CXTDETAIL' )
	Local cCNACode := ""
	Local cCNAStore := ""
	Local cCNCCodCli := ""
	Local cCNCLjCli := ""
	Local cPlaOri := ""

	If nOperation <> MODEL_OPERATION_DELETE

		FWModelActive( _oModelCTR )

		oMdlCNC := _oModelCTR:GetModel( 'CNCDETAIL' )
		oMdlCNA := _oModelCTR:GetModel( 'CNADETAIL' )
		oMdlCNB := _oModelCTR:GetModel( 'CNBDETAIL' )
		oMdlCXS := _oModelCTR:GetModel( 'CXSDETAIL' )
		oMdlCXT := _oModelCTR:GetModel( 'CXTDETAIL' )
		
		cCode := 'CXT_FORNEC'
		cStore := 'CXT_LOJA'
		cCNCCode := 'CNC_CODIGO'
		cCNCStore := 'CNC_LOJA'
		cCNACode := 'CNA_FORNEC'
		cCNAStore := 'CNA_LJFORN'

		If CNTGetFun() == 'CNTA301'
			cCode := 'CXT_CLIENT'
			cStore := 'CXT_LOJACL'
			cCNCCode := 'CNC_CLIENT'
			cCNCStore := 'CNC_LOJACL'				
			cCNACode := 'CNA_CLIENT'
			cCNAStore := 'CNA_LOJACL'
		Endif

		lModelUpd := oMdlCNC:CanInsertLine()

		If !lModelUpd .OR. FWIsInCallStack("TECA870")
			CNTA300BlMd(_oModelCTR:GetModel('CNCDETAIL'),.F.)
			CNTA300BlMd(_oModelCTR:GetModel('CNADETAIL'),.F.)			
		Endif

		For nX := 1 to oSpreadsheet:Length()
			oSpreadsheet:Goline( nX )
			If !oSpreadsheet:IsDeleted()
				For nY := 1 to oProduct:Length()
					oProduct:Goline( nY )
					If !oProduct:IsDeleted()
						For nZ := 1 to oCode:Length()
							oCode:GoLine( nZ )
							If !oCode:IsDeleted()			
								If !( oMdlCNC:SeekLine( { { cCNCCode, oCode:GetValue( cCode ) }, { cCNCStore, oCode:GetValue( cStore ) } } ) )
									If !( Empty( oMdlCNC:GetValue( cCNCCode ) ) )
										oMdlCNC:AddLine()
									Endif
									oMdlCNC:SetValue( cCNCCode, oCode:GetValue( cCode ) )
									oMdlCNC:SetValue( cCNCStore, oCode:GetValue( cStore ) )
								Endif
							Else
								If lGS .And. oMdlCNC:SeekLine( { { cCNCCode, oCode:GetValue( cCode ) }, { cCNCStore, oCode:GetValue( cStore ) } } )
									cPlaOri := oSpreadsheet:GetValue( "CNA_PLAORI" )
									cCNCCodCli := oMdlCNC:GetValue( cCNCCode )
									cCNCLjCli := oMdlCNC:GetValue( cCNCStore )
									For nW := 1 To oMdlCNA:Length()
										If !oMdlCNA:IsDeleted( nW ) .And. oMdlCNA:GetValue( "CNA_PLAORI", nW ) <> cPlaOri .And. oMdlCNA:GetValue( cCNACode, nW ) == cCNCCodCli .And. oMdlCNA:GetValue( cCNAStore, nW ) == cCNCLjCli
											lHasClient := .T.
											Exit
										EndIf
									Next nW
									If oMdlCNA:SeekLine( { { cCNACode, oMdlCNC:GetValue( cCNCCode ) } ,;
															{ cCNAStore, oMdlCNC:GetValue( cCNCStore ) } ,;
															{ 'CNA_TIPPLA', oSpreadsheet:GetValue( 'CNA_TIPPLA' ) } ,;
															{ 'CNA_RATEIO', "1"								},;
															{ 'CNA_PLAORI' , cPlaOri } } )
										If oMdlCNA:CanDeleteLine()
											oMdlCNA:DeleteLine()
										EndIf
									EndIf
									If !lHasClient
										If oMdlCNC:CanDeleteLine()
											oMdlCNC:DeleteLine()
										EndIf
									EndIf
									lHasClient := .F.
								Endif
							Endif
						Next nZ
					Endif
				Next nY
			Endif
		Next nX

		If oModel:VldData()
			//Chama função responsavel por preencher a CNA e CNB no model CNTA300/301
			lRet := RetCNACNB( oModel )			
		EndIf

	Endif		

	If lRet
		oModel:DeActivate()
	Endif

	RestArea( aArea )
	FwFreeArray( aArea )
	FreeObj( _oModelCTR )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCNACNB
 Responsavel pela retorno das infomações do rateio no modelo do CNTA300 da CNA e CNB

@param oModel, object, recebe o modelo de dados

@return lRateOk,boolean, retorna .T. caso não encontre nenhum erro
@author ivan.magno
@since 09/04/2024
/*/
//-------------------------------------------------------------------
Static Function RetCNACNB( oModel )
	Local aArea := GetArea()
	Local nX := 0
	Local nZ := 0
	Local nY := 0
	Local nW := 0
	Local nLinCNAAtu := 0
	Local nLinCNBAtu := 0
	Local nLineCode	 := 0
	Local lRateOk := .F.
	Local lGS := FunName() $ "TECA850*TECA870*TECA745"
	local oSpreadsheet := oModel:GetModel( 'CNADETAIL' )
	Local oProduct := oModel:GetModel( 'CXSDETAIL' )
	Local oCode := oModel:GetModel( 'CXTDETAIL' )
	Local oMdlCNA := _oModelCTR:GetModel( 'CNADETAIL' )
	Local oMdlCNB := _oModelCTR:GetModel( 'CNBDETAIL' )
	Local nItPla := GetSx3Cache( 'CNA_NUMERO', 'X3_TAMANHO' )
	Local nItCNB := GetSx3Cache( 'CNB_ITEM', 'X3_TAMANHO' )
	Local nItmdstCNB := GetSx3Cache( 'CNB_ITMDST', 'X3_TAMANHO' )
	Local cCode := 'CXT_FORNEC'
	Local cStore := 'CXT_LOJA'
	Local cCNACode := 'CNA_FORNEC'
	Local cCNAStore := 'CNA_LJFORN'
	Local cSpreadsheet := ""
	Local cTesCNB := ""
	Local cCcCNB  := ""
	
	If CNTGetFun() == 'CNTA301'
		cCode := 'CXT_CLIENT'
		cStore := 'CXT_LOJACL'
		cCNACode := 'CNA_CLIENT'
		cCNAStore := 'CNA_LOJACL'
	EndIf

	If oModel:GetOperation() <> MODEL_OPERATION_DELETE
		If Empty(oMdlCNA:GetValue( "CNA_PLAORI"))
			oMdlCNA:LoadValue( "CNA_PLAORI", oMdlCNA:GetValue( "CNA_NUMERO" ) )
			oMdlCNA:LoadValue( "CNA_RATEIO", "1" )

			For nW := 1 to oMdlCNB:Length()
				oMdlCNB:Goline(nW)			
				If !oMdlCNB:Isdeleted()
					If !Empty(oMdlCNB:GetValue( "CNB_PRODUT")) .AND. Empty(oMdlCNB:GetValue( "CNB_ITMORI"))
						oMdlCNB:LoadValue( "CNB_ITMORI", oMdlCNB:GetValue( "CNB_ITEM" ) )
					Endif
				Endif	
			Next

		Endif	
	Endif

	If FWIsInCallStack("TECA870")
		CNTA300BlMd(_oModelCTR:GetModel('CNADETAIL'),.F.)
		CNTA300BlMd(_oModelCTR:GetModel('CNBDETAIL'),.F.)
		CNTA300BlMd(_oModelCTR:GetModel('CXSDETAIL'),.F.)
		CNTA300BlMd(_oModelCTR:GetModel('CXTDETAIL'),.F.)
	Endif

	cSpreadsheet := oMdlCNA:GetValue( 'CNA_NUMERO', oMdlCNA:Length() )

	For nX := 1 to oSpreadsheet:Length()
		oSpreadsheet:Goline( nX )
		If !oSpreadsheet:IsDeleted()
			For nY := 1 to oProduct:Length()
				oProduct:Goline( nY )
				If !oProduct:IsDeleted()
					For nZ := 1 to oCode:Length()
						oCode:GoLine( nZ )
						If !oCode:IsDeleted()
							If !( oMdlCNA:SeekLine( { { cCNACode, oCode:GetValue( cCode ) } ,;
													  { cCNAStore, oCode:GetValue( cStore ) } ,;
													  { 'CNA_TIPPLA', oSpreadsheet:GetValue( 'CNA_TIPPLA' ) } ,;
													  { 'CNA_RATEIO', "1"								},;
													  { 'CNA_PLAORI' , oSpreadsheet:GetValue( 'CNA_PLAORI' ) } } ) )

								If !( Empty( oMdlCNA:GetValue( 'CNA_TIPPLA' ) ) )
									oMdlCNA:AddLine()
									cSpreadsheet := Soma1(IIF(Empty(cSpreadsheet), StrZero(0,nItPla), cSpreadsheet))
									oMdlCNA:LoadValue( 'CNA_NUMERO' , cSpreadsheet )
									oMdlCNA:LoadValue( 'CNA_PERIOD' , oSpreadsheet:GetValue( "CNA_PERIOD"))
									oMdlCNA:LoadValue( 'CNA_PERREC' , oSpreadsheet:GetValue( "CNA_PERREC"))
									oMdlCNA:LoadValue( 'CNA_QTDREC' , oSpreadsheet:GetValue( "CNA_QTDREC"))
									oMdlCNA:LoadValue( 'CNA_DIASEM' , oSpreadsheet:GetValue( "CNA_DIASEM"))
									oMdlCNA:LoadValue( 'CNA_DTINI ' , oSpreadsheet:GetValue( "CNA_DTINI "))
									oMdlCNA:LoadValue( 'CNA_DTFIM ' , oSpreadsheet:GetValue( "CNA_DTFIM "))
									oMdlCNA:LoadValue( 'CNA_PROMED' , oSpreadsheet:GetValue( "CNA_PROMED"))

								Endif

								oMdlCNA:SetValue( cCNACode, oCode:GetValue( cCode ) )
								oMdlCNA:SetValue( cCNAStore, oCode:GetValue( cStore ) )
								oMdlCNA:SetValue( 'CNA_TIPPLA', oSpreadsheet:GetValue( 'CNA_TIPPLA' ) )
								oMdlCNA:LoadValue( 'CNA_RATEIO', oSpreadsheet:GetValue( 'CNA_RATEIO' ) )
								oMdlCNA:LoadValue( 'CNA_PLAORI', oSpreadsheet:GetValue( 'CNA_PLAORI' ) )
							Endif

							If !( oMdlCNB:SeekLine( { { 'CNB_ITMORI', oProduct:GetValue( 'CXS_ITEM' ) },;
													  { 'CNB_PRODUT', oProduct:GetValue( 'CXS_PRODUT' ) },;
							 						  { 'CNB_ITMDST', Space( nItmdstCNB ) }} ) )

								If !( Empty( oMdlCNB:GetValue( 'CNB_PRODUT' ) ) )
									oMdlCNB:AddLine()
								Endif
								oMdlCNB:LoadValue( 'CNB_ITEM' , StrZero( oMdlCNB:Length(), nItCNB ) )
								oMdlCNB:LoadValue( 'CNB_ITMORI' , oProduct:GetValue( 'CXS_ITEM' ) )
								nLineCode := oCode:GetLine()
								oMdlCNB:SetValue( 'CNB_PRODUT', oProduct:GetValue( 'CXS_PRODUT' ) )
								oCode:GoLine(nLineCode)
								oMdlCNB:LoadValue( 'CNB_QUANT', oProduct:GetValue( 'CXS_SLDMED' ))								
								oMdlCNB:SetValue( 'CNB_VLUNIT', ( oProduct:GetValue( 'CXS_VLTOT' ) * ( oCode:GetValue( 'CXT_PERC' ) /100 ) ) )
								oCode:GoLine(nLineCode)

								If lGS
									// busca a TES no item original
									nLinCNAAtu := oMdlCNA:GetLine()
									nLinCNBAtu := oMdlCNB:GetLine()
									oMdlCNA:GoLine(1)
									oMdlCNB:GoLine(1)
									If oMdlCNA:SeekLine( { { "CNA_CONTRA", oMdlCNA:GetValue( "CNA_CONTRA" ) } ,{ "CNA_REVISA", oMdlCNA:GetValue( "CNA_REVISA" ) } ,{ "CNA_NUMERO", oSpreadsheet:GetValue( "CNA_PLAORI" ) } } )
										If oMdlCNB:SeekLine( { { 'CNB_ITMORI', oProduct:GetValue( "CXS_ITEM" ) },{ 'CNB_PRODUT', oProduct:GetValue( "CXS_PRODUT" ) } } )
											cTesCNB := oMdlCNB:GetValue( "CNB_TS" )
											cCcCNB  := oMdlCNB:GetValue( "CNB_CC" )
											oMdlCNA:GoLine( nLinCNAAtu )
											oMdlCNB:GoLine( nLinCNBAtu )
											oMdlCNB:LoadValue( "CNB_TS" , cTesCNB )
											oMdlCNB:LoadValue( "CNB_CC" , cCcCNB )
										EndIf
									EndIf
									oMdlCNA:GoLine( nLinCNAAtu )
									oMdlCNB:GoLine( nLinCNBAtu )
								EndIf
							Else					
								oMdlCNB:SetValue( 'CNB_VLUNIT', ( oProduct:GetValue( 'CXS_VLTOT' ) * ( oCode:GetValue( 'CXT_PERC' ) /100 ) ) )
							Endif

							If !( _oModelCTR:GetModel( 'CXSDETAIL' ):SeekLine( { { 'CXS_ITEM', oProduct:GetValue( 'CXS_ITEM' ) } } ) )
								If !( Empty(  _oModelCTR:GetValue( 'CXSDETAIL' , 'CXS_ITEM' ) ) )
									_oModelCTR:GetModel( 'CXSDETAIL' ):AddLine()
								Endif
								_oModelCTR:Loadvalue( 'CXSDETAIL', 'CXS_ITEM'  , oProduct:GetValue( 'CXS_ITEM' ) )
								_oModelCTR:Loadvalue( 'CXSDETAIL', 'CXS_PRODUT', oProduct:Getvalue( 'CXS_PRODUT' ) )
								_oModelCTR:Loadvalue( 'CXSDETAIL', 'CXS_VLTOT' , oProduct:Getvalue( 'CXS_VLTOT' ) )
								_oModelCTR:Loadvalue( 'CXSDETAIL', 'CXS_PLAORI' , oSpreadsheet:GetValue( 'CNA_PLAORI' ) )
								_oModelCTR:Loadvalue( 'CXSDETAIL', 'CXS_SLDMED' , oProduct:Getvalue( 'CXS_SLDMED' ) )
							Else
								_oModelCTR:Loadvalue( 'CXSDETAIL', 'CXS_VLTOT' , oProduct:Getvalue( 'CXS_VLTOT' ) )
							Endif

							If !( _oModelCTR:GetModel( 'CXTDETAIL' ):SeekLine( { { 'CXS_ITEM' , oProduct:GetValue( 'CXS_ITEM' ) },;
																				 { cCode	 , oCode:Getvalue( cCode ) 	 },;
														 						 { cStore	 , oCode:Getvalue( cStore )  } } ) )

								If !( Empty( _oModelCTR:GetValue( 'CXTDETAIL', 'CXT_ITEM') ) )
									_oModelCTR:GetModel( 'CXTDETAIL' ):AddLine()
								Endif

								_oModelCTR:Loadvalue( 'CXTDETAIL', cCode     , oCode:Getvalue( cCode ) )
								_oModelCTR:Loadvalue( 'CXTDETAIL', cStore    , oCode:Getvalue( cStore ) )
								_oModelCTR:Loadvalue( 'CXTDETAIL', 'CXT_PERC', oCode:Getvalue( 'CXT_PERC' ) ) 
								_oModelCTR:Loadvalue( 'CXTDETAIL', 'CXT_VALOR', ( oProduct:GetValue( 'CXS_VLTOT' ) * ( oCode:GetValue( 'CXT_PERC' ) /100 ) ) )
								_oModelCTR:Loadvalue( 'CXTDETAIL', 'CXT_ITEM', oProduct:GetValue( 'CXS_ITEM' ) )
								_oModelCTR:Loadvalue( 'CXTDETAIL', 'CXT_PLAORI' , oSpreadsheet:GetValue( 'CNA_PLAORI' ) )

							Else
								_oModelCTR:Loadvalue( 'CXTDETAIL', 'CXT_PERC' , oCode:Getvalue( 'CXT_PERC' ) ) 
								_oModelCTR:Loadvalue( 'CXTDETAIL', 'CXT_VALOR', ( oProduct:GetValue( 'CXS_VLTOT' ) * ( oCode:GetValue( 'CXT_PERC' ) /100 ) ) )
							Endif														
						Endif
					Next nZ
				Endif
			Next nY
		Endif
	Next nX

	If  oModel:VldData()		
		lRateOk :=.T.
	Endif
	
	RestArea( aArea )
	FwFreeArray( aArea )

Return lRateOk

//-------------------------------------------------------------------
/*/{Protheus.doc} CN340RATSER
	Função responsável para armazenar o modelo de dados do CNTA300 na variavel _oModelCTR

@param oModelCTR , Recebe o modelo do CNTA300/301

@author ivan.magno
@since 05/04/2024
/*/
//-------------------------------------------------------------------
Function CN340RATSER( oModelCTR )
	Local cText := STR0007 // Incluir
	Local nModelType := MODEL_OPERATION_INSERT
	Local cRateio := ""
	Local cPlaOri := ""

	_oModelCTR := oModelCTR
	nOperation := _oModelCTR:GetOperation()
	cRateio := _oModelCTR:Getvalue('CNADETAIL', 'CNA_RATEIO')
	cPlaOri := _oModelCTR:Getvalue('CNADETAIL', 'CNA_PLAORI')

	
	If nOperation == MODEL_OPERATION_INSERT
		
		If	A300GTpRev() == DEF_REV_ABERT  .OR. A300GTpRev() == DEF_REV_ORCGS// Revisão - Aberta ou Orçamento de Serviços
			cText := STR0008 // Alterar
			nModelType := MODEL_OPERATION_UPDATE
			 

		Elseif !(Empty( A300GTpRev() ) )  // Todos os tipos de revisão diferente de Orçamento de Serviços e Aberta
			
			cText := STR0023 // Visualizar
			nModelType := MODEL_OPERATION_VIEW

		Endif

	Elseif nOperation == MODEL_OPERATION_UPDATE

		cText := STR0008 // Alterar
		nModelType := MODEL_OPERATION_UPDATE

	Elseif nOperation == MODEL_OPERATION_VIEW

		cText := STR0023 // Visualizar
		nModelType := MODEL_OPERATION_VIEW

	Endif

	FWExecView(cText , 'CNTA340' , nModelType )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN340RatAut
	Função responsável pelo gerenciamento da variável estática _oModelCTR

@param lSet, boolean, Se for .T. deixar seguir com o armazenamento do modelo
do CNTA300/301
@param _oModel ,objeto , armazena o modelo do CNTA300/301

@return _oModelCTR,objeto, retorna o modelo de dados do CNTA300/301
@author ivan.magno
@since 27/03/2024
/*/
//-------------------------------------------------------------------
Function CN340RatAut(lSet , oModel )
	Default lSet := .F.
	Default oModel := Nil

	If lSet
		_oModelCTR := oModel
	Endif

Return _oModelCTR

//-------------------------------------------------------------------
/*/{Protheus.doc} CN340VlAct
	Bloco chamado no SetVldActivate do modulo.

@param oModel, object, Modelo de dados.

@Return lRet, boolean, Retorna .T. caso o modelo de dados for validado
@author ivan.magno
@since 27/03/2024
/*/
//-------------------------------------------------------------------
Function CN340VlAct( oModel )
	Local lRet := .T.
	Local dDtIni := ""
	Local cPayCond := ""
	Local cVldUnit := ""
	Local cTpcto := ""

	If !( valType( _oModelCTR ) == "O" .and. _oModelCTR:IsActive() .and. _oModelCTR:GetId() $ "CNTA300|CNTA301" )
		Help(" ",1,"CN340VLACT",, STR0010 , 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0011 } ) //Modelo Inválido - Somente poderá ser chamado o CNTA340 com o modelo do CNTA300 ativo
		lRet := .F.
	EndIf

	If lRet
		dDtIni 	 := _oModelCTR:GetValue( "CN9MASTER", "CN9_DTINIC" )
		cPayCond := _oModelCTR:GetValue( "CN9MASTER", "CN9_CONDPG" )
		cVldUnit := _oModelCTR:GetValue( "CN9MASTER", "CN9_UNVIGE" )
		cTpcto 	 := _oModelCTR:GetValue( "CN9MASTER", "CN9_TPCTO"  )

		If Empty( dDtIni ) .OR. Empty(AllTrim( cPayCond ) ) .OR. Empty(AllTrim( cTpcto ) ) .OR. Empty(AllTrim( cVldUnit ) )
			Help(" ",1,"CN340VLMODEL",, STR0002, 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0003 } ) //Inclusão do contrato - Preencher os campos obrigatórios no cabeçalho do contrato
			lRet := .F.
		Endif

	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN340DeAct
	Bloco chamado no DeActivate do modulo. Limpa variaveis estaticas de cache
@author ivan.magno
@since 05/04/2024
/*/
//-------------------------------------------------------------------
Function CN340DeAct( oModel )

	CN340RatAut(.T. , Nil)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RetStore
 Retorna a loja do Cliente/Fornecedor

@param cAliasSeek,caracter, Alias que será utilizado na consulta

@return cStore, caracter, retorna a loja do cliente/fornecedor
@author ivan.magno
@since 11/04/2024
/*/
//-------------------------------------------------------------------
Static Function RetStore( cAliasSeek )
	Local aArea := GetArea()
	Local cStore := " "
	Local oModel := FWModelActive()
	Local oCode := oModel:GetModel( 'CXTDETAIL' )
	Local cCpoSeek := 'CXT_FORNEC'
	Local cKey := ""
	Local cPrefix := ""

	Default cAliasSeek := 'SA2'

	If cAliasSeek == 'SA1'
		cCpoSeek   := 'CXT_CLIENT'
	Endif

	cPrefix	:= PrefixoCpo( cAliasSeek )

	( cAliasSeek )->(Dbsetorder( 1 ) )
	cKey := xFilial( cAliasSeek ) + oCode:GetValue( cCpoSeek )

	If ( cAliasSeek )->( MsSeek( cKey ) )
		While ( cAliasSeek )->( !Eof() .and. &( cPrefix + '_FILIAL' + '+' + cPrefix + '_COD') == cKey)
			cStore := ( cAliasSeek )->( &( cPrefix + '_LOJA' ) )
			If ( cAliasSeek )->( &( cPrefix + '_MSBLQL') ) == '1'
				( cAliasSeek )->( dbSkip() )
			Else
				Exit
			EndIf
		End
	EndIf

	RestArea( aArea )
	FwFreeArray( aArea )

Return cStore

//-------------------------------------------------------------------
/*/{Protheus.doc} RetDescPro
	Função utilizada no gatilho do campo CXS_PRODUT para retornar a
descrição do produto

@return cDesc, caracter, retorna a descrição do produto
@author ivan.magno
@since 11/04/2024
/*/
//-------------------------------------------------------------------
Static Function RetDescPro()
	Local aArea := GetArea()
	Local aAreaSB1 := SB1->( GetArea() )
	Local oModel := FWModelActive()
	Local oProduct := oModel:GetModel( "CXSDETAIL" )
	Local cProduct := oProduct:GetValue( "CXS_PRODUT" )
	Local cDesc	:= ""

	cDesc := Substr( Posicione( "SB1", 1, xFilial( "SB1" ) + cProduct, "SB1->B1_DESC"), 1, 15 )

	RestArea( aArea )
	RestArea( aAreaSB1 )
	FwFreeArray( aArea )
	FwFreeArray( aAreaSB1 )

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldCXS
	Valida se o percentual foi distruido corretamente
	e está em 100% na grid Fornecedores/Cliente

@param oModelCXS, object, modelo do CXS

@return lRet boolean Retorna .T. caso percentual for 100% distruibuido
@author ivan.magno
@since 11/04/2024
/*/
//-------------------------------------------------------------------
Static Function PosVldCXS( oModelCXS )
	Local aArea := GetArea()
	Local oModel := oModelCXS:Getmodel()
  	Local oCode := oModel:GetModel( "CXTDETAIL" )
	Local oProduct := oModel:GetModel( "CXSDETAIL" )
  	Local nSumPerc := 0
	Local nX := 0
	Local nCalcVlr := 0
	Local lRet := .T.

	If !FWIsInCallStack('RetGrid')
	
		For nX := 1 To oCode:Length()
			oCode:GoLine( nX )
			If !oCode:Isdeleted()				
				nSumPerc += oCode:GetValue( "CXT_PERC" )
				nCalcVlr := ( oProduct:GetValue( "CXS_VLTOT" ) * oCode:GetValue( "CXT_PERC" ) ) /100
				oCode:LoadValue( "CXT_VALOR" , nCalcVlr)
			Endif
		Next

		lRet := ( nSumPerc == 100 )

		If	!lRet
			cValPerc := cValToChar( nSumPerc )
			Help(" ", 1, "CN340PERC",, STR0004, 1, 0, NIL, NIL, NIL, NIL, NIL, { I18N( STR0005 ,{ cValPerc } ) } )//Percentual - O percentual está #1 % e precisar ser igual a 100%
		Endif

	EndIf

	RestArea( aArea )
	FwFreeArray( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CNIsTpServ
	Valida se o tipo da planilha informado é do tipo Serviço

@return lRet,  boolean  ,Retorna .T. caso a planilha seja de serviço
@author ivan.magno
@since 11/04/2024
/*/
//-------------------------------------------------------------------
Function CNIsTpServ()
	Local lRet := .T.
	local aArea := GetArea()
	Local aAreaCNL := CNL->( GetArea() )
	Local oModel := FwModelActive()
	Local cTipPla := oModel:GetValue( "CNADETAIL", "CNA_TIPPLA" )

	IF !FwIsInCallStack("TECA850") .AND. !FwIsInCallStack("TECA870")
		If CNL->( MsSeek( xFilial( "CNL" ) + cTipPla ) )
			lRet := ( CNL->CNL_PLSERV == '1') // Serviço? 1 = Sim, 2 = Não
			If !lRet
				Help(" ", 1, "CN340PLASER",, STR0012, 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0013 } ) //Planilha de Serviço - A planilha selecionada não é do tipo serviço. Insira uma planilha do tipo serviço.
			EndIf
		EndIf
	Endif	

	RestArea( aArea )
	RestArea( aAreaCNL )
	FwFreeArray( aArea )
	FwFreeArray( aAreaCNL )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN340Code
	Responsável por verificar o código + loja do  cliente e fornecedor

@return lSeek, boolean,  Retorna .T. caso encontre  o código + loja
@author ivan.magno
@since 09/04/2024
/*/
//-------------------------------------------------------------------
Function CN340Code()
    Local oModel := FWModelActive()
	Local oCode := oModel:GetModel( 'CXTDETAIL' )
	Local aArea := GetArea()
	Local cAliasSeek := 'SA2'
	Local cCpoSeek := 'CXT_FORNEC'
	Local cStoreSeek := 'CXT_LOJA'
	Local lSeek := .F.
	Local cKey := ""
	Local cPrefix := ""

	If  CNTGetFun() == 'CNTA301'
		cAliasSeek := 'SA1'
		cCpoSeek   := 'CXT_CLIENT'
		cStoreSeek := 'CXT_LOJACL'
	Endif

	cPrefix	:= PrefixoCpo( cAliasSeek )
	
	( cAliasSeek )->(Dbsetorder( 1 ) )
	cKey := xFilial( cAliasSeek ) + oCode:GetValue( cCpoSeek )

	lSeek := ( cAliasSeek )->( MsSeek( cKey ) )

	If lSeek .AND. !Empty(oCode:GetValue( cStoreSeek ) )
		lSeek := ExistCpo(cAliasSeek, oCode:GetValue( cCpoSeek ) + oCode:GetValue( cStoreSeek ) )
	Endif

	If !lSeek
		Help(" ",1,"REGNOIS")
	Endif

	RestArea( aArea )
	FwFreeArray( aArea )

Return lSeek

//-------------------------------------------------------------------
/*/{Protheus.doc} HasCNTA340
	Verifica se existe as tabelas no dicionado e função no repositorio.

@return boolean, Retorna se existe as tabelas/campos no dicionario
@author ivan.magno
@since 15/04/2024
/*/
//-------------------------------------------------------------------
Function HasCNTA340()
	Local lHasPlaori := (CNA->(FieldPos("CNA_PLAORI") ) > 0 .AND. X3Uso(GetSx3Cache('CNA_PLAORI', 'X3_USADO') ) )
	Local lHasRateio := (CNA->(FieldPos("CNA_RATEIO") ) > 0 .AND. X3Uso(GetSx3Cache('CNA_RATEIO', 'X3_USADO') ) )

Return AliasInDic( 'CXS' ) .AND. AliasInDic( 'CXT' ) .AND. lHasPlaori .AND. lHasRateio

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCNA
	Realiza a query para carregar os dados na Grid.

@param oModelCNA, object, modelo do CNA

@return array, Retorna os registros da CNA no modelo da CNTA340
@author ivan.magno
@since 26/04/2024
/*/
//-------------------------------------------------------------------
Static Function LoadCNA( oModelCNA )
	Local aArea	:= GetArea()
	Local cAliasCNA := ""
	Local oModel := oModelCNA:GetModel()
	Local oModelCXS := _oModelCTR:GetModel( "CXSDETAIL")
	Local oPrepCNA
	Local aRet := {}
	Local aSaveLines := FWSaveRows()

	If !oModelCXS:IsUpdated()
		cQuery := " SELECT CNA_FILIAL,CNA_CONTRA,CNA_REVISA, CNA_PLAORI CNA_NUMERO,CNA_TIPPLA,CNA_RATEIO,CNA_PERIOD,CNA_PERREC,CNA_QTDREC,CNA_DIASEM,CNA_DTINI,CNA_DTFIM,CNA_PROMED "
		cQuery += " FROM " + RetSqlName( "CNA" ) + " CNA "
		cQuery += " WHERE CNA_FILIAL = ? "
		cQuery += " AND CNA_CONTRA  =  ? "
		cQuery += " AND CNA_REVISA = ? "
		cQuery += " AND CNA_RATEIO = '1' "
		cQuery += " AND CNA_PLAORI = ? "


		cQuery += " AND D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY CNA_FILIAL, CNA_CONTRA, CNA_REVISA, CNA_PLAORI, CNA_TIPPLA, CNA_RATEIO,CNA_PERIOD,CNA_PERREC,CNA_QTDREC,CNA_DIASEM,CNA_DTINI,CNA_DTFIM,CNA_PROMED "
		cQuery += " ORDER BY CNA_PLAORI "

		oPrepCNA := FWPreparedStatement():New(ChangeQuery( cQuery ) )
		oPrepCNA:SetString(1, xFilial( 'CNA' ) )
		oPrepCNA:SetString(2, oModel:GetValue( "CN9MASTER" , "CN9_NUMERO" ) )
		oPrepCNA:SetString(3, oModel:GetValue( "CN9MASTER" , "CN9_REVISA" ) )
		oPrepCNA:SetString(4, _oModelCTR:GetValue( "CNADETAIL" , "CNA_PLAORI" ) )
		
		cAliasCNA := MPSysOpenQuery( oPrepCNA:getFixQuery() )

		TCSetField(cAliasCNA, "CNA_DTINI", "D",GetSx3Cache( 'CNA_DTINI', 'X3_TAMANHO' ),GetSx3Cache( 'CNA_DTINI', 'X3_DECIMAL' ))
		TCSetField(cAliasCNA, "CNA_DTFIM", "D",GetSx3Cache( 'CNA_DTFIM', 'X3_TAMANHO' ),GetSx3Cache( 'CNA_DTFIM', 'X3_DECIMAL' ))
		TCSetField(cAliasCNA, "CNA_PROMED", "D",GetSx3Cache( 'CNA_PROMED', 'X3_TAMANHO' ),GetSx3Cache( 'CNA_PROMED', 'X3_DECIMAL' ))

		aRet := FWLoadByAlias(oModelCNA, cAliasCNA  , 'CNA' )

		( cAliasCNA )->(DbCloseArea() )
	Endif

	RestArea( aArea )
	FWRestRows( aSaveLines )
	FwFreeArray( aArea )
	FwFreeArray( aSaveLines )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} loadCXS
	Realiza a query para carregar os dados na Grid CXSDETAIL no CNTA340

@param oModelCXS, object, modelo da CXS

@return array, Retorna os registros da CXS no modelo da CNTA340
@author ivan.magno
@since 26/04/2024
/*/
//-------------------------------------------------------------------
Static Function LoadCXS( oModelCXS )
	Local aArea	:= GetArea()
	Local cAliasCXS := ""
	Local aRet := {}
	Local aSaveLines := FWSaveRows()
	Local oModel := oModelCXS:GetModel()	
	Local oPrepCXS
	Local oModelCXT := _oModelCTR:GetModel( "CXTDETAIL")

	If !oModelCXT:IsUpdated()
		cQuery := " SELECT CXS_FILIAL, CXS_CONTRA, CXS_REVISA, CXS_PLAORI CXS_NUMPLA, CXS_ITEM, CXS_PRODUT, CXS_VLTOT,CXS_SLDMED "
		cQuery += " FROM " + RetSqlName( "CXS" ) + " CXS "
		cQuery += " WHERE CXS_FILIAL = ? "
		cQuery += " AND CXS_CONTRA  =  ? "
		cQuery += " AND CXS_REVISA = ? "
		cQuery += " AND CXS_PLAORI = ? "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY CXS_FILIAL, CXS_CONTRA, CXS_REVISA, CXS_PLAORI, CXS_ITEM, CXS_PRODUT, CXS_VLTOT, CXS_SLDMED "
		cQuery += " ORDER BY CXS_ITEM "

		oPrepCXS := FWPreparedStatement():New(ChangeQuery( cQuery ) )
		oPrepCXS:SetString(1, oModel:GetValue( "CNADETAIL" , "CNA_FILIAL" ) )
		oPrepCXS:SetString(2, oModel:GetValue( "CN9MASTER" , "CN9_NUMERO" ) )
		oPrepCXS:SetString(3, oModel:GetValue( "CN9MASTER" , "CN9_REVISA" ) )
		oPrepCXS:SetString(4, oModel:GetValue( "CNADETAIL" , "CNA_NUMERO" ) )

		cAliasCXS := MPSysOpenQuery( oPrepCXS:getFixQuery(), "CXSTEMP" )

		aRet := FWLoadByAlias(oModelCXS, cAliasCXS  , 'CXS' )

		(cAliasCXS)->(DbCloseArea() )
	Endif	

	RestArea( aArea )
	FWRestRows( aSaveLines )
	FwFreeArray( aArea )
	FwFreeArray( aSaveLines )

return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} loadCXT
	Realiza a query para carregar os dados na grid do CXTDETAIL

@param oModelCXT, object, modelo da CXT

@return array, Retorna os registros da CXT no modelo da CNTA340
@author ivan.magno
@since 26/04/2024
/*/
//-------------------------------------------------------------------
Static Function LoadCXT( oModelCXT )
	Local aArea	:= GetArea()
	Local cAliasCXT := ""
	Local aRet := {}
	Local aSaveLines := FWSaveRows()
	Local oModel := oModelCXT:GetModel()
	Local oModelCXS := _oModelCTR:GetModel( "CXSDETAIL")
	Local oPrepCXT

	If !oModelCXS:IsUpdated()
		cQuery := " SELECT CXT_FILIAL,CXT_CONTRA,CXT_REVISA,CXT_PLAORI CXT_NUMPLA ,CXT_ITEM,CXT_FORNEC,CXT_LOJA,CXT_CLIENT,CXT_LOJACL,CXT_PERC, CXT_VALOR "
		cQuery += " FROM " + RetSqlName( "CXT" ) + " CXT "
		cQuery += " WHERE CXT_FILIAL = ? "
		cQuery += " AND CXT_CONTRA  =  ? "
		cQuery += " AND CXT_REVISA = ? "
		cQuery += " AND CXT_PLAORI = ? "
		cQuery += " AND CXT_ITEM = ? "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY CXT_FILIAL, CXT_CONTRA, CXT_REVISA, CXT_PLAORI , CXT_ITEM, CXT_FORNEC, CXT_LOJA, CXT_CLIENT, CXT_LOJACL, CXT_PERC, CXT_VALOR "
		cQuery += " ORDER BY CXT_ITEM "

		oPrepCXT := FWPreparedStatement():New(ChangeQuery( cQuery ) )
		oPrepCXT:SetString(1, oModel:GetValue( "CXSDETAIL" , "CXS_FILIAL" ) )
		oPrepCXT:SetString(2, oModel:GetValue( "CN9MASTER" , "CN9_NUMERO" ) )
		oPrepCXT:SetString(3, oModel:GetValue( "CN9MASTER" , "CN9_REVISA" ) )
		oPrepCXT:SetString(4, oModel:GetValue( "CXSDETAIL" , "CXS_NUMPLA" ) )
		oPrepCXT:SetString(5, oModel:GetValue( "CXSDETAIL" , "CXS_ITEM"   ) )

		cAliasCXT := MPSysOpenQuery( oPrepCXT:getFixQuery(), "CXTTEMP" )		

		aRet := FWLoadByAlias( oModelCXT , cAliasCXT  , 'CXT' )

		( cAliasCXT )->( DbCloseArea() )
	Endif	
	
	RestArea( aArea )	
	FWRestRows( aSaveLines )
	FwFreeArray( aArea )
	FwFreeArray( aSaveLines )
	
return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN340PRODU
	Função executada no modelo do CNTA340 para retornar a descrição dos produtos
	quando chamado o SetForceLoad

@return cDesc, retorna a descrição dos produtos
@author ivan.magno
@since 26/04/2024
/*/
//-------------------------------------------------------------------

Function CN340PRODU()
	Local aArea := GetArea()	
	Local oModel := FWModelActive()
	Local cDesc := ""

	If FwIsInCallStack("LoadCXS")

		If oModel:GetId() == "CNTA340" .AND. !( oModel:GetOperation() == MODEL_OPERATION_INSERT )
			cDesc := Posicione( "SB1", 1, xFilial("SB1") + CXSTEMP->CXS_PRODUT , "B1_DESC" )
		Endif
	Endif

	RestArea( aArea )
	FwFreeArray( aArea )

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} CN340Name
	Função executada no modelo do CNTA340 para retornar
	o nome do fornecedor/cliente quando chamado o SetForceLoad

@return cName, retorna o nome do fornecedor/cliente
@author ivan.magno
@since 26/04/2024
/*/
//-------------------------------------------------------------------

Function CN340Name()
	Local aArea := GetArea()
	Local oModel := FWModelActive()	
	Local cName := ""

	If FwIsInCallStack("LoadCXT")

		If oModel:GetId() == "CNTA340" .And. !(oModel:GetOperation() == MODEL_OPERATION_INSERT )

			If  CNTGetFun() == 'CNTA301'
				cName:= Posicione( "SA1", 1, xFilial( "SA1" ) + CXTTEMP->( CXT_CLIENT+CXT_LOJACL ), "A1_NOME" )
			Else		
				cName:= Posicione( "SA2", 1, xFilial( "SA2" ) + CXTTEMP->( CXT_FORNEC+CXT_LOJA ), "A2_NOME" )
			Endif

		Endif
	Endif

	RestArea( aArea )
	FwFreeArray( aArea )

Return cName

//-------------------------------------------------------------------
/*/{Protheus.doc} RetGrid
	Realiza o retorno dos dados do CNTA300/301 no CNTA340 antes de salvar no banco

@param oModel, object, modelo ativo do CNTA340

@return lRet, Retorna .T. após realizar a carga dos dados
@author ivan.magno
@since 29/04/2024
/*/
//-------------------------------------------------------------------
Static Function RetGrid( oModel )
	Local aArea     := GetArea()
    Local lRet   	:= .T.
	Local aSaveLines := {}
   	Local oCNARet	 := oModel:GetModel( 'CNADETAIL' )
	Local oCXSRet	 := oModel:GetModel( 'CXSDETAIL' )
	Local oCXTRet	 := oModel:GetModel( 'CXTDETAIL' )
    Local oModelCNA  := _oModelCTR:GetModel( 'CNADETAIL' )
	Local oModelCXS  := _oModelCTR:GetModel( 'CXSDETAIL' )
	Local oModelCXT  := _oModelCTR:GetModel( 'CXTDETAIL' )
	Local nX     	 := 0
	Local nY     	 := 0
	Local nZ     	 := 0
	Local cCode := 'CXT_FORNEC'
	Local cStore := 'CXT_LOJA'
	Local cCNACode := 'CNA_FORNEC'
	Local cCNAStore := 'CNA_LJFORN'
	Local nItPla := GetSx3Cache( 'CNA_NUMERO', 'X3_TAMANHO' )
	Local cPlaOri := ""

	If CNTGetFun() == 'CNTA301'
		cCode := 'CXT_CLIENT'
		cStore := 'CXT_LOJACL'
		cCNACode := 'CNA_CLIENT'
		cCNAStore := 'CNA_LOJACL'
	EndIf

    If oModelCXS:IsUpdated() .and. oModelCXT:IsUpdated()

		oCNARet:ClearData( .T. , .T. )
		oCNARet:LoadValue( 'CNA_NUMERO' , StrZero(1, nItPla ) )

		aSaveLines := FWSaveRows()

		//Armazena a Planilha de origem
		cPlaOri := oModelCNA:GetValue( 'CNA_PLAORI' )

        For nX := 1 to oModelCNA:Length()
			oModelCNA:Goline( nX )
			If !oModelCNA:IsDeleted() .AND. cPlaOri == oModelCNA:GetValue( 'CNA_PLAORI' )
				For nY := 1 to oModelCXS:Length()
					oModelCXS:Goline( nY )
					If !oModelCXS:IsDeleted()
						For nZ := 1 to oModelCXT:Length()
							oModelCXT:GoLine( nZ )
							If !oModelCXT:IsDeleted()
								If !( oCNARet:SeekLine( { { 'CNA_PLAORI', oModelCNA:GetValue( 'CNA_PLAORI' ) } ,;
														  { 'CNA_TIPPLA',  oModelCNA:GetValue( 'CNA_TIPPLA' ) } ,;
														  { 'CNA_RATEIO', "1"								  } } ) )				

									oCNARet:LoadValue( 'CNA_PLAORI'	, oModelCNA:GetValue( 'CNA_PLAORI' ) )
									oCNARet:LoadValue( 'CNA_PERIOD' , oModelCNA:GetValue( "CNA_PERIOD"))
									oCNARet:LoadValue( 'CNA_PERREC' , oModelCNA:GetValue( "CNA_PERREC"))
									oCNARet:LoadValue( 'CNA_QTDREC' , oModelCNA:GetValue( "CNA_QTDREC"))
									oCNARet:LoadValue( 'CNA_DIASEM' , oModelCNA:GetValue( "CNA_DIASEM"))
									oCNARet:LoadValue( 'CNA_DTINI ' , oModelCNA:GetValue( "CNA_DTINI "))
									oCNARet:LoadValue( 'CNA_DTFIM ' , oModelCNA:GetValue( "CNA_DTFIM "))
									oCNARet:LoadValue( 'CNA_PROMED' , oModelCNA:GetValue( "CNA_PROMED"))									
									oCNARet:SetValue( 'CNA_TIPPLA'	, oModelCNA:GetValue( 'CNA_TIPPLA' ) )
									oCNARet:SetValue( 'CNA_RATEIO'	, '1' 								)
									
								Endif

								If !( oCXSRet:SeekLine( { { 'CXS_ITEM' , oModelCXS:GetValue( 'CXS_ITEM' )    } ,;
														  {'CXS_PRODUT', oModelCXS:GetValue( 'CXS_PRODUT' ) } } ) )

									If !( Empty(  oCXSRet:GetValue('CXS_ITEM' ) ) ) .AND. !( Empty(Alltrim(oCXSRet:GetValue('CXS_PRODUT' ) ) ) )
										oCXSRet:AddLine()
									Endif
									oCXSRet:Loadvalue( 'CXS_ITEM'  , oModelCXS:Getvalue( 'CXS_ITEM') )
									oCXSRet:SetValue( 'CXS_PRODUT', oModelCXS:Getvalue( 'CXS_PRODUT' ) )
									oCXSRet:LoadValue( 'CXS_VLTOT' , oModelCXS:Getvalue( 'CXS_VLTOT' ) )
									oCXSRet:LoadValue( 'CXS_SLDMED', oModelCXS:GetValue( 'CXS_SLDMED' ))								
				
								Endif

									If !( Empty(alltrim( oCXTRet:GetValue( 'CXT_ITEM' ) ) ) )
										oCXTRet:AddLine()
									Endif

									oCXTRet:SetValue( cCode	   , oModelCNA:Getvalue( cCNACode ) )
									oCXTRet:SetValue( cStore      , oModelCNA:Getvalue( cCNAStore ) )
									oCXTRet:SetValue( 'CXT_PERC'  , oModelCXT:Getvalue( 'CXT_PERC' ) )
									oCXTRet:Loadvalue( 'CXT_VALOR' , oModelCXT:Getvalue( 'CXT_VALOR' ) )
									oCXTRet:Loadvalue( 'CXT_ITEM'  , oModelCXS:GetValue( 'CXS_ITEM' ) )
									oCXTRet:Loadvalue( 'CXT_PLAORI', oModelCXS:GetValue( 'CXS_PLAORI' ) )

							Endif
						Next nZ
					Endif
				Next nY
			Endif
		Next nX
		FWRestRows( aSaveLines )
	Endif

	RestArea( aArea )
	FwFreeArray( aArea )
	FwFreeArray( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetGridGs
	Realiza o carregamento dos dados do CNTA300/301 no CNTA340 quando não tiver planilha de origem

@param oModel, object, modelo ativo do CNTA340

@return lRet, Retorna .T. após realizar a carga dos dados
@author ivan.magno
@since 17/06/2024
/*/
//-------------------------------------------------------------------
Static Function RetGridGs( oModel )

	Local aArea     := GetArea()
	Local aSaveLines := FWSaveRows()
	Local oCNARet	 := oModel:GetModel( 'CNADETAIL' )
	Local oCXSRet	 := oModel:GetModel( 'CXSDETAIL' )
	Local oCXTRet	 := oModel:GetModel( 'CXTDETAIL' )
	Local oModelCNA  := _oModelCTR:GetModel( 'CNADETAIL' )
	Local oModelCNB	 := _oModelCTR:GetModel( 'CNBDETAIL' )
	Local oModelCXS  := _oModelCTR:GetModel( 'CXSDETAIL' )
	Local oModelCXT  := _oModelCTR:GetModel( 'CXTDETAIL' )
	Local nOper       := oModel:GetOperation()
	Local nX     	 := 0
	Local cCode := 'CXT_FORNEC'
	Local cStore := 'CXT_LOJA'
	Local cCNACode := 'CNA_FORNEC'
	Local cCNAStore := 'CNA_LJFORN'
	Local nLine := 0

	If CNTGetFun() == 'CNTA301'
		cCode := 'CXT_CLIENT'
		cStore := 'CXT_LOJACL'
		cCNACode := 'CNA_CLIENT'
		cCNAStore := 'CNA_LOJACL'
	EndIf

    If (nOper == MODEL_OPERATION_INSERT .OR. nOper == MODEL_OPERATION_UPDATE) .and. !oModelCXS:IsUpdated() .and. !oModelCXT:IsUpdated()

		nLine := oModelCNA:GetLine()
		oModelCNA:Goline( nLine )

		oModelCNA:LoadValue( "CNA_PLAORI", oModelCNA:GetValue( "CNA_NUMERO" ) )
		oModelCNA:LoadValue( "CNA_RATEIO", "1" )

		If !oModelCNA:IsDeleted() .AND. !Empty(oModelCNA:GetValue( cCNACode ) )
			For nX := 1 to oModelCNB:Length()
				oModelCNB:Goline( nX )
				If !oModelCNB:IsDeleted()
					If !( oCNARet:SeekLine( { { 'CNA_PLAORI', oModelCNA:GetValue( 'CNA_PLAORI' ) } ,;
											{'CNA_TIPPLA',  oModelCNA:GetValue( 'CNA_TIPPLA' ) } } ) )												
		
						oCNARet:LoadValue( 'CNA_PLAORI', oModelCNA:GetValue('CNA_NUMERO') )
						oCNARet:SetValue( 'CNA_TIPPLA', oModelCNA:GetValue( 'CNA_TIPPLA' ) )
						oCNARet:LoadValue( 'CNA_PERIOD', oModelCNA:GetValue( "CNA_PERIOD"))
						oCNARet:LoadValue( 'CNA_PERREC', oModelCNA:GetValue( "CNA_PERREC"))
						oCNARet:LoadValue( 'CNA_QTDREC', oModelCNA:GetValue( "CNA_QTDREC") - oModelCNA:GetValue( "CNA_MEDEFE"))
						oCNARet:LoadValue( 'CNA_DIASEM', oModelCNA:GetValue( "CNA_DIASEM"))
						oCNARet:LoadValue( 'CNA_PROMED', oModelCNA:GetValue( "CNA_PROMED"))
						oCNARet:LoadValue( 'CNA_DTINI ', oModelCNA:GetValue( "CNA_DTINI "))
						oCNARet:LoadValue( 'CNA_DTFIM ', oModelCNA:GetValue( "CNA_DTFIM "))
					Endif

					If !( oCXSRet:SeekLine( { { 'CXS_ITEM' , oModelCNB:GetValue( 'CNB_ITEM' )    } ,;
											{'CXS_PRODUT', oModelCNB:GetValue( 'CNB_PRODUT' ) } } ) )

						If !( Empty(  oCXSRet:GetValue( 'CXS_ITEM' ) ) ) .AND. !( Empty(Alltrim(oCXSRet:GetValue('CXS_PRODUT' ) ) ) )
							oCXSRet:AddLine()
						Endif
						oCXSRet:Loadvalue( 'CXS_ITEM'  , oModelCNB:Getvalue( 'CNB_ITEM') )
						oCXSRet:SetValue( 'CXS_PRODUT', oModelCNB:Getvalue( 'CNB_PRODUT' ) )
						oCXSRet:LoadValue( 'CXS_SLDMED', oModelCNB:Getvalue( 'CNB_SLDMED' ) )
						oCXSRet:SetValue( 'CXS_VLTOT' , oModelCNB:Getvalue( 'CNB_VLUNIT' ) )

					Endif

					oCXTRet:SetValue( cCode	   , oModelCNA:Getvalue( cCNACode ) )
					oCXTRet:SetValue( cStore      , oModelCNA:Getvalue( cCNAStore ) )
					oCXTRet:SetValue( 'CXT_PERC'  , 100 )
					oCXTRet:Loadvalue( 'CXT_ITEM'  , oModelCNB:GetValue( 'CNB_ITEM' ) )
					oCXTRet:Loadvalue( 'CXT_PLAORI', oModelCNA:GetValue( 'CNA_PLAORI' ) )

				Endif
			Next
		Endif

		//Limpa novamente os campos abaixo	
		oModelCNA:LoadValue( "CNA_PLAORI", "" )
		oModelCNA:LoadValue( "CNA_RATEIO", "2")
		
	Endif

	If FindFunction("TecOnlyVw") .AND. FunName() $ "TECA850*TECA870*TECA745"	
		TecOnlyVw( oModel )
	EndIf

	RestArea( aArea )
	FWRestRows( aSaveLines )
	FwFreeArray( aArea )
	FwFreeArray( aSaveLines )
Return

/*/{Protheus.doc} PreLinCXT
	Realiza a pre-validacao dos dados do modelo CXT
	@type Static Function
	@author Anderson F. Gomes
	@since 13/05/2025
	@version 12.1.2310
	@param oModelCXT , Object, Modelo CXT
	@param nLin , Numeric, Linha posicionada
	@param cAction , Character, Acao executada
	@param cField , Character, Campo de origem da acao
	@param xOldValue , Vardic, valor Anterior do Campo
	@param xNewValue , Vardic, Novo Valor do Campo
	@return lRet, logical, .T. Acao valida
/*/
Static Function PreLinCXT( oModelCXT, nLin, cAction, cField, xOldValue, xNewValue ) As Logical
	Local lRet As logical
	Local lGS As Logical
	Local oMdl300 As Object
	Local oMdlCNA As Object
	Local oMdl340 As Object
	Local o340CNA As Object
	Local oMdlCXS As Object
	Local nLineBKP As Numeric
	Local nCXTVal As Numeric
	Local nVlMin As Numeric
	Local nDecimal As Numeric

	lRet := .T.
	lGS := FunName() $ "TECA850*TECA870*TECA745"
	nLineBKP := 1

	If lGS
		If cAction == "DELETE" .Or. ( cAction == "CANSETVALUE" .And. cField $ "CXT_CLIENT|CXT_LOJACL" )
			oMdl300 := _oModelCTR:getmodel()
			oMdlCNA := oMdl300:GetModel("CNADETAIL")
			oMdl340 := oModelCXT:GetModel()
			o340CNA := oMdl340:GetModel("CNADETAIL")
			nLineBKP := oMdlCNA:GetLine()

			If oMdlCNA:SeekLine( { { 'CNA_NUMERO', o340CNA:GetValue( "CNA_PLAORI" ) } } )
				If oMdlCNA:GetValue("CNA_CLIENT") == oModelCXT:GetValue("CXT_CLIENT")
					lRet := .F.
					Help(" ",1,"PreLinCXT",, STR0024 , 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0025 } )
				EndIf
			EndiF
			oMdlCNA:goline(nLineBKP)
		EndIf
		If !IsInCallStack("cn340activ") .And. cAction == "SETVALUE" .And. cField $ "CXT_PERC"
			oMdl340 := oModelCXT:GetModel()
			oMdlCXS := oMdl340:GetModel( "CXSDETAIL" )

			nCXTVal := ( oMdlCXS:GetValue( "CXS_VLTOT" ) * xNewValue ) / 100

			nDecimal := GetSx3Cache( "CXT_VALOR" , "X3_DECIMAL" )

			nVlMin := 1/(10^nDecimal) //Valor mínimo de acordo com o decimal

			//Verifica se o Valor novo Excede o minimo permitido para o campo de acordo com seu decimal:
			If nVlMin > nCXTVal
				lRet := .F.
				Help(" ",1,"PreLinCXT",, STR0026 +cValToChar(nCXTVal)+ STR0027 + cValToChar(nVlMin) , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0028} )
			EndIf
		EndIf
	EndIf

Return lRet
