#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LOJA8010.CH"

Static __aPrepared := {} as array

//--------------------------------------------------------------------
/*/{Protheus.doc} LOJA8010
Cadastro de Regiões de Filiais (Agrupamento de Filiais)

@type    function
@author  Squad Retail / Jesus S. Junior
@since   08/2026
@version 1.0
@return  Nil
/*/
//--------------------------------------------------------------------
Function LOJA8010()
	Local oBrowse as object
	Private aRotina := MenuDef() as array

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("MGE")
	oBrowse:SetDescription(STR0001) // "Regiões de Filiais"
	oBrowse:DisableDetails()
	oBrowse:Activate()
Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Operacoes disponiveis: Incluir, Alterar, Visualizar, Excluir e Copiar.

@type    Static Function
@author  Squad Retail / Jesus S. Junior
@since   08/2026
@return  array, Estrutura de menu do MVC
/*/
//--------------------------------------------------------------------
Static Function MenuDef() as array
	Local aRotina := {} as array

	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.LOJA8010" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.LOJA8010" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.LOJA8010" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0007  ACTION "VIEWDEF.LOJA8010" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE STR0008  ACTION "VIEWDEF.LOJA8010" OPERATION 9                      ACCESS 0 // "Copiar"

Return aRotina

//--------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados master-detail MGE (regiao) e MGF (filiais da regiao).

@type    Static Function
@author  Squad Retail / Jesus S. Junior
@since   08/2026
@return  object, Objeto FWFormModel
/*/
//--------------------------------------------------------------------
Static Function ModelDef() as object
	Local oModel  as object
	Local oStrMGE := FWFormStruct(1, "MGE") as object
	Local oStrMGF := FWFormStruct(1, "MGF") as object
	Local oEvent  := LJ8010EVDEF():New() as object

	oModel := MPFormModel():New("LOJA8010")

	oModel:AddFields("MGE_MASTER", /*cOwner*/, oStrMGE)
	oModel:AddGrid("MGF_DETAIL", "MGE_MASTER", oStrMGF)

	oModel:SetRelation("MGF_DETAIL", {{"MGF_FILIAL", "xFilial('MGF')"}, {"MGF_COD", "MGE_COD"}}, "MGF_FILIAL+MGF_COD+MGF_CODFIL")

	oModel:SetPrimaryKey({"MGE_FILIAL", "MGE_COD"})
	oModel:GetModel("MGF_DETAIL"):SetUniqueLine({"MGF_CODFIL"})
	oModel:GetModel("MGF_DETAIL"):SetOptional(.T.)

	oModel:SetDescription(STR0001) // "Regiões de Filiais"
	oModel:GetModel("MGE_MASTER"):SetDescription(STR0001) // "Regiões de Filiais"
	oModel:GetModel("MGF_DETAIL"):SetDescription(STR0002) // "Filiais da Região"

	oModel:InstallEvent("LJ8010EVDEF", /*cOwner*/, oEvent)

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface do cadastro: cabecalho (MGE) + grid de filiais (MGF).

