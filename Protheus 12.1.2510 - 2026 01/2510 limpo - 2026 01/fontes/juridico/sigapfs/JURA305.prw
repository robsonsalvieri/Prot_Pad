#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'JURA305.CH'

//------------------------------------------------------------------------------
/* /{Protheus.doc} JURA305(lAutomato)
Emissão de Ocorrências do jurídico

@param lAutomato - Indica se esta sendo executado pela automação
@return .T.

@since 26/10/2022
/*/
//------------------------------------------------------------------------------
Function JURA305(lAutomato)

Local lVldUser       := Iif(FindFunction("JurVldUxP"), JurVldUxP(), .T.) // Valida o participante relacionado ao usuário logado
Local cConfig        := SuperGetMv('MV_JCFGOCO',, '')

Private lChkTab      := .T.
Private lChkPenden   := .F.
Private lChkTdCont   := .F.
Default lAutomato    := .F.

	If lVldUser
		If !Empty(cConfig)

			If !lAutomato
				J305TelaEm() // Cria a tela de emissão de ocorrencias
			EndIf

		Else
			MsgInfo(STR0001) // "Para utilizar a funcionalidade de Faturamento por ocorrencias é necessário realizar configuração prévia!"
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J305MsgDt(cMsg)
Função para exibir a mensagem de erro da validação dos campos de data

@Param  cMsg - Mensagem de aviso de falha
@Return .F.

@since 26/10/2022
@Obs     Só entra nessa função quando falha a validação de data
/*/
//-------------------------------------------------------------------
Static Function J305MsgDt(cMsg)
	ApMsgStop( cMsg )
Return (.F.)

//-------------------------------------------------------------------
/*/{Protheus.doc} J305TelaEm()
Cria a tela de Emissão de ocorrencias do juridico para realizar

@Return lRet - Boolean (.T./.F.)

