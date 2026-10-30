#INCLUDE "PARMTYPE.CH" 
#INCLUDE "STWGIFTLIST.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "POSCSS.CH"     
#INCLUDE "STPOS.CH"
#INCLUDE "FWBROWSE.CH"

#DEFINE POS_MMODO			1				//Modo de abertura
#DEFINE POS_MRET			2       		//Modo de retorno
#DEFINE POS_MTPL			3				//Tipo da lista
#DEFINE POS_MNL			4				//Numero da lista (Filtro ME1)
#DEFINE POS_MONL			5				//Online
#DEFINE POS_MLNOM			6				//Entrar com nomes dos presenteadores
#DEFINE POS_MLENVM		7				//Enviar mensagem
#DEFINE POS_MLITAB		8				//Listar itens em aberto
#DEFINE POS_MORI			9				//Origem da lista (filtro ME1)
#DEFINE POS_MFILT			10				//Filtro (ME2)
#DEFINE POS_MMULT			11				//Multi-selecao
#DEFINE POS_MMTOD			12				//Marcar todos
#DEFINE POS_MQTDU			13				//Quantidade utilizada
#DEFINE POS_MLAQTD		14				//Alterar quantidade
#DEFINE POS_MAME			15				//Alterar modo de entrega
#DEFINE POS_MTPEVE		16				//Tipo de evento (filtro ME1)
#DEFINE POS_MSTAT			17	  			//Status da lista (filtro ME1)


//-------------------------------------------------------------------
/*/{Protheus.doc} STWGLSearch
Função de Busca da Lista de Presentes
@param  cFil     - Filial da Busca
@param  aHeader01 - Header da Lista
@param  aFiltro - Filtro de Busca
@param  aDados01 - Array de Dados
@param  oDlg - Janela de Retorno
@param  oGD01 - Grid de REtorno
@param  aMainCfg - Configuração principal
@author  Varejo
@version P11.8
@since   17/12/14
@return  Nil
@sample
/*/
//-------------------------------------------------------------------
Function STWGLSearch(    cFil    ,aHeader01,aFiltro,aDados01,;
							oDlg     ,oGD01  , aMainCfg)

Local aLstCmp			:= {}				//Lista de campos para consulta
Local lRet				:= .F.				//Controle de retorno
Local aRet				:= {} 				//Retorno do Execute

Default cFil    	:= ""					// Filial
Default aHeader01	:= {}					// cabecalho
Default aFiltro		:= {}				// filtro da tabela de itens
Default aDados01	:= {}					// array dos dados a incluir
Default oDlg		:= NIL					// objeto do dialog
Default oGD01		:= NIL					// objeto do dialog
Default aMainCfg	:= {}					// array com tamanho do objeto GD

If ValType(aFiltro) == "A" .AND. Len(aFiltro) > 0
	//Montar lista de campos a partir do cabecalho
	aEval(aHeader01,{|x| aAdd(aLstCmp,x[1])})
	//Bloco de tratamento de erro
		
	LjMsgRun( STR0012,, { || lRet := STDGLRetD( "LJ845PESQC", {"",aLstCmp,aFiltro,0,.T.,aMainCfg}, @aRet) } ) //"Pesquisando Lista na Retaguarda. Aguarde..."
				
    If !lRet .OR. Valtype(aRet) <> "A"
		ConOut(STR0013 + "Lj845PesqC")        	//"Erro na execução(Retaguarda) - " 
		Alert(STR0013 +  "Lj845PesqC")        	//"Erro na execução(Retaguarda) - "
	ElseIf Valtype(aRet) == "A"	.AND. Len(aRet) == 0
		MsgInfo(STR0014,STR0015)	//"Lista não localizada. Verifique os parâmetros de pesquisa."   ## //"Consulta Retaguarda"
    EndIf						
Endif

aDados01 := aClone(aRet)

