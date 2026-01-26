#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA059 Requisição de Negociação de Frete

Generico.

@sample
GFEA059()

@author Equipe Frete Embarcador
@since 03/04/2018
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA059()
	Local oBrowse 	:= Nil
	Private aRotina := MenuDef()
	Private lCopy 	:= .F.

	oBrowse := FWMBrowse():New()
	oBrowse:setAlias("GXR")
	oBrowse:setMenuDef("GFEA059")
	oBrowse:setDescription("Requisição de Negociação de Frete")
	
	oBrowse:AddLegend("GXR_SIT=='1'", "WHITE", "Em Edição") //"Em Edição"
	oBrowse:AddLegend("GXR_SIT=='2'", "BLUE", "Requisitada") //"Requisitada"
	oBrowse:AddLegend("GXR_SIT=='3'", "YELLOW", "Em Negociação") //"Em Negociação"
	oBrowse:AddLegend("GXR_SIT=='4'", "GREEN", "Atendida") //"Atendida"
	oBrowse:AddLegend("GXR_SIT=='5'", "RED", "Cancelada") //"Cancelada"
	
	oBrowse:SetFilterDefault("GXR_CODUSU = '" + RetCodUsr() + "'") 
	
	oBrowse:Activate()
    
Return Nil  

//------------------------------------------------------------------------------
// Função MenuDef
//------------------------------------------------------------------------------

