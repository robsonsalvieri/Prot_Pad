#INCLUDE "JURXFIX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

Static _lExecutou    := .F.
Static _cEmpresa     := ""
Static _aTabExist    := {}
Static _aColExist    := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} JURXFIX
Esta função é responsável por compatibilizar os dados do módulo
pré-faturamento de Serviços (PFS).

@author Abner Fogaça de Oliveira
@since 16/02/26
/*/
//-------------------------------------------------------------------
Main Function JURXFIX()
Local oModal     := FWDialogModal():New()
Local aTFolder   := {STR0001, STR0002} //#"Compatibilizador" ##"Selecionar Empresas"
Local aEmp       := RupGetEmp()
Local oMarkNo    := LoadBitmap(GetResources(), "LBNO")
Local oMarkOk    := LoadBitmap(GetResources(), "LBOK")
Local cRelStart  := "2210" // "Release inicial"
Local cRelFinish := GetRpoRelease()
Local cMemo      := ""
Local oMemoTermo := Nil
Local oAceite    := Nil
Local lAceite    := .F.
Local oListbox   := Nil

	oModal:SetFreeArea(300, 150)
	oModal:SetEscClose(.T.)
	oModal:SetTitle(STR0003) //"Compatibilizador do módulo - SIGAPFS"
	oModal:CreateDialog()
	oModal:addOkButton({|| Iif(lAceite, (RupProc(aEmp, cRelStart, cRelFinish), oModal:oOwner:End()), ApMsgStop(STR0004, STR0001))}) //# "É necessário confirmar a realização dos procedimentos antes executar o compatibilizador."  ##"Compatibilizador"
	oModal:addCloseButton()
	oMainPnl := oModal:GetPanelMain()

	oTFolder := TFolder():New( 0, 0, aTFolder, , oMainPnl, , , , .T., , , )
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	oTFolder:bSetOption := ({||})
	oTfolder1 := oTFolder:aDialogs[1]
	oTfolder2 := oTFolder:aDialogs[2]

	//Folder 1
	cMemo := + CRLF
	cMemo += STR0013 + CRLF + CRLF // "Por se tratar de um processo crítico é necessário fazer uma cópia de segurança do diretório de dicionários e demais arquivos locais, bem como da base de dados."
	cMemo += STR0014 + CRLF + CRLF // "Note que a base de dados pode estar armazenada em arquivos locais ou em banco de dados relacional, isto varia de acordo com sua instalação."
	cMemo += STR0015 + CRLF + CRLF // "Verifique se há espaço livre em disco para os arquivos locais e no banco de dados relacional, quando utilizado."

	oMemoTermo := TMultiget():New(010, 010, {| u | If( pCount() > 0, cMemo := u, cMemo ) }, oTfolder1, 279, 100, , , , , , .T., , , , , , .T., , , , , .T.)
	oAceite := TCheckBox():New(115, 010, STR0005, {|u| If(PCount() > 0, lAceite := u, lAceite)}, oTfolder1, 200, 008, , , , , , , ,.T., , , , ) // "Verifiquei os procedimentos antes de executar o compatibilizador."

	//Folder 2
	@ 10, 10 Listbox oListbox /*Var cVar*/ Fields Header " ", STR0006, STR0007 Size 279, 100 Of oTfolder2 Pixel //#"Código" ## "Grupo de Empresa"
	oListbox:SetArray(aEmp[1])
	oListbox:bLine := {|| {IIf( aEmp[1][oListbox:nAt, 1], oMarkOk, oMarkNo ), ;
	aEmp[1][oListbox:nAt, 2], ;
	aEmp[1][oListbox:nAt, 3]}}
	oListbox:BlDblClick   := { || aEmp[1][oListbox:nAt, 1] := !aEmp[1][oListbox:nAt, 1], oListbox:Refresh()}
	oListbox:BHeaderClick := { || aEval(aEmp[1], {|a, n| aEmp[1][n, 1] := !aEmp[1][n,1]}), oListbox:Refresh() }
	oListbox:cToolTip     := oModal:cTitle
	oListbox:lHScroll     := .F. // NoScroll

	oModal:Activate()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RupGetEmp()
Função para retonar o grupo de empresas e filiais do sistema.

@Return aEmp    Array com as informaçoes das SM0

