
#include 'TOTVS.ch'
#include "PROTHEUS.CH"
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#include "OFIA486.CH" // mesmo CH do OFIA486

Static lPEVERTPGCC	:= ExistBlock("VERTPGCC")
Static cMVCHKCRE 	:= GetMv("MV_CHKCRE")
Static lMultMoeda	:= FGX_MULTMOEDA()
CLASS OFIA486EVDEF FROM FWModelEvent

	Data lMostraEstoque
	Data aMotCancel
	Data aIteRes
	Data aIteDev
	Data aIteSug
	Data lSugCompra

	Data aIteTrf

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()
	METHOD GridLinePosVld()
	METHOD BeforeTTS()
	METHOD InTTS()
	METHOD ModelPosVld()
	METHOD GetItensSugestao()
	METHOD GetGeraSugestao()
	METHOD ValidRequiredField()
	METHOD GetConferencia()
	METHOD VldActivate()
	METHOD DeActivate()
	METHOD AvalCredVSJ()
	METHOD GetItemTransferenciaVDD()
	METHOD GetSaldoItem()

ENDCLASS


METHOD New() CLASS OFIA486EVDEF
	local oRpm := OFJDRpmConfig():New()
	::lMostraEstoque := oRpm:MostraEstoqueAoDigitar()
	::aMotCancel     := {}
	::aIteRes        := {}
	::aIteDev        := {}
	::aIteSug        := {}
	::lSugCompra     := ( ( GetNewPar("MV_SUGCOS","N") == "S" ))

	::aIteTrf        := {}

RETURN .T.


METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFIA486EVDEF

	Local lRet      := .t.

	Local lVOICODSIT:= VOI->(FieldPos("VOI_CODSIT")) > 0
	Local lVOITESPEC:= VOI->(FieldPos("VOI_TESPEC")) > 0 // Argentina/México - Tem TES default para PEÇAS no Cadastro do Tipo de Tempo
	Local oRpm := OFJDRpmConfig():New()
	Local oOficina := DMS_Oficina():New()

	Local lVSJQTDTRA:= VSJ->(FieldPos("VSJ_QTDTRA")) > 0

	If cModelId == "VSJDETAIL"
	
		If cAction == "CANSETVALUE"

			If IsInCallStack("OM020029G_Demanda_Retroativa")
				If !(cId $ "VSJ_CODSIT/VSJ_MOTPED/")
					lRet := .f.
				EndIf
			Else
				if !(oSubModel:IsInserted(nLine))
					lRet := .f.
				EndIf

				If cId $ "VSJ_GRUITE/VSJ_CODITE/VSJ_QTDINI/VSJ_OPER/VSJ_CODTES/VSJ_CODSIT/VSJ_NNRCOD/"
					If Empty(oSubModel:GetValue( "VSJ_TIPTEM" ))
						lRet := .f.
					EndIf
				EndIf
				If cId $ "VSJ_FATPAR/VSJ_LOJA"
					If !Empty(oSubModel:GetValue( "VSJ_TIPTEM" ))
						VOI->(DbSetOrder(1))
						If VOI->(DbSeek(xFilial("VOI")+oSubModel:GetValue( "VSJ_TIPTEM" )))
							If VOI->VOI_ALTCLI == "0"
								lRet := .f.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

		ElseIf cAction == "DELETE"

			if !(oSubModel:IsInserted(nLine))

				// Se o registro estiver gravado na base, so podera ser marcada venda perdida se nao foi feita requisicao ...
				If !oSubModel:IsDeleted(nLine)

					oView := FWViewActive()

					If oSubModel:GetValue("VSJ_QTDREQ") > 0
						FMX_HELP("VSJMANUAL",STR0011) // "Não é possível registrar venda perdida pois já houve requisição."
						Return .f.
					EndIf

					If oSubModel:GetValue("VSJ_QTDAGU") > 0
						FMX_HELP("VSJMANUAL",STR0012) // Impossível excluir, pois esta Peça já possui Sugestão de Compras relacionada a Ordem de Serviço.
						Return .f.
					EndIf

					If lVSJQTDTRA .and. oSubModel:GetValue("VSJ_QTDTRA") > 0
						FMX_HELP("VSJMANUAL", STR0030) // "Impossível excluir, pois esta Peça já possui Solicitação de Transferencia para outra filial que está relacionada a Ordem de Serviço."
						Return .f.
					EndIf

					::aMotCancel := OFA210MOT("000002","2","","",.f.) // Filtro da consulta do motivo
					If Len(::aMotCancel) == 0
						FMX_HELP("VSJMANUAL",STR0013) // "É necessário informar o motivo do cancelamento do registro de peça pendente para requisição."
						Return .f.
					EndIf

					If ::GetConferencia(oSubModel:GetValue("VSJ_CODIGO")) > 0 // Valida se possui conferência em andamento
						FMX_HELP("VSJEMCONF",STR0019) // Impossível excluir, pois esta Peça encontra-se em processo de Conferência.
						Return .f.
					Endif

					oSubModel:SetValue("VSJ_QTDITE", 0 )
					oSubModel:SetValue("VSJ_MOTPED", ::aMotCancel[1])
					oSubModel:SetValue("VSJ_DESMOT", ::aMotCancel[2])

					oView:Refresh('VIEW_VSJ')
				EndIf

			Else

				nPLVDD := aScan( ::aIteTrf, {|x| x[1] == nLine } )
				If nPLVDD > 0
					::aIteTrf[nPLVDD,3] := .f.
				EndIf

			EndIf

		ElseIf cAction == "SETVALUE"

			If IsInCallStack("OM020029G_Demanda_Retroativa")
				Return(.T.)
			EndIf
			
			If cId $ "VSJ_GRUITE/VSJ_CODITE/VSJ_QTDINI"
				If lVSJQTDTRA .and. oSubModel:GetValue( "VSJ_QTDTRA" ) > 0
					FMX_HELP("OA486ERR001", STR0031) // Não é possível alterar um item com pedido de peças pendente.
					Return .F.
				EndIf
			EndIf

			If cId == "VSJ_TIPTEM"
				
				If oOficina:TipoTempoBloqueado(xValue, .T.)
					Return .F.
				Endif

				VOI->( DbSetOrder(1) )
				VOI->( DbSeek( xFilial("VOI") + xValue ) )

				If VOI->VOI_DEPGAR <> "1" .and. !Empty(oSubModel:GetValue("VSJ_DEPGAR"))
					oSubModel:SetValue("VSJ_DEPGAR", Space(GetSX3Cache("VSJ_DEPGAR","X3_TAMANHO")) )
				EndIf

				If VOI->VOI_DEPINT <> "1" .and. !Empty(oSubModel:GetValue("VSJ_DEPINT"))
					oSubModel:SetValue("VSJ_DEPINT", Space(GetSX3Cache("VSJ_DEPINT","X3_TAMANHO")) )
				EndIf

				If cPaisLoc $ "ARG/MEX" .and. lVOITESPEC .and. !Empty(VOI->VOI_TESPEC) // Argentina/México - Tem TES default para PEÇAS no Cadastro do Tipo de Tempo
					oSubModel:LoadValue("VSJ_OPER" , Space(GetSX3Cache("VSJ_OPER","X3_TAMANHO")) )
					oSubModel:SetValue("VSJ_CODTES", VOI->VOI_TESPEC )
				ElseIf !Empty(VOI->VOI_CODOPE)
					If !Empty(oSubModel:GetValue("VSJ_CODITE"))
						oSubModel:SetValue("VSJ_OPER", VOI->VOI_CODOPE )
					EndIf
				EndIf

				If lVOICODSIT
					oSubModel:SetValue("VSJ_CODSIT", VOI->VOI_CODSIT )
				EndIf

				oSubModel:SetValue("VSJ_FORMUL", VOI->VOI_VALPEC )

				If !Empty(oSubModel:GetValue("VSJ_GRUITE")) .and. !Empty(oSubModel:GetValue("VSJ_CODITE"))
					oSubModel:LoadValue( "VSJ_VALPEC", FG_VALPEC(FwFldGet("VSJ_TIPTEM"),"VOI->VOI_VALPEC",SB1->B1_GRUPO,SB1->B1_CODITE,,.f.,.t.) )
				Endif

			ElseIf cId == "VSJ_NNRCOD"

				if ! empty(FwFldGet("VSJ_NNRCOD")) .and. ! empty(FwFldGet("VSJ_CODITE"))
					FG_POSSB1('FwFldGet("VSJ_CODITE")','SB1->B1_CODITE','FwFldGet("VSJ_GRUITE")')

					if oRpm:lNovaConfiguracao
						If !empty(FwFldGet("VSJ_NNRCOD"))
							oSubModel:LoadValue( "VSJ_LOCAL" , FwFldGet("VSJ_NNRCOD") )
						EndIf
					endif

					If ::lMostraEstoque
						nQtdEst := ::GetSaldoItem( SB1->B1_COD, oSubModel:GetValue( "VSJ_LOCAL" ) )
						oSubModel:LoadValue("VSJ_QTDEST", nQtdEst )
					EndIf

				endif

			ElseIf cId == "VSJ_CODITE"
				
				if oRpm:lNovaConfiguracao

					cLocalProv := ""
					if empty(FwFldGet("VSJ_NNRCOD")) .and. ! empty(VO1->VO1_SEGMTO)
						cLocalProv := oRpm:oNovaConfiguracao:PrimArmazemProvavel(VO1->VO1_SEGMTO)
					endif
					If empty(cLocalProv)
						cLocalProv := OM0200065_ArmazemOrigem( FwFldGet("VSJ_TIPTEM") )
					EndIf
					if ! empty(cLocalProv)
						oSubModel:LoadValue("VSJ_NNRCOD", cLocalProv)
					endif

					If !empty(FwFldGet("VSJ_NNRCOD"))
						oSubModel:SetValue( "VSJ_LOCAL" , FwFldGet("VSJ_NNRCOD") )
					EndIf

				else

					cOrigem := OM0200065_ArmazemOrigem( FwFldGet("VSJ_TIPTEM") )
					oSubModel:SetValue( "VSJ_LOCAL" , cOrigem )
					oSubModel:LoadValue( "VSJ_VALCUS", FS_VALCUS( SB1->B1_COD , cOrigem ) )

				endif

				If ::lMostraEstoque
					nQtdEst := ::GetSaldoItem( SB1->B1_COD, oSubModel:GetValue( "VSJ_LOCAL" ) )
					oSubModel:LoadValue("VSJ_QTDEST", nQtdEst )
				EndIf

				If !Empty(SB1->B1_TS)
					oSubModel:LoadValue("VSJ_CODTES", SB1->B1_TS)
				EndIf

				If cPaisLoc $ "ARG/MEX" .and. lVOITESPEC // Argentina/México - Tem TES default para PEÇAS no Cadastro do Tipo de Tempo
					VOI->( DbSetOrder(1) )
					VOI->( DbSeek( xFilial("VOI") + oSubModel:GetValue("VSJ_TIPTEM") ) )
					If !Empty(VOI->VOI_TESPEC) // Argentina/México - Tem TES default para PEÇAS no Cadastro do Tipo de Tempo
						oSubModel:LoadValue("VSJ_OPER", Space(GetSX3Cache("VSJ_OPER","X3_TAMANHO")) )
						oSubModel:LoadValue("VSJ_CODTES", VOI->VOI_TESPEC )
					EndIf
				EndIf

				If !Empty(oSubModel:GetValue("VSJ_TIPTEM"))
					oSubModel:LoadValue( "VSJ_VALPEC", FG_VALPEC(FwFldGet("VSJ_TIPTEM"),"VOI->VOI_VALPEC",SB1->B1_GRUPO,SB1->B1_CODITE,,.f.,.t.) )
				Endif

				oSubModel:SetValue( "VSJ_PROIMP", Posicione("VAI",4,xFilial("VAI") + __cUserID , "VAI_CODUSR" ) )

				if !OA486010H_VerificaPecaDigitada(M->VSJ_CODITE, oSubModel:GetValue("VSJ_GRUITE") )
					return .f.
				endif

				If Empty(oSubModel:GetValue("VSJ_CODIGO"))
					oSubModel:SetValue("VSJ_CODIGO", GetSxeNum("VSJ","VSJ_CODIGO",,3) )
				EndIf

			ElseIf cId == "VSJ_OPER"

				cAuxTES := MaTesInt(2,xValue,FwFldGet("VSJ_FATPAR"),FwFldGet("VSJ_LOJA"),"C",SB1->B1_COD)

				If !Empty(cAuxTES)
					SF4->(dbSetOrder(1))
					If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
						Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VSJ_CODTES")) + ": " + cAuxTES ,4,1)
						Return .f.
					EndIf
					oSubModel:LoadValue("VSJ_CODTES", cAuxTES )
				EndIf

			ElseIf cId == "VSJ_QTDINI"

				If ::lMostraEstoque
					If oSubModel:GetValue("VSJ_QTDEST") < xValue
						AVISO(STR0007, STR0008 + cValToChar(oSubModel:GetValue("VSJ_QTDEST")), { "Ok" }, 3)
					EndIf
				EndIf

				If lVSJQTDTRA
					::GetItemTransferenciaVDD(oSubModel,xValue,oSubModel:GetValue("VSJ_CODTES"),nLine)
				EndIf

				oSubModel:LoadValue("VSJ_QTDDIG", xValue )
				oSubModel:LoadValue("VSJ_QTDITE", xValue )

			ElseIf cId == "VSJ_CODTES"

				If lVSJQTDTRA
					::GetItemTransferenciaVDD(oSubModel,oSubModel:GetValue("VSJ_QTDINI"),xValue,nLine)
				EndIf

			EndIf

			//Validacao por Ponto de Entrada
			If ExistBlock("OM020OKV")
				lRet := ExecBlock("OM020OKV",.f.,.f.,{cId})
			Endif

		ElseIf cAction == "UNDELETE"

			lRet := OA4860015_FATSP(FwFldGet('VSJ_NUMOSV'), oSubModel:GetValue("VSJ_TIPTEM", nLine ),oSubModel:GetValue("VSJ_FATPAR", nLine ) )
			If lRet
				lRet := OA4860015_FATSP(FwFldGet('VSJ_NUMOSV'), oSubModel:GetValue("VSJ_TIPTEM", nLine ),oSubModel:GetValue("VSJ_FATPAR", nLine ), oSubModel:GetValue("VSJ_LOJA"  , nLine ))
			EndIf

			nPLVDD := aScan( ::aIteTrf, {|x| x[1] == nLine } )
			If nPLVDD > 0
				::aIteTrf[nPLVDD,3] := .t.
			EndIf

		EndIf
		
	EndIf