If oDlg # Nil
	oGD01:SetArray(aDados01)
	oGD01:Refresh()
	oGD01:GoTop(.T.)
	Eval(oGD01:bLDblClick)
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STWGLItSearch
Função de Busca dos Itens da Lista de Presentes
@param		cNumLst - Numero da Lista
@param		aDados01 - Dados da Lista
@param		aLstC01 - Campos da Lista
@param		aItRet - Itens de Listas Selecionados
@param		aMsgRet - Mensagens
@param		aMainCfg - Configuracao Principal
@param		aLstC02 - Campos Itens
@param		aLstC03 - Campos Mensagens
@param		aHeader02 - Header Itens
@param		aDados02 - Dados Itens de Lista
@param		oPnlGrdP - Panel de Itens de Listas
@param		oGrpPrd - Panel do Grid de Itens
@param		oCbxMet - Combo Métodos de Entrega
@param		aCbxMet - Array de Combo de Métodos de Entrega
@param		oGrpGen - Grupo de Grid de Mensagens/Atores/Entregas
@param		aDados03 - Dados de Mensagens
@param		nPosCab - Posicao do Grid de Listas
@param		lGrdMsgAtv - Grid de Mensagens Ativo
@param		cTextoGen - Texto do Grid de Mensagens/atores/Entregas
@param		oLblGen - Label de Mensagens/atores/Entrega
@param		aHeader03 - Header de Mensagens
@param		aAuxCombo - Combo
@param		oPnlGen - Panel Genérico
@param		cTextoBtn - Texto Botão 
@param		oBtnCnc - Botão Cancelar
@param		oBtnCnf - Botão Finalizar
@param		lPosicionado - Posicionado no Grid da Lista
@param		oBtnConf - Botão Confirmar
@author  Varejo
@version P11.8
@since   17/12/14
@return  Nil
@sample
/*/
//-------------------------------------------------------------------
Function STWGLItSearch( cNumLst, aDados01, aLstC01, aItRet,;
						aMsgRet, aMainCfg, aLstC02, aLstC03,;
						aHeader02, aDados02, oPnlGrdP, oGrpPrd,;
						oCbxMet, aCbxMet, oGrpGen, aDados03,;
						nPosCab, lGrdMsgAtv, cTextoGen, oLblGen, ;
						aHeader03, aAuxCombo, oPnlGen, cTextoBtn, ;
						oBtnCnc, oBtnCnf, lPosicionado, oBtnConf ) 

Local lRet				:= .T.													//Controle de retorno
Local lOk				:= .T.													//Controle de fluxo
Local cTMP				:= ""													//String temporaria
Local lExtra			:= .F.													//Aceita quantidades extras?
Local lListaItAb		:= .F.													//Listar apenas itens em aberto?
Local lTCBox			:= .T.													//Substituir valores de campos combobox
Local cModoEnt 		:= ""													//Método de entrega

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca de dados da ME2  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
lOK := STDGLRetD( "LJ845RETD", ;
				{xFilial("ME2"),"ME2","ME2.ME2_CODIGO = '" + cNumLst + "'",aLstC02,1,lTCBox},;
				@aDaDos02)



If lOK 
	ConOut("Execução com sucesso - " + "LJ845RETD ME2")
Else
	ConOut("Erro na execução - " + "LJ845RETD ME2")
EndIf
				 
If Len(aDados02) == 0
	oGrpPrd:SetArray(aDados02)
	oGrpPrd:Refresh()		
	lOk := .F.
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca de dados da MED  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
If lOk .AND. Len(aDados03) = 0
	lOK := STDGLRetD("LJ845RETD", ;
				{xFilial("MED"),"MED","",aLstC03,1,.F., .T.},;
				@aMsgRet			)	
	aEval(aMsgRet, { |l|,  aAdd(aDados03, aClone(aIns(aSize(l, len(l)+1), 1))), aTail(aDados03)[1] := space(1) } )  				
Endif

If lOK 
	ConOut("Execução com sucesso - " + "LJ845RETD MED" )
Else
	ConOut("Erro na execução - " + "LJ845RETD MED")
EndIf

lExtra := STDGLRtCol(2,"ME1_EXTRA",0,nPosCab,aLstC01,aDados01,.F.,lTCBox) == "1"
lListaItAb := aMainCfg[POS_MLITAB]
//Se estiver configurado para listar todos os itens, verificar se extras sao permitidos na lista, se nao for permitido bloquear a visualizacao de itens zerados
If !lListaItAb .AND. !lExtra
	lListItAb := .T.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimentar arquivo temporario  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTMP := STDGLRtCol(2,"ME1_TIPO",0,nPosCab,aLstC01,aDados01,.F.,lTCBox)
	Do Case
	Case cTMP == "1"	//Credito
			cModoEnt := STR0002 //"1=Credito"
			aCbxMet := {STR0002,STR0003} //"1=Credito"#"2=Retira"
		Case cTMP == "2"	//Entrega
			cModoEnt := STR0004 //"1=Entrega"
			aCbxMet := {STR0004,STR0003} ///"1=Entrega"#"2=Retira"
		Case cTMP == "4" //2-Entrega ou 4-Retira
			cModoEnt := STR0003 //"2=Retira"
			aCbxMet := {STR0004,STR0003} ///"1=Entrega"#"2=Retira"	
		Otherwise					//Entrega programada
			cModoEnt := STR0004 //"1=Entrega"
			aCbxMet := {STR0004,STR0003} ///"1=Entrega"#"2=Retira""
	EndCase

	aDados02 := STDGLIt(aDados02, aMainCfg, aLstC02, lTCBox, ;
							lListaItAb, aHeader02, aItRet, cNumLst, ;
							cModoEnt, aCbxMet)

	If oCbxMet # NIL
		oCbxMet:SetItems(aCbxMet)

		If cTMP == "4"
			oCbxMet:nat := 2 
		EndIf	

		oCbxMet:Refresh()
	EndIf

	If oPnlGrdP # Nil	
			oGrpPrd:SetArray(aDados02)		
			oGrpPrd:GoTop(.T.)
			Eval(oGrpPrd:bChange)
	Endif

	lPosicionado := .T.
	If ValType(oBtnConf) == "O"
		oBtnConf:Refresh()
	EndIf

	If !lGrdMsgAtv 
		//Monta a grid de mensagens
		STWGLGdGe( oPnlGen, @aDados03, aHeader03, aAuxCombo, ;
					@oGrpGen, @lGrdMsgAtv, @cTextoGen, @oLblGen, ;
					@cTextoBtn, @oBtnCnc, @oBtnCnf)
	Else
	
		//Monta o Grid de Mensagens		
		If oGrpGen # NIL .and. Len(aDados03) > 0
			oGrpGen:SetArray(aDados03)
			oGrpGen:Refresh()
			lGrdMsgAtv := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWGLGdGe
Função de Montagem do Grid de Mensagens
@param	oPnlGen - Panel Genérico
@param	aDados03 - Dados da Mensagem
@param	aHeader03 - Header da Mensagem
@param	aAuxCombo - Combo da Mensagem
@param	oGrpGen - Grupo de Campos Genérico
@param	lGrdMsgAtv - Grid de Mensagem Ativo
@param	cTextoGen - Texto Genérico
@param	oLblGen - Label Genérico
@param	cTextoBtn - Texto do botão
@param	oBtnCnc - Botao cancela
@param	oBtnCnf - Botao confirmar
@author  Varejo
@version P11.8
@since   17/12/14
@return  Nil
@sample
/*/
//-------------------------------------------------------------------