@Author SISJURI
@since 17/01/2019
/*/
//-------------------------------------------------------------------
Static function RupGetEmp()
Local aEmp     := {}
Local aSM0     := {}
Local nI       := 0
Local cEmpAux  := ""
Local aMarcEmp := {}
Local aProcEmp := {}

	OpenSm0()
	aSM0 := FWLoadSM0(.T., .F.)

	For nI := 1 To Len(aSM0)
		If cEmpAux != aSM0[nI][1]
			Aadd(aMarcEmp, {.T., aSM0[nI][1], aSM0[nI][6]})
			cEmpAux := aSM0[nI][1]
		EndIf
		Aadd(aProcEmp, {aSM0[nI][1], aSM0[nI][2]})
	Next nI

	aEmp := {aClone(aMarcEmp), aClone(aProcEmp)}
	JurFreeArr(@aMarcEmp)
	JurFreeArr(@aProcEmp)

Return aEmp

//-------------------------------------------------------------------
/*/{Protheus.doc} RupSetcEmp(aEmp, cMsgEmp)
Função para retonar as empresas selecionadas para executar o Rup.

@Param aEmp      Array gerado pela rotina RupGetEmp()
@Param cMsgEmp   Mensagem com as empresas selecionada sem dicionário
                 carregado, passado por referencia

@Return aEmpRup  Array com as empresas selecionadas

@Author SISJURI
@since 17/01/2019
/*/
//-------------------------------------------------------------------
Static function RupSetcEmp(aEmp, cMsgEmp)
Local aEmpRup   := {}
Local aEmpMark  := aEmp[1]
Local aEmpAll   := aEmp[2]
Local nI        := 0
Local aEmpMsg   := {}

	Default cMsgEmp := ""

	For nI := 1 To Len(aEmpAll)
		If aScan(aEmpMark, {|x| x[1] .And. x[2] == aEmpAll[nI][1]}) > 0
			If MpDicInDb() .Or. RpcChkSxs(aEmpAll[nI][1], @aEmpMsg, .F.)
				aAdd(aEmpRup, aClone(aEmpAll[nI]))
			EndIf
		EndIf
	Next nI

	Aeval(aEmpMsg, {|x| cMsgEmp += I18N(STR0008 + CRLF, {x[1]})} ) //"A Empresa '#1' não tem dados para serem compatibilizados."
	JurFreeArr(@aEmpAll)

Return aEmpRup

//-------------------------------------------------------------------
/*/{Protheus.doc} RupProc()
Função para retonar o grupo de empresas e filiais do sistema.

@Return aEmp    Array com as informaçoes das SM0

@Author SISJURI
@since 17/01/2019
/*/
//-------------------------------------------------------------------
Static function RupProc(aEmp, cRelStart, cRelFinish)
Local lRet      := .T.
Local cEmpMsg   := ""
Local aEmpresas := RupSetcEmp(aEmp, @cEmpMsg)
Local cRelIni   := SubStr(cRelStart, rat('.', cRelStart) + 1)
Local cRelFin   := SubStr(cRelFinish, rat('.', cRelFinish) + 1)

	FWMsgRun(, {|| lRet := RupProcRun(aEmpresas, cRelIni, cRelFin) }, STR0001, STR0009) //"Compatibilizando as empresas selecionadas..."

	If lRet
		ApMsgInfo(cEmpMsg + CRLF + STR0010, STR0001) //# "Compatibilizador finalizado com sucesso." ## "Compatibilizador"
	Else
		ApMsgStop(cEmpMsg + CRLF + STR0011, STR0001) //# "Compatibilizador finalizado com erro." ## "Compatibilizador"
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RupProcRun()
Rotina de abertura de ambiente e execução do Rup por empresa e filial.

@Return aEmpresas   Array com as informaçoes das empresas
@param  cRelStart   Release de partida Ex: 014
@param  cRelFinish  Release de chegada Ex: 017

@Author SISJURI
@since 17/01/2019
/*/
//-------------------------------------------------------------------
Static function RupProcRun(aEmpresas, cRelStart, cRelFinish)
Local lRet     := .T.
Local cEmpOld  := ""
Local cEmpAux  := ""
Local cFilAux  := ""
Local nI       := 0
Local nP       := 0

	Private __CINTERNET := Nil // Habilita mensagens em tela após a preparação de ambiente

	For nI := 1 To Len(aEmpresas)
		cEmpAux  := aEmpresas[nI][1]
		cFilAux  := aEmpresas[nI][2]

		If cEmpOld != cEmpAux // Monta ambiente com nova empresa
			cEmpOld := cEmpAux
			RPCSetType(3) // Prepara o ambiente e não consome licença
			lRet := RpcSetEnv(cEmpAux, cFilAux, /*cEnvUser*/, /*cEnvPass*/, "PFS", /*cFunName*/ "PFSRUN", /*aTables*/, /*lShowFinal*/, /*lAbend*/,  /*lOpenSX*/ .T., /*lConnect*/.T.)
			__CINTERNET := Nil
		Else
			cFilAnt := cFilAux // Troca filial da mesma empresa
		EndIf

		If lRet
			FWMsgRun(, {|| PFSRUN( , , cRelStart, cRelFinish, )}, STR0001, I18N(STR0012, {"["+cEmpAnt+"]", "["+cFilAnt+"] "})) // "Compatibilizando a empresa: #1 e filial: #2..."
		EndIf

		nP := nI + 1
		If nP <= Len(aEmpresas) .And. aEmpresas[nP][1] != cEmpAux
			RpcClearEnv()
		EndIf
	Next nI