RETURN lRet


METHOD GridLinePosVld(oSubModel, cModelID, nLine) CLASS OFIA486EVDEF

	If cModelId == "VSJDETAIL"

		If IsInCallStack("OM020029G_Demanda_Retroativa")
			Return(.T.)
		EndIf

		if !(oSubModel:IsInserted(nLine))

			If !oSubModel:IsDeleted(nLine) .and. !Empty(oSubModel:GetValue("VSJ_MOTPED"))
				oSubModel:SetValue("VSJ_QTDITE", oSubModel:GetValue("VSJ_QTDINI") )
				oSubModel:SetValue("VSJ_MOTPED", "")
				oSubModel:SetValue("VSJ_DESMOT", "")
			EndIf

		EndIf

		VOI->( DbSetOrder(1) )
		VOI->( MsSeek( xFilial("VOI") + oSubModel:GetValue('VSJ_TIPTEM')) ) 

		If VOI->VOI_DEPINT=="1" .And. Empty(oSubModel:GetValue('VSJ_DEPINT'))
			Help(NIL, NIL,STR0014, NIL,STR0015,1,0, NIL, NIL, NIL, NIL, NIL, {STR0016})
			Return(.F.)
		EndIf
		If VOI->VOI_DEPGAR=="1" .And. Empty(oSubModel:GetValue('VSJ_DEPGAR'))
			Help(NIL, NIL,STR0014,NIL,STR0017,1,0, NIL, NIL, NIL, NIL, NIL, {STR0018})
			Return(.F.)
		EndIf

	EndIf

	If !::AvalCredVSJ(oSubModel)
		Return(.F.)
	Endif

