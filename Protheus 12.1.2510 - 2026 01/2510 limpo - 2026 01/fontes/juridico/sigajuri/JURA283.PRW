#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'JURA283.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} JURA283
Rotina responsavel pelas publicações do Totvs Jurídico

@since 01/10/2020
/*/
//------------------------------------------------------------------------------
Function JURA283()
Local oBrowse := FWMBrowse():New()

	oBrowse:SetDescription(STR0001) // Publicações - Totvs Jurídico
	oBrowse:SetMenuDef('JURA283')
	oBrowse:SetAlias('NR0')
	oBrowse:SetLocate()

	oBrowse:Activate()
	oBrowse:Destroy()
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function

@since 01/10/2020
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.JURA283' OPERATION OP_VISUALIZAR ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.JURA283' OPERATION OP_INCLUIR    ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.JURA283' OPERATION OP_ALTERAR    ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.JURA283' OPERATION OP_EXCLUIR    ACCESS 0 // Excluir

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author asd
@since 01/10/2020
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel  := Nil
Local oStrNR0 := FWFormStruct(1,'NR0')

	//Limpa o status da distribuição após 20 minutos da requisição
	ClearStatus()

	oModel := MPFormModel():New('JURA283', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	oModel:SetDescription(STR0001)
	oModel:AddFields('NR0MASTER', Nil /*cOwner*/, oStrNR0, /*bPre*/, /*bPos*/, /*bLoad*/)
	oModel:GetModel('NR0MASTER'):SetDescription(STR0001) //'Publicação - Totvs Jurídico'
	JurSetRules( oModel, 'NR0MASTER',, 'NR0' )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author asd
@since 01/10/2020
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView   := FWFormView():New()
Local oModel  := FwLoadModel('JURA283')
Local oStrNR0 := FWFormStruct(2, 'NR0')

	oView:SetModel(oModel)
	oView:AddField('VIEW_NR0' ,oStrNR0,'NR0MASTER')
	oView:SetDescription(STR0001) //'Publicação - Totvs Jurídico'

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} J283RepPub
Função responsável por reprocessar as publicação não localizadas

@since 01/10/2020
@param cDtIni, character, Data inicial para busca
@param cDtFim, character, Data final para busca

