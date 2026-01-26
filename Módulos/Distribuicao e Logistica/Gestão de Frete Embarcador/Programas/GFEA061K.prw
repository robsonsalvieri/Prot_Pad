#INCLUDE "PROTHEUS.CH"
#Include "fileio.ch"
#INCLUDE "FWMVCDEF.CH"

Static nGV9CDEMIT := TamSX3("GV9_CDEMIT")[1]
Static nGV9NRTAB  := TamSX3("GV9_NRTAB")[1]
Static nGV9NRNEG  := TamSX3("GV9_NRNEG")[1]
Static nGXTNRCT   := TamSX3("GXT_NRCT")[1]
Static nGV9CDCLFR := TamSX3("GV9_CDCLFR")[1]
Static nGV9CDTPOP := TamSX3("GV9_CDTPOP")[1]
Static nGV8NRCIOR := TamSX3("GV8_NRCIOR")[1]
Static nGV8NRREOR := TamSX3("GV8_NRREOR")[1]
Static nGV8CDPAOR := TamSX3("GV8_CDPAOR")[1]
Static nGV8CDUFOR := TamSX3("GV8_CDUFOR")[1]
Static nGV8CDREM  := TamSX3("GV8_CDREM")[1]
Static nGV8NRCIDS := TamSX3("GV8_NRCIDS")[1]
Static nGV8NRREDS := TamSX3("GV8_NRREDS")[1]
Static nGV8CDPADS := TamSX3("GV8_CDPADS")[1]
Static nGV8CDUFDS := TamSX3("GV8_CDUFDS")[1]
Static nGV8CDDEST := TamSX3("GV8_CDDEST")[1]
Static nGV1CDCOMP := TamSX3("GV1_CDCOMP")[1]

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA061K()
Função melhorada para importação de XML de tabelas de frete
@author  Jefferson Hita
@since   24/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA061K(cTargetDir, cLogDir, lSim, lLibre, lGerLog)
	Private oProcess
	Private lEnd

	oProcess := MsNewProcess():New({|lEnd| ImportXmlTable(cTargetDir, cLogDir, lSim, lLibre, lGerLog) },"Importação Tabela de Frete","Importação de tabelas XML", .T.) 
	oProcess:Activate()
Return

