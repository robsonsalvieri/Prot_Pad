#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

#INCLUDE "CRM060EventDEFDMS.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM060EventDEFDMS
Classe responsável pelo evento das regras de negócio da
localização Padrão DMS.

@type 		Classe
@author 	Squad DMS
@version	12.1.33 / Superior
@since		18/01/2022
/*/
//-------------------------------------------------------------------
Class CRM060EventDEFDMS From FwModelEvent

	Method New() CONSTRUCTOR
	Method GridLinePosVld()

	//----------------------------------------------------------------------
	// Bloco com regras de negócio dentro da transação do modelo de dados.
	//---------------------------------------------------------------------
	Method AfterTTS()

EndClass

Method New() Class CRM060EventDEFDMS
Return self

METHOD GridLinePosVld(oSubModel, cModelId, nLine) CLASS CRM060EventDEFDMS
	
	local nPos

	if cModelId == "AC8CONTDET"

		if GetNewPar("MV_MIL0185",.f.) == .f. // Verifica se o ambiente esta integrado com o Blackbird
			return .t.
		endif 

		//Conout("Linha - " + cvaltochar(osubmodel:GetLine()) + " - AC8_CODCON: " + osubmodel:getValue("AC8_CODCON") + " - AC8_PRIMAR: " + oSubModel:GetValue("AC8_PRIMAR") )

		if oSubModel:GetValue("AC8_PRIMAR") == "0"
			return .t.
		endif

		nBkpLine := oSubModel:GetLine()
		for nPos := 1 to oSubModel:Length()
			if nPos == nLine
				loop
			endif

			oSubModel:GoLine(nPos)
			if oSubModel:GetValue("AC8_PRIMAR", nPos) == "1"
				oSubModel:LoadValue("AC8_PRIMAR","0")
			endif
		next nPos
		oSubModel:GoLine(nLine)

		//oSubModel:SetLine(nLine)

	endif
RETURN .T.

METHOD AfterTTS(oModel, cModelId) CLASS CRM060EventDEFDMS

	local nAuxOper
	local aSplitName
	local oModelAC8

	Local cQAlias  := "SQLVK8"

	local cFilSA1 := ""
	local cCodSA1 := ""
	local cLojSA1 := ""

	local aCpoVK8 := {}

	local nLinhaFinan

	nAuxOper := oModel:GetOperation()
	oModelAC8 := oModel:GetModel("AC8MASTER")
	
	// Por enquanto so iremos tratar contatos relacionados a cliente ...
	If oModelAC8:GetValue("AC8_ENTIDA") <> "SA1"
		Return .t.
	EndIf

	if GetNewPar("MV_MIL0185",.f.) == .f. // Verifica se o ambiente esta integrado com o Blackbird
		return .t.
	endif 

	cFilSA1 := alltrim(oModelAC8:GetValue("AC8_FILENT"))
	cCodEnt := alltrim(oModelAC8:GetValue("AC8_CODENT"))
	cCodSA1 := left(cCodEnt, TamSX3("A1_COD")[1])
	cLojSA1 := right(cCodEnt, TamSX3("A1_LOJA")[1])

	oModelAC8 := oModel:GetModel("AC8CONTDET")

	cSQL := "SELECT VK7_CODIGO " + ;
		" FROM " + RetSQLName("VK7") + " VK7 " + ;
		" WHERE VK7.VK7_FILIAL = '" + xFilial("VK7") + "' " + ;
			" AND VK7.VK7_A1FIL = '" + xFilial("SA1") + "' " + ;
			" AND VK7.VK7_A1COD = '" + cCodSA1 + "' " + ;
			" AND VK7.VK7_A1LOJA = '" + cLojSA1 + "' " + ;
			" AND VK7.VK7_BBINTG = '1' " + ; // Registro integrado
			" AND VK7.VK7_BBDEL = '0' " + ; // Registro NAO EXCLUIDO
			" AND VK7.D_E_L_E_T_ = ' '"

	cCodVK7 := FM_SQL(cSQL)

	if empty(cCodVK7)
		return .t.
	endif

	For nLinhaFinan := 1 to oModelAC8:Length()

		oModelAC8:GoLine(nLinhaFinan)

		if oModelAC8:isDeleted() .or. empty(oModelAC8:GetValue("AC8_CODCON"))
			Loop
		endif

		SU5->(dbSetOrder(1))
		SU5->(msSeek( xFilial("SU5") + oModelAC8:GetValue("AC8_CODCON")))

		aCpoVK8 := {}

		aSplitName := SplitName(SU5->U5_CONTAT)
		aAdd( aCpoVK8 , { 'VK8_FSNAME' , aSplitName[1] , NIL } )
		aAdd( aCpoVK8 , { 'VK8_LSNAME' , aSplitName[2] , NIL } )

		aAdd( aCpoVK8 , { 'VK8_EMAIL' , SU5->U5_EMAIL , NIL } )

		// Adicionando telefones 
		addPhone(@aCpoVK8, "VK8_PPHONE", SU5->U5_CODCONT, "1")
		addPhone(@aCpoVK8, "VK8_HPHONE", SU5->U5_CODCONT, "2")
		addPhone(@aCpoVK8, "VK8_MPHONE", SU5->U5_CODCONT, "5")
		addPhone(@aCpoVK8, "VK8_FAXNUM", SU5->U5_CODCONT, "3")

		// Grava o Relacionamento o Cliente relacionado ao contato para conseguir verificar se mais pra frente o contato foi removido do cliente ...
		aAdd( aCpoVK8 , { 'VK8_A1FIL' , cFilSA1 , NIL } )
		aAdd( aCpoVK8 , { 'VK8_A1COD' , cCodSA1 , NIL } )
		aAdd( aCpoVK8 , { 'VK8_A1LOJA' , cLojSA1 , NIL } )

		aAdd( aCpoVK8 , { 'VK8_PRICUS' , oModelAC8:GetValue("AC8_PRIMAR") , NIL } )

		aAdd( aCpoVK8 , { 'VK8_CODVK7' , cCodVK7 , NIL } )

		// Utiliza os enderecos informados na SU5 pois quando o contato é atualizado pela rotina de contatos (TMKA070),
		// a propria rotina atualiza os campos de endereco da SU5 de acordo com o endereco marcado como padrão...
		if ! empty(SU5->U5_CODAGA)
			AGA->(dbSetOrder(2))
			AGA->(dbSeek(xFilial("AGA") + SU5->U5_CODAGA))

			aAdd( aCpoVK8, { 'VK8_PA_AGA' , alltrim(SU5->U5_CODAGA)  , NIL } )
			aAdd( aCpoVK8, { 'VK8_PAEND1' , alltrim(AGA->AGA_END)    , NIL } )
			aAdd( aCpoVK8, { 'VK8_PAEND2' , alltrim(AGA->AGA_BAIRRO) , NIL } )
			aAdd( aCpoVK8, { 'VK8_PAEND3' , alltrim(AGA->AGA_COMP)   , NIL } )
			aAdd( aCpoVK8, { 'VK8_PACIDA' , alltrim(AGA->AGA_MUNDES) , NIL } )
			aAdd( aCpoVK8, { 'VK8_PAESTA' , alltrim(AGA->AGA_EST)    , NIL } )

			if ! empty( AGA->AGA_END )
				aAdd( aCpoVK8, { 'VK8_PAPAIS' , "BRA" , NIL } )
			endif

			aAdd( aCpoVK8, { 'VK8_PACEP'  , alltrim(AGA->AGA_CEP)    , NIL } )

			// Como nao existe endereco de correspondencia no cadastro de Contato
			// deve utilizar o endereco fisico como endereco de correspondencia 
			aAdd( aCpoVK8, { 'VK8_MAEND1' , alltrim(AGA->AGA_END)    , NIL } )
			aAdd( aCpoVK8, { 'VK8_MAEND2' , alltrim(AGA->AGA_BAIRRO) , NIL } )
			aAdd( aCpoVK8, { 'VK8_MAEND3' , alltrim(AGA->AGA_COMP)   , NIL } )
			aAdd( aCpoVK8, { 'VK8_MACIDA' , alltrim(AGA->AGA_MUNDES) , NIL } )
			aAdd( aCpoVK8, { 'VK8_MAESTA' , alltrim(AGA->AGA_EST)    , NIL } )

			if ! empty( AGA->AGA_END )
				aAdd( aCpoVK8, { 'VK8_MAPAIS' , "BRA" , NIL } )
			endif

			aAdd( aCpoVK8, { 'VK8_MACEP'  , alltrim(AGA->AGA_CEP)    , NIL } )
			//

		endif

		aAdd( aCpoVK8, { 'VK8_U5FIL'  , SU5->U5_FILIAL , NIL } )
		aAdd( aCpoVK8, { 'VK8_U5COD'  , SU5->U5_CODCONT , NIL } )
		aAdd( aCpoVK8, { 'VK8_U5SYNC' , "1" , NIL } )
		aAdd( aCpoVK8, { 'VK8_AC8DEL' , "0" , NIL } )

		nAuxRecVK8 := FindVK8(cCodSA1, cLojSA1, SU5->U5_FILIAL, SU5->U5_CODCONT)
		dbSelectArea("VK8")
		if nAuxRecVK8 <> 0
			nAuxOper := MODEL_OPERATION_UPDATE
			VK8->(DbGoTo(nAuxRecVK8))

			if isEqual(aCpoVK8)
				conout(STR0010 + oModelAC8:GetValue("AC8_CODCON"))	// "Contato nao precisa de alteracao: "
				loop
			endif
		Else
			nAuxOper := MODEL_OPERATION_INSERT
		endif

		aAdd( aCpoVK8, { 'VK8_BBSYNC' , "0" , NIL } ) // Marca registro como 0=Não

		GravaVK8(aCpoVK8, nAuxOper)
		
	Next nLinhaFinan

	// Ao final do processamentos das linhas da Model
	// é necessário verificar se existe registro na VK8 sem referencia na AC8
	// neste caso os registros deverão ser marcados como excluidos na VK8 para 
	// transmissão ao BlackBird
	cSQL := ;
			"SELECT VK8.R_E_C_N_O_ RECVK8" +;
				" FROM " + RetSQLName("VK7") + " VK7" +;
				" JOIN " + RetSQLName("VK8") + " VK8 " +;
				 "  ON VK8.VK8_FILIAL = '" + xFilial("VK8") + "' " +;
				 " AND VK8.VK8_CODVK7 = VK7.VK7_CODIGO " +;
				 " AND VK8.D_E_L_E_T_ = ' '" +;
			"WHERE VK7.VK7_FILIAL = '" + xFilial("VK7") + "'" +;
				" AND VK7.VK7_A1FIL = ' '" +;
				" AND VK7.VK7_A1COD = '" + cCodSA1 + "'" +;
				" AND VK7.VK7_A1LOJA = '" + cLojSA1 + "'" +;
				" AND VK7.D_E_L_E_T_ = ' '" +;
				" AND VK8.VK8_AC8DEL = '0'" +;
				" AND NOT EXISTS ( " +;
						" SELECT * " +;
						" FROM " + RetSQLName("AC8") + " AC8" +;
					" WHERE AC8.AC8_FILIAL = '" + xFilial("AC8") + "'" +;
						" AND AC8.AC8_ENTIDA = 'SA1'" +;
						" AND AC8.AC8_CODENT = '" + cCodEnt + "'" +;
						" AND AC8.D_E_L_E_T_ = ' '" +;
						" AND AC8.AC8_FILIAL = VK8.VK8_U5FIL " +;
						" AND AC8.AC8_CODCON = VK8.VK8_U5COD " +;
					") "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )

		dbSelectArea("VK8")

		nAuxOper := MODEL_OPERATION_UPDATE
		VK8->(DbGoTo( (cQAlias)->RECVK8 ))

		aCpoVK8 := {}
		aAdd( aCpoVK8, { 'VK8_AC8DEL' , "1" , NIL } )

		GravaVK8(aCpoVK8, nAuxOper)

		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )

RETURN .T.


Static Function GravaVK8(aCpoVK8, nAuxOper)

	local oModel
	local oAux
	local oStruct
	local aAux
	local nI

	local cModelVK8 := 'MODEL_VK8'
	
	local lRet

	oModel := FWLoadModel( 'OFIA401' )
	oModel:SetOperation( nAuxOper )

	lRet := oModel:Activate()

	If lRet
		oAux := oModel:GetModel( cModelVK8 )
		oStruct := oAux:GetStruct()
		aAux := oStruct:GetFields()

		For nI := 1 To Len( aCpoVK8 )
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoVK8[nI][1] ) } ) ) > 0
				If !( lAux := oModel:SetValue( cModelVK8, aCpoVK8[nI][1], aCpoVK8[nI][2] ) )
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf

	If lRet
		If ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()
		EndIf
	EndIf

	If !lRet

		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro   := oModel:GetErrorMessage()

		AutoGrLog(STR0001 + ' [' + AllToChar(aErro[1]) + ']' ) // "Id do formulário de origem: "
		AutoGrLog(STR0002 + ' [' + AllToChar(aErro[2]) + ']' ) // "Id do campo de origem: "
		AutoGrLog(STR0003 + ' [' + AllToChar(aErro[3]) + ']' ) // "Id do formulário de erro: "
		AutoGrLog(STR0004 + ' [' + AllToChar(aErro[4]) + ']' ) // "Id do campo de erro: "
		AutoGrLog(STR0005 + ' [' + AllToChar(aErro[5]) + ']' ) // "Id do erro: "
		AutoGrLog(STR0006 + ' [' + AllToChar(aErro[6]) + ']' ) // "Mensagem do erro: "
		AutoGrLog(STR0007 + ' [' + AllToChar(aErro[7]) + ']' ) // "Mensagem da solução: "
		AutoGrLog(STR0008 + ' [' + AllToChar(aErro[8]) + ']' ) // "Valor atribuido: "
		AutoGrLog(STR0009 + ' [' + AllToChar(aErro[9]) + ']' ) // "Valor anterior: "

		MostraErro()

	EndIf

	oModel:DeActivate()

Return lRet


/*/{Protheus.doc} SplitName
Quebra o nome para gravacao correta do Customer

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
Static Function SplitName(cFullName)

	local cFirstName := ""
	local cLastName := cFullName
	local nPos

	cFullName := allTrim(cFullName)
	cLastName := cFullName

	// Retira o Sobrenome
	nPos := AT(" ",cFullName)
	If nPos <> 0
		cLastName := Right(cFullName,Len(cFullName) - nPos)
		cFirstName := AllTrim(Left(cFullName,nPos))
	EndIf