@since 26/10/2022
/*/
//-------------------------------------------------------------------
Function J305TelaEm()

Local oPnl           := Nil
Local oDlg           := Nil
Local oMainColl      := Nil
Local oLayer         := FWLayer():New()
Local bConfir        := {||}
Local cLojaAuto      := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local oSocio         := Nil
Local oMoeda         := Nil
Local oEscrit        := Nil
Local oOcorre        := Nil
Local oTipoTS        := Nil
Local oGetGrup       := Nil
Local oLkUpSA1       := __FWLookUp('SA1NUH')
Local lOk            := .F.

Private cGetCaso     := Space( 240 )
Private cGetClie     := Criavar( 'A1_COD'    , .F. )
Private cContratos   := Space( 250 )
Private cEscrit      := Criavar( 'NS7_COD'   , .F. )
Private cOcorre      := Criavar( 'OI2_COD'   , .F. )
Private cGetGrup     := Criavar( 'ACY_GRPVEN', .F. )
Private cGetLoja     := Criavar( 'A1_LOJA'   , .F. )
Private cMoeda       := Criavar( 'CTO_MOEDA' , .F. )
Private cSocio       := Criavar( 'RD0_SIGLA' , .F. )
Private cTipoTS      := Criavar( 'NRD_COD'   , .F. )
Private oGetClie     := Nil
Private oGetLoja     := Nil
Private oChkTdCont   := Nil
Private oChkTdCaso   := Nil
Private oContratos   := Nil
Private oDtRefIni    := Nil
Private oDtRefFim    := Nil
Private dDtRefIni    := CToD( '01/01/1900' )
Private dDtRefFim    := dDataBase
Private cSituSoc     := STR0002 //"Todos"
Private cExcSoc      := Space( 230 )

	oLkUpSA1:SetRetFunc( { |x,y| LKRetSA1(x, y, @cGetClie, @cGetLoja ) } )

	DEFINE MSDIALOG oDlg TITLE STR0003 FROM 176, 188 TO 450, 980 Pixel // "Emissão de Ocorrencias do jurídico"

	oLayer:init(oDlg, .F.) // Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
	oLayer:addCollumn("MainColl", 100, .F.) // Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel( 'MainColl' )

	oPnl := tPanel():New(0, 0, '', oMainColl,,,,,, 0, 0)
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT

	// Referência
	@ 002, 005  To  040, 220 Label STR0004 Pixel Of oPnl // "Referência"

	@ 010, 010 Say STR0005 Size 050, 008 Pixel Of oPnl // "Data Inicial"
	@ 017, 010 MsGet oDtRefIni Var dDtRefIni Size 060, 009 Pixel Of oPnl;
	Valid IIf( !Empty(dDtRefFim) .And. dDtRefIni > dDtRefFim, J305MsgDt( STR0009 ), .T.) HasButton // "A data inicial não pode ser maior que a data final."

	@ 010, 080 Say STR0006 Size 050, 008 Pixel Of oPnl // "Data Final"
	@ 017, 080 MsGet oDtRefFim Var dDtRefFim Size 060, 009 Pixel Of oPnl;
	Valid IIf( !Empty(dDtRefFim) .And. dDtRefIni > dDtRefFim, J305MsgDt( STR0010 ), .T.) HasButton // "A data final não pode ser menor que a data inicial."

	// Filtros
	@ 002, 227  To  100, 394 Label STR0007 Pixel Of oPnl // " Filtros "

	// Sócio
	@ 010, 232 Say STR0008 Size 070, 008 Pixel Of oPnl // "Sócio"
	@ 017, 232 MsGet oSocio Var cSocio   Size 075, 009 When !lChkPenden Pixel Of oPnl F3 'RD0REV';
	Valid ( Empty( cSocio ) .Or. ( ExistCpo( 'RD0', cSocio, 9) .And. JA201VGCLC('Socio', @cGetGrup, @cGetClie, @cGetLoja, @cGetCaso, @cSocio, @cSituSoc, @cExcSoc) ) )  HasButton
	oSocio:bF3 := {|| JbF3LookUp('RD0REV', oSocio, @cSocio)}

	// Moeda
	@ 010, 315 Say STR0011 Size 070, 008 Pixel Of oPnl // "Moeda"
	@ 017, 315 MsGet oMoeda Var cMoeda   Size 075, 009 Pixel Of oPnl F3 'CTO';
	Valid ( Empty( cMoeda ) .Or. ExistCpo( 'CTO', cMoeda ) ) HasButton
	oMoeda:bF3 := {|| JbF3LookUp('CTO', oMoeda, @cMoeda)}

	// Contrato
	@ 030, 232 Say STR0012 Size 021, 008 Pixel Of oPnl // "Contrato"
	@ 029, 270 CheckBox oChkTdCont Var lChkTdCont Prompt STR0002 Size 040, 008 Pixel Of oPnl When (!Empty(cContratos) .And. !lChkPenden) // "Todos"
	@ 037, 232 MsGet oContratos Var cContratos Size 075, 009 Pixel Of oPnl F3 'J96NT0';
	Valid ((Empty( cContratos ) .Or. J201VldCpo(cContratos, "NT0", 1, 'NT0_COD', STR0012)) .And. JA305VLC() ) HasButton // "Contrato"
	oContratos:bF3 := {|| JbF3LUpMul('NT0OI2', oContratos, @cContratos)}
	oContratos:bSetGet := {|u| If(Pcount() > 0, cContratos := PADR(u, 250, " "), PADR(cContratos, 250, " ")) }

	// Grupo de Clientes
	@ 030, 315 Say STR0013 Size 060, 008 Pixel Of oPnl // "Grupo de Clientes"
	@ 037, 315 MsGet oGetGrup Var cGetGrup Size 075, 009 Pixel Of oPnl  F3 'ACY';
	Valid ( Empty( cGetGrup ) .Or. JA201VGCLC('Grupo', @cGetGrup,  @cGetClie, @cGetLoja, @cGetCaso) ) HasButton;
	When (Empty(cGetCaso) .And. !lChkPenden)
	oGetGrup:bF3 := {|| JbF3LookUp('ACY', oGetGrup, @cGetGrup)}

	// Cliente
	@ 050, 232 Say STR0014 Size 060, 008 Pixel Of oPnl          // "Cliente"
	@ 057, 232 MsGet oGetClie Var cGetClie Size 055, 009 Pixel Of oPnl F3 'SA1NUH';
	Valid {|| ( JA201VGCLC('Cliente', @cGetGrup,  @cGetClie, @cGetLoja, @cGetCaso) ) .And. JA305VLC() } HasButton;

	oGetClie:bF3 := {|a,b,c| Iif(oLkUpSA1:Activate(cGetClie+cGetLoja),;
	(oLkUpSA1:ExecuteReturn(oGetClie), oGetClie:lModified := .T., oGetLoja:lModified := .T., oGetLoja:Refresh());
	, Nil), oLkUpSA1:DeActivate()}

	// Loja
	@ 057, 287 MsGet oGetLoja     Var cGetLoja    Size 020, 009 Pixel Of oPnl;
	Valid {|| ( JA201VGCLC('Loja', @cGetGrup,  @cGetClie, @cGetLoja, @cGetCaso) ) .And. JA305VLC() } HasButton  ;

	Iif (cLojaAuto == "1", oGetLoja:Hide(), )

	// Escritório
	@ 050, 315 Say STR0015 Size 060, 008 Pixel Of oPnl // "Escritório"
	@ 057, 315 MsGet oEscrit Var cEscrit Size 075, 009 Pixel Of oPnl F3 'NS7';
	Valid ( Empty( cEscrit ) .Or. ExistCpo( 'NS7', cEscrit ) ) HasButton
	oEscrit:bF3 := {|| JbF3LookUp('NS7', oEscrit, @cEscrit)}

	// Ocorrência
	@ 070, 232 Say STR0016 Size 060, 008 Pixel Of oPnl // "Ocorrência"
	@ 077, 232 MsGet oOcorre Var cOcorre Size 075, 009 Pixel Of oPnl F3 'OI2';
	Valid ( Empty( cOcorre ) .Or. ExistCpo( 'OI2', cOcorre ) )  HasButton
	oOcorre:bF3 := {|| JbF3LookUp('OI2', oOcorre, @cOcorre)}

	// Tipos de Honorários
	@ 070, 315 Say STR0017 Size 100, 008 Pixel Of oPnl //"Tipos de Honorários"
	@ 077, 315 MsGet oTipoTS Var cTipoTS Size 075, 009 Pixel Of oPnl F3 'NRA' ;
	Valid (Empty( cTipoTS ) .Or. ExistCpo( 'NRA', cTipoTS )) HasButton
	oTipoTS:bF3 := {|| JbF3LUpMul('NRA', oTipoTS, @cTipoTS)}

	oDlg:lEscClose := .F.

	bConfir := {|| IIF( lOk := J305VldFil(dDtRefIni, dDtRefFim, cSocio, cMoeda, cContratos,;
										cGetGrup, cGetClie, cEscrit, cOcorre, cTipoTS), ;
										Processa({|| J305SolOcor(dDtRefIni, dDtRefFim, cSocio, cMoeda, cContratos,;
										cGetGrup, cGetClie, cGetLoja,  cEscrit, cOcorre, cTipoTS, lChkTdCont ), ;
										STR0018, "" }), ) } // "Gerando solicitações ... "

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bConfir, {|| oDlg:End()}, , /*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA305VLC()
Função utilizada validação do preenchimento dos campos contrato, cliente
e loja na tela de emissão de ocorrências

@since 26/10/2022
/*/
//-------------------------------------------------------------------
Static Function JA305VLC()

