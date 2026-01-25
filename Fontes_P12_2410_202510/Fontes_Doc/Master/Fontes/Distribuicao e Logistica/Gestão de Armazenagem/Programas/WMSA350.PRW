#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'WMSA350.CH'

//----------------------------------------------------------
/*/{Protheus.doc} WMSA350 - Regras para Convocação WMS

@author  Guilherme Alexandre Metzger
@version P11
@since   24/02/15
/*/
//----------------------------------------------------------
Function WMSA350()
Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('DCQ')         //Alias da tabela utilizada
	oBrowse:SetDescription(STR0001) //Descrição do browse "Regras para Convocação WMS"
	oBrowse:SetMenuDef('WMSA350')   //Nome do fonte onde esta a função MenuDef
	oBrowse:SetAmbiente(.F.)        //Desabilita opção Ambiente do menu Ações Relacionadas
	oBrowse:SetWalkThru(.F.)        //Desabilita opção WalkThru do menu Ações Relacionadas

	// Adiciona as legendas do browse
	oBrowse:AddLegend("DCQ_STATUS=='1'", 'GREEN', STR0008) // Ativo
	oBrowse:AddLegend("DCQ_STATUS=='2'", 'RED'  , STR0009) // Inativo


	oBrowse:Activate()
Return

//----------------------------------------------------------
// Função MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0011 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA350' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA350' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA350' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.WMSA350' OPERATION 5 ACCESS 0 // Excluir

	// Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock('WMS350MNU')
		ExecBlock('WMS350MNU',.F.,.F.)
	EndIf
Return aRotina

//----------------------------------------------------------
// Função ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel   := MPFormModel():New('WMSA350',{ |oModel| PreVldMdl(oModel) },{ |oModel| PosVldMdl(oModel) })
Local oStruDCQ := FWFormStruct(1, 'DCQ')
Local oStruD1R := Nil

	oModel:AddFields('DCQMASTER', /*cOwner*/, oStruDCQ)
	oModel:SetPrimaryKey({'DCQ_FILIAL','DCQ_TPREGR','DCQ_STATUS','DCQ_LOCAL','DCQ_CODFUN','DCQ_CODZON','DCQ_SERVIC','DCQ_TAREFA','DCQ_ATIVID'})
	If AliasIndic("D1R")
	    oStruD1R := FWFormStruct(1,'D1R')
		oModel:AddGrid('D1RDETAIL', 'DCQMASTER', oStruD1R)
		// Criação de relação entre as entidades do modelo
		oModel:SetRelation('D1RDETAIL', { { 'D1R_FILIAL', 'xFilial( "D1R" )' },;
										  { 'D1R_TPREGR', 'DCQ_TPREGR' },;
										  { 'D1R_STATUS', 'DCQ_STATUS' },;
										  { 'D1R_LOCAL',  'DCQ_LOCAL'  },;
										  { 'D1R_CODFUN', 'DCQ_CODFUN' },;
										  { 'D1R_ZONDCQ', 'DCQ_CODZON' },;
										  { 'D1R_SERVIC', 'DCQ_SERVIC' },;
										  { 'D1R_TAREFA', 'DCQ_TAREFA' },;
										  { 'D1R_ATIVID', 'DCQ_ATIVID' }},;
										  D1R->( IndexKey( 1 ) ) )
		// Define validação de linha duplicada para o grid
		oModel:GetModel('D1RDETAIL'):SetUniqueLine({'D1R_CODZON'})
		oModel:GetModel('D1RDETAIL'):SetOptional( .T. )
	EndIf

Return oModel