Function ImportXmlTable(cTargetDir, cLogDir, lSim, lLibre, lGerLog)
	Local cFileName  as char
	Local cFileDir   as char
	Local nHdl       as char
	Local oModelGV8  as object
	Local oModelGV7  as object
	Local oModelGUY  as object
	Local cChave     as char
	Local lSit	     as logical
	local nLinha     as numeric
	Local cGv9Filter := ""
	Local aAreaGUB   := GUB->( GetArea() )
	Local aAreaGV9   := GV9->(GetArea())
	Local aAreaGVA   := GVA->(GetArea())
	Local nI         := 0
	Local iCdFxTv    := 0

	Private nAcaoZero  	:= 0
	Private nQtFXFI     := 0
	Private nVlFixo    	:= 0
	Private nVlUnit    	:= 0
	Private nPerVal    	:= 0
	Private nValMin    	:= 0
	Private nValLim    	:= 0
	Private nVlFixE    	:= 0
	Private nPcExtr    	:= 0
	Private nVlUniE    	:= 0
	Private nFracao    	:= 0
	Private nFraExt		:= 0
	Private cDst       	:= ""
	Private cOri       	:= ""
	Private cTrp       	:= ""
	Private cNrct      	:= ""
	Private cNrNeg 	   	:= ""
	Private cNrTab     	:= ""
	Private cTpOri     	:= ""
	Private cTpDst		:= ""
	Private aLog        := {}
	Private lErro 		:= .F.
	Private lFoundGXT   := .F.
	Private cCdFxTv     as char
	Private cNrRota     as char
	Private cUnPes      as char
	Private lFRACEX		:= GFXCP2610("GV1_FRACEX")

	Private oTemGV8 as object
    Private oTemGUY as object
    Private oTemGV6 as object
    Private oTemGV1 as object
    Private oTemGV7 as object
	Private oTemGVW as object

	Default lEnd 	:= .F.
	Default lGerLog := .T.

	nImp  		:= 0
	lReal 		:= .F.

	oProcess:SetRegua1(0)
	oProcess:IncRegua1("Iniciando importação.")

	oProcess:SetRegua2(0)
	oProcess:IncRegua2("Avaliando tabelas...")
	// Armazena e limpa filtro aplicado
	cGv9Filter := GV9->(dbFilter())
	GV9->(DbClearFilter())

	CriaTabTmp()

	cUnPes := SuperGetMV("MV_UMPESO", .F., "KG",)

	cLogTxt := ""

	oModelNeg := FWLoadModel('GFEA061A')
	oModelGV8 := oModelNeg:GetModel("DETAIL_GV8")
	oModelGV7 := oModelNeg:GetModel("DETAIL_GV7")
	oModelGUY := oModelNeg:GetModel("DETAIL_GUY")

	If GFXCP12125("GVW_CDEMIT")
		oModelCTR := FWLoadModel('GFEA083')
	EndIf

	oModelTRF := FWLoadModel("GFEA061F")

	cFileDir  := GetFileDir(cTargetDir)[1]
	cFileName := GetFileDir(cTargetDir)[2]

	cLogTxt += LogMessage("AVISO: Iniciando Importação do Arquivo " + cFileName + CRLF + CRLF + CRLF)

	Aadd(aLog, cLogTxt)

	aIndic := {'TRANSP','NRTAB','NRNEG'}

	// Realizando a leitura do arquivo e validações iniciais do arquivo
	oProcess:IncRegua1("Realizando a leitura do arquivo...")
	oXmlParser := XMLParserGFE61K():New(cTargetDir, lLibre)
	If Empty(oXmlParser:_xml)
		oXmlParser := nil
		Return .F.
	EndIf
	
	// Verifica o arquivo a ser importado está todo com açao zero(0) assim não deverá continuar o processamento
	nLinha := oXmlParser:GetTotalRows()
	If nLinha == nAcaoZero
		lErro := .T.
	EndIf

	cLogTxt += LogMessage("AVISO: Verificação inicial concluída. " + CRLF)
	Aadd(aLog, cLogTxt)
	cLogTxt := ""

	oProcess:IncRegua1("Processando os dados...")
	If !lErro
		oProcess:SetRegua2(nLinha)
		For nI := 1 to nLinha
			oProcess:IncRegua2("Gravando linha: " + cValToChar(nI) + " de " + cValToChar(nLinha))

			lSit := .T.

			nImp  := nImp + 1
			If AllTrim(oXmlParser:GetCol("ACAO",nI)) == "0"
				Loop
			EndIf

			cTrp   := PadR(oXmlParser:GetCol("TRANSP",nI), nGV9CDEMIT)
			cNrTab := PadR(oXmlParser:GetCol("NRTAB",nI) , nGV9NRTAB)
			cNrNeg := PadR(oXmlParser:GetCol("NRNEG",nI) , nGV9NRNEG)

			If Empty(Alltrim(cTrp)) .And. Empty(Alltrim(cNrTab)) .And. Empty(Alltrim(cNrNeg))
				Loop
			EndIf

			If !Empty(oXmlParser:GetCol("NRCT", nI))
				cNrct  := PadR(oXmlParser:GetCol("NRCT", nI), nGXTNRCT)
			EndIf

			// Se for uma nova negociação realiza a criação da negociação anterior
			If !Empty(cChave) .And. cChave <> cTrp + cNrTab + cNrNeg
				lReal = .T.
				insertGV9(cChave)
			EndIf

			cTpOri := RetTpOriDsT(AllTrim(oXmlParser:GetCol("TPORIG", nI)))
			cTpDst := RetTpOriDsT(AllTrim(oXmlParser:GetCol("TPDEST", nI)))

			cOri := VldOriDst(AllTrim(oXmlParser:GetCol("ORIGEM",nI)), cTpOri)
			cDst := VldOriDst(AllTrim(oXmlParser:GetCol("DESTIN",nI)), cTpDst)


			// Verifica se é o primeiro registro ou se é uma nova negociação
			If Empty(cChave) .or. cChave <> cTrp + cNrTab + cNrNeg
				lReal  := .F.
				cChave := cTrp + cNrTab + cNrNeg

				GV9->(DbSetOrder(1))
				If GV9->(DbSeek(xFilial("GV9")+cTrp+cNrTab+cNrNeg))	// msseek para cabeçalho das tabelas, usar o que ja esta na memoria.
					cAcao := "alterada"
					If GV9->GV9_SIT == "1"
						oModelNeg:SetOperation(MODEL_OPERATION_UPDATE)
						oModelTRF:SetOperation(MODEL_OPERATION_UPDATE)
					//Else
						//lSit := .F.
						//Loop
					EndIf
				Else
					cAcao := "criada"
					oModelNeg:SetOperation(MODEL_OPERATION_INSERT)
					oModelTRF:SetOperation(MODEL_OPERATION_INSERT)
				EndIf

				oModelNeg:Activate()

				oModelNeg:LoadValue("GFEA061A_GV9","GV9_CDEMIT", cTrp)
				oModelNeg:LoadValue("GFEA061A_GV9","GV9_NRTAB" , cNrTab)
				oModelNeg:LoadValue("GFEA061A_GV9","GV9_NRNEG" , cNrNeg)
			EndIf

			cLogTxt += LogMessage("AVISO: Incluindo/Alterando: " + "Transp: " + AllTrim(oXmlParser:GetCol("TRANSP",nI)) + " NrTab: " +;
									AllTrim(oXmlParser:GetCol("NRTAB",nI)) + " NrNeg: " + AllTrim(oXmlParser:GetCol("NRNEG",nI)) + " DtInicio " +;
									Alltrim(oXmlParser:GetCol("INICIO",nI)) + " Compon " + AllTrim(oXmlParser:GetCol("COMPON",nI)) + CRLF)

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			cAdICMs := RetSimNao(oXmlParser:GetCol("IMPINC",nI))

			oModelNeg:LoadValue("GFEA061A_GV9","GV9_CDCLFR", PadR(oXmlParser:GetCol("CLASSF",nI), nGV9CDCLFR))
			oModelNeg:LoadValue("GFEA061A_GV9","GV9_CDTPOP", PadR(oXmlParser:GetCol("TPOPER",nI), nGV9CDTPOP))
			oModelNeg:LoadValue("GFEA061A_GV9","GV9_DTVALI", CToD(Alltrim(oXmlParser:GetCol("INICIO",nI))))
			oModelNeg:LoadValue("GFEA061A_GV9","GV9_DTVALF", CToD(Alltrim(oXmlParser:GetCol("TERMIN",nI))))
			oModelNeg:LoadValue("GFEA061A_GV9","GV9_UNIFAI", cUnPes)
			oModelNeg:LoadValue("GFEA061A_GV9","GV9_ADICMS", cAdICMs)

			nVlFixo := IIf(!Empty(oXmlParser:GetCol("VLFIXO",nI)),val(strtran(oXmlParser:GetCol("VLFIXO",nI),",",".")),0)
			nVlUnit := IIf(!Empty(oXmlParser:GetCol("VLUNIT",nI)),val(strtran(oXmlParser:GetCol("VLUNIT",nI),",",".")),0)
			nPerVal := IIf(!Empty(oXmlParser:GetCol("PERVAL",nI)),val(strtran(oXmlParser:GetCol("PERVAL",nI),",",".")),0)
			nValMin := IIf(!Empty(oXmlParser:GetCol("VALMIN",nI)),val(strtran(oXmlParser:GetCol("VALMIN",nI),",",".")),0)
			nValLim := IIf(!Empty(oXmlParser:GetCol("VALLIM",nI)),val(strtran(oXmlParser:GetCol("VALLIM",nI),",",".")),0)
			nVlFixE := IIf(!Empty(oXmlParser:GetCol("VLFIXE",nI)),val(strtran(oXmlParser:GetCol("VLFIXE",nI),",",".")),0)
			nPcExtr := IIf(!Empty(oXmlParser:GetCol("PCEXTR",nI)),val(strtran(oXmlParser:GetCol("PCEXTR",nI),",",".")),0)
			nVlUniE := IIf(!Empty(oXmlParser:GetCol("VLUNIE",nI)),val(strtran(oXmlParser:GetCol("VLUNIE",nI),",",".")),0)
			nFracao := IIf(!Empty(oXmlParser:GetCol("FRACAO",nI)),val(strtran(oXmlParser:GetCol("FRACAO",nI),",",".")),0)
			nQtFXFI := IIf(!Empty(oXmlParser:GetCol("FAIXAF",nI)),val(strtran(oXmlParser:GetCol("FAIXAF",nI),",",".")),0)
			nFRACEX := IIf(!Empty(oXmlParser:GetCol("FRACEX",nI)),val(strtran(oXmlParser:GetCol("FRACEX",nI),",",".")),0)


			// ========================================================================================================================================
			// Verifica se já existe um registro da Faixa/Tp Veiculo Tab Frete na tabela temporária
			// ========================================================================================================================================
			cTabName  := oTemGV7:GetRealName()
			cAuxAlias := GetNextAlias()
			cQuerySQL := "SELECT *"+;
						 " FROM " + cTabName +;
						 " WHERE TRANSP = '" + cTrp + "'" +;
						 " AND NRTAB = '" + cNrTab + "'" +;
						 " AND NRNEG = '" + cNrNeg + "'" +;
						 " AND FAIXAF = '" + cValToChar(nQtFXFI) + "'" +;
						 " AND TPVEIC = '" + oXmlParser:GetCol("TPVEIC", nI) + "'"

			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySQL), cAuxAlias, .T., .T.)
			If (cAuxAlias)->(!Eof())
				cCdFxTv := cValToChar((cAuxAlias)->CDFXTV)
			Else
				// Só inclui uma nova linha caso não exista o registro na tabela temporária
				iCdFxTv := iCdFxTv + 1
				cCdFxTv := PADL(cValToChar(iCdFxTv), 4, "0")
				lCdFxTv := .F.

				// Caso exista a tabela já criada na tabela de frete, atualiza o número da faixa que deverá ser utilizado
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT GV7_CDFXTV
					FROM %Table:GV7% GV7
					WHERE GV7_FILIAL = %xFilial:GV7%
					AND GV7_CDEMIT = %Exp:cTrp%
					AND GV7_NRTAB  = %Exp:cNrTab%
					AND GV7_NRNEG  = %Exp:cNrNeg%
					AND GV7.%NotDel%
				EndSql
				If !(cAliasQry)->(Eof())
					cCdFxTv := PADL(cvaltochar(val(GV7->GV7_CDFXTV) + 1),4,"0")
				EndIf
				(cAliasQry)->(DbCloseArea())


				// Verifica se exista um registro com o mesmo tipo veículo/faixa na tabela de frete
				If !Empty(oXmlParser:GetCol("TPVEIC",nI)) .Or. (Empty(oXmlParser:GetCol("TPVEIC",nI)) .And. (Empty(nQTFXFI) .Or. nQTFXFI == 0))
					cWhere := " AND GV7_CDTPVC  = '" + AllTrim(oXmlParser:GetCol("TPVEIC",nI)) + "'"
				ElseIf nQtFXFI != 0
					cWhere := " AND GV7_QTFXFI  = '" + cValToChar(nQtFXFI) + "'"
				EndIf
				cWhere := "%" + cWhere + "%"

				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT GV7_CDFXTV
					FROM %Table:GV7% GV7
					WHERE GV7_FILIAL = %xFilial:GV7%
					AND GV7_CDEMIT = %Exp:cTrp%
					AND GV7_NRTAB = %Exp:cNrTab%
					AND GV7_NRNEG = %Exp:cNrNeg%
					AND GV7.%NotDel%
					%Exp:cWhere%
				EndSql
				If !(cAliasQry)->(Eof())
					cCdFxTv := PADL(cvaltochar(val((cAliasQry)->GV7_CDFXTV)),4,"0")
					lCdFxTv := .T.
				EndIf
				(cAliasQry)->(DbCloseArea())

				If Reclock(_cAliaGV7, .T.)
					(_cAliaGV7)->TRANSP := cTrp
					(_cAliaGV7)->NRTAB  := cNrTab
					(_cAliaGV7)->NRNEG  := cNrNeg
					(_cAliaGV7)->FAIXAF := nQtFXFI
					(_cAliaGV7)->TPVEIC := oXmlParser:GetCol("TPVEIC", nI)
					(_cAliaGV7)->CDFXTV := cCdFxTv
					(_cAliaGV7)->(MsUnlock())
				EndIf

				If (oModelGV7:GetQtdLine() > 1 .Or. !Empty(oModelGV7:GetValue('GV7_CDFXTV', 1))) .And. !lCdFxTv
					oModelGV7:Addline(.T.)
				EndIf

				If !GV7->(DbSeek(xFilial("GV7") + cTrp + cNrTab + cNrNeg + cCdFxTv))
					If !lCdFxTv
						oModelGV7:LoadValue("GV7_CDEMIT", cTrp)
						oModelGV7:LoadValue("GV7_NRTAB" , cNrTab)
						oModelGV7:LoadValue("GV7_NRNEG" , cNrNeg)
						oModelGV7:LoadValue("GV7_CDFXTV", cCdFxTv)

						IF nQtFXFI == 0
							cFaixaF := Val('999.999.999,99999')
						Else
							cFaixaF := nQtFXFI
						EndIf

						If !Empty(oXmlParser:GetCol("TPVEIC", nI)) .Or. (Empty(oXmlParser:GetCol("TPVEIC", nI)) .And. (Empty(nQTFXFI) .Or. nQTFXFI == 0))
							oModelGV7:LoadValue("GV7_CDTPVC", AllTrim(oXmlParser:GetCol("TPVEIC", nI)))
							oModelNeg:LoadValue("GFEA061A_GV9","GV9_TPLOTA", "2")
							oModelNeg:LoadValue("GFEA061A_GV9","GV9_UNIFAI", " ")
						ElseIf nQtFXFI != 0
							oModelGV7:LoadValue("GV7_QTFXFI", nQtFXFI)
							oModelGV7:LoadValue("GV7_UNICAL", cUnPes)
							oModelNeg:LoadValue("GFEA061A_GV9","GV9_TPLOTA", "1")
						EndIf
					EndIf
				EndIf
			EndIf
			(cAuxAlias)->(DbCloseArea())
			
			// ========================================================================================================================================
			// Verifica se já existe uma Rota na tabela temporária
			// ========================================================================================================================================
			InsertRota(@oModelGV8)

			// ========================================================================================================================================
			// Verifica todas as tarifas vinculadas a uma negociação
			// ========================================================================================================================================
			cAuxAlias := GetNextAlias()
			cQuerySQL := "SELECT *"+;
						 " FROM " + oTemGV6:GetRealName() +;
						 " WHERE TRANSP = '" + AllTrim(cTrp) + "'" +;
						 " AND NRTAB = '" + AllTrim(cNrTab) + "'" +;
						 " AND NRNEG = '" + AllTrim(cNrNeg) + "'" +;
						 " AND CDFXTV = '" + AllTrim(cCdFxTv) + "'" +;
						 " AND NRROTA = '" + AllTrim(cNrRota) + "'"

			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySQL), cAuxAlias, .T., .T.)
			If (cAuxAlias)->(Eof())
				If Reclock(_cAliaGV6, .T.)
					(_cAliaGV6)->TRANSP := cTrp
					(_cAliaGV6)->NRTAB  := cNrTab
					(_cAliaGV6)->NRNEG  := cNrNeg
					(_cAliaGV6)->CDFXTV := cCdFxTv
					(_cAliaGV6)->NRROTA := cNrRota

					If !Empty(oXmlParser:GetCol("PRAZO"))
						(_cAliaGV6)->PRAZO   := Val(oXmlParser:GetCol("PRAZO", nI))
						(_cAliaGV6)->CONSPZ  := AllTrim(oXmlParser:GetCol("CONSPZ", nI))
						(_cAliaGV6)->TPPRAZ  := AllTrim(oXmlParser:GetCol("TPPRAZ", nI))
						(_cAliaGV6)->CONTPZ  := AllTrim(oXmlParser:GetCol("CONTPZ", nI))
					EndIf
					(_cAliaGV6)->(MsUnlock())
				EndIf
			EndIf
			(cAuxAlias)->(DbCloseArea())

			// ========================================================================================================================================
			// Verifica a tabela de Contrato de Transportes
			// ========================================================================================================================================
			InsertContrato()

			// ========================================================================================================================================
			// Verifica todos os componentes vinculados a uma negociação
			// ========================================================================================================================================
			InsertCompTab(@oModelGUY, @nI)
			
			// ========================================================================================================================================
			// Verifica todas as tarifas/componentes vinculadas a uma negociação
			// ========================================================================================================================================
			cAuxAlias := GetNextAlias()
			cQuerySQL := "SELECT *"+;
						 " FROM " + oTemGV1:GetRealName() +;
						 " WHERE TRANSP = '" + AllTrim(cTrp) + "'" +;
						 " AND NRTAB = '" + AllTrim(cNrTab) + "'" +;
						 " AND NRNEG = '" + AllTrim(cNrNeg) + "'" +;
						 " AND CDFXTV = '" + AllTrim(cCdFxTv) + "'" +;
						 " AND NRROTA = '" + AllTrim(cNrRota) + "'" +;
						 " AND COMPON = '" + AllTrim(oXmlParser:GetCol("COMPON",nI)) + "'"

			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySQL), cAuxAlias, .T., .T.)
			If (cAuxAlias)->(Eof())
				If Reclock(_cAliaGV1, .T.)
					(_cAliaGV1)->TRANSP := cTrp
					(_cAliaGV1)->NRTAB  := cNrTab
					(_cAliaGV1)->NRNEG  := cNrNeg
					(_cAliaGV1)->CDFXTV := cCdFxTv
					(_cAliaGV1)->NRROTA := cNrRota
					(_cAliaGV1)->COMPON := AllTrim(oXmlParser:GetCol("COMPON",nI))
					(_cAliaGV1)->VLFIXO := nVlFixo
					(_cAliaGV1)->VLUNIT := nVlUnit
					(_cAliaGV1)->PERVAL := nPerVal
					(_cAliaGV1)->VALMIN := nValMin
					(_cAliaGV1)->VALLIM := nValLim
					(_cAliaGV1)->VLFIXE := nVlFixE
					(_cAliaGV1)->PCEXTR := nPcExtr
					(_cAliaGV1)->VLUNIE := nVlUniE
					(_cAliaGV1)->CALCEX := AllTrim(oXmlParser:GetCol("CALCEX",nI))
					(_cAliaGV1)->FRACAO := nFracao
					If lFRACEX
						(_cAliaGV1)->FRACEX := nFRACEX
					EndIf
					(_cAliaGV1)->(MsUnlock())
				EndIf
			EndIf
			(cAuxAlias)->(DbCloseArea())
		Next

		// Último registro da Negociação de Frete e a situação da planilha permite a inclusão/alteração
		If !lReal .And. lSit
			oProcess:SetRegua2(0)
			oProcess:IncRegua2("Conferindo dados importados...")
			
			insertGV9(cChave, lSim)
		EndIf
	EndIf

	oProcess:IncRegua1("Finalizada a importação do arquivo!") 
	oProcess:SetRegua2(0)
	oProcess:IncRegua2("Criando somente o log da importação...")

	If lGerLog
		nHdl := FCreate(cLogDir + cFileName + ".txt")
		If nHdl == -1
			MsgAlert("Não foi possível criar o arquivo de log!")
			MsgInfo(cLogTxt)
		Else
			For nI := 1 To Len(aLog)
				FWrite(nHdl, aLog[nI])
			Next
			FClose(nHdl)
		EndIf
	EndIf

	oModelNeg  := Nil
	oXmlParser := Nil
	DelClassIntF()

	// Retorna filtro utilizado anteriormente usado
	GV9->(DbSetFilter({|| cGv9Filter }, cGv9Filter))

	MsgInfo("Operações concluídas. Consulte o log no caminho abaixo para mais informações: " + CRLF + CRLF + cLogDir+cFileName+".txt")

	RestArea(aAreaGUB)
	RestArea(aAreaGV9)
	RestArea(aAreaGVA)