Local lRet := .T.

	If (!Empty( cGetClie ) .Or. !Empty( cGetLoja ))
		cContratos := Space( 250 )
		lChkTdCont := .F.
		oContratos:Disable()
		oChkTdCont:Disable()
	Else
		oContratos:Enable()
		oChkTdCont:Enable()
		oContratos:Refresh()
		oChkTdCont:Refresh()
	EndIf

	If Empty( cGetClie )
		cGetLoja := Criavar( 'A1_LOJA', .F. )
		oGetLoja:Refresh()
	EndIf

	If Empty( cContratos )
		lChkTdCont := .F.
		oChkTdCont:Disable()
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J305NT0SXB(lPreload)
Consulta padrão para campo de Contratos. Usado na tela de emissão de
ocorrencias do jurídico

@param lPreload - (.T./.F.) - Indica se a consulta deve ser pré-carregada
@Return lRet    - (.T./.F.) - Indica se as informações são válidas

@since 26/10/2022
/*/
//-------------------------------------------------------------------
Function J305NT0SXB(lPreload)
Local aArea       := GetArea()
Local lRet        := .F.
Local nResult     := 0
Local cQuery      := ""
Local cOrderBy    := " ORDER BY NT0.NT0_COD "
Local cGroupBy    := " GROUP BY NT0.NT0_COD, NT0.NT0_NOME, NT0.R_E_C_N_O_ "
Local aCampos     := {'NT0_COD', 'NT0_NOME'}

Default lPreload  := .T.

	cQuery := " SELECT NT0.NT0_COD,  "            // Código do contrato
	cQuery +=        " NT0.NT0_NOME, "            // Desc do contrato
	cQuery +=        " NT0.R_E_C_N_O_ RECNONT0 "  // Recno contrato
	cQuery += " FROM " + RetSqlName('NT0') + " NT0 "
	cQuery +=     " INNER JOIN " + RetSqlName('OI4') + " OI4 "
	cQuery +=          " ON (OI4_CCONTR = NT0.NT0_COD "
	cQuery +=                 " AND OI4.D_E_L_E_T_ = ' ') "
	cQuery += " WHERE NT0.D_E_L_E_T_ = ' ' "

	nResult := JurF3SXB("NT0", aCampos, ,.T. ,.F. , "JURA096", cQuery, lPreload, ,.F., cGroupBy, cOrderBy)

	RestArea( aArea )

	If nResult > 0
		lRet := .T.
		DbSelectArea("NT0")
		NT0->(dbgoTo(nResult))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J305VldFil(dDtRefIni, dDtRefFim, cSocio, cMoeda, cContratos,
							cGetGrup, cGetClie, cEscrit, cOcorre, cTipoTS)
Valida os campos de filtros preenchidos na tela de emissão

@param dDtRefIni  - Campo de filtro de Data referencia inicial
@param dDtRefFim  - Campo de filtro de Data referencia final
@param cSocio     - Campo de filtro de Socio
@param cMoeda     - Campo de filtro de Moeda
@param cContratos - Campo de filtro de Contratos
@param cGetGrup   - Campo de filtro de Grupo de clientes
@param cGetClie   - Campo de filtro de Código cliente
@param cEscrit    - Campo de filtro de Escritório
@param cOcorre    - Campo de filtro de Ocorrencia
@param cTipoTS    - Campo de filtro de Tipos de honorários
@Return lRet - (.T./.F.) - Indica se o preenchimento dos filtros é valido

@since 26/10/2022
/*/
//-------------------------------------------------------------------
Function J305VldFil(dDtRefIni, dDtRefFim, cSocio, cMoeda, cContratos, ;
						cGetGrup, cGetClie, cEscrit, cOcorre, cTipoTS)

Local lRet        := .T.

	If Empty(DtoS(dDtRefIni))
		lRet := J305MsgDt(STR0019)  // "Data inicial não foi preenchida. Verifique!"
	EndIf

	If lRet .AND. Empty(DtoS(dDtRefFim))
		lRet := J305MsgDt( STR0020 ) // "Data final não foi preenchida. Verifique!"
	EndIf

	// Validação dos capmos de filtro
	If lRet .AND. (Empty(cSocio) .AND. Empty(cMoeda) .AND. Empty(cContratos) .AND. Empty(cGetGrup) .AND. ;
					Empty(cGetClie) .AND. Empty(cEscrit) .AND. Empty(cOcorre) .AND. Empty(cTipoTS) )
		lRet := J305MsgDt( STR0021 ) // "Não foi preenchido nenhum campo de filtro. Verifique!"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J305SolOcor(dDtRefIni, dDtRefFim, cSocio, cMoeda,
							cContratos, cGetGrup, cGetClie, cGetLoja,
							cEscrit, cOcorre, cTipoTS, lChkTdCont)

Busca os contratos de acordo com os filtros da tela de emissão para
cadastrar as solicitações.

@param dDtRefIni  - Campo de filtro de Data referencia inicial
@param dDtRefFim  - Campo de filtro de Data referencia final
@param cSocio     - Campo de filtro de Socio
@param cMoeda     - Campo de filtro de Moeda
@param cContratos - Campo de filtro de Contratos
@param cGetGrup   - Campo de filtro de Grupo de clientes
@param cGetClie   - Campo de filtro de Código cliente
@param cGetLoja   - Campo de filtro de Loja cliente
@param cEscrit    - Campo de filtro de Escritório
@param cOcorre    - Campo de filtro de Ocorrencia
@param cTipoTS    - Campo de filtro de Tipos de honorários
@param lChkTdCont - Campo de filtro Todos
@param lAutomato  - Indica se esta sendo executado pela automação
@param aDadosSol  - Dados para executar automação
@Return lRet      - (.T./.F.)

