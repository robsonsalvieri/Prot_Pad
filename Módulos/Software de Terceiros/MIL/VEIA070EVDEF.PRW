#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "VEIA070.CH"

#DEFINE _ID_SYNC_BB_ "VV1_PROATU/VV1_LJPATU/VV1_CODFRO/VV1_CAMBIO/VV1_FABMOD/VV1_NUMMOT/VV1_SERMOT/VV1_BBEQTY/VV1_BBSTTY/VV1_BBINST/VV1_BBSTST/VV1_LOCRID/VV1_SOLCID/VV1_OBSVEI/VV1_NUMCMO/VV1_BBYARD/VV1_DATPED/VV1_DATETG/VV1_PEDFAB/VV1_MODVEI/VV1_DTDPCP/VV1_DTEFAB/VV1_DTUVEN/VV1_OBSERV/VV1_VEND  /VV1_FILULV/VV1_CLIULV/VV1_CLJULV/VV1_OBSERV/VV1_ULTKIL/VV1_ULTTRI/"
#DEFINE _ID_GERAR_LOG_ "VV1_CHASSI/VV1_CHAINT/VV1_ULTMOV/VV1_ESTVEI/VV1_SITVEI/VV1_FILPRO/VV1_PROATU/VV1_LJPATU/VV1_FILENT/VV1_TRACPA/VV1_FILSAI/VV1_NUMTRA/VV1_LOCRID/VV1_SOLCID/VV1_BBEQTY/VV1_BBSTTY/VV1_BBINST/VV1_BBSTST/VV1_BBYARD/"

CLASS VEIA070EVDEF FROM  FWModelEvent
	Data cIDVV1
	Data cMVGRUVEI
	Data cPrefB1COD
	Data cMVMIL0003
	DATA cMVMIL0010
	Data lB1CHASSI
	Data lVV1CONTA
	Data lVV1CEST
	Data lVV1MSBLQL
	Data lVV1GRPTI
	Data lVV1GRTIDC
	DATA lVV1CONGAN
	Data lVV1_PLAANT
	DATA lVV1TESSAI
	Data oVeiculos
	DATA oPeca
	Data lEnviar // Controla se o registro ja foi enviado para nao entrar em LOOP
	Data lGerarLog
	Data lConfirm
	Data cRotOrigem
	Data cAuxFil_UltMov
	Data cAuxMov_UltMov
	Data aCfgsPacote
	Data lIntegDynamics

	METHOD New() CONSTRUCTOR
	METHOD BeforeTTS()
	METHOD InTTS()
	METHOD VldActivate()
	METHOD FieldPreVld()
	METHOD AfterTTS()
	METHOD DeActivate()
	METHOD Activate()

	METHOD _SyncBlackbird()
	METHOD _GeraLogVW0()
	METHOD _Ajusta_SC1_SC7()

ENDCLASS


METHOD New(cIDVV1) CLASS VEIA070EVDEF

	Default cIDVV1 := "MODEL_VV1"

	::cMVGRUVEI  := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(VV1->VV1_CHAINT), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1]))
	::cPrefB1COD := ::cMVGRUVEI + "_"
	::lB1CHASSI  := SB1->(FieldPos("B1_CHASSI")) > 0
	::lVV1CONTA  := VV1->(FieldPos("VV1_CONTA")) > 0
	::lVV1CEST   := (VV1->(FieldPos("VV1_CEST")) > 0 .and. SB1->(FieldPos("B1_CEST")) > 0)
	::lVV1MSBLQL := (VV1->(FieldPos("VV1_MSBLQL")) > 0 .and. SB1->(FieldPos("B1_MSBLQL")) > 0)
	::lVV1GRPTI  := (VV1->(FieldPos("VV1_GRPTI")) > 0 .and. SB1->(FieldPos("B1_GRPTI")) > 0)
	::lVV1CONGAN := (VV1->(FieldPos("VV1_CONGAN")) > 0 .and. SB1->(FieldPos("B1_CONCGAN")) > 0)
	::lVV1_PLAANT := VV1->(FieldPos("VV1_PLAANT")) > 0
	::lVV1TESSAI := (VV1->(FieldPos("VV1_TESSAI")) > 0 .and. SB1->(FieldPos("B1_TS")) > 0)
	// Cria registro no SB1 quando for cadastrado um veículo na rotina Veículos Mod. 2 (VEIXA010)? (0=Não / 1=Sim) - CARACTERE
	::cMVMIL0003 := GetNewPar("MV_MIL0003","1")

	// O Módulo de Veículos trabalhará com Veículos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
	::cMVMIL0010 := GetNewPar("MV_MIL0010","0") 
	::cIDVV1     := cIDVV1
	::oVeiculos := DMS_Veiculo():New()
	::aCfgsPacote := {}

	self:lEnviar := .f.
	self:lGerarLog := .f.
	self:lConfirm := .f.
	self:cRotOrigem := ""
	//nAuxTabSize := 0
	//GetGlbVars("v070ColSize", nAuxTabSize)
	//PutGlbVars("v070ColSize", nAuxTabSize + 3)

	//cAlinha := ""
	
	::oPeca     := DMS_Peca():New()

	::lIntegDynamics := GetNewPar("MV_MIL0185",.f.) // Verifica se o ambiente esta integrado com o Blackbird