@return oResponse, JsonObject, Objeto com a resposta do processamento
/*/
//------------------------------------------------------------------------------
Function J283RepPub(cDtIni, cDtFim)
Local oGstRel    := JsonObject():New()
Local oResponse  := JsonObject():New()
Local oBody      := JsonObject():New()
Local aInfXml    := {}
Local cQuery     := ''
Local cTmpAlias  := GetNextAlias()
Local cChave     := ""
Local cFile      := ""
Local cUserTk    := JGetAuthTk()

Default cDtIni   := DtoS(Date()-60)
Default cDtFim   := DtoS(Date())

	If (J288InProc("Publicacao", .T.))
		oResponse['operation'] := "Error"
		oResponse['message']   := JurEncUTF8(STR0020) // Já existe um reprocessamento em andamento."
	Else
		// Monta a query
		cQuery += "SELECT  NR0.NR0_CAJURI"
		cQuery +=       " ,NR0.NR0_DTPUBL"
		cQuery +=       " ,NR0.NR0_NUMPRO"
		cQuery +=       " ," + RetCmpMemo("NR0.NR0_TEORPB") + " NR0_TEORPB"
		cQuery +=       " ,NR0.NR0_SITUAC"
		cQuery +=       " ,NR0.NR0_CODIMP"
		cQuery +=       " ,NR0.NR0_DTEXCL"
		cQuery +=       " ,NR0.NR0_USREXC"
		cQuery +=       " ,NR0.NR0_CODREL"
		cQuery +=       " ,NR0.NR0_NOME"
		cQuery +=       " ,NR0.NR0_PAGINA"
		cQuery +=       " ,NR0.NR0_JORNAL"
		cQuery +=       " ,NR0.NR0_OBS"
		cQuery +=       " ,NR0.NR0_ORGAO"
		cQuery +=       " ,NR0.NR0_CIDADE"
		cQuery +=       " ,NR0.NR0_VARA"
		cQuery +=       " ,NR0.NR0_CODSEQ"
		cQuery +=  " FROM " + RetSqlName("NR0") + " NR0"
		cQuery += " WHERE NR0.NR0_FILIAL = '" + xFilial("NR0") + "'"
		cQuery +=   " AND NR0.D_E_L_E_T_ = ' '"
		cQuery +=   " AND NR0.NR0_DTCHEG BETWEEN '" + cDtIni + "' AND '" + cDtFim + "'"
		cQuery +=   " AND NR0.NR0_SITUAC = '3'"
		cQuery += " ORDER BY NR0.NR0_NUMPRO"

		cQuery := ChangeQuery(cQuery)
		cQuery := StrTran(cQuery,",' '",",''")

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTmpAlias, .T., .T.)

		While (cTmpAlias)->(!Eof())
			Aadd(aInfXml, {;
				(cTmpAlias)->NR0_CAJURI,; //1
				" "                    ,; //2
				(cTmpAlias)->NR0_DTPUBL,; //3
				(cTmpAlias)->NR0_NUMPRO,; //4
				(cTmpAlias)->NR0_TEORPB,; //5
				(cTmpAlias)->NR0_SITUAC,; //6
				(cTmpAlias)->NR0_CODIMP,; //7
				(cTmpAlias)->NR0_DTEXCL,; //8
				(cTmpAlias)->NR0_USREXC,; //9
				(cTmpAlias)->NR0_CODREL,; //10
				(cTmpAlias)->NR0_NOME  ,; //11
				(cTmpAlias)->NR0_PAGINA,; //12
				(cTmpAlias)->NR0_JORNAL,; //13
				(cTmpAlias)->NR0_OBS   ,; //14
				(cTmpAlias)->NR0_ORGAO ,; //15
				(cTmpAlias)->NR0_CIDADE,; //16
				(cTmpAlias)->NR0_VARA  ,; //17
				(cTmpAlias)->NR0_CODSEQ;  //18
				})
			(cTmpAlias)->(DbSkip())
		End

		(cTmpAlias)->(DbCloseArea())

		If Len(aInfXml) > 0
			// Preenchimento padrão do oGstRel
			oGstRel := J288JsonRel()

			cChave := Encode64(oGstRel['O17_FILIAL'] + oGstRel['O17_CODIGO'])
			cFile  := "Publicacao:[" + cChave + "]"
			
			oGstRel["O17_FILE"]   := cFile
			oGstRel["O17_CHAVE"]  := cChave
			oGstRel["O17_DESC"]   := STR0014 // Reprocessamento de publicações
			oGstRel["O17_MAX"]    := Len(aInfXml)
			oGstRel["O17_URLREQ"] := "JURCONTENCIOSO/publicacao/reprocessa"
			oGstRel['O17_TIPO']   := '2' // Tipo de processamento

			// Preenche oBody com as informações necessárias para a O17_BODY
			oBody["cDtIni"] := cDtIni
			oBody["cDtFim"] := cDtFim
			oGstRel["O17_BODY"] := oBody:toJson()

			// Salva no O17
			J288GestRel(oGstRel)

			// Inicia o job em segundo plano
			STARTJOB("JWSReprJob", GetEnvServer(), .F., oBody, oGstRel, cEmpAnt, cFilAnt, cUserTk, aInfXml)

			// Retorna resposta para o endpoint
			oResponse['operation'] := "Notification"
			oResponse['message']   := JurEncUTF8(STR0015)  // O reprocessamento das publicações foi iniciado em segundo plano.
			oResponse['codigo']    := Encode64(oGstRel['O17_FILIAL'] + oGstRel['O17_CODIGO'])

		Else
			oResponse['operation'] := "Notification"
			oResponse['message']   := JurEncUTF8(STR0017) // Nenhuma publicação encontrada para o reprocessamento.
		EndIf
	EndIf
Return oResponse

//------------------------------------------------------------------------------
/*/{Protheus.doc} JWSReprJob
Função responsável por executar a função de reprocessamento das publicações
em segundo plano

@since 09/04/2025
@param oBody    - JsonObject, Objeto com os dados do processamento
@param oGstRel  - JsonObject, Objeto de gestão de relatórios
@param cEmpLog  - Character, Empresa logada
@param cFilLog  - Character, Filial logada
@param cUsuario - Character, Usuário logado
@param aInfXml  - Array, Array com as informações das publicações a serem reprocessadas