@since 26/10/2022
/*/
//-------------------------------------------------------------------
Function J305SolOcor(dDtRefIni, dDtRefFim, cSocio, cMoeda, cContratos,;
					cGetGrup, cGetClie, cGetLoja, cEscrit, cOcorre, cTipoTS, ;
					lChkTdCont, lAutomato, aDadosSol)

Local lRet        := .F.
Local cQuery      := ""
Local aListSol    := {}
Local aErros      := {}
Local cCodT       := SuperGetMv('MV_JCFGOCO',, '')
Local cUrlReq     := "https://api.totvsjuridico.totvs.com.br/api/ocorrencia/new/"+ Encode64(cCodT)

Default lAutomato := .F.
Default aDadosSol := {}

	ProcRegua( 1 )
	IncProc( STR0022 ) // "Buscando contratos"

	If !lAutomato
		// Busca contratos de acordo com os filtros da tela de emissão
		cQuery := J305QryCntr(cSocio, cMoeda, cContratos,cGetGrup, cGetClie, ;
								cGetLoja, cEscrit, cOcorre, cTipoTS, lChkTdCont,;
								dDtRefIni, dDtRefFim)

		// Guarda os dados em objeto para criar a solicitação
		aListSol := J305Result(cQuery, dDtRefIni, dDtRefFim)
	Else
		aListSol := aClone(aDadosSol)
	EndIf

	// Cria requisição para gravar a solicitação na azure
	If Len(aListSol) > 0

		ProcRegua( 2 )
		IncProc( STR0023 ) // "Criando solicitações"

		aErros := J305SolAz(aListSol, cCodT)

		// Grava na tabela de monitor de acompanhamento
		lRet := J305MonSol(aListSol, 3, aErros, cUrlReq)

		If lRet
			FWAlertSuccess( STR0024 ) // "Solicitações enviadas para processamento com sucesso! Acesse a rotina de acompanhamento para verificar o status das solicitações."
		EndIf
	EndIf

	If Len(aErros) > 0
		FWAlertWarning( STR0025 ) // "Algumas solicitações não foram gravadas! Para reenvia-las acesse a rotina de acompanhamento de solicitações para verificar."
	EndIf

	aSize(aDadosSol, 0)
	aSize(aListSol, 0)
	aSize(aErros, 0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J305QryCntr(cSocio, cMoeda, cContratos, cGetGrup, cGetClie,
					cGetLoja, cEscrit, cOcorre, cTipoTS, lChkTdCont)
Executa a query de busca de contratos de acordo com os filtros utilizados
na tela de emissão de ocorrencias do jurídico

@param cSocio     - Campo de filtro de Socio
@param cMoeda     - Campo de filtro de Moeda
@param cContratos - Campo de filtro de Contratos
@param cGetGrup   - Campo de filtro de Grupo de clientes
@param cGetClie   - Campo de filtro de Código cliente
@param cGetLoja   - Campo de filtro de Loja cliente
@param cEscrit    - Campo de filtro de Escritório
@param cOcorre    - Campo de filtro de Ocorrencia
@param cTipoTS    - Campo de filtro de Tipos de honorários
@param lChkTdCont - Campo de filtro Todos
@param dDtRefIni  - Campo de filtro de Data referencia inicial
@param dDtRefFim  - Campo de filtro de Data referencia final
@return cQuery    - Query com filtros aplicados

@since 26/10/2022
/*/
//-------------------------------------------------------------------
Function J305QryCntr(cSocio, cMoeda, cContratos, cGetGrup, cGetClie, ;
					cGetLoja, cEscrit, cOcorre, cTipoTS, lChkTdCont, ;
					dDtRefIni, dDtRefFim)

