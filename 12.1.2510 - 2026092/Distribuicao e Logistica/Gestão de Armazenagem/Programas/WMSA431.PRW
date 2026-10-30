#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FIVEWIN.CH"
#Include "WMSA431.CH"

// Gráficos
#Define GRAF_SIT_ATU     1
#Define GRAF_SIT_DFG     2

#Define QTD_END_OCUP_SEL 1
#Define QTD_END_OCUP_DEM 2
#Define QTD_END_A_LIBER  3
#Define QTD_END_LIVRE    4
#Define PERCENT_OCUP_SEL 5
#Define PERCENT_OCUP_DEM 6
#Define PERCENT_A_LIBER  7
#Define PERCENT_LIVRE    8
#Define QTD_END_TOT      9

#Define WMSA43101 "WMSA43101"
#Define WMSA43102 "WMSA43102"
#Define WMSA43103 "WMSA43103"
#Define WMSA43104 "WMSA43104"
#Define WMSA43105 "WMSA43105"
#Define WMSA43106 "WMSA43106"
#Define WMSA43107 "WMSA43107"
#Define WMSA43108 "WMSA43108" 
#Define WMSA43109 "WMSA43109" 

Static cAliasTDfg := Nil
Static cAliasTOri := Nil
Static cAliasTDes := Nil
Static oBrowse    := Nil
Static oDlg       := Nil
Static oMrkBrw    := Nil
Static oTabTmpDfg := Nil
Static oTabTmpOri := Nil
Static oTabTmpDes := Nil
Static oGrafLeft  := Nil
Static oGrafRight := Nil
Static oRight     := Nil
Static oLeft      := Nil
Static aColsDfg   := {}
Static aSeeksDfg  := {}
Static aIndexDfg  := {}
Static aFieldsDfg := {}
Static aArqTabDfg := {}
Static aArqTabOri := {}
Static aArqTabDes := {}
Static aDadosGraf := {}
Static nAtuLivre  := 0
Static nAtuOcpSel := 0
Static nAtuOcpDem := 0
Static nAtuALiber := 0
Static nDfgOcpSel := 0
Static nDfgALiber := 0
//-----------------------------------
/*{Protheus.doc}
Desfragmentador de Estoque

@author Alexsander Burigo Corrêa
@version P12
@Since	01/04/2018
@obs Desfragmentador de Estoque
*/
//-----------------------------------
Function WMSA431()
Local aCoors     := FWGetDialogSize(oMainWnd)
Local oLayer     := Nil
Local lDadosDfg  := .F.
Local lMarcar    := .F.

Private lMvPerMtEs := .F.
Private lMvPerJtUn := .F.
Private nMvPercOcu := 0
Private cMvProdDe  := ""
Private cMvProdAte := ""
Private cMvZona    := ""
Private cMvLocal   := ""
Private cMvEOriDe  := ""
Private cMvEOriAte := ""
Private cMvEDesDe  := ""
Private cMvEDesAte := ""
Private nPriMovDfg := ""

	If !SuperGetMv("MV_WMSNEW",.F.,.F.)
		Return WMSA430()
	EndIf

	If InitParam()
		// Cria tabela temporária
		CriaTabDfg()
		CriaTabOri()
		CriaTabDes()

		Processa( {|| WmsEndOcup()} , STR0002, STR0016 + "...", .F. ) // "Desfragmentador de Estoque" ## "Analisando Endereços"

		Define MsDialog oDlg TITLE STR0002 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL // Desfragmentador de Estoque
		oLayer := FWLayer():New()
		oLayer:Init(oDlg,.F.,.T.)
		oLayer:AddLine("TOP",60,.T.)
		oLayer:AddLine("BOTTOM",40,.T.)
		oLayer:AddCollumn( "LEFT",50,.T.,"BOTTOM" )
		oLayer:AddCollumn( "RIGHT",50,.T.,"BOTTOM" )

		oLnTop := oLayer:GetLinePanel("TOP")
		oLeft := oLayer:GetColPanel("LEFT","BOTTOM" )
		oRight := oLayer:GetColPanel("RIGHT","BOTTOM" )
		// Monta Browse
		oMrkBrw := FWMarkBrowse():New()
		oMrkBrw:SetOwner(oLnTop)
		oMrkBrw:SetAlias(cAliasTDfg)
		oMrkBrw:oBrowse:SetQueryIndex(aIndexDfg)
		oMrkBrw:SetTemporary(.T.)
		oMrkBrw:SetSeek(,aSeeksDfg)
		oMrkBrw:SetColumns(aColsDfg)
		oMrkBrw:oBrowse:SetFieldFilter( aFieldsDfg )
		oMrkBrw:SetUseFilter()
		oMrkBrw:SetParam({|| SelFiltro() })
		oMrkBrw:SetFieldMark("TMP_OK")
		oMrkBrw:SetDescription(STR0002) // Desfragmentador de Estoque
		oMrkBrw:ForceQuitButton()
		oMrkBrw:oBrowse:SetFixedBrowse(.T.)
		oMrkBrw:oBrowse:SetMenuDef('WMSA431')
		oMrkBrw:SetAfterMark( {|| AfterMark()} )
		oMrkBrw:SetAllMark( {|| AllMark(lMarcar := !lMarcar), oMrkBrw:Refresh(.T.)} )
		oMrkBrw:Activate()
		// Marca todos os registros
		AllMark(lMarcar := .T.)
		// Monta dados para os gráficos
		MntGrfAtu()
		MntGrfDfg()
		// Mostra Gráficos
		MstGrfAtu()
		MstGrfDfg()
		oMrkBrw:Refresh(.T.)
		ACTIVATE MsDialog oDlg CENTER

		DelTabTmp( cAliasTDfg )
		DelTabTmp( cAliasTOri )
		DelTabTmp( cAliasTDes )
	EndIf
Return Nil
//-----------------------------------
/*{Protheus.doc}
MenuDef

@author Alexsander Burigo Corrêa
@version P12
@Since	01/04/2018
@obs
*/
//-----------------------------------
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0009 ACTION "WMSA431EXC()"     OPERATION 4 ACCESS 0 DISABLE MENU // Gerar Ordem de Serviço
Return aRotina
//-----------------------------------
/*{Protheus.doc}
Executar a Desfragmentação

@author Alexsander Burigo Corrêa
@version P12
@Since	01/04/2018
@obs Executar a Desfragmentação
*/
//-----------------------------------
Function WMSA431EXC()
	Processa( {|| ProcRegua(0), Processa( {|| GeraOSDfg() } , STR0009, STR0011 + "...", .F. )  } , STR0009, STR0011 + "...", .F. ) // Executar // Desfragmentando
Return .T.
//-----------------------------------
/*{Protheus.doc}
Executa a Desfragmentação

@author Alexsander Burigo Corrêa
@version P12
@Since	01/04/2018
@obs Executa a Desfragmentação
*/
//-----------------------------------
Static oMntUniItem := Nil
Static oTipUnit    := Nil
Static oTransf     := Nil
//-------------------------------------------------------
Static Function GeraOSDfg()
Local lRet       := .T.
Local cTable     := "%"+oTabTmpDfg:GetRealName()+"%"
Local cAliasQry  := Nil
Local cAliasD14  := Nil
Local cSrvTransf := ""
Local cTarefa    := ""
	dbSelectArea(oTabTmpDfg:GetAlias())
	// Monta o array com os itens selecionados do MarkBrowse
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT TED.R_E_C_N_O_ RECNOTED,
				TED.TMP_LOCORI,
				TED.TMP_ENDORI,
				TED.TMP_LOCDES,
				TED.TMP_ENDDES,
				TED.TMP_PRDORI,
				TED.TMP_PRODUT,
				TED.TMP_LOTECT, 
				TED.TMP_NUMLOT,
				' ' TMP_NUMSER,
				TED.TMP_QTDDES,
				TED.TMP_IDUORI,
				TED.TMP_TPUORI,
				TED.TMP_IDUDES,
				TED.TMP_TPUDES
		FROM %Exp:cTable% TED
		WHERE TED.TMP_OK = %Exp:oMrkBrw:Mark()%
		AND TED.TMP_IDUORI = '  '
		AND TED.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
		oTipUnit    := WMSDTCUnitizadorArmazenagem():New()
		oTransf     := WMSBCCTransferencia():New()
		oRegraConv  := WMSBCCRegraConvocacao():New()
		oTransf:oOrdServ := WMSDTCOrdemServicoCreate():New()
		WmsOrdSer(oTransf:oOrdServ) // Atualiza referencia do objeto WMS
		// Valida se há serviço de transferência definido
		cSrvTransf := oTransf:oMovServic:FindTransf()
		cTarefa    := oTransf:oMovTarefa:GetTarefa()
		If Empty(cSrvTransf)
			WmsMessage(oTransf:oMovServic:GetErro(),WMSA43101,5/*MSG_HELP*/)
			lRet := .F.
		EndIf
		Do While lRet .And. (cAliasQry)->(!Eof())

			lUnitOri  := WmsArmUnit((cAliasQry)->TMP_LOCORI)
			lUnitDes  := WmsArmUnit((cAliasQry)->TMP_LOCDES)
			// Inicializa os objetos
			oTransf:oMovEndOri:ClearData()
			oTransf:oMovEndDes:ClearData()
			oTransf:oMovPrdLot:ClearData()

			// Seta o serviço
			oTransf:oMovServic:SetServico(cSrvTransf)
			// Informações do endereço origem
			oTransf:oMovEndOri:SetArmazem((cAliasQry)->TMP_LOCORI)
			oTransf:oMovEndOri:SetEnder((cAliasQry)->TMP_ENDORI)
			oTransf:oMovEndOri:LoadData()
			// Informações do unitizador origem
			If lUnitOri
				oTransf:SetIdUnit((cAliasQry->TMP_IDUORI))
			Else
				oTransf:SetIdUnit("")
				oTransf:SetTipUni("")
			EndIf

			// Informações do endereço destino
			oTransf:oMovEndDes:SetArmazem((cAliasQry)->TMP_LOCDES)
			oTransf:oMovEndDes:SetEnder((cAliasQry)->TMP_ENDDES)
			oTransf:oMovEndDes:LoadData()
			// Informações do unitizador destino
			If lUnitDes
				oTransf:SetUniDes((cAliasQry->TMP_IDUDES))
				oTransf:SetTipUni((cAliasQry->TMP_TPUDES))
			Else
				oTransf:SetUniDes("")
				oTransf:SetTipUni("")
			EndIf

			If lUnitOri .And. !lUnitDes
				// Busca todos os produtos do unitizador
				cAliasD14 := GetNextAlias()
				BeginSql Alias cAliasD14
					SELECT D14.D14_LOCAL,
							D14.D14_PRODUT,
							D14.D14_PRDORI,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_NUMSER,
							D14.D14_QTDEST,
							D14.D14_QTDES2
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_IDUNIT = %Exp:oTransf:GetIdUnit()%
					AND D14.%NotDel%
				EndSql
				Do While lRet .And. (cAliasD14)->(!Eof())
					// Seta a informação do produto do unitizador
					oTransf:oMovPrdLot:SetArmazem((cAliasD14)->D14_LOCAL)
					oTransf:oMovPrdLot:SetProduto((cAliasD14)->D14_PRODUT)
					oTransf:oMovPrdLot:SetPrdOri((cAliasD14)->D14_PRDORI)
					oTransf:oMovPrdLot:SetLoteCtl((cAliasD14)->D14_LOTECT)
					oTransf:oMovPrdLot:SetNumLote((cAliasD14)->D14_NUMLOT)
					oTransf:oMovPrdLot:SetNumSer((cAliasD14)->D14_NUMSER)
					oTransf:oMovPrdLot:LoadData()
					oTransf:SetQuant((cAliasD14)->D14_QTDEST)
					// Validação do produto
					lRet := ValEndSel()
					(cAliasD14)->(dbSkip())
				EndDo
				(cAliasD14)->(dbCloseArea())
			Else
				If !lUnitOri
					// Seta a informação do produto que está no modelo
					oTransf:oMovPrdLot:SetArmazem((cAliasQry)->TMP_LOCORI)
					oTransf:oMovPrdLot:SetProduto((cAliasQry)->TMP_PRODUT)
					oTransf:oMovPrdLot:SetPrdOri((cAliasQry)->TMP_PRDORI)
					oTransf:oMovPrdLot:SetLoteCtl((cAliasQry)->TMP_LOTECT)
					oTransf:oMovPrdLot:SetNumLote((cAliasQry)->TMP_NUMLOT)
					oTransf:oMovPrdLot:LoadData()
				EndIf
				oTransf:SetQuant((cAliasQry)->TMP_QTDDES)
				// Validação do produto
				lRet := ValEndSel()
			EndIf
			// Gera a ordem de serviço
			If lRet
				cDocto := GetSX8Num("DCF","DCF_DOCTO")
				// Atribui servico
				oTransf:oOrdServ:oServico:SetServico(cSrvTransf)
				// Atribui produto/Lote/Sublote
				oTransf:oOrdServ:oProdLote:SetArmazem((cAliasQry)->TMP_LOCORI)
				oTransf:oOrdServ:oProdLote:SetPrdOri((cAliasQry)->TMP_PRDORI)
				oTransf:oOrdServ:oProdLote:SetProduto((cAliasQry)->TMP_PRODUT)
				oTransf:oOrdServ:oProdLote:SetLoteCtl((cAliasQry)->TMP_LOTECT)
				oTransf:oOrdServ:oProdLote:SetNumLote((cAliasQry)->TMP_NUMLOT)
				// Atribui endereco origem
				oTransf:oOrdServ:oOrdEndOri:SetArmazem((cAliasQry)->TMP_LOCORI)
				oTransf:oOrdServ:oOrdEndOri:SetEnder((cAliasQry)->TMP_ENDORI)
				// Atribui endereco destino
				oTransf:oOrdServ:oOrdEndDes:SetArmazem((cAliasQry)->TMP_LOCDES)
				oTransf:oOrdServ:oOrdEndDes:SetEnder((cAliasQry)->TMP_ENDDES)
				// Atribui informações do unitizador
				oTransf:oOrdServ:SetIdUnit((cAliasQry)->TMP_IDUORI)
				If WmsArmUnit(oTransf:oOrdServ:oOrdEndDes:GetArmazem())
					oTransf:oOrdServ:oOrdEndDes:LoadData()
					If !( cValtoChar(oTransf:oOrdServ:oOrdEndDes:GetTipoEst()) $ "2|7|8" )
						oTransf:oOrdServ:SetUniDes((cAliasQry)->TMP_IDUORI)
						oTransf:oOrdServ:SetTipUni((cAliasQry)->TMP_TPUORI)
					EndIf
				Else
					oTransf:oOrdServ:SetUniDes("")
					oTransf:oOrdServ:SetTipUni("")
				EndIf
				// Atribui quantidade
				oTransf:oOrdServ:SetQuant((cAliasQry)->TMP_QTDDES)
				oTransf:oOrdServ:SetOrigem('DCF')
				If oTransf:oOrdServ:CreateDCF()
					(oTabTmpDfg:GetAlias())->(dbGoTo((cAliasQry)->RECNOTED))
					RecLock(oTabTmpDfg:GetAlias(),.F.)
					(oTabTmpDfg:GetAlias())->(dbDelete())
					(oTabTmpDfg:GetAlias())->(MsUnLock())
				EndIf
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	// Apresenta mensagem de inconsistência da criação das ordens de serviço
	// caso serviço não efetue execução automática 
	If Empty(oTransf:oOrdServ:aLibDCF)
		oTransf:oOrdServ:ShowWarnig()
	EndIf
	// Analisa se tem execução automática
	WmsExeServ()
	// Monta dados para os gráficos
	MntGrfAtu()
	MntGrfDfg()
	// Mostra Gráficos
	MstGrfAtu()
	MstGrfDfg()
	// Atualiza tela
	oMrkBrw:Refresh(.T.)
