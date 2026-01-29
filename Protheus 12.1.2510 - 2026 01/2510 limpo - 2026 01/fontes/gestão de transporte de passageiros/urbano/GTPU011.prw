#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPU011.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU011
	Alocação de recursos - Urbano

	@author Breno Gomes
    @since 05/03/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Function GTPU011()
	Local oBrowse := FWMBrowse():New()

	oBrowse:SetDescription(STR0001) //'Alocação de recursos'
	oBrowse:SetAlias("H7E")
	oBrowse:SetLocate()
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef - Menu Funcional

    @return aRotina - Estrutura
    [n,1] Nome a aparecer no cabecalho
    [n,2] Nome da Rotina associada
    [n,3] Reservado
    [n,4] Tipo de Transação a ser efetuada:
    1 - Pesquisa e Posiciona em um Banco de Dados
    2 - Simplesmente Mostra os Campos
    3 - Inclui registros no Bancos de Dados
    4 - Altera o registro corrente
    5 - Remove o registro corrente do Banco de Dados
    6 - Alteração sem inclusão de registros
    7 - Cópia
    8 - Imprimir
    [n,5] Nivel de acesso
    [n,6] Habilita Menu Funcional

    @author Breno Gomes
    @since 05/03/2024
    @version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

    aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.GTPU011", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.GTPU011", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.GTPU011", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.GTPU011", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.GTPU011", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

    Função responsavel pela definição do modelo
    @author Breno Gomes
    @since 05/03/2024
    @return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel        := Nil
	Local oStructH7E    := FWFormStruct(1, 'H7E')
	Local oStructH7F    := FWFormStruct(1, 'H7F')
	Local oStructH7G    := FWFormStruct(1, 'H7G')
	Local aH7FRelation  := {}
	Local aH7GRelation  := {}

	oModel := MPFormModel():New("GTPU011",/*bPre*/, /*bPos*/{|oModel| posVldModel(oModel)},/*bCommit*/,/*bCancel*/)
	oModel:AddFields('H7EMASTER',/*cOwner*/,oStructH7E)
	oModel:GetModel( "H7EMASTER" ):SetDescription( "H7EMASTER" ) //"Alocação de recursos"
	//GRID DIAS X ESCALAS
	oModel:AddGrid('H7FDETAIL','H7EMASTER',oStructH7F)

	aAdd(aH7FRelation, { 'H7F_FILIAL', "xFilial('H7F')" })
	aAdd(aH7FRelation, { 'H7F_CODH7E', 'H7E_CODIGO'     })

	oModel:SetRelation('H7FDETAIL', aH7FRelation, H7F->(IndexKey(1)))
	//GRID ESCALAS X COLABORADOR/VEICULO
	If FwIsInCallStack('GTPUJ001')
		oStructH7G:SetProperty("H7G_SENTID", MODEL_FIELD_VALID,  {||.T.} )
	Endif
	oModel:AddGrid('H7GDETAIL', 'H7FDETAIL', oStructH7G)

	aAdd(aH7GRelation, { 'H7G_FILIAL', "xFilial('H7G')" })
	aAdd(aH7GRelation, { 'H7G_CODH7E', 'H7E_CODIGO'     })
	aAdd(aH7GRelation, { 'H7G_CODH7F', 'H7F_CODIGO'     })

	oModel:SetRelation('H7GDETAIL', aH7GRelation, H7G->(IndexKey(1)))

	oModel:GetModel('H7FDETAIL'):SetUniqueLine({"H7F_CODIGO"})
	oModel:GetModel('H7GDETAIL'):SetUniqueLine({"H7G_CODIGO"})

	oModel:getModel('H7FDETAIL'):SetOptional(.T.)
	oModel:getModel('H7GDETAIL'):SetOptional(.T.)

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

    Função responsavel pela definição da view
    @type Static Function
    @author Breno Gomes
    @since 05/03/2024
    @version 1.0
    @return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView      := Nil
	Local oModel     := FWLoadModel("GTPU011")
	Local oStructH7E := FWFormStruct(2, "H7E")
	Local oStructH7F := FWFormStruct(2, 'H7F')
	Local oStructH7G := FWFormStruct(2, 'H7G')

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField('VIEW_H7E', oStructH7E, 'H7EMASTER')
    oView:AddGrid('VIEW_H7F' , oStructH7F, 'H7FDETAIL')
	oView:AddGrid('VIEW_H7G' , oStructH7G, 'H7GDETAIL')

    oView:CreateHorizontalBox('CABEC', 30)
    oView:CreateHorizontalBox('GRIDH7F' , 35)
	oView:CreateHorizontalBox('GRIDH7G' , 35)

    oView:SetOwnerView('VIEW_H7E', 'CABEC')
    oView:SetOwnerView('VIEW_H7F', 'GRIDH7F')
	oView:SetOwnerView('VIEW_H7G', 'GRIDH7G')

	oStructH7F:RemoveField("H7F_CODH7E")
	oStructH7G:RemoveField("H7G_CODH7E")
	oStructH7G:RemoveField("H7G_CODH7H")

    oView:EnableTitleView('VIEW_H7E', STR0001 ) //"Alocação de recursos"
	oView:EnableTitleView('VIEW_H7F', STR0008 ) //"Escalas x dias alocados"
	oView:EnableTitleView('VIEW_H7G', STR0009 ) //"Escalas x Colaboradores/Veiculos"


Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} posVldModel

    Função responsável por validar as linhas do grid
    @type Function
    @author Breno Gomes
    @since 24/04/2024
    @version 1.0
    @return lRet .T. se estiver tudo ok .F. se houver inconsistência nos dados