Local cQuery   := ""
Local cCodPart := ""

	cContratos := J305CSQLIn(cContratos, "NT0_COD")
	cTipoTS    := J305CSQLIn(cTipoTS, "NT0_CTPHON")

	cQuery := " SELECT NT0.NT0_COD, "
	cQuery +=        " NT0.NT0_NOME, "
	cQuery +=        " NT0.R_E_C_N_O_, "
	cQuery +=        " NT0.NT0_CMOE, "
	cQuery +=        " NT0.NT0_CTPHON, "
	cQuery +=        " NT0.NT0_CESCR, "
	cQuery +=        " NT0.NT0_CCLIEN, "
	cQuery +=        " NT0.NT0_CLOJA, "
	cQuery +=        " OI2.OI2_COD, "
	cQuery +=        " OI2.OI2_DESC, "
	cQuery +=        " OI2.OI2_ENTIDA, "
	cQuery +=        " OI2.OI2_RETORN, "
	cQuery +=        " CASE WHEN NW2.NW2_COD IS NULL "
	cQuery +=             " THEN '" + Space(TamSx3('NW2_COD')[1]) + "' "
	cQuery +=             " ELSE NW2.NW2_COD END NW2_COD "

	cQuery += " FROM " + RetSqlName("NT0") + " NT0 "

	// Relacionamento clientes x Casos do contrato
	cQuery +=        " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery +=            " ON (SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery +=                " AND SA1.A1_COD = NT0.NT0_CCLIEN "
	cQuery +=                " AND SA1.A1_LOJA = NT0.NT0_CLOJA "
	cQuery +=                " AND SA1.D_E_L_E_T_ = ' ') "

	// Junção de contratos
	cQuery +=        " LEFT OUTER JOIN " + RetSqlName("NW3") + " NW3 "
	cQuery +=            " ON (NW3.NW3_FILIAL = '" + xFilial("NW3") + "' "
	cQuery +=                " AND NT0.NT0_COD = NW3.NW3_CCONTR "
	cQuery +=                " AND NW3.D_E_L_E_T_ = ' ') "
	cQuery +=        " LEFT OUTER JOIN " + RetSqlName("NW2") + " NW2 "
	cQuery +=            " ON (NW2.NW2_FILIAL = '" + xFilial("NW2") + "' "
	cQuery +=                " AND NW3.NW3_CJCONT = NW2.NW2_COD "
	cQuery +=                " AND NW2.D_E_L_E_T_ = ' ') "

	// Faturamento de ocorrencias
	cQuery +=        " INNER JOIN " + RetSqlName("OI4") + " OI4 "
	cQuery +=            " ON OI4.OI4_FILIAL = '" + xFilial("OI4") + "' "
	cQuery +=                " AND OI4_CCONTR = NT0_COD "
	cQuery +=                " AND OI4.D_E_L_E_T_ = ' ' "

	// Ocorrências
	cQuery +=        " INNER JOIN " + RetSqlName("OI2") + " OI2 "
	cQuery +=            " ON OI2.OI2_FILIAL = '" + xFilial("OI2") + "' "
	cQuery +=                " AND OI2.OI2_COD = OI4.OI4_COCORR "
	cQuery +=                " AND OI2.D_E_L_E_T_ = ' ' "

	// Tipos de Honorários
	cQuery +=        " INNER JOIN " + RetSqlName("NRA") + " NRA "
	cQuery +=            " ON NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
	cQuery +=                " AND NRA.NRA_COD = NT0.NT0_CTPHON "
	cQuery +=                " AND NRA.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") + " '
	cQuery +=       " AND NT0.D_E_L_E_T_ = ' ' "
	cQuery +=       " AND NT0.NT0_ATIVO = '1' "
	cQuery +=       " AND NT0.NT0_SIT = '2' "

	// Filtro socio
	If !Empty(cSocio)
		cCodPart := JurGetDados('RD0', 9, xFilial('RD0') + cSocio, 'RD0_CODIGO')
		cQuery +=   " AND ( (NW2.NW2_CPART IS NULL AND NT0.NT0_CPART1 = '" + cCodPart + "') "
		cQuery +=            " OR NW2.NW2_CPART = '" + cCodPart + "' ) "
	EndIf

	// Filtro moeda
	If !Empty(cMoeda)
		cQuery +=   " AND ( (NW2.NW2_CMOE IS NULL AND NT0.NT0_CMOE = '" + cMoeda + "')  "
		cQuery +=            " OR "
		cQuery +=            " NW2.NW2_CMOE = '" + cMoeda + "' "
		cQuery +=       " ) "
	EndIf

	// Filtro contratos
	If !Empty(cContratos)

		If lChkTdCont // Todos os contratos
			cQuery += " AND ( NT0.NT0_COD IN (" + cContratos + ") "
			cQuery +=       " OR EXISTS (SELECT NW3c.R_E_C_N_O_ "
			cQuery +=                      " FROM " + RetSqlName("NW3") + " NW3c "
			cQuery +=                      " WHERE NW3c.NW3_FILIAL = '" + xFilial("NW3") +"' "
			cQuery +=                        " AND NW3c.NW3_CCONTR = NT0.NT0_COD "
			cQuery +=                        " AND EXISTS ( SELECT NW3d.R_E_C_N_O_ "
			cQuery +=                                       " FROM " + RetSqlName("NW3") + " NW3d "
			cQuery +=                                       " WHERE NW3d.NW3_FILIAL = '" + xFilial("NW3") +"' "
			cQuery +=                                           " AND NW3d.NW3_CJCONT = NW3c.NW3_CJCONT "
			cQuery +=                                           " AND NW3d.NW3_CCONTR IN (" + cContratos + ") "
			cQuery +=                                           " AND NW3d.D_E_L_E_T_ = ' ') "
			cQuery +=                         " AND NW3c.D_E_L_E_T_ = ' ' "
			cQuery +=                  " )) "
		Else
			cQuery += " AND NT0.NT0_COD IN ( " + cContratos + " ) "
		EndIf
	EndIf

	// Filtro Grupo de clientes
	If !Empty(cGetGrup)
		cQuery +=   " AND EXISTS ( SELECT SA1A.R_E_C_N_O_ "
		cQuery +=                " FROM " + RetSqlName("SA1") + " SA1A "
		cQuery +=                " WHERE SA1A.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery +=                       " AND SA1A.A1_GRPVEN = '" + cGetGrup + "' "
		cQuery +=                       " AND SA1A.A1_COD = NT0.NT0_CCLIEN "
		cQuery +=                       " AND SA1A.A1_LOJA = NT0.NT0_CLOJA "
		cQuery +=                       " AND SA1A.D_E_L_E_T_ = ' ' ) "
	EndIf

	// Filtro de Escritorio
	If !Empty(cEscrit)
		cQuery += " AND NT0.NT0_CESCR = '" + cEscrit + "' "
	EndIf

	// Filtro de ocorrencia
	If !Empty(cOcorre)
		cQuery += " AND OI2.OI2_COD = '" + cOcorre + "' "
	EndIf

	// Filtro de Tipos de Honorários
	If !Empty(cTipoTS)
		cQuery += " AND NT0.NT0_CTPHON IN ( " + cTipoTS + " ) "
	EndIf

	If !Empty(cGetClie) .And. !Empty(cGetLoja)
		cQuery += " AND NT0.NT0_CCLIEN = '" + cGetClie + "' "
		cQuery += " AND NT0.NT0_CLOJA = '" + cGetLoja + "' "
	EndIf

	// Validação para não duplicar solicitações do mesmo contrato / ocorrência / período
	cQuery += " AND NOT EXISTS( "
	cQuery +=                   " SELECT OI7.OI7_IDSOL "
	cQuery +=                   " FROM " + RetSqlName("OI7") + " OI7 "
	cQuery +=                   " WHERE OI7.OI7_STATUS IN( '1', '7' ) " // 1=Pendente / 7=Pendente de revisão
	cQuery +=                        " AND OI7.OI7_CCONTR = NT0.NT0_COD "
	cQuery +=                        " AND OI7.OI7_COCORR = OI2.OI2_COD "
	cQuery +=                        " AND ( OI7.OI7_DTINI >= '" +  DTOS( dDtRefIni ) + "' "
	cQuery +=                                  " AND OI7.OI7_DTFIM  <= '" +  DTOS( dDtRefFim ) + "' ) "
	cQuery +=                        " AND OI7.D_E_L_E_T_ = ' ' "
	cQuery +=                 " ) "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J305CSQLIn(cCods, cCampo)
Transforma uma cadeia de codigos separados por ";" em uma cadeira de codigos
para condição Sql IN.

