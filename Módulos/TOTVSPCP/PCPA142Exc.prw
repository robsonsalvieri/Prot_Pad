#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA142.CH"

Static _aLoad      := {}
Static _lFechaTela := .F.
Static _o142Exec   := Nil

/*/{Protheus.doc} LimpezaHW8
Limpeza de dos Logs do processamento do MRP
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
/*/
CLASS LimpezaHW8 FROM LongNameClass

	DATA dDataFim  as DATE
	DATA dDataIni  as DATE
	DATA nRadio    as INTEGER
	Data oButton   as OBJECT
	DATA oDataFim  as OBJECT
	DATA oDataIni  as OBJECT
	DATA oModel    as OBJECT
	DATA oRadio    as OBJECT
	DATA oView     as OBJECT
	DATA oViewExec as OBJECT

	METHOD New() CONSTRUCTOR
	METHOD AbreTelaHW8()
	METHOD DestroyHW8()
	METHOD MarcaDatas(dDataIni, dDataFim)

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe para a Limpeza dos Logs
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
@return Self, objeto, classe LimpezaHW8
/*/
METHOD New() CLASS LimpezaHW8
	Self:nRadio   := 1
	Self:dDataIni := StoD("")
	Self:dDataFim := StoD("")
Return Self

/*/{Protheus.doc} DestroyHW8
Método para limpar da memória os objetos utilizados pela classe
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
@return Nil
/*/
METHOD DestroyHW8() CLASS LimpezaHW8

	Self:dDataFim := Nil
	Self:dDataIni := Nil
	Self:nRadio   := Nil
	Self:oButton  := Nil
	Self:oRadio   := Nil

	If Self:oView <> Nil
		Self:oView:DeActivate()
	EndIf

	FreeObj(Self:oView)
	Self:oView    := Nil

	FreeObj(Self:oDataIni)
	Self:oDataIni := Nil

	FreeObj(Self:oDataFim)
	Self:oDataFim := Nil

	aSize(_aLoad, 0)
	_aLoad := {}

	_lFechaTela := .F.

Return

/*/{Protheus.doc} AbreTelaHW8
Método para abrir a tela
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
@return
/*/
METHOD AbreTelaHW8() CLASS LimpezaHW8
	Local aArea     := GetArea()
	Local aButtons  := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
						 {.T.,STR0077},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} } //"Confirmar"
	Local oViewExec := FWViewExec():New()

	_o142Exec := Self

	LoadPrcHW8()

	If Self:oView == Nil
		Self:oView := ViewDef()
		Self:oView:AddUserButton(STR0080, "", {|| AcaoBotao(_o142Exec, 0)}   , , , , .T.) //"Cancelar"
	EndIf

	Self:oModel    := Self:oView:oModel
	Self:oViewExec := oViewExec

	Self:oModel:setOperation(MODEL_OPERATION_UPDATE)
	oViewExec:setView(::oView)
	oViewExec:setTitle(STR0081) //"Limpeza dos Logs do MRP
	oViewExec:setOperation(MODEL_OPERATION_UPDATE)
	oViewExec:setReduction(40)
	oViewExec:setButtons(aButtons)
	oViewExec:setCancel({|| AcaoBotao(_o142Exec, 1)})
	oViewExec:openView(.F.)

	RestArea(aArea)

	Self:DestroyHW8()
	_o142Exec := Nil

Return

/*/{Protheus.doc} MarcaDatas
Marca todos os ID's dentro do intervalo e desmarca os demais
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
/*/
METHOD MarcaDatas(dDataIni, dDataFim) CLASS LimpezaHW8
	Local oGrid  := _o142Exec:oModel:GetModel("GRID")

	oGrid:SetNoInsertLine(.F.)

	If oGrid:CanClearData()
		oGrid:ClearData(.T., .F.)
		oGrid:DeActivate()
		oGrid:lForceLoad := .T.
		oGrid:Activate()
	EndIf

	oGrid:SetNoInsertLine(.T.)
	oGrid:GoLine(1)

Return

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
@return oModel, objeto, modelo definido
/*/
Static Function ModelDef()
	Local oModel    := MPFormModel():New('PCPA142Exc' )
	Local oStruCab  := FWFormModelStruct():New()
	Local oStruGrid := FWFormStruct( 1, "HW8", {|cCampo| !AllTrim(cCampo) $ "|HW8_FILIAL|HW8_DET|HW8_API|"})

	//Cria campo para o modelo invisível
	oStruCab:AddField(STR0082, STR0082, "ARQ", "C", 1, 0, , , {}, .T., , .F., .F., .F., , ) //Consulta, Consulta

	//FLD_INVISIVEL - Modelo "invisível"
	oModel:addFields('FLD_INVISIVEL', /*cOwner*/, oStruCab, , , {|| LoadMdlFld()})
	oModel:GetModel("FLD_INVISIVEL"):SetDescription(STR0082) //Consulta
	oModel:GetModel("FLD_INVISIVEL"):SetOnlyQuery(.T.)

	//::cModelName - Grid de resultados (o nome deve ser atribuido através da propriedade ::cModelName)
	oModel:AddGrid("GRID", "FLD_INVISIVEL", oStruGrid,,,,,{|| LoadDados()})
	oModel:GetModel("GRID"):SetDescription(STR0083) //"Logs do processamentos MRP"
	oModel:GetModel("GRID"):SetOptional(.T.)
	oModel:GetModel("GRID"):SetOnlyQuery(.T.)
	oModel:GetModel("GRID"):SetNoInsertLine(.T.)
	oModel:GetModel("GRID"):SetNoDeleteLine(.T.)
	oModel:GetModel("GRID"):SetNoUpdateLine(.T.)

	oModel:SetDescription(STR0082) //Consulta
	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
