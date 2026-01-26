#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#define ABERTA "A" 
#define FECHADA "F"
#define PENDENTE "P"
#define ENVIDADA "T" 
#define FALHA   "E"
#define RECEBIDA_NAO_LIDA "N"
#define RECEBIDA_LIDA "L"
#define Status "A=Aberta;F=Fechada;P=Pendente;T=Enviada;E=Falha;N=Recebido Não Lido;L=Recebido Lido"

Static aCampos := {}
Static nModo := 0
Static nAcesso := 1

/*/{Protheus.doc} PLPTU003
Tela de Sala de Chat de Auditores
@type function
@version 12.1.2410
@author zaar.goes
@since 07/04/2025
/*/
Function PLPTU003()
	Local cGridFilter := ""
	
	// abre a tela de filtro
	cGridFilter := PLPTU003FIL(.F.)
	setKey(VK_F2 ,{|| cGridFilter := PLPTU003FIL(.T.) })

	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()

	// Definição da tabela do Browse
	oBrowse:SetAlias('BIV')

	// Titulo da Browse
	oBrowse:SetDescription( 'Chat de Auditores' )
	oBrowse:SetFilterDefault( cGridFilter )

	oBrowse:addLegend("BIV_STAPRO == '" + ABERTA +"'", "WHITE", "Sala Aberta")
	oBrowse:addLegend("BIV_STAPRO == '" + FECHADA +"'", "BLACK", "Sala Fechada")
	oBrowse:addLegend("BIV_STAPRO == '" + PENDENTE +"'", "YELLOW", "Pendente de Envio")
	oBrowse:addLegend("BIV_STAPRO == '" + ENVIDADA +"'", "GREEN", "Mensagem Transmitida")
	oBrowse:addLegend("BIV_STAPRO == '" + FALHA +"'", "RED", "Falha na Transmissão")
	oBrowse:addLegend("BIV_STAPRO == '" + RECEBIDA_NAO_LIDA +"'", "ORANGE", "Resposta não lida")
	oBrowse:addLegend("BIV_STAPRO == '" + RECEBIDA_LIDA +"'", "BLUE", "Resposta lida")	

	// Ativação da Classe
	oBrowse:Activate()	
Return NIL

/*/{Protheus.doc} PLIMPARQC
Abertura de tela via tela de importação do arquvio de Cobrança ou Utilizaçã (antigo A500)
@type function
@version 12.1.2410
@author zaar.goes
@since 10/04/2025
@param aParams, array, Dados da Guia de combrança
/*/
Function PLIMPARQC(aParams)        
	Local Qxx	

	aCampos := aParams
	Qxx := PLSSALAB(aCampos)
	nModo := iif(!Qxx->(Eof()),MODEL_OPERATION_UPDATE,MODEL_OPERATION_INSERT)
	nAcesso := 0	

	if nModo = MODEL_OPERATION_UPDATE
		DbSelectArea("BIV")
		BIV->(DbSetOrder(1))
		DbSeek(FWxFilial('BIV') + Qxx->BIV_IDSALA)				
	endif

	FWExecView(iif(nModo == MODEL_OPERATION_INSERT, 'Chat de Auditores - Inclusão', 'Chat de Auditores - Alteração'),'PLPTU003',nModo)		

    If MsgYesNo("Deseja realizar a transmissão das mensagens pendentes?")
		PLENVCHAT()
	EndIf
	
Return

/*/{Protheus.doc} ModelDef
Definição da tela
@type function
@version  
@author zaar.goes
@since 02/04/2025
/*/
Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruBIV := FWFormStruct( 1, 'BIV' )
Local oStruBIU := FWFormStruct( 1, 'BIU' )
// Modelo de dados construído
Local oModel
	
// Cria o objeto do Modelo de Dados e insere a funçao de pós-validação
oModel := MPFormModel():New( 'PLPTU003', , {|oModelGrid| PLPTU003OK(oModelGrid) } )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'BIVMASTER', /*cOwner*/, oStruBIV )

// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'BIUDETAIL', 'BIVMASTER', oStruBIU, { |oModelGrid, nLine, cAction, cField| BIUPRE(oModelGrid, nLine, cAction, cField) } )

oStruBIU:AddField( ;
        AllTrim('') , ;               // [01] C Titulo do campo
        AllTrim('') , ;               // [02] C ToolTip do campo
        'BIU_LEGEND' , ;               // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        50 , ;                      // [05] N Tamanho do campo
        0 , ;                      // [06] N Decimal do campo
        NIL , ;                     // [07] B Code-block de validação do campo
        NIL , ;                     // [08] B Code-block de validação When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
        { || PLSLEG(oModel) }, ;           // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
        .T. )                      // [14] L Indica se o campo é virtual 

// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'BIUDETAIL', {	{ 'BIU_FILIAL'	, 'xFilial( "BIU" )'	},;
       									{ 'BIU_IDSALA'	, 'BIV_IDSALA' 		}},;
       				   BIU->( IndexKey( 1 ) ) )

// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( Fundesc() )

// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:GetModel( 'BIVMASTER' ):SetDescription( 'Motivos de Críticas' )

//BIU é obrigatoria
oModel:GetModel('BIUDETAIL'):SetOptional(.F.)