@Param cCods  - Cadeia de codigos para ser transformada 000001;000002
@Param cCampo - Nome do campo referente a cadeia de codigos Ex: A1_COD
@Return cRet  -  Cadeia de codigos com aspas simples e separados por ",
				" Ex: '000001','000002'

@since 28/10/2022
/*/
//-------------------------------------------------------------------
Static Function J305CSQLIn(cCods, cCampo)
Local cRet    := ""
Local aCods   := StrTokArr(AllTrim(cCods), ";")
Local nTamCod := TamSX3(cCampo)[1]
Local nI      := 0

	If Len(aCods) > 0

		For nI := 1 To Len(aCods)
			cCod := PadR(aCods[nI], nTamCod, " ") //Tratamento de espaços p/ Oracle
			If !Empty(cCod)
				cRet += cCod + Iif(Len(aCods) != nI, "','", "")
			EndIf
		Next nI

		If !Empty(cRet)
			cRet := "'" + cRet + "'"
		EndIf

		JurFreeArr(@aCods)
	EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J305Result(cQuery, dDtRefIni, dDtRefFim)
Responsável por obter os dados dos contratos de acordo com a query e
montar o objeto com os dados para o cadastro da solicitação

@param cQuery      - Query que será executrada na busca dos dados
@param dDtRefIni   - Campo de filtro de Data referencia inicial
@param dDtRefFim   - Campo de filtro de Data referencia final
@return aListSolic - Lista de solicitações

@since 28/10/2022
/*/
//-------------------------------------------------------------------
Function J305Result(cQuery, dDtRefIni, dDtRefFim)
Local aArea       := GetArea()
Local cAlias      := GetNextAlias()
Local oDataRef    := JsonObject():New()
Local oJsonSol    := Nil
Local cCodOcorre  := ""
Local cCodContr   := ""
Local cCliente    := ""
Local cLoja       := ""
Local nIndex      := 0
Local aListSolic  := {}

	If !Empty(cQuery)

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cAlias, .T., .F. )

		If !(cAlias)->(EOF())
			(cAlias)->(DbGoTop())

			oDataRef['inicial'] := DTOS( dDtRefIni )
			oDataRef['final']   := DTOS( dDtRefFim )

			While !(cAlias)->(EOF())
				nIndex++
				cCodOcorre := (cAlias)->OI2_COD
				cCodContr  := (cAlias)->NT0_COD
				cCliente   := (cAlias)->NT0_CCLIEN
				cLoja      := (cAlias)->NT0_CLOJA

				// Objeto da solicitação
				oJsonSol := JsonObject():New()
				oJsonSol['solicitacao'] := {}
				Aadd(oJsonSol['solicitacao'], JsonObject():New())

				oJsonSol['solicitacao'][nIndex]['id']                := Lower(FWUUIDv4(.T.))
				oJsonSol['solicitacao'][nIndex]['entidade']          := (cAlias)->OI2_ENTIDA  // 1=Processo / 2=Ato processual
				oJsonSol['solicitacao'][nIndex]['campoRetorno']      := AllTrim((cAlias)->OI2_RETORN)
				oJsonSol['solicitacao'][nIndex]['solicitante']       := J305Solicitante()
				oJsonSol['solicitacao'][nIndex]['dataLog']           := J305MkData()
				oJsonSol['solicitacao'][nIndex]['contrato']          := J305Contrato(cCodContr, cCliente, cLoja)
				oJsonSol['solicitacao'][nIndex]['ocorrencia']        := J305Ocorrencia(cCodOcorre, JConvUTF8((cAlias)->OI2_DESC))
				oJsonSol['solicitacao'][nIndex]['dataReferencia']    := oDataRef
				oJsonSol['solicitacao'][nIndex]['filtros']           := J305GetFil( cCodOcorre )
				oJsonSol['solicitacao'][nIndex]['casos']             := J305GtCasos( cCodContr )

				If VALTYPE(oJsonSol) <> "U"
					aAdd(aListSolic, oJsonSol['solicitacao'][1])
					FwFreeObj(oJsonSol)
					oJsonSol := Nil
					nIndex := 0
				EndIf

				(cAlias)->( DbSkip() )
			EndDo

		Else
			J305MsgDt( STR0026 ) // "Não foram encontrados dados para emissão de ocorrencias do juridico."
		EndIf

		(cAlias)->(dbCloseArea())
	EndIf

	RestArea(aArea)

Return aListSolic

//-------------------------------------------------------------------
/*/{Protheus.doc} J305GetFil( cCodOcorr )
Responsável por buscar os campos das condições das ocorrencias cadastradas

@param cCodOcorr  - Códigos das ocorrencias
@return oResponse - Objeto com filtros das condições de ocorrencias

@since 28/10/2022
/*/
//-------------------------------------------------------------------
Function J305GetFil( cCodOcorr )
Local cAlias    := GetNextAlias()
Local aArea     := GetArea()
Local aFiltros  := {}
Local cQuery    := ""
Local cOcorre   := cCodOcorr
Local nQtdReg   := 0

	If !Empty(cOcorre)
		If ";" $ cOcorre
			cOcorre := J305CSQLIn(cOcorre, "OI3_COD")
		EndIf

		cQuery := " SELECT OI3_CAMPO, OI3_TIPO, OI3_CONTEU "
		cQuery +=   " FROM " + RetSqlName("OI3") + " OI3 "
		cQuery +=  " WHERE OI3_COD IN( ? ) "
		cQuery +=    " AND OI3.D_E_L_E_T_ =  ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{cOcorre}), cAlias, .T., .F. )

		While !(cAlias)->( EOF())
			nQtdReg++
			Aadd(aFiltros, JsonObject():New())
			aFiltros[nQtdReg]['campo'] := AllTrim( (cAlias)->OI3_CAMPO )
			aFiltros[nQtdReg]['tipo']  := AllTrim( (cAlias)->OI3_TIPO )
			aFiltros[nQtdReg]['valor'] := AllTrim( (cAlias)->OI3_CONTEU )
			(cAlias)->(DbSkip())
		EndDo

		(cAlias)->( DbCloseArea() )
	EndIf
	RestArea(aArea)