Return

METHOD AfterTTS(oModel, cModelId) CLASS VEIA070EVDEF
local nOpc      := oModel:GetOperation()
local oModelRep := oModel:getModel("REPLICAR")
local nI
local cChassi
local cPlaca
local cRenavam
//local cAlinha := ""

	//Conout(cAlinha + "      _ ___       _  __  _               _           ___ ___ __ ")
	//Conout(cAlinha + "\  / |_  |   /\  / \  / / \   __    /\ _|_ _|_  _  ._ |   | (_  ")
	//Conout(cAlinha + " \/  |_ _|_ /--\ \_/ /  \_/        /--\ |   |_ (/_ |  |   | __) ")
	//Conout(cAlinha + "                                                                ")
	
	If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE
	
		If ! IsInCallStack("VEIA270") .and. ! isInCallStack("VEIA140")
			VA070013B_GravaFrota(oModel, nOpc) // Grava VC3
		EndIf

		if ValType(oModelRep) == "O"
			for nI := 1 to oModelRep:length()		// Replicar Chassi
				oModelRep:goLine(nI)
				cChassi := oModelRep:getValue("CHASSI")

				if ! oModelRep:isDeleted() .and. ! empty( cChassi )

					if VA070027H_ValidaX3Nivel("VV1_PLAVEI")
						cPlaca := oModelRep:getValue("PLAVEI")
					Endif

					if VA070027H_ValidaX3Nivel("VV1_RENAVA")
						cRenavam := oModelRep:getValue("RENAVA")
					Endif

					If !FWIsInCallStack("VXA001CAD") // Evitar loop infinito e cadastro em duplicidade
						lInclui := VA070024C_InclusaoReplica( cChassi, cPlaca, cRenavam )
					Endif
				endif
			next
		Endif
	EndIf

	self:lEnviar := .t.
	self:lConfirm := .t.

	self:cAuxFil_UltMov := oModel:GetModel("MODEL_VV1"):GetValue("VV1_AUXFIL")
	self:cAuxMov_UltMov := oModel:GetModel("MODEL_VV1"):GetValue("VV1_AUXMOV")
Return .T.