RETURN


METHOD InTTS(oModel, cModelId) CLASS OFIA486EVDEF

	Local nI         := 0
	Local lVSJManRes := ( IsInCallStack("OFIOM020") .or. IsInCallStack("OFIXA120") ) .and. GetNewPar("MV_MIL0155","0") == "1" // Faz reserva automatica na digitacao do VSJ Manual ? Este parametro é dependente do parametro MV_RITEORC = "S"
	Local lMovReserv := ( !IsInCallStack("OFIOM020") .and. !IsInCallStack("OFIXA120") ) .and. GetNewPar("MV_RITEORC","N") == "S"
	
	Local cOrigem    := "OF"
	Local nCntFor    := 0
	Local nPosVDD    := 0
	Local nCnt       := 0
	Local nLinIte    := 0

	Local aTransf    := {}
	Local lTemEmail  := ( FindFunction("VA0100071_ExisteEmail") .and. FindFunction("OXA0200051_EnviarEmail") )
	Local aVDD       := {}

	Local oRpm    := OFJDRpmConfig():New()

	oMdDet := oModel:GetModel("VSJDETAIL")

	For nI := 1 to oMdDet:Length()
		oMdDet:GoLine(nI)

		If ExistBlock("X486NAUN")
			ExecBlock("X486NAUN",.F.,.F.,{oMdDet:GetValue("VSJ_NUMOSV"), "OFIA486EVDEF", oMdDet:GetValue("VSJ_CODITE"), oMdDet:GetValue("VSJ_QESTNA"), oMdDet:GetValue("VSJ_QTDINI"), oMdDet:GetValue("VSJ_LOCAL"), "InTTS " + cValtoChar(oMdDet:GetValue("VSJ_NUMORC")) + " CODIGO:" + cValtoChar(oMdDet:GetValue("VSJ_CODIGO")), oMdDet:GetValue("VSJ_FILIAL")})
		EndIf
	Next

	If IsInCallStack("OM020029G_Demanda_Retroativa")
		Return(.T.)
	EndIf

	if oRpm:lNovaConfiguracao .and. OA4860105_PrecisaDeSaldo(VO1->VO1_NUMOSV)
		if MsgYesNo(STR0035,STR0007) //"Deseja realizar a transferência interna entre armazéns?"
			OFIA509(,VO1->VO1_NUMOSV)
		endif
	endif

	If lMovReserv .or. lVSJManRes .or. Len(::aIteTrf) > 0

		For nI := 1 to oMdDet:Length()

			oMdDet:GoLine(nI)

			VSJ->(DbSetOrder(3))
			VSJ->(DbSeek(xFilial("VSJ")+oMdDet:GetValue("VSJ_CODIGO")))

			If oMdDet:IsInserted()

				If oMdDet:GetValue("VSJ_RESPEC") == "0"
					aAdd(::aIteRes,{VSJ->(RecNo()),0,""})
				EndIf

			EndIf

			If oMdDet:GetValue("VSJ_QTDAGU") == 0
				aAdd(::aIteSug, VSJ->(RecNo()) )
			EndIf

		Next

		If Len(::aIteRes) > 0

			lSugestao := If(IsInCallStack("OA4860045_GeraSugestaoCompra"),.t.,.f.)

			cDocto := OA4820015_ProcessaReservaItem(cOrigem,,"A","R",::aIteRes,"13",,lSugestao,,,,)

		EndIf

	EndIf

	
