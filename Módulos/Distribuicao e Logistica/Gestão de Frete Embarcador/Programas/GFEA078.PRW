#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE _CRLF CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA078
Painel de Requisições

@author João Leonardo Schmidt
@since 05/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA078()
	Local oBrowse
	Local cMVGFE013	:= SuperGetMV("MV_GFE013",.F.,"")
	Local aAux
		
	Private aRotina := MenuDef()
		
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GXR")
	oBrowse:SetMenuDef("GFEA078")
	oBrowse:SetDescription("Painel Requisições de Frete")
	
	oBrowse:AddLegend("GXR_SIT=='1'", "WHITE" , "Em Edição", "1") //"Em Edição"
	oBrowse:AddLegend("GXR_SIT=='2'", "BLUE"  , "Requisitada", "1") //"Requisitada"
	oBrowse:AddLegend("GXR_SIT=='3'", "YELLOW", "Em Negociação", "1") //"Em Negociação"
	oBrowse:AddLegend("GXR_SIT=='4'", "GREEN" , "Atendida", "1") //"Atendida"
	oBrowse:AddLegend("GXR_SIT=='5'", "RED"   , "Cancelada", "1") //"Cancelada"
	
	If !Empty(cMVGFE013)
		aAux := StrTokArr(cMVGFE013, ";")
		
		oBrowse:AddLegend("EMPTY(GXR_DTLIM)", "WHITE" , "Prioridade Não Informada", "2") 
		oBrowse:AddLegend({|| (GXR_DTLIM - Date()) < 0}, "BLACK" , "Prioridade Vencida", "2") //"Em Edição"
		oBrowse:AddLegend({|| (GXR_DTLIM - Date()) >= Val(Substr(aAux[1],1,At("-",aAux[1]) - 1)) .And. (GXR_DTLIM - Date()) <= Val(Substr(aAux[1],At("-",aAux[1]) + 1,At("/",aAux[1]) - ( At("-",aAux[1]) + 1)))}, "RED"  	, Substr(aAux[1],At("/",aAux[1]) + 1), "2")
		oBrowse:AddLegend({|| (GXR_DTLIM - Date()) >= Val(Substr(aAux[2],1,At("-",aAux[2]) - 1)) .And. (GXR_DTLIM - Date()) <= Val(Substr(aAux[2],At("-",aAux[2]) + 1,At("/",aAux[2]) - ( At("-",aAux[2]) + 1)))}, "YELLOW"  	, Substr(aAux[2],At("/",aAux[2]) + 1), "2")
		oBrowse:AddLegend({|| (GXR_DTLIM - Date()) >= Val(Substr(aAux[3],1,At("-",aAux[3]) - 1)) .And. (GXR_DTLIM - Date()) <= Val(Substr(aAux[3],At("-",aAux[3]) + 1,At("/",aAux[3]) - ( At("-",aAux[3]) + 1)))}, "GREEN"  	, Substr(aAux[3],At("/",aAux[3]) + 1), "2")
	
		oBrowse:AddFilter("Prioridade Vencida", "GXR_DTLIM < Date() .And. GXR_DTLIM > SToD('')")
		oBrowse:AddFilter(Substr(aAux[1],At("/",aAux[1]) + 1), "(GXR_DTLIM - Date()) >= " + Substr(aAux[1],1,At("-",aAux[1]) - 1) + " .And. (GXR_DTLIM - Date()) <= " + Substr(aAux[1],At("-",aAux[1]) + 1,At("/",aAux[1]) - ( At("-",aAux[3]) + 1)))
		oBrowse:AddFilter(Substr(aAux[2],At("/",aAux[2]) + 1), "(GXR_DTLIM - Date()) >= " + Substr(aAux[2],1,At("-",aAux[2]) - 1) + " .And. (GXR_DTLIM - Date()) <= " + Substr(aAux[2],At("-",aAux[2]) + 1,At("/",aAux[2]) - ( At("-",aAux[3]) + 1)))
		oBrowse:AddFilter(Substr(aAux[3],At("/",aAux[3]) + 1), "(GXR_DTLIM - Date()) >= " + Substr(aAux[3],1,At("-",aAux[3]) - 1) + " .And. (GXR_DTLIM - Date()) <= " + Substr(aAux[3],At("-",aAux[3]) + 1,At("/",aAux[3]) - ( At("-",aAux[3]) + 1)))
	EndIf	
	
	// Cria o filtro para o programa exibir apenas requisições finalizadas pelo usuário requisitante
	// A segunda parte do filtro é referente a visualização das requisições apenas do usuário, dos subordinados ou sem usuário definido
	oBrowse:SetFilterDefault("@ GXR_SIT <> '1' AND (GXR_USUNEG = '" + Space(TamSX3("GXR_USUNEG")[1]) + "' OR GXR_USUNEG = '" + RetCodUsr() + "')") 
	
	// Inclusão das opções de visão
	oBrowse:SetAttach(.T.)
	
	oBrowse:Activate()
Return(Nil)

Static Function MenuDef()
	Local aRotina := {}
	
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	AAdd(aRotina, {"Pesquisar"					, 'AxPesqui'									, 0, 1  , 0, .T. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Visualizar"					, "VIEWDEF.GFEC059"								, 0, 2  , 0, .T. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Alterar"					, "VIEWDEF.GFEA078"								, 0, 4  , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Imprimir"					, "VIEWDEF.GFEA078"								, 0, 8  , 0, .T. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Associar Requisição"		, "AssociarReq()"								, 0, 9  , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Desassociar Requisição"		, "DesassociarReq()"							, 0, 10 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Concluir Requisição"		, "ConcluirReq()"								, 0, 11 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Registrar Contratos"		, "GFE078RegContrato()"							, 0, 12 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Comentar"					, "GFE059ACOM('2')"								, 0, 13 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Anexos"						, "MsDocument('GXR',GXR->(RecNo()), 3)"			, 0,  4 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Reenviar Aviso Conclusão"	, "GFEA79MAIL()"								, 0, 14 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Solicitar Cotação"			, "GFEA78COT(GXR->GXR_FILIAL, GXR->GXR_IDREQ)"	, 0, 15 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Reabrir Requisição"			, "ReabrirReq()"								, 0, 16 , 0, .F. /*Habilita Menu Funcional*/})
Return aRotina