Return


//============================================================================
// Classe/Metodos para leitura do arquivo XML e Validações iniciais
//============================================================================
CLASS XMLParserGFE61K FROM LongNameClass
	DATA _xml
	DATA aIdx
	DATA nRow
	DATA cAliasT
	DATA aFields

	Method New() Constructor
	Method GetCol()
	Method GetTotalRows()

ENDCLASS

Method New(cFile, lLibre) Class XMLParserGFE61K
	Local nI		 := 0
	Local nHdl 	     := 0
	Local nImp 		 := 0
	Local nPos	     := 0
	Local nPos2	     := 0
	Local nData      := 0
	Local nCount     := 0
	Local nIndexCell := 0
	Local cRow 	     := ""
	Local cData      := ""

	oProcess:SetRegua2(0)

	nHdl  := FOpen(cFile, FO_READWRITE + FO_SHARED)
	If nHdl < 0
		MsgAlert("Não foi possível abrir o arquivo!")
		FClose(nHdl)
		Return

	Else
		::_xml := {}

		FT_FUse(cFile)
		::nRow := 0
		FT_FGoTop()

		While !FT_FEOF()
			nCount++
			cRow := FT_FReadLn()
			oProcess:IncRegua2("Realizando leitura das linhas: " + cValToChar(::nRow))

			If "</Worksheet>" $ cRow
				Exit
			EndIf

			If "<Row" $ cRow
				::nRow := ::nRow + 1

			ElseIf "<Data ss:" $ cRow .and. ::nRow == 2
				nData := nData + 1
				
				If '<Data ss:Type="String">' $ cRow  
					nPos  := At('<Data ss:Type="String">', cRow)
					nPos2 := At('</Data>', cRow)
					nPos := nPos+Len('<Data ss:Type="String">')
					
				ElseIf '<Data ss:Type="Number">' $ cRow
					nPos  := At('<Data ss:Type="Number">', cRow)
					nPos2 := At('</Data>', cRow)
					nPos := nPos+Len('<Data ss:Type="Number">')
				EndIf	

				cData := SubStr(cRow,nPos,nPos2-nPos)

				Aadd(::_xml, Column():New(cData))

			ElseIf "<Data ss:" $ cRow .and. ::nRow > 2
				nData := nData + 1

				If '<Data ss:Type="String">' $ cRow  
					nPos  := At('<Data ss:Type="String">', cRow)
					nPos2 := At('</Data>', cRow) 
					nPos := nPos+Len('<Data ss:Type="String">')
					
				ElseIf '<Data ss:Type="Number">' $ cRow
					nPos  := At('<Data ss:Type="Number">', cRow)
					nPos2 := At('</Data>', cRow)
					nPos := nPos+Len('<Data ss:Type="Number">')
				EndIf	

				cData := SubStr(cRow,nPos,nPos2-nPos)
				
				If "ss:Index=" $ cRow
					nPos  := At('ss:Index="', cRow)
					nPos  := nPos + Len('ss:Index="')
					If "ss:StyleID" $ cRow
						nPos2 := At('" ss:StyleID',cRow)
					Else
						nPos2 := At('"><Data',cRow)
					EndIf

					nIndexCell := Val(SubStr(cRow, nPos, (nPos2 - nPos)))

					nData := nIndexCell
				
					If nIndexCell != 0 .and. nIndexCell <= Len(::_xml)
						::_xml[nIndexCell]:AddValue(cData)
					EndIf
				Else
					If nData <= Len(::_xml)
						::_xml[nData]:AddValue(cData)
					EndIf
				EndIf

			ElseIf '</Row>' $ cRow
				nData := 0

				// Apos Fechamento do bloco de informações, realiza a validação daquelas informações
				nImp += 1
				preVldFile(::_xml, nImp)
			EndIf

			FT_FSkip()
		EndDo

		For nI := Len(::_xml) to 1 step -1
			If !At('#' , ::_xml[nI]:cTitle) == 0
				::_xml := ADel( ::_xml, nI)
			EndIf
		Next
		
		FClose(nHdl)
	
	EndIf
		
	::nRow := ::nRow - 2	