@return nRet, Integer, Retorno da execução
/*/
//------------------------------------------------------------------------------
Function JWSReprJob(oBody, oGstRel, cEmpLog, cFilLog, cUsuario, aInfXml)
Local nRet := 0

	RPCSetType(3)
	RPCSetEnv(cEmpLog, cFilLog, , , 'JWSReprJob')

	// Valida se o usuário informado é válido
	JHasUserTk(cUsuario)

	oBody['cIdThredExec'] := "JWSReprJob" + __CUSERID + StrZero(Randomize(1,9999),4)

	// Prepara oGstRel para controle do processamento
	oGstRel['O17_DESC'] := STR0018 // Reprocessando publicações.
	oGstRel['O17_BODY'] := oBody:toJson()
	J288GestRel(oGstRel)

	// Trava a execução por ID da thread
	If LockByName(oBody["cIdThredExec"], .T., .T.)
		
		// Executa processamento
		nRet := J20ProcXML(aInfXml, Nil, '3', '', Nil, Nil, .F., Nil, oGstRel)

		// Atualiza progresso final
		oGstRel['O17_PERC']   := 100
		oGstRel['O17_STATUS'] := "2"
		oGstRel['O17_DESC']   := STR0019 // Concluído! Atualize a página!
		J288GestRel(oGstRel)

		// Libera trava
		UnLockByName(oBody["cIdThredExec"], .T., .T.)
	EndIf

	// Finaliza ambiente
	RpcClearEnv()

Return nRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} RetCmpMemo
Função responsável por retornar no formato correto conforme o banco
@since 01/10/2020
@param cCampo, character, Campo a ser formatado pelo banco
@return cCampoQry - retorna o campo para realizar o cast no banco
/*/
//------------------------------------------------------------------------------
Static Function RetCmpMemo(cCampo)
Local cCampoQry := ""
Local cBanco    := Upper( TcGetDb() )
Local cQuant    := cValToChar(8000)   //Quantidade de caracteres que serão retornados no campo memo

	If cBanco $ "ORACLE"
		cCampoQry := "TO_CHAR(SUBSTR(" + cCampo + ", 1, " + cValToChar(4000) + "))"
	ElseIf cBanco $ "POSTGRES"
		cCampoQry := "SUBSTR(" + cCampo + ", 1, " + cQuant + ")::char(500) "
	ElseIf cBanco == "MSSQL" .Or. cBanco == "DB2"
		cCampoQry := "CAST(" + cCampo + " AS VARCHAR(" + cQuant + "))"
	EndIf
Return cCampoQry

//------------------------------------------------------------------------------
/*/{Protheus.doc} J283ImpPub
Função responsável por tmbar publicações localizadas

@param aPub     - Array, Array com as publicações a serem importadas
@param cAto     - Character, Ato processual a ser utilizado
@param cEmpLog  - Character, Empresa logada
@param cFilLog  - Character, Filial logada
@param cUsuario - Character, Usuário logado

@since 21/10/2020
@return cCampoQry - retorna o campo para realizar o cast no banco
/*/
//------------------------------------------------------------------------------
Function J283ImpPub(aPub, cAto, cEmpLog, cFilLog, cUsuario)
Local aArea     := GetArea()
Local cFilAmb   := '' 
Local cResult   := ''
Local cMsg      := ''
Local nSuccess  := 0
Local nError    := 0
Local nI        := 0
Local cIdImport := AllTrim(cUsuario) + FWTimeStamp(4)
Local lNR0_Erro := .F.

	// Inicializa o ambiente
	RPCSetType(3) // Prepara o ambiente e não consome licença
	RPCSetEnv(cEmpLog, cFilLog, , , 'J283ImpPub') // Abre o ambiente

	// Valida se o usuário informado é válido
	JHasUserTk(cUsuario)

	cFilAmb  := cFilAnt

	dbSelectArea('NR0')
	dbSetOrder(1) // NR0_FILIAL+NR0_CODIMP+NR0_CODSEQ
	lNR0_Erro := (NR0->(FieldPos('NR0_ERRO')) > 0)

	For nI := 1 to Len(aPub)

		If NR0->( dbSeek(Decode64( aPub[nI] )) )
			cFilAnt := NR0->NR0_FILPRO
			cResult := GravaAnd(NR0->NR0_CAJURI, cAto, NR0->NR0_DTPUBL, NR0->NR0_TEORPB, NR0_CODREL, NR0->NR0_FILPRO)

			NR0->(RecLock('NR0', .F.))

			If cResult == 'Ignored'
				NR0->NR0_SITUAC := '1'
				If lNR0_Erro
					NR0->NR0_ERRO := ''
				EndIf
			
			ElseIf cResult = 'success'
					NR0->NR0_SITUAC := '5'
					If lNR0_Erro
						NR0->NR0_ERRO := cIdImport
					EndIf
					nSuccess++

			Else
				cMsg := STR0006 + cIdImport + CRLF; // 'Código de importação: '
					+ STR0007 + cResult // 'Mensagem de erro: '
				NR0->NR0_SITUAC := '1'
				
				If lNR0_Erro
					NR0->NR0_ERRO := SubStr(cMsg,1,250)
				EndIf

				nError++
			EndIf

			NR0->( MsUnlock() )
		Endif
	Next nI

	NR0->( DbCloseArea() )

	If(nSuccess > 0)
		cMsg := (STR0008 + cValToChar(nSuccess) + STR0009) //"Foram importadas " //" publicações com sucesso."
		JA280Notify(cMsg, , , '2', "J283ImpPub", '/Publicacoes' + '?success=true&id='+cIdImport)
	EndIf

	If (nError > 0)
		cMsg := (STR0010 + cValToChar(nError) + STR0011) // ("Hove falha na importação de " // " publicações. Verifique!"
		JA280Notify(cMsg, , 'minus-circle', '2', "ImpDistr", '/Publicacoes' + '?success=false&id='+cIdImport )
	EndIf

	cFilAnt := cFilAmb
	RestArea(aArea)

