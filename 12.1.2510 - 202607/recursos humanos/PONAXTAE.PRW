#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PONAXTAE.CH"

PUBLISH MODEL REST NAME PONAXTAE

/*/{Protheus.doc} PONAXTAE
Tela para realizar a configuração do envio de relatórios para o Totvs Assinatura Eletrônica
@type function
@author Cícero Alves
@since 08/01/2026
@return NIL, NIL
/*/
Function PONAXTAE()
	
	Local oBrowse
	
	If !ValidRegs()
		// "Funcionalidade não disponível para esta versão do sistema."
		Help(,,"HELP",, STR0022, 1, 0,,,,,, {STR0023}) // "Para utilizar a tela de configuração da integração com o Totvs Assinatura Eletrônica é necessário atualizar o sistema."
		Return
	EndIf
	
	oBrowse := BrowseDef()
	oBrowse:Activate()
	
	ResetStatic()
	
Return

/*/{Protheus.doc} BrowseDef
Cria o Browse para navegação na rotina
@type static function
@author Cícero Alves
@since 08/01/2026
@return object, instância da classe FWMBrowse
/*/
Static Function BrowseDef()
	
	Local oBrwRR3 := FWMBrowse():New()
	
	oBrwRR3:SetAlias("RR3")
	oBrwRR3:SetDescription(STR0001) // "Configuração Integração TAE"
	oBrwRR3:SetFilterDefault("AllTrim(RR3_ROTINA) $ 'PONR010'")
	oBrwRR3:DisableDetails()
	
	oBrwRR3:SetMenuDef("PONAXTAE")
	
Return oBrwRR3