@type    Static Function
@author  Squad Retail / Jesus S. Junior
@since   08/2026
@return  object, Objeto FWFormView
/*/
//--------------------------------------------------------------------
Static Function ViewDef() as object
	Local oView   as object
	Local oModel  := FWLoadModel("LOJA8010") as object
	Local oStrMGE := FWFormStruct(2, "MGE") as object
	Local oStrMGF := FWFormStruct(2, "MGF") as object

	// Oculta campos que nao devem aparecer na tela de cadastro
	oStrMGE:RemoveField("MGE_QTFIL")
	oStrMGF:RemoveField("MGF_COD")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_MGE", oStrMGE, "MGE_MASTER")
	oView:AddGrid("VIEW_MGF" , oStrMGF, "MGF_DETAIL")

	oView:CreateHorizontalBox("BOX_SUP", 35)
	oView:CreateHorizontalBox("BOX_INF", 65)

	oView:SetOwnerView("VIEW_MGE", "BOX_SUP")
	oView:SetOwnerView("VIEW_MGF", "BOX_INF")

	oView:EnableTitleView("VIEW_MGF", STR0002) // "Filiais da Região"

Return oView

//--------------------------------------------------------------------
/*/{Protheus.doc} LJ8010EVDEF
Eventos do cadastro de Regioes de Filiais.
Concentra pos-validacao do modelo, commit e todas as regras de negocio
Documentacao sobre eventos do MVC:
http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type    Class
@author  Squad Retail / Jesus S. Junior
@since   08/2026
@version 1.0
/*/
//--------------------------------------------------------------------
CLASS LJ8010EVDEF From FWModelEvent

	METHOD New()        CONSTRUCTOR
	METHOD ModelPosVld()

ENDCLASS

//--------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da classe LJ8010EVDEF.

@type    Method
@author  Squad Retail / Jesus S. Junior
@since   08/2026
/*/
//--------------------------------------------------------------------
Method New() Class LJ8010EVDEF
Return Self

//--------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Pos-validacao do modelo antes do commit.
Exige ao menos uma filial ativa e valida na regiao.

@type    Method
@author  Squad Retail / Jesus S. Junior
@since   08/2026
@param   oModel, object, Modelo de dados
@param   cID,    character, Identificador do modelo
@return  logical, .T. se os dados estao validos
/*/
//--------------------------------------------------------------------
Method ModelPosVld(oModel, cID) Class LJ8010EVDEF
	Local lRet       := .T. as logical
	Local nQtdLinhas := 0 as numeric
	Local nI         := 0 as numeric
	Local oMdlMGF    as object

	Default oModel := Nil

	If oModel <> Nil

		oMdlMGF := oModel:GetModel("MGF_DETAIL")

		For nI := 1 To oMdlMGF:Length()
			If !oMdlMGF:IsDeleted(nI) .And. !Empty(oMdlMGF:GetValue("MGF_CODFIL", nI))
				nQtdLinhas++
			EndIf
		Next nI

		If nQtdLinhas == 0
			Help(, , "LJ8010EVDEF", , STR0003, 1, 0) // "Informe ao menos uma filial para a região"
			lRet := .F.
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} L8010QtF
Conta quantas filiais compoe a regiao,
garantindo contagem correta mesmo quando a sessao esta em outra filial.

Obs: Usado no X3_RELACAO e X3_INIBRW do campo MGE_QTFIL

@type    Function
@author  Squad Retail / Jesus S. Junior
@since   08/2026
@param   cCodReg, character, Codigo da regiao
@return  numeric, Quantidade de filiais da regiao
/*/
//--------------------------------------------------------------------
Function L8010QtF(cCodReg as character) as numeric
	Local nQtd      := 0 as numeric
	Local cFilBusca := "" as character
	Local aArea     as array

	Default cCodReg := ""

	If !Empty(cCodReg)
		cFilBusca := MGE->MGE_FILIAL

		aArea := MGF->(GetArea())

		DbSelectArea("MGF")
		MGF->(DbSetOrder(1)) // MGF_FILIAL+MGF_COD+MGF_CODFIL
		If MGF->(DbSeek(cFilBusca + cCodReg))
			While !MGF->(Eof()) .And. MGF->MGF_FILIAL == cFilBusca .And. MGF->MGF_COD == cCodReg
				nQtd++
				MGF->(DbSkip())
			EndDo
		EndIf
		RestArea(aArea)
	EndIf

Return nQtd