Static Function MenuDef()
	Local aRotina := {}

	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	AAdd(aRotina, {"Pesquisar"							, 'AxPesqui'								, 0, 1  , 0, .T. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Visualizar"							, "VIEWDEF.GFEC059"							, 0, 2  , 0, .T. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Incluir"							, "VIEWDEF.GFEA059"							, 0, 3  , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Alterar"							, "VIEWDEF.GFEA059"							, 0, 4  , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Excluir"							, "VIEWDEF.GFEA059"							, 0, 5  , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Imprimir"							, "VIEWDEF.GFEA059"							, 0, 8  , 0, .T. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Concluir Edição"					, "GFEA59ConcluirEdicao()"					, 0, 10 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Retornar para Em Edição"			, "GFEA59RetornarEdicao()"					, 0, 11 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Cancelar"							, "GFEA59Cancelar()"						, 0, 12 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Comentar"							, "GFE059ACOM('1')"							, 0, 13 , 0, .F. /*Habilita Menu Funcional*/}) 
	AAdd(aRotina, {"Anexos"								, "MsDocument('GXR',GXR->(RecNo()), 3)"		, 0, 4  , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Aceitar e Encerrar"					, "GFEA59Aceitar('1')"						, 0, 14 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Aceitar e Contratar"				, "GFEA59Aceitar('2')"						, 0, 14 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Recusar Negociação"					, "GFEA59Recusar()"							, 0, 15 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Copiar"								, "GFEA59COPY()"							, 0, 9  , 0, .F. /*Habilita Menu Funcional*/})
	
Return aRotina

//------------------------------------------------------------------------------
// Função ModelDef
//------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel   := MPFormModel():New('GFEA059', /*bPreValid*/ ,( { |oMod| GFE059PVL( oMod ) } ) , /*bComValid*/ ,/*bCancel*/ )
    Local oStruGXR := FWFormStruct(1,'GXR')

    oModel:AddFields('GFEA059_GXR', /*cOwner*/, oStruGXR)
    
    oModel:SetActivate({|oMod| GFEA59ACT(oMod)})
    oModel:SetVldActivate({|oMod| GFEA059VL(oMod)})

Return oModel

//------------------------------------------------------------------------------
// Função ViewDef
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('GFEA059')
	Local oView    := FWFormView():New()
	Local oStruGXR := FWFormStruct(2,'GXR')
	
	oView:SetModel(oModel)
	oView:AddField('GFEA059_GXR', oStruGXR, /**/ )
	
Return oView

/* Validação para os campos no Dicionário de Dados */
Function GFEA059Ret(cCodUsu,nCampo)
	Local aArray := {}
	Local cDepto := ""
	Local cRamal := ""
	
	PswOrder(1)
	
	If PswSeek( cCodUsu, .T. )  
   		aArray := PswRet() // Retorna vetor com informações do usuário
	EndIf
	
    If nCampo = 1 //fone/ramal
    	cRamal := aArray[1][20] // Retorna ramal
    	Return cRamal
    EndIF
    
    If nCampo = 2 //departamento
		cDepto := aArray[1][12] // Retorna Departamento
		Return cDepto
	EndIf
	
Return

/*/{Protheus.doc} GFEA59ConcluirEdicao
//TODO Descrição auto-gerada.
@author Leonardo Ribas Jimenez Hernandez
@since 07/05/2018
@version 1.0
@param cGXRFILIAL, characters, Filial da Requisição de Frete
@param cGXRIDREQ, characters, Requisição de Frete
@type function
/*/
Function GFEA59ConcluirEdicao(cGXRFILIAL,cGXRIDREQ)
	Local aRetSit := {.T.,""}
	Local cDescSit := "concluir a edição" //"Concluir a Edição da"
	Local lRetPerg := .T.
	Local cMsgPadrao := "Requisição de Negociação de Frete (SIGAGFE) " +chr(13)+chr(10)
	
	Default cGXRFILIAL	:= '' 
	Default cGXRIDREQ		:= ''
	
	//Caso for chamado por outro lugar, fazer a verificação aqui
	If GXR->GXR_SIT == "1"
		If !IsBlind()
			lRetPerg := MsgYesNo("Deseja " + cDescSit + " da Requisição de Negociação de Frete selecionada?", Capital(cDescSit) + "?") //"Deseja "###" a requisição de frete selecionada?"
		Else
			lRetPerg := .T.
		EndIf

		If lRetPerg
			// Como a função é executada pela própria rotina, o registro já está posicionado.
			// quando a função for chamada externamente, deverá posicionar no registro para depois executar a ação.
			If !Empty(cGXRIDREQ)
				GXR->(dbSetOrder(1))
				If !GXR->(dbSeek(cGXRFILIAL + cGXRIDREQ))
					aRetSit := {.F., "Requisição de Negociação de Frete não existe na base de dados! Verifique os dados informados. Filial:("+ cGXRFILIAL +") Requisição:("+ cGXRIDREQ +") "}
				EndIf
			EndIf
			
			//Verificação existente caso função seja chamada por outro lugar
			If GXR->GXR_SIT != "1" //em edição
				aRetSit := {.F., cMsgPadrao + "A edição da Requisição de Negociação de Frete não pode ser concluída, pois ela não está Em Edição."}
			EndIf
			
			If aRetSit[1] == .T.
				RecLock("GXR", .F.)
					GXR->GXR_SIT := '2'
				GXR->(MsUnlock())
			EndIf
		EndIf
	Else
		aRetSit := {.F., cMsgPadrao + "A edição da Requisição de Negociação de Frete não pode ser concluída, pois ela não está Em Edição."}
	EndIf
	
	If aRetSit[1] == .F.
		GFEHelp(aRetSit[2])
	EndIf
Return

/*/{Protheus.doc} GFEA59RetornarEdicao
//TODO Descrição auto-gerada.
@author Leonardo Ribas Jimenez Hernandez
@since 07/05/2018
@version 1.0
@param cGXRFILIAL, characters, Filial da Requisição de Frete
@param cGXRIDREQ, characters, Requisição de Frete
@type function
/*/
Function GFEA59RetornarEdicao(cGXRFILIAL,cGXRIDREQ)
	Local aRetSit := {.T.,""}
	Local cDescSit := "retornar para Em Edição" //"retornar para Em Edição"
	Local lRetPerg := .T.
	Local cMsgPadrao := "Requisição de Negociação de Frete (SIGAGFE) " +chr(13)+chr(10)
	
	Default cGXRFILIAL	:= '' 
	Default cGXRIDREQ	:= '' 


	//Caso for chamado por outro lugar, fazer a verificação aqui
	If GXR->GXR_SIT == "2"
		If !IsBlind()
			lRetPerg := MsgYesNo("Deseja " + cDescSit + " a Requisição de Negociação de Frete selecionada?", Capital(cDescSit) + "?") //"Deseja "###" a requisição de frete selecionada?"
		Else
			lRetPerg := .T.
		EndIf
		
		If lRetPerg
			// Como a função é executada pela própria rotina, o registro já está posicionado.
			// quando a função for chamada externamente, deverá posicionar no registro para depois executar a ação.
			If !Empty(cGXRIDREQ)
				GXR->(dbSetOrder(1))
				If !GXR->(dbSeek(cGXRFILIAL + cGXRIDREQ))
					aRetSit := {.F., "Requisição de Negociação de Frete não existe na base de dados! Verifique os dados informados. Filial:("+ cGXRFILIAL +") Requisição:("+ cGXRIDREQ +") "}
				EndIf
			EndIf
			
			If aRetSit[1] == .T.
				RecLock("GXR", .F.)
					GXR->GXR_SIT := '1'
				GXR->(MsUnlock())
			EndIf
		EndIf
	Else
		aRetSit := {.F., cMsgPadrao + "Retornar para Em Edição somente se a Requisição estiver como Requisitada."}
	EndIf
	
	If aRetSit[1] == .F.
		GFEHelp(aRetSit[2])
	EndIf
Return

/*/{Protheus.doc} GFEA59Cancelar
//TODO Descrição auto-gerada.
@author Leonardo Ribas Jimenez Hernandez
@since 18/04/2018
@version 1.0
@param cGXRFILIAL, characters, Filial da Requisição de Frete
@param cGXRIDREQ, characters, Requisição de Frete
@type function
/*/
Function GFEA59Cancelar(cGXRFILIAL,cGXRIDREQ)

	Local oRequisicaoFrete  := GFERequisicaoFrete():New()
	Local oPainelRequisicao 
	Local oGFEComment 	:= GFEComment():New()
	Local lIsRomAGR		:= FindFunction("AGRX570RSF")
	Local lUsaUBA		:= .F.
	
	Default cGXRFILIAL	:= '' 
	Default cGXRIDREQ		:= ''
	 
	If !Empty(cGXRIDREQ)
		oRequisicaoFrete:setIdReq(cGXRIDREQ)
		oRequisicaoFrete:setFil(cGXRFILIAL)							
	Else
		oRequisicaoFrete:setIdReq(GXR->GXR_IDREQ)
	EndIf
	oRequisicaoFrete:validCancel()
	
	If !oRequisicaoFrete:getStatus()
		GFEHelp(oRequisicaoFrete:getMensagem())
		oGFEComment:destroy(oGFEComment)
		oRequisicaoFrete:destroy(oRequisicaoFrete)
		return
	EndIf
	
	oGFEComment:setTitleWindow("Cancelar Requisição")
	oGFEComment:setTitleMemo("Digite o motivo para o cancelamento da requisição: " + GXR->GXR_IDREQ)
	oGFEComment:setBtnConfirm("Confirmar")
	oGFEComment:setBtnCancel("Desistir")
	oGFEComment:createWindow()
	
	If !oGFEComment:getStatus()
		oGFEComment:destroy(oGFEComment)
		oRequisicaoFrete:destroy(oRequisicaoFrete)
		Return		
	Else
		If AllTrim(oGFEComment:getText()) != ""
			oRequisicaoFrete:setSitRes("5")
			oRequisicaoFrete:setMotCanc(oGFEComment:getText())		
			oRequisicaoFrete:changeSituation()			
			CursorWait()			
			//Bloco responsavel pelo envio do e-mail
			oPainelRequisicao := GFEPainelRequisicao():New()
			oPainelRequisicao:setIdReq(GXR->GXR_IDREQ)
			oPainelRequisicao:SendMailCancel()		
			If oPainelRequisicao:getStatus() == .F.		                                                   
		   	GFEHelp ("Não foi possível enviar o e-mail para o usuário negociador. " + USRRETMAIL(GXR->GXR_USUNEG),;		   	   
		   	    	  "Se necessário estabelecer contato com o usuário negociador, também é possível realizá-lo por meio dos comentários.", "Envio de Email - Cancelamento")		
			EndIf
			oPainelRequisicao:Destroy(oPainelRequisicao)
			CursorArrow()			
		Else
			GFEHelp("É necessário que exista um motivo para realizar esta ação!")
			GFEA59Cancelar(cGXRFILIAL,cGXRIDREQ)
		EndIf
	EndIf
	
	If GFXPR12117("MV_AGRUBA") .and. lIsRomAGR
		lUsaUBA		:= SuperGetMv("MV_AGRUBA",.F.,.F.)
		//Caso esteja excluido ou cancelando a requisição
		If (oRequisicaoFrete:getSitRes() = '5') .AND. oRequisicaoFrete:getStatus()
						
			// ******************************************* //
			//	 /****** CHAMADA AGROINDÚSTRIA *******/	   //
			// ******************************************* //
			if  lUsaUBA
				AGRX570RSF(GXR->GXR_FILIAL,GXR->GXR_IDREQ,GXR->GXR_PESOT)
			endIf			
		endIf
	endIf
	oGFEComment:destroy(oGFEComment)
	oRequisicaoFrete:destroy(oRequisicaoFrete)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA59Aceitar
Função responsável por aceitar a negociação

@author Leonardo Ribas Jimenez Hernandez
@since 30/05/2018
@version 1.0

@param 
/*/
//-------------------------------------------------------------------
Function GFEA59Aceitar(nOp)
	Local oRequisicaoFrete  := GFERequisicaoFrete():New()	
	Local oPainelRequisicao 
	Local cMsg 				:= ""
	Local aRet				:= {}
	
	// "Seta" os dados necessários para execução do método de Requisição de Frete
	oRequisicaoFrete:setIdReq(GXR->GXR_IDREQ)
	oRequisicaoFrete:setCodUsu(RetCodUsr())
	oRequisicaoFrete:setNewSitRes("1")
	
	// Executa o método de Validar Negociação
	oRequisicaoFrete:ValNegociacao()
	
	// Verificado a situação após a execução
	If oRequisicaoFrete:getStatus() == .F.
		// Busca o retorno da execução do método
		Help( ,, 'HELP',, oRequisicaoFrete:getMensagem(), 1, 0,)
		// Destroy o objeto criado para os métodos de Requisição de Frete
		oRequisicaoFrete:Destroy(oRequisicaoFrete)
		Return
	EndIf
	
	cMsg := oRequisicaoFrete:getMensagem()
	If Empty(cMsg)
		cMsg := "Deseja aceitar a negociação?"
	Else
		cMsg := oRequisicaoFrete:getMensagem() + " Deseja aceitar a negociação?"
	EndIf

	If MSGYESNO(cMsg)
		CursorWait()		
		//Função responsável por efetivar o aceite da requisição
		GFE059Aceite(GXR->GXR_IDREQ)
		//Bloco responsavel pelo envio do e-mail
		oPainelRequisicao := GFEPainelRequisicao():New()
		oPainelRequisicao:setIdReq(GXR->GXR_IDREQ)
		oPainelRequisicao:SendMailAccept()		
		If oPainelRequisicao:getStatus() == .F.		                                                   
		   GFEHelp ("Não foi possível enviar o e-mail para um ou mais destinatários: " + USRRETMAIL(GXR->GXR_USUNEG) + ", " + GXR->GXR_EMAIL + ", " + GXR->GXR_CC,;		   	   
  	   	            "Se necessário estabelecer contato com o usuário negociador, também é possível realizá-lo por meio dos comentários.", "Envio de Email - Aceite")		
		EndIf
		oPainelRequisicao:Destroy(oPainelRequisicao)
		CursorArrow()
	EndIf
	
	If nOp == "2" .And. GXR->GXR_FDADE == "1"
		aRet := GFEA59NReqCont()
	EndIf
	
	// Destroy o objeto criado para os métodos de Requisição de Frete
	oRequisicaoFrete:Destroy(oRequisicaoFrete)	
Return ()

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE059Aceite
Função responsável por efetivar o aceite da requisição

@author Leonardo Ribas Jimenez Hernandez
@since 30/05/2018
@version 1.0

@param cIdReq - Id da Requisição de Negociação de Frete
/*/
//-------------------------------------------------------------------
Function GFE059Aceite(cIdReq)

	GXR->(dbSetOrder(1))
	If GXR->(dbSeek(xFilial("GXR") + cIdReq))
		RecLock("GXR", .F.)
			GXR->GXR_SITRES	:= "1"
			GXR->GXR_MOTREJ := ""
		GXR->(MsUnlock())	
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA59Recusar
Função responsável por recusar a negociação

@author Leonardo Ribas Jimenez Hernandez
@since 30/05/2018
@version 1.0

@param 
/*/
//-------------------------------------------------------------------
Function GFEA59Recusar()
	Local oRequisicaoFrete  := GFERequisicaoFrete():New()	
	Local oPainelRequisicao 
	Local cMsg := "" 

	// "Seta" os dados necessários para execução do método de Requisição de Frete
	oRequisicaoFrete:setIdReq(GXR->GXR_IDREQ)
	oRequisicaoFrete:setCodUsu(RetCodUsr())
	oRequisicaoFrete:setNewSitRes("2")
	
	// Executa o método de Validar Registrar Contrato
	oRequisicaoFrete:ValNegociacao()
	
	// Verificado a situação após a execução
	If oRequisicaoFrete:getStatus() == .F.
		// Busca o retorno da execução do método
		Help( ,, 'HELP',, oRequisicaoFrete:getMensagem(), 1, 0,)
		// Destroy o objeto criado para os métodos de Requisição de Frete
		oRequisicaoFrete:Destroy(oRequisicaoFrete)
		Return
	EndIf
	
	cMsg := oRequisicaoFrete:getMensagem()
	If Empty(cMsg)
		cMsg := "Deseja recusar a negociação?"
	Else
		cMsg := oRequisicaoFrete:getMensagem() + " Deseja recusar a negociação?"
	EndIf
	
	If MSGYESNO(cMsg)
		CursorWait()
		//Função responsável por efetivar a recusa da Requisição de Frete
		GFE059Recusa(GXR->GXR_IDREQ)
		//Bloco responsavel pelo envio do e-mail	
		oPainelRequisicao := GFEPainelRequisicao():New()
		oPainelRequisicao:setIdReq(GXR->GXR_IDREQ) 
		oPainelRequisicao:SendMailReject()			
		If oPainelRequisicao:getStatus() == .F.		   
		   GFEHelp ("Não foi possível enviar o e-mail para um ou mais destinatários: " + USRRETMAIL(GXR->GXR_USUNEG) + ", " + GXR->GXR_EMAIL + ", " + GXR->GXR_CC,;		   	   
		            "Se necessário estabelecer contato com o usuário negociador, também é possível realizá-lo por meio dos comentários.", "Envio de Email - Recusado")
		EndIf
		oPainelRequisicao:Destroy(oPainelRequisicao)
		CursorArrow()
	EndIf	
	
	// Destroy o objeto criado para os métodos de Requisição de Frete
	oRequisicaoFrete:Destroy(oRequisicaoFrete)	
Return ()

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE059Recusa
Função responsável por efetivar o recusa da requisição

@author Leonardo Ribas Jimenez Hernandez
@since 30/05/2018
@version 1.0

@param cIdReq - Id da Requisição de Negociação de Frete
/*/
//-------------------------------------------------------------------
Function GFE059Recusa(cIdReq)
	Local cTexto1 := ""

	DEFINE MSDIALOG oDlg TITLE "Recusar Negociação" From 4,0 To 16,60 OF oMainWnd				 //"Recusar Negociação"
	@ 4, 006  SAY "Motivo da Recusa:" SIZE 70,7 PIXEL OF oDlg //"Motivo da Recusa:"
	// Usando o New
	oTMultiget1 := TMultiget():New(13,06,{|u|If(Pcount()>0,cTexto1:=u,cTexto1)},;
	oDlg,225,60,,,,,,.T.)
	
	oButtonOK   := tButton():New(75,5,'OK',oDlg,{|| If(GFERECNEG(cIdReq, cTexto1),oDlg:End(),NIL)},25,10,,,,.T.) //chamada da funcao para atualizar os campos
	oButtonCanc := tButton():New(75,35,"Cancelar",oDlg,{||(oDlg:End())},25,10,,,,.T.) //"Cancelar"
	
	ACTIVATE MSDIALOG oDlg

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFERECNEG
Função responsável por efetivar o recusa da requisição

@author Leonardo Ribas Jimenez Hernandez
@since 30/05/2018
@version 1.0

@param cIdReq - Id da Requisição de Negociação de Frete
/*/
//-------------------------------------------------------------------
Function GFERECNEG(cIdReq, cTexto1)

	GXR->(dbSetOrder(1))
	If GXR->(dbSeek(xFilial("GXR") + cIdReq))
		RecLock("GXR", .F.)
			GXR->GXR_SITRES	:= "2"
			GXR->GXR_MOTREJ := cTexto1
		GXR->(MsUnlock())	
	EndIf

Return .T.

/*-------------------------------------------------------------------
Realiza a validação do formulário da requisição de frete na ativação
-------------------------------------------------------------------*/
Function GFEA059VL(oModel)
	Local lRet    	:= .T.
	Local nOpc    	:= (oModel:GetOperation())
	
	If (nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_DELETE) .And. GXR->GXR_SIT != '1'   
		GFEHelp("Não é possível alterar ou excluir se a Requisição de Negociação de Frete não estiver Em Edição.", "Verifique o status da Requisição, ela deve estar igual a: 1-Em Edição.")
		Return .F.
	EndIf

Return lRet

/*-------------------------------------------------------------------
Realiza a validação do formulário da requisição de frete na confirmação
-------------------------------------------------------------------*/
Function GFE059PVL(oModel)
	Local lRet    	:= .T.
	Local nOpc    	:= (oModel:GetOperation())
	Local lIsRomAGR	:= FindFunction("AGRX570RSF")
	Local lUsaUBA	:= .F.
	
	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
		If M->GXR_PESOT == 0 .And. M->GXR_QTDET == 0 .And. M->GXR_VALORT == 0
			GFEHelp("Existem campos obrigatórios que não foram preenchidos!","Verificar os campos Peso Total, Quantidade Total e Valor Total para que ao menos um destes possua valor.","SIGAGFE - GFEA059")
			Return .F.
		EndIf
	EndIf
	
	//Faz a exclusão dos comentários da requisição
	If(nOpc == MODEL_OPERATION_DELETE)
		aAreaGXW  := GXW->( GetArea() )
			GXW->( dbSetOrder(01) )
			GXW->( dbSeek(GXR->GXR_FILIAL + GXR->GXR_IDREQ) )
			While !GXW->( Eof() ) .and. GXW->GXW_IDREQ == GXR->GXR_IDREQ
				RecLock("GXW",.F.)
					dbDelete()
				GXW->( MsUnlock() )
				GXW->( dbSkip() )
			EndDo		
		RestArea(aAreaGXW)
		
		iF GFXPR12117("MV_AGRUBA") .and. lIsRomAGR
			lUsaUBA	:= SuperGetMv("MV_AGRUBA",.F.,.F.)
			// ******************************************* //
			//	 /****** CHAMADA AGROINDÚSTRIA *******/	   //
			// ******************************************* //
			If  lUsaUBA
				AGRX570RSF(GXR->GXR_FILIAL,GXR->GXR_IDREQ,GXR->GXR_PESOT)
			EndIf
		EndIf
	EndIf	
Return lRet

Function GFEA59NReqCont()
	Local aDadosGXR			:= Array(29)
	Local cNovoNrReq		:= 0
	Local aDadosGXS			:= {}
	Local nX				:= 0
	Local aRet				:= {.T., ""}
	
	If GXR->GXR_FDADE == "1"
	 	If GXR->GXR_GERCON == "2"
		
			cNovoNrReq	:= GETSXENUM("GXR","GXR_IDREQ")
			
			RecLock("GXR",.F.)
				GXR->GXR_GERCON	:= "1"
			GXR->(MsUnlock())
			
			aDadosGXR[1]	:= GXR->GXR_FILIAL
			aDadosGXR[2] 	:= GXR->GXR_CODUSU
			aDadosGXR[3] 	:= GXR->GXR_EMAIL
			aDadosGXR[4] 	:= GXR->GXR_FONE
			aDadosGXR[5] 	:= GXR->GXR_DEPTO
			aDadosGXR[6] 	:= GXR->GXR_USUPER
			aDadosGXR[7] 	:= GXR->GXR_NOMSUP
			aDadosGXR[8] 	:= GXR->GXR_CC
			aDadosGXR[9] 	:= GXR->GXR_IDENT
			aDadosGXR[10] 	:= GXR->GXR_TPIDEN
			aDadosGXR[11] 	:= GXR->GXR_CDREM
			aDadosGXR[12] 	:= GXR->GXR_NRCIDO
			aDadosGXR[13] 	:= GXR->GXR_UFO
			aDadosGXR[14] 	:= GXR->GXR_CDDEST
			aDadosGXR[15] 	:= GXR->GXR_NRCIDD
			aDadosGXR[16] 	:= GXR->GXR_UFD
			aDadosGXR[17] 	:= GXR->GXR_CDTPOP
			aDadosGXR[18] 	:= GXR->GXR_CDCLFR
			aDadosGXR[19] 	:= GXR->GXR_PESOT
			aDadosGXR[20] 	:= GXR->GXR_UMPESO
			aDadosGXR[21] 	:= GXR->GXR_QTDET
			aDadosGXR[22] 	:= GXR->GXR_VALORT
			aDadosGXR[23] 	:= GXR->GXR_INFOAD
			aDadosGXR[24] 	:= GXR->GXR_DTINI
			aDadosGXR[25] 	:= GXR->GXR_DTTER
			aDadosGXR[26]	:= GXR->GXR_IDREQ
			aDadosGXR[27]	:= GXR->GXR_CSTRES
			If GFXCP12123("GXR_PEDCOM")
				aDadosGXR[28]	:= GXR->GXR_PEDCOM
			EndIf
			If GFXCP12123("GXR_IDOUT")
				aDadosGXR[29]	:= GXR->GXR_IDOUT
			EndIf
			
			GXS->(dbSetOrder(1))
			If GXS->(dbSeek(GXR->GXR_FILIAL + GXR->GXR_IDREQ))
				While !GXS->(EoF()) .And. (GXS->GXS_FILIAL == GXR->GXR_FILIAL .And. GXS->GXS_IDREQ == GXR->GXR_IDREQ)
					Aadd(aDadosGXS,{GXS->GXS_MRKBR, GXS->GXS_JUSTIF, GXS->GXS_CDTRP, GXS->GXS_NRCT, GXS->GXS_FILCT, GXS->GXS_NRNEG, GXS->GXS_NRTAB, GXS->GXS_FILTAB,;
									GXS->GXS_CODREF, GXS->GXS_FILREF, GXS->GXS_PESOT, GXS->GXS_QTDET, GXS->GXS_TOTFRT, GXS->GXS_FRTPES, GXS->GXS_PRAZO, GXS->GXS_TPPRAZ,;
									GXS->GXS_FRTCOT, GXS->GXS_ORICOT, GXS->GXS_NMCONT, GXS->GXS_EMCONT, GXS->GXS_FOCONT, GXS->GXS_JUSCOT})
					GXS->(dbSkip())
				EndDo
			EndIf
			
			RecLock("GXR",.T.)
				GXR->GXR_FILIAL	:= aDadosGXR[1]
				GXR->GXR_IDREQ  := cNovoNrReq
				GXR->GXR_CODUSU := aDadosGXR[2]
				GXR->GXR_EMAIL	:= aDadosGXR[3]
				GXR->GXR_FONE	:= aDadosGXR[4]
				GXR->GXR_DEPTO	:= aDadosGXR[5]
				GXR->GXR_USUPER	:= aDadosGXR[6]
				GXR->GXR_NOMSUP	:= aDadosGXR[7]
				GXR->GXR_CC		:= aDadosGXR[8]
				GXR->GXR_FDADE	:= "2"
				GXR->GXR_IDENT	:= aDadosGXR[9]
				GXR->GXR_TPIDEN	:= aDadosGXR[10]
				GXR->GXR_CDREM	:= aDadosGXR[11]
				GXR->GXR_NRCIDO	:= aDadosGXR[12]
				GXR->GXR_UFO	:= aDadosGXR[13]
				GXR->GXR_CDDEST	:= aDadosGXR[14]
				GXR->GXR_NRCIDD	:= aDadosGXR[15]
				GXR->GXR_UFD	:= aDadosGXR[16]
				GXR->GXR_CDTPOP	:= aDadosGXR[17]
				GXR->GXR_CDCLFR	:= aDadosGXR[18]
				GXR->GXR_PESOT	:= aDadosGXR[19]
				GXR->GXR_UMPESO	:= aDadosGXR[20]
				GXR->GXR_QTDET	:= aDadosGXR[21]
				GXR->GXR_VALORT	:= aDadosGXR[22]
				GXR->GXR_INFOAD	:= aDadosGXR[23]
				GXR->GXR_DTINI	:= aDadosGXR[24]
				GXR->GXR_DTTER	:= aDadosGXR[25]
				GXR->GXR_DTLIM	:= aDadosGXR[24]
				GXR->GXR_MOTLIM	:= "Requisição gerada através da aprovação de requisição com finalidade consulta."
				GXR->GXR_OBSREQ	:= ""
				GXR->GXR_DTREQ	:= Date()
				GXR->GXR_HRREQ	:= SUBSTR(TIME(), 1, 5)                                                                                                            
				GXR->GXR_SIT	:= "2"
				GXR->GXR_USUNEG	:= ""
				GXR->GXR_AVISO	:= "1"
				GXR->GXR_SITRES	:= "0"
				GXR->GXR_MOTREJ	:= ""
				GXR->GXR_MOTCAN	:= ""
				GXR->GXR_REQBAS	:= aDadosGXR[26]
				GXR->GXR_GERCON := "2"
				GXR->GXR_CSTRES	:= aDadosGXR[27]
				If GFXCP12123("GXR_PEDCOM")
					GXR->GXR_PEDCOM := aDadosGXR[28]
				EndIf
				If GFXCP12123("GXR_IDOUT")
					GXR->GXR_IDOUT	:= aDadosGXR[29]
				EndIf
				If GFXCP12123("GXR_REQACT")
					GXR->GXR_REQACT := "2"
				EndIf
				
				ConfirmSx8()	
			GXR->(MsUnLock())
			
			For nX := 1 To Len(aDadosGXS)
				RecLock("GXS",.T.)
					GXS->GXS_FILIAL	:= aDadosGXR[1]
					GXS->GXS_IDREQ	:= cNovoNrReq
					GXS->GXS_SEQ	:= Iif(nX < 10,"0" + AllTrim(STR(nX)), AllTrim(STR(nX)))
					GXS->GXS_MRKBR	:= aDadosGXS[nX][1]
					GXS->GXS_JUSTIF	:= aDadosGXS[nX][2]
					GXS->GXS_CDTRP	:= aDadosGXS[nX][3]
					GXS->GXS_NRCT	:= aDadosGXS[nX][4]
					GXS->GXS_FILCT	:= aDadosGXS[nX][5]
					GXS->GXS_NRNEG	:= aDadosGXS[nX][6]
					GXS->GXS_NRTAB	:= aDadosGXS[nX][7]
					GXS->GXS_FILTAB	:= aDadosGXS[nX][8]
					GXS->GXS_CODREF	:= aDadosGXS[nX][9]
					GXS->GXS_FILREF	:= aDadosGXS[nX][10]
					GXS->GXS_PESOT	:= aDadosGXS[nX][11]
					GXS->GXS_QTDET	:= aDadosGXS[nX][12]
					GXS->GXS_TOTFRT	:= aDadosGXS[nX][13]
					GXS->GXS_FRTPES	:= aDadosGXS[nX][14]
					GXS->GXS_PRAZO	:= aDadosGXS[nX][15]
					GXS->GXS_TPPRAZ	:= aDadosGXS[nX][16]
					GXS->GXS_FRTCOT	:= aDadosGXS[nX][17]
					GXS->GXS_ORICOT	:= aDadosGXS[nX][18]
					GXS->GXS_NMCONT	:= aDadosGXS[nX][19]
					GXS->GXS_EMCONT	:= aDadosGXS[nX][20]
					GXS->GXS_FOCONT	:= aDadosGXS[nX][21]
					GXS->GXS_JUSCOT	:= aDadosGXS[nX][22]
				GXS->(MsUnLock())
			Next nX
			
			aRet[1]	:= .T.
			aRet[2]	:= "Com base nesta requisição de consulta foi gerada uma requisição de contratação com o código " + cNovoNrReq + "." 
		Else
			aRet[1]	:= .F.
			aRet[2]	:= "Esta requisição de consulta já gerou uma requisição de contratação!"
		EndIf
	Else
		aRet[1]	:= .F. 
		aRet[2]	:= "Para geração de requisição de contratação, a requisição base deve ser de consulta!"
	EndIf
	
Return aRet

Function GFEA59COPY()
	
	lCopy := .T.

	FWExecView("Cópia","GFEA059",9,,{|| .T.}) //"Cópia"
Return

/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA59ACT
Função chamada após a ativação do Model

@sample
GFEA59ACT(oModel)

@author João Leonardo Schmidt
@since 28/01/2019
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFEA59ACT(oModel)
	Local oModelGXR 	:= oModel:GetModel("GFEA059_GXR")
	Local aFieldGXR 	:= oModelGXR:GetStruct():aFields
	Local nI			:= 0
	Local cCodUsr		:= RetCodUsr()
	
	If IsInCallStack("GFEA059") .And. lCopy
	
		For nI := 1 To Len(aFieldGXR)
	
			If aFieldGXR[nI][3] == "GXR_DTREQ"
				oModelGXR:SetValue(aFieldGXR[nI][3], Date())
			ElseIf aFieldGXR[nI][3] == "GXR_HRREQ"
				oModelGXR:SetValue(aFieldGXR[nI][3], SubStr(Time(),1,5))
			ElseIf aFieldGXR[nI][3] == "GXR_SIT"
				oModelGXR:SetValue(aFieldGXR[nI][3], "1")
			ElseIf aFieldGXR[nI][3] == "GXR_USUNEG"
				oModelGXR:SetValue(aFieldGXR[nI][3], "")
			ElseIf aFieldGXR[nI][3] == "GXR_AVISO"
				oModelGXR:SetValue(aFieldGXR[nI][3], "1")
			ElseIf aFieldGXR[nI][3] == "GXR_SITRES"
				oModelGXR:SetValue(aFieldGXR[nI][3], "0")
			ElseIf aFieldGXR[nI][3] == "GXR_MOTREJ"
				oModelGXR:SetValue(aFieldGXR[nI][3], "")
			ElseIf aFieldGXR[nI][3] == "GXR_MOTCAN"
				oModelGXR:SetValue(aFieldGXR[nI][3], "")
			ElseIf aFieldGXR[nI][3] == "GXR_REQBAS"
				oModelGXR:SetValue(aFieldGXR[nI][3], "")
			ElseIf aFieldGXR[nI][3] == "GXR_GERCON"
				oModelGXR:SetValue(aFieldGXR[nI][3], "2")
			ElseIf aFieldGXR[nI][3] == "GXR_CODUSU"
				oModelGXR:SetValue(aFieldGXR[nI][3], cCodUsr)
			EndIf
		Next nI
	
		lCopy := .F.
	
	EndIf

Return Nil

Function GFEA59TPIDEN()
	Local lMV_ERPGFE := SuperGetMv("MV_ERPGFE",.F.,"1") != "2"
	
	If lMV_ERPGFE .And. (M->GXR_TPIDEN == "2" .Or. M->GXR_TPIDEN == "5")
		GFEHelp("Função disponível apenas para ERP Protheus!",,"Função não disponível")
		Return .F.
	EndIf
Return .T.