Return lRet

Static Function ValEndSel()
Local lRet := .T.
	// Verificação do endereço origem
	If !oTransf:ChkEndOri()
		aAdd(oTransf:oOrdServ:aWmsAviso, WMSA43107 + " - " + oTransf:GetErro()) // Erro ChkEndOri
		lRet := .F.
	EndIf
	// Verificação do endereço destino
	If lRet .And. !Empty(oTransf:oMovEndDes:GetEnder())
		If !oTransf:ChkEndDes()
			aAdd(oTransf:oOrdServ:aWmsAviso, WMSA43108 + " - " + oTransf:GetErro()) // Erro ChkEndDes
			lRet := .F.
		EndIf
	EndIf
Return lRet

Static Function SelFiltro()
	If InitParam()
		// Limpa tabela temporária
		LimpTabTmp()
		// Processa parametros
		Processa( {|| WmsEndOcup()} , STR0002, STR0016 + "...", .F. ) // "Desfragmentador de Estoque" ## "Analisando Endereços"
		// Atualiza Browse
		AllMark(.T.)
		// Atualiza Gráficos
		MntGrfAtu()
		MntGrfDfg()
		// Mostra dados nos gráficos
		MstGrfAtu()
		MstGrfDfg()
		// Atualiza tela
		oMrkBrw:Refresh(.T.)
	EndIf
Return
//-----------------------------------
/*{Protheus.doc}
Cria a tabela temporária

@author Alexsander Burigo Corrêa
@version P12
@Since	01/04/2018
@obs Cria a tabela temporária
*/
//-----------------------------------
Static Function WmsEndOcup()
Local lRet       := .T.
	// Avalia endereços para desfragmentar
	ProcRegua(3)
	IncProc(STR0017) // Analise endereços para desfragmentação

	ValSeqAbas() //--Analisa cadastros de sequencia de abastecimento dos produtos

	If !WmsEndOri()
		// Não há endereços para desfragmentação, analise os parâmetros de seleção
		lRet := .F.
	EndIf
	// Avalia endereços destinos disponíveis
	IncProc(STR0018) // Analise endereços destino desfragmentação
	If lRet .And. !WmsEndDes()
		// Não há endereços destinos disponíveis para desfragmentação, analise os parâmetros de seleção
		lRet := .F.
	EndIf
	// Efetua análise da desfragmentação
	IncProc(STR0019) // Processando desfragmentação
	If lRet .And. !WmsMovDfg()
		// Não foi possível desfragmentar os endereços, analise os parâmetros de seleção
		lRet := .F.
	EndIf
Return lRet

Static Function WmsEndOri()
Local lRet       := .T.
Local cQuery     := ""
Local cTable     := "%"+oTabTmpOri:GetRealName()+"%"
Local cAliasQry  := Nil
Local nOrdem     := 0
Local cCodCfgAnt := ""
	// Monta tabela temporária dos endereços que serão desfragmentados
	// Considera somente os endereços com saldo e o endereço não esteja com algum bloqueio
	// e que tenham o percentual de ocupação abaixo do parametro informado
	cQuery := " SELECT SBE.BE_LOCAL,"
	cQuery +=        " SBE.BE_LOCALIZ,"
	cQuery +=        " SBE.BE_ESTFIS,"
	cQuery +=        " SBE.BE_CODCFG,"
	cQuery +=        " SBE.BE_VALNV1,"
	cQuery +=        " SBE.BE_VALNV2,"
	cQuery +=        " SBE.BE_VALNV3,"
	cQuery +=        " SBE.BE_VALNV4,"
	cQuery +=        " SBE.BE_VALNV5,"
	cQuery +=        " SBE.BE_VALNV6,"
	cQuery +=        " 0 PNV_PESNV1,"
	cQuery +=        " 0 PNV_PESNV2,"
	cQuery +=        " 0 PNV_PESNV3,"
	cQuery +=        " 0 PNV_PESNV4,"
	cQuery +=        " 0 PNV_PESNV5,"
	cQuery +=        " 0 PNV_PESNV6,"
	cQuery +=        " 0 PNV_PESLAD"
	cQuery +=  " FROM "+RetSqlName("SBE")+" SBE"
	cQuery += " INNER JOIN "+RetSqlName("DC8")+" DC8"
	cQuery +=    " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
	cQuery +=   " AND DC8.DC8_CODEST = SBE.BE_ESTFIS"
	cQuery +=   " AND DC8.DC8_TPESTR IN ('1','2','4','6')"
	cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
	// Numero de unitizadores
	cQuery += " INNER JOIN (SELECT D14.D14_LOCAL,"
	cQuery +=                    " D14.D14_ENDER,"
	cQuery +=                    " SBE.BE_NRUNIT,"
	cQuery +=                    " SUM( (CASE WHEN SB5.B5_UMIND = '1'"
	cQuery +=                               " THEN D14.D14_QTDEST"
	cQuery +=                               " ELSE D14.D14_QTDES2"
	cQuery +=                                " END) / (DC2.DC2_LASTRO * DC2.DC2_CAMADA) ) D14_NRUNIT"
	cQuery +=               " FROM "+RetSqlName("D14")+" D14"
	cQuery +=              " INNER JOIN "+RetSqlName("SBE")+" SBE"
	cQuery +=                 " ON SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=                " AND SBE.BE_LOCAL = D14.D14_LOCAL"
	cQuery +=                " AND SBE.BE_LOCALIZ = D14.D14_ENDER"
	cQuery +=                " AND SBE.BE_CODZON = '"+cMvZona+"'"
	cQuery +=                " AND SBE.BE_CODZON <> '"+Space(TamSx3("BE_CODZON")[1])+"'"
	cQuery +=                " AND SBE.D_E_L_E_T_ =  ' '"
	cQuery +=              " INNER JOIN "+RetSqlName("DC3")+" DC3"
	cQuery +=                 " ON DC3.DC3_FILIAL = '"+xFilial("DC3")+"'"
	cQuery +=                " AND DC3.DC3_LOCAL = D14.D14_LOCAL"
	cQuery +=                " AND DC3.DC3_CODPRO = D14.D14_PRODUT"
	cQuery +=                " AND DC3.DC3_TPESTR = D14.D14_ESTFIS"
	cQuery +=                " AND DC3.D_E_L_E_T_ = ' '"
	cQuery +=              " INNER JOIN "+RetSqlName("DC2")+" DC2"
	cQuery +=                 " ON DC2.DC2_FILIAL = '"+xFilial("DC2")+"'"
	cQuery +=                " AND DC2.DC2_CODNOR = DC3.DC3_CODNOR"
	cQuery +=                " AND DC2.D_E_L_E_T_ = ' '"
	cQuery +=              " INNER JOIN "+RetSqlName("SB5")+" SB5"
	cQuery +=                 " ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
	cQuery +=                " AND SB5.B5_COD = D14.D14_PRODUT"
	cQuery +=                " AND SB5.D_E_L_E_T_ = ' '"
	cQuery +=              " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                " AND D14.D_E_L_E_T_ = ' '"
	cQuery +=              " GROUP BY D14.D14_LOCAL,"
	cQuery +=                       " D14.D14_ENDER,"
	cQuery +=                       " SBE.BE_NRUNIT"
	cQuery +=             " HAVING SUM(D14.D14_QTDEST) > 0"
	cQuery +=                " AND SUM(D14.D14_QTDEPR + D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDEMP) = 0"
	cQuery +=              ") UNT"
	cQuery +=    " ON UNT.D14_LOCAL = SBE.BE_LOCAL"
	cQuery +=   " AND UNT.D14_ENDER = SBE.BE_LOCALIZ"
	cQuery +=   " AND (CASE WHEN UNT.BE_NRUNIT <= 0 THEN 0 ELSE (UNT.D14_NRUNIT / UNT.BE_NRUNIT * 100) END)  <= "+cValtoChar(nMvPercOcu)
	// Peso e cubagem
	cQuery += " INNER JOIN (SELECT NRU.D14_LOCAL D14_LOCAL,"
	cQuery +=                    " NRU.D14_ENDER D14_ENDER,"
	cQuery +=                    " SUM (D0T_TARA * NRU.D14_NRUNIT) CAP_PESO,"
	cQuery +=                    " SUM ((D0T_ALTURA * D0T_LARGUR * D0T_COMPRI) * NRU.D14_NRUNIT) CAP_VOLUME"
	cQuery +=               " FROM "+RetSqlName("D0T")+" D0T"
	cQuery +=              " INNER JOIN (SELECT D14.D14_LOCAL,"
	cQuery +=                                 " D14.D14_ENDER,"
	cQuery +=                                 " D14.D14_CODUNI,"
	cQuery +=                                 " COUNT(DISTINCT D14.D14_IDUNIT) D14_NRUNIT"
	cQuery +=                            " FROM "+RetSqlName("D14")+" D14"
	cQuery +=                           " INNER JOIN "+RetSqlName("SBE")+" SBE"
	cQuery +=                              " ON SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=                             " AND SBE.BE_LOCAL = D14.D14_LOCAL"
	cQuery +=                             " AND SBE.BE_LOCALIZ = D14.D14_ENDER"
	cQuery +=                             " AND SBE.BE_CODZON = '"+cMvZona+"'"
	cQuery +=                             " AND SBE.BE_CODZON <> '"+Space(TamSx3("BE_CODZON")[1])+"'"
	cQuery +=                             " AND SBE.D_E_L_E_T_ =  ' '"
	cQuery +=                           " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                             " AND D14.D14_LOCAL = '"+cMvLocal+"'"
	cQuery +=                             " AND D14.D14_ENDER  BETWEEN '"+cMvEOriDe+"' AND '"+cMvEOriAte+"'"
	cQuery +=                             " AND D14.D14_IDUNIT <> '"+Space(TamSx3("D14_IDUNIT")[1])+"'"
	cQuery +=                             " AND D14.D_E_L_E_T_ = ' '"
	cQuery +=                           " GROUP BY D14.D14_LOCAL,"
	cQuery +=                                    " D14.D14_ENDER,"
	cQuery +=                                    " D14.D14_CODUNI"
	cQuery +=                          " HAVING SUM(D14.D14_QTDEST) > 0"
	cQuery +=                             " AND SUM(D14.D14_QTDEPR + D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDEMP) = 0"
	cQuery +=                           ") NRU"
	cQuery +=                 " ON D0T.D0T_CODUNI = NRU.D14_CODUNI"
	cQuery +=              " WHERE D0T.D0T_FILIAL = '"+xFilial("D0T")+"'"
	cQuery +=                " AND D0T.D0T_CTRALT = '1'"
	cQuery +=                " AND D0T.D_E_L_E_T_ = ' '"
	cQuery +=              " GROUP BY NRU.D14_LOCAL,"
	cQuery +=                       " NRU.D14_ENDER"
	cQuery +=              " UNION ALL"
	cQuery +=             " SELECT NRU.D14_LOCAL D14_LOCAL,"
	cQuery +=                    " NRU.D14_ENDER D14_ENDER,"
	cQuery +=                    " SUM (D0T_TARA * NRU.D14_NRUNIT) D0T_PESUNI,"
	cQuery +=                    " SUM ((D0T_ALTURA * D0T_LARGUR * D0T_COMPRI) * NRU.D14_NRUNIT) D0T_VOLUNI"
	cQuery +=               " FROM "+RetSqlName("D0T")+" D0T"
	cQuery +=              " INNER JOIN (SELECT D14.D14_LOCAL,"
	cQuery +=                                 " D14.D14_ENDER,"
	cQuery +=                                 " D14.D14_CODUNI,"
	cQuery +=                                 " COUNT(DISTINCT D14.D14_IDUNIT) D14_NRUNIT"
	cQuery +=                            " FROM "+RetSqlName("D14")+" D14"
	cQuery +=                           " INNER JOIN "+RetSqlName("SBE")+" SBE"
	cQuery +=                              " ON SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=                             " AND SBE.BE_LOCAL = D14.D14_LOCAL"
	cQuery +=                             " AND SBE.BE_LOCALIZ = D14.D14_ENDER"
	cQuery +=                             " AND SBE.BE_CODZON = '"+cMvZona+"'"
	cQuery +=                             " AND SBE.BE_CODZON <> '"+Space(TamSx3("BE_CODZON")[1])+"'"
	cQuery +=                             " AND SBE.D_E_L_E_T_ =  ' '"
	cQuery +=                           " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                             " AND D14.D14_LOCAL = '"+cMvLocal+"'"
	cQuery +=                             " AND D14.D14_ENDER BETWEEN '"+cMvEOriDe+"' AND '"+cMvEOriAte+"'"
	cQuery +=                             " AND D14.D14_IDUNIT <> '"+Space(TamSx3("D14_IDUNIT")[1])+"'"
	cQuery +=                             " AND D14.D_E_L_E_T_ = ' '"
	cQuery +=                           " GROUP BY D14.D14_LOCAL,"
	cQuery +=                                    " D14.D14_ENDER,"
	cQuery +=                                    " D14.D14_CODUNI"
	cQuery +=                    	   " HAVING SUM(D14.D14_QTDEST) > 0"
	cQuery +=                    	      " AND SUM(D14.D14_QTDEPR + D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDEMP) = 0"
	cQuery +=                    ") NRU"
	cQuery +=                 " ON D0T.D0T_CODUNI = NRU.D14_CODUNI"
	cQuery +=              " WHERE D0T.D0T_FILIAL = '"+xFilial("D0T")+"'"
	cQuery +=                " AND D0T.D0T_CTRALT = '2'"
	cQuery +=                " AND D0T.D_E_L_E_T_ = ' '"
	cQuery +=              " GROUP BY NRU.D14_LOCAL,"
	cQuery +=                       " NRU.D14_ENDER"
	cQuery +=              " UNION ALL"
	cQuery +=             " SELECT D14.D14_LOCAL D14_LOCAL,"
	cQuery +=                    " D14.D14_ENDER D14_ENDER,"
	cQuery +=                    " SUM(SB1.B1_PESBRU * ( D14.D14_QTDEST + D14.D14_QTDEPR))  CAP_PESO,"
	cQuery +=                    " SUM( ( (SB5.B5_COMPRLC * SB5.B5_LARGLC * SB5.B5_ALTURLC ) * (CASE WHEN SB5.B5_UMIND = '1'"
	cQuery +=                                                                                      " THEN (D14.D14_QTDEST + D14.D14_QTDEPR)"
	cQuery +=                                                                                      " ELSE ( D14.D14_QTDES2 + D14.D14_QTDEP2)"
	cQuery +=                                                                                       " END ) ) ) CAP_VOLUME"
	cQuery +=               " FROM "+RetSqlName("D14")+" D14"
	cQuery +=              " INNER JOIN "+RetSqlName("SBE")+" SBE"
	cQuery +=                 " ON SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=                " AND SBE.BE_LOCAL = D14.D14_LOCAL"
	cQuery +=                " AND SBE.BE_LOCALIZ = D14.D14_ENDER"
	cQuery +=                " AND SBE.BE_CODZON = '"+cMvZona+"'"
	cQuery +=                " AND SBE.BE_CODZON <> '"+Space(TamSx3("BE_CODZON")[1])+"'"
	cQuery +=                " AND SBE.D_E_L_E_T_ =  ' '"
	cQuery +=              " INNER JOIN "+RetSqlName("SB1")+" SB1"
	cQuery +=                 " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery +=                " AND SB1.B1_COD = D14.D14_PRODUT"
	cQuery +=                " AND SB1.D_E_L_E_T_ = ' '"
	cQuery +=              " INNER JOIN "+RetSqlName("SB5")+" SB5"
	cQuery +=                 " ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
	cQuery +=                " AND SB5.B5_COD = SB1.B1_COD"
	cQuery +=                " AND SB5.D_E_L_E_T_ = ' '"
	cQuery +=              " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                " AND D14.D14_LOCAL = '"+cMvLocal+"'"
	cQuery +=                " AND D14.D14_ENDER BETWEEN '"+cMvEOriDe+"' AND '"+cMvEOriAte+"'"
	cQuery +=                " AND D14.D14_IDUNIT = '"+Space(TamSx3("D14_IDUNIT")[1])+"'"
	cQuery +=                " AND D14.D_E_L_E_T_ = ' '"
	cQuery +=              " GROUP BY D14.D14_LOCAL,"
	cQuery +=                       " D14.D14_ENDER"
	cQuery +=              " HAVING SUM(D14.D14_QTDEST) > 0"
	cQuery +=                 " AND SUM(D14.D14_QTDEPR + D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDEMP) = 0"
	cQuery +=              ") CAP"
	cQuery +=    " ON CAP.D14_LOCAL = SBE.BE_LOCAL"
	cQuery +=   " AND CAP.D14_ENDER = SBE.BE_LOCALIZ"
	cQuery +=   " AND (CASE WHEN SBE.BE_CAPACID <= 0 THEN 0 ELSE (CAP.CAP_PESO / SBE.BE_CAPACID * 100) END) <= "+cValtoChar(nMvPercOcu)
   	cQuery +=   " AND (CASE WHEN (SBE.BE_ALTURLC * SBE.BE_LARGLC * SBE.BE_COMPRLC) <= 0 THEN 0 ELSE ((CAP.CAP_VOLUME / (SBE.BE_ALTURLC * SBE.BE_LARGLC * SBE.BE_COMPRLC)) * 100) END) <= "+cValtoChar(nMvPercOcu)
	cQuery += " WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=   " AND SBE.BE_LOCAL  = '"+cMvLocal+"'"
	cQuery +=   " AND SBE.BE_LOCALIZ BETWEEN '"+cMvEOriDe+ "' AND '"+cMvEOriAte+"'"
	cQuery +=   " AND SBE.BE_CODZON = '"+cMvZona+"'"
	cQuery +=   " AND SBE.BE_CODZON <> '"+Space(TamSx3("BE_CODZON")[1])+"'"
	cQuery +=   " AND SBE.D_E_L_E_T_ =  ' '"
	cQuery += " ORDER BY SBE.BE_LOCAL,"
	cQuery +=          " SBE.BE_CODZON,"
	cQuery +=          " SBE.BE_ESTFIS,"
	cQuery +=          " SBE.BE_LOCALIZ"
	cQuery := ChangeQuery(cQuery)
	WmsQry2Tmp(,aArqTabOri,cQuery,oTabTmpOri,.T.)
	(cAliasTOri)->(dbGoTop())
	lRet := (cAliasTOri)->(!Eof())
	If lRet
		// Atualiza informação se produto compartilha endereço
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DC7.DC7_CODCFG,
					CASE WHEN DC7.DC7_PESO1 IS NULL THEN 0 ELSE DC7.DC7_PESO1 END DC7_PESO1,
					CASE WHEN DC7.DC7_PESO2 IS NULL THEN 0 ELSE DC7.DC7_PESO2 END DC7_PESO2
			FROM %Table:DC7% DC7
			WHERE DC7.DC7_FILIAL = %xFilial:DC7%
			AND EXISTS (SELECT 1
						FROM %Exp:cTable% TMP
						WHERE TMP.TMP_CODCFG = DC7.DC7_CODCFG
						AND TMP.%NotDel% )
			AND DC7.%NotDel%
			ORDER BY DC7.DC7_CODCFG,
						DC7.DC7_SEQUEN
		EndSql
		Do While lRet .And. (cAliasQry)->(!Eof())
			If !(cCodCfgAnt = (cAliasQry)->DC7_CODCFG)
				cCodCfgAnt := (cAliasQry)->DC7_CODCFG
				nOrdem     := 0
			EndIf
			// Inicializa ordem quando inicio de configuração
			nOrdem += 1
			// Atualiza peso nivel
			cQuery := "UPDATE "+oTabTmpOri:GetRealName()
			Do Case
				Case nOrdem == 1
				cQuery += " SET TMP_PESNV1 = "+cValtoChar((cAliasQry)->DC7_PESO2)+","
				cQuery +=     " TMP_PESLAD = "+cValtoChar((cAliasQry)->DC7_PESO1)
				Case nOrdem == 2
				cQuery += " SET TMP_PESNV2 = "+cValtoChar((cAliasQry)->DC7_PESO2)
				Case nOrdem == 3
				cQuery += " SET TMP_PESNV3 = "+cValtoChar((cAliasQry)->DC7_PESO2)
				Case nOrdem == 4
				cQuery += " SET TMP_PESNV4 = "+cValtoChar((cAliasQry)->DC7_PESO2)
				Case nOrdem == 5
				cQuery += " SET TMP_PESNV5 = "+cValtoChar((cAliasQry)->DC7_PESO2)
				Case nOrdem == 6
				cQuery += " SET TMP_PESNV6 = "+cValtoChar((cAliasQry)->DC7_PESO2)
			EndCase
			cQuery += " WHERE TMP_CODCFG = '"+(cAliasQry)->DC7_CODCFG+"'"
			cQuery +=   " AND D_E_L_E_T_ = ' '"
			lRet := (TcSQLExec(cQuery) >= 0)
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet

Static Function WmsEndDes()
Local lRet       := .T.
Local cQuery     := ""
Local cTable     := "%"+oTabTmpDes:GetRealName()+"%"
Local cAliasQry  := Nil
Local nOrdem     := 0
Local cCodCfgAnt := ""
Local cIsNull	 := ""
Local cTipoDB	 := Alltrim(Upper(TCGetDB()))

	// Monta tabela temporária dos endereços
	// Considera somente os endereços com saldo e o endereço não esteja com algum bloqueio
	cQuery := " SELECT SBE.BE_LOCAL,"
	cQuery +=        " SBE.BE_LOCALIZ,"
	cQuery +=        " SBE.BE_ESTFIS,"
	cQuery +=        " SBE.BE_ALTURLC,"
	cQuery +=        " SBE.BE_LARGLC,"
	cQuery +=        " SBE.BE_COMPRLC,"
	cQuery +=        " SBE.BE_CODCFG,"
	cQuery +=        " SBE.BE_VALNV1,"
	cQuery +=        " SBE.BE_VALNV2,"
	cQuery +=        " SBE.BE_VALNV3,"
	cQuery +=        " SBE.BE_VALNV4,"
	cQuery +=        " SBE.BE_VALNV5,"
	cQuery +=        " SBE.BE_VALNV6,"
	cQuery +=        " 0 PNV_PESNV1,"
	cQuery +=        " 0 PNV_PESNV2,"
	cQuery +=        " 0 PNV_PESNV3,"
	cQuery +=        " 0 PNV_PESNV4,"
	cQuery +=        " 0 PNV_PESNV5,"
	cQuery +=        " 0 PNV_PESNV6,"
	cQuery +=        " 0 PNV_PESLAD,"
	cQuery +=        " ' ' DC3_TIPEND,"
	cQuery +=        " CASE WHEN SBE.BE_NRUNIT = 0 THEN UNT.QTD_NORMA  ELSE (SBE.BE_NRUNIT * UNT.QTD_NORMA) END TMP_QTDCAP,"
	cQuery +=        " CASE WHEN SLD.D14_QTDEST IS NULL THEN 0 ELSE SLD.D14_QTDEST END TMP_QTDOCU,"
	cQuery +=        " CASE WHEN SLD.D14_QTDEST IS NULL THEN 0 ELSE SLD.D14_QTDEST END TMP_QTDORI,"
	cQuery +=        " CASE WHEN SBE.BE_NRUNIT = 0 THEN 1 ELSE SBE.BE_NRUNIT END BE_NRUNIT,"
	cQuery +=        " CASE WHEN UNT.D14_NRUNIT IS NULL THEN 0 ELSE UNT.D14_NRUNIT END D14_NRUNIT,"
	cQuery +=        " SBE.BE_CAPACID,"
	cQuery +=        " CASE WHEN CAP.CAP_PESO IS NULL THEN 0 ELSE CAP.CAP_PESO END CAP_PESO,"
	cQuery +=        " (SBE.BE_ALTURLC * SBE.BE_LARGLC * SBE.BE_COMPRLC) BE_VOLUME,"
	cQuery +=        " CASE WHEN CAP.CAP_VOLUME IS NULL THEN 0 ELSE CAP.CAP_VOLUME END CAP_VOLUME,"
	cQuery +=        " SBE.BE_CODPRO,"
	cQuery +=        " CASE WHEN SLD.D14_PRODUT IS NULL THEN ' ' ELSE SLD.D14_PRODUT END SLD_PRMPRD,"
	cQuery +=        " UNT.QTD_NORMA,"
	cQuery +=        " CASE WHEN SLD.SLD_NROPRD > 1 THEN '1' ELSE '2' END SLD_PRDDIF,"
	cQuery +=        " '2'"
	cQuery +=  " FROM "+RetSqlName("SBE")+" SBE"
	cQuery += " INNER JOIN "+RetSqlName("DC8")+" DC8"
	cQuery +=    " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
	cQuery +=   " AND DC8.DC8_CODEST = SBE.BE_ESTFIS"
	cQuery +=   " AND DC8.DC8_TPESTR IN ('1','2','4','6')"
	cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
	// Numero de unitizadores e quantida norma total
	cQuery += " INNER JOIN (SELECT D14.D14_LOCAL,"
	cQuery +=                    " D14.D14_ENDER,"
	cQuery +=                    " MAX((CASE WHEN SB5.B5_UMIND = '1'"
	cQuery +=                               " THEN 1"
	cQuery +=                               " ELSE SB1.B1_CONV"
	cQuery +=                                " END) * (DC2.DC2_LASTRO*DC2.DC2_CAMADA)) QTD_NORMA,"
	cQuery +=                    " SUM( (CASE WHEN SB5.B5_UMIND = '1'"
	cQuery +=                               " THEN (D14.D14_QTDEST+D14.D14_QTDEPR)"
	cQuery +=                               " ELSE (D14.D14_QTDES2+D14.D14_QTDEP2)"
	cQuery +=                                " END) / (DC2.DC2_LASTRO*DC2.DC2_CAMADA) ) D14_NRUNIT"
	cQuery +=               " FROM "+RetSqlName("D14")+" D14"
	cQuery +=              " INNER JOIN "+RetSqlName("SBE")+" SBE"
	cQuery +=                 " ON SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=                " AND SBE.BE_LOCAL = D14.D14_LOCAL"
	cQuery +=                " AND SBE.BE_LOCALIZ = D14.D14_ENDER"
	cQuery +=                " AND SBE.BE_CODZON = '"+cMvZona+"'"
	cQuery +=                " AND SBE.BE_CODZON <> '"+Space(TamSx3("BE_CODZON")[1])+"'"
	cQuery +=                " AND SBE.D_E_L_E_T_ =  ' '"
	cQuery +=              " INNER JOIN "+RetSqlName("DC3")+" DC3"
	cQuery +=                 " ON DC3.DC3_FILIAL = '"+xFilial("DC3")+"'"
	cQuery +=                " AND DC3.DC3_LOCAL = D14.D14_LOCAL"
	cQuery +=                " AND DC3.DC3_CODPRO = D14.D14_PRODUT"
	cQuery +=                " AND DC3.DC3_TPESTR = D14.D14_ESTFIS"
	cQuery +=                " AND DC3.D_E_L_E_T_ = ' '"
	cQuery +=              " INNER JOIN "+RetSqlName("DC2")+" DC2"
	cQuery +=                 " ON DC2.DC2_FILIAL = '"+xFilial("DC2")+"'"
	cQuery +=                " AND DC2.DC2_CODNOR = DC3.DC3_CODNOR"
	cQuery +=                " AND DC2.D_E_L_E_T_ = ' '"
	cQuery +=              " INNER JOIN "+RetSqlName("SB1")+" SB1"
	cQuery +=                 " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery +=                " AND SB1.B1_COD = D14.D14_PRODUT"
	cQuery +=                " AND SB1.D_E_L_E_T_ = ' '"
	cQuery +=              " INNER JOIN "+RetSqlName("SB5")+" SB5"
	cQuery +=                 " ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
	cQuery +=                " AND SB5.B5_COD = D14.D14_PRODUT"
	cQuery +=                " AND SB5.D_E_L_E_T_ = ' '"
	cQuery +=              " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                " AND (D14.D14_QTDEST + D14.D14_QTDEPR) > 0"
	cQuery +=                " AND D14.D_E_L_E_T_ = ' '"
	cQuery +=              " GROUP BY D14.D14_LOCAL,"
	cQuery +=                       " D14.D14_ENDER) UNT"
	cQuery +=    " ON UNT.D14_LOCAL = SBE.BE_LOCAL"
	cQuery +=   " AND UNT.D14_ENDER = SBE.BE_LOCALIZ"
	// Peso e cubagem
	cQuery += " INNER JOIN (SELECT NRU.D14_LOCAL D14_LOCAL,"
	cQuery +=                    " NRU.D14_ENDER D14_ENDER,"
	cQuery +=                    " SUM (D0T_TARA * NRU.D14_NRUNIT) CAP_PESO,"
	cQuery +=                    " SUM ((D0T_ALTURA * D0T_LARGUR * D0T_COMPRI) * NRU.D14_NRUNIT) CAP_VOLUME"
	cQuery +=               " FROM "+RetSqlName("D0T")+" D0T"
	cQuery +=              " INNER JOIN (SELECT D14.D14_LOCAL,"
	cQuery +=                                 " D14.D14_ENDER,"
	cQuery +=                                 " D14.D14_CODUNI,"
	cQuery +=                                 " COUNT(DISTINCT D14.D14_IDUNIT) D14_NRUNIT"
	cQuery +=                            " FROM "+RetSqlName("D14")+" D14"
	cQuery +=                           " INNER JOIN "+RetSqlName("SBE")+" SBE"
	cQuery +=                              " ON SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=                             " AND SBE.BE_LOCAL = D14.D14_LOCAL"
	cQuery +=                             " AND SBE.BE_LOCALIZ = D14.D14_ENDER"
	cQuery +=                             " AND SBE.BE_CODZON = '"+cMvZona+"'"
	cQuery +=                             " AND SBE.BE_CODZON <> '"+Space(TamSx3("BE_CODZON")[1])+"'"
	cQuery +=                             " AND SBE.D_E_L_E_T_ =  ' '"
	cQuery +=                           " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                             " AND D14.D14_LOCAL = '"+cMvLocal+"'"
	cQuery +=                             " AND D14.D14_ENDER  BETWEEN '"+cMvEDesDe+"' AND '"+cMvEDesAte+"'"
	cQuery +=                             " AND (D14.D14_QTDEST + D14.D14_QTDEPR) > 0"
	cQuery +=                             " AND D14.D14_IDUNIT <> '"+Space(TamSx3("D14_IDUNIT")[1])+"'"
	cQuery +=                             " AND D14.D_E_L_E_T_ = ' '"
	cQuery +=                           " GROUP BY D14.D14_LOCAL,"
	cQuery +=                                    " D14.D14_ENDER,"
	cQuery +=                                    " D14.D14_CODUNI) NRU"
	cQuery +=                 " ON D0T.D0T_CODUNI = NRU.D14_CODUNI"
	cQuery +=              " WHERE D0T.D0T_FILIAL = '"+xFilial("D0T")+"'"
	cQuery +=                " AND D0T.D0T_CTRALT = '1'"
	cQuery +=                " AND D0T.D_E_L_E_T_ = ' '"
	cQuery +=              " GROUP BY NRU.D14_LOCAL,"
	cQuery +=                       " NRU.D14_ENDER"
	cQuery +=              " UNION ALL"
	cQuery +=             " SELECT NRU.D14_LOCAL D14_LOCAL,"
	cQuery +=                    " NRU.D14_ENDER D14_ENDER,"
	cQuery +=                    " SUM (D0T_TARA * NRU.D14_NRUNIT) D0T_PESUNI,"
	cQuery +=                    " SUM ((D0T_ALTURA * D0T_LARGUR * D0T_COMPRI) * NRU.D14_NRUNIT) D0T_VOLUNI"
	cQuery +=               " FROM "+RetSqlName("D0T")+" D0T"
	cQuery +=              " INNER JOIN (SELECT D14.D14_LOCAL,"
	cQuery +=                                 " D14.D14_ENDER,"
	cQuery +=                                 " D14.D14_CODUNI,"
	cQuery +=                                 " COUNT(DISTINCT D14.D14_IDUNIT) D14_NRUNIT"
	cQuery +=                            " FROM "+RetSqlName("D14")+" D14"
	cQuery +=                           " INNER JOIN "+RetSqlName("SBE")+" SBE"
	cQuery +=                              " ON SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=                             " AND SBE.BE_LOCAL = D14.D14_LOCAL"
	cQuery +=                             " AND SBE.BE_LOCALIZ = D14.D14_ENDER"
	cQuery +=                             " AND SBE.BE_CODZON = '"+cMvZona+"'"
	cQuery +=                             " AND SBE.BE_CODZON <> '"+Space(TamSx3("BE_CODZON")[1])+"'"
	cQuery +=                             " AND SBE.D_E_L_E_T_ =  ' '"
	cQuery +=                           " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                             " AND D14.D14_LOCAL = '"+cMvLocal+"'"
	cQuery +=                             " AND D14.D14_ENDER BETWEEN '"+cMvEDesDe+"' AND '"+cMvEDesAte+"'"
	cQuery +=                             " AND (D14.D14_QTDEST + D14.D14_QTDEPR) > 0"
	cQuery +=                             " AND D14.D14_IDUNIT <> '"+Space(TamSx3("D14_IDUNIT")[1])+"'"
	cQuery +=                             " AND D14.D_E_L_E_T_ = ' '"
	cQuery +=                           " GROUP BY D14.D14_LOCAL,"
	cQuery +=                                    " D14.D14_ENDER,"
	cQuery +=                                    " D14.D14_CODUNI) NRU"
	cQuery +=                 " ON D0T.D0T_CODUNI = NRU.D14_CODUNI"
	cQuery +=              " WHERE D0T.D0T_FILIAL = '"+xFilial("D0T")+"'"
	cQuery +=                " AND D0T.D0T_CTRALT = '2'"
	cQuery +=                " AND D0T.D_E_L_E_T_ = ' '"
	cQuery +=              " GROUP BY NRU.D14_LOCAL,"
	cQuery +=                       " NRU.D14_ENDER"
	cQuery +=              " UNION ALL"
	cQuery +=             " SELECT D14.D14_LOCAL D14_LOCAL,"
	cQuery +=                    " D14.D14_ENDER D14_ENDER,"
	cQuery +=                    " SUM(SB1.B1_PESBRU * ( D14.D14_QTDEST + D14.D14_QTDEPR))  CAP_PESO,"
	cQuery +=                    " SUM( ( (SB5.B5_COMPRLC * SB5.B5_LARGLC * SB5.B5_ALTURLC ) * (CASE WHEN SB5.B5_UMIND = '1'"
	cQuery +=                                                                                      " THEN (D14.D14_QTDEST + D14.D14_QTDEPR)"
	cQuery +=                                                                                      " ELSE ( D14.D14_QTDES2 + D14.D14_QTDEP2)"
	cQuery +=                                                                                       " END ) ) ) CAP_VOLUME"
	cQuery +=               " FROM "+RetSqlName("D14")+" D14"
	cQuery +=              " INNER JOIN "+RetSqlName("SBE")+" SBE"
	cQuery +=                 " ON SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=                " AND SBE.BE_LOCAL = D14.D14_LOCAL"
	cQuery +=                " AND SBE.BE_LOCALIZ = D14.D14_ENDER"
	cQuery +=                " AND SBE.BE_CODZON = '"+cMvZona+"'"
	cQuery +=                " AND SBE.BE_CODZON <> '"+Space(TamSx3("BE_CODZON")[1])+"'"
	cQuery +=                " AND SBE.D_E_L_E_T_ =  ' '"
	cQuery +=              " INNER JOIN "+RetSqlName("SB1")+" SB1"
	cQuery +=                 " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery +=                " AND SB1.B1_COD = D14.D14_PRODUT"
	cQuery +=                " AND SB1.D_E_L_E_T_ = ' '"
	cQuery +=              " INNER JOIN "+RetSqlName("SB5")+" SB5"
	cQuery +=                 " ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
	cQuery +=                " AND SB5.B5_COD = SB1.B1_COD"
	cQuery +=                " AND SB5.D_E_L_E_T_ = ' '"
	cQuery +=              " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                " AND D14.D14_LOCAL = '"+cMvLocal+"'"
	cQuery +=                " AND D14.D14_ENDER BETWEEN '"+cMvEDesDe+"' AND '"+cMvEDesAte+"'"
	cQuery +=                " AND (D14.D14_QTDEST + D14.D14_QTDEPR) > 0"
	cQuery +=                " AND D14.D14_IDUNIT = '"+Space(TamSx3("D14_IDUNIT")[1])+"'"
	cQuery +=                " AND D14.D_E_L_E_T_ = ' '"
	cQuery +=              " GROUP BY D14.D14_LOCAL,"
	cQuery +=                       " D14.D14_ENDER) CAP"
	cQuery +=    " ON CAP.D14_LOCAL = SBE.BE_LOCAL"
	cQuery +=   " AND CAP.D14_ENDER = SBE.BE_LOCALIZ"
	// Primeiro produto, quantidade estoque e entrada prevista
	cQuery += " INNER JOIN ( SELECT D14.D14_LOCAL,"
	cQuery +=                     " D14.D14_ENDER,"
	cQuery +=                     " COUNT(DISTINCT D14.D14_PRODUT) SLD_NROPRD,"
	cQuery +=                     " MIN(D14.D14_PRODUT) D14_PRODUT,"
	cQuery +=                     " SUM(D14.D14_QTDEST + D14.D14_QTDEPR) D14_QTDEST"
	cQuery +=                " FROM "+RetSqlName("D14")+" D14"
	cQuery +=               " INNER JOIN "+RetSqlName("SBE")+" SBE"
	cQuery +=                  " ON SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=                 " AND SBE.BE_LOCAL = D14.D14_LOCAL"
	cQuery +=                 " AND SBE.BE_LOCALIZ = D14.D14_ENDER""
	cQuery +=                 " AND SBE.BE_CODZON = '"+cMvZona+"'"
	cQuery +=                 " AND SBE.BE_CODZON <> '"+Space(TamSx3("BE_CODZON")[1])+"'"
	cQuery +=                 " AND SBE.D_E_L_E_T_ =  ' '"
	cQuery +=               " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=                 " AND (D14.D14_QTDEST + D14.D14_QTDEPR) > 0"
	cQuery +=                 " AND D14.D_E_L_E_T_ = ' '"
	cQuery +=               " GROUP BY D14.D14_LOCAL,"
	cQuery +=                        " D14.D14_ENDER) SLD"
	cQuery +=    " ON SLD.D14_LOCAL = SBE.BE_LOCAL"
	cQuery +=   " AND SLD.D14_ENDER = SBE.BE_LOCALIZ"
	cQuery += " WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=   " AND SBE.BE_LOCAL  = '"+cMvLocal+"'"
	cQuery +=   " AND SBE.BE_LOCALIZ BETWEEN '"+cMvEDesDe+ "' AND '"+cMvEDesAte+"'"
	cQuery +=   " AND SBE.BE_CODZON = '"+cMvZona+"'"
	cQuery +=   " AND SBE.BE_CODZON <> '"+Space(TamSx3("BE_CODZON")[1])+"'"
	cQuery +=   " AND SBE.D_E_L_E_T_ =  ' '"
	cQuery += " ORDER BY SBE.BE_LOCAL,"
	cQuery +=          " SBE.BE_CODZON,"
	cQuery +=          " SBE.BE_ESTFIS,"
	cQuery +=          " SBE.BE_LOCALIZ"
	cQuery := ChangeQuery(cQuery)
	WmsQry2Tmp(,aArqTabDes,cQuery,oTabTmpDes,.T.)
	(cAliasTDes)->(dbGoTop())
	lRet := (cAliasTDes)->(!Eof())

	//--Tratamento realizado devido ausência de ChangeQuery() 
	If ("INFORMIX" $ cTipoDB) .Or. ("ORACLE" $ cTipoDB)
		cIsNull	:= "NVL"
	ElseIf ("DB2" $ cTipoDB)  .Or. ("POSTGRES" $ cTipoDB)
		cIsNull	:= "COALESCE"
	Else
		cIsNull	:= "ISNULL"
	EndIf

	If lRet
		// Atualiza informação se produto compartilha endereço
		cQuery := "UPDATE "+oTabTmpDes:GetRealName()
		cQuery += " SET TMP_TIPEND = " + cIsNull + "( (SELECT DC3.DC3_TIPEND"
		cQuery +=                     " FROM "+RetSqlName("DC3")+" DC3"
		cQuery +=                    " WHERE DC3.DC3_FILIAL = '"+xFilial("DC3")+"'"
		cQuery +=                      " AND DC3.DC3_CODPRO = TMP_PRDAUX"
		cQuery +=                      " AND DC3.DC3_LOCAL = TMP_LOCAL"
		cQuery +=                      " AND DC3.DC3_TPESTR = TMP_ESTFIS"
		cQuery +=                      " AND DC3.D_E_L_E_T_ = ' '), ' ')"

		lRet := (TcSQLExec(cQuery) >= 0)
	EndIf
	If lRet
		// Atualiza informação se produto compartilha endereço
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DC7.DC7_CODCFG,
					CASE WHEN DC7.DC7_PESO1 IS NULL THEN 0 ELSE DC7.DC7_PESO1 END DC7_PESO1,
					CASE WHEN DC7.DC7_PESO2 IS NULL THEN 0 ELSE DC7.DC7_PESO2 END DC7_PESO2
			FROM %Table:DC7% DC7
			WHERE DC7.DC7_FILIAL = %xFilial:DC7%
			AND EXISTS (SELECT 1
						FROM %Exp:cTable% TMP
						WHERE TMP.TMP_CODCFG = DC7.DC7_CODCFG
						AND TMP.%NotDel% )
			AND DC7.%NotDel%
			ORDER BY DC7.DC7_CODCFG,
						DC7.DC7_SEQUEN
		EndSql
		Do While lRet .And. (cAliasQry)->(!Eof())
			If !(cCodCfgAnt = (cAliasQry)->DC7_CODCFG)
				cCodCfgAnt := (cAliasQry)->DC7_CODCFG
				nOrdem     := 0
			EndIf
			// Inicializa ordem quando inicio de configuração
			nOrdem += 1
			// Atualiza peso nivel
			cQuery := "UPDATE "+oTabTmpDes:GetRealName()
			Do Case
				Case nOrdem == 1
				cQuery += " SET TMP_PESNV1 = "+cValtoChar((cAliasQry)->DC7_PESO2)+","
				cQuery +=     " TMP_PESLAD = "+cValtoChar((cAliasQry)->DC7_PESO1)
				Case nOrdem == 2
				cQuery += " SET TMP_PESNV2 = "+cValtoChar((cAliasQry)->DC7_PESO2)
				Case nOrdem == 3
				cQuery += " SET TMP_PESNV3 = "+cValtoChar((cAliasQry)->DC7_PESO2)
				Case nOrdem == 4
				cQuery += " SET TMP_PESNV4 = "+cValtoChar((cAliasQry)->DC7_PESO2)
				Case nOrdem == 5
				cQuery += " SET TMP_PESNV5 = "+cValtoChar((cAliasQry)->DC7_PESO2)
				Case nOrdem == 6
				cQuery += " SET TMP_PESNV6 = "+cValtoChar((cAliasQry)->DC7_PESO2)
			EndCase
			cQuery += " WHERE TMP_CODCFG = '"+(cAliasQry)->DC7_CODCFG+"'"
			cQuery +=   " AND D_E_L_E_T_ = ' '"
			lRet := (TcSQLExec(cQuery) >= 0)
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet

Static Function WmsMovDfg()
Local lRet      := .T.
Local cQuery    := ""
Local cTable    := "%"+oTabTmpDfg:GetRealName()+"%"
Local cAliasQry := Nil
Local cAliasTMP := Nil
Local cAliasEnd := Nil
Local cDBMS     := Upper(TCGETDB())
	// Analisa desfragmentação dentro da mesma estrutura física e estruturas sem controle de unitizador
	cQuery := "SELECT D14.D14_LOCAL,"
	cQuery +=       " D14.D14_ENDER,"
	cQuery +=       " D14.D14_PRDORI,"
	cQuery +=       " D14.D14_PRODUT,"
	cQuery +=       " SB1.B1_DESC,"
	cQuery +=       " D14.D14_LOTECT,"
	cQuery +=       " D14.D14_NUMLOT,"
	cQuery +=       " D14.D14_ESTFIS,"
	cQuery +=       " TMP.TMP_VALNV1,"
	cQuery +=       " TMP.TMP_VALNV2,"
	cQuery +=       " TMP.TMP_VALNV3,"
	cQuery +=       " TMP.TMP_VALNV4,"
	cQuery +=       " TMP.TMP_VALNV5,"
	cQuery +=       " TMP.TMP_VALNV6,"
	cQuery +=       " TMP.TMP_PESNV1,"
	cQuery +=       " TMP.TMP_PESNV2,"
	cQuery +=       " TMP.TMP_PESNV3,"
	cQuery +=       " TMP.TMP_PESNV4,"
	cQuery +=       " TMP.TMP_PESNV5,"
	cQuery +=       " TMP.TMP_PESNV6,"
	cQuery +=       " TMP.TMP_PESLAD,"
	cQuery +=       " D14.D14_QTDEST CAP_QTDEST,"
	cQuery +=       " SUM(SB1.B1_PESBRU * D14.D14_QTDEST) CAP_PESO,"
	cQuery +=       " SUM( ( (SB5.B5_COMPRLC * SB5.B5_LARGLC * SB5.B5_ALTURLC ) * (CASE WHEN SB5.B5_UMIND = '1' THEN D14.D14_QTDEST"
	cQuery +=                                                                         " ELSE D14.D14_QTDES2"
	cQuery +=                                                                     " END ) ) ) CAP_VOLUME"
	cQuery +=  " FROM "+oTabTmpOri:GetRealName()+ " TMP"
	cQuery += " INNER JOIN "+RetSqlName("D14")+ " D14"
	cQuery +=    " ON D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=   " AND D14.D14_LOCAL = TMP.TMP_LOCAL"
	cQuery +=   " AND D14.D14_ENDER = TMP.TMP_ENDER"
	cQuery +=   " AND D14.D14_IDUNIT = '"+Space(TamSx3("D14_IDUNIT")[1])+"'"
	cQuery +=   " AND D14.D14_PRODUT BETWEEN '"+cMvProdDe+"' AND '"+cMvProdAte+"'"
	cQuery +=   " AND D14.D14_QTDEST > 0"
	cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1"
	cQuery +=    " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery +=   " AND SB1.B1_COD = D14.D14_PRODUT"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("SB5")+" SB5"
	cQuery +=    " ON SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
	cQuery +=   " AND SB5.B5_COD = SB1.B1_COD"
	cQuery +=   " AND SB5.D_E_L_E_T_ = ' '"
	cQuery += " WHERE TMP.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY D14.D14_LOCAL,"
	cQuery +=          " D14.D14_ENDER,"
	cQuery +=          " D14.D14_PRDORI,"
	cQuery +=          " D14.D14_PRODUT,"
	cQuery +=          " SB1.B1_DESC,"
	cQuery +=          " D14.D14_LOTECT,"
	cQuery +=          " D14.D14_NUMLOT,"
	cQuery +=          " D14.D14_ESTFIS,"
	cQuery +=          " TMP.TMP_VALNV1,"
	cQuery +=          " TMP.TMP_VALNV2,"
	cQuery +=          " TMP.TMP_VALNV3,"
	cQuery +=          " TMP.TMP_VALNV4,"
	cQuery +=          " TMP.TMP_VALNV5,"
	cQuery +=          " TMP.TMP_VALNV6,"
	cQuery +=          " TMP.TMP_PESNV1,"
	cQuery +=          " TMP.TMP_PESNV2,"
	cQuery +=          " TMP.TMP_PESNV3,"
	cQuery +=          " TMP.TMP_PESNV4,"
	cQuery +=          " TMP.TMP_PESNV5,"
	cQuery +=          " TMP.TMP_PESNV6,"
	cQuery +=          " TMP.TMP_PESLAD,"
	cQuery +=          " D14.D14_QTDEST"
	cQuery += " ORDER BY D14.D14_LOCAL,"
	cQuery +=          " D14.D14_ENDER,"
	cQuery +=          " D14.D14_PRODUT,"
	cQuery +=          " D14.D14_LOTECT,"
	cQuery +=          " D14.D14_NUMLOT"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	Do While lRet .And. (cAliasQry)->(!Eof())
		cAliasEnd := GetNextAlias()
		BeginSql Alias cAliasEnd
			SELECT 1
			FROM %Exp:cTable% TED
			WHERE TED.TMP_LOCDES = %Exp:(cAliasQry)->D14_LOCAL%
			AND TED.TMP_ENDDES = %Exp:(cAliasQry)->D14_ENDER%
			AND TED.%NotDel%
		EndSql
		If (cAliasEnd)->(Eof())
			// Busca nos endereços destino se há espaço para os produtos
			cQuery := " SELECT TMP.TMP_LOCAL,"
			cQuery +=        " TMP.TMP_ENDER,"
			cQuery +=        " TMP.TMP_QTNORM,"
			cQuery +=        " TMP.TMP_QTDCAP,"
			cQuery +=        " TMP.TMP_QTDOCU,"
			cQuery +=        " TMP.TMP_QTDORI,"
			cQuery +=        " TMP.TMP_CAPACI,"
			cQuery +=        " TMP.TMP_CAPOCU,"
			cQuery +=        " TMP.TMP_M3ENDE,"
			cQuery +=        " TMP.TMP_M3OCUP,"
			cQuery +=        " CASE WHEN TMP.TMP_PRODUT = '"+(cAliasQry)->D14_PRODUT+"' THEN 1"
			cQuery +=             " WHEN (TMP.TMP_PRDDIF = '2' AND TMP.TMP_PRDAUX = '"+(cAliasQry)->D14_PRODUT+"') THEN 2"
			cQuery +=             " ELSE 3"
			cQuery +=         " END TMP_ORDEM,"
			// Calcula um Endereco Alvo com base nos Pesos atribuidos aos Niveis
			cQuery +=       " ((ABS(TMP.TMP_VALNV1 - "+Str((cAliasQry)->TMP_VALNV1)+") * "+Str((cAliasQry)->TMP_PESNV1)+") +"
			cQuery +=        " (ABS(TMP.TMP_VALNV2 - "+Str((cAliasQry)->TMP_VALNV2)+") * "+Str((cAliasQry)->TMP_PESNV2)+") +"
			cQuery +=        " (ABS(TMP.TMP_VALNV3 - "+Str((cAliasQry)->TMP_VALNV3)+") * "+Str((cAliasQry)->TMP_PESNV3)+") +"
			cQuery +=        " (ABS(TMP.TMP_VALNV4 - "+Str((cAliasQry)->TMP_VALNV4)+") * "+Str((cAliasQry)->TMP_PESNV4)+") +"
			cQuery +=        " (ABS(TMP.TMP_VALNV5 - "+Str((cAliasQry)->TMP_VALNV5)+") * "+Str((cAliasQry)->TMP_PESNV5)+") +"
			cQuery +=        " (ABS(TMP.TMP_VALNV6 - "+Str((cAliasQry)->TMP_VALNV6)+") * "+Str((cAliasQry)->TMP_PESNV6)+")"
			// Inclui o Peso "LADO"  para  Enderecos  localizados  no  Mesmo  Nivel
			// Primario e Secundario (Ex.:Na mesma Rua e mesmo Predio)
			If "MSSQL" $ cDBMS .Or. "POSTGRES" $ cDBMS
				cQuery += "+(CASE WHEN (ABS(TMP.TMP_VALNV1-"+Str((cAliasQry)->TMP_VALNV1)+") = 0 AND ( ( TMP.TMP_VALNV1-(2*( CAST(TMP.TMP_VALNV1/2 AS INTEGER))) ) != ( "+Str((cAliasQry)->TMP_VALNV2)+"-(2*( CAST("+Str((cAliasQry)->TMP_VALNV1)+"/2 AS INTEGER))) ) )) THEN (1*"+Str((cAliasQry)->TMP_PESLAD)+") ELSE 0 END)"
			Else
				cQuery += "+(CASE WHEN (ABS(TMP.TMP_VALNV1-"+Str((cAliasQry)->TMP_VALNV1)+") = 0 AND (MOD(TMP.TMP_VALNV1,2) != MOD("+Str((cAliasQry)->TMP_VALNV2)+",2))) THEN (1*"+Str((cAliasQry)->TMP_PESLAD)+") ELSE 0 END)"
			EndIf
			cQuery +=        ") TMP_DISTAN"
			cQuery +=  " FROM "+oTabTmpDes:GetRealName()+ " TMP"
			cQuery += " WHERE TMP.TMP_LOCAL = '"+(cAliasQry)->D14_LOCAL+"'"
			cQuery +=   " AND TMP.TMP_ENDER <> '"+(cAliasQry)->D14_ENDER+"'"
			cQuery +=   " AND TMP.TMP_ESTFIS = '"+(cAliasQry)->D14_ESTFIS+"'"
			cQuery +=   " AND TMP.TMP_ENDLIB = '2'"
			If nPriMovDfg == 1
				cQuery += " AND ((TMP.TMP_PRDDIF = '2' AND TMP.TMP_PRDAUX = '"+(cAliasQry)->D14_PRODUT+"')"
				cQuery +=  " OR (TMP.TMP_PRDDIF = '1' AND TMP.TMP_TIPEND = '4'))"
			ElseIf nPriMovDfg == 2
				cQuery += " AND ((TMP.TMP_PRDDIF = '2' AND TMP.TMP_PRDAUX = '"+(cAliasQry)->D14_PRODUT+"')"
				cQuery +=  " OR (TMP.TMP_PRDDIF = '1' AND TMP.TMP_TIPEND = '4'))"
			Else
				cQuery += " AND (TMP.TMP_PRDDIF = '2' AND TMP.TMP_PRDAUX = '"+(cAliasQry)->D14_PRODUT+"')"
			EndIf
			// Controla lote
			If !Empty((cAliasQry)->D14_LOTECT)
				cQuery += " AND (TMP.TMP_TIPEND <> '3'"
				cQuery +=  " OR (TMP.TMP_TIPEND = '3'"
				cQuery += " AND EXISTS (SELECT 1 
				cQuery +=               " FROM "+RetSqlName("D14")+" D14"
				cQuery +=              " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
				cQuery +=                " AND D14.D14_LOCAL = TMP.TMP_LOCAL"
				cQuery +=                " AND D14.D14_ENDER = TMP.TMP_ENDER"
				cQuery +=                " AND D14.D14_LOTECT = '"+(cAliasQry)->D14_LOTECT+"')))" 
			EndIf
			cQuery +=   " AND TMP.TMP_QTDCAP >= (TMP.TMP_QTDOCU + "+cValtoChar((cAliasQry)->CAP_QTDEST)+")"
			cQuery +=   " AND ( TMP.TMP_CAPACI <= 0 OR TMP.TMP_CAPACI >= (TMP.TMP_CAPOCU + "+cValtoChar((cAliasQry)->CAP_PESO)+"))"
			cQuery +=   " AND ( TMP.TMP_M3ENDE <= 0 OR TMP.TMP_M3ENDE >= (TMP.TMP_M3OCUP + "+cValtoChar((cAliasQry)->CAP_VOLUME)+"))"
			cQuery +=   " AND NOT EXISTS (SELECT 1"
			cQuery +=                     " FROM "+oTabTmpDfg:GetRealName()+" TED"
			cQuery +=                    " WHERE TED.TMP_LOCORI = TMP.TMP_LOCAL"
			cQuery +=                      " AND TED.TMP_ENDORI = TMP.TMP_ENDER"
			cQuery +=                      " AND TED.D_E_L_E_T_ = ' ')"
			cQuery +=   " AND TMP.D_E_L_E_T_ = ' '"
			If nPriMovDfg == 1
				cQuery += " ORDER BY TMP_DISTAN,"
				cQuery +=          " TMP_ORDEM,"
				cQuery +=          " TMP.TMP_QTDORI DESC,"
				cQuery +=          " TMP.TMP_LOCAL,"
				cQuery +=          " TMP.TMP_ENDER"
			ElseIf nPriMovDfg == 2
				cQuery += " ORDER BY TMP.TMP_QTDORI DESC,"
				cQuery +=          " TMP_ORDEM,"
				cQuery +=          " TMP.TMP_LOCAL,"
				cQuery +=          " TMP.TMP_ENDER"
			Else
				cQuery += " ORDER BY TMP_ORDEM,"
				cQuery +=          " TMP.TMP_QTDORI DESC,"
				cQuery +=          " TMP.TMP_LOCAL,"
				cQuery +=          " TMP.TMP_ENDER"
			EndIf
			cQuery := ChangeQuery(cQuery)
			cAliasTMP := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTMP,.F.,.T.)
			If (cAliasTMP)->(!Eof())
				// Grava de/para desfragmentação
				cQuery := "INSERT INTO "+oTabTmpDfg:GetRealName()
				cQuery +=      " (TMP_OK,"
				cQuery +=       " TMP_LOCORI,"
				cQuery +=       " TMP_ENDORI,"
				cQuery +=       " TMP_LOCDES,"
				cQuery +=       " TMP_ENDDES,"
				cQuery +=       " TMP_IDUORI,"
				cQuery +=       " TMP_TPUORI,"
				cQuery +=       " TMP_IDUDES,"
				cQuery +=       " TMP_TPUDES,"
				cQuery +=       " TMP_PRDORI,"
				cQuery +=       " TMP_PRODUT,"
				cQuery +=       " TMP_DESPRO,"
				cQuery +=       " TMP_LOTECT,"
				cQuery +=       " TMP_NUMLOT,"
				cQuery +=       " TMP_QTDDES)"
				cQuery +=" VALUES "
				cQuery +=      " ('"+Space(TamSx3("DCF_OK")[1])+"',"
				cQuery +=       "'"+(cAliasQry)->D14_LOCAL+"',"
				cQuery +=       "'"+(cAliasQry)->D14_ENDER+"',"
				cQuery +=       "'"+(cAliasTMP)->TMP_LOCAL+"',"
				cQuery +=       "'"+(cAliasTMP)->TMP_ENDER+"',"
				cQuery +=       "'"+Space(TamSx3("D14_IDUNIT")[1])+"',"
				cQuery +=       "'"+Space(TamSx3("D14_CODUNI")[1])+"',"
				cQuery +=       "'"+Space(TamSx3("D14_IDUNIT")[1])+"',"
				cQuery +=       "'"+Space(TamSx3("D14_CODUNI")[1])+"',"
				cQuery +=       "'"+(cAliasQry)->D14_PRDORI+"',"
				cQuery +=       "'"+(cAliasQry)->D14_PRODUT+"',"
				cQuery +=       "'"+StrTran((cAliasQry)->B1_DESC,"'")+"',"
				cQuery +=       "'"+(cAliasQry)->D14_LOTECT+"',"
				cQuery +=       "'"+(cAliasQry)->D14_NUMLOT+"',"
				cQuery +=       cValtoChar((cAliasQry)->CAP_QTDEST)+")"
				lRet := (TcSQLExec(cQuery) >= 0)
				// Ajusta dimensionais ocupados do endereço destino
				If lRet
					// Atualiza unitizador ocupado
					cQuery := "UPDATE "+oTabTmpDes:GetRealName()
					cQuery +=   " SET TMP_NRUOCU += "+cValtoChar(((cAliasQry)->CAP_QTDEST / (cAliasTMP)->TMP_QTNORM))+","
					cQuery +=       " TMP_QTDOCU += "+cValtoChar((cAliasQry)->CAP_QTDEST)+","
					cQuery +=       " TMP_CAPOCU += "+cValtoChar((cAliasQry)->CAP_PESO)+","
					cQuery +=       " TMP_M3OCUP += "+cValtoChar((cAliasQry)->CAP_VOLUME)
					cQuery += " WHERE TMP_LOCAL = '"+(cAliasTMP)->TMP_LOCAL+"'"
					cQuery +=   " AND TMP_ENDER = '"+(cAliasTMP)->TMP_ENDER+"'"
					cQuery +=   " AND D_E_L_E_T_ = ' '"
					lRet := (TcSQLExec(cQuery) >= 0)
				EndIf
				// Ajusta dimensionais ocupados do endereço origem
				If lRet
					// Atualiza unitizador ocupado
					cQuery := "UPDATE "+oTabTmpDes:GetRealName()
					cQuery +=   " SET TMP_NRUOCU -= "+cValtoChar(((cAliasQry)->CAP_QTDEST / (cAliasTMP)->TMP_QTNORM))+","
					cQuery +=       " TMP_QTDOCU -= "+cValtoChar((cAliasQry)->CAP_QTDEST)+","
					cQuery +=       " TMP_CAPOCU -= "+cValtoChar((cAliasQry)->CAP_PESO)+","
					cQuery +=       " TMP_M3OCUP -= "+cValtoChar((cAliasQry)->CAP_VOLUME)+","
					cQuery +=       " TMP_ENDLIB = '1'"
					cQuery += " WHERE TMP_LOCAL = '"+(cAliasQry)->D14_LOCAL+"'"
					cQuery +=   " AND TMP_ENDER = '"+(cAliasQry)->D14_ENDER+"'"
					cQuery +=   " AND D_E_L_E_T_ = ' '"
					lRet := (TcSQLExec(cQuery) >= 0)
				EndIf
			EndIf
			(cAliasTMP)->(dbCloseArea())
		EndIf
		(cAliasEnd)->(dbCloseArea())
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
Return lRet