Return lRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} JChkfile
Execução da Rotina de Verificação de Tabelas em Buffer

@return lRet, Indica se a tabela existe

@author fabiana.silva
@since  25/06/2021
/*/
//-------------------------------------------------------------------------
Static Function JChkfile(cAlias)
Local nPos := {}
Local lRet := .F.

	If (nPos := aScan(_aTabExist, {|t| t[1] == cAlias})) > 0
		lRet := _aTabExist[nPos, 2]
	Else
		lRet := Chkfile(cAlias)
		aAdd(_aTabExist, {cAlias, lRet})
	EndIf

Return lRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} JColumnPos
Execução da Rotina de Verificação de Colunas em Buffer

@param  cCampo, Campo a ser verificado

@return nRet  , Indica a posição do campo no banco

@author fabiana.silva
@since  25/06/2021
/*/
//-------------------------------------------------------------------------
Static Function JColumnPos(cCampo)
Local nPos := {}
Local nRet := 0
Local cAls := ""

	If (nPos := aScan(_aColExist, {|t| t[1] == cCampo})) > 0
		nRet := _aColExist[nPos, 2]
	Else
		cAls := Substr(cCampo, 1, At("_", cCampo) - 1)

		If Len(cAls) < 3
			cAls := "S" + cAls
		EndIf

		nRet := (cAls)->(ColumnPos(cCampo))
		aAdd(_aColExist, {cCampo, nRet})
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PFSRUN
Função para compatibilização do release incremental.
Esta função é relativa ao módulo pré-faturamento de Serviços (PFS).

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA

@Author Abner Fogaça de Oliveira
@since 18/02/2026
/*/
//-------------------------------------------------------------------
Function PFSRUN(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

If _cEmpresa == cEmpAnt //Controle para permitir a atualização de todas as empresas
	_lExecutou := .T.
Else
	//Reinicia as variáveis estáticas a cada mudança de empresa, para alteração de dicionário de dados
	_lExecutou  := .F.
	_cEmpresa   := cEmpAnt
	_aTabExist  := {}
	_aColExist  := {}
EndIf

//------------------------------------------------------
// Atualizações necessárias para clientes que estão no release 12.1.33
//------------------------------------------------------
If cRelFinish >= "2210"

// Release 12.1.2510
	//---------------------------------------------------------------------------------------------
	// DJURFAT1-20360 - Saldos do limite por fatura na moeda do limite - Tipo 004-Limite por fatura
	//---------------------------------------------------------------------------------------------
	If JColumnPos("NXB_CMOELI") > 0
		JPFS20360()
	EndIf

	//---------------------------------------------------------------------------------------------
	// DJURFAT1-21183 - [Reforma tributária] - Substituição do campo concatenado NZQ_CPAGTO [016390]
	//---------------------------------------------------------------------------------------------
	If JColumnPos("NZQ_CPIDK7") > 0
		JPFS21183("NZQ", "NZQ_CPAGTO", "NZQ_CPIDK7")
	EndIf

	//---------------------------------------------------------------------------------------------
	// DJURFAT1-21184 - [Reforma tributária] - Substituição do campo concatenado NV4_CPAGTO [016390]
	//---------------------------------------------------------------------------------------------
	If JColumnPos("NV4_CPIDK7") > 0
		JPFS21183("NV4", "NV4_CPAGTO", "NV4_CPIDK7")
	EndIf

	//---------------------------------------------------------------------------------------------
	// DJURFAT1-21185 - [Reforma tributária] - Substituição do campo concatenado NVY_CPAGTO [016390]
	//---------------------------------------------------------------------------------------------
	If JColumnPos("NVY_CPIDK7") > 0
		JPFS21183("NVY", "NVY_CPAGTO", "NVY_CPIDK7")
	EndIf

	//---------------------------------------------------------------------------------------------
	// DJURFAT1-21180 - [Reforma tributária] - Substituição do campo concatenado OHB_CPAGTO [016390]
	//---------------------------------------------------------------------------------------------
	If JColumnPos("OHB_CPIDK7") > 0
		JPFS21183("OHB", "OHB_CPAGTO", "OHB_CPIDK7")
	EndIf

	//---------------------------------------------------------------------------------------------
	// DJURFAT1-21181 - [Reforma tributária] - Substituição do campo concatenado OHB_FATPAG [016390]
	//---------------------------------------------------------------------------------------------
	If JColumnPos("OHB_FPIDK7") > 0
		JPFS21183("OHB", "OHB_FATPAG", "OHB_FPIDK7")
	EndIf

	//---------------------------------------------------------------------------------------------
	// DJURFAT1-21179 - [Reforma tributária] - Substituição do campo concatenado OHB_CRECEB [016390]
	//---------------------------------------------------------------------------------------------
	If JColumnPos("OHB_CRIDK7") > 0
		JPFS21179("OHB", "OHB_CRECEB", "OHB_CRIDK7")
	EndIf

	//---------------------------------------------------------------------------------------------
	// DJURFAT1-21182 - [Reforma tributária] - Substituição do campo concatenado OHI_CHVTIT [016390]
	//---------------------------------------------------------------------------------------------
	If JColumnPos("OHI_CRIDK7") > 0
		JPFS21179("OHI", "OHI_CHVTIT", "OHI_CRIDK7")
	EndIf

EndIf

Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JPFS20360
Realiza o preenchimento dos campo NXB_CMOELI para os tipos de honorários Limite Por fatura e
Limite por período.

@author Abner Fogaça de Oliveira
@since  16/02/2026
/*/
//---------------------------------------------------------------------------------------------------
Static Function JPFS20360()
Local aAreaNXB  := NXB->(GetArea())
Local cQuery    := ""
Local cAlsTmp   := ""
Local aParams   := {}
Local oQuery    := Nil

	cQuery := " SELECT NXB.R_E_C_N_O_ RECNXB, NX8.NX8_CMOELI"
	cQuery +=   " FROM " + RetSqlName("NXB") + " NXB"
	cQuery +=  " INNER JOIN " + RetSqlName("NTH") + " NTH"
	cQuery +=     " ON NTH.NTH_FILIAL = NXB.NXB_FILIAL"
	cQuery +=    " AND NTH.NTH_CTPHON = NXB.NXB_CTPHON"
	cQuery +=    " AND NTH.D_E_L_E_T_ = ?"
	Aadd(aParams, {"C", ' '})
	cQuery +=    " AND NTH.NTH_CAMPO = 'NT0_VLRLIF'"
	cQuery +=    " AND NTH.NTH_VISIV = ?"
	Aadd(aParams, {"C", '1'})
	cQuery +=  " INNER JOIN " + RetSqlName("NXA") + " NXA"
	cQuery +=     " ON NXA.NXA_FILIAL = NXA.NXA_FILIAL"
	cQuery +=    " AND NXA.NXA_CESCR = NXB.NXB_CESCR"
	cQuery +=    " AND NXA.NXA_COD = NXB.NXB_CFATUR"
	cQuery +=    " AND NXA.NXA_TIPO = ?"
	Aadd(aParams, {"C", 'FT'})
	cQuery +=    " AND NXA.NXA_SITUAC IN (?)" // Somente faturas validas
	aAdd(aParams, {"IN", {'1','3'}})
	cQuery +=    " AND NXA.NXA_FATADC = ?"
	Aadd(aParams, {"C", '2'})
	cQuery +=    " AND NXA.D_E_L_E_T_ = ?"
	Aadd(aParams, {"C", ' '})
	cQuery +=  " INNER JOIN " + RetSqlName("NX8") + " NX8"
	cQuery +=     " ON NX8.NX8_FILIAL = NXA.NXA_FILIAL"
	cQuery +=    " AND NX8.NX8_CPREFT = NXA.NXA_CPREFT"
	cQuery +=    " AND NX8.NX8_CCONTR = NXB.NXB_CCONTR"
	cQuery +=    " AND NX8.D_E_L_E_T_ = ?"
	Aadd(aParams, {"C", ' '})
	cQuery +=  " WHERE NXB.NXB_FILIAL = ?"
   	Aadd(aParams, {"C", xFilial("NXB")})
	cQuery +=    " AND NXB.NXB_CMOELI = ?"
	Aadd(aParams, {"C", ' '})
	cQuery +=    " AND NXB.D_E_L_E_T_ = ?"
	Aadd(aParams, {"C", ' '})
	
	cQuery  := ChangeQuery(cQuery)
	oQuery  := FWPreparedStatement():New(cQuery)
	oQuery  := JQueryPSPr(oQuery, aParams)
	cQuery  := oQuery:GetFixQuery()
	cAlsTmp := GetNextAlias()
	MpSysOpenQuery(cQuery, cAlsTmp)

	While (cAlsTmp)->(!EOF())
		NXB->(DbGoTo((cAlsTmp)->RECNXB))

		If NXB->(!EOF())
			RecLock("NXB", .F.)
			NXB->NXB_CMOELI := (cAlsTmp)->NX8_CMOELI
			NXB->(MsUnLock())
		EndIf

		(cAlsTmp)->(DbSkip())
	EndDo

	(cAlsTmp)->(DbCloseArea())
	RestArea(aAreaNXB)

Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JPFS21183
Realiza o preenchimento dos campo NZQ_CPIDK7, NZY_CPIDK7, NV4_CPIDK7, OHB_CPIDK7 e OHB_FPIDK7 
com o valor do campo FK7_IDDOC.