/*/
//------------------------------------------------------------------------------
Static Function posVldModel( oModel )
Local lRet        := .T.
Local oModelH7F   := oModel:GetModel( 'H7FDETAIL' )
Local oModelH7G   := oModel:GetModel( 'H7GDETAIL' )
Local cCodEscala  := oModel:GetValue( 'H7EMASTER','H7E_CODH76')
Local cDescEscala := oModel:GetValue( 'H7EMASTER','H7E_DSCESC')
Local dDataIni    := oModel:GetValue( 'H7EMASTER','H7E_DTINIC')
Local dDataFim    := oModel:GetValue( 'H7EMASTER','H7E_DTFINA')
Local nOperation  := oModel:GetOperation()
Local nI          := 0

	If nOperation != MODEL_OPERATION_DELETE
		If GTPUVldPer(cCodEscala, dDataIni, dDataFim, oModel:GetValue( 'H7EMASTER','H7E_CODIGO')  )
			For nI := 1 To oModelH7F:GetQtdLine()
				oModelH7F:GoLine( nI )
				If oModelH7F:GetValue('H7F_CODH76') <> cCodEscala
					lRet := .F.
					cMsgError := I18n(STR0010,{cCodEscala,cDescEscala}) //"Todas as configurações devem respeitar a escala principal #1 - #2 "
					oModel:setErrorMessage(,, oModelH7F:GetId(),, STR0011, cMsgError,,,)//""Alocação inválida"  - "Todas as configurações devem respeitar a escala principal #1 - #2 "
					Exit
				EndIf

				If oModelH7F:GetValue('H7F_DATA') < dDataIni .Or. oModelH7F:GetValue('H7F_DATA') > dDataFim
					lRet := .F.
					cMsgError := I18n(STR0012,{dToC(oModelH7F:GetValue('H7F_DATA')), dToC(dDataIni), dToC(dDataFim)}) //"A data #1 deve estar entre o intervalo de alocação : #2 - #3 "
					oModel:setErrorMessage(,, oModelH7F:GetId(),, STR0014 , cMsgError,,,)//"Data inválida" - "A data #1 deve estar entre o intervalo de alocação : #2 - #3 "
					Exit
				EndIf
			Next nI
			If lRet
				For nI := 1 To oModelH7G:GetQtdLine()
					oModelH7G:GoLine( nI )
					if oModelH7G:GetValue('H7G_CODH76') <> cCodEscala
						lRet := .F.
						cMsgError := I18n(STR0010,{cCodEscala,cDescEscala}) //"Todas as configurações devem respeitar a escala principal #1 - #2 "
						oModel:setErrorMessage(,, oModelH7G:GetId(),, STR0011, cMsgError,,,)//"Alocação inválida"  - "Dados inválidos para a programação :#1 Horário: #2 - #3 - Sentido: #4"
						Exit
					EndIf
					If lRet .And. Empty(oModelH7G:GetValue('H7G_CODH70')) .And. Empty(oModelH7G:GetValue('H7G_CODGYG')) .And. Empty(oModelH7G:GetValue('H7G_CODH78'))
						lRet := .F.
						cMsgError := STR0013// "Para efetuar a alocação, em seus horários devem ter ao menos um veículo ou um motorista, Informe um desses dados para prosseguir!"
						oModel:setErrorMessage(,, oModelH7G:GetId(),, STR0011, cMsgError,,,)//"Alocação inválida"
						Exit
					EndIf
					If lRet
						If Empty(oModelH7G:GetValue('H7G_CODH77')) .And. Empty(oModelH7G:GetValue('H7G_CODH78'))
							lRet := .F.
							cMsgError := STR0017 //"Para efetuar a alocação, é necessário informar uma viagem ou um trecho"
							oModel:setErrorMessage(,, oModelH7G:GetId(),, STR0011, cMsgError,,,)//"Alocação inválida"
							Exit
						Else
							If !Empty(oModelH7G:GetValue('H7G_CODH77'))
								H77->(dbSetOrder(1))

								If !H77->(dbSeek(xFilial('H77') + cCodEscala + oModelH7G:GetValue('H7G_CODH77') ))
									lRet := .F.
									cMsgError := STR0015 //"Viagem informada não existe para a escala selecionada"
									oModel:setErrorMessage(,, oModelH7G:GetId(),, STR0011, cMsgError,,,)//"Alocação inválida"
									Exit
								Endif
							Endif

							If !Empty(oModelH7G:GetValue('H7G_CODH78'))
								H78->(dbSetOrder(1))

								If !H78->(dbSeek(xFilial('H78') + cCodEscala + oModelH7G:GetValue('H7G_CODH78') ))
									lRet := .F.
									cMsgError := STR0016 //"Trecho informado não existe para a escala selecionada"
									oModel:setErrorMessage(,, oModelH7G:GetId(),, STR0011, cMsgError,,,)//"Alocação inválida"
									Exit
								Endif
							Endif
						EndIf
					EndIf
				Next nI
			EndIf
		Else
			lRet := .F.
			cMsgError := I18n(STR0021,{cDescEscala}) //"Há dias alocados para a escala #1 em outro grupo de alocação dentro período informado, verifique! "
			oModel:setErrorMessage(,, oModelH7G:GetId(),, STR0011, cMsgError,,,)//"Alocação inválida"
		EndIf
	EndIf
Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPUVldPer

    Função responsável por validar a vigência da alocação, pois não deve conflitar as datas
    @type Function
	@param oModel - Modelo de dados H7E
    @author Breno Gomes
    @since 21/01/2025
    @version 1.0
    @return lRet .T. se estiver tudo ok .F. se houver inconsistência nas datas
/*/
//------------------------------------------------------------------------------
Static Function GTPUVldPer(cCodEscala, dDataIni, dDataFim, cCodAlocacao)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasTmp := ""

	cQuery := " SELECT * FROM ?"
	cQuery += " WHERE H7E_FILIAL = ?"
	cQuery +=       " AND H7E_CODH76 = ?"
	cQuery +=       " AND H7E_DTINIC <= ?"
	cQuery +=       " AND H7E_DTFINA >= ?"
	cQuery +=       " AND H7E_CODIGO != ?"
	cQuery +=       " AND D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery)

	oQuery := FWPreparedStatement():New(cQuery)
	oQuery:SetUnsafe(1, RetSqlName("H7E"))
	oQuery:SetString(2, xFilial("H7E"))
	oQuery:SetUnsafe(3, cCodEscala)
	oQuery:SetString(4, dToS(dDataFim))
	oQuery:SetString(5, dToS(dDataIni))
	oQuery:SetString(6, cCodAlocacao)

	cQuery := oQuery:GetFixQuery()
	cAliasTmp := MPSysOpenQuery( cQuery )

	lRet := (cAliasTmp)->( EOF() )

	If Select(cAliasTmp) > 0
		(cAliasTmp)->(DBCloseArea())
	Endif
Return lRet