Static Function ModelDef()
	Local oModel
	Local oModelGXS
	
	oModel := MPFormModel():New("GFEA078", /* */, {|oMod| GFEA078POS(oMod)} /**/, /**/, /**/, /*bCancel*/)
	oModel:AddFields("GFEA078_GXR", Nil, FWFormStruct(1,"GXR"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GXR_FILIAL", "GXR_IDREQ"})
	oModel:SetDescription("Painel Requisições")
	
	oModel:AddGrid("GFEA078_GXS", "GFEA078_GXR",FWFormStruct(1,'GXS'))
	oModel:SetRelation("GFEA078_GXS",{{"GXS_FILIAL","xFilial('GXS')"} ,{"GXS_IDREQ","GXR_IDREQ"}},"GXS_FILIAL+GXS_IDREQ")
	
	oModel:SetOptional("GFEA078_GXS", .T. )
	
	oModelGXS := oModel:GetModel("GFEA078_GXS")
	oModelGXS:SetUniqueLine({"GXS_SEQ"})
	
	oModel:SetVldActivate({ |oMod| GFEA078VL( oMod )})
	oModel:SetActivate()	
Return oModel

Static Function ViewDef()
	Local oModel  	 := FWLoadModel("GFEA078")
	Local oStructGXR := FWFormStruct(2,"GXR")
	Local oStructGXS := FWFormStruct(2,'GXS')
	Local oView   	 := Nil
	
	oView := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField("GFEA078_GXR",oStructGXR,/*cLinkID*/)
	oView:AddGrid('GFEA078_GXS',oStructGXS)
	
	oView:createHorizontalBox("MASTER", 60)
	oView:createHorizontalBox("DETAIL", 40)

	oView:CreateFolder("COTACOES","DETAIL")
	oView:AddSheet("COTACOES","DET01","Cotações de Frete") //"Exceções"

	oView:CreateHorizontalBox( "DETAILCOTAC"  , 100,,,"COTACOES","DET01" )
	
	oView:SetOwnerView("GFEA078_GXR","MASTER")
	oView:SetOwnerView("GFEA078_GXS","DETAILCOTAC")
		
	oStructGXS:RemoveField("GXS_IDREQ")
	
	oView:AddIncrementField("GFEA078_GXS","GXS_SEQ")
	
	If GFXCP12123("GXS_FRTCOT")
		oView:AddUserButton("Buscar Referências", "MAGIC_BMP", {|oView| GFE078BuscaReferencia(oView)}, ) //""
	EndIf

Return oView

Function AssociarReq()
	Local oPainelRequisicao := GFEPainelRequisicao():New()
	
	// "Seta" os dados necessários para execução do método de Assumir Requisição
	oPainelRequisicao:setIdReq(GXR->GXR_IDREQ)
	oPainelRequisicao:setUsuNegoc(RetCodUsr())
	
	// Executa o método de Assumir Requisição
	oPainelRequisicao:ValidarAssociarRequisicao()
	
	// Verificado a situação após a execução
	If oPainelRequisicao:getStatus() == .F.
		// Busca o retorno da execução do método
		Help( ,, 'HELP',, oPainelRequisicao:getMensagem(), 1, 0,)
		// Destroy o objeto criado para os métodos do Painel de Requisição
		oPainelRequisicao:Destroy(oPainelRequisicao)
		Return
	EndIf
	
	// Define os valores que serão atualizados
	oPainelRequisicao:setSitReq("3")
	
	// Realiza a alteração dos dados
	oPainelRequisicao:AlterarSituacao()
	
	// Destroy o objeto criado para os métodos do Painel de Requisição
	oPainelRequisicao:Destroy(oPainelRequisicao)
Return

Function DesassociarReq()
	Local oPainelRequisicao := GFEPainelRequisicao():New()
	
	// "Seta" os dados necessários para execução do método de Assumir Requisição
	oPainelRequisicao:setIdReq(GXR->GXR_IDREQ)
	oPainelRequisicao:setUsuNegoc(RetCodUsr())
	
	// Executa o método de Assumir Requisição
	oPainelRequisicao:ValidarDesassociarRequisicao()
	
	// Verificado a situação após a execução
	If oPainelRequisicao:getStatus() == .F.
		// Busca o retorno da execução do método
		Help( ,, 'HELP',, oPainelRequisicao:getMensagem(), 1, 0,)
		// Destroy o objeto criado para os métodos do Painel de Requisição
		oPainelRequisicao:Destroy(oPainelRequisicao)
		Return
	EndIf
	
	// Define os valores que serão atualizados
	oPainelRequisicao:setSitReq("2")
	oPainelRequisicao:setUsuNegoc(Space(TamSX3("GXR_USUNEG")[1]))
	
	// Realiza a alteração dos dados
	oPainelRequisicao:AlterarSituacao()
	
	// Destroy o objeto criado para os métodos do Painel de Requisição
	oPainelRequisicao:Destroy(oPainelRequisicao)
Return ()

Function ConcluirReq()
	Local oPainelRequisicao := GFEPainelRequisicao():New()
	
	// "Seta" os dados necessários para execução do método de Concluir Requisição
	oPainelRequisicao:setIdReq(GXR->GXR_IDREQ)
	oPainelRequisicao:setUsuNegoc(RetCodUsr())
	
	// Executa o método de Concluir Requisição
	oPainelRequisicao:ValidarConcluirRequisicao()
	
	// Verificado a situação após a execução
	If oPainelRequisicao:getStatus() == .F.
		// Busca o retorno da execução do método
		Help( ,, 'HELP',, oPainelRequisicao:getMensagem(), 1, 0,)
		// Destroy o objeto criado para os métodos do Painel de Requisição
		oPainelRequisicao:Destroy(oPainelRequisicao)
		Return
	EndIf
	
	If MSGYESNO("Deseja concluir esta requisição? Após a conclusão da requisição se houver pendência de geração de contrato será solicitada a confirmação das geração dos contratos.")
		// Define os valores que serão atualizados
		oPainelRequisicao:setSitReq("4")
	EndIf
	
	CursorWait()
	
	If GFXCP12123("GXR_REQACT") .And. GXR->GXR_REQACT == "2"
		GFE059Aceite(GXR->GXR_IDREQ)
		
		oPainelRequisicao:SetReqAct('2')
	EndIf
	
	oPainelRequisicao:SendMailConclusion()
	If oPainelRequisicao:getStatus() == .F.
		GFEHelp(oPainelRequisicao:getMensagem(),"Verifique a mensagem de ocorrência, realize o ajuste e envie novamente.","Envio de Email da Requisição")
		oPainelRequisicao:setAviso('3') // 3=Tentativa de Envio                                                                     
	Else
		oPainelRequisicao:setAviso('2') // 2=Enviado com Sucesso
	EndIf
	
	// Realiza a alteração dos dados
	oPainelRequisicao:AlterarSituacao()
	
	If GXR->GXR_FDADE == "2"
		GFE078RegContrato()
	EndIf
	
	// Destroy o objeto criado para os métodos do Painel de Requisição
	oPainelRequisicao:Destroy(oPainelRequisicao)
	CursorArrow()
Return ()

Function ReabrirReq()
	
	If GXR->GXR_SIT == "4"
		If MSGYESNO("Deseja reabrir esta requisição?")
			GXR->(dbSetOrder(1))
			If GXR->(dbSeek(xFilial("GXR") + GXR->GXR_IDREQ))
				RecLock("GXR", .F.)
					GXR->GXR_SIT    := "3"
					GXR->GXR_USUNEG := RetCodUsr()
				GXR->(MsUnlock())
			EndIf
		EndIf
	Else
		GFEHelp("Requisição não está atendida.","Apenas requisições atendidas podem ser abertas.","Não é possível reabrir a requisição.")
	EndIf
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA078VL
Função responsável por validar se o usuário pode realizar a alteração dos dados 

@author João Leonardo Schmidt
@since 17/04/2018
@version 1.0

@param oModel - Modelo de Dados da função principal
/*/
//-------------------------------------------------------------------
Function GFEA078VL(oModel)
	Local nOp := oModel:GetOperation()
	Local oPainelRequisicao := GFEPainelRequisicao():New()
	
	If nOp == MODEL_OPERATION_UPDATE 
		// "Seta" os dados necessários para execução do método de Assumir Requisição
		oPainelRequisicao:setSitReq(GXR->GXR_SIT)
		oPainelRequisicao:setUsuNegoc(RetCodUsr())
	
		// Executa o método de Validar Alteração
		oPainelRequisicao:ValidarAlterarDados()
	
		// Verificado a situação após a execução
		If oPainelRequisicao:getStatus() == .F.
			// Busca o retorno da execução do método
			Help( ,, 'HELP',, oPainelRequisicao:getMensagem(), 1, 0,)
			// Destroy o objeto criado para os métodos do Painel de Requisição
			oPainelRequisicao:Destroy(oPainelRequisicao)
			Return .F.
		EndIf
	
		// Destroy o objeto criado para os métodos do Painel de Requisição
		oPainelRequisicao:Destroy(oPainelRequisicao)
	EndIf
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA078VL
Função responsável por validar o model de alteração de dados 

@author João Leonardo Schmidt
@since 17/04/2018
@version 1.0

@param oModel - Modelo de Dados da função principal
/*/
//-------------------------------------------------------------------
Function GFEA078POS(oModel)
	Local nOpc     	 		:= oModel:GetOperation()
	Local oModelGXS 	    := oModel:GetModel("GFEA078_GXS")
	Local oPainelRequisicao := GFEPainelRequisicao():New()
	Local nI			    := 0
	
	If nOpc == MODEL_OPERATION_UPDATE
		If M->GXR_PESOT == 0 .And. M->GXR_QTDET == 0 .And. M->GXR_VALORT == 0
			GFEHelp("Existem campos obrigatórios que não foram preenchidos!","Verificar os campos Peso Total, Quantidade Total e Valor Total para que ao menos um destes possua valor.","SIGAGFE - GFEA078")
			Return .F.
		EndIf
	
		For nI := 1 To oModelGXS:Length()
			If oModelGXS:IsDeleted(nI)
				Loop
			EndIf
			oModelGXS:GoLine(nI)
		
			// "Seta" os dados necessários para execução do método de Validar Resultado
			oPainelRequisicao:setResulSeq(FwFldGet("GXS_SEQ",nI))
			oPainelRequisicao:setSel(FwFldGet("GXS_MRKBR",nI))
			oPainelRequisicao:setJustifSel(FwFldGet("GXS_JUSTIF",nI))
			oPainelRequisicao:setCdTrp(FwFldGet("GXS_CDTRP",nI))
			oPainelRequisicao:setFilContrato(FwFldGet("GXS_FILCT",nI))
			oPainelRequisicao:setNrContrato(FwFldGet("GXS_NRCT",nI))
			oPainelRequisicao:setFilTabelaFrete(FwFldGet("GXS_FILTAB",nI))
			oPainelRequisicao:setNrTab(FwFldGet("GXS_NRTAB",nI))
			oPainelRequisicao:setNrNeg(FwFldGet("GXS_NRNEG",nI))			
			oPainelRequisicao:setFilReferencia(FwFldGet("GXS_FILREF",nI))
			oPainelRequisicao:setNrReferencia(FwFldGet("GXS_CODREF",nI))
			oPainelRequisicao:setFrtPes(FwFldGet("GXS_FRTPES",nI))
			oPainelRequisicao:setTpPrazo(FwFldGet("GXS_TPPRAZ",nI))
			oPainelRequisicao:setPrazo(FwFldGet("GXS_PRAZO",nI))
			oPainelRequisicao:setReqDtIni(M->GXR_DTINI)
			oPainelRequisicao:setReqDtFim(M->GXR_DTTER)
			
			// Executa o método de Validar Resultado
			oPainelRequisicao:ValidarResultado()
			
			// Verificado a situação após a execução
			If oPainelRequisicao:getStatus() == .F.
				// Busca o retorno da execução do método
				Help( ,, 'HELP',, oPainelRequisicao:getMensagem(), 1, 0,)
				// Destroy o objeto criado para os métodos do Painel de Requisição
				oPainelRequisicao:Destroy(oPainelRequisicao)
				Return .F.
			EndIf
		Next
		
		// Destroy o objeto criado para os métodos do Painel de Requisição
		oPainelRequisicao:Destroy(oPainelRequisicao)
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE078RegContrato
Função responsável por registrar os contratos de forma automática

@author Leonardo Ribas Jimenez Hernandez
@since 18/05/2018
@version 1.0

@param 
/*/
//-------------------------------------------------------------------
Function GFE078RegContrato()
	Local oGerarContrato := GFEGerarContrato():New()

	// "Seta" os dados necessários para execução do método de Gerar Contrato
	oGerarContrato:setIdReq(GXR->GXR_IDREQ)
	oGerarContrato:setUsuNegoc(RetCodUsr())
	
	// Executa o método de Validar Registrar Contrato
	oGerarContrato:ValidarRegistrarContrato()
	
	// Verificado a situação após a execução
	If oGerarContrato:getStatus() == .F.
		// Busca o retorno da execução do método
		Help( ,, 'HELP',, oGerarContrato:getMensagem(), 1, 0,)
		// Destroy o objeto criado para os métodos do Gerar Contrato
		oGerarContrato:Destroy(oGerarContrato)
		Return
	EndIf
	
	If MSGYESNO("Será gerado um contrato de transporte para cada cotação selecionada da requisição que ainda não tenha contrato relacionado. Deseja continuar?")
		CursorWait()
		//Função responsável por efetivar o registro do contrato
		GFE078EfetivaContrato(GXR->GXR_IDREQ)
		CursorArrow()
	EndIf
	
	// Destroy o objeto criado para os métodos de Gerar Contrato
	oGerarContrato:Destroy(oGerarContrato)
Return ()

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE078EfetivaContrato
Função responsável por efetivar os contratos de forma automática

@author Leonardo Ribas Jimenez Hernandez
@since 18/05/2018
@version 1.0

@param cIdReq - Id da Requisição de Negociação de Frete
/*/
//-------------------------------------------------------------------
Function GFE078EfetivaContrato(cIdReq)
	Local lRet 				:= .F.
	Local lGerar 			:= .F.
	Local cUsuario 			:= ""
	Local nX				:= 0
	Local aCotacoes 		:= {}
	Local oGerarContrato	:= GFEGerarContrato():New()
	Local GFELog			:= GFEViewProc():New()
	Local nTotal			:= 0
	Local nSucesso			:= 0
	Local nErro				:= 0
	Local cMsg				:= ""
	Local cErroMsg			:= ""
	Local aDtFret			:= {}
	Local cMVAGRORI			:= SuperGetMV("MV_AGRORI",.F.,.F.)
	Local cMVSIGAAGR		:= SuperGetMV("MV_SIGAAGR",.F.,.F.)
	Local lRetAGR001		:= .T.
	
	Private nVlFrtUni		:= 0
	Private nVlFrtFix		:= 0

	cCodUsu := RetCodUsr()
	cUsuario := UsrRetName(cCodUsu)

	GXR->(dbSetOrder(1))
	If GXR->(dbSeek(xFilial("GXR") + cIdReq))
		GXS->(dbSetOrder(1))
		If GXS->(dbSeek(xFilial("GXS") + cIdReq))
			While !GXS->(Eof()) .And. GXS->GXS_IDREQ == cIdReq 
				If GXS->GXS_MRKBR
					If !Empty(GXS->GXS_NRCT)
						GXS->(dbSkip())
						Loop
					EndIf
					aDtFret := GerarDtFret(GXR->GXR_DTTER,GXS->GXS_PRAZO,GXS->GXS_TPPRAZ) 
					If GFXCP12117("GXR_OBSCGA") .And. GFXCP12117("GXT_OBSDGA");
						.And. GFXCP12117("GXR_UNIMED") .And. GFXCP12117("GXS_FRTQTD")
						AADD(aCotacoes,{GXS->GXS_NRCT,; //1
							DtoS(Date()),; //2
							cUsuario,; // 3
							GXS->GXS_CDTRP,; //4
							GXR->GXR_CDCLFR,; //5
							GXR->GXR_CDTPOP,; //6
							GXS->GXS_PESOT,; //7
							GXS->GXS_QTDET,; //8
							GXR->GXR_DTINI,; //9     //certo
							GXR->GXR_DTTER,; //10   //vai pra data entrega
							aDtFret[2],; //11   // dt termino - prazo
							GXS->GXS_NRTAB,; //12
							GXS->GXS_NRNEG,; //13
							GXS->GXS_SEQ,;   //14
							GXR->GXR_NRCIDO,; //15
							GXR->GXR_NRCIDD,; //16
							GXR->GXR_UMPESO,; //17
							GXS->GXS_FRTPES,; //18
							GXR->GXR_OBSCGA,; //19
							GXR->GXR_OBSDGA,;
							GXR->GXR_UNIMED,;
							GXS->GXS_FRTQTD}) 
						lRet := .T.
					Else
						AADD(aCotacoes,{GXS->GXS_NRCT,; //1
							DtoS(Date()),; //2
							cUsuario,; // 3
							GXS->GXS_CDTRP,; //4
							GXR->GXR_CDCLFR,; //5
							GXR->GXR_CDTPOP,; //6
							GXS->GXS_PESOT,; //7
							GXS->GXS_QTDET,; //8
							GXR->GXR_DTINI,; //9     //certo
							GXR->GXR_DTTER,; //10   //vai pra data entrega
							aDtFret[2],; //11   // dt termino - prazo
							GXS->GXS_NRTAB,; //12
							GXS->GXS_NRNEG,; //13
							GXS->GXS_SEQ,;   //14
							GXR->GXR_NRCIDO,; //15
							GXR->GXR_NRCIDD,; //16
							GXR->GXR_UMPESO,; //17
							GXS->GXS_FRTPES}) //18 
						lRet := .T.
					EndIf
				EndIf
				GXS->(dbSkip())
			EndDo
		EndIf
	EndIf

	//chama função AGRO passando filial e contrato (AGRX550E.prw)
	If cMVAGRORI .And. cMVSIGAAGR .And. FindFunction("GFEAGR001")
		lRetAGR001 := GFEAGR001(GXS->GXS_FILCT, GXS->GXS_NRCT, .F.)
		If !lRetAGR001
			Return .F.
		EndIf
	EndIf   
	
	If lRet == .T.
		For nX := 1 To Len(aCotacoes)
			//If !Empty(aCotacoes[nX][1])
			//	Loop
		//	EndIf
			nTotal++
			lGerar := .T.
			
			//CONTRATO
			oGerarContrato:setFilCt(xFilial("GXT"))
			oGerarContrato:setNrCt(aCotacoes[nX,1])
			oGerarContrato:setDtCt(aCotacoes[nX,2])
			oGerarContrato:setUsuar(aCotacoes[nX,3])
			oGerarContrato:setCdTrp(aCotacoes[nX,4])
			oGerarContrato:setCdClfr(aCotacoes[nX,5])
			oGerarContrato:setCdTpop(aCotacoes[nX,6])
			oGerarContrato:setDtIRet(aCotacoes[nX,9])
			oGerarContrato:setDtFent(aCotacoes[nX,10])
			oGerarContrato:setDtFret(aCotacoes[nX,11])
			oGerarContrato:setNrTab(aCotacoes[nX,12])
			oGerarContrato:setNrNeg(aCotacoes[nX,13])
			oGerarContrato:setObsCga(aCotacoes[nX,19])
			oGerarContrato:setObsDga(aCotacoes[nX,20])
			
			//ROTAS
			oGerarContrato:setPesot(aCotacoes[nX,7])
			oGerarContrato:setQtDet(aCotacoes[nX,8])
			oGerarContrato:setSeq(aCotacoes[nX,14])
			oGerarContrato:setNrCido(aCotacoes[nX,15])
			oGerarContrato:setNrCidd(aCotacoes[nX,16])
			oGerarContrato:setUnimed(aCotacoes[nX,17])
			oGerarContrato:setVlUni(aCotacoes[nX,18])
			oGerarContrato:setUniQtd(aCotacoes[nX,21])
			oGerarContrato:setFrtQtd(aCotacoes[nX,22])
			oGerarContrato:setImpinc('1') // Valor padrão do campo
			
			//Método para geração do Contrato
			oGerarContrato:GravarContrato()
			
			aCotacoes[nX,1] := oGerarContrato:getNrCt()
			
			If aDtFret[1] == .T.
				If oGerarContrato:getStatus()
					//Atualiza número de contrato na tabela de Resultados
					GXS->(dbSetOrder(1))
					If GXS->(dbSeek(xFilial("GXS") + cIdReq + aCotacoes[nX,14]))
						RecLock("GXS", .F.)
							GXS->GXS_FILCT	:= oGerarContrato:getFilCt()
							GXS->GXS_NRCT	:= aCotacoes[nX,1]
						GXS->(MsUnlock())
					EndIf
				EndIf
			Else
				oGerarContrato:setStatus(.F.)
				oGerarContrato:setErroMensagem("Não foi possível gerar a Data Final de Retirada do Contrato de Transporte." +; 
											" Acesse o cadastro de Calendário de Transporte e gere para o ano informado no campo Data Término.")
				oGerarContrato:setMensagem("Contrato " + AllTrim(oGerarContrato:getNrCt()) + " ")												
			EndIf
			
			cMsg 		:= oGerarContrato:getMensagem()
			cErroMsg	:= oGerarContrato:getErroMensagem()
			
			If oGerarContrato:getStatus()
				GFELog:Add(Replicate('-',50))
				GFELog:Add(Space(4) + cMsg + ":")
				GFELog:Add(Space(7) + "Gerado com sucesso")
				GFELog:Add("")
				nSucesso++
				ConfirmSX8()
			Else
				GFELog:AddErro(Replicate('-',50))
				GFELog:AddErro(Space(4) + cMsg + ":")
				GFELog:AddErro(Space(7)+"Motivo: " + cErroMsg)
				GFELog:AddErro("")
				nErro++
				RollBackSxe()
			EndIf
			
			oGerarContrato:ClearData()
		Next nX
	EndIf

	//chama função AGRO passando filial e contrato (AGRX550E.prw)
	If lRetAGR001 .And. !Empty(GXS->GXS_NRTAB) .And. !Empty(GXS->GXS_NRNEG) .And. cMVAGRORI .And. cMVSIGAAGR .And. FindFunction("GFEAGR001")
		lRetAGR001 := GFEAGR001(GXS->GXS_FILCT, GXS->GXS_NRCT, .T.)
		If !lRetAGR001
			Return .F.
		EndIf
	EndIf   
	
	GFELog:Add(Replicate('-',50))
	GFELog:Add("")
	GFELog:Add("Total de contratos processados :" + cValToChar(nTotal))
	GFELog:Add("Total de contratos Gerados : "  + cValToChar(nSucesso))
	GFELog:Add("Total de contratos com erros : "  + cValToChar(nErro))
	GFELog:Show("Geração de Contratos", "Contratos Gerados", "Erros", "Um ou mais Contratos não foram gerados, clique no botão 'Erros' para mais detalhes.")	
	
	// Destroy o objeto criado para os métodos de Gerar Contrato
	oGerarContrato:Destroy(oGerarContrato)
Return lRet

Function GerarDtFret(cDtTer,cPrazo,cTpPraz)
	Local aData := {.T.,""}
	
	If cTpPraz == '0'
		cPrazo := GFEPrzCorr(cPrazo,cDtTer, .F.) 
		If cPrazo == Nil
			aData[1] := .F.
		EndIf
	Elseif cTpPraz == '2'
		cPrazo := NOROUND(cPrazo/24, 0)
 	EndIf
 	
 	If aData[1] == .T.
 		aData[2] := cDtTer - cPrazo
 	EndIf
Return aData

Function GFEA79MAIL()
	Local oPainelRequisicao
	
	If GXR->GXR_SIT != '4'
		GFEHelp("Somente Requisições atendidas podem ser executadas o reenvio de email.","Execute o re-envio de email para uma requisição Atendida.","Envio de Email da Requisição")
		Return .F.
	EndIf
	
	If GXR->GXR_AVISO == '2'
		If !MSGYESNO("Já consta com 'Enviado com Sucesso' o aviso de email, deseja enviar novamente o email?")
			Return .F.
		EndIf
	EndIf
	
	If Empty(GXR->GXR_EMAIL) .and. Empty(GXR->GXR_CC)
		GFEHelp("Os campos e-mail (GXR_EMAIL) e e-mail cópia (GXR_CC) não estão preenchidos.","Informe um email válido para executar o envio de e-mail.","Envio de Email da Requisição")
		Return .F.
	EndIf

	CursorWait()
	
	oPainelRequisicao := GFEPainelRequisicao():New()
	
	// "Seta" os dados necessários para execução do método de Concluir Requisição
	oPainelRequisicao:setIdReq(GXR->GXR_IDREQ)
	
	If GFXCP12123("GXR_REQACT") .And. GXR->GXR_REQACT == "2"
		oPainelRequisicao:SetReqAct('2')
	EndIf
	
	oPainelRequisicao:SendMailConclusion()
	if oPainelRequisicao:getStatus() == .F.
		GFEHelp(oPainelRequisicao:getMensagem(),"Verifique a mensagem de ocorrência, realize o ajuste e envie novamente.","Envio de Email da Requisição")
		oPainelRequisicao:Destroy(oPainelRequisicao)
	Else
		oPainelRequisicao:setAviso('2') // 2=Enviado com Sucesso
		oPainelRequisicao:AlterarAviso()
		oPainelRequisicao:Destroy(oPainelRequisicao)
	EndIf
	
	CursorArrow()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE078BuscaReferencia
Função responsável por efetivar os contratos de forma automática

@author Leonardo Ribas Jimenez Hernandez
@since 17/08/2018
@version 1.0

@param cIdReq - Id da Requisição de Negociação de Frete
/*/
//-------------------------------------------------------------------
Function GFE078BuscaReferencia(oView)

	Local oCriaCotacao := GFECriaCotacao():New()
	Local aRequisicoes[14]
	Local aGXS := {}
	Local dDtIni
	Local cHoraRef := ''
	Local cTpTab := ''

	oModel := FwModelActive()

	CursorWait()
	oCriaCotacao:BuscaCotacao(oModel)
	If oCriaCotacao:getStatus() == .F.
		GFEHelp("Para buscar novas referências, necessário deletar as existentes.",,"Cotações de Frete")
		oCriaCotacao:Destroy(oCriaCotacao)
		Return .F.
	EndIf	
	
	aRequisicoes[1]	:= oModel:getValue("GFEA078_GXR", "GXR_CDREM","1")
	aRequisicoes[2]	:= oModel:getValue("GFEA078_GXR", "GXR_CDDEST","1")
	aRequisicoes[3]	:= oModel:getValue("GFEA078_GXR", "GXR_NRCIDO","1")
	aRequisicoes[4]	:= oModel:getValue("GFEA078_GXR", "GXR_NRCIDD","1")
	aRequisicoes[5]	:= ""
	aRequisicoes[6]	:= ""
	aRequisicoes[7]	:= oModel:getValue("GFEA078_GXR", "GXR_CDTPOP","1")
	aRequisicoes[8]	:= ""
	aRequisicoes[9]	:= ""
	aRequisicoes[10] := oModel:getValue("GFEA078_GXR", "GXR_CDCLFR","1")

	dDtIni := oModel:getValue("GFEA078_GXR", "GXR_DTINI","1")
	cTpTab := '4' 

	//Retorna os Fretes Referência
	aGXS := GFETabPrzQbr(aRequisicoes, dDtIni, cHoraRef, cTpTab, "1")
		
	If aGXS[5] == .F.
		GFEHelp(aGXS[6],,"Cotações de Frete")
		Return .F.
	EndIf

	oCriaCotacao:setOriCot('2')		

	oCriaCotacao:ConCriaCot(aGXS[7],oModel)
	If oCriaCotacao:getStatus() == .F.
		GFEHelp(oCriaCotacao:getMensagem(),,"Não é possível gerar Cotações de Frete!")
		oCriaCotacao:Destroy(oCriaCotacao)
		Return .F.
	EndIf
	
	oCriaCotacao:Destroy(oCriaCotacao)

	CursorArrow()

Return .T.

Function GFEA78COT(cFilReq, cNrReq)
	Local aAux 	  	:= {} 	
	Local aEmailTMP	:= {}
	Local lReenvia	:= .F.
	Local cQuery	:= ""
	Local cAliasQry := GetNextAlias()
	 
	Default cFilReq	:= ""
	Default cNrReq	:= ""

	cQuery := "SELECT * FROM " + RetSqlName('GXS') + " GXS"
	cQuery += " INNER JOIN " + RetSqlName("GXR") + " GXR"
	cQuery += " ON GXS.GXS_FILIAL = GXR.GXR_FILIAL "
	cQuery += " AND GXS.GXS_IDREQ = GXR.GXR_IDREQ " 
    cQuery += " WHERE GXS.GXS_FILIAL = '" + cFilReq + "'"
	cQuery += " AND GXS.GXS_IDREQ = '" + cNrReq + "'"
	cQuery += " AND GXS.GXS_STATUS <> '0'"
	cQuery += " AND GXS.D_E_L_E_T_ = ''"
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	If (cAliasQry)->(!Eof())
		lReenvia := MsgYesNo("Existem cotações já enviadas. Deseja reenviar todas as cotações já enviadas?")
	EndIf

	cAliasQry := GFEA078ABD(cFilReq, cNrReq, lReenvia)
	
	If (cAliasQry)->(Eof()) 
		ApMsgAlert("Não foram encontradas cotações para enviar","Painel Negociação")
		Return .F.
	EndIf
  
	//Preenche o array	
	While (cAliasQry)->(!Eof()) 
		If Empty((cAliasQry)->GXS_EMCONT)
			MsgAlert("E-mail para envio do WorkFlow não está preenchido. O envio não será realizado.")
			Return .F.
		EndIf
		
		aAux := {}
		
		aAdd(aAux, (cAliasQry)->GXS_IDREQ)
		aAdd(aAux, (cAliasQry)->GXS_SEQ)
		aAdd(aAux, (cAliasQry)->GXS_EMCONT)
		
		aAdd(aAux, POSICIONE("GUB", 1, XFILIAL("GUB") + (cAliasQry)->GXR_CDCLFR, "GUB_DSCLFR"))               
		aAdd(aAux, POSICIONE("GV4", 1, XFILIAL("GV4") + (cAliasQry)->GXR_CDTPOP, "GV4_DSTPOP"))              
		aAdd(aAux, "") //POSICIONE("GV3", 1, XFILIAL("GV3") + (cAliasQry)->GXR_CDTPVC, "GV3_DSTPVC"))               
		
		aAdd(aAux, POSICIONE("GU3", 1, XFILIAL("GU3") + (cAliasQry)->GXR_CDREM, "GU3_NMEMIT"))
		aAdd(aAux, POSICIONE("GU7", 1, XFILIAL("GU7") + (cAliasQry)->GXR_NRCIDO, "GU7_NMCID"))
		aAdd(aAux, POSICIONE("GU7", 1, XFILIAL("GU7") + (cAliasQry)->GXR_NRCIDO, "GU7_CDUF"))
		
		aAdd(aAux, POSICIONE("GU3", 1, XFILIAL("GU3") + (cAliasQry)->GXR_CDDEST, "GU3_NMEMIT"))
		aAdd(aAux, POSICIONE("GU7", 1, XFILIAL("GU7") + (cAliasQry)->GXR_NRCIDD, "GU7_NMCID"))
		aAdd(aAux, POSICIONE("GU7", 1, XFILIAL("GU7") + (cAliasQry)->GXR_NRCIDD, "GU7_CDUF"))
		
		aAdd( aAux,   StrZero(Day(StoD((cAliasQry)->GXR_DTINI)),2) + "/" + StrZero(Month(StoD((cAliasQry)->GXR_DTINI)),2) + "/" + Str(Year(StoD((cAliasQry)->GXR_DTINI)),4))             
		aAdd( aAux,   StrZero(Day(StoD((cAliasQry)->GXR_DTTER)),2) + "/" + StrZero(Month(StoD((cAliasQry)->GXR_DTTER)),2) + "/" + Str(Year(StoD((cAliasQry)->GXR_DTTER)),4))
		aAdd( aAux,   StrZero(Day(StoD((cAliasQry)->GXR_DTLIM)),2) + "/" + StrZero(Month(StoD((cAliasQry)->GXR_DTLIM)),2) + "/" + Str(Year(StoD((cAliasQry)->GXR_DTLIM)),4))
		
		aAdd(aAux, (cAliasQry)->GXR_UMPESO)
		aAdd(aAux, (cAliasQry)->GXS_PESOT)
		aAdd(aAux, (cAliasQry)->GXR_PESOT)
		aAdd(aAux, POSICIONE("GU3", 1, XFILIAL("GU3") + (cAliasQry)->GXS_CDTRP, "GU3_NMEMIT"))		
		aAdd(aAux, (cAliasQry)->GXR_INFOAD)
		
		aAdd( aEmailTMP, aAux )
		
		GXS->(DbSetOrder(1))
		If GXS->(DbSeek((cAliasQry)->GXS_FILIAL+(cAliasQry)->GXS_IDREQ+(cAliasQry)->GXS_SEQ))		
			Reclock("GXS",.F.)
				GXS->GXS_STATUS := "3"
			GXS->(MsUnlock())	
		EndIf
		
		(cAliasQry)->(DbSkip())
	EndDo
  
	(cAliasQry)->(dbCloseArea())
  
	//manda e-mail sobre as cotações
	If GFEA078MAIL(aEmailTMP)
		MsgAlert("Os registros de cotação foram enviados para solicitação via WorkFlow!")		
	Else
		MsgAlert("Ocorreu algum erro no processamento do WorkFlow para o envio das cotações!")
		Return .F.
	EndIf
Return .T.

Function GFEA078ABD(cFilReq, cNrReq, lReenvia)
	Local cQuery 	  := ""
	Local cAliasQry   := GetNextAlias()
	
	Default lReenvia := .F.
	
	cQuery += "SELECT GXR.GXR_FILIAL "
	cQuery += ",GXR.GXR_IDREQ "
	cQuery += ",GXR.GXR_CODUSU "
	cQuery += ",GXR.GXR_EMAIL "
	cQuery += ",GXR.GXR_FONE "
	cQuery += ",GXR.GXR_DEPTO "
	cQuery += ",GXR.GXR_USUPER "
	cQuery += ",GXR.GXR_NOMSUP "
	cQuery += ",GXR.GXR_CC "
	cQuery += ",GXR.GXR_FDADE "
	cQuery += ",GXR.GXR_IDENT "
	cQuery += ",GXR.GXR_TPIDEN "
	cQuery += ",GXR.GXR_CDREM "
	cQuery += ",GXR.GXR_NRCIDO "
	cQuery += ",GXR.GXR_UFO "
	cQuery += ",GXR.GXR_CDDEST "
	cQuery += ",GXR.GXR_NRCIDD "
	cQuery += ",GXR.GXR_UFD "
	cQuery += ",GXR.GXR_CDTPOP "
	cQuery += ",GXR.GXR_CDCLFR "
	cQuery += ",GXR.GXR_PESOT "
	cQuery += ",GXR.GXR_UMPESO "
	cQuery += ",GXR.GXR_QTDET "
	cQuery += ",GXR.GXR_VALORT "
	/*cQuery += ",GXR.GXR_INFOAD "*/
	cQuery += ",GXR.GXR_DTINI "
	cQuery += ",GXR.GXR_DTTER "
	cQuery += ",GXR.GXR_DTLIM "
	cQuery += ",GXR.GXR_MOTLIM "
	cQuery += ",GXR.GXR_OBSREQ "
	cQuery += ",GXR.GXR_DTREQ "
	cQuery += ",GXR.GXR_HRREQ "
	cQuery += ",GXR.GXR_SIT "
	cQuery += ",GXR.GXR_USUNEG "
	cQuery += ",GXR.GXR_AVISO "
	cQuery += ",GXR.GXR_SITRES "
	cQuery += ",GXR.GXR_MOTREJ "
	cQuery += ",GXR.GXR_MOTCAN "
	cQuery += ",GXR.D_E_L_E_T_ "
	cQuery += ",GXR.R_E_C_N_O_ "
	cQuery += ",GXR.R_E_C_D_E_L_ "
	cQuery += ",GXR.GXR_CSTRES "
	cQuery += ",GXR.GXR_REQBAS "
	cQuery += ",GXR.GXR_GERCON "
	cQuery += ",GXR.GXR_OBSCGA "
	cQuery += ",GXR.GXR_OBSDGA "
	cQuery += ",GXR.GXR_UNIMED "
	cQuery += ",GXS.GXS_FILIAL "
	cQuery += ",GXS.GXS_IDREQ "
	cQuery += ",GXS.GXS_SEQ "
	cQuery += ",GXS.GXS_MRKBR "
	cQuery += ",GXS.GXS_JUSTIF "
	cQuery += ",GXS.GXS_CDTRP "
	cQuery += ",GXS.GXS_FILCT "
	cQuery += ",GXS.GXS_NRCT "
	cQuery += ",GXS.GXS_FILTAB "
	cQuery += ",GXS.GXS_NRTAB "
	cQuery += ",GXS.GXS_NRNEG "
	cQuery += ",GXS.GXS_FILREF "
	cQuery += ",GXS.GXS_CODREF "
	cQuery += ",GXS.GXS_PESOT "
	cQuery += ",GXS.GXS_QTDET "
	cQuery += ",GXS.GXS_TOTFRT "
	cQuery += ",GXS.GXS_FRTPES "
	cQuery += ",GXS.GXS_PRAZO "
	cQuery += ",GXS.D_E_L_E_T_ "
	cQuery += ",GXS.R_E_C_N_O_ "
	cQuery += ",GXS.R_E_C_D_E_L_ "
	cQuery += ",GXS.GXS_TPPRAZ "
	cQuery += ",GXS.GXS_FRTCOT "
	cQuery += ",GXS.GXS_ORICOT "
	cQuery += ",GXS.GXS_NMCONT "
	cQuery += ",GXS.GXS_EMCONT "
	cQuery += ",GXS.GXS_FOCONT "
	cQuery += ",GXS.GXS_JUSCOT "
	cQuery += ",GXS.GXS_FRTQTD "
	cQuery += ",GXS.GXS_STATUS "
	cQuery += ",GXS.GXS_DTATU "
	cQuery += ",GXS.GXS_HRATU "
	
	If TcGetDB() == 'ORACLE'
	  	cQuery += ",UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(GXR.GXR_INFOAD, 3200,1)) 			AS GXR_INFOAD "
	Else 
		cQuery += ",ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),GXR.GXR_INFOAD)),'') 	AS GXR_INFOAD  "
	EndIf
	
	cQuery += "  FROM " + RetSqlName('GXS') + " GXS"
	cQuery += " INNER JOIN " + RetSqlName("GXR") + " GXR"
	cQuery += "    ON GXS.GXS_FILIAL = GXR.GXR_FILIAL "
	cQuery += "   AND GXS.GXS_IDREQ  = GXR.GXR_IDREQ " 
    cQuery += " WHERE GXS.GXS_FILIAL = '" + cFilReq + "'"
	cQuery += "   AND GXS.GXS_IDREQ  = '" + cNrReq + "'"
	If !lReenvia
		cQuery += " AND GXS.GXS_STATUS = '0'"
	EndIf
	cQuery += " AND GXS.D_E_L_E_T_ = ''"
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
Return cAliasQry

Function GFEA078MAIL(aEmailTMP)
	Local cRemetnt		:= AllTrim( SuperGetMV("MV_RELACNT",.F.,"") )
	Local aAnexos   	:=  {} 
	Local nX			:= 1
	Local aAux          := {}
	Local cTemplate     := SUPERGETMV( "MV_GFEWF02", .T., "" )
	Local cProsse       := POSICIONE("N7L",1,XFILIAL("N7L")+cTemplate,"N7L_PROCES")
	
	If Empty(cTemplate)
		ApMsgAlert("Preencher o parametro MV_GFEWF02","Painel Negociação")
		Return .F.
	EndIf
	
	//Percorre todo o array com os e-mail
	While Len(aEmailTMP) >= nX
	
		If nx == 1 .OR. aEmailTMP[nX - 1][2] <> aEmailTMP[nX][2]
			aAux := {}
		EndIf
		
		AADD(aAux, aEmailTMP[nX])
	
		If Len(aEmailTMP) == nX .OR. aEmailTMP[nX][2] <> aEmailTMP[nX+1][2]
			//Cria o template para o workflow
			CriaTemplate(aAux)
			
			//Envia e-mail - Utiliza função do Agro
			OGX017(aEmailTMP[nX][3] ,	;   //E-mails dos destinatários
				   "",		;					//Corpo do e-mail
				   "",		;					//Alias do browse que chamou a tela envio de email
				   "GXS_IDREQ = '" + aEmailTMP[nX][1] + "' AND GXS_SEQ = '" + aEmailTMP[nX][2] + "'",; //Chave utilizada como filtro do registro pai
				   cProsse,	;					//Processo utilizado para filtro de template
				   {},		;					//Array de indices para a tabela temporaria
				   0,		;					//Numero da ordem dos indices a ser utilizada
				   aAnexos,	;					//Array de anexos para o e-mail
				   cRemetnt,;					//Remetente
				   cTemplate,;					//Codigo do Workflow
				   .T.,		;					//Executa automaticamente ?
				   .T.,		;					//Possui WF ?
				   {"GFEA078", "GXS", 	"GXS_IDREQ = '" + aEmailTMP[nX][1] + "' AND GXS_SEQ = '" + aEmailTMP[nX][2] + "'" , "GFEA078WFRT()", {GXS->GXS_IDREQ, GXS->GXS_SEQ}})  //Array do WF
			
		EndIf
		
		nX++						
	EndDo	
  
return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTemplate
Cria template para enviar o e-mail de cotação

@author João Leonardo Schmidt
@since 30/01/2019
@version 1.0

@param aEmailTMP - Array com chave da Requisição e Email
/*/
//------------------------------------------------------------------- 
Static Function CriaTemplate(aEmailTMP)
	Local nX
	Local nHandle 
	Local cHtml := ''
	
	nHandle := FCreate("\workflow\templates\cotacao.html")
	
	cHtml += RetornaHtml('Head') + RetornaHtml('BodyIni') 
	cHtml := StrTran( cHtml , "%GXS_CDTRP%", aEmailTMP[1][19]  )
	cHtml := StrTran( cHtml , "%GXR_DTLIM%", aEmailTMP[1][15]  )

	For nX := 1 To Len(aEmailTMP)
	
			cHtml +=  RetornaHtml('BodyMid') 
			
			cHtml := StrTran( cHtml , "%CHAVE%"			, xFilial("GXS")+aEmailTMP[nX][1]+aEmailTMP[nX][2])
			cHtml := StrTran( cHtml , "%GXR_NRCIOR%"	, aEmailTMP[nX][8] + "/" + aEmailTMP[nX][9])
			cHtml := StrTran( cHtml , "%GXR_NRCIDS%"	, aEmailTMP[nX][11] + "/" + aEmailTMP[nX][12])
			cHtml := StrTran( cHtml , "%GXR_CDCLFR%"	, aEmailTMP[nX][4])
			cHtml := StrTran( cHtml , "%GXR_CDTPOP%"	, aEmailTMP[nX][5])
			cHtml := StrTran( cHtml , "%GXR_DTINI%" 	, aEmailTMP[nX][13])
			cHtml := StrTran( cHtml , "%GXR_DTTER%" 	, aEmailTMP[nX][14])
			cHtml := StrTran( cHtml , "%GXS_PESOT%"  	, If(!Empty(aEmailTMP[nX][17]),cValToChar(aEmailTMP[nX][17]),cValToChar(aEmailTMP[nX][18])))
			cHtml := StrTran( cHtml , "%GXR_UMPESO%" 	, aEmailTMP[nX][16])
			If !Empty(aEmailTMP[nX][20])
				cHtml := StrTran( cHtml , "%GXR_INFOAD%"	, aEmailTMP[nX][20])
			Else
				cHtml := StrTran( cHtml , "%GXR_INFOAD%"	, "Sem informações adicionais.")
			EndIf
	Next nX 
	
	cHtml += RetornaHtml('BodyFim') 
	FWrite(nHandle, cHtml  ) 
	
	FClose(nHandle) 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetornaHtml
Retorna trechos do Html para construção 

@author João Leonardo Schmidt
@since 30/01/2019
@version 1.0

@param cParam - parametro referente ao retorno do html
/*/
//------------------------------------------------------------------- 
Static Function RetornaHtml(cParam)
	Local cRetorno := ''
	
	If cParam == "Head"
		cRetorno += "<!DOCTYPE html>																									" + _CRLF
		cRetorno += "<html>                                                                                                             " + _CRLF
		cRetorno += '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css">               ' + _CRLF
		cRetorno += '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap-theme.min.css">         ' + _CRLF
		cRetorno += "<head>                                                                                                             " + _CRLF
		cRetorno += '<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js" type="text/javascript"></script>    ' + _CRLF
		cRetorno += '<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-maskmoney/3.0.2/jquery.maskMoney.min.js"                type="text/javascript"></script>' + _CRLF
		cRetorno += '<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>                        ' + _CRLF
		cRetorno += "<title>Solicita&ccedil;&atilde;o Cota&ccedil;&atilde;o de Frete</title>                                               " + _CRLF
		cRetorno += '    <script type="text/javascript">                                                                                ' + _CRLF
		cRetorno += "		$(document).ready(function (){                                                                              " + _CRLF
		cRetorno += '			  $(".valFretePreso").maskMoney({                                                                       ' + _CRLF
		cRetorno += "				allowNegative: false,                                                                               " + _CRLF
		cRetorno += "				decimal: '.',                                                                                       " + _CRLF
		cRetorno += "				affixesStay: false                                                                                  " + _CRLF
		cRetorno += "			  });                                                                                                   " + _CRLF
		cRetorno += '			  $(".valAliqImposto").maskMoney({                                                                      ' + _CRLF
		cRetorno += "				allowNegative: false,                                                                               " + _CRLF
		cRetorno += "				decimal: '.',                                                                                       " + _CRLF
		cRetorno += "				numeralMaxLength: true,                                                                             " + _CRLF
		cRetorno += "				affixesStay: false                                                                                  " + _CRLF
		cRetorno += "			  });		                                                                                            " + _CRLF		
		cRetorno += "		});                                                                                                         " + _CRLF
	
		cRetorno += "  function Enviar(pBotao)																							" + _CRLF	
		cRetorno += " 		{																											" + _CRLF
		cRetorno += " 	  //wfForm.cObs.value = wfForm.textarea.value																	" + _CRLF
		cRetorno += " 		  wfForm.cBtRetorno.value= pBotao																			" + _CRLF
		cRetorno += " 		var primeiro = true;																						" + _CRLF
		cRetorno += ' 		var resultado = "";																							' + _CRLF
		cRetorno += ' 	  $(".linha").each(function(){																					' + _CRLF
		cRetorno += " 	    var chave =  $('#chave').val();												" + _CRLF
		cRetorno += " 		var fretePreso =  $('#fretePreso').val();									" + _CRLF
		cRetorno += " 		var incImposto =  $('#incImposto').val();									" + _CRLF
		cRetorno += " 		console.log(chave);																							" + _CRLF	
		cRetorno += " 		console.log(fretePreso);																					" + _CRLF
		cRetorno += " 		console.log(incImposto);                                                                                   " + _CRLF
		cRetorno += " 	if (primeiro){																									" + _CRLF
		cRetorno += ' 			resultado = chave+";"+fretePreso+";"+incImposto;														' + _CRLF	
		cRetorno += ' 			primeiro = false;																						' + _CRLF	
		cRetorno += ' 		}																											' + _CRLF
		cRetorno += ' 		else																										' + _CRLF	
		cRetorno += ' 			resultado+= "|"+chave+";"+fretePreso+";"+incImposto;													' + _CRLF			
		cRetorno += " 	  });																											" + _CRLF
		cRetorno += ' 	  $("#resultado").val(resultado);																				' + _CRLF
		cRetorno += ' 	  wfForm.resultado.value=resultado;	 																			' + _CRLF
		cRetorno += " 	  console.log(wfForm.resultado.value);																			" + _CRLF	
		cRetorno += " 	  return true																									" + _CRLF
		cRetorno += " 	}																												" + _CRLF
	
		cRetorno += "    </script>                                                                                                      " + _CRLF
		cRetorno += '  <style type="text/css">                                                                                          ' + _CRLF
		cRetorno += "    body { padding-top: 10px;                                                                                      " + _CRLF
		cRetorno += "			background-color: #fbfbfb;                                                                              " + _CRLF
		cRetorno += "		}                                                                                                           " + _CRLF
		cRetorno += "	.ctn{                                                                                                           " + _CRLF
		cRetorno += "		background-color: #FFFFFF;                                                                                  " + _CRLF
		cRetorno += "		border-radius: .25rem;                                                                                      " + _CRLF
		cRetorno += "		 box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.15);                                                               " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "	.bg {		                                                                                                    " + _CRLF
		cRetorno += "		background-color: #0c9abe;                                                                                  " + _CRLF
		cRetorno += "		 border-radius: .25rem;                                                                                     " + _CRLF
		cRetorno += "		 box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.15);                                                               " + _CRLF
		cRetorno += "		 font-family: inherit;                                                                                      " + _CRLF
		cRetorno += "		  font-size: 16px;                                                                                          " + _CRLF
		cRetorno += "		  font-style: normal;                                                                                       " + _CRLF
		cRetorno += "		  font-stretch: normal;                                                                                     " + _CRLF
		cRetorno += "		  line-height: 1.5;                                                                                         " + _CRLF
		cRetorno += "		  letter-spacing: normal;                                                                                   " + _CRLF
		cRetorno += "		  text-align: left;                                                                                         " + _CRLF
		cRetorno += "		  color: #ffffff;                                                                                           " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "	                                                                                                                " + _CRLF
		cRetorno += "	.bg2{                                                                                                           " + _CRLF
		cRetorno += "		background-color: #FFFFFF;                                                                                  " + _CRLF
		cRetorno += "		border-radius: .25rem;                                                                                      " + _CRLF
		cRetorno += "		border: solid 1px #0c9abe;                                                                                  " + _CRLF
		cRetorno += "		font-family: inherit;                                                                                       " + _CRLF
		cRetorno += "		font-size: 16px;                                                                                            " + _CRLF
		cRetorno += "		font-style: normal;                                                                                         " + _CRLF
		cRetorno += "		font-stretch: normal;                                                                                       " + _CRLF
		cRetorno += "		line-height: 1.5;                                                                                           " + _CRLF
		cRetorno += "		letter-spacing: normal;                                                                                     " + _CRLF
		cRetorno += "		text-align: center;                                                                                         " + _CRLF
		cRetorno += "		color: #0c9abe;                                                                                             " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "	.Background-da-pgina {                                                                                          " + _CRLF
		cRetorno += "	  width: 352px;                                                                                                 " + _CRLF
		cRetorno += "	  height: 24px;                                                                                                 " + _CRLF
		cRetorno += "	  @apply --text;                                                                                                " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "	.fontBold {                                                                                                     " + _CRLF
		cRetorno += "	  width: 385px;                                                                                                 " + _CRLF
		cRetorno += "	  height: 66px;                                                                                                 " + _CRLF
		cRetorno += "	  font-family: inherit;                                                                                         " + _CRLF
		cRetorno += "	  font-size: 16px;                                                                                              " + _CRLF
		cRetorno += "	  font-weight: bold;                                                                                            " + _CRLF
		cRetorno += "	  font-style: normal;                                                                                           " + _CRLF
		cRetorno += "	  font-stretch: normal;                                                                                         " + _CRLF
		cRetorno += "	  line-height: normal;                                                                                          " + _CRLF
		cRetorno += "	  letter-spacing: normal;                                                                                       " + _CRLF
		cRetorno += "	  text-align: left;                                                                                             " + _CRLF
		cRetorno += "	  color: #4a5c60;	                                                                                            " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "	.fontBoldCab {                                                                                                  " + _CRLF
		cRetorno += "	  width: 385px;                                                                                                 " + _CRLF
		cRetorno += "	  height: 66px;                                                                                                 " + _CRLF
		cRetorno += "	  font-family: inherit;                                                                                         " + _CRLF
		cRetorno += "	  font-size: 30px;                                                                                              " + _CRLF
		cRetorno += "	  font-weight: bold;                                                                                            " + _CRLF
		cRetorno += "	  font-style: normal;                                                                                           " + _CRLF
		cRetorno += "	  font-stretch: normal;                                                                                         " + _CRLF
		cRetorno += "	  line-height: normal;                                                                                          " + _CRLF
		cRetorno += "	  letter-spacing: normal;                                                                                       " + _CRLF
		cRetorno += "	  text-align: left;                                                                                             " + _CRLF
		cRetorno += "	  color: #4a5c60;	                                                                                            " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "	.fontBody {                                                                                                     " + _CRLF
		cRetorno += "	  width: 478px;                                                                                                 " + _CRLF
		cRetorno += "	  height: 66px;                                                                                                 " + _CRLF
		cRetorno += "	  font-family: inherit;                                                                                         " + _CRLF
		cRetorno += "	  font-size: 16px;                                                                                              " + _CRLF
		cRetorno += "	  font-weight: 200;                                                                                             " + _CRLF
		cRetorno += "	  font-style: normal;                                                                                           " + _CRLF
		cRetorno += "	  font-stretch: normal;                                                                                         " + _CRLF
		cRetorno += "	  line-height: normal;                                                                                          " + _CRLF
		cRetorno += "	  letter-spacing: normal;                                                                                       " + _CRLF
		cRetorno += "	  text-align: left;                                                                                             " + _CRLF
		cRetorno += "	  color: #4a5c60;	                                                                                            " + _CRLF
		cRetorno += "	}                                                                                                               " + _CRLF
		cRetorno += "  </style>                                                                                                         " + _CRLF
		cRetorno += "</head>                                                                                                            " + _CRLF
	ElseIf cParam == "BodyIni"
		cRetorno += " <body>																											" + _CRLF
		cRetorno += " <br>                                                                                           					" + _CRLF
		cRetorno += ' <form action="mailto:%WFMailTo%" method="post" role="form"  class="form-inline" name="wfForm"> 					' + _CRLF
		cRetorno += '   <input type="hidden" name="cBtRetorno" id="cBtRetorno" value="%cBtRetorno%" />               					' + _CRLF
		cRetorno += '   <input type="hidden" name="resultado" id="resultado" value="%resultado%" />             						' + _CRLF
		cRetorno += '   <div class="container ctn">                                                                  					' + _CRLF
		cRetorno += '   <div class="well">	                                                                        					' + _CRLF
		cRetorno += " 	  <div>                                                                                     					" + _CRLF
		cRetorno += '       <font class="fontBoldCab" >Cota&ccedil;&atilde;o de Frete</font>                                       					' + _CRLF
		cRetorno += " 	  <p>&nbsp;</p>	                                                                            					" + _CRLF
		cRetorno += ' 	  <font class="fontBody">Prezado %GXS_CDTRP%,<br>	                                                    					' + _CRLF
		cRetorno += "       Solicitamos o preenchimento da cota&ccedil;&atilde;o de frete conforme dados a seguir. Consideraremos as respostas enviadas até o dia %GXR_DTLIM%. </font> " + _CRLF
		cRetorno += " 	  <p>&nbsp;</p>                                                                             					" + _CRLF
		cRetorno += "       <div>                                                                                    					" + _CRLF
		cRetorno += ' 	  <table width="100%" id="tbFretes" name="tbFretes">                                        					' + _CRLF
		cRetorno += " 		<thead>                                                                                 					" + _CRLF
		cRetorno += " 			<th>Origem</th>                                                                     					" + _CRLF
		cRetorno += " 			<th>Destino</th>                                                                    					" + _CRLF
		cRetorno += " 			<th>Classifica&ccedil;&atilde;o Frete</th>                                                        					" + _CRLF
		cRetorno += " 			<th>Tipo de Opera&ccedil;&atilde;o</th>                                                           					" + _CRLF
		cRetorno += " 			<th>Vig&ecirc;ncia(Início)</th>                                                                   					" + _CRLF
		cRetorno += " 			<th>Vig&ecirc;ncia(Fim)</th>                                                                   					" + _CRLF
		cRetorno += " 			<th>Peso Total (%GXR_UMPESO%)</th>                                                                   					" + _CRLF
		cRetorno += " 			<th>Frete Peso(R$ / %GXR_UMPESO%)</th>                                                                 					" + _CRLF
		cRetorno += " 			<th>Imposto?</th>                                                           						" + _CRLF
		cRetorno += " 		</thead>                                                                                					" + _CRLF
		cRetorno += " 		<tbody>                                                                                 					" + _CRLF
	ElseIf cParam == "BodyMid"
		cRetorno += '			<tr class="linha">																						' + _CRLF
		cRetorno += '				<td>%GXR_NRCIOR%</td>       																		' + _CRLF
		cRetorno += '				<td>%GXR_NRCIDS%</td>																				' + _CRLF
		cRetorno += '				<td>%GXR_CDCLFR%</td>																				' + _CRLF
		cRetorno += '				<td>%GXR_CDTPOP%</td>																				' + _CRLF
		cRetorno += '				<td>%GXR_DTINI%</td>       																		' + _CRLF
		cRetorno += '				<td>%GXR_DTTER%</td>       																		' + _CRLF
		cRetorno += '				<td>%GXS_PESOT%</td>       																		' + _CRLF
		cRetorno += '				<td>				        																		' + _CRLF
		cRetorno += '					<input type="hidden" name="chave" id="chave" value="%CHAVE%"/>									' + _CRLF
		cRetorno += '					<input type="text" name="fretePreso" id="fretePreso" class="valFretePreso" maxlength="8" placeholder="00000.00" />		' + _CRLF	
		cRetorno += '				</td> 																								' + _CRLF
		cRetorno += '				<td>																								' + _CRLF
		cRetorno += '					<select name="incImposto" id="incImposto">														' + _CRLF			
		cRetorno += '						<option value="1">Com Imposto</option>																' + _CRLF
		cRetorno += '						<option value="2">Sem Imposto</option>																' + _CRLF
		cRetorno += '					</select>																						' + _CRLF
		cRetorno += '				</td>																								' + _CRLF
		cRetorno += '			</tr>																									' + _CRLF
		cRetorno += '			<tr class="linha">																						' + _CRLF
		cRetorno += '				<td colspan="9">Informa&ccedil;&otilde;es Adicionais: %GXR_INFOAD%</td>       																		' + _CRLF
		cRetorno += '			</tr>																									' + _CRLF
	ElseIf cParam == "BodyFim"
		cRetorno += " 		</tbody>																									" + _CRLF
		cRetorno += " 	</table>																										" + _CRLF
		cRetorno += " 	<p>&nbsp;</p>																									" + _CRLF
		cRetorno += ' 	<table width="100%">																							' + _CRLF
		cRetorno += " 		<tr>																										" + _CRLF
		cRetorno += " 			<td>																									" + _CRLF
		cRetorno += ' 				  <h6 align="center">																				' + _CRLF
		cRetorno += ' 					<button type="submit" name="btnAprov" class="btn bg"  onclick="Enviar(' + " '4' " + ')"/>Enviar</button>' + _CRLF
		cRetorno += " 				  </h6>																								" + _CRLF	  
		cRetorno += " 			</td>																									" + _CRLF
		cRetorno += " 		</tr>																										" + _CRLF
		cRetorno += " 	</table>																										" + _CRLF
		cRetorno += " 	  <p>&nbsp;</p>																									" + _CRLF
		cRetorno += ' 	  <h6><font size="1" face="Verdana"><center>Em caso de dificuldades por gentileza, entre em contato com nosso departamento de TI</center></font></br></h6> ' + _CRLF
		cRetorno += "     </div>																										" + _CRLF
		cRetorno += "  </div> 																											" + _CRLF
		cRetorno += " </form>																											" + _CRLF
		cRetorno += " </body>																											" + _CRLF
		cRetorno += " </html>																											" + _CRLF
	EndIf

Return cRetorno

Function GFEA078WFRT(oProcess, aRet)
	Local cRetorno 	:= DecodeUTF8(oProcess:oHtml:RetByName("resultado")) //Pega o retorno do html
	Local aAux 		:= {}
	Local aRetorno 	:= {}
	Local nX
	
	aAux := StrTokArr(cRetorno, "|") // divide em array cada registro (linha)
		
	For nX := 1 To Len(aAux)
		AADD(aRetorno, StrTokArr( aAux[nX], ";" ) ) // divide em array cada campo (coluna)
	Next nX 
	
	For nX := 1 To Len(aRetorno)
		GXS->(DbSetOrder(1))
		If GXS->(DbSeek(aRetorno[nX][1])) //Busca o registro e grava as informações
			If GXS->GXS_STATUS == "3"
				GXR->(dbSetOrder(1))
				If GXR->(dbSeek(GXS->GXS_FILIAL + GXS->GXS_IDREQ)) .And. GXR->GXR_DTLIM > Date()
					Reclock("GXS",.F.)
						GXS->GXS_FRTCOT := VAL(	StrTran( aRetorno[nX][2], "," ) 	)
						GXS->GXS_STATUS := "1"
						GXS->GXS_DTATU  := DDATABASE
						GXS->GXS_HRATU  := SubStr(TIME(), 0, 8)
					GXS->(MsUnlock())
				EndIf
			EndIf
		EndIf
	Next nX 
Return .T.

Function GFEA78CONT()
	Local cEmail := ""

	GU2->(dbSetOrder(1))
	If GU2->(dbSeek(xFilial("GU2")+M->GXS_CDTRP))
		While !(GU2->(EoF())) .And. GU2->GU2_FILIAL == xFilial("GU2") .And. GU2->GU2_CDEMIT == M->GXS_CDTRP
			If GFXCP12117("GU2_RECCOT") .And. GU2->GU2_RECCOT == "1"
				If Empty(cEmail)
					cEmail := GU2->GU2_EMAIL
				EndIf
			EndIf
			
			GU2->(dbSkip())
		EndDo
	EndIf
	
	If Empty(cEmail)
		GU3->(dbSetOrder(1))
		If GU3->(dbSeek(xFilial("GU3")+M->GXS_CDTRP))
			cEmail := GU3->GU3_EMAIL
		EndIf
	EndIf
Return cEmail

Function GFEA78RPES()
Return GXR->GXR_PESOT

Function GFEA78RQTD()
Return GXR->GXR_QTDET

Function GFEA78PRZ(nOpc)
	Local cRet 			:= ""
	Local aCriterios 	:= Array(10)
	Local aResult		:= {}
	
	Default nOpc := 3
	
	aCriterios[1] 	:= GXR->GXR_CDREM
	aCriterios[2] 	:= GXR->GXR_CDDEST
	aCriterios[3]	:= GXR->GXR_NRCIDO
	aCriterios[4]	:= GXR->GXR_NRCIDD
	aCriterios[5]	:= M->GXS_CDTRP
	aCriterios[6]	:= Posicione("GU3", 1, xFilial("GU3")+M->GXS_CDTRP, "GU3_CDGREM")
	aCriterios[7]	:= GXR->GXR_CDTPOP
	aCriterios[10]	:= GXR->GXR_CDCLFR
	
	aResult := GFETabPrzQbr(aCriterios, Date(), Time(), "1")
	
	If nOpc == 1
		cRet := aResult[8]
	ElseIf nOpc == 2
		cRet := aResult[9]
	EndIf
Return cRet

// Função criada para preenchimento de informações de contato no grid de Cotação de Frete
Function GFEA78CHKC(cOpc, cCodEmit)
	Local cRet      := " "
	Local cAliasGU3 := GetNextAlias()

	Default nOpc := 3

	BeginSQL Alias cAliasGU3
		SELECT GU3.GU3_EMAIL AS GU3EMAIL
		     , GU2.GU2_EMAIL AS GU2EMAIL
		     , GU2.GU2_NOME AS GU2CONT
		     , GU3.GU3_FONE1 AS GU3FONE
		     , GU2.GU2_FONE1 AS GU2FONE
		FROM %Table:GU3% GU3
		LEFT JOIN %Table:GU2% GU2
		ON GU2.GU2_FILIAL = GU3.GU3_FILIAL
		AND GU2.GU2_CDEMIT = GU3.GU3_CDEMIT
		AND GU2.GU2_SIT = '1'
		AND GU2.GU2_RECCOT = '1'
		AND GU2.%NotDel%
		WHERE GU3.GU3_FILIAL = %xFilial:GU3%
		AND GU3_CDEMIT = %Exp:cCodEmit%
		AND GU3.%NotDel%
	EndSQL
	If (cAliasGU3)->(!Eof())
		If Alltrim((cAliasGU3)->GU2EMAIL) <> ''
			If cOpc == '1'
				cRet := Alltrim((cAliasGU3)->GU2EMAIL)
			ElseIf cOpc == '2'
				cRet := Alltrim((cAliasGU3)->GU2CONT)
			ElseIf cOpc == '3'
				cRet := Alltrim((cAliasGU3)->GU2FONE)
			EndIf
		Else
			If cOpc == '1'
				cRet := Alltrim((cAliasGU3)->GU3EMAIL)
			ElseIf cOpc == '2'
				cRet := Alltrim("")
			ElseIf cOpc == '3'
				cRet := Alltrim((cAliasGU3)->GU3FONE)
			EndIf
		EndIf
	EndIf
	(cAliasGU3)->(dbCloseArea())

Return cRet