Return aFiltros

//-------------------------------------------------------------------
/*/{Protheus.doc} J305MonSol( aListSolic, nOperation, aErros, cUrlReq  )
Responsável por gravar as solicitações na rotina de Acompanhamento
de solicitações de ocorrencias do jurídico

@param aListSolic - Lista de solicitações de ococrrencias
@param nOperation - Numero da operação (3-Inclusão/4-Alteração)
@param aErros     - Array com erros.
@param cUrlReq    - URL da requisição para Azure
@return lRet      - (.T./.F.) Indica se a solicitação foi gravada

@since 28/10/2022
/*/
//-------------------------------------------------------------------
Function J305MonSol( aListSolic, nOperation, aErros, cUrlReq )
Local aArea    := GetArea()
Local oMdl306  := Nil
Local nI       := 1
Local nPos     := 0
Local nQtdSol  := Len(aListSolic)
Local lRet     := .T.
Local lMetrics := FindFunction("JurMetric")

Default nOperation := 3

	oMdl306 := FWLoadModel("JURA306")
	oMdl306:SetOperation(nOperation)

	ProcRegua( nQtdSol )
	IncProc(STR0027) // "Gravando solicitações"

	For nI := 1 To nQtdSol
		oMdl306:Activate()
		IncProc(STR0027 + cValToChar(nI) + "/" + cValToChar(nQtdSol) ) // "Gravando solicitações"

		// Inclusão
		If nOperation == 3
			oMdl306:SetValue( "OI7MASTER", "OI7_IDSOL ", aListSolic[nI]['id']       )
			oMdl306:SetValue( "OI7MASTER", "OI7_ENTIDA", aListSolic[nI]['entidade'] ) 
			oMdl306:SetValue( "OI7MASTER", "OI7_CCONTR", aListSolic[nI]['contrato']['codigo'] )
			oMdl306:SetValue( "OI7MASTER", "OI7_COCORR", aListSolic[nI]['ocorrencia']['codigo'] )
			oMdl306:SetValue( "OI7MASTER", "OI7_DTINI ", STOD(aListSolic[nI]['dataReferencia']['inicial']) )
			oMdl306:SetValue( "OI7MASTER", "OI7_DTFIM ", STOD(aListSolic[nI]['dataReferencia']['final'])   )
			oMdl306:SetValue( "OI7MASTER", "OI7_CODUSR", __cUserId                     )
			oMdl306:SetValue( "OI7MASTER", "OI7_USER  ", aListSolic[nI]['solicitante']['nome'] )
			oMdl306:SetValue( "OI7MASTER", "OI7_BODY  ", aListSolic[nI]:toJSon()       )
			oMdl306:SetValue( "OI7MASTER", "OI7_URLREQ", cUrlReq                       )

			If Len(aErros) > 0
				If (nPos := aScan( aErros, {|x| x[1] == aListSolic[nI]['id'] })) > 0
					oMdl306:SetValue( "OI7MASTER", "OI7_MSG   ", aErros[nPos][2] )
					oMdl306:SetValue( "OI7MASTER", "OI7_STATUS", '7' ) // Pendente de revisão
				EndIf
			Else
				oMdl306:SetValue( "OI7MASTER", "OI7_MSG   ", "" )
				oMdl306:SetValue( "OI7MASTER", "OI7_STATUS", '1' ) // Pendente
			EndIf
		EndIf

		// Alteração
		If nOperation == 4
			oMdl306:SetValue( "OI7MASTER", "OI7_MSG   ", "" )
			oMdl306:SetValue( "OI7MASTER", "OI7_STATUS", '1' ) // Pendente
		EndIf
		
		If ( lRet := oMdl306:VldData() )
			lRet := oMdl306:CommitData()
		EndIf

		If !lRet
			JurMsgErro(oMdl306:aErrorMessage[6], STR0028, ; // "Não foi possível gravar a solicitação de ocorrencias para acompanhamento!"
						oMdl306:aErrorMessage[7]) 
		EndIf

		oMdl306:DeActivate()

		// Envia métricas para License server
		If lMetrics
			J305SetMet()
		EndIf
	Next nI

	oMdl306:Destroy()
	oMdl306 := Nil
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J305SolAz(aListSol, cCodT)
Responsável por enviar as solicitações na azure

@param aListSol   - Lista de solicitações
@param cCodT      - Código do cliente TOTVS
@return aErrosSol - Array de erros da gravação na Azure

@since 28/10/2022
/*/
//-------------------------------------------------------------------
Function J305SolAz(aListSol, cCodT)
Local lRet      := .F.
Local nI        := 1
Local aHeader   := {}
Local aErrosSol := {}
Local oRest     := nil
Local cError    := ""

	If !Empty(cCodT)
		cEndPoint := 'ocorrencia/config/'+Encode64(cCodT)
		oRest := JRestOcor(cEndPoint,@aHeader)
		If lRet := oRest:Get(aHeader)
			FwFreeObj(oRest)
		EndIf
	Else
		MsgInfo(STR0029) // "Para utilizar a funcionalidade de Faturamento por ocorrencias é necessário realizar configuração prévia!"
	EndIf

	// Se existe a configuração do cliente (codigoT)
	If lRet
		For nI := 1 To Len(aListSol)
			If !J305PostSol(aListSol[nI], cCodT, @cError)
				// Se não conseguir gravar na Azure guarda
				aAdd(aErrosSol, { aListSol[nI]['id'], STR0030 + CRLF + cError }) // 'Não foi possível gravar a solicitação na Azure.'
				cError := ""
			EndIf
		Next nI
	EndIf
Return aErrosSol

//------------------------------------------------------------------------------
/* /{Protheus.doc} J305PostSol(oBody, cCodT, cError)
Responsavel por gravar a solicitação na azure

@param oBody  - Body da requisição em Json
@param cCodT  - CodigoT da configuração
@param cError - Mensagem de erro da gravação da solicitação na Azure

@return lRet  - Informa se a solicitação foi cadastrada com sucesso

@since 28/10/2022
/*/
//------------------------------------------------------------------------------
Static Function J305PostSol(oBody, cCodT, cError)
Local lRet         := .T.
Local oRest        := nil
Local aHeader      := {}
Local cEndPoint    := "ocorrencia/new/"+ Encode64(cCodT)

	oRest := JRestOcor(cEndPoint,@aHeader)
	oRest:SetPostParams(oBody:toJson())

	If !oRest:Post(aHeader)
		lRet := .F.
		cError := oRest:GetLastError()
		JurMsgErro(STR0031 + cError) // "Falha na gravação: "
	EndIf
	FwFreeObj(oRest)
Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} J305GtCasos(cCodContr)
Responsavel por gravar a solicitação na azure