// Retorna o Modelo de dados
Return oModel

/*/{Protheus.doc} PLSLEG
Informa a legenda correta conforme BIU_STAPRO
@type function
@version  
@author zaar.goes
@since 07/04/2025
@return cRet, Cor da Legenda
/*/
Function PLSLEG(oModelGrid)
	Local cRet := "BR_BRANCO"
	Local oModel := oModelGrid:GetModel()
	Local nOperation := oModel:GetOperation()

	if nOperation != 3
		Do Case
			Case BIU->BIU_STAPRO == PENDENTE 
				cRet := "BR_AMARELO"
			Case BIU->BIU_STAPRO == ENVIDADA 
				cRet := "BR_VERDE"
			Case BIU->BIU_STAPRO == FALHA 
				cRet := "BR_VERMELHO"
			Case BIU->BIU_STAPRO == RECEBIDA_NAO_LIDA 
				cRet := "BR_LARANJA"
			Case BIU->BIU_STAPRO == RECEBIDA_LIDA 
				cRet := "BR_AZUL"
		EndCase
	endif
Return cRet

/*/{Protheus.doc} MenuDef
Define o menu de aplicação
@type function
@version  
@author zaar.goes
@since 4/2/2025
/*/
Static Function MenuDef()
private aRotina := {}

ADD OPTION aRotina Title 'Visualizar'				Action 'VIEWDEF.PLPTU003' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir' 					Action 'VIEWDEF.PLPTU003' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' 					Action 'VIEWDEF.PLPTU003' OPERATION 4 ACCESS 0
Add Option aRotina Title 'Filtro(F2)'  			    Action 'PLPTU003FIL(.T.)' OPERATION 1 Access 0
ADD OPTION aRotina Title 'Excluir' 					Action 'VIEWDEF.PLPTU003' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Imprimir' 				Action 'VIEWDEF.PLPTU003' OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Marcar como lida' 		Action "PLSATST('" + RECEBIDA_LIDA + "', '" + RECEBIDA_NAO_LIDA + "', 'lida')" OPERATION 1 ACCESS 0
ADD OPTION aRotina Title 'Marcar como não lida'		Action "PLSATST('" + RECEBIDA_NAO_LIDA + "','" + RECEBIDA_LIDA +"', 'não lida')" OPERATION 1 ACCESS 0
ADD OPTION aRotina Title 'Fechar sala' 				Action 'PLSFSALA()' OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Enviar"                   Action 'PLENVCHAT()'       OPERATION 3 ACCESS 0 

Return aRotina