//--------------------------------------------------------------------
/*/{Protheus.doc} L8010VlFil
Verifica se a filial ja pertence a outro(s) agrupamento(s).
Em caso positivo informa quais e solicita confirmacao.

Obs: Usado no X3_VALID do campo MGF_CODFIL

@type    Function
@author  Squad Retail / Jesus S. Junior
@since   08/2026
@return  logical, .T. mantem a filial / .F. rejeita
/*/
//--------------------------------------------------------------------
Function L8010VlFil() as logical
	Local oModel     := FwModelActive() as object
	Local lRet       := .T. as logical
	Local cCodFil    := "" as character
	Local cNomeFil   := "" as character
	Local cMsgCodFil := "" as character
	Local cCodReg    := "" as character
	Local cRegs      := "" as character
	Local cNomeReg   := "" as character
	Local cCodMGF    := "" as character
	Local cFilMGF    := "" as character
	Local nQtd       := 0 as numeric
	Local nI         := 0 as numeric
	Local aCodRegs   := {} as array
	Local aArea      as array

	cCodFil := M->MGF_CODFIL

	If !Empty(cCodFil)

		// Valida se a filial informada existe no cadastro de filiais (SM0)
		If !ExistCpo("SM0", cEmpAnt + cCodFil)
			lRet := .F.
		EndIf

		If lRet .And. oModel != Nil
			cCodReg := oModel:GetValue("MGE_MASTER", "MGE_COD")
		EndIf

		cFilMGF := xFilial("MGF")

		If lRet
			aArea := MGF->(GetArea())
			DbSelectArea("MGF")

			// Busca todos os registros independentemente da filial corrente,
			// pois uma filial pode pertencer a agrupamentos de outras filiais/empresas.
			MGF->(DbSetOrder(1)) // MGF_FILIAL+MGF_COD+MGF_CODFIL
			MGF->(DbGoTop())
			While !MGF->(Eof())
				If MGF->MGF_CODFIL == cCodFil
					If MGF->MGF_COD != cCodReg .Or. MGF->MGF_FILIAL != cFilMGF
						// Guarda sem AllTrim para preservar o padding da chave do indice MGE
						aAdd(aCodRegs, {MGF->MGF_COD, MGF->MGF_FILIAL})
					EndIf
				EndIf
				MGF->(DbSkip())
			EndDo
			RestArea(aArea)

			// Segunda passada: busca o nome de cada agrupamento encontrado
			nQtd := Len(aCodRegs)
			If nQtd > 0
				aArea := MGE->(GetArea())
				DbSelectArea("MGE")
				MGE->(DbSetOrder(1)) // MGE_FILIAL+MGE_COD
				For nI := 1 To nQtd
					cCodMGF  := aCodRegs[nI][1]
					cNomeReg := ""
					If MGE->(DbSeek(aCodRegs[nI][2] + cCodMGF))
						cNomeReg := AllTrim(MGE->MGE_NOME)
					EndIf
					cRegs += AllTrim(cCodMGF) + " - " + cNomeReg + CRLF
				Next nI
				RestArea(aArea)
			EndIf

			If nQtd > 0
				If !IsBlind()
					cNomeFil   := Posicione("SM0", 1, cEmpAnt + M->MGF_CODFIL, "M0_FILIAL")
					cMsgCodFil := AllTrim(cCodFil) + " - " + AllTrim(cNomeFil)
					lRet       := MsgYesNo(I18n(STR0009, {cMsgCodFil, CRLF, cRegs}, STR0010)) // "A filial #1 já pertence ao(s) agrupamento(s):#2#3#2Deseja adicioná-la mesmo assim?" # "Ateno"
				EndIf
			EndIf

		EndIf 
	EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} L8010NmFil
Retorna o nome da filial para inicializar MGF_NOMFIL e MGF_UF.

Quando a chamada vem da acao ADDLINE (nova linha no grid), retorna ""
para evitar herdar o nome da linha anterior.

Obs: Usada no X3_RELACAO dos campos MGF_NOMFIL e MGF_UF

