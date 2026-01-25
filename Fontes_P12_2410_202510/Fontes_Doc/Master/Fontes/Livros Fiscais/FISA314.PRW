#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FISA314.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA314
Cadastro MVC para atender o Cadastro de forma de pagamento por regime

@author Matheus Massarotto_
@since 04/10/2023
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA314()
	Local	oBrw	:= FWmBrowse():New()

	oBrw:SetDescription( STR0001 ) //Cadastro de forma de pagamento por regime
	oBrw:SetAlias( 'CJS')
	oBrw:SetMenuDef( 'FISA314' )

	oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Matheus Massarotto
@since 04/10/2023
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return FWMVCMenu( "FISA314" )
//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Matheus Massarotto
@since 04/10/2023
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()
	Local oStruCJS := Nil
	Local oModel   := Nil
	Local oMontQry := Nil
	Local bPost		:= {|oModel, oMontQry|FSA314VLDA(oModel, oMontQry)}

	oStruCJS := FWFormStruct( 1, 'CJS' )// Cria a estrutura a ser usada no Modelo de Dados
	oModel   := MPFormModel():New('FISA314',,bPost,)

// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'MODEL_CJS', /*cOwner*/, oStruCJS)
	oModel:GetModel( 'MODEL_CJS' ):SetPrimaryKey( { 'CJS_FILIAL' , 'CJS_FORMA', 'CJS_REGIME'} )

	oStruCJS:SetProperty('CJS_FORMA' , MODEL_FIELD_VALID , {|| ValidCpo("CJS_FORMA") })

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Matheus Massarotto
@since 04/10/2023
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel	:= FWLoadModel( 'FISA314' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStruCJS	:= FWFormStruct( 2, 'CJS' )// Cria a estrutura a ser usada na View
	Local oView		:= FWFormView():New()

	oView:SetModel( oModel )

	oView:AddField( 'VIEW_CJS', oStruCJS, 'MODEL_CJS' )

	oView:EnableTitleView( 'VIEW_CJS',  STR0001 ) //Cadastro de forma de pagamento por regime

	oView:CreateHorizontalBox( 'FIELDSCJS', 100 )

	oView:SetOwnerView( 'VIEW_CJS', 'FIELDSCJS' )

Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCpo
Validação de campos.

@author Delleon Fernandes
@since 14/11/2023
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function ValidCpo(cCampo)

	Local aArea       := GetArea()
	Local lRet        := .T.
	Local oModel      := FWModelActive()
	Local cCJS_FORMA  as Char

	If cCampo $ "CJS_FORMA"
		cCJS_FORMA  := oModel:GetValue('MODEL_CJS', "CJS_FORMA" )

		lRet := Len(FWGetSX5( "24", cCJS_FORMA )) > 0

		If lRet
			CJS->(DbSetOrder(1))
			If CJS->(DbSeek(xFilial("CJS") + cCJS_FORMA))
				lRet := .F.
				oModel:SetErrorMessage('FISA314', cCampo, 'FISA314', cCampo, "Erro", STR0002, STR0003) // "Forma de pagamento já existente.", "Não é permitido a mesma forma de pagamento para mais de um regime."
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} FSA314VLDA
Valida para não permitir exclusão de forma de pagamento que está utilizada em alguma importação.

@author Delleon Fernandes
@since 18/01/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Function FSA314VLDA(oModel, oMontQry)

	Local nOperation := oModel:GetOperation()
	Local lRet		 := .T.
	Local cForma     := ""
	Local cRegime    := ""
	
	If nOperation == MODEL_OPERATION_DELETE .Or. nOperation == MODEL_OPERATION_UPDATE
		cForma  := oModel:GetValue('MODEL_CJS',"CJS_FORMA")

		lRet := QryVlda(CJS->CJS_FORMA, oMontQry)

		If nOperation == MODEL_OPERATION_DELETE .And. !lRet
			oModel:SetErrorMessage('FISA314', "CJS_FORMA", 'FISA314', "CJS_FORMA", , STR0004, STR0005) // "Não é possível excluir.", "O registro está sendo utilizado por alguma importação realizada."
		ElseIf nOperation == MODEL_OPERATION_UPDATE
			cRegime := oModel:GetValue('MODEL_CJS',"CJS_REGIME")
			If !lRet .And. (CJS->CJS_FORMA <> cForma .Or. CJS->CJS_REGIME <> cRegime )
				oModel:SetErrorMessage('FISA314', "CJS_FORMA", 'FISA314', "CJS_FORMA", , STR0006, STR0005) // 'Não é possível alterar esta forma de pagamento.', 'O registro está sendo utilizado por alguma importação realizada.'
			Else
				lRet := .T.
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QryVlda
Query para verificar se existe alguma importação com a forma de pagamento informada.

@author Delleon Fernandes
@since 18/01/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function QryVlda(cFORMA, oMontQry)
	Local cQuery     := ""
	Local cAliascTMP := GetNextAlias()
	Local lRet       := .T.

	If oMontQry == Nil

		cQuery += " SELECT COUNT(CJR_TIPO) AS QTDE"
		cQuery += " FROM ? "
		cQuery += " WHERE CJR_FILIAL = ? "
		cQuery += "		AND CJR_FORMA = ? "
		cQuery += "     AND D_E_L_E_T_= ? "

		oMontQry := FWPreparedStatement():New( ChangeQuery(cQuery) )
	EndIf

	oMontQry:SetUnsafe(1, RetSqlName("CJR"))
	oMontQry:SetString(2, xFilial("CJR"))
	oMontQry:SetString(3, cFORMA)
	oMontQry:SetString(4, " ")

	MPSysOpenQuery(oMontQry:GetFixQuery(), cAliascTMP)

	lRet := !((cAliascTMP)->(!Eof()) .And. (cAliascTMP)->QTDE > 0)
	
	(cAliascTMP)->(DbCloseArea())

Return lRet