//----------------------------------------------------------
// Função ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('WMSA350')
Local oView    := FWFormView():New()
Local oStruDCQ := FWFormStruct(2, 'DCQ')
Local oStruD1R := Nil


	oView:SetModel(oModel)
	oView:AddField('VIEWDCQ', oStruDCQ, 'DCQMASTER')
	//Remove campos repetidos

	If AliasIndic("D1R")
		oStruD1R := FWFormStruct(2, 'D1R')

		oStruD1R:RemoveField('D1R_LOCAL')
		oStruD1R:RemoveField('D1R_CODFUN')
		// Criando o componente de grid na interface
		oView:AddGrid('VIEWD1R', oStruD1R, 'D1RDETAIL'/*,{ |oModel| Pre1(oModel) },{ |oModel| Pre2(oModel) },{ |oModel| Pre3(oModel) },{ |oModel| Pre4(oModel) }*/ )
		// Criação dos conteiners para exibição dos dados na interface
		oView:CreateHorizontalBox('SUPERIOR', 65)
		oView:CreateHorizontalBox('INFERIOR', 35)
		// Relacionando o componente da interface
		oView:SetOwnerView('DCQMASTER', 'SUPERIOR')
		oView:SetOwnerView('VIEWD1R', 'INFERIOR')
		oView:AddIncrementalField('VIEWD1R','D1R_ORDEM')
	EndIf

Return oView

//----------------------------------------------------------
// Função de pre-validação do Model
//----------------------------------------------------------
Static Function PreVldMdl(oModel)
Local nOp       := oModel:GetOperation()
Local oModelD1R := oModel:GetModel("D1RDETAIL")

If AliasIndic("D1R")
	If nOp == MODEL_OPERATION_UPDATE .OR. nOp == MODEL_OPERATION_INSERT
		If oModel:GetModel('DCQMASTER'):GetValue('DCQ_FLUTUA') == '2' .OR.;
		   oModel:GetModel('DCQMASTER'):GetValue('DCQ_TPREGR') == '2'
			oModel:GetModel('D1RDETAIL'):SetNoInsertLine(.t.)
			oModel:GetModel('D1RDETAIL'):SetNoUpdateLine(.t.)
			oModel:GetModel('D1RDETAIL'):SetNoDeleteLine(.t.)
			oModelD1R:SetLine(1)
		EndIf
	EndIf
EndIf

Return .T.