METHOD BeforeTTS(oModel, cModelId) CLASS VEIA070EVDEF
	Local oMVV1
	Local cTmpObs
	Local cPlaAnt
	Local cPlavei
	//Local oSoConfig

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oMVV1 := oModel:GetModel("MODEL_VV1")
		cTmpObs := oMVV1:GetValue("VV1_OBSERV")
		// Dados informados e Log de Inclusão
		cTmpObs := Alltrim(cTmpObs) + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
			"*** " + left(Alltrim(UsrRetName(__CUSERID)), 15) + " " + Transform(dDataBase,"@D") + "-" + Transform(time(),"@R 99:99") + "h" + " ***" + Chr(13) + Chr(10) +; // hs
			Repl("_", TamSx3("VV1_OBSERV")[1] - 4) + Chr(13) + Chr(10)

		oMVV1:LoadValue("VV1_OBSERV", cTmpObs)

		
			self:cRotOrigem := alltrim(oMVV1:GetValue("VV1_ROTINA"))
		
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If ::lVV1_PLAANT
			cPlaVei := oMVV1:GetValue("VV1_PLAVEI")
			cPlaAnt := FM_SQL("SELECT VV1_PLAVEI FROM " + RetSQLName("VV1") + " WHERE R_E_C_N_O_ = " + cValToChar(oMVV1:GetDataId()) )
			If cPlaAnt <> cPlaVei .and. Empty(oMVV1:GetValue("VV1_PLAANT")) .and. ( Subs(cPlaAnt,5,1) >= "0" .and. Subs(cPlaAnt,5,1) <= "9" ) .and. ( Subs(cPlaVei,5,1) <= "0" .or. Subs(cPlaVei,5,1) >= "9" )
				oMVV1:LoadValue("VV1_PLAANT", cPlaAnt)
				If ExistFunc("VXA0100012_AtualizaPlacaMercosul")
					VXA0100012_AtualizaPlacaMercosul(cPlaVei, cPlaAnt)
				EndIf
			EndIf
		EndIf
	EndIf
Return


METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS VEIA070EVDEF
	//local cAlinha := ""
	
	if cModelID == "MODEL_VV1" .and. cAction == "SETVALUE"
		if self:lIntegDynamics .and. cId $ _ID_SYNC_BB_
//			conout(cAlinha + " VEIA070 - Ajustando campo para sincronia - " + cID + " -> " + cValToChar(xValue))
			oSubModel:loadValue("VV1_BBSYNC","0")
			if oSubModel:getValue("VV1_BBDEL") == "1"
				oSubModel:loadValue("VV1_BBDEL","0")
			EndIf
		EndIf

		if ! self:lGerarLog .and. cId $ _ID_GERAR_LOG_
			self:lGerarLog := .t.
//			conout(cAlinha + " VEIA070 - Ajuste para gerar LOG de Alteracao - " + cID + " -> " + cValToChar(xValue))
		EndIf
	EndIf
Return .T.