Static Function AtuALiber()
Local nALiber   := 0
Local cAliasQry := Nil
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT COUNT(*) QTD_ALIBER
		FROM %Table:D14% D14
		INNER JOIN %Table:SBE% SBE
		ON SBE.BE_FILIAL = %xFilial:SBE%
		AND SBE.BE_LOCAL  = D14.D14_LOCAL
		AND SBE.BE_CODZON = %Exp:cMvZona%
		AND SBE.BE_CODZON <> '  '
		AND SBE.BE_LOCALIZ = D14.D14_ENDER
		AND SBE.%NotDel%
		INNER JOIN %Table:DC8% DC8
		ON DC8.DC8_FILIAL = %xFilial:DC8%
		AND DC8.DC8_CODEST = SBE.BE_ESTFIS
		AND DC8.DC8_TPESTR IN ('1','2','4','6')
		AND DC8.%NotDel%
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL  = %Exp:cMvLocal%
		AND D14.D14_ENDER BETWEEN %Exp:cMvEOriDe% AND %Exp:cMvEOriAte%
		AND (D14.D14_QTDEST + D14.D14_QTDEPR) - D14.D14_QTDSPR <= 0
		AND D14.%NotDel%
	EndSql	
	// Quantidade endereços livres
	nALiber := (cAliasQry)->QTD_ALIBER
	(cAliasQry)->(dbCloseArea())
