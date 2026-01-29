#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ESTA012.CH"

PUBLISH MODEL REST NAME ESTA012 SOURCE ESTA012

Static __cResultF3 := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ESTA012
Configurador de características

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12
/*/
//-------------------------------------------------------------------
Function ESTA012()
	Local oBrowse As Object

	// Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("D4V")
	oBrowse:SetDescription(STR0007) // "Configurador de características de produto"
	oBrowse:DisableDetails()

	// Ativa a Browse
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12

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

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina As Array

	aRotina := {}

	aAdd(aRotina, {STR0001, "PesqBrw"        , 0, 1, 0, .T. }) // "Pesquisar"
	aAdd(aRotina, {STR0002, "VIEWDEF.ESTA012", 0, 2, 0, NIL }) // "Visualizar"
	aAdd(aRotina, {STR0003, "VIEWDEF.ESTA012", 0, 3, 0, NIL }) // "Incluir"
	aAdd(aRotina, {STR0004, "VIEWDEF.ESTA012", 0, 4, 0, NIL }) // "Alterar"
	aAdd(aRotina, {STR0005, "VIEWDEF.ESTA012", 0, 5, 0, NIL }) // "Excluir"
	aAdd(aRotina, {STR0006, "VIEWDEF.ESTA012", 0, 8, 0, NIL }) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do Configurador de Características

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12

@return  oModel - Modelo de dados
@obs     D4VMASTER - Dados principais
         D4WDETAIL - Características - Lista de Opções

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     As Object
	Local oStruD4V   As Object
	Local oStruD4W   As Object
	Local oEventMain As Object
	Local aRelD4W    As Array

	oEventMain := ESTA012EVDEF():New()

	oStruD4V   := FWFormStruct(1, "D4V")
	oStruD4W   := FWFormStruct(1, "D4W")

	oStruD4W:SetProperty("D4W_VALOR" , MODEL_FIELD_OBRIGAT, .T.) // Define o campo Valor como obrigatório

	// Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("ESTA012", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields("D4VMASTER", /*cOwner*/, oStruD4V)
	oModel:AddGrid("D4WDETAIL", "D4VMASTER", oStruD4W, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)

	oModel:GetModel("D4WDETAIL"):SetUniqueLine({"D4W_VALOR"})  // Define o campo D4W_VALOR como chave única do detalhe D4WDETAIL

	aRelD4W := {}

	// Fazendo o relacionamento (D4V e D4W)
	aAdd(aRelD4W, {"D4W_FILIAL", "FWxFilial('D4W')"} )
	aAdd(aRelD4W, {"D4W_CODATR", "D4V_COD"})
	oModel:SetRelation("D4WDETAIL", aRelD4W, D4W->(IndexKey(1)))

	oModel:SetOptional("D4WDETAIL", .T. ) // Define o detalhe D4WDETAIL como opcional no modelo de dados

	oModel:InstallEvent('ESTA012EVDEF', /*cOwner*/, oEventMain)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Configurador de características

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12

@return oView - View de dados
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView    As Object
	Local oModel   As Object
	Local oStruD4V As Object
	Local oStruD4W As Object
	
	oModel   := FWLoadModel("ESTA012")
	oStruD4V := FWFormStruct(2, "D4V")
	oStruD4W := FWFormStruct(2, "D4W")

	// Removendo campos de chave estrangeira que fazem parte do relacionamento
	oStruD4V:RemoveField("D4V_COD")
	oStruD4W:RemoveField("D4W_CODATR")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Redefinindo os títulos dos campos para melhorar a usabilidade
	oStruD4V:SetProperty("D4V_TIPO" , MVC_VIEW_TITULO, STR0008) // "Tipo de característica"
	oStruD4V:SetProperty("D4V_TPSEL", MVC_VIEW_TITULO, STR0009) // "Tipo de seleção"
	oStruD4V:SetProperty("D4V_F3"    , MVC_VIEW_TITULO, STR0011) // "Consulta Padrão"
	
	oStruD4V:SetProperty("D4V_NOME"  , MVC_VIEW_INSERTLINE, .T.) // Faz uma quebra de linha após o campo D4V_NOME
	oStruD4V:SetProperty("D4V_TPSEL", MVC_VIEW_INSERTLINE, .T.) // Faz uma quebra de linha após o campo D4V_TPSEL
	
	oView:AddField("VIEW_D4V", oStruD4V, "D4VMASTER")
	oView:AddGrid("VIEW_D4W",  oStruD4W, "D4WDETAIL")
	
	// Partes da tela
	oView:CreateHorizontalBox("CABEC_D4V", 50)
	oView:CreateHorizontalBox("BOTTOM_D4W", 50)
	
	oView:SetOwnerView("VIEW_D4V", "CABEC_D4V")
	oView:SetOwnerView("VIEW_D4W", "BOTTOM_D4W")
	
	oView:EnableTitleView("VIEW_D4V", STR0012) // "Características"
	oView:EnableTitleView("VIEW_D4W", STR0013) // "Lista de opções"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ESTA012EVDEF