METHOD InTTS(oModel, cModelId) CLASS VEIA070EVDEF
	Local cCodSB1
	Local aVetSB1
	Local lRet := .T.
	Local nOpcA := 3
	Local nOperModel := oModel:GetOperation()


	// Cria registro no SB1 quando for cadastrado um veículo na rotina Veículos Mod. 2 (VEIXA010)? (0=Não / 1=Sim) - CARACTERE
	// NAO VAMOS CRIAR / ATUALIZAR SB1 QUANDO A CHAMADA VIER DA ROTINA DE INITIAL Data LOAD (OFIA264)
	If ( nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE ) .and. ::cMVMIL0003 == "1" .and. ! IsInCallStack("OFIA264")

		// Sitvei diferente de "8" - Pedido
		// Ou 
		// O veiculo esta em pedido e chamada do VEIA070 for diferentes das rotinas de pedido de compra. 
		// Checagem necessaria para nao criar registro na tabela de produto enquanto o VEICULO esta sendo alterado pelas rotinas de pedido de compra.
		If VV1->VV1_SITVEI <> "8" .or. (VV1->VV1_SITVEI == "8" .and. ! IsInCallStack("VEIA140") .and. ! IsInCallStack("VEIA162") .and. ! IsInCallStack("VEIXX002")) .or. (cPaisLoc == "ARG" .and. VV1->VV1_SITVEI == "8" .and. VV1->VV1_INDCAL == "2")
			INCLUI := ( nOperModel == MODEL_OPERATION_INSERT )
			ALTERA := ( nOperModel == MODEL_OPERATION_UPDATE )

			cCodSB1   := ::cPrefB1COD + VV1->VV1_CHAINT
			aVetSB1   := {}
			lRet := .T.
			nOpcA := 3

			DBSelectArea("SB1")
			DBSetOrder(1)
			if dbSeek(xFilial("SB1")+cCodSB1)
				nOpcA := 4
			EndIf

			If nOpcA <> 3 // Alteração
				aAdd(aVetSB1,{"B1_DESC"    ,VV1->VV1_CHASSI })
				aAdd(aVetSB1,{"B1_LOCPAD"  ,VV1->VV1_LOCPAD })
				aAdd(aVetSB1,{"B1_PRV1"    ,VV1->VV1_SUGVDA })
				aAdd(aVetSB1,{"B1_ORIGEM"  ,VV1->VV1_PROVEI })
				aAdd(aVetSB1,{"B1_POSIPI"  ,VV1->VV1_POSIPI })
				aAdd(aVetSB1,{"B1_GRTRIB"  ,VV1->VV1_GRTRIB })
				If ::lB1CHASSI
					aAdd(aVetSB1,{"B1_CHASSI"  ,VV1->VV1_CHASSI })
				EndIf
				If ::lVV1CONTA
					aAdd(aVetSB1,{"B1_CONTA"   ,VV1->VV1_CONTA  })
					aAdd(aVetSB1,{"B1_CC"      ,VV1->VV1_CC     })
					aAdd(aVetSB1,{"B1_ITEMCC"  ,VV1->VV1_ITEMCC })
					aAdd(aVetSB1,{"B1_CLVL"    ,VV1->VV1_CLVL   })
				EndIf
				If ::lVV1CEST
					aAdd(aVetSB1,{"B1_CEST"    ,VV1->VV1_CEST   })
				EndIf

				// Bloqueio/Desbloqueio de Chassi
				If ::lVV1MSBLQL
					aAdd(aVetSB1,{"B1_MSBLQL"  ,VV1->VV1_MSBLQL })
				EndIf

				// Grupo TI
				If ::lVV1GRPTI
					aAdd(aVetSB1,{"B1_GRPTI"   ,VV1->VV1_GRPTI })
				EndIf

					// Argentina (Concepto de retencion de ganancias)
					If ::lVV1CONGAN
						aAdd(aVetSB1,{"B1_CONCGAN" ,VV1->VV1_CONGAN })
					EndIf

				// TES Padrão Saída
				If ::lVV1TESSAI
					aAdd(aVetSB1,{"B1_TS"   ,VV1->VV1_TESSAI })
				EndIf
			EndIf

			lRet := ::oVeiculos:CriaPeca(VV1->VV1_CHAINT,nOpcA,aVetSB1,"VA010AB1", cCodSB1) // Inclui/Altera SB1 do Veiculo
			If !lRet
				AutoGrLog(RetTitle("VV1_CHAINT")+" :"+VV1->VV1_CHAINT)
				if ! IsBlind()
					MostraErro()
				endif
			EndIf

			self:_Ajusta_SC1_SC7( cCodSB1 , VV1->VV1_CHASSI ) // Necessário ajustar o CHASSI na Descrição do SC1 e SC7

		EndIf

	ElseIf nOperModel == MODEL_OPERATION_DELETE

		lRet := .T.
		If ::cMVMIL0003  == "1"// Cria registro no SB1 quando for cadastrado um veículo na rotina Veículos Mod. 2 (VEIXA010)? (0=Não / 1=Sim) - CARACTERE
			If ::cMVMIL0010 == "0" // O Módulo de Veículos trabalhará com Veículos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
				cCodSB1 := ::cPrefB1COD + VV1->VV1_CHAINT
				lRet := ::oPeca:ExcluiPeca(cCodSB1) // Excluir SB1 correspondente ao VV1
			EndIf
		EndIf

	EndIf
Return lRet

METHOD VldActivate(oModel, cModelId) CLASS VEIA070EVDEF
	Local nOperation := oModel:GetOperation()
	Local nRegs := 0

	If nOperation == 5
		nRegs:= FM_SQL(" SELECT COALESCE(count(*),0) as COUNT FROM "+RetSQLName('VQ0')+" WHERE VQ0_CHAINT = '"+VV1->VV1_CHAINT+"' AND D_E_L_E_T_ = ' ' ")
		If nRegs > 0
			FMX_HELP("VEIA070EVDEFERR01",STR0004,STR0005)//("O Chassi selecionado ja possui um pedido. Impossivel continuar. / Atencao")
			Return .f.
		endIf
	EndIf
Return .T.