// #######################################
	// # Gravacao do VDD                     #
	// #######################################
	aVDD := {}
	for nCntFor := 1 to Len(::aIteTrf)

		If ::aIteTrf[nCntFor,3] // Verifica se a linha deve ser criada

			nLinIte := ::aIteTrf[nCntFor,1]
			aTransf := ::aIteTrf[nCntFor,2]
			
			DBSelectArea("VDD")
			DBSetOrder(4)

			for nCnt := 1 to Len(aTransf)

				aRetVDD := OXA0200045_LevantaPedidoTransferencia(xFilial("VSJ"), , aTransf[nCnt,1], aTransf[nCnt,2], aTransf[nCnt,5], "S" , FwFldGet('VSJ_NUMOSV'), oMdDet:GetValue("VSJ_CODIGO", nLinIte ) )

				if Len(aRetVDD) == 0

					cCodVDD := GetSxENum("VDD","VDD_CODIGO")
					ConfirmSX8()

					reclock("VDD",.t.)
						VDD->VDD_FILIAL := xFilial("VDD")
						VDD->VDD_CODIGO := cCodVDD
						VDD->VDD_FILOSV := xFilial("VSJ")
						VDD->VDD_NUMOSV := FwFldGet('VSJ_NUMOSV')
						VDD->VDD_CODVSJ := oMdDet:GetValue("VSJ_CODIGO", nLinIte )
						VDD->VDD_FILPED := aTransf[nCntFor,5]
						VDD->VDD_GRUPO  := aTransf[nCntFor,1]
						VDD->VDD_CODITE := aTransf[nCntFor,2]
						VDD->VDD_STATUS := "S"
						VDD->VDD_QUANT  := aTransf[nCntFor,4]
						VDD->VDD_TIPTRA := "0" // Avulsa
						VDD->VDD_VENTRA := VO1->VO1_FUNABE //VS1->VS1_CODVEN
					msunlock()

					If lTemEmail

						nPosVDD := aScan(aVDD, {|x| x[1] == aTransf[nCntFor,5] }) // Pesquisa a Filial
						If nPosVDD == 0 // Enviar um e-mail por Filial
							aAdd(aVDD,{aTransf[nCntFor,5],{},VDD->VDD_NUMOSV,VDD->VDD_VENTRA})
							nPosVDD := len(aVDD)
						EndIf

						aAdd(aVDD[nPosVDD,2],{ aTransf[nCntFor,1] , aTransf[nCntFor,2] , "" , aTransf[nCntFor,4] })

					EndIf

				endif

			Next

		EndIf

	Next

	If len(aVDD) > 0
		For nPosVDD := 1 to len(aVDD)
			If VA0100071_ExisteEmail( aVDD[nPosVDD,1] , "002001" )
				// Envio de Email - Evento: 002001 = Inclusão do Pedido de Transferencia
				OXA0200051_EnviarEmail( aVDD[nPosVDD,1] , "002001" , STR0032 , "3" , aClone(aVDD[nPosVDD,2]) , aVDD[nPosVDD,4] , /* Filial Orcamento */ , /* Nro Orcamento */ , xFilial("VSJ") , aVDD[nPosVDD,3] ) // Transferência de Peças - Pedido Incluido
			EndIf
		Next
	EndIf