Eventos padrão do cadastro de Configurador de características

As regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type    Class
@author  Jorge Martins
@since   03/11/2025
@version 12
 
/*/
//-------------------------------------------------------------------
CLASS ESTA012EVDEF From FWModelEvent
	DATA nOpc As Numeric

	METHOD New() CONSTRUCTOR

	METHOD ModelPosVld()
	METHOD E012VlCpos()
	METHOD E012VldDup()

ENDCLASS

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe ESTA010EVDEF

@type    Method
@author  Jorge Martins
@since   03/11/2025
@version 12
/*/
//-------------------------------------------------------------------------------------------------------------
Method New() Class ESTA012EVDEF
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método de validação do modelo antes da gravação dos dados

@type    Method
@author  Jorge Martins
@since   03/11/2025
@version 12
@param   oModel - Modelo de dados de regras de dias de antecedência para vencimento
@param   cID    - Identificador do modelo
@return  lValid - .T. se os dados estão válidos e podem ser gravados

/*/
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel, cID) CLASS ESTA012EVDEF
	Local lValid As Logical

	lValid := .T.

	::nOpc := oModel:GetOperation()
	
	If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
		If lValid
			lValid := ::E012VlCpos(oModel) // Valida se os valores dos campos estão corretos
		EndIf
		
		If lValid
			lValid := ::E012VldDup(oModel) // Valida se existe duplicidade
		EndIf
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} E012VlCpos
Método de validação dos valores dos campos

@type    Method
@author  Jorge Martins
@since   03/11/2025
@version 12
@param   oModel - Modelo de dados de parâmetros para características de produto
@return  lValid - .T. se os dados estão válidos e podem ser gravados

/*/
//-------------------------------------------------------------------
METHOD E012VlCpos(oModel) CLASS ESTA012EVDEF
	Local lValid     As Logical
	Local cProblema  As Character
	Local cSolucao   As Character
	Local cRotina    As Character
	Local oGridLista As Object
	Local nQtdLinha  As Numeric
	Local nLinha     As Numeric
	Local nLinhaVld  As Numeric

	lValid    := .T.
	nLinhaVld := 0
	cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
	
	If oModel:GetValue("D4VMASTER", "D4V_TIPO") == "1" // Se o tipo for Lista de Opções
		oGridLista  := oModel:GetModel("D4WDETAIL")
		nQtdLinha   := oGridLista:GetQtdLine()
		
		For nLinha := 1 To nQtdLinha // Verifica se existe pelo menos uma linha preenchida no detalhe
			If !oGridLista:IsDeleted(nLinha) .And. !Empty(oGridLista:GetValue("D4W_VALOR", nLinha))
				nLinhaVld++
			EndIf
		Next

		If nLinhaVld == 0 // Se não existir nenhuma linha preenchida no detalhe
			lValid    := .F.
			cProblema := STR0028 // "Deve existir pelo menos uma opção na lista de opções."
			cSolucao  := STR0029 // "Inclua pelo menos uma opção na lista de opções."
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		EndIf
	
	Else // Se o tipo for diferente de Lista de Opções
		oGridLista  := oModel:GetModel("D4WDETAIL")
		nQtdLinha   := oGridLista:GetQtdLine()
		If nQtdLinha > 0
			For nLinha := 1 To nQtdLinha
				If !oGridLista:IsDeleted(nLinha) .And. !Empty(oGridLista:GetValue("D4W_VALOR", nLinha))
					lValid    := .F.
					cProblema := STR0037 // "Não pode haver opções cadastradas para o tipo de característica selecionada."
					cSolucao  := STR0038 // "Exclua as opções cadastradas ou altere o tipo de característica para 'Lista de Opções'."
					Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
					Exit
				EndIf
			Next nI
		EndIf
	EndIf

	If lValid .And. oModel:GetValue("D4VMASTER", "D4V_TIPO") == "2" // Se o tipo for Consulta Padrão
		If Empty(oModel:GetValue("D4VMASTER", "D4V_F3"))
			lValid    := .F.
			cProblema := STR0030 // "O código da consulta padrão não foi informado."
			cSolucao  := STR0031 // "Informe o código da consulta padrão."
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		EndIf
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} E012F3SXB
Monta a consulta padrão de Consultas

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12
@return  lRet - .T. se a consulta foi executada com sucesso
/*/
//-------------------------------------------------------------------
Function E012F3SXB()
	Local oModalDlg As Object
	Local oColumn   As Object
	Local oList     As Object
	Local aList     As Array
	Local aSeek     As Array
	Local lRet      As Logical

	lRet := .T.

	oModalDlg := FWDialogModal():New()
	oModalDlg:setSize(200, 500)
	oModalDlg:SetTitle(STR0014) // "Consultas"
	oModalDlg:SetEscClose(.T.) // Permite fechar a tela com a tecla ESC
	oModalDlg:CreateDialog()

	// Campos de busca
	aSeek := {}
	Aadd(aSeek, {STR0015, {{"", "C", 6 , 0, STR0015, "@!", "XB_ALIAS" }}}) // "Consulta"  ### "Consulta"
	Aadd(aSeek, {STR0016, {{"", "C", 20, 0, STR0016, "@!", "XB_DESCRI"}}}) // "Descrição" ### "Descrição"

	aList := E012ListSXB() // Busca a lista de SXB

	oList := FWBrowse():New(oModalDlg:GetPanelMain())
	oList:SetDataArray()
	oList:SetArray(aList)
	oList:DisableConfig()
	oList:DisableReport()
	oList:SetSeek(, aSeek)
	oList:SetOwner(oModalDlg:GetPanelMain())
	oList:SetDoubleClick( {|| lRet := .T., E012SetF3(aList[oList:At()][1]), oModalDlg:Deactivate(), oList:DeActivate() } )

	oColumn := FWBrwColumn():New(); oColumn:SetData({||aList[oList:At()][1]}); oColumn:SetTitle(STR0015); oColumn:SetSize(035); oList:SetColumns({oColumn}) // "Consulta" 
	oColumn := FWBrwColumn():New(); oColumn:SetData({||aList[oList:At()][2]}); oColumn:SetTitle(STR0016); oColumn:SetSize(015); oList:SetColumns({oColumn}) // "Descrição"

	oList:Activate()

	oModalDlg:AddOkButton( {|| lRet := .T., E012SetF3(aList[oList:At()][1]), oModalDlg:Deactivate(), oList:DeActivate() }, STR0017) // "Confirmar"
	oModalDlg:AddCloseButton( {|| lRet := .F., oModalDlg:Deactivate(), oList:DeActivate() }, STR0018) // "Fechar"
	oModalDlg:Activate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} E012ListSXB
Monta a lista de SXB para consulta padrão de Consultas

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12
@return  aSXB - Array com a lista de SXB
/*/
//-------------------------------------------------------------------
Static Function E012ListSXB()
	Local aList    As Array
	Local aArea    As Array
	Local aAreaSXB As Array
	Local aSXB     As Array
	Local cFiltro  As Character

	aArea    := GetArea()
	aAreaSXB := SXB->( GetArea() )
	aList    := {}
	aSXB     := {}

	cFiltro  := "SXB->XB_ALIAS <> 'RETSXB' .And. SXB->XB_TIPO == '1' .And. SXB->XB_CONTEM <> ''"
	
	SXB->(DbSetFilter({|| &cFiltro }, cFiltro))
	SXB->(dbGoTop())

	While !SXB->(Eof())
		Aadd(aSXB, {SXB->XB_ALIAS, SXB->(XBDescri())})
		SXB->(DbSkip())
	EndDo

	RestArea(aAreaSXB)
	RestArea(aArea)