METHOD Activate(oModel, lCopy) CLASS VEIA070EVDEF
local   cAux   := ""
private INCLUI := lCopy

	if lCopy
		cAux := &( getSx3Cache( "VV1_CHAINT", "X3_RELACAO" ) )
		oModel:LoadValue( "MODEL_VV1", "VV1_CHAINT" , cAux )
		oModel:LoadValue( "MODEL_VV1", "VV1_OBSERV" , ""   )
		oModel:LoadValue( "MODEL_VV1", "VV1_CODMAR" , VV1->VV1_CODMAR )		
	endif
RETURN .T.

METHOD DeActivate(oModel) CLASS VEIA070EVDEF
//	local cAlinha := ""

	local lCancSync := .f.

	//conout(cAlinha + "      _ ___       _  __  _          _                                   ")
	//conout(cAlinha + "\  / |_  |   /\  / \  / / \   __   | \  _   /\   _ _|_ o     _. _|_  _  ")
	//conout(cAlinha + " \/  |_ _|_ /--\ \_/ /  \_/        |_/ (/_ /--\ (_  |_ | \/ (_|  |_ (/_ ")
	//Conout(cAlinha + "                                                                        ")
	//conout(" ")
	//conout(cAlinha + "self:lConfirm  -> " + cValtochar(self:lConfirm))
	//conout(cAlinha + "self:lEnviar   -> " + cValtochar(self:lEnviar))
	//conout(cAlinha + "self:lGerarLog -> " + cValtochar(self:lGerarLog))
	//conout(" ")
	//conout(cAlinha + "oModel:GetOperation -> " + IIF( oModel:GetOperation() == MODEL_OPERATION_INSERT , "INCLUSAO", IIF( oModel:GetOperation() == MODEL_OPERATION_UPDATE , "ALTERACAO" , IIF( oModel:GetOperation() == MODEL_OPERATION_DELETE , "EXCLUSAO" , "" ))) )
	//Conout(" ")

	if oModel:IsActive()
	else

		if self:lConfirm
//			conout("______________________ VERIFICANDO ______________________")
			// Nao vamos transmitir nesse momento, pois ao confirmar a operação, o registro sera transmitido...
			// Nao transmite nem gera log quando se trata de uma inclusao e veio da rotina de inclusao de entrada...
			lCancSync := (FM_PILHA("VA0700103_INCLUSAONOVOCHASSI") .or. FM_PILHA("VX000INC") .or. FM_PILHA("VA3300081_VV1_AMS"))

			// Se o registro já esta integrado, nao sera integrado novamente 
			if ! lCancSync .and. (self:lIntegDynamics .and. VV1->VV1_BBINTG == '1' .and. VV1->VV1_BBSYNC == '1')
				lCancSync := .t.
			endif

			//if (FM_PILHA("VA0700103_INCLUSAONOVOCHASSI") .and. FM_PILHA("VX000INC")) .or. (VV1->VV1_BBINTG == '1' .and. VV1->VV1_BBSYNC == '1')
			//	//conout(cAlinha + "CANCELANDO TRANSMISAO / GERACAO DE LOG" )
			//	//Conout(" ")
			//	//conout(cAlinha + " __             __   ___                 __   __     ___  __             __           __        __ ")
			//	//conout(cAlinha + "/  `  /\  |\ | /  ` |__  |     /\  |\ | |  \ /  \     |  |__)  /\  |\ | /__`  |\/| | /__`  /\  /  \")
			//	//conout(cAlinha + "\__, /~~\ | \| \__, |___ |___ /~~\ | \| |__/ \__/     |  |  \ /~~\ | \| .__/  |  | | .__/ /~~\ \__/")
			//	//conout(cAlinha + "                                                                                                   ")
			//	//Conout(" ")
			//else
			if ! lCancSync
				self:_SyncBlackbird(oModel)
				self:_GeraLogVW0(oModel)
			EndIf
		EndIf
	EndIf

	//Conout(cAlinha + "      _ ___       _  __  _          _                 _                                   ")
	//Conout(cAlinha + "\  / |_  |   /\  / \  / / \   __   |_ o ._ _    __   | \  _   /\   _ _|_ o     _. _|_  _  ")
	//Conout(cAlinha + " \/  |_ _|_ /--\ \_/ /  \_/        |  | | | |        |_/ (/_ /--\ (_  |_ | \/ (_|  |_ (/_ ")
	//Conout(cAlinha + "                                                                                          ")

	//nAuxTabSize := 0
	//GetGlbVars("v070ColSize", nAuxTabSize)
	//PutGlbVars("v070ColSize", nAuxTabSize - 3)
	//Conout("")
