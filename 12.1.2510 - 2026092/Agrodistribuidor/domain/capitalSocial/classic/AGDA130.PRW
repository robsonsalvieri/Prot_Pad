#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "AGDA130.ch"

/*/{Protheus.doc} AGDA130
Rotina para registrar abertura de conta de cotas e valores cooperado
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Function AGDA130()
	Local oMBrowse := Nil

	If .Not. TableInDic('NF3')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NF3" )
	oMBrowse:SetDescription( STR0001  )  //"Conta de Cotas e Valores Cooperado"
	oMBrowse:DisableDetails()
	oMBrowse:AddLegend("NF3_STATUS=='1'","GREEN"  ,X3Combo( "NF3_STATUS", "1" ))
	oMBrowse:AddLegend("NF3_STATUS=='2'","RED"    ,X3Combo( "NF3_STATUS", "2" ))
	oMBrowse:AddLegend("NF3_STATUS=='3'","YELLOW" ,X3Combo( "NF3_STATUS", "3" ))

	if hasSmartX()
		oMBrowse:setSmartX()
	endIf
	oMBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Menu
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Static Function MenuDef()
Return AGDA130MNU()

/*/{Protheus.doc} ModelDef
Model do AGDA130
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNF3  := FwFormStruct( 1, "NF3" )
	Local oEvent     := AGDA130EVT():New()

	oModel := MpFormModel():New( "AGDA130" )
	oModel:SetDescription(  STR0001 )  //"Conta de Cotas e Valores Cooperado"


	//campo apenas no modelo de dados para controle interno do sistema, não será exibido na tela, e não consta no diconario(SX3)
	oStruNF3:AddField( ;
		STR0014 , ;						// [01] C Titulo do campo #'Gera Automát.'
	STR0015 , ;							// [02] C ToolTip do campo #"Gera automatizado"
	'TMP_GERAUT' , ;               		// [03] C identificador (ID) do Field
	'C' , ;                    			// [04] C Tipo do campo
	1 , ;                       		// [05] N Tamanho do campo
	0 , ;                       		// [06] N Decimal do campo
	{|| .T.} , ;      					// [07] B Code-block de validação do campo
	NIL , ;                     		// [08] B Code-block de validação When do campo
	{'1=Sim','2=Não'} , ;				// [09] A Lista de valores permitido do campo
	NIL , ;                     		// [10] L Indica se o campo tem preenchimento obrigatório
	{||'2'} , ;           				// [11] B Code-block de inicializacao do campo
	NIL , ;                     		// [12] L Indica se trata de um campo chave
	NIL , ;                     		// [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       		// [14] L Indica se o campo é virtual

	oStruNF3:SetProperty('NF3_MATCOO', MODEL_FIELD_WHEN,{|| .F. }) //garantir que campo não seja editável, pois o mesmo é preenchido automaticamente pelo sistema

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA130_NF3", , oStruNF3)
	oModel:GetModel( "AGDA130_NF3" ):SetDescription(  STR0001 )  //"Conta de Cotas e Valores Cooperado"
	oModel:SetPrimaryKey( { "NF3_FILIAL", "NF3_CODCOO", "NF3_LOJCOO" } )

	oModel:InstallEvent("AGDA130EVT", /*cOwner*/, oEvent)

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao do Model
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Static Function ViewDef()
	Local oModel	:= FwLoadModel( "AGDA130" )
	Local oStruNF3  := FwFormStruct( 2, "NF3" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oStruNF3:RemoveField( "NF3_DATCAD" )
	oStruNF3:RemoveField( "NF3_STATUS" )

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NF3', oStruNF3, 'AGDA130_NF3' )

	oView:CreateHorizontalBox( 'CABEC', 100 )
	oView:SetOwnerView( 'VIEW_NF3', 'CABEC' )
	oView:EnableTitleView("VIEW_NF3")
	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} AGDA130COT
Realiza cálculo do Valor Total do Capital Social ou Quantidade de Cotas pelo valor da cota definido via parâmetro
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@param cTipo, Character, indica tipo de calculo a ser efetuado
@param nValor, numeric, valor a ser efetuado calculo
@return numeric, valor calculado pelo valor da cota
/*/
Function AGDA130COT()
	Local cReadVar   := ReadVar()
	Local oModel    := FwModelActive()
	Local oNF3       := oModel:GetModel("AGDA130_NF3")

	Local nValorCota := SuperGetMV( "MV_AGD0011",.F., 0 )
	Local nResultado := 0

	If "NF3_QTDCOT" $ cReadVar .and. !Empty(M->NF3_QTDCOT)
		nResultado := M->NF3_QTDCOT * nValorCota
	elseIf "NF3_VALCOT" $ cReadVar .and. !Empty(M->NF3_VALCOT)
		nResultado    := int(M->NF3_VALCOT / nValorCota)
		oNF3:loadValue("NF3_VALCOT", nResultado * nValorCota, .T.)
	Endif

Return nResultado


/*/{Protheus.doc} AGD130VTPM
Validação para o campo NF3_TPOPER via dicionario(SX3) 
@type function
@version 12
@author claudineia.reinert
@since 15/07/2026
@return Logical, .T. se o campo for válido, .F. caso contrário
/*/
Function AGD130VTPM()
	If !Empty(M->NF3_TPOPER)
		dbSelectArea("NF5")
		NF5->(dbSetOrder(1)) //NF5_FILIAL+NF5_CODIGO
		If NF5->(dbSeek(xFilial("NF5")+M->NF3_TPOPER))
			If Type("M->TMP_GERAUT")== "C" .and. M->TMP_GERAUT == "1" //gera automatizado via outra rotina, aceitará qualquer tipo de movimentação
				return .T.
			elseIf !(NF5->NF5_TIPO $ "23")
				AGDHELP( STR0002 , STR0016, STR0017 + AllTrim(X3CboxDesc( "NF5_TIPO", "2" )) + '/' + AllTrim(X3CboxDesc( "NF5_TIPO", "3" )))  //"Tipo de movimentação inválido para abertura de nova conta de cooperado." //"Informe uma movimentação do tipo "
				Return .F.
			Endif
		Else
			Return .F. //código informado não existe na NF5
		EndIf
	EndIf
Return .T.


/*/{Protheus.doc} AGDA130VLD
Validação de campo NF3 via dicionario SX3
@type function
@version 12
@author claudineia.reinert
@since 03/08/2026
@return Logical, .T. se o campo for válido, .F. caso contrário
/*/
Function AGDA130VLD()
	Local lRet 		:= .T.
	Local cReadVar  := ReadVar()
	Local oModel    := FwModelActive()

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .and. ("NF3_CODCOO" $ cReadVar  .OR. "NF3_LOJCOO" $ cReadVar )
		cCodCoop := M->NF3_CODCOO
		cLojCoop := IIF(!Empty(M->NF3_LOJCOO), M->NF3_LOJCOO, "")
		dbSelectArea("NEP")
		NEP->(dbSetOrder(1))
		IF !(NEP->(DBSeek(FWxFilial("NEP") + cCodCoop + cLojCoop))) .or. (NEP->(NEP_CODCLI+NEP_LOJCLI) == (cCodCoop + cLojCoop) .and. (NEP->NEP_COOPER <> "1" .or. Empty(NEP->NEP_MATRIC)))
			lRet := .F.
			AGDHELP(STR0006, STR0009)//"Cooperado não cadastrado."
		EndIf
	Endif

Return lRet
