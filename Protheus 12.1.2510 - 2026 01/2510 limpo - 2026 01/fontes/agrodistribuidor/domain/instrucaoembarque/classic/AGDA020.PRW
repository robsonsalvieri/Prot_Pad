#INCLUDE "AGDA020.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#DEFINE IE_PEDIDO_SERVICE agd.instrucaoEmbarquePedidoService.agdInstrucaoEmbarquePedidoService
#DEFINE INSTRUCAO_EMBARQUE_ITEM_REPOSITORY agd.instrucaoEmbarqueItemRepository.agdInstrucaoEmbarqueItemRepository
#DEFINE NEGOCIO_SERVICE agd.negocioService.agdNegocioService
#DEFINE NEGOCIO_VENDA_PERDIDA_REPOSITORY agd.vendaPerdidaRepository.agdVendaPerdidaRepository
#DEFINE NEGOCIO_INSUMO_SERVICE  agd.negocioInsumoService.agdNegocioInsumoService
#DEFINE REPOSITORY_UTILS agd.repositoryUtils.agdRepositoryUtils

/*/{Protheus.doc} AGDA020
Rotina para Cadastro de Instrução de embarque dos itens de insumo da negociação de barter
@type function
@version P12
@author claudineia.reinert
@since 12/11/2024
/*/
Function AGDA020()
	Local oMBrowse := Nil

	If .Not. TableInDic('NEC')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NEC" )
	oMBrowse:SetDescription( STR0001 ) //#"Instrução de Embarque"
	oMBrowse:DisableDetails()
	SetKey(VK_F4,{|| AGDA020Key() })
	oMBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Definição do menu
@type function
@version P12
@author claudineia.reinert
@since 12/11/2024
@return Array, array com o menu da rotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	/**************************************************************************************
    Nao Mudar a Ordem do Menu -	Impacto no Cockpit Barter - Permissão de acesso das rotinas
	***************************************************************************************/	

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGDA020' OPERATION 2 ACCESS 0 //#"Visualizar"
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.AGDA020' OPERATION 3 ACCESS 0 //#"Incluir"
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.AGDA020' OPERATION 4 ACCESS 0 //#"Alterar"
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.AGDA020' OPERATION 5 ACCESS 0 //#"Excluir"
	ADD OPTION aRotina Title STR0006 Action 'AGD20HIST' 	  OPERATION 7 ACCESS 0 //#"Historico"
	ADD OPTION aRotina Title STR0025 Action 'AGD20GERAPV'     OPERATION 8 ACCESS 0 //#"Gerar Pedido"
	ADD OPTION aRotina Title STR0012 Action 'AGD20CONSPV'     OPERATION 8 ACCESS 0 //#"Cons. Pedido"
	ADD OPTION aRotina Title STR0015 Action 'AGD20EXCLPV'     OPERATION 5 ACCESS 0 //#"Exlcuir Pedido" //
	ADD OPTION aRotina Title STR0019 Action 'AGD20FATPV'     OPERATION 8 ACCESS 0 //#"Faturar Pedido"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de dados
@type function
@version P12
@author claudineia.reinert
@since 12/11/2024
@return Object, modelo de dados
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNEC  := FwFormStruct( 1, "NEC" )
	Local oStruNED	:= FwFormStruct( 1, "NED" )
	Local oEvent        := AGDA020EVT():New()

	oModel := MpFormModel():New( "AGDA020")
	oModel:SetDescription( STR0001 ) //##"Instrução de Embarque"

	oStruNED:SetProperty( "NED_CODBRT" 	, MODEL_FIELD_INIT 	, {| | M->NEC_CODBRT } )

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA020_NEC", , oStruNEC)
	oModel:GetModel( "AGDA020_NEC" ):SetDescription( STR0007 ) //#"Dados Instrução de Embarque"
	oModel:SetPrimaryKey( { "NEC_FILIAL", "NEC_CODIGO" } )

	oModel:AddGrid( "AGDA020_NED", "AGDA020_NEC", oStruNED)
	oModel:GetModel( "AGDA020_NED" ):SetDescription( STR0008 ) //#"Itens Instrução de Embarque"

	//Atribui um relacionamento de Pai X Filho
	oModel:SetRelation( 'AGDA020_NED', {{'NED_FILIAL', 'xFilial("NED")'},{ 'NED_CODIEB', 'NEC_CODIGO' }}, NED->(IndexKey( 1 ) ) )

	oModel:GetModel( "AGDA020_NED" ):SetUniqueLine( { 'NED_ITEM' } )
	oModel:GetModel( "AGDA020_NED" ):SetOptional( .F. )
	oModel:GetModel('AGDA020_NED'):SetUseOldGrid(.T.)

	oModel:InstallEvent("AGDA020EVT", /*cOwner*/, oEvent)
Return oModel