//----------------------------------------------------------
// Função de pós-validação do Model
//----------------------------------------------------------
Static Function PosVldMdl(oModel)
Local nOp       := oModel:GetOperation()
Local oModelD1R := Nil 
Local nX        := 0
Local lRet      := .T.
Local lExiste   := .F.
Local lTemLinha := .F.

	If nOp == MODEL_OPERATION_INSERT .Or. nOp == MODEL_OPERATION_UPDATE
		// Não permite que seja gravado registro duplicado
		If oModel:GetValue('DCQMASTER','DCQ_TPREGR') == '1' .And.; // Limitação
			(nOp == MODEL_OPERATION_INSERT .Or. (nOp == MODEL_OPERATION_UPDATE .And.;
			(oModel:IsFieldUpdated('DCQMASTER','DCQ_STATUS') .Or. oModel:IsFieldUpdated('DCQMASTER','DCQ_LOCAL' ) .Or.;
			 oModel:IsFieldUpdated('DCQMASTER','DCQ_CODFUN') .Or. oModel:IsFieldUpdated('DCQMASTER','DCQ_CODZON') .Or.;
			 oModel:IsFieldUpdated('DCQMASTER','DCQ_SERVIC') .Or. oModel:IsFieldUpdated('DCQMASTER','DCQ_TAREFA') .Or.;
			 oModel:IsFieldUpdated('DCQMASTER','DCQ_ATIVID'))))
			
			DCQ->(DbSetOrder(1))
			lExiste := DCQ->(DbSeek(xFilial('DCQ')+oModel:GetValue('DCQMASTER','DCQ_TPREGR')+oModel:GetValue('DCQMASTER','DCQ_STATUS')+oModel:GetValue('DCQMASTER','DCQ_LOCAL')+oModel:GetValue('DCQMASTER','DCQ_CODFUN')+oModel:GetValue('DCQMASTER','DCQ_CODZON')+oModel:GetValue('DCQMASTER','DCQ_SERVIC')+oModel:GetValue('DCQMASTER','DCQ_TAREFA')+oModel:GetValue('DCQMASTER','DCQ_ATIVID')))
		ElseIf oModel:GetValue('DCQMASTER','DCQ_TPREGR') == '2' .And.; // Sequência
				(nOp == MODEL_OPERATION_INSERT .Or. (nOp == MODEL_OPERATION_UPDATE .And.;
				(oModel:IsFieldUpdated('DCQMASTER','DCQ_STATUS') .Or. oModel:IsFieldUpdated('DCQMASTER','DCQ_LOCAL' ) .Or.;
				 oModel:IsFieldUpdated('DCQMASTER','DCQ_SERVIC') .Or. oModel:IsFieldUpdated('DCQMASTER','DCQ_TAREFA') .Or.;
				 oModel:IsFieldUpdated('DCQMASTER','DCQ_ATIVID') .Or. oModel:IsFieldUpdated('DCQMASTER','DCQ_ENDINI') .Or.;
				 oModel:IsFieldUpdated('DCQMASTER','DCQ_ENDFIM'))))
			DCQ->(DbSetOrder(3))
			lExiste := DCQ->(DbSeek(xFilial('DCQ')+oModel:GetValue('DCQMASTER','DCQ_TPREGR')+oModel:GetValue('DCQMASTER','DCQ_STATUS')+oModel:GetValue('DCQMASTER','DCQ_LOCAL')+oModel:GetValue('DCQMASTER','DCQ_SERVIC')+oModel:GetValue('DCQMASTER','DCQ_TAREFA')+oModel:GetValue('DCQMASTER','DCQ_ATIVID')+oModel:GetValue('DCQMASTER','DCQ_ENDINI')+oModel:GetValue('DCQMASTER','DCQ_ENDFIM')))
		EndIf
		If lExiste
			HELP(,,'JAGRAVADO')
			lRet := .F.
		EndIf

		If lRet .AND. AliasIndic("D1R")
			oModelD1R := oModel:GetModel("D1RDETAIL")

			For nX := 1 To oModelD1R:Length()
				If !oModelD1R:IsDeleted() .AND. !Empty(oModel:GetModel('D1RDETAIL'):GetValue('D1R_CODZON'))
					lTemLinha := .T.
					If Empty(oModel:GetModel('DCQMASTER'):GetValue('DCQ_CODZON'))
						oModel:SetErrorMessage (,,,,STR0012,STR0013,STR0014)  //"Atenção"###"O campo 'Codigo Zona' primário deverá ser informado quando existir 'Zona(s) informada(s)' na grid!"###"Deletar as linhas da grid ou preencher o campo 'Codigo Zona'."
						lRet := .F.
						oModelD1R:SetLine(1)
						Exit
					EndIf
				EndIf
			Next nX

			If lRet .AND. lTemLinha .AND. Empty(oModel:GetValue('DCQMASTER','DCQ_CODFUN'))
				oModel:SetErrorMessage (,,,,STR0012,STR0020,STR0021)  //"Atenção"###"O campo 'Funcionario' deverá ser informado quando existir 'Zona(s) alternativa informada(s)' na grid!"###"Exclua as linhas da grid ou preencha o campo 'Funcionario'."   
				lRet := .F.
			EndIf
		EndIf

	EndIf

Return lRet

//----------------------------------------------------------
// Validação do campo Zona
//----------------------------------------------------------
Function WMS350ZONA()
Local lRet := .T.
Local oModel := FWModelActive()
Local oModelD1R := oModel:GetModel("D1RDETAIL")
Local cMsg := ''

If !Empty(M->D1R_CODZON)
	lRet := ExistCpo("DC4", M->D1R_CODZON)
EndIf

If lRet .AND. M->DCQ_CODZON == M->D1R_CODZON
	oModel:GetModel():SetErrorMessage('D1RDETAIL','D1R_CODZON','D1RDETAIL','D1R_CODZON','WMS350ZONA',STR0015,STR0016) //"O campo 'Codigo Zona' da grid não poderá ser igual ao campo 'Codigo Zona' da parte superior da tela!"###"Informe outro valor para o campo 'Codigo Zona'."
	lRet := .F.
EndIf