Obs: Foi feito esta função, pois os campos NZQ_CPAGTO, NV4_CPAGTO, NVY_CPAGTO, OHB_CPAGTO e 
OHB_FATPAG estavam separados por pipes ("|")

@param cTabela, Nome da tabela a ser atualizada
@param cCpoTab, Campo da tabela que pode ser relacionado com o campo FK7_CHAVE.
@param cCpoFK7, Campo da tabela que vai receber o conteudo do campo FK7_IDDOC.

@author Victor Hayashi
@since  06/05/2026
/*/
//---------------------------------------------------------------------------------------------------
Static Function JPFS21183(cTabela, cCpoTab, cCpoFK7)
Local aArea     := {}
Local cQuery    := ""
Local cAlsTmp   := ""
Local aParams   := {}
Local oQuery    := Nil

	cQuery := " SELECT A.R_E_C_N_O_ TABREC, FK7.FK7_IDDOC"
	cQuery +=   " FROM " + RetSqlName(cTabela) + " A"
	cQuery +=  " INNER JOIN " + RetSqlName("FK7") + " FK7"
	cQuery +=     " ON FK7.FK7_CHAVE = A.?"
	Aadd(aParams, {"U", cCpoTab})
	cQuery +=    " AND FK7.D_E_L_E_T_ = ?"
	Aadd(aParams, {"C", Space(1)})
	cQuery +=  " WHERE A.? = ?"
	Aadd(aParams, {"U", cCpoFK7})
	Aadd(aParams, {"C", Space(1)})
	cQuery +=    " AND A.D_E_L_E_T_ = ?"
	Aadd(aParams, {"C", Space(1)})

	cQuery  := ChangeQuery(cQuery)
	oQuery  := FWPreparedStatement():New(cQuery)
	oQuery  := JQueryPSPr(oQuery, aParams)
	cQuery  := oQuery:GetFixQuery()
	cAlsTmp := MpSysOpenQuery(cQuery)

	While (cAlsTmp)->(!EOF())

		If cTabela == "NZQ" .And. cCpoFK7 == "NZQ_CPIDK7"
			aArea := NZQ->(GetArea())
			NZQ->(DbGoTo((cAlsTmp)->TABREC))
			If NZQ->(!EOF())
				RecLock("NZQ", .F.)
				NZQ->NZQ_CPIDK7 := (cAlsTmp)->FK7_IDDOC
				NZQ->(MsUnLock())
			EndIf
		ElseIf cTabela == "NV4" .And. cCpoFK7 == "NV4_CPIDK7"
			aArea := NV4->(GetArea())
			NV4->(DbGoTo((cAlsTmp)->TABREC))
			If NV4->(!EOF())
				RecLock("NV4", .F.)
				NV4->NV4_CPIDK7 := (cAlsTmp)->FK7_IDDOC
				NV4->(MsUnLock())
			EndIf
		ElseIf cTabela == "NVY" .And. cCpoFK7 == "NVY_CPIDK7"
			aArea := NVY->(GetArea())
			NVY->(DbGoTo((cAlsTmp)->TABREC))
			If NVY->(!EOF())
				RecLock("NVY", .F.)
				NVY->NVY_CPIDK7 := (cAlsTmp)->FK7_IDDOC
				NVY->(MsUnLock())
			EndIf
		ElseIf cTabela == "OHB" .And. cCpoFK7 == "OHB_CPIDK7"
			aArea := OHB->(GetArea())
			OHB->(DbGoTo((cAlsTmp)->TABREC))
			If OHB->(!EOF())
				RecLock("OHB", .F.)
				OHB->OHB_CPIDK7 := (cAlsTmp)->FK7_IDDOC
				OHB->(MsUnLock())
			EndIf
		ElseIf cTabela == "OHB" .And. cCpoFK7 == "OHB_FPIDK7"
			aArea := OHB->(GetArea())
			OHB->(DbGoTo((cAlsTmp)->TABREC))
			If OHB->(!EOF())
				RecLock("OHB", .F.)
				OHB->OHB_FPIDK7 := (cAlsTmp)->FK7_IDDOC
				OHB->(MsUnLock())
			EndIf
		EndIf

		(cAlsTmp)->(DbSkip())
	EndDo

	(cAlsTmp)->(DbCloseArea())
	RestArea(aArea)

Return Nil


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JPFS21179
Realiza o preenchimento dos campo OHB_CRIDK7 e OHI_CRIDK7 com o valor do campo FK7_IDDOC.

Obs: Foi feito esta função, pois os campos OHB_CRECEB e OHI_CHVTIT não estavam separados por pipes ("|")

@param cTabela, Nome da tabela a ser atualizada
@param cCpoTab, Campo da tabela que pode ser relacionado com o campo FK7_CHAVE.
@param cCpoFK7, Campo da tabela que vai receber o conteudo do campo FK7_IDDOC.

@author Victor Hayashi
@since  06/05/2026
/*/
//---------------------------------------------------------------------------------------------------
Static Function JPFS21179(cTabela, cCpoTab, cCpoFK7)
Local aArea     := {}
Local cQuery    := ""
Local cAlsTmp   := ""
Local aParams   := {}
Local oQuery    := Nil

	cQuery := " SELECT A.R_E_C_N_O_ TABREC, ? CHVTIT"
	Aadd(aParams, {"U", cCpoTab})
	cQuery +=   " FROM " + RetSqlName(cTabela) + " A"
	cQuery +=  " WHERE A.? = ?"
	Aadd(aParams, {"U", cCpoFK7})
	Aadd(aParams, {"C", Space(1)})
	cQuery +=    " AND A.D_E_L_E_T_ = ?"
	Aadd(aParams, {"C", Space(1)})

	cQuery  := ChangeQuery(cQuery)
	oQuery  := FWPreparedStatement():New(cQuery)
	oQuery  := JQueryPSPr(oQuery, aParams)
	cQuery  := oQuery:GetFixQuery()
	cAlsTmp := MpSysOpenQuery(cQuery)

	While (cAlsTmp)->(!EOF())
		If cTabela == "OHB" .And. cCpoFK7 == "OHB_CRIDK7"
			aArea := OHB->(GetArea())
			OHB->(DbGoTo((cAlsTmp)->TABREC))
			
			RecLock("OHB", .F.)
			OHB->OHB_CRIDK7 := FinBuscaFK7((cAlsTmp)->CHVTIT, "SE1")
			OHB->(MsUnLock())
		ElseIf cTabela == "OHI" .And. cCpoFK7 == "OHI_CRIDK7"
			aArea := OHI->(GetArea())
			OHI->(DbGoTo((cAlsTmp)->TABREC))

			RecLock("OHI", .F.)
			OHI->OHI_CRIDK7 := FinBuscaFK7((cAlsTmp)->CHVTIT, "SE1")
			OHI->(MsUnLock())
		EndIf

		(cAlsTmp)->(DbSkip())
	EndDo

	(cAlsTmp)->(DbCloseArea())
	RestArea(aArea)

Return Nil