Return aSXB

//-------------------------------------------------------------------
/*/{Protheus.doc} E012F3SXBR
Retorna o registro posicionado pela consulta especifica RETSXB.

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12
@return  cResult - Código da consulta selecionada
/*/
//-------------------------------------------------------------------
Function E012F3SXBR()
	Local cResult As Character

	cResult := E012GetF3()

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} E012SetF3
Define o código da consulta selecionada na variável estática.

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12
/*/
//-------------------------------------------------------------------
Static Function E012SetF3(cResult)
	__cResultF3 := cResult
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} E012GetF3
Retorna o código da consulta selecionada na variável estática.

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12
@return  __cResultF3 - Código da consulta selecionada (variável estática)
/*/
//-------------------------------------------------------------------
Static Function E012GetF3()
Return __cResultF3

//-------------------------------------------------------------------
/*/{Protheus.doc} E012VldVal
Rotina de validação dos campos

@Obs: Função utilizada no X3_VALID dos campos da tabela D4V

@type    Function
@author  Jorge Martins
@since   03/11/2025
@version 12
@param   cField - Campo a ser validado
@param   xValue - Conteúdo do campo
@return  lValid - .T. se o valor do campo é válido
/*/
//-------------------------------------------------------------------
Function E012VldVal(cField, xValue)
	Local lValid     As Logical
	Local cProblema  As Character
	Local cSolucao   As Character
	Local cRotina    As Character
	Local cCampo     As Character
	Local aAreaSXB   As Array
	Local oModel     As Object
	Local oGridLista As Object
	Local nQtdLinha  As Numeric
	Local nLinha     As Numeric

	lValid := .T.
	cCampo := ""

	// Campo de consulta padrão que deve existir na tabela SXB
	If cField $ "D4V_F3"
		If !Empty(xValue)
			aAreaSXB := SXB->(GetArea())
			SXB->(DbSetOrder(1)) // XB_ALIAS
			If !SXB->(DbSeek(xValue)) // DBSeek usado em If para não travar DbAccess caso não encontre
				lValid    := .F.
				cProblema := STR0022 // "A consulta padrão informada não existe."
				cSolucao  := STR0021 // "Informe uma consulta padrão válida."
				cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
				Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
			EndIf
			RestArea(aAreaSXB)
		EndIf

	ElseIf cField == "D4V_TIPO"
		If xValue <> "1" // Se não for do tipo Lista de Opções
			oModel := FwModelActive()
			If oModel:GetId() == "ESTA012"
				oGridLista  := oModel:GetModel("D4WDETAIL")
				nQtdLinha   := oGridLista:GetQtdLine()
				If nQtdLinha > 0
					For nLinha := 1 To nQtdLinha
						If !oGridLista:IsDeleted(nLinha) .And. (nQtdLinha > 1 .Or. !Empty(oGridLista:GetValue("D4W_VALOR", nLinha)))
							oGridLista:GoLine(nLinha)
							oGridLista:DeleteLine() // Exclui todas as linhas do detalhe
						EndIf
					Next nI
					oGridLista:GoLine(1)
				EndIf
			EndIf
		EndIf
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} E012VldDup
Método de validação de duplicidade de características