RETURN .t.


METHOD BeforeTTS(oModel, cModelId) CLASS OFIA486EVDEF

	Local nI         := 0
	Local cOrigem    := "OF"
	Local oRpm       := OFJDRpmConfig():New()
	Local aStructFields := {}

	If IsInCallStack("OM020029G_Demanda_Retroativa")
		Return(.T.)
	EndIf
	
	oMdDet := oModel:GetModel("VSJDETAIL")
	aStructFields := oMdDet:GetStruct():aFields

	For nI := 1 to oMdDet:Length()

		oMdDet:GoLine(nI)

		If !::ValidRequiredField(aStructFields, oMdDet, /*lShowHelp*/) // Valida se os campos obrigatrios esto preenchidos
			Return .F.
		Endif

		VSJ->(DbSetOrder(3))
		VSJ->(DbSeek(xFilial("VSJ")+oMdDet:GetValue("VSJ_CODIGO")))
		SB1->(DBSetOrder(7))
		SB1->(DBSeek(xFilial("SB1") + oMdDet:GetValue("VSJ_GRUITE") + oMdDet:GetValue("VSJ_CODITE")))

		if cPaisLoc $ "ARG|MEX"
			oMdDet:LoadValue( "VSJ_LOCAL", oMdDet:GetValue("VSJ_NNRCOD"))
		endif

		if cPaisLoc $ "ARG|MEX"
			if oMdDet:GetValue("VSJ_QESTNA") < 0 .and. ! empty(oMdDet:GetValue("VSJ_NNRCOD"))
				nQtd := oRpm:SaldoDaPeca(SB1->B1_COD, VO1->VO1_SEGMTO, .T., cFilAnt, oMdDet:GetValue("VSJ_NNRCOD"))
				oMdDet:LoadValue( "VSJ_QESTNA", nQtd)
			Endif
		else
			If oMdDet:IsInserted()
				if oMdDet:GetValue("VSJ_QESTNA") < 0
					nQtd := oRpm:SaldoDaPeca(SB1->B1_COD,, .T., cFilAnt, iif(empty(oMdDet:GetValue("VSJ_LOCAL")), SB1->B1_LOCPAD, oMdDet:GetValue("VSJ_LOCAL")))
					oMdDet:LoadValue( "VSJ_QESTNA", nQtd)
				endif
			EndIf
		endif

		If oMdDet:IsDeleted()
			If oMdDet:GetValue("VSJ_RESPEC") == "1"
				aAdd(::aIteDev,{VSJ->(RecNo()),0,""})
			EndIf
			If !Empty(oMdDet:GetValue("VSJ_MOTPED"))
				oMdDet:UnDeleteLine(.f.)
			EndIf
		EndIf

	Next

	If Len(::aIteDev) > 0
		cDocto := OA4820015_ProcessaReservaItem(cOrigem,,"A","D",::aIteDev,"16")
		If Empty(cDocto)
			Return .f.
		EndIf
	EndIf

RETURN .t.

METHOD ModelPosVld(oModel, cModelId) CLASS OFIA486EVDEF

	Local lRet 		:= .T.
	Default oModel 	:= FwModelActive()

	oVSJDetail := oModel:GetModel("VSJDETAIL")

	If !::AvalCredVSJ(oVSJDetail)
		lRet := .F.
	Endif

Return lRet

/*/{Protheus.doc} GetItensSugestao

	@type method
	@author Renato Vinicius
	@since 30/03/2023
/*/

METHOD GetItensSugestao() CLASS OFIA486EVDEF

	oModel := FwModelActive()
	oMdCab := oModel:GetModel("VSJMASTER")

	If ::lSugCompra
		::aIteSug := OA4860035_LevantaInfoItensSugestao(oMdCab:GetValue("VSJ_NUMOSV"))
	EndIf

Return ::aIteSug

/*/{Protheus.doc} GetItensSugestao

	@type method
	@author Renato Vinicius
	@since 30/03/2023
/*/