Return


METHOD _SyncBlackbird(oModel) CLASS VEIA070EVDEF

	local nOperacao
//	local cAlinha := ""

	if self:lEnviar == .f.
		return
	EndIf

	if self:lIntegDynamics == .f. // Verifica se o ambiente esta integrado com o Blackbird
		return
	endif

	if empty(VV1->VV1_CHASSI)
		return
	EndIf

	self:lEnviar := .f.
	nOperacao := oModel:GetOperation()
	if nOperacao == MODEL_OPERATION_INSERT .or. nOperacao == MODEL_OPERATION_UPDATE

		if VV1->VV1_BBDEL == "1" // Registro excluido
			if VV1->VV1_BBINTG == "1" // Registro marcado como integrado
//				Conout(cAlinha + "Chamada da rotina de transmissao de EXCLUSAO automatica")
				VA0700053_ExcluirBlackbird("VV1",VV1->(Recno()),4,.f.)
			EndIf
		else
			VA0700033_TransmitirBlackBird("VV1",VV1->(Recno()),4,.f.)
		EndIf
		
	EndIf

	if nOperacao == MODEL_OPERATION_DELETE
		if VV1->VV1_BBINTG == "1" // Registro marcado como integrado
			VA0700053_ExcluirBlackbird("VV1",VV1->(Recno()),4,.f.)
		EndIf
	EndIf
Return


METHOD _GeraLogVW0(oModel) CLASS VEIA070EVDEF
	local nOperacao
	
	if self:lGerarLog == .f.
		return
	EndIf
	if empty(VV1->VV1_CHASSI)
		return
	EndIf
	nOperacao := oModel:GetOperation()
	if nOperacao <> MODEL_OPERATION_INSERT .and. nOperacao <> MODEL_OPERATION_UPDATE
		return
	EndIf
	VA0700173_LogVW0(self:cRotOrigem, self:cAuxFil_UltMov, self:cAuxMov_UltMov)
Return


METHOD _Ajusta_SC1_SC7(cCodSB1,cChassi) CLASS VEIA070EVDEF
	Local cQuery    := ""
	Local cSQLAlias := "SQLSC1SC7"
	Local aArea     := GetArea()
	//	
	cQuery := "SELECT R_E_C_N_O_ AS RECSC1"
	cQuery += "  FROM "+RetSQLName("SC1")
	cQuery += " WHERE C1_FILIAL  = '"+xFilial("SC1")+"'"
	cQuery += "   AND C1_PRODUTO = '"+Alltrim(cCodSB1)+"'"
	cQuery += "   AND C1_DESCRI <> '"+Alltrim(cChassi)+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		DbSelectArea("SC1")
		SC1->(DbGoto((cSQLAlias)->( RECSC1 ))) // Posiciona na SC1 para ajustar a Descrição do Produto (CHASSI)
		RecLock("SC1",.f.)
			SC1->C1_DESCRI := Alltrim(cChassi)
		MsUnLock()
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	//
	cQuery := "SELECT R_E_C_N_O_ AS RECSC7"
	cQuery += "  FROM "+RetSQLName("SC7")
	cQuery += " WHERE C7_FILIAL  = '"+xFilial("SC7")+"'"
	cQuery += "   AND C7_PRODUTO = '"+Alltrim(cCodSB1)+"'"
	cQuery += "   AND C7_DESCRI <> '"+Alltrim(cChassi)+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		DbSelectArea("SC7")
		SC7->(DbGoto((cSQLAlias)->( RECSC7 ))) // Posiciona na SC7 para ajustar a Descrição do Produto (CHASSI)
		RecLock("SC7",.f.)
			SC7->C7_DESCRI := Alltrim(cChassi)
		MsUnLock()
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	//
	RestArea( aArea )	
	//
Return