@type    Function
@author  Squad Retail / Jesus S. Junior
@since   08/2026
@return  character, Nome da filial ou "" se linha nova / filial vazia
/*/
//--------------------------------------------------------------------
Function L8010IniCp(cCampo as Character) as character
	Local cRet    := "" as character
	Local cCodFil := "" as character
	Local cCpoRet := "" as character

	Default cCampo := ""

	If !Empty(cCampo)
		If !FwIsInCallStack("ADDLINE") // Inclusão de linha no grid — nesse caso retorna vazio para nao copiar o valor anterior.
			If cCampo == "MGF_NOMFIL"
				cCpoRet := "M0_FILIAL"
			ElseIf cCampo == "MGF_UF"
				cCpoRet := "M0_ESTENT"
			EndIf
	
			cCodFil := MGF->MGF_CODFIL
			If !Empty(cCodFil)
				cRet := Posicione("SM0", 1, cEmpAnt + cCodFil, cCpoRet)
			EndIf
		EndIf
	EndIf

Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} L8010QtdAg
Conta em quantos agrupamentos distintos a filial ja esta usada

Obs: Usada no X3_RELACAO do campo MGF_AGRUP e 
           no gatilho do campo MGF_CODFIL para o MGF_AGRUP

@type    Function
@author  Squad Retail / Jesus S. Junior
@since   08/2026
@param   cCodFil, character, Codigo da filial membro
@return  numeric, Quantidade de agrupamentos da filial
/*/
//--------------------------------------------------------------------
Function L8010QtdAg(cCodFil as character) as numeric
	Local nQtd      := 0 as numeric
	Local cFilBusca := FwxFilial("MGF") as character
	Local cQuery    := "" as character
	Local cAliasQry := "" as character
	Local oQry      := Nil as object
	Local nParam    := 0 as numeric

	Default cCodFil := ""

	If !Empty(cCodFil) .And. !FwIsInCallStack("ADDLINE")

		cQuery := "SELECT COUNT(1) AS QTDAG"
		cQuery +=  " FROM " + RetSqlName("MGF") + " MGF "
		cQuery += " WHERE MGF.MGF_FILIAL = ?" // #1
		cQuery +=   " AND MGF.MGF_CODFIL = ?" // #2
		cQuery +=   " AND MGF.D_E_L_E_T_ = ?" // #3

		oQry := L8010GetQry(cQuery)

		nParam := 1
		oQry:SetString(nParam++, cFilBusca) // #1
		oQry:SetString(nParam++, cCodFil)   // #2
		oQry:SetString(nParam++, Space(1))  // #3

		cAliasQry := GetNextAlias()
		oQry:OpenAlias(cAliasQry)

		If !(cAliasQry)->(Eof())
			nQtd := (cAliasQry)->QTDAG
		EndIf
		(cAliasQry)->(DbCloseArea())

	EndIf

Return nQtd

//--------------------------------------------------------------------
/*/{Protheus.doc} L8010GetQry
Cache de statements preparados do LOJA8010.
Evita recompilar a mesma query a cada chamada: verifica o MD5 do texto
e reutiliza o FWExecStatement ja existente quando a query e identica.

@type    Static Function
@author  Squad Retail / Jesus S. Junior
@since   08/2026
@param   cQuery, character, Texto SQL com placeholders (?)
@return  object, Objeto FWExecStatement pronto para receber parametros
/*/
//--------------------------------------------------------------------
Static Function L8010GetQry(cQuery as character) as object
	Local oPrepared    := Nil as object
	Local nPosPrepared := 0 as numeric
	Local cMD5         := "" as character

	Default cQuery := ""

	cMD5 := MD5(cQuery)

	If (nPosPrepared := Ascan(__aPrepared, {|x| x[2] == cMD5})) == 0
		cQuery := ChangeQuery(cQuery)
		Aadd(__aPrepared, {FWExecStatement():New(cQuery), cMD5})
		nPosPrepared := Len(__aPrepared)
	EndIf

	oPrepared := __aPrepared[nPosPrepared][1]

Return oPrepared