Return nALiber

Static Function AtuLivre()
Local nLivre    := 0
Local cAliasQry := Nil
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT COUNT(*) QTD_LIVRE
		FROM %Table:SBE% SBE
		WHERE SBE.BE_FILIAL = %xFilial:SBE%
		AND SBE.BE_LOCAL  = %Exp:cMvLocal%
		AND SBE.BE_CODZON = %Exp:cMvZona%
		AND SBE.BE_CODZON <> ' '
		AND SBE.BE_LOCALIZ BETWEEN %Exp:cMvEOriDe% AND %Exp:cMvEOriAte%
		AND SBE.%NotDel%
		AND NOT EXISTS (SELECT 1
						FROM %Table:D14% D14
						WHERE D14.D14_FILIAL = %xFilial:D14%
						AND D14.D14_LOCAL = SBE.BE_LOCAL
						AND D14.D14_ENDER = SBE.BE_LOCALIZ
						AND D14.D14_ESTFIS = SBE.BE_ESTFIS
						AND (D14.D14_QTDEST + D14.D14_QTDEPR) > 0
						AND D14.%NotDel% )
		AND EXISTS (SELECT 1
					FROM %Table:DC8% DC8
					WHERE DC8.DC8_FILIAL = %xFilial:DC8%
					AND DC8.DC8_CODEST = SBE.BE_ESTFIS
					AND DC8.DC8_TPESTR IN ('1','2','4','6')
					AND DC8.%NotDel% )
	EndSql
	// Quantidade endereços livres
	nLivre := (cAliasQry)->QTD_LIVRE
	(cAliasQry)->(dbCloseArea())
Return nLivre

Static Function AtuOcupSel()
Local nOcupSel  := 0
Local cAliasQry := Nil
	// Query para busca enderecos ocupados
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT COUNT(*) QTD_OCUPAD
		FROM %Table:D14% D14
		INNER JOIN %Table:SBE% SBE
		ON SBE.BE_FILIAL = %xFilial:SBE%
		AND SBE.BE_LOCAL = D14.D14_LOCAL
		AND SBE.BE_CODZON = %Exp:cMvZona%
		AND SBE.BE_CODZON <> '  '
		AND SBE.BE_LOCALIZ = D14.D14_ENDER
		AND SBE.%NotDel%
		INNER JOIN %Table:DC8% DC8
		ON DC8.DC8_FILIAL = %xFilial:DC8%
		AND DC8.DC8_CODEST = SBE.BE_ESTFIS
		AND DC8.DC8_TPESTR IN ('1','2','4','6')
		AND DC8.%NotDel%
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL  = %Exp:cMvLocal%
		AND D14.D14_ENDER BETWEEN  %Exp:cMvEOriDe% AND %Exp:cMvEOriAte%
		AND D14.D14_PRODUT BETWEEN %Exp:cMvProdDe% AND %Exp:cMvProdAte%
		AND (D14.D14_QTDEST + D14.D14_QTDEPR) - D14.D14_QTDSPR > 0
		AND D14.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		nOcupSel := (cAliasQry)->QTD_OCUPAD
	EndIf
	(cAliasQry)->(dbCloseArea())
Return nOcupSel

Static Function AtuOcupDem()
Local nOcupDem  := 0
Local cAliasQry := Nil
	// Query para busca enderecos ocupados
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT COUNT(*) QTD_OCUPAD
		FROM %Table:D14% D14
		INNER JOIN %Table:SBE% SBE
		ON SBE.BE_FILIAL = %xFilial:SBE%
		AND SBE.BE_LOCAL  = D14.D14_LOCAL
		AND SBE.BE_CODZON = %Exp:cMvZona%
		AND SBE.BE_CODZON <> '  '
		AND SBE.BE_LOCALIZ = D14.D14_ENDER
		AND SBE.%NotDel%
		INNER JOIN %Table:DC8% DC8
		ON DC8.DC8_FILIAL = %xFilial:DC8%
		AND DC8.DC8_CODEST = SBE.BE_ESTFIS
		AND DC8.DC8_TPESTR IN ('1','2','4','6')
		AND DC8.%NotDel%
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL  = %Exp:cMvLocal%
		AND D14.D14_ENDER BETWEEN %Exp:cMvEOriDe% AND %Exp:cMvEOriAte%
		AND D14.D14_PRODUT NOT BETWEEN %Exp:cMvProdDe% AND %Exp:cMvProdAte%
		AND (D14.D14_QTDEST + D14.D14_QTDEPR) - D14.D14_QTDSPR > 0
		AND D14.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		nOcupDem := (cAliasQry)->QTD_OCUPAD
	EndIf
	(cAliasQry)->(dbCloseArea())
Return nOcupDem

Static Function DfgALiber()
Local nALiber   := 0
Local cTable    := "%"+oTabTmpDfg:GetRealName()+"%"
Local cAliasQry := Nil
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT COUNT(*) QTD_LIVRE
		FROM %Exp:cTable% TED
		WHERE TED.TMP_OK <> '  '
		AND TED.%NotDel%
	EndSql
	// Quantidade endereços livres
	nALiber := (cAliasQry)->QTD_LIVRE
Return nALiber
//-----------------------------------
/*{Protheus.doc}
AfterMark

@author Alexsander Burigo Corrêa
@version P12
@Since	01/04/2018
@obs AfterMark
*/
//-----------------------------------
Static Function AfterMark()
	MntGrfDfg()
	MstGrfDfg()
Return
//-----------------------------------
/*{Protheus.doc}
AllMark

@author Alexsander Burigo Corrêa
@version P12
@Since	01/04/2018
@obs AllMark
*/
//-----------------------------------
Static Function AllMark(lMarcar)
Local lRet      := .T.
Local cQuery    := ""
	cQuery := "UPDATE "+oTabTmpDfg:GetRealName()
	cQuery +=   " SET TMP_OK = '"+IIf(lMarcar,oMrkBrw:Mark()," ")+"'"
	cQuery +=   " WHERE D_E_L_E_T_ = ' '"
	lRet := (TcSQLExec(cQuery) >= 0)
	AfterMark()
