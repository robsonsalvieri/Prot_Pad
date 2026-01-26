#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'WMSA020.CH'

#DEFINE WMSA02001 "WMSA02001"
#DEFINE WMSA02002 "WMSA02002"
#DEFINE WMSA02003 "WMSA02003"

//----------------------------------------------------------
/*/{Protheus.doc} WMSA020 - Cadastro de Normas

@author  SIGAWMS
@version P11
@since   25/02/15
/*/
//----------------------------------------------------------
Function WMSA020()
Local oBrowse
	If AMiIn(39,42) // Somente autorizado para OMS e WMS
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('DC2')         // Alias da tabela utilizada
		oBrowse:SetDescription(STR0001) // Descrição do browse "Cadastro de Normas"
		oBrowse:SetMenuDef('WMSA020')   // Nome do fonte onde esta a função MenuDef
		oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
		oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
		oBrowse:Activate()
	EndIf
Return
//----------------------------------------------------------
// Função MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0009 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA020' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.WMSA020' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.WMSA020' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.WMSA020' OPERATION 5 ACCESS 0 // Excluir
Return aRotina
//----------------------------------------------------------
// Função ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel := MPFormModel():New('WMSA020',,{|oModel|ValidMld(oModel)})
Local oStruDC2 := FWFormStruct(1, 'DC2')
	oModel:AddFields('DC2MASTER', /*cOwner*/, oStruDC2)
Return oModel
//----------------------------------------------------------
// Função ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('WMSA020')
Local oView    := FWFormView():New()
Local oStruDC2 := FWFormStruct(2, 'DC2')
	oView:SetModel(oModel)
	oView:AddField('VIEWDC2', oStruDC2, 'DC2MASTER')