@type    Method
@author  Jorge Martins
@since   03/11/2025
@version 12
@param   oModel - Modelo de dados de regras de dias de antecedência para vencimento
@return  lValid - .T. se os dados estão válidos e sem duplicidade

/*/
//-------------------------------------------------------------------
METHOD E012VldDup(oModel) CLASS ESTA012EVDEF
Local lValid     As Logical
Local lCaracDup  As Logical
Local lAutoCaSem As Logical // Variável para controle de inclusão de características semelhantes via automação
Local lTestAuto  As Logical // Variável para controle de teste de automação
Local cQuery     As Character
Local cQryNome   As Character
Local cAliasDup  As Character
Local cProblema  As Character
Local cSolucao   As Character
Local cRotina    As Character
Local cCaracSem  As Character
Local cNome      As Character
Local cCaracAuto As Character
Local oDup       As Object
Local oModelD4V  As Object
Local nParam     As Numeric

	lValid     := .T.
	lCaracDup  := .F.
	lAutoCaSem := .F.
	lTestAuto  := .F.
	nParam     := 1
	cCaracSem  := ""
	cCaracAuto := ""
	oModelD4V  := oModel:GetModel("D4VMASTER")
	cNome      := AllTrim(Upper(oModelD4V:GetValue("D4V_NOME")))

	cQuery :=   "SELECT D4V_NOME"
	cQuery +=    " FROM " + RetSqlName("D4V") + " D4V"
	cQuery +=   " WHERE D4V.D4V_FILIAL = ?"
	cQuery +=     " AND UPPER(D4V.D4V_NOME) IN (?)"

	If ::nOpc == MODEL_OPERATION_UPDATE
		cQuery += " AND D4V.D4V_COD <> ?"
	EndIf
	cQuery +=     " AND D4V.D_E_L_E_T_ = ?"

	oDup := FWExecStatement():New(cQuery)

	oDup:SetString(nParam++, FWxFilial("D4V"))
	oDup:SetIn(nParam++, E012SetIn(cNome))
	If ::nOpc == MODEL_OPERATION_UPDATE
		oDup:SetString(nParam++, oModelD4V:GetValue("D4V_COD"))
	EndIf
	oDup:SetString(nParam++, Space(1))

	cAliasDup := GetNextAlias()
	oDup:OpenAlias(cAliasDup)

	While !(cAliasDup)->(EOF())
		cQryNome := AllTrim(Upper((cAliasDup)->D4V_NOME))
		If cQryNome == cNome // Verifica se é exatamente igual
			lCaracDup := .T.
			Exit // Se achar exatamente igual já pode sair do loop
		EndIf
		cCaracSem += cQryNome + ", " // Concatena características semelhantes
		(cAliasDup)->(DbSkip())
	EndDo

	(cAliasDup)->(DBCloseArea())

	If lCaracDup // Se existir características com o mesmo nome
		lValid    := .F.
		cProblema := STR0035 // "Já existe característica com o mesmo nome."
		cSolucao  := STR0025 // "Verifique os dados informados e tente novamente."
		cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
		Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})

	ElseIf !Empty(cCaracSem) // Se existir característica com nome semelhante
		cCaracSem := SubStr(cCaracSem, 1, Len(cCaracSem)-2) // Remove a última vírgula e espaço
		
		If E012Auto("EST012_017") // Inclui características semelhantes? "Sim" - Usado em teste de semelhança via automação
			lTestAuto  := .T. // Indica que é um teste de automação
			lAutoCaSem := .T. // Indica que é para incluir automaticamente as características semelhantes sem perguntar ao usuário

		ElseIf E012Auto() // Inclui características semelhantes? "Não" - Usado em teste de semelhança via automação
			lTestAuto  := .T. // Indica que é um teste de automação
			lAutoCaSem := .F. // Indica que NÃO é para incluir automaticamente as características semelhantes
			
			// Armazena as características semelhantes para mensagem de retorno quando for automação
			cCaracAuto := I18n(STR0036, {cNome, cCaracSem}) // " Característica novo: '#1'. Características existentes: '#2'" 
		EndIf

		If !lAutoCaSem // Se não for para incluir automaticamente as características semelhantes

			// Verifica se é um teste de automação, e caso não seja, 
			// pergunta ao usuário se deseja continuar com a inclusão mesmo com características semelhantes
			If lTestAuto .Or. !APMsgYesNo(I18n(STR0023, {cCaracSem}), STR0020) // "Existem característica(s) com nomes semelhantes: '#1'. Deseja continuar com a inclusão?" # "Atenção"
				lValid    := .F.
				cProblema := STR0024 + cCaracAuto // "Já existem uma ou mais características com nome semelhante."
				cSolucao  := STR0025 // "Verifique os dados informados e tente novamente."
				cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
				Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
			EndIf
		EndIf
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} E012SetIn
Monta um array com as variações singular/plural do termo informado.

@type    Function
@author  Jorge Martins
@since   07/11/2025
@version 12
@param   cTexto - Termo a ser verificado
@return  aIn - Array com as variações do termo
/*/
//-------------------------------------------------------------------
Static Function E012SetIn(cTexto)
	Local aIn       As Array
	Local cItem     As Character
	
	aIn   := {}
	cItem := AllTrim(Upper(cTexto))

	/* -------------------------------------------------------- |
	|  Regras singular/plural baseadas na gramática portuguesa  |
	| --------------------------------------------------------- |
	| Final em vogais - Singular - A |E |I |O |U                |
	|                 - Plural   - AS|ES|IS|OS|US               |
	|                                                           |
	| Final em R ou Z - Singular - R  |Z                        |
	|                 - Plural   - RES|ZES                      |
	|                                                           |
	| Final em L      - Singular - AL |EL |IL       |OL |UL     |
	|                 - Plural   - AIS|EIS|IS ou EIS|OIS|UIS    |
	|                                                           |
	| Final em M      - Singular - M                            |
	|                 - Plural   - NS                           |
	|                                                           |
	| Final em S      - Singular - S                            |
	|                 - Plural   - SES                          |
	| -------------------------------------------------------- */

	// Caso a palavra esteja no singular - Verifica e adiciona o termo no plural
	If SubStr(cItem, Len(cItem), 1) $ "AEIOU" // Final em vogais
		Aadd(aIn, cItem + "S") // (Ex: Livro vira Livros, Caneta vira Canetas)

	ElseIf SubStr(cItem, Len(cItem), 1) == "R" .Or. SubStr(cItem, Len(cItem), 1) == "Z" // Final em R ou Z 
		Aadd(aIn, cItem + "ES") // (Ex: Cor vira Cores, Raiz vira Raizes)

	ElseIf SubStr(cItem, Len(cItem), 1) == "L" // Final em L
		If SubStr(cItem, Len(cItem) - 1, 1) == "I" // Verifica se a letra anterior ao L é I
			Aadd(aIn, SubStr(cItem, 1, Len(cItem) - 1) + "S") // (Ex: Civil vira Civis)
			Aadd(aIn, SubStr(cItem, 1, Len(cItem) - 2) + "EIS") // (Ex: Útil vira Uteis)
		Else
			Aadd(aIn, SubStr(cItem, 1, Len(cItem) - 1) + "IS") // (Ex: Animal vira Animais, Papel vira Papeis)
		EndIf

	ElseIf SubStr(cItem, Len(cItem), 1) == "M" // Final em M
		Aadd(aIn, SubStr(cItem, 1, Len(cItem) - 1) + "NS") // (Ex: Item vira Itens)

	ElseIf SubStr(cItem, Len(cItem), 1) == "S" // Final em S
		Aadd(aIn, cItem + "ES") // (Ex: Mes vira Meses)

	EndIf

	// Caso a palavra esteja no plural - Verifica e adiciona o termo no singular
	If SubStr(cItem, Len(cItem) - 2, 3) $ "AIS|EIS|OIS|UIS" // Final em L
		Aadd(aIn, SubStr(cItem, 1, Len(cItem) - 2) + "L") // (Ex: Materiais vira material, Papeis vira papel)
		If SubStr(cItem, Len(cItem) - 2, 3) == "EIS" // Final em L (Ex: Uteis vira útil)
			Aadd(aIn, SubStr(cItem, 1, Len(cItem) - 3) + "IL") // Para final em IL
		EndIf

	ElseIf SubStr(cItem, Len(cItem) - 1, 2) $ "IS" // Final em L ou S (Sendo I a vogal anterior)
		Aadd(aIn, SubStr(cItem, 1, Len(cItem) - 1) + "L") // Para final em L (Ex: Civis vira civil)
		Aadd(aIn, SubStr(cItem, 1, Len(cItem) - 1)) // Para final em S (Ex: Leis vira Lei)

	ElseIf SubStr(cItem, Len(cItem) - 2, 3) $ "RES|ZES" // Final em R ou Z
		Aadd(aIn, SubStr(cItem, 1, Len(cItem) - 2)) // (Ex: Cores vira cor, Raizes vira raiz)

	ElseIf SubStr(cItem, Len(cItem) - 1, 2) == "NS" // Final em M 
		Aadd(aIn, SubStr(cItem, 1, Len(cItem) - 2) + "M") // (Ex: Itens vira item)

	ElseIf SubStr(cItem, Len(cItem) - 2, 3) == "SES" // Final em S 
		Aadd(aIn, SubStr(cItem, 1, Len(cItem) - 2)) // (Ex: Meses vira mes)

	ElseIf SubStr(cItem, Len(cItem) - 1, 2) $ "AS|ES|IS|OS|US" // Final em vogais 
		Aadd(aIn, SubStr(cItem, 1, Len(cItem) - 1)) // (Ex: Pesos vira peso, Páginas vira página)

	EndIf

	Aadd(aIn, cItem) // Adiciona também o termo original

Return aIn

//-------------------------------------------------------------------
/*/{Protheus.doc} E012Auto
Verifica se o teste está sendo feito via automação
Em caso afirmativo, verifica se o caso de teste atual é o esperado.

@type    Function
@author  Jorge Martins
@since   10/11/2025
@version 12
@param   cTestCase - Nome do caso de teste a ser verificado
@return  lTestAuto - .T. se o teste está sendo feito via automação
/*/
//-------------------------------------------------------------------
Static Function E012Auto(cTestCase)
	Local lTestAuto As Logical
	Local aRetAuto  As Array

	Default cTestCase := ""

	lTestAuto := .F.

	If FindFunction("GetParAuto") // Teste de semelhança via automação
		aRetAuto  := GetParAuto("ESTA012TestCase")
		If (ValType(aRetAuto) == "A" .And. Len(aRetAuto) == 1 .And. ValType(aRetAuto[1]) == "C")
			If Empty(cTestCase) .Or. aRetAuto[1] $ cTestCase // Verifica se é o caso de teste esperado ou se não foi informado (teste geral)
				lTestAuto := .T.
			EndIf
		EndIf
	EndIf

Return lTestAuto