/*/{Protheus.doc} ViewDef
Definição da visualização dos dados
@type function
@version P12
@author claudineia.reinert
@since 12/11/2024
@return Object, Objeto de dados da View
/*/
Static Function ViewDef()
	Local oModel	:= FwLoadModel( "AGDA020" )
	Local oStruNEC  := FwFormStruct( 2, "NEC" )
	Local oStruNED  := FwFormStruct( 2, "NED" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oStruNED:RemoveField( "NED_CODIEB" )
	oStruNED:RemoveField( "NED_CODBRT" )

	If IsInCallStack( "AGDA010MIE" )
		oStruNEC:SetProperty("NEC_CODBRT", MVC_VIEW_CANCHANGE, .F.)
	EndIf

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NEC', oStruNEC, 'AGDA020_NEC' )

	oView:AddGrid( 'VIEW_NED', oStruNED, 'AGDA020_NED' )
	oView:AddIncrementField( 'VIEW_NED', 'NED_ITEM' )

	oView:CreateHorizontalBox( 'CABEC', 50 )
	oView:CreateHorizontalBox( 'GRID', 50 )

	oView:SetOwnerView( 'VIEW_NEC', 'CABEC' )
	oView:SetOwnerView( 'VIEW_NED', 'GRID' )

	oView:EnableTitleView("VIEW_NEC")
	oView:EnableTitleView("VIEW_NED")

	oView:SetCloseOnOk({||.T.})
Return oView


/*/{Protheus.doc} AGDA020Key
Funcao para exibir o saldo do produto/lote
@type function
@version P12
@author carlos.augusto
@since 02/10/2025
/*/
Function AGDA020Key()
	Local cCampo 	:= AllTrim(Upper(ReadVar()))
	Local oModel	:= FWModelActive()
	Local oModelNED := Nil
	Local cProduto  := Nil
	Local cArmOri   := Nil

	If oModel <> NIL
		oModelNED := oModel:GetModel("AGDA020_NED")
		cProduto  := oModelNED:GetValue("NED_CODPRO")
		cArmOri   := oModelNED:GetValue("NED_LOCAL")
		
		Do Case
			Case cCampo == "M->NED_LOTCTL"
				F4Lote( , , , 'AGDA020' , cProduto, cArmOri , NIL , Nil , 2 , , , .F. )
			Case cCampo == "M->NED_QTDIEB"
				If !Empty(cProduto)
					MaViewSB2(cProduto,,)
				EndIf
		EndCase
	EndIf

Return NIL


/*/{Protheus.doc} AGD20TGCLI
Função de gatilho ao informar os campos NEC_CODCLI E NEC_LOJCLI
@type function
@version p12.1.2410
@author claudineia.reinert
@since 11/12/2024
@return Logical, valor .T. 
/*/
Function AGD20TGCLI()
	Local oModel    := FwModelActive()
	Local oNEC		:= oModel:GetModel("AGDA020_NEC")
	Local oNED		:= oModel:GetModel("AGDA020_NED")
	Local oView     := FWViewActive()
	Local nOperation    := oModel:GetOperation()
	Local oNegocioInsumoService	:= NIL
	Local oNegocioService := nil
	Local cVersaoNegocio := ""
	Local nSaldoNEB  := 0
	Local nCount	:= 0
	Local aAreaNEB	:= NIL

	If nOperation == MODEL_OPERATION_INSERT .and. !IsInCallStack("HTTPCALLCLASS")
		If oNED:Length() > 0
			oNED:DelAllLine() //Deleta todas as linhas
			oNED:ClearData() //limpa as linhas da tela
		EndIf
		If !Empty(oNEC:GetValue("NEC_CODCLI")) .and. !Empty(oNEC:GetValue("NEC_LOJCLI"))

			oNEC:LoadValue("NEC_NOMCLI", Alltrim(Posicione('SA1',1,xFilial('SA1')+oNEC:GetValue("NEC_CODCLI")+oNEC:GetValue("NEC_LOJCLI"),'A1_NOME')) )

			oNegocioService := NEGOCIO_SERVICE():New()
			cVersaoNegocio := oNegocioService:buscarVersaoAtualValida(oNEC:GetValue("NEC_CODBRT"))

			dbSelectArea('NEB')
			NEB->(DBGoTop())
			NEB->(dbSetOrder(2)) //
			IF NEB->(dbSeek(xFilial('NEB')+oNEC:GetValue("NEC_CODBRT")+cVersaoNegocio+oNEC:GetValue("NEC_CODCLI")+oNEC:GetValue("NEC_LOJCLI"))) .and. !Empty(cVersaoNegocio)
				nCount	:= 0
				While NEB->(!EoF()) .and. (xFilial('NEB')+oNEC:GetValue("NEC_CODBRT") + cVersaoNegocio + oNEC:GetValue("NEC_CODCLI") + oNEC:GetValue("NEC_LOJCLI") == NEB->(NEB_FILIAL + NEB_CODBRT + NEB_VERSAO + NEB_CLIENT + NEB_LOJENT ))

					oNegocioInsumoService:= NEGOCIO_INSUMO_SERVICE():new(NEB->NEB_CODBRT, cVersaoNegocio, NEB->NEB_ITEM)
					nSaldoNEB := oNegocioInsumoService:getSaldo() //Busca saldo disponivel do item da negociação

					IF nSaldoNEB > 0
						nCount++
						if (nCount > oNED:Length())
							oNED:ADDLINE()
						endif
						aAreaNEB := NEB->(GetArea()) //ARMAZENA AREA POSICIONADA, POIS NED_ITEBRT GATILHA USANDO INDICE NEB
						oNED:SetValue('NED_CODBRT'	, NEB->NEB_CODBRT)
						oNED:SetValue('NED_ITEBRT'	, NEB->NEB_ITEM)
						oNED:SetValue("NED_ITEM"  	, StrZero( oNED:Length(), TamSX3("NED_ITEM")[1]) )
						oNED:SetValue('NED_QTDIEB'	, nSaldoNEB)
						RestArea(aAreaNEB)
					ENDIF
					FreeObj(oNegocioInsumoService)

					NEB->(DbSkip())
				endDo
			ENDIF

			oNED:GoLine(1)

			If oView != Nil .AND. ValType(oView) == "O";
				.AND. oView:oModel:getId() == "AGDA020"
				oView:Refresh("AGDA020_NED")
			EndIf
		EndIf
	EndIf
	FreeObj(oNegocioService)
Return .T.

/*/{Protheus.doc} fQryItAloc
Executa query que retorna a quantidade alocada do item da negociação em instruções de embarque desconsiderando IE atual
@type function
@version P12.1.2410
@author claudineia.reinert
@since 12/12/2024
@param cCodBRT, character, Codigo da negociação de barter
@param cIteBRT, character, item da negociação de barter
@param cCodPro, character, codigo do produto da negociação de barter
@param cCodIEB, character, codigo da instrução de embarque para desconsiderar no filtro, caso seja passado em branco será desconsiderado no filtro
@return Numeric, quantidade alocada
/*/
Static function fQryItAloc(cCodBRT,cIteBRT,cNotCodIEB)
	Local nRet 		:= 0
	Local cQuery	:= ""
	Local cAliQry 	:= GetNextAlias()
	Local oStatement 	:= nil

	cQuery := " SELECT  SUM(NED_QTDIEB) AS QTD_ALOCADA "
	cQuery += " FROM "+ retSqlName('NED') +" NED "
	cQuery += " INNER JOIN "+ retSqlName('NEC') +" NEC ON NEC_FILIAL = NED_FILIAL "
	cQuery += " AND NEC.D_E_L_E_T_ = '' AND NEC_CODIGO = NED_CODIEB "
	cQuery += " WHERE NED_FILIAL = ? "
	cQuery += " AND NED_CODBRT = ? "
	cQuery += " AND NED_ITEBRT = ? "
	cQuery += " AND NED_CODIEB <> ? "
	cQuery += " AND NED.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery( cQuery )

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1, FWxFilial('NED'))
	oStatement:SetString(2, cCodBRT)
	oStatement:SetString(3, cIteBRT)
	oStatement:SetString(4, cNotCodIEB)
	cQuery := oStatement:GetFixQuery()
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliQry,.T.,.T.)

	If !(cAliQry)->(Eof())
		nRet := (cAliQry)->QTD_ALOCADA
	EndIf
	(cAliQry)->(dbCloseArea())