Return lRet
//-----------------------------------
/*{Protheus.doc}
Cria a tabela temporária

@author Alexsander Burigo Corrêa
@version P12
@Since	01/04/2018
@obs Cria a tabela temporária
*/
//-----------------------------------
Static Function CriaTabOri()
Local aIndex     := {}
Local aArqTmp    := {}
Local aColsSX3   := {}
Local nX         := 0
	// Cria tabela de quantidade disponível para armazenagem
	aArqTabOri := {}

	// Monta tabelas temporárias utilizadas no processo
	Aadd(aIndex, "TMP_LOCAL+TMP_ENDER" )

	AAdd(aArqTmp,{"TMP_LOCAL"  ,BuscarSX3("BE_LOCAL"  , ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Armazém
	AAdd(aArqTmp,{"TMP_ENDER"  ,BuscarSX3("BE_LOCALIZ", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Endereço origem
	AAdd(aArqTmp,{"TMP_ESTFIS" ,BuscarSX3("D14_ESTFIS", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Estrutura física
	AAdd(aArqTmp,{"TMP_CODCFG" ,BuscarSX3("BE_CODCFG" , ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Cod. config. endereço
	AAdd(aArqTmp,{"TMP_VALNV1" ,BuscarSX3("BE_VALNV1" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Configuração nivel 1
	AAdd(aArqTmp,{"TMP_VALNV2" ,BuscarSX3("BE_VALNV2" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Configuração nivel 2
	AAdd(aArqTmp,{"TMP_VALNV3" ,BuscarSX3("BE_VALNV3" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Configuração nivel 3
	AAdd(aArqTmp,{"TMP_VALNV4" ,BuscarSX3("BE_VALNV4" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Configuração nivel 4
	AAdd(aArqTmp,{"TMP_VALNV5" ,BuscarSX3("BE_VALNV5" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Configuração nivel 5
	AAdd(aArqTmp,{"TMP_VALNV6" ,BuscarSX3("BE_VALNV6" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Configuração nivel 6
	AAdd(aArqTmp,{"TMP_PESNV1" ,BuscarSX3("DC7_PESO2" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso nivel 1
	AAdd(aArqTmp,{"TMP_PESNV2" ,BuscarSX3("DC7_PESO2" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso nivel 2
	AAdd(aArqTmp,{"TMP_PESNV3" ,BuscarSX3("DC7_PESO2" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso nivel 3
	AAdd(aArqTmp,{"TMP_PESNV4" ,BuscarSX3("DC7_PESO2" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso nivel 4
	AAdd(aArqTmp,{"TMP_PESNV5" ,BuscarSX3("DC7_PESO2" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso nivel 5
	AAdd(aArqTmp,{"TMP_PESNV6" ,BuscarSX3("DC7_PESO2" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso nivel 6
	AAdd(aArqTmp,{"TMP_PESLAD" ,BuscarSX3("DC7_PESO1" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso lado

	For nX := 1 To Len(aArqTmp)
		AAdd(aArqTabOri,{aArqTmp[nX][1],aArqTmp[nX][3],aArqTmp[nX][4],aArqTmp[nX][5]})
	Next nX
	cAliasTOri := GetNextAlias()
	CriaTabTmp(aArqTabOri,aIndex,cAliasTOri,@oTabTmpOri)
Return
//-----------------------------------
/*{Protheus.doc}
Cria a tabela temporária

@author Alexsander Burigo Corrêa
@version P12
@Since	01/04/2018
@obs Cria a tabela temporária
*/
//-----------------------------------
Static Function CriaTabDes()
Local aIndex     := {}
Local aArqTmp    := {}
Local aColsSX3   := {}
Local nX         := 0
	// Cria tabela de quantidade disponível para armazenagem
	aArqTabDes := {}

	// Monta tabelas temporárias utilizadas no processo
	Aadd(aIndex, "TMP_LOCAL+TMP_ENDER" )

	AAdd(aArqTmp,{"TMP_LOCAL"  ,BuscarSX3("BE_LOCAL"  , ,aColsSX3)           ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Armazém
	AAdd(aArqTmp,{"TMP_ENDER"  ,BuscarSX3("BE_LOCALIZ", ,aColsSX3)           ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Endereço origem
	AAdd(aArqTmp,{"TMP_ESTFIS" ,BuscarSX3("D14_ESTFIS", ,aColsSX3)           ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Estrutura física
	AAdd(aArqTmp,{"TMP_ALTULC" ,BuscarSX3("BE_ALTURLC", ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Altura do endereço
	AAdd(aArqTmp,{"TMP_LARGLC" ,BuscarSX3("BE_LARGLC" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Largura do endereço
	AAdd(aArqTmp,{"TMP_COMPLC" ,BuscarSX3("BE_COMPRLC", ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Comprimento do endereço
	AAdd(aArqTmp,{"TMP_CODCFG" ,BuscarSX3("BE_CODCFG" , ,aColsSX3)           ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Cod. config. endereço
	AAdd(aArqTmp,{"TMP_VALNV1" ,BuscarSX3("BE_VALNV1" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Configuração nivel 1
	AAdd(aArqTmp,{"TMP_VALNV2" ,BuscarSX3("BE_VALNV2" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Configuração nivel 2
	AAdd(aArqTmp,{"TMP_VALNV3" ,BuscarSX3("BE_VALNV3" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Configuração nivel 3
	AAdd(aArqTmp,{"TMP_VALNV4" ,BuscarSX3("BE_VALNV4" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Configuração nivel 4
	AAdd(aArqTmp,{"TMP_VALNV5" ,BuscarSX3("BE_VALNV5" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Configuração nivel 5
	AAdd(aArqTmp,{"TMP_VALNV6" ,BuscarSX3("BE_VALNV6" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Configuração nivel 6
	AAdd(aArqTmp,{"TMP_PESNV1" ,BuscarSX3("DC7_PESO2" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso nivel 1
	AAdd(aArqTmp,{"TMP_PESNV2" ,BuscarSX3("DC7_PESO2" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso nivel 2
	AAdd(aArqTmp,{"TMP_PESNV3" ,BuscarSX3("DC7_PESO2" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso nivel 3
	AAdd(aArqTmp,{"TMP_PESNV4" ,BuscarSX3("DC7_PESO2" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso nivel 4
	AAdd(aArqTmp,{"TMP_PESNV5" ,BuscarSX3("DC7_PESO2" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso nivel 5
	AAdd(aArqTmp,{"TMP_PESNV6" ,BuscarSX3("DC7_PESO2" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso nivel 6
	AAdd(aArqTmp,{"TMP_PESLAD" ,BuscarSX3("DC7_PESO1" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Peso lado
	AAdd(aArqTmp,{"TMP_TIPEND" ,BuscarSX3("DC3_TIPEND", ,aColsSX3)           ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Tipo de endereçamento
	AAdd(aArqTmp,{"TMP_QTDCAP" ,BuscarSX3("D14_QTDEST", ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Quantidade total capacidade norma
	AAdd(aArqTmp,{"TMP_QTDOCU" ,BuscarSX3("D14_QTDEST", ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Quantidade ocupada no endereço
	AAdd(aArqTmp,{"TMP_QTDORI" ,BuscarSX3("D14_QTDEST", ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Quantidade desfragmentada
	AAdd(aArqTmp,{"TMP_NRUNIT" ,BuscarSX3("BE_NRUNIT" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Número unitizadores endereço
	AAdd(aArqTmp,{"TMP_NRUOCU" ,BuscarSX3("BE_NRUNIT" , ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Número unitizadores ocupados
	AAdd(aArqTmp,{"TMP_CAPACI" ,BuscarSX3("BE_CAPACID", ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Capacidade do endereço
	AAdd(aArqTmp,{"TMP_CAPOCU" ,BuscarSX3("BE_CAPACID", ,aColsSX3)           ,"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Capacidade do endereço ocupados
	AAdd(aArqTmp,{"TMP_M3ENDE" ,"M3 End."                                    ,"N",15         ,3          ,Nil})         // Metragem cúbica do endereço
	AAdd(aArqTmp,{"TMP_M3OCUP" ,"M3 End. Ocup."                              ,"N",15         ,3          ,Nil})         // Comprimento do endereço
	AAdd(aArqTmp,{"TMP_PRODUT" ,BuscarSX3("BE_CODPRO", ,aColsSX3)            ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Produto exclusivo quando houver
	AAdd(aArqTmp,{"TMP_PRDAUX" ,BuscarSX3("BE_CODPRO", ,aColsSX3)            ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Primeiro produto no endereço
	AAdd(aArqTmp,{"TMP_QTNORM" ,BuscarSX3("D14_QTDEST","Qtde Norma",aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Quantidade norma
	AAdd(aArqTmp,{"TMP_PRDDIF" ,"Prd. dif?"                                  ,"C",1          ,0          ,Nil})         // Mais de um produto no endereço
	AAdd(aArqTmp,{"TMP_ENDLIB" ,"End. lib?"                                  ,"C",1          ,0          ,Nil})         // Endereço a ser liberado
	For nX := 1 To Len(aArqTmp)
		AAdd(aArqTabDes,{aArqTmp[nX][1],aArqTmp[nX][3],aArqTmp[nX][4],aArqTmp[nX][5]})
	Next nX
	cAliasTDes := GetNextAlias()
	CriaTabTmp(aArqTabDes,aIndex,cAliasTDes,@oTabTmpDes)
Return

//-----------------------------------
/*{Protheus.doc}
Cria a tabela temporária

@author Alexsander Burigo Corrêa
@version P12
@Since	01/04/2018
@obs Cria a tabela temporária
*/
//-----------------------------------
Static Function CriaTabDfg()
Local aIndex     := {}
Local aArqTmp    := {}
Local aColsSX3   := {}
Local nX         := 0
Local nY         := 0
	// Cria tabela de quantidade disponível para armazenagem
	aArqTabDfg := {}
	aColsDfg   := {}

	// Monta tabelas temporárias utilizadas no processo
	Aadd(aIndexDfg, "TMP_LOCORI+TMP_ENDORI+TMP_LOCDES+TMP_ENDDES+TMP_IDUORI+TMP_PRDORI+TMP_PRODUT+TMP_LOTECT+TMP_NUMLOT" )
	Aadd(aIndexDfg, "TMP_LOCDES+TMP_ENDDES+TMP_LOCORI+TMP_ENDORI+TMP_IDUORI+TMP_PRDORI+TMP_PRODUT+TMP_LOTECT+TMP_NUMLOT" )

	AAdd(aArqTmp,{"TMP_OK"     ,BuscarSX3("DCF_OK"    , ,aColsSX3)              ,"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Mark
	AAdd(aArqTmp,{"TMP_LOCORI" ,BuscarSX3("BE_LOCAL"  ,"Arm. Origem"  ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Armazém
	AAdd(aArqTmp,{"TMP_ENDORI" ,BuscarSX3("BE_LOCALIZ","End. Origem"  ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Endereço origem
	AAdd(aArqTmp,{"TMP_LOCDES" ,BuscarSX3("BE_LOCAL"  ,"Arm. Destino" ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Armazém
	AAdd(aArqTmp,{"TMP_ENDDES" ,BuscarSX3("BE_LOCALIZ","End. Destino" ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Endereço destino
	AAdd(aArqTmp,{"TMP_IDUORI" ,BuscarSX3("D14_IDUNIT",               ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Identificador do unitizador origem
	AAdd(aArqTmp,{"TMP_TPUORI" ,BuscarSX3("D14_CODUNI",               ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // tipo unitizador origem
	AAdd(aArqTmp,{"TMP_IDUDES" ,BuscarSX3("D14_IDUNIT",               ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Identificador do unitizador destino
	AAdd(aArqTmp,{"TMP_TPUDES" ,BuscarSX3("D14_CODUNI",               ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // tipo unitizador destino
	AAdd(aArqTmp,{"TMP_PRDORI" ,BuscarSX3("D14_PRDORI",               ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Produto Origem
	AAdd(aArqTmp,{"TMP_PRODUT" ,BuscarSX3("D14_PRODUT",               ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Produto
	aAdd(aArqTmp,{"TMP_DESPRO" ,BuscarSX3("B1_DESC",                  ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Descrição do produto
	AAdd(aArqTmp,{"TMP_LOTECT" ,BuscarSX3("D14_LOTECT",               ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Lote do produto
	AAdd(aArqTmp,{"TMP_NUMLOT" ,BuscarSX3("D14_NUMLOT",               ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Sublote do lote do produto
	AAdd(aArqTmp,{"TMP_QTDDES" ,BuscarSX3("D14_QTDEST",               ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // Quantidade desfragmentada

	AAdd(aSeeksDfg, {; // Armazém + Endereço
		AllTrim(aArqTmp[2][2])+' + '+AllTrim(aArqTmp[3][2]),;
		{;
			{'NNR',aArqTmp[2][3],aArqTmp[2][4],aArqTmp[2][5],aArqTmp[2][2],Nil},;
			{'SBE',aArqTmp[3][3],aArqTmp[3][4],aArqTmp[3][5],aArqTmp[3][2],Nil};
		}})
	AAdd(aSeeksDfg, {; // Armazém + Endereço
		AllTrim(aArqTmp[4][2])+' + '+AllTrim(aArqTmp[5][2]),;
		{;
			{'NNR',aArqTmp[4][3],aArqTmp[4][4],aArqTmp[4][5],aArqTmp[4][2],Nil},;
			{'SBE',aArqTmp[5][3],aArqTmp[5][4],aArqTmp[5][5],aArqTmp[5][2],Nil};
		}})
		
	For nX := 1 To Len(aArqTmp)
		If aArqTmp[nX][1] != "TMP_OK"
			nY += 1
			AAdd(aColsDfg,FWBrwColumn():New())
			aColsDfg[nY]:SetData( &("{||"+aArqTmp[nX][1]+"}") )
			aColsDfg[nY]:SetTitle(aArqTmp[nX][2])
			aColsDfg[nY]:SetType(aArqTmp[nX][3])
			aColsDfg[nY]:SetSize(aArqTmp[nX][4])
			aColsDfg[nY]:SetDecimal(aArqTmp[nX][5])
			aColsDfg[nY]:SetPicture(aArqTmp[nX][6])
		EndIf
		AAdd(aArqTabDfg,{aArqTmp[nX][1],aArqTmp[nX][3],aArqTmp[nX][4],aArqTmp[nX][5]})
	Next nX

	// Cria tabela
	cAliasTDfg := GetNextAlias()
	CriaTabTmp(aArqTabDfg,aIndexDfg,cAliasTDfg,@oTabTmpDfg)	
Return

Static Function MntGrfAtu()
Local nAtuEndTot := 0
	// Busca dados atual dos endereços
	nAtuLivre  := AtuLivre()   // Calcula endereços livres da situação atual
	nAtuOcpDem := AtuOcupDem() // Calcula endereços ocupados dos demais produtos da situação atual
	nAtuOcpSel := AtuOcupSel() // Calcula endereços ocupados dos produtos selecionados da situação atual 
	nAtuALiber := AtuALiber()  // Calcula endereços ocupados que poderão ser liberados  
	nAtuEndTot := nAtuLivre + nAtuOcpSel + nAtuOcpDem + nAtuALiber
	// Atualização informações do gráfico de dados atuais
	aDadosGraf[GRAF_SIT_ATU][QTD_END_LIVRE ]   := nAtuLivre
	aDadosGraf[GRAF_SIT_ATU][QTD_END_OCUP_DEM] := nAtuOcpDem
	aDadosGraf[GRAF_SIT_ATU][QTD_END_OCUP_SEL] := nAtuOcpSel
	aDadosGraf[GRAF_SIT_ATU][QTD_END_A_LIBER]  := nAtuALiber
	aDadosGraf[GRAF_SIT_ATU][PERCENT_LIVRE]    := (nAtuLivre  / nAtuEndTot) * 100 // % endereços livres situação atual
	aDadosGraf[GRAF_SIT_ATU][PERCENT_OCUP_DEM] := (nAtuOcpDem / nAtuEndTot) * 100 // % endereços ocupados demais produtos situação atual
	aDadosGraf[GRAF_SIT_ATU][PERCENT_OCUP_SEL] := (nAtuOcpSel / nAtuEndTot) * 100 // % Endereços ocupados seleção produtos situação atual
	aDadosGraf[GRAF_SIT_ATU][PERCENT_A_LIBER]  := (nAtuALiber / nAtuEndTot) * 100 // % endereços a serem liberados
	aDadosGraf[GRAF_SIT_ATU][QTD_END_TOT]      := nAtuEndTot                      // Total de endereços
Return

Static Function MntGrfDfg()
Local nDfgALiber := 0
Local nDfgEndTot := 0
	// Busca dados pós-desfragmentação dos endereços
	nDfgOcpSel := nAtuOcpSel
	nDfgALiber := nAtuALiber
	nQtdLib    := DfgALiber()
	//
	nDfgOcpSel -= nQtdLib
	nDfgALiber += nQtdLib
	nDfgEndTot := nAtuLivre + nAtuOcpDem + nDfgOcpSel + nDfgALiber
	
	// Atualização informações do gráfico dos dados pós-desfragmentação
	aDadosGraf[GRAF_SIT_DFG][QTD_END_LIVRE]    := nAtuLivre
	aDadosGraf[GRAF_SIT_DFG][QTD_END_OCUP_SEL] := nAtuOcpDem
	aDadosGraf[GRAF_SIT_DFG][QTD_END_OCUP_DEM] := nDfgOcpSel
	aDadosGraf[GRAF_SIT_DFG][QTD_END_A_LIBER]  := nDfgALiber
	aDadosGraf[GRAF_SIT_DFG][PERCENT_LIVRE]    := (nAtuLivre  / nDfgEndTot) * 100 // % endereços livres situação pós-desfragmentação
	aDadosGraf[GRAF_SIT_DFG][PERCENT_OCUP_DEM] := (nAtuOcpDem / nDfgEndTot) * 100 // % endereços ocupados demais produtos situação pós-desfragmentação
	aDadosGraf[GRAF_SIT_DFG][PERCENT_OCUP_SEL] := (nDfgOcpSel / nDfgEndTot) * 100 // % Endereços ocupados seleção produtos situação pós-desfragmentação
	aDadosGraf[GRAF_SIT_DFG][PERCENT_A_LIBER]  := (nDfgALiber / nDfgEndTot) * 100 // % endereços a serem liberados pós-desfragmentação
	aDadosGraf[GRAF_SIT_DFG][QTD_END_TOT]      := nDfgEndTot                      // Total de endereços
	
Return

Static Function InitParam()
Local lRet := .T.
	If Pergunte("WMSA431")
		cMvProdDe  := MV_PAR01
		cMvProdAte := MV_PAR02
		cMvZona    := MV_PAR03
		cMvLocal   := MV_PAR04
		cMvEOriDe  := MV_PAR05
		cMvEOriAte := MV_PAR06
		cMvEDesDe  := MV_PAR07
		cMvEDesAte := MV_PAR08
		nMvPercOcu := MV_PAR09
		nPriMovDfg := IIf(Empty(MV_PAR10),3,MV_PAR10)
		//lMvPerMtEs := (MV_PAR11 == '1')
		//lMvPerJtUn := (MV_PAR12 == '1')
		aDadosGraf := {{0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0}}
		nAtuLivre  := 0
		nAtuOcpSel := 0
		nAtuOcpDem := 0
		nAtuALiber := 0
		nDfgOcpSel := 0
		nDfgALiber := 0
	Else
		lRet := .F.
	EndIf
Return lRet

Static Function LimpTabTmp()
Local lRet      := .T.
Local cQuery    := ""
Local lDadosDfg := .F.
	// Valida se há dados da desfragmentaçção
	(cAliasTDfg)->(dbGoTop())
	lDadosDfg := (cAliasTDfg)->(!Eof())
	// Limpa tabelas temporárias
	cQuery := "DELETE FROM "+oTabTmpOri:GetRealName()
	lRet := (TcSQLExec(cQuery) >= 0)
	If lRet
		cQuery := "DELETE FROM "+oTabTmpDes:GetRealName()
		lRet := (TcSQLExec(cQuery) >= 0)
		If lRet
			cQuery := "DELETE FROM "+oTabTmpDfg:GetRealName()
			lRet := (TcSQLExec(cQuery) >= 0)
		EndIf
	EndIf
	If lRet .And. lDadosDfg
		// Limpa dados tela
		MstGrfAtu()
		MstGrfDfg()
		// Mostra tela
		oMrkBrw:Refresh(.T.)
	EndIf
Return lRet

Static Function MstGrfAtu()
	// Adiciona as colunas do gráfico esquerdo - Situação Atual
	FreeObj(oGrafLeft)
	oGrafLeft := FWChartFactory():New()
	oGrafLeft := oGrafLeft:GetInstance(BARCHART)
	oGrafLeft:Init(oLeft,.F.,.F.)
	oGrafLeft:SetMaxY(100)
	oGrafLeft:SetTitle(STR0005 , CONTROL_ALIGN_CENTER) // Situação Atual
	oGrafLeft:SetLegend(CONTROL_ALIGN_RIGHT)
	oGrafLeft:AddSerie( "% "+STR0006+" ("+AllTrim(Str(NoRound(aDadosGraf[GRAF_SIT_ATU][QTD_END_LIVRE],2)))+")"   , NoRound(aDadosGraf[GRAF_SIT_ATU][PERCENT_LIVRE],2)    ) // Liberados
	oGrafLeft:AddSerie( "% "+STR0007+" ("+AllTrim(Str(NoRound(aDadosGraf[GRAF_SIT_ATU][QTD_END_OCUP_DEM],2)))+")", NoRound(aDadosGraf[GRAF_SIT_ATU][PERCENT_OCUP_DEM],2) ) // Demais Produtos
	oGrafLeft:AddSerie( "% "+STR0020+" ("+AllTrim(Str(NoRound(aDadosGraf[GRAF_SIT_ATU][QTD_END_OCUP_SEL],2)))+")", NoRound(aDadosGraf[GRAF_SIT_ATU][PERCENT_OCUP_SEL],2) ) // Seleção Produtos
	oGrafLeft:AddSerie( "% "+STR0021+" ("+AllTrim(Str(NoRound(aDadosGraf[GRAF_SIT_ATU][QTD_END_A_LIBER],2)))+")" , NoRound(aDadosGraf[GRAF_SIT_ATU][PERCENT_A_LIBER],2)  ) // À liberar
	oGrafLeft:Build()
Return

Static Function MstGrfDfg()
	// Adiciona as colunas do gráfico direito - Situação Pós-Desfragmentação
	FreeObj(oGrafRight)
	oGrafRight := FWChartFactory():New()
	oGrafRight := oGrafRight:GetInstance( BARCHART )
	oGrafRight:Init(oRight, .F., .F. )
	oGrafRight:SetMaxY(100)
	oGrafRight:SetTitle( STR0008, CONTROL_ALIGN_CENTER ) // Situação Pós-Desfragmentação
	oGrafRight:SetLegend( CONTROL_ALIGN_RIGHT )
	oGrafRight:AddSerie( "% "+STR0006+" ("+AllTrim(Str(NoRound(aDadosGraf[GRAF_SIT_DFG][QTD_END_LIVRE],2)))+")"   , NoRound(aDadosGraf[GRAF_SIT_DFG][PERCENT_LIVRE],2)    ) // Liberados
	oGrafRight:AddSerie( "% "+STR0007+" ("+AllTrim(Str(NoRound(aDadosGraf[GRAF_SIT_DFG][QTD_END_OCUP_SEL],2)))+")", NoRound(aDadosGraf[GRAF_SIT_DFG][PERCENT_OCUP_SEL],2) ) // Demais Produtos
	oGrafRight:AddSerie( "% "+STR0020+" ("+AllTrim(Str(NoRound(aDadosGraf[GRAF_SIT_DFG][QTD_END_OCUP_DEM],2)))+")", NoRound(aDadosGraf[GRAF_SIT_DFG][PERCENT_OCUP_DEM],2) ) // Seleção Produtos
	oGrafRight:AddSerie( "% "+STR0021+" ("+AllTrim(Str(NoRound(aDadosGraf[GRAF_SIT_DFG][QTD_END_A_LIBER],2)))+")" , NoRound(aDadosGraf[GRAF_SIT_DFG][PERCENT_A_LIBER],2)  ) // À liberar
	oGrafRight:Build()
Return

//-----------------------------------
/*{Protheus.doc}
Valida se a estrutura do produto possui sequencia de abastecimento
@author Fagner Ferraz Barreto
@Since 27/10/2022
*/
//-----------------------------------
Static Function ValSeqAbas()
	Local cAliasQry	:= GetNextAlias()
	Local cMsg		:= ""

	BeginSql Alias cAliasQry
		SELECT
			D14.D14_LOCAL, 
			D14.D14_ENDER, 
			D14.D14_IDUNIT,
			D14.D14_PRODUT,
			D14.D14_ESTFIS
		FROM %Table:D14% D14
		INNER JOIN %Table:SBE% SBE
			ON SBE.BE_FILIAL = %xFilial:SBE%
			AND SBE.BE_LOCAL  = D14.D14_LOCAL
			AND SBE.BE_CODZON = %Exp:cMvZona%
			AND SBE.BE_CODZON <> ' '
			AND SBE.BE_LOCALIZ = D14.D14_ENDER
			AND SBE.%NotDel%
		WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL  = %Exp:cMvLocal%
			AND D14.D14_ENDER BETWEEN %Exp:cMvEOriDe% AND %Exp:cMvEOriAte%
			AND D14.D14_PRODUT BETWEEN %Exp:cMvProdDe% AND %Exp:cMvProdAte%
			AND D14.D14_IDUNIT = ' ' //--Busca itens não unitizados
			AND D14.%NotDel%
			AND NOT EXISTS (	SELECT 1 FROM %Table:DC3% DC3
								WHERE DC3.DC3_LOCAL = D14.D14_LOCAL 
									AND DC3.DC3_CODPRO = D14.D14_PRODUT 
									AND DC3.DC3_TPESTR = D14.D14_ESTFIS 
									AND DC3.%NotDel%	)
		GROUP BY
			D14.D14_LOCAL, 
			D14.D14_ENDER, 
			D14.D14_IDUNIT,
			D14.D14_PRODUT,
			D14.D14_ESTFIS
		UNION ALL
		SELECT 
			D14.D14_LOCAL, 
			D14.D14_ENDER, 
			D14.D14_IDUNIT,
			D14.D14_PRODUT,
			D14.D14_ESTFIS
		FROM %Table:D14% D14
		INNER JOIN %Table:SBE% SBE
			ON SBE.BE_FILIAL = %xFilial:SBE%
			AND SBE.BE_LOCAL  = D14.D14_LOCAL
			AND SBE.BE_CODZON = %Exp:cMvZona%
			AND SBE.BE_CODZON <> ' '
			AND SBE.BE_LOCALIZ = D14.D14_ENDER
			AND SBE.%NotDel%
		WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL = %Exp:cMvLocal%
			AND D14.D14_ENDER BETWEEN %Exp:cMvEOriDe% AND %Exp:cMvEOriAte%
			AND D14.D14_PRODUT BETWEEN %Exp:cMvProdDe% AND %Exp:cMvProdAte%
			AND D14.D14_IDUNIT <> ' ' //--Busca itens unitizados
			AND D14.%NotDel%
			AND NOT EXISTS (	SELECT 1 FROM %Table:DC3% DC3
								WHERE DC3.DC3_LOCAL = D14.D14_LOCAL 
									AND DC3.DC3_CODPRO = D14.D14_PRODUT 
									AND DC3.DC3_TPESTR = D14.D14_ESTFIS 
									AND DC3.%NotDel%	)
		GROUP BY
			D14.D14_LOCAL,
			D14.D14_ENDER,
			D14.D14_IDUNIT,
			D14.D14_PRODUT,
			D14.D14_ESTFIS
		ORDER BY D14_LOCAL, D14_PRODUT
	EndSql

	If ( cAliasQry )->( !EOF() )
		
		cMsg := STR0022 + CRLF + CRLF //--"Os registros abaixo não possuem sequencia de abastecimento cadastrada e não serão apresentados pela rotina de desfragmentação de estoque."

		While ( cAliasQry )->( !EOF() )
			cMsg += WmsFmtMsg(STR0023,{{"[VAR01]",AllTrim((cAliasQry)->D14_LOCAL)},{"[VAR02]",AllTrim((cAliasQry)->D14_PRODUT)},{"[VAR03]",AllTrim(( cAliasQry)->D14_ESTFIS)}}) + CRLF //--Armazem: [VAR01] produto: [VAR02] estrutura: [VAR03].
			( cAliasQry )->( DbSkip() )
		EndDo

		WmsMessage(cMsg,WMSA43109)
		
	EndIf

	( cAliasQry )->( DbCloseArea() )

Return