Function STWGLGdGe( oPnlGen, aDados03, aHeader03, aAuxCombo, ;
					oGrpGen,  lGrdMsgAtv, cTextoGen, oLblGen, ;
					cTextoBtn, oBtnCnc, oBtnCnf)

		STIGLGdGe( oPnlGen, aDados03, aHeader03, aAuxCombo, ;
					@oGrpGen,"aDados03[oBrwConten3:nAt]", .F.)
					
		lGrdMsgAtv:= .T.
		cTextoGen := STR0005 //"Mensagens"
		oLblGen:Refresh()
		
		cTextoBtn := STR0006 //"Cancelar" 
		oBtnCnc:cCaption := STR0006
		
		oBtnCnc:lVisible := .T.
		oBtnCnf:lVisible := .T.
		
		oBtnCnc:Refresh()
		oBtnCnf:Refresh()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STWGLBtCnf
Função de Finalização do Panel da Lista
@param  aListaRet - Itens de Lista Selecionados
@author  Varejo
@version P11.8
@since   17/12/14
@return  lRet  - Sucesso
@sample
/*/
//-------------------------------------------------------------------

Function STWGLBtCnf(aListaRet)

Local nItemLine   	:= 0				// Linha do item
Local oModelSale  	:= STDGPBModel() 	// Model de venda
Local lRet				:= .F.				// Retorno
Local nX				:= 0				//Contador 2
Local lItemFiscal    := .T.				//Item Fiscal
Local aItRet			:= {}				//Item de Retorno
Local nY				:= 0				//Contador 1


STIExchangePanel( { || STIPanItemRegister() } )

For nY := 1 to Len(aListaRet)
	aItRet := {}
	aItRet := aClone(aListaRet[nY, 05]) //Itens da Lista


	For nX := 1 to Len(aItRet)
		//Seta a quantidade 
		STBSetQuant( aItRet[nX, 04] )
		
		If oModelSale:GetModel("SL2DETAIL"):Length() == 1 .AND. Empty(STDGPBasket("SL2","L2_NUM",1))
			nItemLine := 1
		Else
			nItemLine := oModelSale:GetModel("SL2DETAIL"):Length()+1
		EndIf
		
		aItRet[nX, 05] := Substr(aItRet[nX, 05], 1,1 )
		If Empty(aItRet[nX, 05]) .OR. aItRet[nX, 05] <> "2"
			aItRet[nX, 05] := "3"
		EndIf
		
		lItemFiscal := aItRet[nX, 05]  == "2"
		
	
		// Dispara o registro de item
		STWItemReg(	nItemLine		,	aItRet[nX, 02]		, /*cCliCode	*/	,	/*cCliLoja	*/	,;
								/*nMoeda*/      	,	/*nDiscount*/   	, /*cTypeDesc */	, /*lAddItem*/  	,;
								/*cItemTES */		,	/*cCliType	*/	, lItemFiscal	,  /*nPrice*/		,;
								/*cTypeItem*/		,   /*lInfoCNPJ*/		, /*lRecovery*/		,  /*nSecItem */    ,;
								/*lServFinal*/		,   /*lProdBonif*/	, .T.,  aItRet[nX, 08], ;
								aItRet[nX, 01], aItRet[nX, 07], aItRet[nX, 05]	)
		
		//Atualiza interface
		STIGridCupRefresh()
	
	Next nX