/*/{Protheus.doc} MenuDef
Definição das opções apresentadas no menu da rotina
@type Static function
@author Cícero Alves
@since 08/01/2026
@return array, Opções para o menu da rotina
/*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.PONAXTAE" OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 // "Manutenção"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.PONAXTAE" OPERATION MODEL_OPERATION_VIEW 	ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.PONAXTAE" OPERATION MODEL_OPERATION_DELETE	ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE STR0027 ACTION "ConfigTAE()" OPERATION 6 ACCESS 0 // "Config. Parâmetros"
	
Return aRotina

/*/{Protheus.doc} ViewDef
Definição da interface
@type static function
@author Cícero Alves
@since 08/01/2026
@return object, instância da classe FWFormView
/*/
Static Function ViewDef()
	
	Local oView 	:= FWFormView():New()
	Local oModel	:= FwLoadModel("PONAXTAE")
	Local oStc_RR3 	:= FWFormStruct(2, "RR3", )
	Local oStc_RR4 	:= FWFormStruct(2, "RR4", {|cCampo| AllTrim(cCampo) $ "RR4_ORDEM|RR4_FILFUN|RR4_MAT|RR4_NOME|RR4_ACAO|RR4_EMAIL|RR4_NOTIFY"})
	
	oView:SetModel(oModel)
	
	oStc_RR3:RemoveField("RR3_ROTINA")
	oStc_RR3:RemoveField("RR3_DOC")
	
	oStc_RR3:SetProperty("RR3_USER", MVC_VIEW_IDFIELD, "USER") 		// Altera o ID do campo
	oStc_RR3:SetProperty("USER", MVC_VIEW_VIRTUAL, .T.)				// Altera para virtual
	// "Usuário do TAE com permissão de upload de arquivos para realizar o envio do documento. Caso não informado será utilizado o parâmetro MV_RHTAEUS"
	oStc_RR3:SetProperty("USER", MVC_VIEW_HELP, {STR0024})
	
	oStc_RR3:SetProperty("RR3_PWORD", MVC_VIEW_IDFIELD, "PWORD")	// Altera o ID do campo
	oStc_RR3:SetProperty("PWORD", MVC_VIEW_VIRTUAL, .T.)			// Altera para virtual
	//"Senha do Usuário do TAE com permissão de upload de arquivos para realizar o envio do documento. Caso não informado será utilizado o parâmetro MV_RHTAEPW"
	oStc_RR3:SetProperty("PWORD", MVC_VIEW_HELP, {STR0025})
	
	oStc_RR4:SetProperty("RR4_NOTIFY", MVC_VIEW_TITULO, "Notificação")		// Altera o ID do campo
	
	oStc_RR4:SetProperty("RR4_NOME", MVC_VIEW_IDFIELD, "NOME")		// Altera o ID do campo
	oStc_RR4:SetProperty("NOME", MVC_VIEW_VIRTUAL, .T.)				// Altera para virtual
	oStc_RR4:SetProperty("NOME", MVC_VIEW_HELP, {STR0026}) 			// "Nome completo do destinatário."
	
	oStc_RR4:AddField("MOVC", "01", "+", STR0005 , {" "}, "C", "@BMP"	,,'',.F.,,,,,, .T.) // "Mover Cima"
	oStc_RR4:AddField("MOVB", "02", "-", STR0006, {" "}, "C", "@BMP"	,,'',.F.,,,,,, .T.) // "Mover Baixo"
	
	oView:AddField( "PONAXTAE_RR3", oStc_RR3)
	oView:AddGrid( "PONAXTAE_RR4", oStc_RR4 )
	oView:EnableTitleView("PONAXTAE_RR4", STR0007) // "Destinatários"
	
	oView:SetViewProperty("PONAXTAE_RR4", "ENABLENEWGRID")
	oView:SetViewProperty("PONAXTAE_RR4", "GRIDNOORDER")
	oView:SetViewProperty("PONAXTAE_RR4", "GRIDSEEK", {.F.})
	oView:SetViewProperty("PONAXTAE_RR4", "GRIDDOUBLECLICK", {{|oFormulario, cFieldName, nLineGrid, nLineModel| PnTaeMove(oFormulario, cFieldName, nLineGrid, nLineModel)}})
	
	oView:createHorizontalBox("TOP", 60)
	oView:createHorizontalBox("BOTTOM", 40)
	
	oView:SetOwnerView( "PONAXTAE_RR3", "TOP")
	oView:SetOwnerView( "PONAXTAE_RR4", "BOTTOM")
	
	oView:EnableControlBar(.T.)
	oView:SetCloseOnOk({ || .T. })
	
Return oView

/*/{Protheus.doc} ModelDef
Definição do Modelo da rotina
@type static function
@author Cícero Alves
@since 08/01/2026
@return object, instância da classe MPFormModel
/*/
Static Function ModelDef()
	
	Local oModel 	:= MPFormModel():New("PONAXTAE", ,{|oModel| ValidLogin(oModel)})
	Local oEventGrv	:= PonTaeEvt():New()
	Local aCopyCpo	:= {}
	Local oStc_RR3 	:= FWFormStruct(1, "RR3")
	Local oStc_RR4 	:= FWFormStruct(1, "RR4")
	
	oStc_RR3:SetProperty("RR3_USER", MODEL_FIELD_IDFIELD, "USER") 		// Altera o ID para não carregar a informação direto da tabela
	oStc_RR3:SetProperty("USER", MODEL_FIELD_VIRTUAL, .T.) 				// Altera o campo para virtual
	oStc_RR3:SetProperty("USER", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "PnGetInfo(1)")) // Carrega o usuário descriptografado
	
	oStc_RR3:SetProperty("RR3_PWORD", MODEL_FIELD_IDFIELD, "PWORD") 	// Altera o ID para não carregar a informação direto da tabela
	oStc_RR3:SetProperty("PWORD", MODEL_FIELD_VIRTUAL, .T.) 			// Altera o campo para virtual
	oStc_RR3:SetProperty("PWORD", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "PnGetInfo(2)"))
	
	oStc_RR3:SetProperty("RR3_SUB", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "PnVldMsg(1)"))
	oStc_RR3:SetProperty("RR3_MSG", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "PnVldMsg(2)"))
	
	// Adiciona um campo Vitual para o nome que será exibido em tela
	aCopyCpo := oStc_RR4:GetAllFieldProp("RR4_NOME")
	aCopyCpo[3] := "NOME"
	
	oStc_RR4:SetProperty("RR4_NOTIFY", MODEL_FIELD_TITULO, STR0028) // "Notificação"
	
	oStc_RR4:AddField(aCopyCpo[1], aCopyCpo[2], aCopyCpo[3], aCopyCpo[4], aCopyCpo[5],,,aCopyCpo[8],,,, .F.,, .T.)
	oStc_RR4:SetProperty("NOME", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "PnGetInfo(3)"))
	
	oStc_RR4:SetProperty("RR4_ROTINA", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "RR3->RR3_ROTINA"))
	
	oStc_RR4:SetProperty("RR4_TPREG", MODEL_FIELD_OBRIGAT, .F.) // O campo será preenchido na validação de linha
	oStc_RR4:SetProperty("RR4_ORDEM", MODEL_FIELD_OBRIGAT, .F.) // O campo será preenchido na validação de linha
	
	oStc_RR4:addField("+", "Mover", "MOVC", "C", 15, 0,,,,,FwBuildFeature(STRUCT_FEATURE_INIPAD, "'PMSSETAUP'"),,,.T.)
	oStc_RR4:addField("-", "Mover", "MOVB", "C", 15, 0,,,,,FwBuildFeature(STRUCT_FEATURE_INIPAD, "'PMSSETADOWN'"),,,.T.)
	
	oModel:SetDescription(STR0001) // "Configuração Integração TAE"
	
	oModel:AddFields("PONAXTAE_RR3", , oStc_RR3,,,)
	oModel:AddGrid("PONAXTAE_RR4", "PONAXTAE_RR3", oStc_RR4, {|oGrid, nLine, cAction, cField| PnTAEDelOk(oGrid, nLine, cAction, cField)}, {|oGrid, nLine| PnTaeLOK(oGrid, nLine) })
	
	oModel:GetModel('PONAXTAE_RR4'):SetUniqueline({"RR4_ROTINA", "RR4_ORDEM"})
	oModel:GetModel('PONAXTAE_RR4'):SetOptional(.T.)
	oModel:GetModel("PONAXTAE_RR4"):SetDescription(STR0007)// "Destinatários"
	
	oModel:SetRelation("PONAXTAE_RR4", {{"RR4_FILIAL", "xFilial('RR4')"}, {"RR4_ROTINA", "RR3_ROTINA"}}, RR4->(IndexKey(1)))
	
	oModel:InstallEvent("PonTaeGrv", , oEventGrv)
	
Return oModel

/*/{Protheus.doc} PnTaeMove
Realiza a troca das linhas do grid para ordenação
@type static function
@author Cícero Alves
@since 08/01/2026
@param oFormulario, object, View do formulário (Não utilizado)
@param cFieldName, character, Nome do campo 
@param nLineGrid, numeric, Linha do grid na View
@param nLineModel, numeric, Linha do grid no Modelo
@return logical, Sempre Falso 
/*/
Static Function PnTaeMove(oFormulario, cFieldName, nLineGrid, nLineModel)
	
	Local oModel 	:= FwModelActive()
	Local oGrid 	:= oModel:GetModel("PONAXTAE_RR4")
	Local oView
	Local nLineTo	:= 0
	Local nLinhas	:= oGrid:Length()
	Local lRet 		:= .T.
	Local nI		:= 0
	Local nOrdemTo	:= 0
	Local nOrdemFrom := 0
	
	If cFieldName == "MOVC" .And. nLineModel > 1 .And. !oGrid:IsDeleted(nLineModel)
		oView := FwViewActive()
		
		// Busca por uma linha válida
		nI := nLineModel-1
		While nI >= 1
			If !oGrid:IsDeleted(nI)
				nLineTo := nI
				EXIT
			EndIf
			nI--
		EndDo
		
		If nLineTo > 0
			
			nOrdemFrom := oGrid:GetValue("RR4_ORDEM")
			
			oGrid:Goline(nLineTo)
			
			nOrdemTo := oGrid:GetValue("RR4_ORDEM")
			oGrid:LoadValue("RR4_ORDEM", nOrdemFrom)
			
			oGrid:Goline(nLineModel)
			oGrid:LoadValue("RR4_ORDEM", nOrdemTo)
			
			oGrid:LineShift(nLineModel, nLineTo)
			
			oGrid:Goline(1)
			oView:Refresh("PONAXTAE_RR4")
		EndIf
		
		lRet := .F.
	EndIf
	
	If cFieldName == "MOVB" .And. nLineModel < nLinhas .And. !oGrid:IsDeleted(nLineModel)
		oView := FwViewActive()
		
		// Busca por uma linha válida
		nI := nLineModel+1
		While nI <= nLinhas
			If !oGrid:IsDeleted(nI)
				nLineTo := nI
				EXIT
			EndIf
			nI++
		EndDo
		
		If nLineTo > 0
			nOrdemFrom := oGrid:GetValue("RR4_ORDEM")
			
			oGrid:Goline(nLineTo)
			nOrdemTo := oGrid:GetValue("RR4_ORDEM")
			oGrid:LoadValue("RR4_ORDEM", nOrdemFrom)
			
			oGrid:Goline(nLineModel)
			oGrid:LoadValue("RR4_ORDEM", nOrdemTo)
			
			oGrid:LineShift(nLineModel, nLineTo)
			
			oGrid:Goline(1)
			oView:Refresh("PONAXTAE_RR4")
		EndIf
		
		lRet := .F.
	EndIf
	
Return lRet

/*/{Protheus.doc} PnRetDesc
Retorna a descrição da rotina com base no STRXXXX salvo no campo RR3_DOC. Utilizada no inicializador do campo RR3_DESC
@type function
@author Cícero Alves
@since 08/01/2026
@param cDoc, character, Código da STR com a descrição da rotina
@return character, Descrição da rotina
/*/
Function PnRetDesc(cDoc)
	
	Local cRet 		:= "" 	as character 
	Local nIndice 	:= 0 	as numeric
	
	DEFAULT cDoc := ""
	
	If !Empty(cDoc)
		cDoc := AllTrim(cDoc)
		nIndice := val(Right(cDoc, 4))
		
		cRet := FWI18NLang("PONAXTAE", cDoc, nIndice)
	EndIf
	
Return cRet

/*/{Protheus.doc} ValidRegs
Valida a existência dos registros na tabela RR3, caso não exista realiza a inclusão
@type static function
@author Cícero Alves
@since 08/01/2026
@return NIL, NIL
/*/
Static Function ValidRegs()
	
	Local aArea := GetArea()
	Local lRet	:= .F.
	
	If ChkFile("RR3") .And. ChkFile("RR4")
		If !lRR3OK
			
			dbSelectArea("RR3")
			dbSetOrder(1)
			
			If RR3->(!dbSeek(xFilial("RR3") + "PONR010"))
				GrvRR3_RR4("PONR010", "STR0008", .T.) // "Espelho de Ponto"
			EndIf
			
			lRR3OK := .T.
			
		EndIf
		
		lRet := .T.
	EndIf
	
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} GrvRR3_RR4
Realiza a gravação dos registros iniciais nas tabelas RR3 e RR4
@type static function
@author Cícero Alves
@since 08/01/2026
@param cRotina, character, Nome da rotina. Chave da tabela RR3
@param cNomeDoc, character, Código da STR com a descrição da rotina
@param lGravaRR4, logical, Define se cria um registro padrão para o funcionáro na tabela RR4
@return NIL, NIL
/*/
Static Function GrvRR3_RR4(cRotina, cNomeDoc, lGravaRR4)
	
	Local aArea := GetArea()
	Local lMRHTae := .F.
	Local cTpNotTae	:= ""
	
	RecLock("RR3", .T.)
		RR3->RR3_FILIAL := xFilial("RR3")
		RR3->RR3_ROTINA	:= cRotina
		RR3->RR3_DOC	:= cNomeDoc
		RR3->RR3_MANUAL	:= "2"
		RR3->RR3_WRKFLW	:= "2"
		RR3->RR3_REFUSE	:= "1"
		RR3->RR3_REMIND	:= "0"
	RR3->(MsUnlock())
	
	If lGravaRR4
		
		lMRHTae := SuperGetMv("MV_MRHTAE",, .F.)
		cTpNotTae := cValToChar(SuperGetMv("MV_RHTAENT", .F., 1))
		
		dbSelectArea("RR4")
		RecLock("RR4", .T.)
			RR4->RR4_FILIAL	:= xFilial("RR4")
			RR4->RR4_ROTINA	:= cRotina
			RR4->RR4_TPREG	:= "1"
			RR4->RR4_ORDEM 	:= 1
			RR4->RR4_ACAO 	:= "0"
			RR4->RR4_KEY 	:= "00"
			If lMRHTae
				RR4->RR4_NOTDOC := If(cTpNotTae $ "1|3", "1", "2")
				RR4->RR4_NOTIFY := cTpNotTae
			Else
				RR4->RR4_NOTDOC := "1"
				RR4->RR4_NOTIFY := "1"
			EndIf
		RR3->(MsUnlock())
	EndIf
	
	RestArea(aArea)
	