Return Self

Method GetCol(cColumn, nRow) Class XMLParserGFE61K
	Local nX   := 0
	Local xRet := {}

	If nRow <> Nil

		For nX := 1 to Len(::_xml)
			If !Empty(::_xml[nX])
				If ::_xml[nX]:cTitle == cColumn
					If !nRow > Len(::_xml[nX]:aValues)
						xRet := ::_xml[nX]:aValues[nRow]
					Else
						xRet := ""
					EndIf
					Exit
				EndIf
			EndIf
		Next

	Else
		For nX := 1 to Len(::_xml)
			If ::_xml[nX]:cTitle == cColumn
				xRet := ::_xml[nX]:aValues
				Exit
			EndIf
		Next
	EndIf

Return xRet

Method GetTotalRows() Class XMLParserGFE61K
Return ::nRow

Static Function CriaTabTmp()
	
	_aFields := {{'TRANSP',TamSx3('GV9_CDEMIT')[3],TamSX3('GV9_CDEMIT')[1],TamSX3('GV9_CDEMIT')[2]},;
                 {'NRTAB' ,TamSx3('GV9_NRTAB')[3] ,TamSX3('GV9_NRTAB')[1] ,TamSX3('GV9_NRTAB')[2]},;
                 {'NRNEG' ,TamSx3('GV9_NRNEG')[3] ,TamSX3('GV9_NRNEG')[1] ,TamSX3('GV9_NRNEG')[2]},;
                 {'ORIGEM',TamSx3('GV8_CDREM')[3] ,TamSX3('GV8_CDREM')[1] ,TamSX3('GV8_CDREM')[2]},;
                 {'DESTIN',TamSx3('GV8_CDREM')[3] ,TamSX3('GV8_CDREM')[1] ,TamSX3('GV8_CDREM')[2]},;
                 {'NRROTA',TamSx3('GV8_NRROTA')[3] ,TamSX3('GV8_NRROTA')[1] ,TamSX3('GV8_NRROTA')[2]};
            	}

	oTemGV8 := FwTemporaryTable():New(_cAliaGV8,_aFields)
	oTemGV8:AddIndex('1', {'TRANSP',; 
							'NRTAB',;
							'NRNEG',;    
							'ORIGEM',; 
							'DESTIN' })

	oTemGV8:Create()

    _aFields := {{'TRANSP',TamSx3('GV9_CDEMIT')[3] ,TamSX3('GV9_CDEMIT')[1],TamSX3('GV9_CDEMIT')[2]},;
                 {'NRTAB' ,TamSx3('GV9_NRTAB')[3]  ,TamSX3('GV9_NRTAB')[1] ,TamSX3('GV9_NRTAB')[2]},;
                 {'NRNEG' ,TamSx3('GV9_NRNEG')[3]  ,TamSX3('GV9_NRNEG')[1] ,TamSX3('GV9_NRNEG')[2]},;
                 {'TPVEIC',TamSx3('GV7_CDTPVC')[3] ,TamSX3('GV7_CDTPVC')[1],TamSX3('GV7_CDTPVC')[2]},;
                 {'FAIXAF',TamSx3('GV7_QTFXFI')[3] ,TamSX3('GV7_QTFXFI')[1],TamSX3('GV7_QTFXFI')[2]},;
                 {'CDFXTV',TamSx3('GV7_CDFXTV')[3] ,TamSX3('GV7_CDFXTV')[1],TamSX3('GV7_CDFXTV')[2]};
            	}

	oTemGV7 := FwTemporaryTable():New(_cAliaGV7,_aFields)
	oTemGV7:AddIndex('1', {'TRANSP',; 
						   'NRTAB',;
						   'NRNEG',;    
						   'TPVEIC',;
						   'FAIXAF' })

	oTemGV7:Create()

    _aFields := {{'TRANSP',TamSx3('GV9_CDEMIT')[3],TamSX3('GV9_CDEMIT')[1],TamSX3('GV9_CDEMIT')[2]},;
                 {'NRTAB' ,TamSx3('GV9_NRTAB')[3] ,TamSX3('GV9_NRTAB')[1] ,TamSX3('GV9_NRTAB')[2]},;
                 {'NRNEG' ,TamSx3('GV9_NRNEG')[3] ,TamSX3('GV9_NRNEG')[1] ,TamSX3('GV9_NRNEG')[2]},;
                 {'COMPON',TamSx3('GUY_CDCOMP')[3] ,TamSX3('GUY_CDCOMP')[1] ,TamSX3('GUY_CDCOMP')[2]};
            	}

	oTemGUY := FwTemporaryTable():New(_cAliaGUY,_aFields)
	oTemGUY:AddIndex('1', {'TRANSP',; 
						   'NRTAB',;
						   'NRNEG',;     
						   'COMPON' })

	oTemGUY:Create()

	////// ------------------- GVW
	If GFXCP12125("GVW_CDEMIT")
		_aFields := {{'TRANSP',TamSx3('GV9_CDEMIT')[3],TamSX3('GV9_CDEMIT')[1],TamSX3('GV9_CDEMIT')[2]},;
                	 {'NRTAB' ,TamSx3('GV9_NRTAB')[3] ,TamSX3('GV9_NRTAB')[1] ,TamSX3('GV9_NRTAB')[2]},;
                	 {'NRNEG' ,TamSx3('GV9_NRNEG')[3] ,TamSX3('GV9_NRNEG')[1] ,TamSX3('GV9_NRNEG')[2]},;
                	 {'NRCT'  ,TamSx3('GVW_NRCT')[3]  ,TamSX3('GVW_NRCT')[1]  ,TamSX3('GVW_NRCT')[2]};
            		}

        oTemGVW := FwTemporaryTable():New(_cAliaGVW,_aFields)
        oTemGVW:AddIndex('1', {'TRANSP',; 
                               'NRTAB',;
                               'NRNEG',;     
                               'NRCT' })

        oTemGVW:Create()
    EndIf
    ////// ------------------- GVW

    _aFields := {{'TRANSP',TamSx3('GV9_CDEMIT')[3],TamSX3('GV9_CDEMIT')[1],TamSX3('GV9_CDEMIT')[2]},;
                 {'NRTAB' ,TamSx3('GV9_NRTAB')[3] ,TamSX3('GV9_NRTAB')[1] ,TamSX3('GV9_NRTAB')[2]},;
                 {'NRNEG' ,TamSx3('GV9_NRNEG')[3] ,TamSX3('GV9_NRNEG')[1] ,TamSX3('GV9_NRNEG')[2]},;
                 {'CDFXTV',TamSx3('GV6_CDFXTV')[3] ,TamSX3('GV6_CDFXTV')[1] ,TamSX3('GV6_CDFXTV')[2]},;
                 {'NRROTA',TamSx3('GV6_NRROTA')[3] ,TamSX3('GV6_NRROTA')[1] ,TamSX3('GV6_NRROTA')[2]},;
                 {'PRAZO' ,TamSx3('GV6_QTPRAZ')[3] ,TamSX3('GV6_QTPRAZ')[1] ,TamSX3('GV6_QTPRAZ')[2]},;
                 {'CONSPZ',TamSx3('GV6_CONSPZ')[3] ,TamSX3('GV6_CONSPZ')[1] ,TamSX3('GV6_CONSPZ')[2]},;
                 {'TPPRAZ',TamSx3('GV6_TPPRAZ')[3] ,TamSX3('GV6_TPPRAZ')[1] ,TamSX3('GV6_TPPRAZ')[2]},;
                 {'CONTPZ',TamSx3('GV6_CONTPZ')[3] ,TamSX3('GV6_CONTPZ')[1] ,TamSX3('GV6_CONTPZ')[2]};
            	}

	oTemGV6 := FwTemporaryTable():New(_cAliaGV6,_aFields)
	oTemGV6:AddIndex('1', { 'TRANSP',; 
                            'NRTAB',;
                            'NRNEG',;
                            'CDFXTV',; 
                            'NRROTA' })

	oTemGV6:Create()

    _aFields := {{'TRANSP',TamSx3('GV9_CDEMIT')[3],TamSX3('GV9_CDEMIT')[1],TamSX3('GV9_CDEMIT')[2]},;
                 {'NRTAB' ,TamSx3('GV9_NRTAB')[3] ,TamSX3('GV9_NRTAB')[1] ,TamSX3('GV9_NRTAB')[2]},;
                 {'NRNEG' ,TamSx3('GV9_NRNEG')[3] ,TamSX3('GV9_NRNEG')[1] ,TamSX3('GV9_NRNEG')[2]},;
                 {'CDFXTV',TamSx3('GV6_CDFXTV')[3] ,TamSX3('GV6_CDFXTV')[1] ,TamSX3('GV6_CDFXTV')[2]},;
                 {'NRROTA',TamSx3('GV6_NRROTA')[3] ,TamSX3('GV6_NRROTA')[1] ,TamSX3('GV6_NRROTA')[2]},;
                 {'COMPON',TamSx3('GV1_CDCOMP')[3] ,TamSX3('GV1_CDCOMP')[1] ,TamSX3('GV1_CDCOMP')[2]},;
                 {'VLFIXO',TamSx3('GV1_VLFIXN')[3] ,TamSX3('GV1_VLFIXN')[1] ,TamSX3('GV1_VLFIXN')[2]},;
                 {'VLUNIT',TamSx3('GV1_VLUNIN')[3] ,TamSX3('GV1_VLUNIN')[1] ,TamSX3('GV1_VLUNIN')[2]},;
                 {'PERVAL',TamSx3('GV1_PCNORM')[3] ,TamSX3('GV1_PCNORM')[1] ,TamSX3('GV1_PCNORM')[2]},;
                 {'VALMIN',TamSx3('GV1_VLMINN')[3] ,TamSX3('GV1_VLMINN')[1] ,TamSX3('GV1_VLMINN')[2]},;
                 {'VALLIM',TamSx3('GV1_VLLIM')[3]  ,TamSX3('GV1_VLLIM')[1]  ,TamSX3('GV1_VLLIM')[2]},;
                 {'VLFIXE',TamSx3('GV1_VLFIXE')[3] ,TamSX3('GV1_VLFIXE')[1] ,TamSX3('GV1_VLFIXE')[2]},;
                 {'PCEXTR',TamSx3('GV1_PCEXTR')[3] ,TamSX3('GV1_PCEXTR')[1] ,TamSX3('GV1_PCEXTR')[2]},;
                 {'VLUNIE',TamSx3('GV1_VLUNIE')[3] ,TamSX3('GV1_VLUNIE')[1] ,TamSX3('GV1_VLUNIE')[2]},;
                 {'CALCEX',TamSx3('GV1_CALCEX')[3] ,TamSX3('GV1_CALCEX')[1] ,TamSX3('GV1_CALCEX')[2]},;
                 {'FRACAO',TamSx3('GV1_VLFRAC')[3] ,TamSX3('GV1_VLFRAC')[1] ,TamSX3('GV1_VLFRAC')[2]};
            	}

	If lFRACEX
		Aadd(_aFields,{'FRACEX',TamSx3('GV1_FRACEX')[3] ,TamSX3('GV1_FRACEX')[1] ,TamSX3('GV1_FRACEX')[2]})
	EndIf

	oTemGV1 := FwTemporaryTable():New(_cAliaGV1,_aFields)
	oTemGV1:AddIndex('1',{'TRANSP',; 
						  'NRTAB',;
						  'NRNEG',;
						  'CDFXTV',;
						  'NRROTA',;
						  'COMPON' })

	oTemGV1:Create()