@param cCodContr - Codigo do Contrato

@return aCasos - Lista de casos do contrato
@since 28/10/2022
/*/
//------------------------------------------------------------------------------
Function J305GtCasos(cCodContr)
Local aArea   := GetArea()
Local nI      := 0
Local aCasos  := {}
Local cQuery  := ""
Local cAlias  := ""

	If !Empty(cCodContr)
		cQuery := " SELECT NUT.NUT_CCLIEN "
		cQuery +=       " ,NUT.NUT_CLOJA "
		cQuery +=       " ,NUT.NUT_CCASO "
		cQuery += " FROM " + RetSqlName("NUT") + " NUT "
		cQuery += " WHERE NUT.NUT_CCONTR = ? "
		cQuery +=   " AND NUT.D_E_L_E_T_ = ' ' "

		cAlias := GetNextAlias()
		dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{cCodContr}), cAlias, .T., .F. )

		While !(cAlias)->( EOF())
			nI++
			aAdd(aCasos,  JsonObject():New())
			aCasos[nI]['cliente'] := allTrim( (cAlias)->NUT_CCLIEN )
			aCasos[nI]['loja']    := allTrim( (cAlias)->NUT_CLOJA )
			aCasos[nI]['caso']    := allTrim( (cAlias)->NUT_CCASO )

			(cAlias)->(DbSkip())
		EndDo

		(cAlias)->( DbCloseArea() )
	EndIf
	RestArea(aArea)

Return aCasos

//-----------------------------------------------------------------
/*/{Protheus.doc} JConvUTF8(cValue)
Converte o Texto para UTF8, removendo os CRLF por || e removendo os espaços laterais

@param  cValue - Valor a ser formatado
@return cReturn - String Encodada UTF-8

@since 05/12/2022
/*/
//-----------------------------------------------------------------
Static Function JConvUTF8(cValue)
Local cReturn := ""

	cReturn := StrTran(EncodeUTF8(Alltrim(cValue)), CRLF, "||")

Return cReturn

//------------------------------------------------------------------------------
/* /{Protheus.doc} J305MkData()
Cria o Agrupador de Datas

@return oReturn - json - Objeto do agrupador 

@since 28/10/2022
/*/
//------------------------------------------------------------------------------
Function J305MkData()
Local oReturn := JsonObject():New()

	oReturn['inclusao']      := ""
	oReturn['processamento'] := ""
	oReturn['conclusao']     := ""

Return oReturn

//------------------------------------------------------------------------------
/* /{Protheus.doc} J305Contrato(cCodContr, cCodClien, cLojClien)
Cria o Agrupador de dados do Contrato

@param cCodContr - Código do Contrato
@param cCodClien - Codigo do Cliente
@param cLojClien - Loja do Cliente

@return oReturn - json - Objeto do agrupador

@since 05/12/2022
/*/
//------------------------------------------------------------------------------
Function J305Contrato(cCodContr, cCodClien, cLojClien)
Local oReturn := JsonObject():New()

	oReturn['codigo']  := cCodContr
	oReturn['cliente'] := cCodClien
	oReturn['loja']    := cLojClien

Return oReturn

//------------------------------------------------------------------------------
/* /{Protheus.doc} J305Ocorrencia(cCodOcorre, cDescOcorre)
Cria o Agrupador de dados do Ocorrencia

@param cCodOcorre  - Código do Ocorrencia
@param cDescOcorre - Descrição do Ocorrencia

@return oReturn - json - Objeto do agrupador

@since 05/12/2022
/*/
//------------------------------------------------------------------------------
Function J305Ocorrencia(cCodOcorre, cDescOcorre)
Local oReturn := JsonObject():New()

	oReturn['codigo']    := cCodOcorre
	oReturn['descricao'] := cDescOcorre

Return oReturn

//------------------------------------------------------------------------------
/* /{Protheus.doc} J305Solicitante()
Cria o Agrupador de dados do Solicitante

@return oReturn - json - Objeto do agrupador

@since 05/12/2022
/*/
//------------------------------------------------------------------------------
Function J305Solicitante()
Local oReturn := JsonObject():New()

	oReturn['nome']  := UsrRetName( __cUserID )
	oReturn['email'] := AllTrim(UsrRetMail( __cUserID ))

Return oReturn

//------------------------------------------------------------------------------
/* /{Protheus.doc} J305SetMet()
Responsável por enviar as métricas da qtd de solicitações emitidas no Faturamento
por Ocorrências do Jurídico para o License server

@since 07/03/2023
/*/
//------------------------------------------------------------------------------
Static Function J305SetMet()
Local cSubRotina := "fat_ocorrencias_qtd_solicitacoes"
Local cIdMetric  := "pre-faturamento-de-servicos-protheus_volume-faturamento-de-ocorrencias_total"

	JurMetric('sum', cSubRotina, cIdMetric, 1, /*dDateSend*/, /*nLapTime*/, 'JURA305')

Return .T.