Return

/*/{Protheus.doc} PonTAEWhen
Define quando os campos do grid podem ser editados
@type function
@author Cícero Alves
@since 08/01/2026
@return logical, Quando verdadeiro o campo poderá ser editado
/*/
Function PonTAEWhen()
	
	Local lRet		:= .T.
	Local cCampo 	:= ReadVar()
	Local oModel 	:= FwModelActive()
	Local cTipoReg	:= oModel:GetValue("PONAXTAE_RR4", "RR4_TPREG")
	
	Do Case
		Case cCampo == "M->RR4_FILFUN"
			If cTipoReg $ "1|2" .Or. !Empty(oModel:GetValue("PONAXTAE_RR4", "RR4_EMAIL"))
				lRet := .F.
			EndIf
		Case cCampo == "M->RR4_MAT"
			If cTipoReg $ "1|2" .Or. !Empty(oModel:GetValue("PONAXTAE_RR4", "RR4_EMAIL")) .Or. Empty(oModel:GetValue("PONAXTAE_RR4", "RR4_FILFUN"))
				lRet := .F.
			EndIf
		Case cCampo == "M->NOME"
			If cTipoReg $ "1|2|3" .Or. !Empty(oModel:GetValue("PONAXTAE_RR4", "RR4_MAT"))
				lRet := .F.
			EndIf
		Case cCampo == "M->RR4_ACAO"
			If cTipoReg $ "1"
				lRet := .F.
			EndIf
		Case cCampo == "M->RR4_EMAIL"
			If cTipoReg $ "1|2" .Or. !Empty(oModel:GetValue("PONAXTAE_RR4", "RR4_MAT"))
				lRet := .F.
			EndIf
		Case cCampo == "M->RR4_NOTDOC"
			lRet := .F.
		Case cCampo == "M->RR4_NOTIFY"
			If cTipoReg == "4" .Or. !Empty(oModel:GetValue("PONAXTAE_RR4", "RR4_EMAIL"))
				lRet := .F.
			EndIf
	EndCase
	