Next nY

STIBtnActivate()

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWGLAtEnt
Função de Exibição dos Dados de Atores/Entregas da Lista
@param  lGrdMsgAtv - Grid de Mensagens Ativo
@param  nOpc = Opção de Seleção 1 - Entregas Programadas/ 2 - Atores
@param  cNumLst - Numero da Lista
@param  cTipoLst - Tipo de Lista
@param  oPnlGen - Panel do Grid
@param  aDados04 - Dados de Atores/Entregas
@param  oGrpGen - Grid Genérico
@param  cTextoGen - Texto Genérico
@param  cLblGen - Label Genérico
@param  cTextoBtn - Texto Botão
@param  oBtnCnc - Botão Cancelar/Fechar
@param  oBtnCnf - Botão Confirmar
@author  Varejo
@version P11.8
@since   17/12/14
@return  lOK  - Sucesso
@sample
/*/
//-------------------------------------------------------------------
Function STWGLAtEnt(lGrdMsgAtv, nOpc, cNumLst, cTipoLst, ;
			oPnlGen, aDados04, oGrpGen, cTextoGen, ;
			cLblGen, cTextoBtn, oBtnCnc, oBtnCnf )
			
Local cAlias := ""
Local aHeader01 			:= {} //Header di Grid de Mensagens /Entregas
Local aLstCmpNL			:= {"MEH_CODLIS","MEE_CODLIS"}							//Lista de campos para nao listar
Local aLstCmp 			:= {} //Lista de Campos
Local lOK 					:= .F.		

Do Case 
	Case nOpc == 1
		cAlias := "MEH"	//Entregas programada
		//Pesquisar se a lista alvo eh do tipo de entrega programada
		If cTipoLst # "3"
			STFMessage("STWGlAb", "STOP",STR0007) //"Este tipo de lista de presente não é de entrega programada!" 
			STFShowMessagem("STWGlAb")

			Return lOk
		Endif
		cTextoGen := STR0008 //"Entregas programadas"
	Case nOpc == 2
		cAlias := "MEE"	//Atores
		cTextoGen := STR0009 //"Atores"
	Otherwise
		Return lOK
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lista de campos e dados da GD  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == cAlias
	If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .AND. aScan(aLstCmpNL,{|x| x == Upper(AllTrim(SX3->X3_CAMPO))}) == 0 .AND. ;
		SX3->X3_CONTEXT # "V"	
	
		aAdd(aLstCmp,SX3->X3_CAMPO)
		//Cabecalho para a GD de lista
		aAdd(aHeader01,{SX3->X3_CAMPO,SX3->X3_PICTURE,AllTrim(X3Titulo()),SX3->X3_TAMANHO,SX3->X3_TIPO})		
	Endif
	SX3->(DbSkip())
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montar a lista de dados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lOk = STDGLRetD( "LJ845RETD", ;
				{xFilial(cAlias),cAlias,cAlias + "." + cAlias + "_CODLIS = '" + cNumLst + "'",aLstCmp,1,.T.},;
				@aDaDos04			)

If lOK 
	ConOut("Execução com sucesso - " + "LJ845RETD " + cAlias )
Else
	ConOut("Erro na execução - " + "LJ845RETD " + cAlias )
EndIf
				 
If !lOk .OR.  Len(aDados04) == 0
	lOk := .F.
Endif	

If lOk

	If lGrdMsgAtv
		//Ativo o Grid de Mensagens
		cTextoBtn := STR0011 //"Mensagens"
		oBtnCnc:cCaption := cTextoBtn
		oBtnCnc:lVisible := .T.
		oBtnCnf:lVisible := .F.
			
		oBtnCnc:Refresh()
		oBtnCnf:Refresh()
		lGrdMsgAtv := .F.

	EndIf	
	cLblGen:Refresh()
	
	//Monta o Grid de Atores/Entregas
	STIGLGd2Gen( oPnlGen, @aDados04, aHeader01, @oGrpGen,"aDados04[oBrwConten3:nAt]", .F.)
	
	oGrpGen:SetArray(aDados04)
	
	oGrpGen:Refresh()
	
EndIf

Return lOk

