#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE 'OFINJD50.CH'
#INCLUDE 'TOPCONN.CH'

CLASS OFINJD50EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD FieldPreVld()

ENDCLASS


METHOD New() CLASS OFINJD50EVDEF

RETURN .T.

METHOD ModelPosVld(oModel, cModelId) CLASS OFINJD50EVDEF

	Local lRet := .t.
	Local aVetCb	:= {}
	Local aVetIt	:= {}
	Local oMGridInfNf := oModel:GetModel("INFORMACAONF")
	Local oMGridGar := oModel:GetModel("GARANTIAS")
	Local nQtdLines  := oMGridGar:Length()
	Local nX

	Local cVMBNUM := ""
	Local cVMBSER := ""
	Local cVMBPED := ""
	Local cVMBCLI := ""
	Local cVMBLOJ := ""

	Local aCabs   := {}
	Local aItens  := {}
	Local cQuery  := ""

	If oModel:GetOperation() == MODEL_OPERATION_DELETE

		SF2->(DbSetOrder(1))
		SF2->(DbSeek(xFilial("SF2")+oMGridInfNf:GetValue("VMBNFTDEA")+oMGridInfNf:GetValue("VMBSFTDEA")+oMGridInfNf:GetValue("C5CLIENTE")+oMGridInfNf:GetValue("C5LOJACLI")))

		Private aCabsSF2  := FWSX3Util():GetAllFields("SF2", .F.)
		Private aItensSD2 := FWSX3Util():GetAllFields("SD2", .F.)

		// Procesa cancelación del documento NF/NDC
		aSize(aCabs, 0)
		aSize(aItens, 0)

		For nX := 1 to Len(aCabsSF2)
			aAdd(aCabs, {aCabsSF2[nX], &("SF2->"+aCabsSF2[nX]), Nil})
		Next nX

		SD2->(dbSetOrder(3))
		SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

		Do While !SD2->(Eof()) .And. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
			aAdd(aItens, {})
			For nX := 1 to Len(aItensSD2)
				aAdd(aItens[Len(aItens)], {aItensSD2[nX],&("SD2->"+aItensSD2[nX]), Nil})
			Next nX
			SD2->(dbSkip())
		Enddo

		lMSErroAuto := .F.

		MSExecAuto({|x,y,z| MATA467N(x,y,z)},aCabs,aItens,6) // Chamada da Nota de Saida Manual e de Beneficiamento a Cliente

		If lMsErroAuto
			MostraErro()
			MsUnlockAll()
			Return .f.
		EndIf

		cQuery := "SELECT R_E_C_N_O_ RECNOVMB"
		cQuery += " FROM " + RetSQLName("VMB") + " "
		cQuery += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "' "
		cQuery += 	" AND VMB_NFTDEA = '" + oMGridInfNf:GetValue("VMBNFTDEA") + "'"
		cQuery += 	" AND VMB_SFTDEA = '" + oMGridInfNf:GetValue("VMBSFTDEA") + "'"
		cQuery += 	" AND VMB_CFTDEA = '" + oMGridInfNf:GetValue("C5CLIENTE") + "'"
		cQuery += 	" AND VMB_LFTDEA = '" + oMGridInfNf:GetValue("C5LOJACLI") + "'"
		cQuery += 	" AND D_E_L_E_T_ = ' '"

		TcQuery cQuery New Alias "TMPVMB"

		While !TMPVMB->( Eof() )

			DbSelectArea("VMB")
			VMB->(DbGoTo(TMPVMB->RECNOVMB))

			RecLock("VMB",.f.)
				VMB->VMB_NFTDEA := ""
				VMB->VMB_SFTDEA := ""
				VMB->VMB_CFTDEA := ""
				VMB->VMB_LFTDEA := ""
				VMB->VMB_PFTDEA := ""
			MsUnLock()

			TMPVMB->( DbSkip() )

		EndDo

		TMPVMB->( DbCloseArea() )

	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE

		If oModel:GetValue("CAMPOSTOTAL" ,"CPOTOTGAR") == 0
			oModel:SetErrorMessage(oModel:GetId(), "", oModel:GetId(), "CPOSELGAR", "OFINJD50EVDEF", STR0015 ) //"Não foi selecionada nenhuma garantia para geração da fatura dealer"
			Return .f.
		EndIf

		aVetCb := {	oModel:GetValue("INFORMACAONF","C5CLIENTE"),;
					oModel:GetValue("INFORMACAONF","C5LOJACLI"),;
					oModel:GetValue("INFORMACAONF","C5VEND1"),;
					oModel:GetValue("INFORMACAONF","C5CONDPAG"),;
					oModel:GetValue("INFORMACAONF","C5NATUREZ"),;
					"",;
					"",;
					oModel:GetValue("INFORMACAONF","C5MENNOTA"),;
					oModel:GetValue("INFORMACAONF","C5MENPAD") }

		aAdd( aVetIt ,{ oModel:GetValue("INFORMACAONF","CPOCODPRD"),;
						oModel:GetValue("CAMPOSTOTAL" ,"CPOTOTFAT"),;
						""})

		aNF := FMX_GERNFS(	aVetCb,;
							aVetIt,;
							.t.,;
							GetNewPar("MV_PREFOFI","OFI"),;
							,;
							oModel:GetValue("INFORMACAONF","C5TIPOCLI"),;
							,;
							,;
							,;
							,;
							oModel:GetValue("INFORMACAONF","C5MOEDA"))

		cVMBNUM := aNF[1]
		cVMBSER := aNF[2]

		If Len(aNF) > 2
			cVMBPED := aNF[3]
		EndIf

		cVMBCLI := oModel:GetValue("INFORMACAONF","C5CLIENTE")
		cVMBLOJ := oModel:GetValue("INFORMACAONF","C5LOJACLI")

		If Empty(cVMBNUM)
			Return .f.
		EndIf

		For nX := 1 to nQtdLines

			oMGridGar:GoLine(nX)

			If oMGridGar:GetValue("CPOSELGAR")

				DbSelectArea("VMB")
				VMB->(DbGoTo(oMGridGar:GetValue("RECNOVMB")))

				RecLock("VMB",.f.)

					VMB->VMB_NFTDEA := cVMBNUM
					VMB->VMB_SFTDEA := cVMBSER
					VMB->VMB_CFTDEA := cVMBCLI
					VMB->VMB_LFTDEA := cVMBLOJ
					VMB->VMB_PFTDEA := cVMBPED

				MsUnLock()

			EndIf

		Next nX
	EndIf

RETURN lRet


METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS OFINJD50EVDEF

	Local oModCab   := FwModelActive()
	Local nVConvert := 0

	If cAction == "SETVALUE"
		If cId == "C5MOEDA"

			nVConvert := FG_MOEDA( oModCab:GetValue("CAMPOSTOTAL","CPOTOTGAR") , oSubModel:GetValue("C5MOEDA") , xValue )

			oModCab:SetValue("CAMPOSTOTAL","CPOTOTGAR",nVConvert)

		EndIf
	EndIf

RETURN