Return lRet

/*/{Protheus.doc} PonVldNiv
Adiciona ou remove as linhas de Gestores no grid de acordo com o campo RR3_NIVEL. Chamada pelo valid do campo
@type function
@author Cícero Alves
@since 08/01/2026
@return logical, Sempre verdadeiro
/*/
Function PonVldNiv()
	
	Local oModel 	:= FwModelActive()
	Local oView 	:= FwViewActive()
	Local oGrid		:= oModel:GetModel("PONAXTAE_RR4")
	Local nLines	:= oGrid:Length()
	Local nI		:= 0
	Local nNivel	:= oModel:GetValue("PONAXTAE_RR3", "RR3_NIVEL")
	
	lCanDelete := .T. // variável de controle para validação do delete
	
	For nI := 1 To nLines
		oGrid:Goline(nI)
		If oGrid:GetValue("RR4_TPREG") == "2"
			oGrid:SetValue("RR4_ORDEM", 0)
			oGrid:DeleteLine()
		EndIf
	Next nI
	
	oGrid:Goline(1)
	
	GetLastOrd(oGrid, 1)
	
	For nI := 1 To nNivel
		
		If oGrid:SeekLine({{"RR4_TPREG", "2"}, {"RR4_KEY", StrZero(nI, 2)}}, .T., .T.)
			oGrid:UnDeleteLine()
		Else
			oGrid:AddLine()
			oGrid:LoadValue("RR4_TPREG", "2")
			oGrid:LoadValue("NOME", STR0021 + " - " + StrZero(nI, 2)) // Gestor
			oGrid:LoadValue("RR4_ACAO", "1")
			oGrid:LoadValue("RR4_NOTDOC", "1")
			oGrid:LoadValue("RR4_NOTIFY", "1")
			oGrid:LoadValue("RR4_KEY", StrZero(nI, 2))
		EndIf
		
		oGrid:LoadValue("RR4_ORDEM", ++nOrdemA)
		
	Next nI
	
	lCanDelete := .F.
	
	OrdenaGrid()
	
	oGrid:Goline(1)
	oView:Refresh("PONAXTAE_RR4")
	