/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@type function
@version  
@author zaar.goes
@since 02/04/2025
/*/
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'PLPTU003' )
// Cria as estruturas a serem usadas na View
Local oStruBIV := FWFormStruct( 2, 'BIV' )
Local oStruBIU := FWFormStruct( 2, 'BIU' )
// Interface de visualização construída
Local oView

 oStruBIU:AddField( ;                      // Ord. Tipo Desc.
        'BIU_LEGEND'                        , ;        // [01] C   Nome do Campo
        "00"                             , ;     // [02] C   Ordem
        AllTrim( ''    )        , ;     // [03] C   Titulo do campo
        AllTrim( '' )       , ;     // [04] C   Descricao do campo
        { 'Legenda' }           , ;     // [05] A   Array com Help
        'C'                             , ;     // [06] C   Tipo do campo
        '@BMP'               , ;     // [07] C   Picture
        NIL                             , ;     // [08] B   Bloco de Picture Var
        ''                             , ;     // [09] C   Consulta F3
        .T.                             , ;     // [10] L   Indica se o campo é alteravel
        NIL                             , ;     // [11] C   Pasta do campo
        NIL                             , ;     // [12] C   Agrupamento do campo
        NIL                                        , ;     // [13] A   Lista de valores permitido do campo (Combo)
        NIL                             , ;     // [14] N   Tamanho maximo da maior opção do combo
        NIL                             , ;     // [15] C   Inicializador de Browse
        .T.                             , ;     // [16] L   Indica se o campo é virtual
        NIL                             , ;     // [17] C   Picture Variavel
        NIL                             )       // [18] L   Indica pulo de linha após o campo 
 

oModel:SetPrimaryKey( { "BIV_FILIAL", "BIV_IDSALA" } )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_BIV', oStruBIV, 'BIVMASTER' )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_BIU', oStruBIU, 'BIUDETAIL' )

//Informo que o campo é incremental
//oView:AddIncrementField( 'VIEW_BIU', 'BIU_IDCHAT' )

oView:AddUserButton("Anexo", "CLIPS", {|| PLSANEXO(oModel)  } )//"Anexos"


//Nao deixa duplicar o campo BIU_IDCHAT
oModel:GetModel( 'BIUDETAIL' ):SetUniqueLine( { 'BIU_IDSALA' ,'BIU_IDCHAT'} )

//Não permite edição nas linhas do grid
//oModel:GetModel( 'BIUDETAIL' ):SetNoUpdateLine( .T. )
//oModel:GetModel( 'BIUDETAIL' ):SetNoDeleteLine( .T. )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_BIV', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_BIU', 'INFERIOR' )

oView:SetAfterViewActivate({|| PLCHATAFTER()})

// Retorna o objeto de View criado
Return oView

/*/{Protheus.doc} PLCHATAFTER
Atualização dos dados da guia de cobrança após a abertura da tela
@type function
@version 12.1.2410
@author zaar.goes
@since 10/04/2025
/*/
Function PLCHATAFTER()	
	Local oView
	If !Empty(aCampos)
		if(nModo == MODEL_OPERATION_INSERT)
			// Preenche os campos
			FwFldPut("BIV_ORGMCB", aCampos[1])
			FwFldPut("BIV_NRDOC1", aCampos[2])
			FwFldPut("BIV_NRDOC2", aCampos[3])
			FwFldPut("BIV_LOTPRT", aCampos[4])
			FwFldPut("BIV_GUIPRT", aCampos[5])
			FwFldPut("BIV_GUIOPE", aCampos[6])
			FwFldPut("BIU_DESMSG", aCampos[1])					
		endif		
		aCampos := {}

		// RECUPERA A VIEW ATIVA E ATUALIZA (NECESSÁRIO PARA EXIBIÇÃO DO CONTEÚDO)
        oView := FwViewActive()
        oView:Refresh()		
	EndIf	 
Return .T.

Function PLSLIMITE(cTexto)
	If Len(AllTrim(cTexto)) > 2000
		MsgStop("Atenção o Limite para este Campo é de 2000 caracteres!" + chr(10);
			+ "Revise a mensagem para que ela não seja cortada na transmissão!")       
	Endif		
Return .T.

/*/{Protheus.doc} PLSAUDTOR
Busca dados do auditor
@type function
@version  
@author zaar.goes
@since 02/04/2025
@param cCampo, character, campo a ser buscado do auditor
@return char, valor do campo
/*/
Function PLSAUDTOR(cCampo)
	Local cRet := ""
	BX4->(DBSetOrder(1)) 
		
	cIDCHAT := xFilial("BX4") + RetCodUsr() + PLSINTPAD()
		
	If BX4->(DBSeek(cIDCHAT))
		cRet := &("BX4->"+cCampo)
	endIf
Return cRet

/*/{Protheus.doc} PLSBGCOB
Busca dados da Guia de Cobrança
@type function
@version 12.1.2410
@author zaar.goes
@since 02/04/2025
/*/
Function PLSBGCOB(lReceb,cORGMCB,cDESTCB,cNRDOC1,cNRDOC2,cLOTPRT,cGUIPRT,cGUIOPE)
    Local cSql
	Local lPLSR506 	:= existBlock("PLSR506")	
	Default lReceb  := .F.
	Default cORGMCB:= ""
	Default cDESTCB:= ""
	Default cNRDOC1:= ""
	Default cNRDOC2:= ""
	Default cLOTPRT:= ""
	Default cGUIPRT:= ""
	Default cGUIOPE:= ""
	
	if (iif(lReceb,cORGMCB != plsIntPad(),  M->BIV_ORGMCB != PLSINTPAD()))
		cSql := "select b.BRJ_OPEORI, b.BRJ_DOCFI1, b.BRJ_DOCFI2, b3.BE4_LOTEDI, b3.BE4_NUMIMP, b3.BE4_NUMGOI,"
		cSql += "       b3.BE4_NMAUDI NOME1, b3.BE4_RMAUDI COD1, b3.BE4_UMAUDI UF1, b3.BE4_NEAUDI NOME2, b3.BE4_REAUDI COD2, b3.BE4_UEAUDI UF2"
		cSql += " from " +  RetSqlName("BRJ") + " b "
		cSql += " inner join " +  RetSqlName("BCI") + " b2 on (b2.BCI_LOTEDI = 'BRJ|' + b.BRJ_CODIGO and b2.D_E_L_E_T_ = ' ') "
		cSql += " inner join " + RetSqlName("BE4") + " b3 on (b3.BE4_CODPEG  = b2.BCI_CODPEG and b3.D_E_L_E_T_ = ' ')"
		cSql += " where b.BRJ_OPEORI = '" +  iif(!lReceb,M->BIV_ORGMCB,cORGMCB) + "'"
		cSql += "   and b.BRJ_DOCFI1 = '" +  iif(!lReceb,M->BIV_NRDOC1,cNRDOC1) + "'"
		cSql += "   and b.BRJ_DOCFI2 = '" +  iif(!lReceb,M->BIV_NRDOC2,cNRDOC2) + "'"
		cSql += "   and b3.BE4_LOTEDI = '" + iif(!lReceb,M->BIV_LOTPRT,cLOTPRT) + "'"
		cSql += "   and b3.BE4_NUMIMP = '" + iif(!lReceb,M->BIV_GUIPRT,cGUIPRT) + "'"
		cSql += "   and b3.BE4_NUMGOI = '" + iif(!lReceb,M->BIV_GUIOPE,cGUIOPE) + "'"
		cSql += "   and b.D_E_L_E_T_ = ' '"
	else		
		cSql := " select b3.BE4_NMAUDI NOME1, b3.BE4_RMAUDI COD1, b3.BE4_UMAUDI UF1, b3.BE4_NEAUDI NOME2, b3.BE4_REAUDI COD2, b3.BE4_UEAUDI UF2"
		cSql += " from " +  RetSqlName("BTO") + " b "
		cSql += " inner join " +  RetSqlName("BCI") + " b2 on (b2.BCI_LOTEDI = 'BTO|' + b.BTO_NUMERO and b2.D_E_L_E_T_ = ' ') "
		cSql += " inner join " + RetSqlName("BE4") + " b3 on (b3.BE4_CODPEG  = b2.BCI_CODPEG and b3.D_E_L_E_T_ = ' ')"
		cSql += " where b.BTO_OPEORI = '" + iif(!lReceb,M->BIV_DESTCB,cDESTCB)+ "'"
		cSql += iif(!lPLSR506, " and b.BTO_PREFIX + b.BTO_NUMTIT = '" + iif(!lReceb,M->BIV_NRDOC1,cNRDOC1) + "'",'')
		cSql += "   and b3.BE4_CODPEG = '" + iif(!lReceb,M->BIV_LOTPRT,cLOTPRT) + "'"
		cSql += "   and (b3.BE4_NUMIMP = '" + iif(!lReceb,M->BIV_GUIPRT,cGUIPRT) + "' or trim(b3.BE4_NUMIMP) = '')"
		cSql += "   and b3.BE4_CODLDP + BE4_CODPEG + BE4_NUMERO = '" + iif(!lReceb,M->BIV_GUIOPE,cGUIOPE) + "'"
		cSql += "   and b.D_E_L_E_T_ = ' '"
	endif

Return PlsQuery(ChangeQuery(cSql),'Qxx')

/*/{Protheus.doc} PLSSALAB
Procura sala de chat
@type function
@version 12.1.2410
@author zaar.goes
@since 02/04/2025
/*/
Function PLSSALAB(aCampos)
	local cSql := "select BIV_IDSALA"		  
	      cSql += " from " +  RetSqlName("BIV") + " b "		  
		  cSql += " where b.BIV_ORGMCB = '" + aCampos[1] + "'"
		  cSql += "   and b.BIV_NRDOC1 = '" + aCampos[2] + "'"
		  cSql += "   and b.BIV_NRDOC2 = '" + aCampos[3] + "'"
		  cSql += "   and b.BIV_LOTPRT = '" + aCampos[4] + "'"
		  cSql += "   and b.BIV_GUIPRT = '" + aCampos[5] + "'"
		  cSql += "   and b.BIV_GUIOPE = '" + aCampos[6] + "'"
		  cSql += "   and b.D_E_L_E_T_ = ' '"
Return PlsQuery(cSql,'Qxx')

/*/{Protheus.doc} PLSAUDT
Busca dados do auditor da guia
@type function
@version 12.1.2410
@author zaar.goes
@since 02/04/2025
@param cCampo, character, Campo buscado
@return character, Dado do auditor
/*/
Function PLSAUDT(cCampo)
	Local Qxx
	Local cRet := ""

	if M->BIV_ORGMCB != PLSINTPAD()
		Qxx := PLSBGCOB()

		if !Qxx->(Eof())
			cRet := AllTrim(&("Qxx->" + cCampo))
		end if
	endif

	if empty(cRet)
		Qxx := PLSAMSG(SubStr(cCampo, Len(cCampo), 1))
		if !Qxx->(Eof())
			cRet := AllTrim(&("Qxx->" + cCampo))
		endif
	EndIf
Return cRet

/*/{Protheus.doc} PLSAMSG
Retorna último remetente das mensagens
@type function
@version 12.1.2410
@author zaar.goes
@since 10/04/2025
@param cCodigo, character, Código do tipo de auditor 1-Médico 2-Enfermeiro
@return object, Query com os dados selecionados
/*/
Static Function PLSAMSG(cCodigo)
	Local cSQL := "select max(b.BIU_IDCHAT) IDCHAT,"
	      cSQL += "       max(b.BIU_NOMEOR) NOME" + cCodigo + ","
		  cSQL += "       max(b.BIU_CONPOR) COD" + cCodigo + ","
		  cSQL += "	      max(BIU_UFCPOR) UF" + cCodigo
		  cSQL += " from " +  RetSqlName("BIU") + " b "
		  cSQL += " where b.BIU_IDSALA = '" + M->BIV_IDSALA + "'"
		  cSQL += "   and b.BIU_TADTOR = " + cCodigo
		  cSQL += "   and b.BIU_ORGMSG <> '" +  PLSINTPAD() + "'"
Return PlsQuery(cSql,'Qxx')

/*/{Protheus.doc} PLPTU003OK
Valida as inforamções da Guia de Cobrança antes da gravação
@type function
@version  
@author zaar.goes
@since 4/2/2025
@return lRet, booleano
/*/
Function PLPTU003OK(oModelGrid)
	local lRet := .T.	
	Local Qxx
	Local oModel := oModelGrid:GetModel()
	Local nOperation := oModel:GetOperation()

		if nOperation == 3 .or. M->BIV_STAPRO == "A"
			if M->BIV_ORGMCB <>  PLSINTPAD() .and. M->BIV_DESTCB <>  PLSINTPAD()
				Help( ,, 'Atenção',,"Origem ou Destino inválido.", 1, 0)
				Return .F.
			endif
			
			Qxx := PLSBGCOB()
			
			lRet := !Qxx->( Eof())

			if !lRet
				Help( ,, 'Atenção',,"Dados da Fatura de Cobrança não encontrados!", 1, 0)
				Return lRet
			endif

			Qxx := PLSSALAB({M->BIV_ORGMCB,;
							M->BIV_NRDOC1,;
							M->BIV_NRDOC2,;
							M->BIV_LOTPRT,;
							M->BIV_GUIPRT,;
							M->BIV_GUIOPE})
			lRet := Qxx->( Eof())

			if !lRet
				Help( ,, 'Atenção',,"Já existe sala aberta para esta Guia de Cobrança!", 1, 0)
				Return .F.
			endif			
		endif

		if nOperation == 5 
			if !(M->BIV_STAPRO $ "AP")
				Help( ,, 'Atenção',,"Já existe mensagens recebidas/transmitidas para esta Guia de Cobrança!" + chr(10) + "Exclusão não permitida.", 1, 0)
				lRet := .F.
			endif
		else
			PLSTRANSM()	
		endif	
Return lRet


/*/{Protheus.doc} PLSTRANSM
Processo de transmissão da mensagem
@type function
@version 12.1.2410
@author zaar.goes
@since 10/04/2025
/*/
Function PLSTRANSM()
	Local oModel := FWModelActive()
	Local oModelBIU := oModel:GetModel( 'BIUDETAIL' )
	Local nI := 0
	Local aSaveLine := FWSaveRows()
	local cArquivo := ""
	Local cIdSala := ""
	Local cIdChat := ""
	Local nCodTrans := ""

	For nI := 1 To oModelBIU:Length()
		oModelBIU:GoLine( nI )			
		cIdSala := oModel:GetValue('BIUDETAIL', 'BIU_IDSALA')
		cIdChat := oModel:GetValue('BIUDETAIL', 'BIU_IDCHAT')
		nCodTrans := val(oModel:GetValue('BIUDETAIL', 'BIU_CODCTR'))

		if oModel:GetValue( 'BIUDETAIL', 'BIU_STAPRO' ) == RECEBIDA_NAO_LIDA
			PLSTATUS(CIdSala + cIdChat, RECEBIDA_LIDA)
		endif

		if oModel:GetValue( 'BIUDETAIL', 'BIU_STAPRO' ) == PENDENTE
				
			if empty(oModel:GetValue( 'BIUDETAIL', 'BIU_ARQANX' )) .and. nI == oModelBIU:Length()
				cArquivo := PLSIMPANX(cIdSala + cIdChat, nCodTrans)
				if !empty(cArquivo)
					oModel:SetValue( 'BIUDETAIL', 'BIU_ARQANX', cArquivo )
				endif
			endif
				
			oModel:SetValue( 'BIUDETAIL', 'BIU_STAPRO', ABERTA )
				
		Endif

		if oModel:GetValue( 'BIUDETAIL', 'BIU_STAPRO' ) == ABERTA 
			oModel:SetValue( 'BIUDETAIL', 'BIU_STAPRO', PENDENTE )
		endif
		
		if nI == oModelBIU:Length()
			oModel:SetValue( 'BIVMASTER', 'BIV_STAPRO', oModel:GetValue( 'BIUDETAIL', 'BIU_STAPRO' ))
		endif
		FWRestRows( aSaveLine )
	Next			
return

/*/{Protheus.doc} PLSTATUS
Atualiza o status da mensagem
@type function
@version 12.1.2410
@author zaar.goes
@since 10/04/2025
@param cChave, character, Chave da mensagem
@param cStatus, character, Status a ser alterado
/*/
Static Function PLSTATUS(cChave, cStatus)
	DbSelectArea("BIU")
	BIU->(DbSetOrder(1))
	If BIU->(DbSeek(FWxFilial('BIU') + cChave))
		Reclock("BIU", .F.)
			BIU->BIU_STAPRO := cStatus			
		BIU->(MsUnlock())
	EndIf	
return

/*/{Protheus.doc} BIUPRE
Validações de alteração/exclusão das mensagens
@type function
@version 12.1.2410
@author zaar.goes
@since 10/04/2025
@param oModelGrid, object, Grid
@param nLinha, numeric, linha alterada
@param cAcao, character, Ação de tela
@param cCampo, character, Campo
@return boolean, Retorno da validação
/*/
Static Function BIUPRE( oModelGrid, nLinha, cAcao, cCampo )
	Local lRet := .T.
	Local oModel := oModelGrid:GetModel()
	Local nOperation := oModel:GetOperation()
	Local cStatus := oModel:GetValue( 'BIUDETAIL', 'BIU_STAPRO' )
		
	// Valida se pode ou não editar uma linha do Grid
	If cAcao == 'DELETE' .AND. nOperation == 4 .AND. !(cStatus $ "AP")
		lRet := .F.
		Help( ,, 'Help',, 'Não é permitido apagar mensagens transmitidas', 1, 0 )
	EndIf

	if cAcao == 'SETVALUE' .AND. nOperation == 4 .AND. !(cStatus $ "AP")
		lRet := .F.
		Help( ,, 'Help',, 'Não é permitido alterar mensagens transmitidas', 1, 0 )
	EndIf
Return lRet

/*/{Protheus.doc} PLSNMOPER
Nome da operadora
@type function
@version 12.1.2410
@author zaar.goes
@since 02/04/2025
@param cUnimed, character, Código da Unimed
@return character, nome do operadora
/*/
Function PLSNMOPER(cUnimed)
    Local cRetorno := ""
    if cUnimed != ""
		DBSelectArea("BA0")
		BA0->(DBSetOrder(1))
		If BA0->(MsSeek(xFilial("BA0") + cUnimed))
			cRetorno := BA0->BA0_NOMINT
		EndIf
	endIf
Return cRetorno

/*/{Protheus.doc} PLStatBox
Lista de status
@type function
@version 12.1.2410
@author zaar.goes
@since 02/04/2025
@return character, lista de status
/*/
Function PLStatBox()
	Local cRet := Status
Return cRet

/*/{Protheus.doc} PLSIDSALA
Próximo sequencial do IdSala
@type function
@version 12.1.2410
@author zaar.goes
@since 02/04/2025
@return numeric, sequencial
/*/
Function PLSIDSALA()
    Local nRet := 0
	Local cBanco := Upper(TCGetDB())

	cSql := "select coalesce(max(cast(BIV_IDSALA as integer)), 0) + 1 AS IDSALA from" + RetSqlName("BIV")

	PlsQuery(cSql,'Qxx')

	If !Qxx->( Eof() )		
		nRet := IIF(ValType(Qxx->IDSALA) == "N",StrZero(Qxx->IDSALA,20),StrZero(VAL(Qxx->IDSALA),20))
	Endif

Return nRet

Function PLSNEXTVAL(cTabela, cCampo)
    Local cBanco := Upper(TCGetDB())
    Local nRet := 0

	cSql := "select coalesce(max(cast("+ cCampo +" as integer)), 0) + 1 AS CAMPO from" + RetSqlName(cTabela)

	PlsQuery(cSql,'Qxx')

	If !Qxx->( Eof() )		
		nRet := IIF(ValType(Qxx->CAMPO) == "N",StrZero(Qxx->CAMPO,10),StrZero(VAL(Qxx->CAMPO),10))
	Endif

Return nRet

/*/{Protheus.doc} PLSIDCHAT
Próximo sequencial do ID Chat da mensagem
@type function
@version 12.1.2410	 
@author zaar.goes
@since 10/11/2025
@param cIdSala, character, ID Sala
@return numeric, sequencial
/*/
Function PLSIDCHAT(cIdSala)
	Local cBanco := Upper(TCGetDB())
    Local nRet := 0

	cSql := "select coalesce(max(cast(BIU_IDCHAT as integer)), 0) + 1 AS IDCHAT from" + RetSqlName("BIU")
	cSql += " where BIU_IDSALA = '" + iif(Valtype(cIdSala) == "N", str(cIdSala), cIdSala) + "'"

	PlsQuery(cSql,'Qxx')

	If !Qxx->( Eof() )		
		nRet := IIF(ValType(Qxx->IDCHAT) == "N",StrZero(Qxx->IDCHAT,20),StrZero(VAL(Qxx->IDCHAT),20))
		
	Endif
Return nRet

/*/{Protheus.doc} PLSSEQCONT
Próximo sequencial do controle de transação
@type function
@version 12.1.2410
@author zaar.goes
@since 10/04/2025
@return numeric, sequencial
/*/
Function PLSSEQCONT()
	Local cBanco := Upper(TCGetDB())
    Local nRet := 0

	cSql := "select coalesce(max(cast(BIU_CODCTR as integer)), 0) + 1 AS SEQCONT from" + RetSqlName("BIU")
	cSql += " where BIU_ORGMSG = '" +  PLSINTPAD() + "'"
	
	PlsQuery(cSql,'Qxx')

	If !Qxx->( Eof() )		
		nRet := IIF(ValType(Qxx->SEQCONT) == "N",StrZero(Qxx->SEQCONT,20),StrZero(VAL(Qxx->SEQCONT),20))

	Endif
	
Return nRet

/*/{Protheus.doc} PLPTU003FIL
Filtros de tela
@type function
@version 12.1.2410
@author zaar.goes
@since 02/04/2025
@param lF2, logical, Origem do acionamento da função
@return character, Filtro
/*/
function PLPTU003FIL(lF2)
	local cStatus	:= space(1)
	Local aStatus := {"0=Todos Ativos","A=Aberta","F=Fechada","P=Pendente","T=Enviada","E=Fallha","N=Recebido Não Lido","L=Recebido Lido" }
	local cFiltro := ""
	local aPergs  := {}
	local aFilter := {}

	default lF2 := .f.

	aAdd( aPergs,{ 2, "Status:"		 	, 	cStatus		, aStatus,100,/*'.T.'*/,.f. } )
	aAdd( aPergs,{ 1, "A partir de:"	, 	dDataBase	, "", "", ""		, "", 50, .f.})
	aAdd( aPergs,{ 1, "Unimed Origem:"	, 	"    "	, "", "", ""		, "", 50, .f.})
	aAdd( aPergs,{ 1, "Unimed Destino:"	, 	"    "	, "", "", ""		, "", 50, .f.})

	cFiltro += "@BIV_FILIAL = '"+ BIV->(xFilial("BIV"))+ "' AND D_E_L_E_T_ = ' ' "

	// tela para selecionar os filtros
	if (paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSP500X',/*lCanSave*/.T.,/*lUserSave*/.T. ) )

		if (!empty(aFilter[1]) .and. aFilter[1] == "0")
			cFiltro += "AND BIV_STAPRO <> 'F' "
		else
			cFiltro += " AND BIV_STAPRO = '" + aFilter[1] + "' "
		endif

		if (!empty(aFilter[2]))
			cFiltro += " AND BIV_DATMSG >= '" + DtoS(aFilter[2]) + "' "
		endif

		if (!empty(aFilter[3]))
			cFiltro += " AND BIV_ORGMCB = '" + aFilter[3] + "' "
		endif

		if (!empty(aFilter[4]))
			cFiltro += " AND BIV_DESTCB = '" + aFilter[4] + "' "
		endif

	endif

	if (lF2)
		If Valtype(oBrowse) == "O"
			oBrowse:SetFilterDefault(cFiltro)
			oBrowse:Refresh(.T.)
		EndIf
	endif

return cFiltro

/*/{Protheus.doc} PLSIMPANX
Anexo da mensagem
@type function
@version 12.1.2410
@author zaar.goes
@since 02/04/2025
@param cIDCHAT, character, Chave da mensagem
@param nCodTrans, numeric, Código de transação
@return character, Nome do arquivo anexado
/*/
Static Function PLSIMPANX(cIDCHAT, nCodTrans)
	Local cArquivo := ""
    //Se a pergunta for confirmada
	If MsgYesNo("Deseja anexar um arquivo ZIP a esta mensagem?", "Atencao")
        cArquivo := fRunProc(cIDCHAT, nCodTrans)
    EndIf
Return cArquivo

/*/{Protheus.doc} fBuscaArquivo
Processo para pesquisa do arquivo na máquina
@type function
@version 12.1.2410
@author zaar.goes
@since 10/04/2025
@return character, caminho do arquivo
/*/
Static Function fBuscaArquivo()
    Local cResultado := ""
    Local cComando   := ""
    Local cDir       := GetTempPath()
    Local cNomBat    := "BuscaArquivo.bat"
    Local cArquivo   := "resultado.txt"
    Default cMascara := "Arquivos ZIP (*.zip)|*.ZIP"
     
    //Se o resultado já existir, exclui
    If File(cDir + cArquivo)
        FErase(cDir + cArquivo)
    EndIf
     
    //Monta o comando para abrir a tela de seleção do windows
    cComando += '@echo off' + CRLF
    cComando += 'setlocal' + CRLF
    cComando += 'set ps_cmd=powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.OpenFileDialog;$f.Filter=' + "'"+cMascara+"'" + ';$f.showHelp=$true;$f.ShowDialog()|Out-Null;$f.FileName"' + CRLF
    cComando += '' + CRLF
    cComando += 'for /f "delims=" %%I in (' + "'%ps_cmd%'" + ') do set "filename=%%I"' + CRLF
    cComando += '' + CRLF
    cComando += 'if defined filename (' + CRLF
    cComando += '    echo %filename% > '+cArquivo + CRLF
    cComando += ')' + CRLF
     
    //Gravando em um .bat o comando
    MemoWrite(cDir + cNomBat, cComando)
     
    //Executando o comando através do .bat
    WaitRun(cDir+cNomBat, 2)
     
    //Se existe o arquivo
    If File(cDir + cArquivo)
     
        //Pegando o resultado que o usuário escolheu
        cResultado := MemoRead(cDir + cArquivo)
    EndIf
Return cResultado

/*/{Protheus.doc} fRunProc
Salva o anexo na base de conhecimento
@type function
@version 12.1.2410
@author zaar.goes
@since 02/04/2025
@param cIDCHAT, character, Chave da mensagem
@param nCodTrans, numeric, código da transação
@return character, nome do anexo salvo
/*/
Static Function fRunProc(cIDCHAT, nCodTrans)   
    Local cArqAtu := ""

	cArqAtu :=upper(AllTrim(StrTran(fBuscaArquivo(), Chr(13) + Chr(10), "")))

	//if cArqAtu != ""					
		cArquivo := iif(cArqAtu != "", PLIncluiBase(cIDCHAT, nCodTrans, cArqAtu, ""), "")
	//endif
Return cArquivo

Function PLIncluiBase(cIDCHAT, nCodTrans, cArqAtu, cArquivo)	
	Local cProxObj
	Local cPathBco := ""
	Local cAlias := "BIU"
	Local lCopy := .F.

	iif(MsMultDir(), cPathBco := MsRetPath(), cPathBco := MsDocPath())
	cArquivo :=  AllTrim(str(nCodTrans) + "_" + iif(cArquivo = "", ExtractFile(cArqAtu), cArquivo))

	//Faz a cópia da origem, para a pasta do banco de conhecimento
	lCopy := __CopyFile(cArqAtu , cPathBco + "\" + cArquivo)
	iif(!lCopy,;
		MsgAlert("Erro ao importar: " + cPathBco + cArquivo, "Atencao!"),;
		cArquivo = "")

	if lCopy		
		//Pega o próximo registro da ACB
		DbSelectArea("ACB")
		ACB->(DbSetOrder(1))
		//ACB->(DbGoBottom())	
		//ACB->(DbSetOrder(2))
			
		//Se não tiver o arquivo na ACB, irá incluir
		If !ACB->(DbSeek(FWxFilial('ACB') + cArquivo))
			cProxObj := PLSNEXTVAL( "ACB", "ACB_CODOBJ" )
			Reclock("ACB", .T.)
				ACB->ACB_FILIAL := FWxFilial('ACB')
				ACB->ACB_CODOBJ := cProxObj
				ACB->ACB_OBJETO := cArquivo
				ACB->ACB_DESCRI := cArquivo
			ACB->(MsUnlock())	
		endif
				
		//Se não existir na tabela de vinculos, irá criar
		DbSelectArea("AC9")
		AC9->(DbSetOrder(1))
		If ! AC9->(DbSeek(FWxFilial('AC9') + cProxObj + cIDCHAT))
			Reclock("AC9", .T.)
				AC9->AC9_FILIAL := FWxFilial('AC9')
				AC9->AC9_ENTIDA := cAlias
				AC9->AC9_CODENT := xFilial(cAlias) + cIDCHAT
				AC9->AC9_CODOBJ := cProxObj
			AC9->(MsUnlock())
		EndIf
	endif
return cArquivo

/*/{Protheus.doc} PLSANEXO
Chamada da base de conhecimento para abertura do anexo
@type function
@version 12.1.2410
@author zaar.goes
@since 02/04/2025
@param oModel, object, Tela
@return logical, situação do retorno
/*/
Function PLSANEXO(oModel) 
Local oBIU		:= oModel:getmodel("BIUDETAIL")
Local cIdSala := oBIU:GetValue('BIU_IDSALA')
Local cIdChat := oBIU:GetValue('BIU_IDCHAT')
Local aArea		:= getArea()
Private aRotina 		:= {}
PRIVATE cCadastro   	:= FunDesc()

aRotina := {{"Anexo",'MsDocument',0/*permite exclusao do registro*/,1/*visualizar arquivo*/},{"Inclusão Rápida",'PLSDOcs',0,3}}//"Anexo"##"Inclusão Rápida"

BIU->(DbSelectArea("BIU"))
BIU->(DbSetOrder(1))	

If BIU->(MsSeek(xFilial("BIU") + cIdSala+cIdChat )) //Posiciona no registro do Candidato
	MsDocument( "BIU", BIU->( RecNo() ), 2 )
Else
	MsgAlert( "Opção não disponível. Na inclusão da mensagem, ao finalizar o cadastro será apresentada a opção de adicionar o anexo", "Atenção")
Endif	


RestArea(aArea)

Return .T.

/*/{Protheus.doc} PLSATST
Alteração do status da tela
@type function
@version 12.1.2410
@author zaar.goes
@since 10/11/2025
@param cStatus, character, Novo Status
@param cNStatus, character, Status Anterior
@param cMsg, character, Descrição do novo status
/*/
Function PLSATST(cStatus, cNStatus, cMsg)	
	if(BIV->BIV_STAPRO == cNStatus)
		if(MsgYesNo("Confirma marcar a sala como " + cMsg +"?"))
			Reclock("BIV", .F.)
				BIV->BIV_STAPRO := cStatus
			BIV->(MsUnlock())
		endif
	else
		MsgAlert( "Status da sala não permite a alteração para " + cMsg, "Atenção")
	endif
return

/*/{Protheus.doc} PLSFSALA
Alterar status da sala para fechado
@type function
@version 12.1.2410
@author zaar.goes
@since 10/04/2025
/*/
Function PLSFSALA()
	if(MsgYesNo("Deseja fechar a sala para arquivar?" + chr(10) + "Ela poderá ser reaberta se receber ou enviar nova mensagem."))
		Reclock("BIV", .F.)
			BIV->BIV_STAPRO := FECHADA
		BIV->(MsUnlock())
	endif
return

Function PLENVCHAT()
	Local cSql   := ""
	Local aRet   := {}
	Local nI     := 0

	cSql := "SELECT R_E_C_N_O_ REC "
	cSql += " FROM " + RetSqlName("BIU") + " "
	cSql += " WHERE "
	cSql += " BIU_FILIAL = '" + xFilial("BIU") + "' "
	cSql += " AND BIU_IDSALA = '"+ BIV->BIV_IDSALA +"'"
	cSql += " AND BIU_STAPRO = 'P' "
	cSql += " AND D_E_L_E_T_ = ' '  "
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBIU",.F.,.T.)

	DO While !TRBBIU->(Eof())
		AADD(aRet,{TRBBIU->REC})
		TRBBIU->(dbSkip())
	EndDo
	
	IIF(SELECT("TRBBIU") > 0, TRBBIU->(dbCloseArea()),"")

	For nI:=1 to Len(aRet)
		BIU->(DBGOTO(aRet[nI][1]))
		fwMsgRun(nil, {|| totvs.protheus.health.plan.unimed.chatauditSendAudit()}, '', " Enviando Mensagem " )
	Next nI

    If Len(aRet) == 0
		MsgAlert("Não há mensagens pendentes para envio!", "Atenção")
	Endif
	
Return .T.	