Return nRet

/*/{Protheus.doc} AGD20NEDITC
Filtro da consulta padrão(SXB) NEDITC - filtra os dados para o campo NED_ITEBRT 
@type function
@version P12
@author claudineia.reinert
@since 05/12/2024
@return Character, Query para o filtro da consulta
/*/
Function AGD20NEDITC()

	Local aArea		:= GetArea()
	Local oModel    := FwModelActive()
	Local oNEC		:= oModel:GetModel("AGDA020_NEC")
	Local cQuery	:= ""
	Local oNegocioService := NEGOCIO_SERVICE():New()
	Local cVersao := oNegocioService:buscarVersaoAtualValida(oNEC:GetValue("NEC_CODBRT"))

	cQuery += "@ D_E_L_E_T_ = ' ' "
	cQuery += " AND NEB_CODBRT = '" + oNEC:GetValue("NEC_CODBRT") + "' "
	cQuery += " AND NEB_VERSAO = '"+cVersao+"' "
	cQuery += " AND NEB_CLIENT = '" + oNEC:GetValue("NEC_CODCLI") + "' "
	cQuery += " AND NEB_LOJENT = '" + oNEC:GetValue("NEC_LOJCLI") + "' "

	RestArea(aArea)

Return cQuery

/*/{Protheus.doc} AGD20VDNEC
Validação de campos da tabela NEC via dicionario de dados SX3
@type function
@version P12.1.2410
@author claudineia.reinert
@since 11/12/2024
@return Logical, Valor logico da validação, verdadeiro(.T.) ou Falso(.F.)
/*/
Function AGD20VDNEC()
	Local lRet 		:= .T.
	Local cReadVar  := ReadVar()
	Local oModel    := FwModelActive()
	Local oNEC		:= oModel:GetModel("AGDA020_NEC")
	Local nQtdCliEnt := 0
	Local lSaldo		:= .F.
	Local oNegocioService := NIL
	Local cVersaoNegocio := ""

	If "NEC_CODBRT" $ cReadVar
		If !Empty(oNEC:GetValue("NEC_CODBRT")) .and. !ExistCpo("NEA",oNEC:GetValue("NEC_CODBRT"))
			lRet := .F. //Mensagem padrão sistema
		Else
			oNegocioService := NEGOCIO_SERVICE():New()
			cVersaoNegocio := oNegocioService:buscarVersaoAtualValida(oNEC:GetValue("NEC_CODBRT"))

			If !Posicione("NEA", 1, xFilial("NEA") + oNEC:GetValue("NEC_CODBRT") + cVersaoNegocio, "NEA_STSAUT") == '2' //1=Nao liberado / 2=Liberado
				lRet := .F.
				AGDHELP( STR0009, STR0017, STR0018 )
			else

				//valida se seta cliente automatico
				nQtdCliEnt := AGD20QCIN(FWxFilial("NEB"),oNEC:GetValue("NEC_CODBRT"))
				If nQtdCliEnt = 1
					DbSelectArea("NEB")
					NEB->(DbSetorder(1)) //NEB_FILIAL+NEB_CODBRT
					If (NEB->(DbSeek(FWxFilial("NEB")+oNEC:GetValue("NEC_CODBRT")+cVersaoNegocio)))
						oNEC:SetValue('NEC_CODCLI', NEB->NEB_CLIENT)
						oNEC:SetValue('NEC_LOJCLI', NEB->NEB_LOJENT)
					EndIf
				Else
					oNEC:SetValue("NEC_CODCLI","")
					oNEC:SetValue("NEC_LOJCLI","")
				EndIf

				//REALIZANDO VALIDACAO DE SALDO DE NEGOCIACAO
				dbSelectArea('NEB')
				NEB->(DBGoTop())
				dbSetOrder(1)
				IF NEB->(dbSeek(xFilial('NEB')+oNEC:GetValue("NEC_CODBRT")+cVersaoNegocio))

					While NEB->(!EoF()) .and. (xFilial('NEB')+oNEC:GetValue("NEC_CODBRT")+cVersaoNegocio == NEB->(NEB_FILIAL+NEB_CODBRT+NEB_VERSAO))
						if AGDA050SLD(NEB->NEB_CODBRT,NEB->NEB_ITEM) > 0
							lSaldo := .T.
						endif
						NEB->(DBSkip())
					endDo

					IF !lSaldo
						lRet := .F.
						oNEC:GetModel():SetErrorMessage("AGDA020_NEC", ,"AGDA020_NEC", ,STR0008, STR0021 )
					ENDIF

				ENDIF

			Endif
		EndIf
	ElseIf "NEC_CODCLI" $ cReadVar .AND. !Empty(oNEC:GetValue("NEC_CODCLI"))
		oNegocioService := NEGOCIO_SERVICE():New()
		cVersaoNegocio := oNegocioService:buscarVersaoAtualValida(oNEC:GetValue("NEC_CODBRT"))
		If !ExistCpo('NEB',oNEC:GetValue("NEC_CODBRT")+cVersaoNegocio+oNEC:GetValue("NEC_CODCLI"),2)
			lRet := .F. //Mensagem padrão sistema
		EndIf
	ElseIf "NEC_LOJCLI" $ cReadVar .AND. !Empty(oNEC:GetValue("NEC_LOJCLI"))
		oNegocioService := NEGOCIO_SERVICE():New()
		cVersaoNegocio := oNegocioService:buscarVersaoAtualValida(oNEC:GetValue("NEC_CODBRT"))
		If !ExistCpo('NEB',oNEC:GetValue("NEC_CODBRT")+cVersaoNegocio+oNEC:GetValue("NEC_CODCLI")+oNEC:GetValue("NEC_LOJCLI"),2)
			lRet := .F. //Mensagem padrão sistema
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} AGD20VDNED
Validação de campos da tabela NED via dicionario de dados SX3
@type function
@version P12.1.2410
@author claudineia.reinert
@since 06/12/2024
@return Logical, Valor .T. ou .F.
/*/
Function AGD20VDNED()
	Local lRet 		:= .T.
	Local cReadVar  := ReadVar()
	Local oModel    := FwModelActive()
	Local oNED		:= oModel:GetModel("AGDA020_NED")
	Local nSaldo  	:= 0
	Local nX     	:= 0
	Local cIteBRT	:= oNED:GetValue("NED_ITEBRT") //armazena item barter atual
	Local oView		:= FwViewActive()

	If "NED_QTDIEB" $ cReadVar

		nSaldo := AGDA020SNED(oModel)

		If oNED:GetValue('NED_QTDIEB') > nSaldo .OR. oNED:GetValue('NED_QTDIEB') < 0
			lRet := .F.
			AGDHELP(STR0009,STR0047, STR0048 + cValToChar(nSaldo)) //"Ajuda" ##"Valor informado maior que o saldo disponivel" ##"Informe um valor menor ou igual a "
		Else
			oNED:SetValue('NED_VALOR', Round(oNED:GetValue('NED_QTDIEB') * oNED:GetValue('NED_PRCUNI'),TamSX3("NED_VALOR")[2]))
			nSaldo -= oNED:GetValue('NED_QTDIEB') //atualiza o saldo com a qtd informada na linha
			//Atualiza saldo para as linhas com mesmo item de insumo
			nLinha := oNED:GetLine()
			For nX := 1 to oNED:Length()
				oNED:GoLine( nX )
				If !oNED:IsDeleted() .AND. oNED:GetValue('NED_ITEBRT') == cIteBRT
					oNED:SetValue("NED_QTDSLD", nSaldo )
				EndIf
			Next nX
			oNED:GoLine( nLinha )

			If valType(oView) == 'O' .AND. oView:IsActive()  // Atualiza a View
				oView:Refresh("VIEW_NED")
			EndIf

		EndIf
	ElseIf "NED_ITEBRT" $ cReadVar
		oNegocioService := NEGOCIO_SERVICE():New()
		cVersaoNegocio := oNegocioService:buscarVersaoAtualValida(oNED:GetValue("NED_CODBRT")) //Obrigatorio versao atual de trabalho
		If !ExistCpo('NEB',oNED:GetValue("NED_CODBRT")+cVersaoNegocio+FwFldGet("NEC_CODCLI")+FwFldGet("NEC_LOJCLI")+oNED:GetValue("NED_ITEBRT"),2)
			lRet := .F. //Mensagem padrão sistema
		EndIf
	ElseIf "NED_LOTCTL" $ cReadVar
		if !AGDX030(oNED:GetValue('NED_TES'))
			AGDHELP(STR0009,STR0029,STR0030)//"Ajuda","Para o preenchimento deste campo é necessário que o TES movimente estoque.","Escolha uma TES adequada ou crie uma nova no cadastro de Entrada e Saida"
			lRet := .F.
		endif
	Endif

Return lRet

/*/{Protheus.doc} AGD20SDITE
Retorna o saldo disponivel para o item de insumo na linha posicionada na IE
Usado no gatilho(SX7) do campo NED_ITEBRT
@type function
@version  P12
@author claudineia.reinert
@since 07/07/2025
@return numeric, Saldo disponível para a linha
/*/
Function AGD20SDITE()
	Local oModel := FwModelActive() //pega modelo ativo
	Local nSaldo := 0

	//Verifica se o modelo é válido
	If ValType(oModel) == "O" .AND. oModel:GetId() == "AGDA020"
		nSaldo := AGDA020SNED(oModel) - oModel:GetModel():GetValue("AGDA020_NED", "NED_QTDIEB") //Busca o saldo disponivel do item/linha posicionada na instrução de embarque considerando o modelo ativo
	EndIf

Return nSaldo

/*/{Protheus.doc} AGDA020SNED
Busca o saldo disponivel do item de insumo,linha posicionada na instrução de embarque, considerando o modelo ativo
OBS: uma IE pode ter o mesmo item de insumo com lote diferente, por isso é necessário considerar/atualizar o saldo de cada linha que possui o item do insumo
@type function
@version  P12
@author claudineia.reinert
@since 07/07/2025
@param oModel, object, modelo de dados da instrução de ambarque 
@return Numeric, Saldo para a linha
/*/
Function AGDA020SNED(oModel) 
	Local nSaldo := 0
	Local nQtdAloc := 0
	Local nQtdDev := 0
	Local nLinha := 0
	Local nX := 0
	Local oNED := oModel:GetModel("AGDA020_NED")
	Local oNEC := oModel:GetModel("AGDA020_NEC")
	Local oVendaPerdidaRepository := nil
	Local oIEItemRepository := nil
	Local cCodBRT	:= oNED:GetValue("NED_CODBRT") //armazena item barter atual
	Local cIteBRTAtu	:= oNED:GetValue("NED_ITEBRT") //armazena item barter atual

	oVendaPerdidaRepository := NEGOCIO_VENDA_PERDIDA_REPOSITORY():new()
	nSaldo   := oNED:GetValue('NED_QTDNEG') - oVendaPerdidaRepository:sumByNegocioInsumo(cCodBRT, cIteBRTAtu)
	FreeObj(oVendaPerdidaRepository)

	nQtdAloc := fQryItAloc(cCodBRT, cIteBRTAtu, oNEC:GetValue('NEC_CODIGO')) //Busca qtd alocada, desconsiderando IE atual

	oIEItemRepository := INSTRUCAO_EMBARQUE_ITEM_REPOSITORY():new()
	nQtdDev := oIEItemRepository:sumByDevolucaoNegocioInsumo(cCodBRT, cIteBRTAtu)

	nLinha := oNED:GetLine()
	For nX := 1 to oNED:Length()
		//percorre os itens da IE para verificar se tem mesmo insumo em outra linha e caso tiver compor o saldo alocado
		oNED:GoLine( nX )
		If !oNED:IsDeleted() .AND. oNED:GetValue('NED_ITEBRT') == cIteBRTAtu .AND. nLinha != nX //desconsidera linha para o saldo, pois esta sendo validada/editada
			nQtdAloc += oNED:GetValue("NED_QTDIEB")
		EndIf
	Next nX
	oNED:GoLine( nLinha )

	nSaldo := (nSaldo - nQtdAloc) + nQtdDev

return nSaldo

/*/{Protheus.doc} AGD20CPFCLI
Filtro da consulta padrão(SXB) NEDCLI - filtra os dados para o campo cliente NED_CODCLI 
@type function
@version P12.1.2410
@author claudineia.reinert
@since 09/12/2024
@return character, filtro SQL com as condições para retorno
/*/
Function AGD20CPFCLI()
	Local cQrySXB	:=	""
	Local oModel    := FwModelActive()
	Local oNEC		:= oModel:GetModel("AGDA020_NEC")
	Local cQuery	:= ""
	Local cAliQry	:= GetNextAlias()
	Local oStatement 	:= nil
	Local cFiltra	:= ""
	Local oNegocioService := NEGOCIO_SERVICE():New()
	Local cVersaoNegocio := oNegocioService:buscarVersaoAtualValida(oNEC:GetValue("NEC_CODBRT"))

	cQuery := " SELECT  NEB_CLIENT, NEB_LOJENT "
	cQuery += " FROM "+ retSqlName('NEB') +" NEB "
	cQuery += " INNER JOIN "+ retSqlName('NEA') +" NEA ON NEA_FILIAL = NEB_FILIAL AND NEA_CODIGO = NEB_CODBRT AND NEA_STATUS != '6' "
	cQuery += " WHERE NEB_FILIAL = ? "
	cQuery += " AND NEB_CODBRT = ? "
	cQuery += " AND NEB_VERSAO = ? "
	cQuery += " AND NEB.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY NEB_CLIENT, NEB_LOJENT "
	cQuery := ChangeQuery( cQuery )

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1, FWxFilial('NEB'))
	oStatement:SetString(2, oNEC:GetValue("NEC_CODBRT"))
	oStatement:SetString(3, cVersaoNegocio)
	cQuery := oStatement:GetFixQuery()
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliQry,.T.,.T.)

	While !(cAliQry)->(Eof())
		If Empty(cFiltra)
			cFiltra += " AND ( "
			cFiltra += "( A1_COD = '"+(cAliQry)->NEB_CLIENT+"' AND A1_LOJA = '"+(cAliQry)->NEB_LOJENT+"' )"
		Else
			cFiltra += " OR ( A1_COD = '"+(cAliQry)->NEB_CLIENT+"' AND A1_LOJA = '"+(cAliQry)->NEB_LOJENT+"' )"
		EndIf
		(cAliQry)->(DbSkip())
	EndDo
	(cAliQry)->(dbCloseArea())
	if !Empty(cFiltra)
		cFiltra += ")"
	EndIf

	cQrySXB  += "@D_E_L_E_T_ = ' ' "
	cQrySXB  += cFiltra

Return cQrySXB

/*/{Protheus.doc} AGD20ININED
Função de carregamento de dados para campos virtuais X3_RELAÇÃO e X3_INIBRW
@type function
@version P12.1.2410
@author claudineia.reinert
@since 12/13/2024
/*/
Function AGD20ININED()
	Local xRet 		:= nil
	Local cReadVar  := ReadVar()
	Local oNegocioService 		:= nil
	Local cVersaoNegocio := ""

	If "NED_QTDNEG" $ cReadVar
		oNegocioService := NEGOCIO_SERVICE():New()
		cVersaoNegocio := oNegocioService:buscarVersaoAtualValida(NED->NED_CODBRT)
		xRet := IF(!INCLUI,POSICIONE('NEB',1,XFILIAL('NEB')+NED->NED_CODBRT+cVersaoNegocio+NED->NED_ITEBRT,'NEB_QTDVEN'),0)
	ElseIf "NED_QTDSLD" $ cReadVar
		xRet := IF(!INCLUI,AGDA050SLD(NED->NED_CODBRT,NED->NED_ITEBRT),0)
	Endif

Return xRet

/*/{Protheus.doc} AGD20QCIN
Retorna a quantidade de clientes/propriedades vinculados na negociação(NEB) para a entrega de insumos
@type function
@version P12.1.2410
@author claudineia.reinert
@since 10/12/2024
@param cCodFilial, character, Codigo da filial da negociação NEA/NEB
@param cCodNegoc, character, codigo da negociação NEA/NEB
@param cCodNegoc, character, codigo da negociação NEA/NEB
@return numeric, Valor numerico 
/*/
function AGD20QCIN(cCodFilial, cCodNegoc)
	Local nRet 		:= 0
	Local cQuery	:= ""
	Local cAliQry 	:= GetNextAlias()
	Local oStatement 	:= nil
	Local oNegocioService := NEGOCIO_SERVICE():New()
	Local cVersaoNegocio := oNegocioService:buscarVersaoAtualValida(cCodNegoc)

	cQuery := " SELECT COUNT(NEB_CLIENT) AS QTD "
	cQuery += " FROM ( "
	cQuery += " SELECT NEB_CLIENT, NEB_LOJENT "
	cQuery += " FROM "+ retSqlName('NEB') + " NEB "
	cQuery += " WHERE NEB_FILIAL = ? "
	cQuery += " AND NEB.NEB_CODBRT = ? "
	cQuery += " AND NEB.NEB_VERSAO = ? "
	cQuery += " AND NEB.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY NEB_CLIENT, NEB_LOJENT ) AS CLIENTE "

	cQuery := ChangeQuery( cQuery )

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1, cCodFilial)
	oStatement:SetString(2, cCodNegoc)
	oStatement:SetString(3, cVersaoNegocio)
	cQuery := oStatement:GetFixQuery()
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliQry,.T.,.T.)

	If !(cAliQry)->(Eof())
		nRet := (cAliQry)->QTD
	EndIf
	(cAliQry)->(dbCloseArea())

Return nRet


/*/{Protheus.doc} AGD20HIST
Chama função para exibir o historico de ações realizadas em um registro posicionado em tela/tabela.
@type function
@version P12.1.2410 
@author claudineia.reinert
@since 16/12/2024
/*/
Function AGD20HIST()
	Local cChaveI := ""
	Local cChaveA := ""

	cChaveI := "NEC->("+Alltrim(AGDXSIXCHV("NEC", 1))+")"
	cChaveA := &(cChaveI)+Space(Len(NE0->NE0_CHAVE)-Len(&cChaveI))

	AGDXHIST("NEC",cChaveA)

Return

/* {Protheus.doc} AGD20GERAPV
	Gerar Pedido de Venda relacionado a instrução de embarque
	@type  Function
	@author Gilson.Venturi
	@since 25/03/2024
	@version P12.1.2510
*/
Function AGD20GERAPV()
	Local lRet				:= .T.
	Local oIEPedidoService	:= nil

	oIEPedidoService := IE_PEDIDO_SERVICE():new(NEC->NEC_CODIGO)
	if oIEPedidoService:hasPedido()
		AGDHELP(STR0009, STR0026 ) //"Instrução de Embarque já contém pedido de venda gerado"
		lRet := .F.
	endif

	If lRet
		oIEPedidoService := IE_PEDIDO_SERVICE():New(NEC->NEC_CODIGO)
		oIEPedidoService:novoPedido()
		if !oIEPedidoService:isSuccess()
			AGDHELP(STR0009, oIEPedidoService:getMessageError() )
		else
			MsgInfo(STR0031 + " " + oIEPedidoService:getResponse() + " " + STR0032  ) // "Pedido XXXX gerado com sucesso"
		endif
	EndIf