Return .T.

/*/{Protheus.doc} OrdenaGrid
Preenche o campo RR4_ORDEM do grid
@type static function
@author Cícero Alves
@since 08/01/2026
@return NIL, NIL
/*/
Static Function OrdenaGrid()
	
	Local oModel 	:= FwModelActive()
	Local oGrid		:= oModel:GetModel("PONAXTAE_RR4")
	Local nI		:= 0
	Local nOrdem	:= 1
	
	For nI := 1 To oGrid:Length()
		oGrid:GoLine(nI)
		If oGrid:IsDeleted()
			oGrid:LoadValue("RR4_ORDEM", 0)
		Else
			oGrid:LoadValue("RR4_ORDEM", nOrdem++)
		EndIf
	Next nI
	
Return

/*/{Protheus.doc} PnTAEDelOk
Verifica se a linha do grid pode ser deletada
@type static function
@author Cícero Alves
@since 08/01/2026
@param oGrid, object, objeto de modelo do FormGrid (FWFormGridModel)
@param nLine, numeric, Linha atual posicionada no modelo
@param cAction, character, Qual a ação realizada pelo usuário
@param cField, character, ID do campo
@return logical, Quando verdadeiro a linha poderá ser deletada
@see https://tdn.totvs.com/display/public/framework/MPFormModel 
/*/
Static Function PnTAEDelOk(oGrid, nLine, cAction, cField)
	
	Local lRet 		:= .T.
	Local cTipoReg	:= ""
	
	If nRR4Key == NIL
		GetLastKey(oGrid, oGrid:GetLine())
	EndIf
	
	If cAction == "DELETE" .And. !lCanDelete
		
		cTipoReg := oGrid:GetValue("RR4_TPREG")
		
		Do Case
			Case cTipoReg == "1" // Funcionário
				lRet := .F.
				// "Não é possível excluir o funcionário da lista de destinatários."
				Help(,,"HELP",, STR0009, 1, 0,,,,,, {STR0010}) // "O documento será enviado para cada funcionário ao gerar o relatório."
			Case cTipoReg == "2"
				lRet := .F.
				// "Não é possível excluir o Gestor da lista de destinatários."
				Help(,,"HELP",, STR0011, 1, 0,,,,,, {STR0012}) // "Altere o campo Nível para alterar os gestores que receberão o documento."
		EndCase
		
		If lRet
			oGrid:SetValue("RR4_ORDEM", 0)
			GetLastOrd(oGrid, nLine)
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} PnTaeLOK
Validação de linha
@type static function
@author Cícero Alves
@since 08/01/2026
@param oGrid, object, objeto de modelo do FormGrid (FWFormGridModel)
@param nLine, numeric, Linha atual posicionada no modelo
@return logical, Quando verdadeiro a linha é válida
/*/
Static Function PnTaeLOK(oGrid, nLine)
	
	Local lRet 		:= .T.
	Local cTpReg 	:= ""
	
	If nOrdemA == 0
		GetLastOrd(oGrid, nLine)
	EndIf
	
	If !oGrid:IsDeleted() .And. oGrid:GetValue("RR4_TPREG") $ " |3|4"
		
		If !Empty(oGrid:GetValue("RR4_EMAIL")) .And. !oGrid:GetValue("RR4_ACAO") == "4"
			lRet := .F.
			//"Para e-Mails externos é permitida apenas a ação de Observar"
			Help(,,"HELP",, STR0013, 1, 0,,,,,, {STR0014}) // "Para as demais ações selecione um funcionário informando a filial e matrícula"
		EndIf
		
		If Empty(oGrid:GetValue("RR4_MAT")) .And. Empty(oGrid:GetValue("RR4_EMAIL"))
			lRet := .F.
			// "É necessário informar uma matrícula ou um e-mail válido."
			Help(,,"HELP",, STR0015, 1, 0,,,,,, {STR0016}) // "Selecione uma filial e matrícula ou informe um e-mail para um observador externo"
		EndIf
		
		If lRet
			If Empty(oGrid:GetValue("RR4_TPREG"))
				If !Empty(oGrid:GetValue("RR4_MAT"))
					cTpReg := "3"
				Else
					cTpReg := "4"
				EndIf
				
				oGrid:SetValue("RR4_TPREG", cTpReg)
				
			EndIf
			
			If Empty(oGrid:GetValue("RR4_ORDEM"))
				oGrid:SetValue("RR4_ORDEM", ++nOrdemA)
			EndIf
			
			If Empty(oGrid:GetValue("RR4_KEY"))
				oGrid:SetValue("RR4_KEY", StrZero(++nRR4Key, 2))
			EndIf
			
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} GetLastOrd
Retorna a última ordem utilizada no grid, desconsidera as linhas deletadas
@type static function
@author Cícero Alves
@since 08/01/2026
@param oGrid, object, objeto de modelo do FormGrid (FWFormGridModel)
@param nLine, numeric, Linha atual posicionada no modelo
@return NIL, NIL
/*/
Static Function GetLastOrd(oGrid, nLine)
	
	Local nI	:= oGrid:Length()
	
	While nI >= 1
		oGrid:GoLine(nI)
		If !oGrid:IsDeleted() .And. oGrid:GetValue("RR4_ORDEM") > 0
			nOrdemA := oGrid:GetValue("RR4_ORDEM")
			EXIT
		EndIf
		nI--
	EndDo
	
	oGrid:Goline(nLine)
	