Return oView
//----------------------------------------------------------
// Função de validação do modelo antes da efetivação do commit
//----------------------------------------------------------
Static Function ValidMld(oModel)
Local lRet      := .T.
Local oModelDC2 := oModel:GetModel('DC2MASTER')
Local nNormaAnt := 0
Local nNormaNov := 0
	If oModelDC2:GetOperation() == MODEL_OPERATION_UPDATE
		//Calcula quantidade atual e nova quantidade da norma
		nNormaAnt := DC2->DC2_LASTRO * DC2->DC2_CAMADA
		nNormaNov := oModelDC2:GetValue('DC2_LASTRO') * oModelDC2:GetValue('DC2_CAMADA')
		//Se o usuário alterou o valor da norma e esta norma possuí saldo em endereço, mostra mensagem de alerta e solicita confirmação
		If !(QtdComp(nNormaAnt) == QtdComp(nNormaNov)) .And. !ValidSaldo(oModelDC2:GetValue('DC2_CODNOR'))
			If QtdComp(nNormaAnt) > QtdComp(nNormaNov)
				/*
					[STR0010] Existe saldo em estoque para a norma [VAR01].
					[STR0011] Ao alterar a norma para uma quantidade menor poderão ocorrer as seguintes divergências nos processos WMS:
					[STR0012] 1. Nas estruturas em que a sequência de abastecimento estiver configurada com o tipo de separação 1-Somente Norma poderá ocorrer saldo restante no endereço ao realizar separações.
					[STR0014] 2. Nas  estruturas em que a sequência de abastecimento estiver configurada com o tipo de separação 2-Saldo Restante poderá ocorrer que as próximas separações gerem duas movimentações para um mesmo endereço, sendo uma considerando a parte da norma e a outra com o saldo restante.
				*/
				WmsMessage( WmsFmtMsg(STR0010,{{"[VAR01]",oModelDC2:GetValue("DC2_CODNOR")}})+ CRLF + CRLF +;
							STR0011+ CRLF + CRLF +;
							STR0012+ CRLF +;
							STR0014, WMSA02002)
			Else
				/*
					[STR0010] Existe saldo em estoque para a norma [VAR01].
					[STR0017] Ao alterar a norma para uma quantidade maior poderão ocorrer as seguintes divergências nos processos WMS:
					[STR0018] 1. Nos próximos recebimentos poderá ocorrer a distribuição de quantidades de forma a completar os paletes já armazenados nas estruturas em que a sequência de abastecimento estiver configurada com o tipo de endereçamento 2-Endereços Parc. Cheios. Tal comportamento pode ser evitado alterando a sequência de abastecimento para o tipo de endereçamento 1-Endereços Vazios.
					[STR0021] 2. Nas próximas separações poderá ocorrer que o saldo nas estruturas em que a sequência de abastecimento estiver configurada com o tipo de separação 1-Somente Norma seja ignorado. Tal comportamento pode ser evitado alterando a sequência de abastecimento para o tipo de separação 2-Saldo Restante.
				*/
				WmsMessage( WmsFmtMsg(STR0010,{{"[VAR01]",oModelDC2:GetValue("DC2_CODNOR")}})+ CRLF + CRLF +;
							STR0017+ CRLF + CRLF +;
							STR0018+ CRLF +;
							STR0021, WMSA02003)
			EndIf
		EndIf
	ElseIf oModelDC2:GetOperation() == MODEL_OPERATION_DELETE
		If !ValidSaldo(oModelDC2:GetValue('DC2_CODNOR'))
			oModelDC2:GetModel():SetErrorMessage(oModelDC2:GetId(),,,,WMSA02001,STR0022)//Não é permitida a exclusão de normas com saldo em estoque.
			lRet := .F.
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------
// Função de validação para avaliar se possui saldo
// no armazém para estruturas que utilizam a norma
//----------------------------------------------------------
Static Function ValidSaldo(cCodNor)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local lReturn   := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW", .F., .F.)
	If !lWmsNew
		// Avalia se possui saldo no armazém para estrturas que utilizam esta norma
		// Neste caso não pode deixar alterar o lastro x camada
		cQuery := "SELECT DISTINCT 1 SBF_EXISTE"
		cQuery +=  " FROM "+RetSqlName("DC3")+" DC3"
		cQuery += " INNER JOIN "+RetSqlName("SBF")+" SBF"
		cQuery +=    " ON SBF.BF_FILIAL = '"+xFilial("SBF")+"'"
		cQuery +=   " AND SBF.BF_LOCAL = DC3_LOCAL"
		cQuery +=   " AND SBF.BF_ESTFIS = DC3_TPESTR"
		cQuery +=   " AND SBF.BF_PRODUTO = DC3_CODPRO"
		cQuery += " WHERE DC3_FILIAL = '"+xFilial("DC3")+"'"
		cQuery +=   " AND DC3_CODNOR = '"+cCodNor+"'"
		cQuery +=   " AND SBF.BF_QUANT > 0"
		cQuery +=   " AND DC3.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SBF.D_E_L_E_T_ = ' '"
	Else
		// Avalia se possui saldo no armazém para estrturas que utilizam esta norma
		// Neste caso não pode deixar alterar o lastro x camada
		cQuery := " SELECT DISTINCT 1 D14_EXISTE"
		cQuery +=   " FROM "+RetSqlName("DC3")+" DC3"
		cQuery +=  " INNER JOIN "+RetSqlName("D14")+" D14"
		cQuery +=     " ON D14.D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=    " AND D14.D14_LOCAL = DC3_LOCAL"
		cQuery +=    " AND D14.D14_ESTFIS = DC3_TPESTR"
		cQuery +=    " AND D14.D14_PRODUT = DC3_CODPRO"
		cQuery +=  " WHERE DC3_FILIAL = '"+xFilial("DC3")+"'"
		cQuery +=    " AND DC3_CODNOR = '"+cCodNor+"'"
		cQuery +=    " AND D14.D14_QTDEST > 0"
		cQuery +=    " AND DC3.D_E_L_E_T_ = ' '"
		cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
	EndIf
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Bof() .And. !Eof())
		lReturn := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lReturn