If lRet
	cAliasD1R  := GetNextAlias()
	BeginSQL Alias cAliasD1R
	SELECT 1
      FROM %Table:D1R% D1R
	 WHERE D1R.D1R_FILIAL = %xFilial:D1R%
	   AND D1R.D1R_CODFUN = %Exp:M->DCQ_CODFUN%
	   AND D1R.D1R_CODZON = %Exp:M->D1R_CODZON%
	   AND D1R.R_E_C_N_O_ <> %Exp:oModelD1R:GetDataId()%
	   AND D1R.%NotDel%
	EndSQL
	If (cAliasD1R)->(!Eof() )
		cMsg := STR0017 + AllTrim(M->D1R_CODZON) + STR0018 + AllTrim(cUserName) + STR0019 //"Zona secundária "###" já informada para o usuario "###". Não é permitido informar a mesma zona secundária para o mesmo usuario mais de uma vez."
		oModel:GetModel():SetErrorMessage('D1RDETAIL','D1R_CODZON','D1RDETAIL','D1R_CODZON','WMS350ZONA',cMsg,STR0016) //"Informe outro valor para o campo 'Codigo Zona'."
		lRet := .F.
	End
	(cAliasD1R)->( dbCloseArea() )
EndIf

Return lRet

//----------------------------------------------------------
// Validação do campo "Flutua Zona?"
//----------------------------------------------------------
Function WMS350FLUT()
Local lRet := .t.
Local nX := 0
Local lLine := .T. 
Local oModel := FWModelActive()
Local oModelD1R := oModel:GetModel("D1RDETAIL")

If AliasIndic("D1R")
	If oModel:GetModel('DCQMASTER'):GetValue('DCQ_TPREGR') == '2' .OR. oModel:GetModel('DCQMASTER'):GetValue('DCQ_FLUTUA') == '2'
		oModel:GetModel('D1RDETAIL'):SetNoInsertLine(.f.)
		oModel:GetModel('D1RDETAIL'):SetNoUpdateLine(.f.)
		oModel:GetModel('D1RDETAIL'):SetNoDeleteLine(.f.)
		For nX := 1 To oModelD1R:Length()
			oModelD1R:GoLine(nX)
			oModelD1R:DeleteLine()
		Next nX
		lLine := .T.
	ElseIf oModel:GetModel('DCQMASTER'):GetValue('DCQ_FLUTUA') == '1' .AND.  oModel:GetModel('DCQMASTER'):GetValue('DCQ_FLUTUA') == '1'
		For nX := 1 To oModelD1R:Length()
			oModelD1R:GoLine(nX)
			oModelD1R:UnDeleteLine()
		Next nX
		lLine := .F.
	EndIF

	oModel:GetModel('D1RDETAIL'):SetNoInsertLine(lLine)
	oModel:GetModel('D1RDETAIL'):SetNoUpdateLine(lLine)
	oModel:GetModel('D1RDETAIL'):SetNoDeleteLine(lLine)

	oModelD1R:SetLine(1)
EndIf

Return lRet

//----------------------------------------------------------
// Validação do campo "Tipo Regra"
//----------------------------------------------------------
Function WMS350TIPR()
Local lRet := .T.
Local nX := 0
Local oModel := FWModelActive()
Local oModelD1R
Local lLine := .T. 

If AliasIndic("D1R")
	oModelD1R := oModel:GetModel("D1RDETAIL")
	If oModel:GetModel('DCQMASTER'):GetValue('DCQ_TPREGR') == '2' .OR. oModel:GetModel('DCQMASTER'):GetValue('DCQ_FLUTUA') == '2'
		oModel:GetModel('D1RDETAIL'):SetNoInsertLine(.f.)
		oModel:GetModel('D1RDETAIL'):SetNoUpdateLine(.f.)
		oModel:GetModel('D1RDETAIL'):SetNoDeleteLine(.f.)
		For nX := 1 To oModelD1R:Length()
			oModelD1R:GoLine(nX)
			oModelD1R:DeleteLine() 
		Next nX
		lLine := .T.
	ElseIf oModel:GetModel('DCQMASTER'):GetValue('DCQ_TPREGR') == '1' .AND.  oModel:GetModel('DCQMASTER'):GetValue('DCQ_FLUTUA') == '1'
		For nX := 1 To oModelD1R:Length()
			oModelD1R:GoLine(nX)
			oModelD1R:UnDeleteLine()
		Next nX
		lLine := .F.
	EndIF

	oModel:GetModel('D1RDETAIL'):SetNoInsertLine(lLine)
	oModel:GetModel('D1RDETAIL'):SetNoUpdateLine(lLine)
	oModel:GetModel('D1RDETAIL'):SetNoDeleteLine(lLine)

	oModelD1R:SetLine(1)
EndIf
Return lRet