Return

// =============================================================================================================================================================================
// Adicionado Demais validações para ser realizadas em momento de leitura de cada linha, melhorando performance para nao ter que tratar novamente depois de leitura do arquivo
// =============================================================================================================================================================================
Static Function preVldFile(oRow, nImp)
	Local cAliGV2 	:= ""

	Private oXmlRow := oRow

	If Len(oXmlRow) > 0 .And. nImp > 2 // Não valida 2 linhas iniciais que são o cabeçalho das colunas
		cTrp   := PadR(GetDataCol("TRANSP"), nGV9CDEMIT)
		cNrTab := PadR(GetDataCol("NRTAB") , nGV9NRTAB)
		cNrNeg := PadR(GetDataCol("NRNEG") , nGV9NRNEG)

		cLogTxt := "--------------------------------------------------------------------------------------------" + CRLF
		cLogTxt += LogMessage("AVISO: Tentando operação do registro na linha número " + cValToChar(nImp) + " : " + CRLF +;
							"                                       Transportador   : " + cTrp + CRLF+;
							"                                       Nro. Tabela     : " + cNrTab + CRLF+;
							"                                       Nro. Negociação : " + cNrNeg + CRLF)
		
		// Verifica se a chave da tabela de frete encontrada ou se o arquivo está com formatação indevida.
		If Empty(cTrp) .Or. Empty(cNrTab) .Or. Empty(cNrNeg)
			cLogTxt += LogMessage("AVISO: Chave da tabela de frete não encontrada ou formatação do arquivo indevida" + CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)

			Aadd(aLog, cLogTxt)
			cLogTxt := ""
			nAcaoZero++
			Return
		EndIf

		// Valida se a ação permitir a importação dos registros
		If Empty(GetDataCol("ACAO")) .OR. AllTrim(GetDataCol("ACAO")) == "0"
			cLogTxt += LogMessage("AVISO: Registro com nenhuma ação definida, não serão realizadas operações" + CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)

			Aadd(aLog, cLogTxt)
			cLogTxt := ""
			nAcaoZero++
			Return
		EndIf

		// Valida se tipo de origem e código origem informado quando não for vazio e tipo origem não for 0-Todos
		If Empty(GetDataCol("TPORIG")) .Or. (!(GetDataCol("TPORIG") == '0') .And. Empty(GetDataCol("ORIGEM")))
			If Empty(GetDataCol("TPORIG"))
				cLogTxt += LogMessage("ERRO: Tipo origem não definida na rota da negociação de frete" + CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
			Else
				cLogTxt += LogMessage("ERRO: Origem não definida na rota da negociação de frete"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			EndIf
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Return
		EndIf

		// Valida se tipo de destino e código destino informado quando não for vazio e tipo destino não for 0-Todos
		If Empty(GetDataCol("TPDEST")) .Or. (!(GetDataCol("TPDEST") == '0') .And. Empty(GetDataCol("DESTIN")))
			If Empty(GetDataCol("TPDEST"))
				cLogTxt += LogMessage("ERRO: Tipo destino não definido na rota da negociação de frete"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			Else
				cLogTxt += LogMessage("ERRO: Destino não definido na rota da negociação de frete"+CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			EndIf
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""
			
			Return
		EndIf

		If Empty(GetDataCol("NRTAB")) .Or. Empty(GetDataCol("NRNEG")) .Or. Empty(GetDataCol("INICIO")) .Or. Empty(GetDataCol("COMPON"))
			cLogTxt += LogMessage("ERRO: Campos obrigatórios não informados"+CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Return
		EndIf

		nQtFXFI := Val(StrTran(GetDataCol("FAIXAF"),",","."))
		If !Empty(GetDataCol("TPVEIC")) .And. (!Empty(nQTFXFI) .Or. nQTFXFI != 0)
			cLogTxt += LogMessage("ERRO: Registro com ambos Tipo de Veículo e Faixa preenchidos. Somente um é permitido!" + CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Return
		EndIf

		cAliGV2 := GetNextAlias()

		BeginSQL Alias cAliGV2
			SELECT GV2.R_E_C_N_O_ RECNOGV2
			FROM %Table:GV2% GV2
			WHERE GV2.GV2_FILIAL = %xFilial:GV2%
			AND GV2.GV2_CDCOMP = %Exp:Alltrim(GetDataCol("COMPON"))%
			AND GV2.%NotDel%
		EndSQL

		If (cAliGV2)->(EoF())
			cLogTxt += LogMessage("ERRO: Componente (" + Alltrim(GetDataCol("COMPON")) + ") não está cadastrado na rotina de Componentes de Frete." + CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			(cAliGV2)->(dbCloseArea())
			Return
		EndIf

		(cAliGV2)->(dbCloseArea())

		nVlFixo := IIf(!Empty(GetDataCol("VLFIXO")), Val(StrTran(GetDataCol("VLFIXO"), ",", ".")), 0)
		nVlUnit := IIf(!Empty(GetDataCol("VLUNIT")), Val(StrTran(GetDataCol("VLUNIT"), ",", ".")), 0)
		nPerVal := IIf(!Empty(GetDataCol("PERVAL")), Val(StrTran(GetDataCol("PERVAL"), ",", ".")), 0)
		nValMin := IIf(!Empty(GetDataCol("VALMIN")), Val(StrTran(GetDataCol("VALMIN"), ",", ".")), 0)
		nValLim := IIf(!Empty(GetDataCol("VALLIM")), Val(StrTran(GetDataCol("VALLIM"), ",", ".")), 0)
		nVlFixE := IIf(!Empty(GetDataCol("VLFIXE")), Val(StrTran(GetDataCol("VLFIXE"), ",", ".")), 0)
		nPcExtr := IIf(!Empty(GetDataCol("PCEXTR")), Val(StrTran(GetDataCol("PCEXTR"), ",", ".")), 0)
		nVlUniE := IIf(!Empty(GetDataCol("VLUNIE")), Val(StrTran(GetDataCol("VLUNIE"), ",", ".")), 0)
		nFracao := IIf(!Empty(GetDataCol("FRACAO")), Val(StrTran(GetDataCol("FRACAO"), ",", ".")), 0)
		nFraExt := IIf(!Empty(GetDataCol("FRACEX")), Val(StrTran(GetDataCol("FRACEX"), ",", ".")), 0)

		// Valida Tipo de Cidade Origem
		cTpOri := RetTpOriDsT(AllTrim(GetDataCol("TPORIG")))
		If Empty(cTpOri)
			cLogTxt += LogMessage("ERRO: Tipo de Cidade Origem inválido!" + CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Return
		EndIf

		// Valida Tipo de Cidade Destino
		cTpDst := RetTpOriDsT(AllTrim(GetDataCol("TPDEST")))
		If Empty(cTpDst)
			cLogTxt += LogMessage("ERRO: Tipo de Cidade Destino inválido!" + CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Return
		EndIf

		If Empty(Posicione("GU3", 1, xFilial("GU3") + cTrp, "GU3_CDEMIT"))
			cLogTxt += LogMessage("ERRO: Transportador não encontrado!" + CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Return
		EndIf

		GVA->(DbSetOrder(1))
		If !GVA->(DbSeek(xFilial("GVA") + cTrp + cNrTab))
			cLogTxt += LogMessage("ERRO: Tabela de Frete não encontrada!" + CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Return
		EndIf

		If GVA->GVA_TPTAB == "2"
			cLogTxt += LogMessage("ERRO: Tabela de Frete não pode ser do tipo Vínculo!" + CRLF)
			cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
			lErro := .T.

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			Return
		EndIf

		// Valida a cidade de origem do rota
		cOri := VldOriDst(AllTrim(GetDataCol("ORIGEM")), cTpOri)
		If !(AllTrim(cTpOri) == '0') .And. Empty(cOri)
			If cTpOri $ "1;2;4;5"
				cLogTxt += LogMessage("ERRO: Cidade de Origem não encontrada!" + CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Return
			Else
				cLogTxt += LogMessage("ERRO: Região de Origem (" + AllTrim(GetDataCol("ORIGEM")) + ") não encontrada!" + CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Return
			EndIf
		EndIf

		// Valida a cidade de destino da rota
		cDst := VldOriDst(AllTrim(GetDataCol("DESTIN")), cTpDst)
		If !(AllTrim(cTpDst) == "0") .And. Empty(cDst)
			If  cTpDst $ "1;2;4;5"
				cLogTxt += LogMessage("ERRO: Cidade de Destino não encontrada!" + CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Return
			Else
				cLogTxt += LogMessage("ERRO: Região de Destino (" + AllTrim(GetDataCol("DESTIN")) + ") não encontrada!" + CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Return
			EndIf
		EndIf

		If !Empty(GetDataCol("NRCT"))
			cNrct  := PadR(GetDataCol("NRCT"), nGXTNRCT)

			GXT->(DbSetOrder(1))
			If !GXT->(DbSeek(xFilial('GXT') + cNrct))
				cLogTxt += LogMessage("ERRO: Contrato não encontrado!" + CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Return

			ElseIf GXT->GXT_CDTRP != cTrp
				cLogTxt += LogMessage("ERRO: Contrato vinculado a outro transportador!" + CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Return
			EndIf
		EndIf

		// =========================================================================================================
		// SEGUNDA PARTE DAS VALIDAÇÕES
		// =========================================================================================================
		Do Case
			Case AllTrim(GetDataCol("ACAO")) == "1"
				GV9->(DbSetOrder(1))
				If GV9->(DbSeek(xFilial("GV9") + cTrp + cNrTab + cNrNeg))
					If GV9->GV9_SIT == "1"
						Aadd(aLog, cLogTxt)
						cLogTxt := ""
					Else
						cLogTxt += LogMessage("ERRO: Não Alterado! Somente é possível alterar negociações com o status 'Em Negociação' !" + CRLF)
						cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
						lErro := .T.

						Aadd(aLog, cLogTxt)
						cLogTxt := ""

						Return
					EndIf
				Else
					Aadd(aLog, cLogTxt)
					cLogTxt := ""
				EndIf

			OtherWise
				cLogTxt += LogMessage("ERRO: Ação inválida informada!" + CRLF)
				cLogTxt += LogMessage("AVISO: Fim da Operação do registro número " + cValToChar(nImp) + "." + CRLF + CRLF)
				lErro := .T.

				Aadd(aLog, cLogTxt)
				cLogTxt := ""

				Return
		EndCase
	EndIf
Return 

Static Function GetDataCol(cColumn)
	Local nX   := 0
	Local nPos := 0
	Local xRet := {}

	For nX := 1 To Len(oXmlRow)
		If !Empty(oXmlRow[nX])
			If oXmlRow[nX]:cTitle == cColumn
				nPos := Len(oXmlRow[nX]:aValues)
				If nPos == 0
					xRet := ""
				Else
					xRet := oXmlRow[nX]:aValues[nPos]
				EndIf

				Exit
			EndIf
		EndIf
	Next

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LogMessage(cMessage)
Criação de logs durante a importação de tabela de frete
/*/
//-------------------------------------------------------------------
Function LogMessage(cMessage)
	cMessage := "[" + cValToChar(Date()) +"]" + "["+cValToChar(Time())+"]"+ " : "+cMessage
Return cMessage


Static Function insertGV9(cChave, lSim)
	Local nTarifa    := 0
	Local cChGV6     := ""
	Local cAuxGV1    := ""
	Local cQuerySQL  := ""
	Local lGV6       := .F.
	Local lFound     := .F.
	Local aArea      := GV9->(GetArea())
	Local oModelGV1  := oModelTRF:GetModel("DETAIL_GV1")

	If oModelNeg:VldData()
		If lSim
			cLogTxt += LogMessage("AVISO: Operação simulada com Sucesso." + CRLF)
			Aadd(aLog, cLogTxt)
			cLogTxt := ""
		Else
			oModelNeg:CommitData()
			cLogTxt += LogMessage("AVISO: Negociação "+cAcao+" com Sucesso." + CRLF)

			If lFoundGXT
				cAuxAlias := GetNextAlias()
				cQuerySQL := "SELECT *"+;
							" FROM " + oTemGVW:GetRealName() +;
							" WHERE TRANSP = '" + AllTrim(cTrp) + "'" +;
							" AND NRTAB = '" + AllTrim(cNrTab) + "'" +;
							" AND NRNEG = '" + AllTrim(cNrNeg) + "'"

				DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySQL), cAuxAlias, .T., .T.)
				While !(cAuxAlias)->(EoF())
					GVW->(DbCloseArea())
					GVW->(DbSetOrder(1))
					If !GVW->(dbSeek(xFilial("GVW")+(cAuxAlias)->TRANSP + (cAuxAlias)->NRTAB + (cAuxAlias)->NRNEG + xFilial("GXT") + (cAuxAlias)->NRCT))
						oModelCTR:SetOperation(MODEL_OPERATION_INSERT)
						criaGVW()
					EndIf
					
					(cAuxAlias)->(DbSkip())
				EndDo
				(cAuxAlias)->(DbCloseArea())
			EndIf

			Aadd(aLog, cLogTxt)
			cLogTxt := ""

			oModelNeg:Deactivate()

			// Após a criação da negociação, realiza a criação das Tarifas (GV6 e GV1)
			cAuxAlias := GetNextAlias()
			cQuerySQL := "SELECT *"+;
						 " FROM " + oTemGV6:GetRealName() +;
						 " WHERE TRANSP = '" + AllTrim(cTrp) + "'" +;
						 " AND NRTAB = '" + AllTrim(cNrTab) + "'" +;
						 " AND NRNEG = '" + AllTrim(cNrNeg) + "'"

			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySQL), cAuxAlias, .T., .T.)
			While (cAuxAlias)->(!Eof()) .Or. Empty(cChave)
				nTarifa++
				oProcess:IncRegua2("Validando tarifa importada..." + cValToChar(nTarifa))	

					// Se for uma nova tarifa realiza a criação da tarifa anterior
					If !Empty(cChGV6) .And. cChGV6 <> (cAuxAlias)->TRANSP + (cAuxAlias)->NRTAB + (cAuxAlias)->NRNEG + (cAuxAlias)->CDFXTV+ (cAuxAlias)->NRROTA
						lGV6 = .T.
						criaGV6(cChGV6)
					EndIf

					If Empty(cChGV6) .or. (cChGV6 <> (cAuxAlias)->TRANSP + (cAuxAlias)->NRTAB + (cAuxAlias)->NRNEG + (cAuxAlias)->CDFXTV+(cAuxAlias)->NRROTA)
						lGV6 := .F.
						cChGV6 := (cAuxAlias)->TRANSP + (cAuxAlias)->NRTAB + (cAuxAlias)->NRNEG + (cAuxAlias)->CDFXTV + (cAuxAlias)->NRROTA	
					EndIf

					GV9->(DbCloseArea())
					GV9->(DbSetOrder(1))
					If GV9->(DbSeek(xFilial("GV9")+(cAuxAlias)->TRANSP+(cAuxAlias)->NRTAB+(cAuxAlias)->NRNEG))
						lFound := .T.

						GV6->(DbSetOrder(1))
						If !GV6->(DbSeek(xFilial("GV6")+(cAuxAlias)->TRANSP+(cAuxAlias)->NRTAB+(cAuxAlias)->NRNEG+(cAuxAlias)->CDFXTV+(cAuxAlias)->NRROTA))
							//Cria
							oModelTRF:Activate()
							
							If FWModeAccess("GV6",1) == "E"
								oModelTRF:LoadValue("GFEA061F_GV6","GV6_FILIAL", xFilial('GV6') )
							EndIf
							
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_CDEMIT", (cAuxAlias)->TRANSP)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_NRTAB" , (cAuxAlias)->NRTAB)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_NRNEG" , (cAuxAlias)->NRNEG)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_CDFXTV", (cAuxAlias)->CDFXTV)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_NRROTA", (cAuxAlias)->NRROTA)
						Else
							oModelTRF:Activate()
						EndIf

						If !Empty(oXmlParser:GetCol("PRAZO"))
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_QTPRAZ", (cAuxAlias)->PRAZO)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_CONSPZ", (cAuxAlias)->CONSPZ)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_TPPRAZ", (cAuxAlias)->TPPRAZ)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_CONTPZ", (cAuxAlias)->CONTPZ)
						Else
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_QTPRAZ", 0)
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_CONSPZ", "0")
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_TPPRAZ", "0")
							oModelTRF:LoadValue("GFEA061F_GV6","GV6_CONTPZ", "0")
						EndIf


						cAuxGV1 := GetNextAlias()
						cQuerySQL := "SELECT *"+;
									" FROM " + oTemGV1:GetRealName() +;
									" WHERE TRANSP = '" + AllTrim((cAuxAlias)->TRANSP) + "'" +;
									" AND NRTAB = '" + AllTrim((cAuxAlias)->NRTAB) + "'" +;
									" AND NRNEG = '" + AllTrim((cAuxAlias)->NRNEG) + "'" +;
									" AND CDFXTV = '" + AllTrim((cAuxAlias)->CDFXTV) + "'" +;
									" AND NRROTA = '" + AllTrim((cAuxAlias)->NRROTA) + "'"

						DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySQL), cAuxGV1, .T., .T.)
						While (cAuxGV1)->(!Eof())
							GV1->(DbSetOrder(1))
							If !GV1->(DbSeek(xFilial("GV1")+(cAuxGV1)->TRANSP+(cAuxGV1)->NRTAB+(cAuxGV1)->NRNEG+(cAuxGV1)->CDFXTV+(cAuxGV1)->NRROTA+(cAuxGV1)->COMPON))
								//Cria
								If oModelGV1:GetQtdLine() > 1 .or. !Empty(oModelGV1:GetValue('GV1_CDCOMP',1))
									oModelGV1:Addline(.T.)
								EndIf

								oModelGV1:LoadValue("GV1_CDEMIT", (cAuxAlias)->TRANSP)
								oModelGV1:LoadValue("GV1_NRTAB" , (cAuxAlias)->NRTAB)
								oModelGV1:LoadValue("GV1_NRNEG" , (cAuxAlias)->NRNEG)
								oModelGV1:LoadValue("GV1_CDFXTV", (cAuxAlias)->CDFXTV)
								oModelGV1:LoadValue("GV1_NRROTA", (cAuxAlias)->NRROTA)
								oModelGV1:LoadValue("GV1_CDCOMP", (cAuxGV1)->COMPON)
							EndIf

							oModelGV1:SeekLine({{"GV1_CDCOMP", (cAuxGV1)->COMPON}})

							oModelGV1:LoadValue("GV1_VLFIXN", (cAuxGV1)->VLFIXO)
							oModelGV1:LoadValue("GV1_VLUNIN", (cAuxGV1)->VLUNIT)
							oModelGV1:LoadValue("GV1_PCNORM", (cAuxGV1)->PERVAL)
							oModelGV1:LoadValue("GV1_VLMINN", (cAuxGV1)->VALMIN)
							oModelGV1:LoadValue("GV1_VLLIM" , (cAuxGV1)->VALLIM)
							oModelGV1:LoadValue("GV1_VLFIXE", (cAuxGV1)->VLFIXE)
							oModelGV1:LoadValue("GV1_PCEXTR", (cAuxGV1)->PCEXTR)
							oModelGV1:LoadValue("GV1_VLUNIE", (cAuxGV1)->VLUNIE)
							oModelGV1:LoadValue("GV1_CALCEX", (cAuxGV1)->CALCEX)
							oModelGV1:LoadValue("GV1_VLFRAC", (cAuxGV1)->FRACAO)

							If lFRACEX
								oModelGV1:LoadValue("GV1_FRACEX", (cAuxGV1)->FRACEX)	
							EndIf

							(cAuxGV1)->(DbSkip())
						EndDo
						(cAuxGV1)->(DbCloseArea())

					EndIf

				(cAuxAlias)->(DBSkip())
			EndDo
			(cAuxAlias)->(DbCloseArea())

			If !lGV6 .and. lFound
				criaGV6(,lSim)
			EndIf
		EndIf
	Else
		cLogTxt += LogMessage(oModelNeg:GetErrorMessage()[6] + CRLF)
		cLogTxt += LogMessage("AVISO: Fim da Operação do registro número "+cValToChar(nImp)+"." + CRLF + CRLF)
		Aadd(aLog, cLogTxt)
		cLogTxt := ""
		oModelNeg:Deactivate()
	EndIf
	RestArea(aArea)
Return


Static Function InsertRota(oModelGV8)
	Local nPos 		:= 0
	Local cQuery    := ""
	Local cQuerySQL := ""
	Local lNrRota   := .F.
	Local cTabName  := oTemGV8:GetRealName()
	Local cAuxAlias := GetNextAlias()
	Local cAliasQry := GetNextAlias()

	cQuerySQL := "SELECT *"+;
					" FROM " + cTabName +;
					" WHERE TRANSP = '" + AllTrim(cTrp) + "'" +;
					" AND NRTAB = '" + AllTrim(cNrTab) + "'" +;
					" AND NRNEG = '" + AllTrim(cNrNeg) + "'" +;
					" AND ORIGEM = '" + AllTrim(cOri) + "'" +;
					" AND DESTIN = '" + AllTrim(cDst) + "'"

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySQL), cAuxAlias, .T., .T.)
	If (cAuxAlias)->(!Eof())
		cNrRota := (cAuxAlias)->NRROTA
	Else

		// Caso exista a tabela já criada na tabela de frete, atualiza o número da rota que deverá ser utilizado
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT MAX(GV8.GV8_NRROTA) GV8_NRROTA
			FROM %Table:GV8% GV8
			WHERE GV8.GV8_FILIAL = %xFilial:GV8%
			AND GV8.GV8_CDEMIT = %Exp:cTrp%
			AND GV8.GV8_NRTAB = %Exp:cNrTab%
			AND GV8.GV8_NRNEG = %Exp:cNrNeg%
			AND GV8.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			cNrRota := PadL(cvaltochar((cAliasQry)->GV8_NRROTA), 4, "0")
		EndIf
		(cAliasQry)->(dbCloseArea())
		

		(_cAliaGV8)->(DBGoTop())
		Do While !(_cAliaGV8)->(Eof())
			If AllTrim((_cAliaGV8)->TRANSP) + AllTrim((_cAliaGV8)->NRTAB) + AllTrim((_cAliaGV8)->NRNEG)  == AllTrim(cTrp) + AllTrim(cNrTab) + AllTrim(cNrNeg)
				cNrRota := IIf( cNrRota < (_cAliaGV8)->NRROTA,(_cAliaGV8)->NRROTA,cNrRota)
			EndIf
			(_cAliaGV8)->(DBSkip())
		EndDo
		cNrRota := PADL(cvaltochar(Val(cNrRota)+1),4,"0")

		// Verifica se exista uma rota com a mesma origem/destino na tabela de frete
		cAliasQry := GetNextAlias()
		cQuery := " SELECT GV8_NRROTA "
		cQuery += " FROM " + RetSQLName("GV8")
		cQuery += " WHERE GV8_FILIAL = '" + xFilial("GV8") + "'"
		cQuery += " AND GV8_CDEMIT = '" + cTrp + "'"
		cQuery += " AND GV8_NRTAB = '" + cNrTab + "'"
		cQuery += " AND GV8_NRNEG = '" + cNrNeg + "'"
		cQuery += " AND GV8_TPORIG = '" + cTpOri + "'"
		Do Case
			Case cTpOri == '1'
				cQuery += " AND GV8_NRCIOR = '" + PadR(cOri, nGV8NRCIOR) + "'"
			Case cTpOri == '2'
				cQuery += " AND GV8_DSTORI = " + cValToChar(Val(Substr(cOri, 1, at("-",cOri) - 1)))
				cQuery += " AND GV8_DSTORF = " + cValToChar(Val(Substr(cOri, at("-",cOri) + 1, Len(cOri))))
			Case cTpOri == '3'
				cQuery += " AND GV8_NRREOR = '" + PadR(cOri, nGV8NRREOR) + "'"
			Case cTpOri == '4'
				cQuery += " AND GV8_CDPAOR = '" + PadR(cOri, nGV8CDPAOR) + "'"
				nPos := IIf(AT( "-", cOri) == 0, AT( "/", cOri), AT( "-", cOri)) + 1 	// Tratamento para buscar o estado considerando "-" ou "/"
				cQuery += " AND GV8_CDUFOR = '" + PadR(Substr(cOri, nPos, nGV8CDUFOR), nGV8CDUFOR) + "'"
			Case cTpOri == '5'
				cQuery += " AND GV8_CDREM  = '" + PadR(cOri, nGV8CDREM) + "'"
		EndCase
		cQuery += " AND GV8_TPDEST = '" + cTpDst + "'"
		Do Case
			Case cTpDst == '1'
				cQuery += " AND GV8_NRCIDS = '" + PadR(cDst, nGV8NRCIDS) + "'"
			Case cTpDst == '2'
				cQuery += " AND GV8_DSTDEI = " + cValToChar(Val(Substr(cDst, 1, at("-",cDst) - 1)))
				cQuery += " AND GV8_DSTDEF = " + cValToChar(Val(Substr(cDst, at("-",cDst) + 1, Len(cDst))))
			Case cTpDst == '3'
				cQuery += " AND GV8_NRREDS = '" + PadR(cDst, nGV8NRREDS) + "'"
			Case cTpDst == '4'
				cQuery += " AND GV8_CDPADS = '" + PadR(cDst, nGV8CDPADS) + "'"
				nPos := IIf(AT( "-", cDst) == 0,AT( "/", cDst),AT( "-", cDst))+1		// Tratamento para buscar o estado considerando "-" ou "/"
				cQuery += " AND GV8_CDUFDS = '" + PadR(Substr(cDst, nPos, nGV8CDUFDS), nGV8CDUFDS) + "'"
			Case cTpDst == '5'
				cQuery += " AND GV8_CDDEST = '" + PadR(cDst, nGV8CDDEST) + "'"
		EndCase
		cQuery += " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		(cAliasQry)->( dbGoTop() )
		If (cAliasQry)->(!Eof())
			cNrRota := PadL(cValToChar(val((cAliasQry)->GV8_NRROTA)), 4, "0")
			lNrRota := .T.
		EndIf
		(cAliasQry)->(DbCloseArea())

		If !lNrRota
			If Reclock(_cAliaGV8, .T.)
				(_cAliaGV8)->TRANSP := cTrp
				(_cAliaGV8)->NRTAB  := cNrTab
				(_cAliaGV8)->NRNEG  := cNrNeg
				(_cAliaGV8)->ORIGEM := cOri
				(_cAliaGV8)->DESTIN := cDst
				(_cAliaGV8)->NRROTA := cNrRota
				(_cAliaGV8)->(MsUnlock())
			EndIf
		EndIf
		If (oModelGV8:GetQtdLine() > 1 .Or. !Empty(oModelGV8:GetValue('GV8_NRROTA',1))) .And. !lNrRota
			oModelGV8:Addline(.T.)
		EndIf

		GV8->(DbCloseArea())
		GV8->(DbSetOrder(1))
		If !GV8->(DbSeek(xFilial("GV8") + cTrp + cNrTab + cNrNeg + cNrRota))
			If !lNrRota
				oModelGV8:LoadValue("GV8_CDEMIT", cTrp)
				oModelGV8:LoadValue("GV8_NRTAB" , cNrTab)
				oModelGV8:LoadValue("GV8_NRNEG" , cNrNeg)
				oModelGV8:LoadValue("GV8_NRROTA", cNrRota)
				oModelGV8:LoadValue("GV8_TPORIG", cTpOri)

				Do Case
					Case cTpOri == '1'
						oModelGV8:LoadValue("GV8_NRCIOR", PadR(cOri, nGV8NRCIOR))
					Case cTpOri == '2'
						oModelGV8:LoadValue("GV8_DSTORI", Val(Substr(cOri, 1, at("-",cOri) - 1)) )
						oModelGV8:LoadValue("GV8_DSTORF", Val(Substr(cOri, at("-",cOri) + 1, Len(cOri))) )
					Case cTpOri == '3'
						oModelGV8:LoadValue("GV8_NRREOR", PadR(cOri, nGV8NRREOR))
					Case cTpOri == '4'
						oModelGV8:LoadValue("GV8_CDPAOR", PadR(cOri, nGV8CDPAOR))
						nPos := IIf(AT("-", cOri) == 0, AT("/", cOri), AT("-", cOri)) + 1	// Tratamento para buscar o estado considerando "-" ou "/"
						cOri := SUBSTR(cOri , nPos, nGV8CDUFOR)
						oModelGV8:LoadValue("GV8_CDUFOR", PadR(cOri, nGV8CDUFOR))
					Case cTpOri == '5'
						oModelGV8:LoadValue("GV8_CDREM", PadR(cOri, nGV8CDREM))
				EndCase

				oModelGV8:LoadValue("GV8_TPDEST", cTpDst)

				Do Case
					Case cTpDst == '1'
						oModelGV8:LoadValue("GV8_NRCIDS", PadR(cDst, nGV8NRCIDS))
					Case cTpDst == '2'
						oModelGV8:LoadValue("GV8_DSTDEI", Val(Substr(cDst, 1, at("-",cDst) - 1)) )
						oModelGV8:LoadValue("GV8_DSTDEF", Val(Substr(cDst, at("-",cDst) + 1, Len(cDst))) )
					Case cTpDst == '3'
						oModelGV8:LoadValue("GV8_NRREDS", PadR(cDst, nGV8NRREDS))
					Case cTpDst == '4'
						oModelGV8:LoadValue("GV8_CDPADS", PadR(cDst, nGV8CDPADS))
						nPos := IIf(AT( "-", cDst) == 0,AT( "/", cDst),AT( "-", cDst)) + 1	// Tratamento para buscar o estado considerando "-" ou "/"
						cDst := SUBSTR(cDst , nPos, nGV8CDUFDS)
						oModelGV8:LoadValue("GV8_CDUFDS", PadR(cDst, nGV8CDUFDS))
					Case cTpDst == '5'
						oModelGV8:LoadValue("GV8_CDDEST", PadR(cDst, nGV8CDDEST))
				EndCase
			EndIf
		EndIf
	EndIf
	(cAuxAlias)->(DbCloseArea())
Return

Static Function InsertContrato()
	Local cQuerySQL := ""
	Local cAuxAlias := GetNextAlias()

	If !Empty(cNrct)
		GXT->(DbSetOrder(1))
		If GXT->(DbSeek(xFilial('GXT') + cNrct))
			lFoundGXT := .T.
			cAuxAlias := GetNextAlias()
			cQuerySQL := "SELECT *"+;
						 " FROM " + oTemGVW:GetRealName() +;
						 " WHERE TRANSP = '" + AllTrim(cTrp) + "'" +;
						 " AND NRTAB = '" + AllTrim(cNrTab) + "'" +;
						 " AND NRNEG = '" + AllTrim(cNrNeg) + "'" +;
						 " AND NRCT = '" + AllTrim(cNrct) + "'"

			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySQL), cAuxAlias, .T., .T.)
			If (cAuxAlias)->(Eof())
				If Reclock(_cAliaGVW, .T.)
					(_cAliaGVW)->TRANSP := cTrp
					(_cAliaGVW)->NRTAB  := cNrTab
					(_cAliaGVW)->NRNEG  := cNrNeg
					(_cAliaGVW)->NRCT   := cNrct

					(_cAliaGVW)->(MsUnlock())
				EndIf
			EndIf
			(cAuxAlias)->(DbCloseArea())
		EndIf
	EndIf
Return

Static Function InsertCompTab(oModelGUY, nI)
	Local cQuerySQL := ""
	Local cAuxAlias := GetNextAlias()
	Local cTabName  := oTemGUY:GetRealName()
	Local cCodComp  := oXmlParser:GetCol("COMPON",nI)

	cQuerySQL := "SELECT *"+;
				 " FROM " + cTabName +;
				 " WHERE TRANSP = '" + AllTrim(cTrp) + "'" +;
				 " AND NRTAB = '" + AllTrim(cNrTab) + "'" +;
				 " AND NRNEG = '" + AllTrim(cNrNeg) + "'" +;
				 " AND COMPON = '" + AllTrim(cCodComp) + "'"

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySQL), cAuxAlias, .T., .T.)
	If (cAuxAlias)->(Eof())
		If Reclock(_cAliaGUY, .T.)
			(_cAliaGUY)->TRANSP := cTrp
			(_cAliaGUY)->NRTAB  := cNrTab
			(_cAliaGUY)->NRNEG  := cNrNeg
			(_cAliaGUY)->COMPON := AllTrim(cCodComp)

			(_cAliaGUY)->(MsUnlock())
		EndIf

		GUY->(DbCloseArea())
		GUY->(DbSetOrder(1))
		If !GUY->(DbSeek(xFilial("GUY") + cTrp + cNrTab + cNrNeg + PadR(cCodComp, nGV1CDCOMP)))
			If oModelGUY:GetQtdLine() > 1 .Or. !Empty(oModelGUY:GetValue('GUY_CDCOMP',1))
				oModelGUY:Addline(.T.)
			EndIf

			oModelGUY:LoadValue("GUY_CDEMIT", cTrp)
			oModelGUY:LoadValue("GUY_NRTAB" , cNrTab)
			oModelGUY:LoadValue("GUY_NRNEG" , cNrNeg)
			oModelGUY:LoadValue("GUY_CDCOMP", PadR(cCodComp, nGV1CDCOMP))
		EndIf
	EndIf
	(cAuxAlias)->(DbCloseArea())
Return