Return

/*/{Protheus.doc} PnTaeVlFil
Limpa os campo Matrícula e Nome quando a filial é limpa. Chamada pela validação do campo RR4_FILFUN
@type function
@author Cícero Alves
@since 09/01/2026
@return Logical, Sempre Verdadeiro
/*/
Function PnTaeVlFil()
	
	Local oModel 	:= FwModelActive()
	Local oGrid		:= oModel:GetModel("PONAXTAE_RR4")
	
	If Empty(oGrid:GetValue("RR4_FILFUN"))
		oGrid:LoadValue("RR4_MAT", " ")
		oGrid:LoadValue("NOME", " ")
		oGrid:LoadValue("RR4_TPREG", "")
	EndIf
	
Return .T.

/*/{Protheus.doc} PnTaeVlMat
Busca pelo funcionário utilizando a filial e matrícula informadas. Chamada pela validação do campo RR4_MAT
@type function
@author Cícero Alves
@since 09/01/2026
@return logical, Verdadeiro se encontrou o funcionário
/*/
Function PnTaeVlMat()
	
	Local oModel 	:= FwModelActive()
	Local oGrid		:= oModel:GetModel("PONAXTAE_RR4")
	Local lRet		:= .T.
	
	If !Empty(oGrid:GetValue("RR4_MAT"))
		dbSelectArea("SRA")
		dbSetOrder(1)
		If dbSeek(oGrid:GetValue("RR4_FILFUN") + oGrid:GetValue("RR4_MAT"))
			oGrid:LoadValue("NOME", SRA->RA_NOME)
		Else
			lRet := .F.
		EndIf
	Else
		oGrid:LoadValue("NOME", " ")
		oGrid:LoadValue("RR4_TPREG", "")
	EndIf
	
Return lRet

/*/{Protheus.doc} PnTaeVMail
Altera os campos RR4_NOTDOC e RR4_NOTIFY para "1", pois esses não serão mais editáveis quando o email é preenchido
@type function
@author Cícero Alves
@since 16/01/2026
@return logical, Sempre verdadeiro
/*/
Function PnTaeVMail()
	
	Local oModel 	:= FwModelActive()
	Local oGrid		:= oModel:GetModel("PONAXTAE_RR4")
	
	If !Empty(oGrid:GetValue("RR4_EMAIL"))
		oGrid:LoadValue("RR4_NOTDOC", "1")
		oGrid:LoadValue("RR4_NOTIFY", "1")
	EndIf
	