Return

/* {Protheus.doc} AGD20CONSPV
	Consulta Pedido de Venda relacionado a instrução de embarque
	@type  Function
	@author Gilson.Venturi
	@since 16/12/2024
	@version P12.1.2510
*/
Function AGD20CONSPV()
	Local oIEPedidoService := nil
	Private aRotina := { { "", "", 0, 1 }, { "", "", 0, 1 } }

	oIEPedidoService := IE_PEDIDO_SERVICE():New(NEC->NEC_CODIGO)
	if oIEPedidoService:hasPedido()
		SC5->(dBSetOrder(1))	//C5_FILIAL+C5_NUM
		SC5->(dBSeek(xFilial("SC5")+oIEPedidoService:getPedido()))
		A410Visual("SC5",SC5->(RecNo()), 2)
	else
		AGDHELP(STR0009, STR0013 ) //"Nenhum Pedido Vinculado"
	endif

	FreeObj(oIEPedidoService)

return .T.

/*/{Protheus.doc} AGD20EXCLPV
Remover Pedido
@type function
@version 12
@author jean.schulze
@since 30/12/2024
@return variant, nil
/*/
Function AGD20EXCLPV()
	Local oIEPedidoService := nil

	oIEPedidoService := IE_PEDIDO_SERVICE():New(NEC->NEC_CODIGO)
	if oIEPedidoService:hasPedido()
		oIEPedidoService:removerPedido()
		if oIEPedidoService:isSuccess()
			MsgInfo(STR0014, STR0015  ) //"Pedido Removido com Sucesso"  //"Excluir Pedido"
		else
			AGDHELP(STR0009, oIEPedidoService:getMessageError())
		endif
	else
		AGDHELP(STR0009, STR0013  ) //"Nenhum Pedido Vinculado "
	endif

	FreeObj(oIEPedidoService)