Return .T.


//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaAnd(cCajuri, cAto, cDtAnd , cTeor, cCodRel, cFilial)
Cria o andamento 

@param cCajuri  - Código do processo
@param cAto     - Código do Ato processual
@param cDtAnd   - Data do andamento
@param cTeor    - Teor da publicação
@param cCodRel  - Código relacional da publicação
@param cFilial  - Filial do processo

@return aMsg[1] - Retorna mensagem de sucesso ou falha

@since 	 02/10/2020
/*/
//----------------------------------------------------------------------------------------------------
Static Function GravaAnd(cCajuri, cAto, cDtAnd , cTeor, cCodRel, cFilPro)
Local oModelJ100 := FWLoadModel("JURA100")
Local aMsg       := {'success'}
Local lCodRel    := .F.
Local aPalavraCh := J020Palavr()//Busca as palavras chaves cadastradas para encontrar o ato automático
Local cCodAtoAut := ""
Local cCodFase   := SuperGetMV('MV_JNT4FAS',, '')// Parametro para retornar o código da fase processual
Local cCodInstan := ""
Local cMostraClie:= SuperGetMV('MV_JNT4CLI',, '2')	//Paramentro exigido para preenchimento do campo "NT4_PCLIEN"
Local lCmpFilPro := NR0->( FieldPos("NR0_FILPRO") ) > 0

	// Verifica se o campo NT4_CODREL existe no dicionário
	If Select("NT4") > 0
		lCodRel := (NT4->(FieldPos('NT4_CODREL')) > 0)
	Else
		DBSelectArea("NT4")
			lCodRel := (NT4->(FieldPos('NT4_CODREL')) > 0)
		NT4->( DBCloseArea() )
	EndIf

	If Len(aPalavraCh) > 0
		cCodAtoAut := J20RetAto(cTeor, aPalavraCh)//Busca ato automático, se não tiver, é usado o ato informado em tela
		if !Empty(cCodAtoAut) 
			cAto := cCodAtoAut
		EndIf
	EndIf

	If Empty(cAto)
		aMsg[1] := 'Ignored'
	Else
		If Empty(cFilPro)
			cFilPro := xFilial("NT4")
		Endif
		
		Begin Transaction
			oModelJ100:SetOperation(MODEL_OPERATION_INSERT)
			oModelJ100:Activate()
			oModelJ100:SetValue("NT4MASTER", "NT4_FILIAL", cFilPro)
			oModelJ100:LoadValue("NT4MASTER", "NT4_CAJURI", cCajuri)
			oModelJ100:SetValue("NT4MASTER", "NT4_DTANDA", cDtAnd)
			oModelJ100:SetValue("NT4MASTER", "NT4_CATO",   cAto)
			oModelJ100:SetValue("NT4MASTER", "NT4_DESC",   cTeor)
			oModelJ100:SetValue("NT4MASTER", "NT4_PCLIEN", cMostraClie )
			If !Empty( cCodFase )
				oModelJ100:SetValue("NT4MASTER", "NT4_CFASE", cCodFase)
			Endif
			// Grava o código da publicação que originou o andamento
			If lCodRel
				oModelJ100:SetValue("NT4MASTER","NT4_CODREL",NR0->NR0_CODREL)
			EndIf

			cCodInstan := JACODINST(cCajuri, cFilPro)
			
			If JurGetDados('NRO',1,xFilial('NRO')+cAto, "NRO_TIPO") == "1" .And. SuperGetMV( 'MV_JINSTST',, '2' ) == '1' .And. Empty(cCodInstan)
				If !lCmpFilPro .OR. Empty(cFilPro)
					cCodInstan := JurGetDados('NUQ',2,xFilial('NUQ') + cCajuri+"1", "NUQ_COD")
				Else
					cCodInstan := JurGetDados('NUQ',2,cFilPro + cCajuri+"1", "NUQ_COD")
				EndIf
			Endif
			
			//Preenche o código de instância
			oModelJ100:SetValue("NT4MASTER", "NT4_CINSTA" , cCodInstan)

			If !( oModelJ100:VldData() .And. oModelJ100:CommitData() )
				aMsg := oModelJ100:GetModel():GetErrormessage()
				
				If Empty(aMsg[6])
					aMsg[6] := STR0012 + " - " + FWTimeStamp(2) //'<J283>Erro ao executar a Importação. Verifique o log do sistema'
				EndIF
				
				aMsg[1] := SubStr(aMsg[6] , 1, 190)
			EndIf

			oModelJ100:DeActivate()
			oModelJ100:Destroy()

			If (aMsg[1] != 'success')
				DisarmTransaction()
			EndIf
		End TransAction
	EndIf

Return aMsg[1]



//-------------------------------------------------------------------
/*/{Protheus.doc} ClearStatus()
Função que limpa o status "Processando" dos registros que ultrapassaram 
20 minutos de precessamento