@return oView, objeto, view definida
/*/
Static Function ViewDef()
	Local oModel    := FWLoadModel("PCPA142Exc")
	Local oStruGrid := FWFormStruct( 2, "HW8", {|cCampo| !AllTrim(cCampo) $ "|HW8_FILIAL|HW8_DET|HW8_API|"})
	Local oView     := FWFormView():New()

	//Definições da View
	oView:SetModel(oModel)

	//Adiciona Other Object de Parâmetros da Limpeza
	oView:AddOtherObject("V_PARAM", {|oPanel| ParamHW8(oPanel) })
	oView:EnableTitleView("V_PARAM", STR0084) //"Parâmetros"

	//V_GRID - View da Grid com resultado da pesquisa
	oView:AddGrid("V_GRID", oStruGrid, "GRID")
	oView:EnableTitleView("V_GRID", STR0085) //"Seleção de ID's para Limpeza"

	//Relaciona a SubView com o Box
	oView:CreateHorizontalBox("BOX_PARAM", 30)
	oView:CreateHorizontalBox("BOX_GRID" , 70)

	//Vincula View aos BOX
	oView:SetOwnerView("V_PARAM", 'BOX_PARAM')
	oView:SetOwnerView("V_GRID" , 'BOX_GRID' )

	//Habilita os botões padrões de filtro e pesquisa
	oView:SetViewProperty("V_GRID", "GRIDFILTER", {.T.} )
	oView:SetViewProperty("V_GRID", "GRIDSEEK"  , {.T.} )

Return oView

/*/{Protheus.doc} ParamHW8
Carga do modelo mestre (invisível)
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
@param 01 - oPanel , objeto, painel onde serão montados os parametros
/*/
Static Function ParamHW8(oPanel)
	Local aItems :={STR0087, STR0088} //'Limpeza Total','Seleção por Data'
	Local oFont  := TFont():New(, , 14, , .T., , , , , .F., .F.)

	//Modo de Limpeza
	TSay():New(20, 10,{||STR0086}, oPanel, , oFont,,,,.T., CLR_RED, CLR_WHITE, 200, 20) //'Modo de Limpeza:'
	_o142Exec:nRadio   := 1
	_o142Exec:oRadio   := TRadMenu():New(30, 10, aItems, {|u| Iif(PCount() == 0, _o142Exec:nRadio, _o142Exec:nRadio := u) }, oPanel, Nil, {|| MudaModoHW8() },,,,,, 170, 20,,,, .T., .T.)

	//Data de Processamento
	TSay():New(20, 210,{|| STR0089}, oPanel, , oFont,,,,.T., CLR_RED, CLR_WHITE, 200, 20) //'Data de Processamento:'
	_o142Exec:dDataIni := StoD("")
	_o142Exec:dDataFim := StoD("")
	_o142Exec:oDataIni := TGet():New( 30, 210, bSetGet(_o142Exec:dDataIni), oPanel, 040, 009,"@D",,0,,,.F.,,.T.,,.F., {|| _o142Exec:nRadio == 2 },.F.,.F., Nil,.F.,.F.)
	_o142Exec:oDataFim := TGet():New( 30, 260, bSetGet(_o142Exec:dDataFim), oPanel, 040, 009,"@D",,0,,,.F.,,.T.,,.F., {|| _o142Exec:nRadio == 2 },.F.,.F., Nil,.F.,.F.)
	_o142Exec:oButton  := TButton():New( 30, 310, STR0100, oPanel, {|| MudaModoMR()}, 030, 010, Nil, Nil, .F., .T., .F., Nil, .F., {|| _o142Exec:nRadio == 2 },,.F.) //"Filtrar"

Return

/*/{Protheus.doc} MudaModoHW8
Ações da Mudança na Seleção do Modo de Execução
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
@return Nil
/*/
Static Function MudaModoHW8()
	Local oGrid   := _o142Exec:oModel:GetModel("GRID")

	If _o142Exec:nRadio == 1
		_o142Exec:dDataIni := StoD("")
		_o142Exec:dDataFim := StoD("")

		If oGrid:CanClearData()
			oGrid:ClearData(.T., .F.)
			oGrid:DeActivate()
			oGrid:lForceLoad := .T.
			oGrid:Activate()
		EndIf

		FocoData(.F.)

	ElseIf _o142Exec:nRadio == 2
		If oGrid:CanClearData()
			oGrid:ClearData(.T., .T.)
		EndIf
		FocoData(.T.)
	EndIf

Return

/*/{Protheus.doc} MudaModoMR
Ações da Mudança na Seleção do Modo de Execução
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
@return Nil
/*/
Static Function MudaModoMR()

	If Empty(_o142Exec:dDataIni) .Or. Empty(_o142Exec:dDataFim)
		HELP(' ', 1, "Help",, STR0101,; //Data de início/final não informado!
			 2, 0, , , , , , {STR0102}) //Informe a data de início e fim para limpeza dos logs
		Return Nil
	ElseIf !Empty(_o142Exec:dDataIni) .AND. !Empty(_o142Exec:dDataFim)
		_o142Exec:MarcaDatas(_o142Exec:dDataIni, _o142Exec:dDataFim)
	EndIf

	FocoData(.F.)

	_o142Exec:oView:oModel:lModify := .F.

Return 

/*/{Protheus.doc} LoadMdlFld
Carga do modelo mestre (invisível)
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
@return aLoad, array, array de load do modelo preenchido
/*/
Static Function LoadMdlFld()
	Local aLoad := {}

	aAdd(aLoad, {"A"}) //dados
	aAdd(aLoad, 1    ) //recno

Return aLoad

/*/{Protheus.doc} LoadPrcHW8
Carga do grid dos registros da HW8
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
@return Nil
/*/
Static Function LoadPrcHW8()
	Local cAlias := GetNextAlias()
	Local cQuery := ""

	cQuery := " SELECT HW8.HW8_ID     AS ID, "
	cQuery +=        " HW8.HW8_SEQUEN AS SEQUEN, "
	cQuery +=        " HW8.HW8_ROTINA AS ROTINA, "
	cQuery +=        " HW8.HW8_DATA   AS DATA, "
	cQuery +=        " HW8.HW8_HORA   AS HORA, "
	cQuery +=        " HW8.HW8_API    AS API, "
	cQuery +=        " HW8.HW8_MSG    AS MSG "
	cQuery += "   FROM " + RetSqlName("HW8") + " HW8 " + HW8Where()
	cQuery += "  ORDER BY HW8.HW8_ID DESC, HW8.HW8_SEQUEN "
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .F.)
	TcSetField(cAlias, 'DATA', 'D', GetSx3Cache("HW8_DATA", "X3_TAMANHO"), 0)

	While (cAlias)->(!EoF())

		aAdd(_aLoad, {0,{ (cAlias)->ID                      ,;
		                  (cAlias)->SEQUEN                  ,;
		                  (cAlias)->ROTINA                  ,;
		                  (cAlias)->DATA                    ,;
		                  (cAlias)->HORA                    ,;
		                  P139GetAPI(AllTrim((cAlias)->API)),;
		                  (cAlias)->MSG}                    })

		(cAlias)->(dbSkip())
	End

	(cAlias)->(dbCloseArea())

Return Nil

/*/{Protheus.doc} AcaoBotao
Método chamado ao pressionar algum botão da tela
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
@param 01 oSelf  , objeto  , classe da tela de consulta
@param 02 nOpcao , numérico, indicador do botão clicado
@return lFechaTela, lógico, indicador para fechar a tela
/*/
Static Function AcaoBotao(oSelf, nOpcao)

	If nOpcao == 1
		If HW8Results() == .F.
			HELP(' ', 1, "Help",, STR0078,; //"Todos os ID's já foram excluídos!"
				 2, 0, , , , , , {STR0079}) //"Alerta!" 
		Else
			FWMsgRun(, {|| HW8Clear()}, STR0075, STR0076) //"Aguarde...", "Limpando registros..."	
		EndIf	
	Else
		oSelf:oView:CloseOwner()
	EndIf

	oSelf:oModel:lModify := .F.

Return _lFechaTela

/*/{Protheus.doc} HW8Clear
Limpeza da base de dados
@author breno.ferreira
@since 03/06/2024
@version P12.1.2310
@return Nil
/*/
Static Function HW8Clear()
	Local cQuery := ""

	cQuery := " DELETE FROM " + RetSqlName("HW8") + HW8Where()

	If ApMsgYesNo(STR0103) //Confirma a exclusão dos registros?
		If TcSqlExec(cQuery) < 0
			Final(STR0117, tcSQLError()) //Erro ao excluir os registros!
		EndIf
		_lFechaTela := .T.
	Else
		_lFechaTela := .F.		
	EndIf

Return Nil

/*/{Protheus.doc} FocoData
Tira o bloqueio das datas para que possam ser colocadas
@author breno.ferreira
@since 20/06/2024
@version P12.1.2310
@return Nil
/*/
Static Function FocoData(lSetFocus)
	Local oGridView := _o142Exec:oView:GetSubView("V_GRID")

	oGridView:DeActivate(.T.)
	oGridView:Activate()
	_o142Exec:oView:Refresh("V_PARAM")
	_o142Exec:oDataIni:Refresh()
	_o142Exec:oDataFim:Refresh()
	_o142Exec:oButton:Refresh()

	If lSetFocus
		_o142Exec:oDataIni:SetFocus()
	EndIf

Return

/*/{Protheus.doc} HW8Where
Retorna o where da query
@author breno.ferreira
@since 27/06/2024
@version P12.1.2310
@return cWhere, caracter, retorna o where
/*/
Static Function HW8Where()
	Local cWhere := ""

	cWhere :=  " WHERE HW8_FILIAL = '" + xFilial("HW8") + "' "
	If _o142Exec:nRadio == 2
		cWhere += " AND HW8_DATA BETWEEN '" + DToS(_o142Exec:dDataIni) + "' AND '" + DToS(_o142Exec:dDataFim) + "' "
	EndIf
	cWhere +=    " AND D_E_L_E_T_ = ' '"

Return cWhere

/*/{Protheus.doc} HW8Results
Retorna a quantidade de registros
@author breno.ferreira
@since 27/06/2024
@version P12.1.2310
@return lConteudo, lógico, retorna .T. ou .F. se houver registros
/*/
Static Function HW8Results()
	Local cAlias    := GetNextAlias()
	Local cQuery    := ""
	Local lConteudo := .T.

	cQuery := "SELECT COUNT(*) AS REGISTROS "
	cQuery +=  " FROM " + RetSqlName("HW8") + HW8Where()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .F.)

	If (cAlias)->REGISTROS == 0
		lConteudo := .F.
	EndIf

	(cAlias)->(dbCloseArea())

Return lConteudo

/*/{Protheus.doc} LoadDados
Irá carregar a grid com os resultados
@author breno.ferreira
@since 01/07/2024
@version P12.1.2310
@return aDados, Array, Retorna os resultados da querry
/*/
Static Function LoadDados()
	Local cQuery := ""
	Local cAlias := GetNextAlias()
	Local aDados := {}

	If _o142Exec:nRadio == 1
		aDados := aClone(_aLoad)
	Else
		cQuery := " SELECT HW8.HW8_ID     AS ID, "
		cQuery +=        " HW8.HW8_SEQUEN AS SEQUEN, "
		cQuery +=        " HW8.HW8_ROTINA AS ROTINA, "
		cQuery +=        " HW8.HW8_DATA   AS DATA, "
		cQuery +=        " HW8.HW8_HORA   AS HORA, "
		cQuery +=        " HW8.HW8_API    AS API, "
		cQuery +=        " HW8.HW8_MSG    AS MSG "
		cQuery +=  "  FROM " + RetSqlName("HW8") + " HW8 " + HW8Where()
		cQuery +=  " ORDER BY HW8.HW8_ID DESC, HW8.HW8_SEQUEN "
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .F.)
		TcSetField(cAlias, 'DATA', 'D', GetSx3Cache("HW8_DATA", "X3_TAMANHO"), 0)

		While (cAlias)->(!EoF())
			aAdd(aDados, {0,{ (cAlias)->ID                      ,;
			                  (cAlias)->SEQUEN                  ,;
			                  (cAlias)->ROTINA                  ,;
			                  (cAlias)->DATA                    ,;
			                  (cAlias)->HORA                    ,;
			                  P139GetAPI(AllTrim((cAlias)->API)),;
			                  (cAlias)->MSG}                    })

			(cAlias)->(dbSkip())
		End

		(cAlias)->(dbCloseArea())
	EndIf

Return aDados