METHOD GetGeraSugestao() CLASS OFIA486EVDEF

	Local lSugAuto    := ( ( GetNewPar("MV_SUGCAU","N") == "S" ))

	If ::lSugCompra
		if lSugAuto
			::lSugCompra := .t.
		elseIf !MsgYesNo( STR0009 + CHR(13) + CHR(10) + STR0010 ,STR0007)  //"Existe um ou mais produtos sem estoque disponivel. # Deseja gerar uma sugestão de compra dos produtos sem estoque disponivel # Atenção
			::lSugCompra := .f.
		EndIf
	Endif

Return ::lSugCompra

METHOD ValidRequiredField(aStructFields, oModelActive, lShowHelp) CLASS OFIA486EVDEF

	Local	lRet		:= .T.
	Local 	nPosField	:= 0
	Default lShowHelp 	:= .F.
	
	For nPosField := 1 To Len(aStructFields)

		If aStructFields[nPosField][10] .and. Empty(oModelActive:GetValue(aStructFields[nPosField][3])) // Estrutura do campo é obrigatório, mas esta vazia no model
			If lShowHelp
				FMX_HELP("OBRIGAT", aStructFields[nPosField][3])
			Endif
			lRet := .F.
			Exit
		Endif

	Next

Return lRet

/*/{Protheus.doc} GetConferencia

	@type method
	@author Francisco Carvalho
	@since 08/04/2025
/*/
METHOD GetConferencia(cCodVSJ) CLASS OFIA486EVDEF

Local cQryConf := ""

Default cCodVSJ := " "

cQryConf += "SELECT VSJ.R_E_C_N_O_ AS RECVSJ"
cQryConf += "  FROM " + RetSqlName( "VSJ" ) + " VSJ"
cQryConf += " INNER JOIN " + RetSqlName( "VM4" ) + " VM4 ON VM4_FILIAL = '" + xFilial('VM4') + "' AND VM4.VM4_CODVSJ = VSJ.VSJ_CODIGO AND VM4.D_E_L_E_T_ = ' '"
cQryConf += " INNER JOIN " + RetSqlName( "VM3" ) + " VM3 ON VM3_FILIAL = '" + xFilial('VM3') + "' AND VM3.VM3_CODIGO = VM4.VM4_CODVM3 AND VM3.VM3_STATUS NOT IN ('4','5') AND VM3.D_E_L_E_T_ = ' '" 
cQryConf += " WHERE VSJ.VSJ_FILIAL = '" + xFilial('VSJ') + "'"
cQryConf += "   AND VSJ.VSJ_CODIGO = '" + cCodVSJ + "'"
cQryConf += "   AND VSJ.D_E_L_E_T_ = ' '"

Return FM_SQL(cQryConf)	

METHOD VldActivate(oModel, cModelId) CLASS OFIA486EVDEF

	If IsInCallStack("OM020029G_Demanda_Retroativa")
		SetKey(VK_F5,{|| OA486007G_DemandaRetroativa() })
	EndIf

Return .T.

METHOD DeActivate(oModel) CLASS OFIA486EVDEF

	If IsInCallStack("OM020029G_Demanda_Retroativa")
		SetKey(VK_F5, Nil )
	EndIf

Return .T.