Return .T.

/*/{Protheus.doc} PnTaeFil
Filtro para a consulta padrão do campo RR4_FILFUN
@type function
@author Cícero Alves
@since 09/01/2026
@return character, Filtro para a consulta em SQL utilizando a filial informada
/*/
function PnTaeFil()
	
	Local oModel 	:= FwModelActive()
	
	Local cRet := "@RA_FILIAL = '" + oModel:GetValue("PONAXTAE_RR4", "RR4_FILFUN") + "'"
	
Return cRet

/*/{Protheus.doc} ValidLogin
Realiza a validação do Usuário e Senha do TAE informados
@type static function
@author Cícero Alves
@since 09/01/2026
@param oModel, object, objeto de modelo (MPFormModel)
@return logical, Verdadeiro quando o login no TAE é realizado com sucesso
/*/
Static Function ValidLogin(oModel)
	
	Local lRet		:= .T.
	Local oSign		:= Nil
	
	If !Empty(AllTrim(oModel:GetValue("PONAXTAE_RR3", "USER"))) .And. !Empty(AllTrim(oModel:GetValue("PONAXTAE_RR3", "PWORD")))
		If !Empty(SuperGetMv('MV_SIGNURL',, ""))
			
			oSign := PONXTAE():New()
			oSign:authenticate(AllTrim(oModel:GetValue("PONAXTAE_RR3", "USER")), AllTrim(oModel:GetValue("PONAXTAE_RR3", "PWORD")))
			
			If !oSign:isAuthenticated()
				//"Não foi possível efetuar a autenticação no Totvs Assinatura Eletrônica"
				Help( ,, "HELP",, STR0017, 1,,,,,,, {STR0018}) // "Verifique o usuário e senha informados."
				lRet := .F.
			EndIf
			
			oSign:destroy()
		Else
			//"Para configurar a integração com o Totvs Assinatura Eletrônica é necessário informar o parâmetro MV_SIGNURL no configurador"
			Help( ,, "HELP",, STR0017, 1,,,,,,, {STR0019}) // "Para configurar a integração com o Totvs Assinatura Eletrônica é necessário informar o parâmetro MV_SIGNURL no configurador."
			lRet := .F.
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} PnGetInfo
Retorna o conteúdo dos campos RR3_USER e RR3_PWORD descriptografados
@type function
@author Cícero Alves
@since 09/01/2026
@param nTipo, numeric, 1 para RR3_USER; 2 para RR3_PWORD
@return character, Conteúdo do campo solicitado
/*/
Function PnGetInfo(nTipo)
	
	Local cInfo := ""
	
	DEFAULT nTipo := 0
	
	If nTipo == 1 .And. !Empty(RR3->RR3_USER)
		cInfo := RC4Crypt(AllTrim(RR3->RR3_USER), "123456789", .F., .T.)
	ElseIf nTipo == 2 .And. !Empty(RR3->RR3_PWORD)
		cInfo := RC4Crypt(AllTrim(RR3->RR3_PWORD), "123456789", .F., .T.)
	ElseIf nTipo == 3
		If RR4->RR4_TPREG == "1"
			cInfo := STR0020 // "Funcionário"
		ElseIf RR4->RR4_TPREG == "2"
			cInfo := STR0021 + " - " + RR4->RR4_KEY // "Gestor"
		Else
			cInfo := RR4->RR4_NOME
		EndIf
	EndIf
	
Return cInfo

/*/{Protheus.doc} GetLastKey
Busca pelo maior valor do campo RR4_KEY já utilizado
@type static function
@author Cícero Alves
@since 16/01/2026
@param oGrid, object, objeto de modelo do FormGrid (FWFormGridModel)
@param nLine, numeric, Linha atual posicionada no modelo
@return numeric, Maior valor do campo RR4_KEY já utilizado
/*/
Static Function GetLastKey(oGrid, nLine)
	
	Local nI := 0
	
	nRR4Key := 0
	
	oGrid:GoLine(1)
	
	For nI := 1 To oGrid:Length()
		oGrid:GoLine(nI)
		If oGrid:GetValue("RR4_TPREG") $ "3|4" .And. Val(oGrid:GetValue("RR4_KEY")) > nRR4Key
			nRR4Key := Val(oGrid:GetValue("RR4_KEY"))
		EndIf
	Next nI
	
	
Return nRR4Key

/*/{Protheus.doc} ResetStatic
Reinicializa as variáveis static utilizadas na rotina
@type static function
@author Cícero Alves
@since 16/01/2026
@return NIL, NIL
/*/
Static Function ResetStatic()
	
	Static lCanDelete := .F.
	Static lRR3OK := .F.
	Static nOrdemA := 0
	Static nRR4Key := NIL
	
	lRR3OK := .F.
	lCanDelete := .F.
	nOrdemA := 0
	nRR4Key := NIL
	
Return 

/*/{Protheus.doc} PnVldMsg
Valida a existência de caracteres não aceitos pelo TAE nos campos de Assunto e Mensagem do e-mail
@type function
@author Cícero Alves
@since 02/04/2026
@param nCpo, numeric, Determina o campo que será validado 
@return logical, verdadeiro se o texto não possuir nenhum caractere especial inválido
/*/
Function PnVldMsg(nCpo)
	
	Local lRet 		:= .F.
	Local oModel 	:= FwModelActive()
	Local cConteud	:= ""
	Local cPattern	:= "[a-zA-Z0-9_@.,()!?:+\-%$\s]+"
	Local oRegEx 	:= tlpp.regex.Regex():New(cPattern)
	
	Do Case
		Case nCpo == 1
			cConteud := AllTrim(oModel:GetValue("PONAXTAE_RR3", "RR3_SUB"))
		Case nCpo == 2
			cConteud := AllTrim(oModel:GetValue("PONAXTAE_RR3", "RR3_MSG"))
	EndCase
	
	lRet := oRegEx:Matches(cPattern, cConteud)
	
	If !lRet
		// "O texto digitado possui caracteres não permitidos." - "Revise o texto digitado." - "Os caracteres especiais permitidos são:"
		Help( ,, "HELP",, STR0029, 1,,,,,,, {STR0030, STR0031, " _ @ . , ( ) ! ? : + - % $ "})
	EndIf
	
Return lRet

//-----------------------------------------FWModelEvent-----------------------------------------\\

/*/{Protheus.doc} PonTaeEvt
Classe responsável pela interceptação do Commit
@type class
@author Cícero Alves
@since 14/01/2026
@see https://tdn.totvs.com/pages/releaseview.action?pageId=269552294
/*/
Class PonTaeEvt FROM FWModelEvent
	
	Data lRet
	Method New()
	Method Before()
	Method After()
	
End Class

/*/{Protheus.doc} PonTaeEvt:New
Construtor da classe PonTaeEvt
@type method
@author Cícero Alves
@since 16/01/2026
@return NIL, NIL
/*/
Method New() Class PonTaeEvt
Return

/*/{Protheus.doc} PonTaeEvt:Before
Método chamado pelo MVC quando ocorrer as ações do commit antes da gravação de cada submodelo (field ou cada linha de uma grid)
Grava o campo RR4_NOME apenas para alguns tipos de resgistro
@type method
@author Cícero Alves
@since 14/01/2026
@param oModel, object, Submodelo
@param cModelId, character, ID do submodelo
@param cAlias, character, Alias do submodelo
@param lNewRecord, logical, Indica se é um registro novo
@return NIL, NIL
@see https://tdn.totvs.com/pages/releaseview.action?pageId=269552294
/*/
Method Before(oModel, cModelId, cAlias, lNewRecord) Class PonTaeEvt
	
	If oModel:GetOperation() != MODEL_OPERATION_DELETE .And. cAlias == "RR4"
		
		If oModel:GetValue("RR4_TPREG") $ "3|4"
			oModel:LoadValue("RR4_NOME", oModel:GetValue("NOME")) 
		EndIf
		
		If oModel:GetValue("RR4_NOTIFY") == "3"
			oModel:LoadValue("RR4_NOTDOC", "2")
		Else
			oModel:LoadValue("RR4_NOTDOC", "1")
		EndIf
	EndIf
	
Return

/*/{Protheus.doc} PonTaeEvt:After
Método chamado pelo MVC quando ocorrer as ações do commit depois da gravação de cada submodelo (field ou cada linha de uma grid)
Realiza a criptografia do usuário e senha informados antes de gravar na tabela
@type method
@author Cícero Alves
@since 16/01/2026
@param oModel, object, Submodelo
@param cModelId, character, ID do submodelo
@param cAlias, character, Alias do submodelo
@param lNewRecord, logical, Indica se é um registro novo
@return NIL, NIL
@see https://tdn.totvs.com/pages/releaseview.action?pageId=269552294
/*/
Method After(oModel, cModelId, cAlias, lNewRecord) Class PonTaeEvt
	
	Local cUserTAE	:= ""
	Local cPWord	:= ""
	
	If oModel:GetOperation() != MODEL_OPERATION_DELETE .And. cAlias == "RR3"
		cUserTAE	:= If(!Empty(oModel:GetValue("USER")), RC4Crypt(AllTrim(oModel:GetValue("USER")), "123456789", .T.), "")
		cPWord	:= If(!Empty(oModel:GetValue("PWORD")), RC4Crypt(AllTrim(oModel:GetValue("PWORD")), "123456789", .T.),"")
		
		RecLock("RR3")
			RR3->RR3_USER := cUserTAE
			RR3->RR3_PWORD := cPWord
		RR3->(MsUnlock())
	EndIf
	
Return