@since 05/10/2020
/*/
//-------------------------------------------------------------------
Static Function ClearStatus()
Local aArea    := GetArea()
Local aAreaNR0 := NR0->( GetArea() )
Local cAlias   := ''
Local cQry     := ''
Local cTempo   := ''

	DbSelectArea("NR0")
	NR0->(DbSetOrder(1)) // NR0_FILIAL+NR0_CODIMP+NR0_CODSEQ
	If(NR0->(FieldPos('NR0_ERRO')) > 0)

		cQry := "SELECT NR0_FILIAL, NR0_CODIMP, NR0_CODSEQ, NR0_ERRO FROM "+ RetSqlName('NR0')
		cQry += " WHERE NR0_SITUAC = '7' AND D_E_L_E_T_ = ' ' AND NR0_FILIAL = '"+ xFilial('NR0') + "'"
		cQry += "ORDER BY NR0_FILIAL, NR0_CODIMP, NR0_CODSEQ"
		cQry :=ChangeQuery(cQry)

		cAlias := GetNextAlias()
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQry), cAlias, .F., .F. )

		If ( (cAlias)->(!Eof()) )

			While (cAlias)->(!Eof())

				cTempo := SubStr(AllTrim( (cAlias)->NR0_ERRO ), len(__CUSERID) + 1)

				If ( (Val(cTempo) + 1200) < Val( FWTimeStamp(4) ) )

					If NR0->( dbSeek((cAlias)->NR0_FILIAL + (cAlias)->NR0_CODIMP +(cAlias)->NR0_CODSEQ) )

						RecLock("NR0", .F.)
							NR0->NR0_SITUAC := "1"
							NR0->NR0_ERRO := AllTrim(NR0->NR0_ERRO) + '<J283>' + STR0012 + " - " + FWTimeStamp(2) //'<J283>Erro ao executar a Importação. Verifique o log do sistema'
						NR0->( MsUnLock() )
					EndIf
				EndIf

				(cAlias)->( dbSkip() )

			End
		EndIf

		(cAlias)->( DbCloseArea() )
	EndIf

	NR0->( DbCloseArea() )

	RestArea( aAreaNR0 )
	RestArea(aArea)

Return .T.


//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcessPub(aPub)
Atualiza o status das publicações para 7= importando
@Param aPub - Array com PKs das publicações

@version 1.0
/*/
//----------------------------------------------------------------------------------------------------
Function ProcessPub(aPub)
Local aArea     := GetArea() 
Local aAreaNR0  := NR0->( GetArea() )
Local nI        := 0
Local cIdImport := AllTrim(__CUSERID) + FWTimeStamp(4)

	dbSelectArea('NR0')
	dbSetOrder(1) // NR0_FILIAL + NR0_CODIMP + NR0_CODSEQ

	For nI := 1 to Len(aPub)
		If NR0->( dbSeek(Decode64( aPub[nI] )) )
			RecLock('NR0', .F.)
				NR0->NR0_SITUAC := '7'
				If(NR0->(FieldPos('NR0_ERRO')) > 0)
						NR0->NR0_ERRO := cIdImport
				EndIf
				
			NR0->( MsUnlock() )
		Endif
	Next nI
	
	NR0->( DbCloseArea() )

	RestArea(aAreaNR0)
	RestArea(aArea)

Return .T.