Method AvalCredVSJ(oVSJDetail) Class OFIA486EVDEF

	Local lRet		:= .T.
	Local lVerTpgCC	:= .T.
	Local nI		:= 0
	Local nValorPec := 0
	Local nPosCli	:= 0
	Local aCliVldCred := {}

	If lPEVERTPGCC // Verifica tipo de Pagamento para Checagem de Credito
		lVerTpgCC := ExecBlock("VERTPGCC", .F., .F., {"OFIA486"})
	EndIf

	If lVerTpgCC .and. "R" $ Upper(cMVCHKCRE)

		For nI := 1 to oVSJDetail:Length()

			oVSJDetail:GoLine(nI)
			If !oVSJDetail:IsDeleted()

				VOI->(DBSetOrder(1))
				If VOI->(DBSeek(xFilial("VOI") + oVSJDetail:GetValue("VSJ_TIPTEM"))) .and. !(VOI->VOI_SITTPO $ "2/3/4")

					nPosCli := aScan(aCliVldCred, {|x| x[1] == oVSJDetail:GetValue("VSJ_FATPAR") .and. x[2] == oVSJDetail:GetValue("VSJ_LOJA")})
					If nPosCli == 0
						aAdd(aCliVldCred, {oVSJDetail:GetValue("VSJ_FATPAR"), oVSJDetail:GetValue("VSJ_LOJA"), 0})
						nPosCli := aScan(aCliVldCred, {|x| x[1] == oVSJDetail:GetValue("VSJ_FATPAR") .and. x[2] == oVSJDetail:GetValue("VSJ_LOJA")})
					Endif

					If VOI->VOI_VLPCAC == "1"
						aCliVldCred[nPosCli][3] += oVSJDetail:GetValue("VSJ_QTDITE") * FG_VALPEC(oVSJDetail:GetValue("VSJ_TIPTEM"),"VOI->VOI_VALPEC", oVSJDetail:GetValue("VSJ_GRUITE"), oVSJDetail:GetValue("VSJ_CODITE"),,.F.,.T.)
					Else
						aCliVldCred[nPosCli][3] += oVSJDetail:GetValue("VSJ_QTDITE") * oVSJDetail:GetValue("VSJ_VALPEC")
					Endif

				Endif
			Endif
		Next

		For nI := 1 To Len(aCliVldCred)
			cCodCli		:= aCliVldCred[ni][1]
			cLojaCli	:= aCliVldCred[ni][2]
			nValorPec	:= aCliVldCred[ni][3]

			If !FindFunction('FGX_ChkCredCond') .or. FGX_ChkCredCond(VO1->VO1_FORPAG)			
				If !FGX_AvalCred(cCodCli, cLojaCli, nValorPec ,.F., , , IIF(lMultMoeda, Max(VO1->VO1_MOEDA, 1), Nil))
					Help("  ",1,"LIMITECRED",, cCodCli+"-"+cLojaCli, 4, 1)
					lRet := .F.
				EndIf
			Endif
			
		Next
	Endif

Return lRet

/*/{Protheus.doc} GetConferencia

	@type method
	@author Francisco Carvalho
	@since 08/04/2025
/*/
METHOD GetItemTransferenciaVDD(oSubModel,nQtdReq,cTES,nLine) CLASS OFIA486EVDEF

	Local lVerTrf  := .f.
	Local nCntFor  := 0
	Local aPedTransf := {}
	Local nQtdEst  := 0

	If cPaisLoc == "ARG"
		lVerTrf := .t.
	EndIf

	if lVerTrf

		SF4->( dbSeek( xFilial("SF4") + cTES ) )

		if SF4->F4_ESTOQUE == "S"

			nQtdEst := ::GetSaldoItem( SB1->B1_COD, oSubModel:GetValue( "VSJ_LOCAL" ) )

			if nQtdEst < nQtdReq .and. MsgYesNo( STR0033, STR0007 ) // "Deseja verificar a disponibilidade da peça em outra filial?","Atenção"

				nEstSeg := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ESTSEG")

				aPedTra2 := OXA020LBOX(xFilial("VSJ"),SB1->B1_GRUPO,SB1->B1_CODITE, nQtdReq - ( nQtdEst - nEstSeg ), 1 )

				if ! Empty(aPedTra2)

					nQtdPTra := 0
					for nCntFor := 1 to Len(aPedTra2)
						nQtdPTra += aPedTra2[nCntFor,4]
					next

					oSubModel:LoadValue("VSJ_QTDTRA", nQtdPTra )

					for nCntFor := 1 to Len (aPedTra2)
						nPos := aScan(aPedTransf,{|x| x[1]+x[2]+x[5] == aPedTra2[nCntFor,1]+aPedTra2[nCntFor,2]+aPedTra2[nCntFor,5]})
						if nPos == 0
							aAdd(aPedTransf,aPedTra2[nCntFor])


						endif
					next

					If Len(aPedTransf) > 0
						/*	
							[1] - Linha na grid
							[2] - Vetor com as quantidades e filiais
							[3] - Indicador de linha valida
						*/
						aAdd(::aIteTrf,{nLine,aPedTransf,.t.})
					EndIf
				endif
			endif
		Else
			If oSubModel:GetValue("VSJ_QTDTRA") > 0
				oSubModel:LoadValue("VSJ_QTDTRA", 0 )
			EndIf
		endif
	endif

Return

/*/{Protheus.doc} GetSaldoItem

	@type method
	@author Renato Vinicius
	@since 11/08/2025
/*/
METHOD GetSaldoItem(cCodProd, cLocItem) CLASS OFIA486EVDEF

	Local oRpm    := OFJDRpmConfig():New()
	Local nSldEst := 0

	If oRpm:lNovaConfiguracao
		If !Empty( cLocItem )
			nSldEst := oRpm:SaldoTotalDaPeca( cCodProd, cFilAnt, cLocItem )
		EndIf
	Else
		nSldEst := FS_SALDOESTQ( cCodProd, cLocItem )
	EndIf

Return nSldEst