return .T.


/*/{Protheus.doc} AGD20FATPV
Faturar Pedido de Venda
@type function
@version 12
@author claudineia.reinert
@since 03/02/2025
@return variant, nil
/*/
Function AGD20FATPV()
	Local oIEPedidoService 	:= nil

	oIEPedidoService := IE_PEDIDO_SERVICE():New(NEC->NEC_CODIGO)
	if oIEPedidoService:hasPedido()
		MsgRun(STR0020,STR0019,{||oIEPedidoService:faturarPedido()}) //#"Aguarde! Processando..." //"Faturar Pedido"
		If  oIEPedidoService:isSuccess()
			MsgInfo(oIEPedidoService:getResponse(), "Faturar Pedido"  ) //#"Faturar Pedido"
		Else
			AGDHELP(STR0019, oIEPedidoService:getMessageError() ) //#"Faturar Pedido"
		EndIf
	else
		AGDHELP(STR0019, STR0013  ) //#"Faturar Pedido" //#"Nenhum Pedido Vinculado "
	endif

	FreeObj(oIEPedidoService)

return .T.

/*/{Protheus.doc} AGD20FBART
Filtro da consulta padrão(SXB) NEA001 - filtra os dados para o campo NEC_CODBRT (Codigo Negociacao) 
@type function
@version P12.1.2410
@author lindembergson.pacheco
@since 19/02/2025
@return character, filtro SQL com as condições para retorno
/*/
Function AGD20FBART()  //REF AGD10CPFPRO
	Local cQry	:=	""

	cQry  += "@D_E_L_E_T_ = ' ' "
	cQry  += 	" AND ( "
	cQry  += 		" NEA_CODIGO  IN ( "
	cQry  += 			" SELECT NEB_CODBRT "
	cQry  += 			" 	FROM ( "
	cQry  += 			" 		SELECT NEB_FILIAL, NEB_CODBRT, NEB_CODPRO,  NEB_QTDVEN, SUM(CASE WHEN NED_QTDIEB > 0 THEN NED_QTDIEB ELSE 0 END) NED_QTDIEB "
	cQry  += 			" 		FROM "+ retSqlName('NEB')+" NEB "
	cQry  += 			" 		INNER JOIN "+ retSqlName('NEA')+" NEA ON NEA.D_E_L_E_T_ = ' ' AND NEA_FILIAL =  NEB_FILIAL AND NEA_CODIGO =  NEB_CODBRT AND NEA_STATUS != '6' AND NEA_STSAUT = '2' AND NEA_VERSAO = NEB_VERSAO "
	cQry  += 			" 		LEFT JOIN "+ retSqlName('NED')+" NED ON NED.D_E_L_E_T_ = ' ' AND NEB_FILIAL = NED_FILIAL AND NEB_CODBRT = NED_CODBRT AND NEB_CODPRO = NED_CODPRO AND NEB_ITEM = NED_ITEBRT "
	cQry  += 			" 		WHERE NEB.D_E_L_E_T_ = ' ' AND NEB_FILIAL = '"+FwxFilial("NEB",FWxFilial("NEA"))+"'   "
	cQry  += 			" 	GROUP BY NEB_FILIAL, NEB_CODBRT, NEB_CODPRO, NEB_QTDVEN "
	cQry  += 			" ) ALIAS "
	cQry  += 			" WHERE NEA_STATUS != '6' AND NEB_QTDVEN > NED_QTDIEB "
	cQry  += 			" GROUP BY NEB_CODBRT "
	cQry  += 		" )"
	cQry  += 	" )"