Return {cFirstName, cLastName}

/*/{Protheus.doc} addPhones
Adiciona dados de telefone na array de integração

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
Static Function addPhone(aCpoVK8, cCampo, cCodCont, cTpPhone)
	AGB->(dbSetOrder(1)) // AGB_FILIAL+AGB_ENTIDA+AGB_CODENT+AGB_TIPO+AGB_PADRAO
	if AGB->(dbSeek(xFilial("AGB") + "SU5" + PadR( cCodCont ,tamsx3("AGB_CODENT")[1]) + cTpPhone + "1" ))
		aAdd( aCpoVK8 , { cCampo , AGB->AGB_DDD + AGB->AGB_TELEFO , NIL } )
	else
		aAdd( aCpoVK8 , { cCampo , " " , NIL } )
	endif
return

/*/{Protheus.doc} isEqual
Verifica se existe algum diferenca dos campos para executar ExecAuto

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
static Function isEqual(aFields)

	local nLinFields
	local cAliasTab := "VK8"

	for nLinFields := 1 to len(aFields)

		if allTrim(aFields[nLinFields,2]) == allTrim(&(cAliasTab + '->' + aFields[nLinFields,1] ))
		else
			return .f.
		endif

	next nLinFields

return .t.

/*/{Protheus.doc} FindVK8
Procura um registro de Contact relacionado ao cliente/contato

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
Static Function FindVK8(cCodSA1, cLojSA1, cU5Filial, cU5CodCon )

	local nAuxRecVK8
	local cSQL

	// Procura Contato contato relacionado com SA1
	cSQL := ;
		"SELECT VK8.R_E_C_N_O_ " +;
			" FROM " + RetSQLName("VK7") + " VK7" +;
			" JOIN " + RetSQLName("VK8") + " VK8 " +;
			" ON VK8.VK8_FILIAL = '" + xFilial("VK8") + "' " +;
			"AND VK8.VK8_CODVK7 = VK7.VK7_CODIGO " +;
			"AND VK8.D_E_L_E_T_ = ' '" +;
		"WHERE VK7.VK7_FILIAL = '" + xFilial("VK7") + "'" +;
			" AND VK7.VK7_A1FIL = '" + xFilial("SA1") + "'" +;
			" AND VK7.VK7_A1COD = '" + cCodSA1 + "'" +;
			" AND VK7.VK7_A1LOJA = '" + cLojSA1 + "'" +;
			" AND VK7.D_E_L_E_T_ = ' '" +;
			" AND VK8.VK8_U5FIL = '" + SU5->U5_FILIAL + "'" +;
			" AND VK8.VK8_U5COD = '" + SU5->U5_CODCONT + "'" 

	nAuxRecVK8 := FM_SQL(cSQL)
	if nAuxRecVK8 <> 0
		//conout("-------------------------------------------------------------------")
		//conout("Atualizando contato ja encontrado - recno " + cvaltochar(nAuxRecVK8))
		//conout("-------------------------------------------------------------------")
		return nAuxRecVK8
	endif

	// Procura um contato DELETADO qualquer do mesmo contato 
	cSQL := ;
		"SELECT VK8.R_E_C_N_O_ " +;
			" FROM " + RetSQLName("VK8") + " VK8 " +;
		"WHERE VK8.VK8_FILIAL = '" + xFilial("VK8") + "'" +;
			" AND VK8.VK8_U5FIL = '" + SU5->U5_FILIAL + "'" +;
			" AND VK8.VK8_U5COD = '" + SU5->U5_CODCONT + "'" +;
			" AND VK8.VK8_AC8DEL = '1'" +;
			" AND VK8.D_E_L_E_T_ = ' '"

	nAuxRecVK8 := FM_SQL(cSQL)

	//Conout("----------------------------------------------------------------------------")
	//conout("Atualizando contato DELETADO ja encontrado - recno " + cvaltochar(nAuxRecVK8))
	//Conout("----------------------------------------------------------------------------")


Return nAuxRecVK8