Return cQry


/*/{Protheus.doc} AGDAGFRETE
Calcula o frete baseado no valor a instruir
@type function
@version P12
@author scheronlini.martins
@since 09/04/2025
@return numeric, return_valor do frete instruido
/*/
function AGDAGFRETE()
	Local oModel     := FwModelActive()
	Local oNED		 := oModel:GetModel("AGDA020_NED")
	Local cCodBRT    := oNED:Getvalue("NED_CODBRT")
	Local cIteBRT    := oNED:Getvalue("NED_ITEBRT")
	Local cQuery     := ""
	Local oStatement := nil
	Local cVersao    := ""
	Local aFrete
	Local nFrete
	Local oNegocioService
	Local oRepositoryUtils := REPOSITORY_UTILS():New()
	Local nFreteInst


	oNegocioService := NEGOCIO_SERVICE():New()
	cVersao := oNegocioService:buscarVersaoAtualValida(cCodBRT)

	cQuery := " SELECT NEB_FRETE"
	cQuery += " FROM "+ retSqlName('NEB') +" NEB "
	cQuery += " WHERE NEB_FILIAL = ? "
	cQuery += " AND NEB_CODBRT = ? "
	cQuery += " AND NEB_VERSAO = ? "
	cQuery += " AND NEB_ITEM = ? "
	cQuery += " AND NEB.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery( cQuery )

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1, FWxFilial('NEB'))
	oStatement:SetString(2, cCodBRT)
	oStatement:SetString(3, cVersao)
	oStatement:SetString(4, cIteBRT)
	cQuery := oStatement:GetFixQuery()


	if len(oRepositoryUtils:freeQueryToArray(cQuery, {"NEB_FRETE"})) > 0
		aFrete := oRepositoryUtils:freeQueryToArray(cQuery, {"NEB_FRETE"})
		nFrete := aFrete[1]:getJsonObject("NEB_FRETE")
	ENDIF

	nFreteInst := Round((nFrete / oNED:Getvalue("NED_QTDNEG")) * oNED:Getvalue("NED_QTDIEB"), TamSX3("NED_FRETE")[2])

Return nFreteInst

