#include "protheus.ch"

#define VM_INSERT   64   // Inclusao de Registro
#define VM_UPDATE   128  // Alteracao de Registro
#define VM_DELETE   256  // Exclusao de Registro

User Function PDAOpen()
Local cX2Alias   := ParamIxb[1]
Local cRealAlias := ParamIxb[2]
Local cNameFile  := ParamIxb[3]
Local cEmpFile   := cEmpAnt //Subs(cNameFile,4,2)
Local cHtrChave := ""
Local nStatusTrg := Val(GetSrvProfString("HHTriggerOn","0"))
Local lTriggerOn := .F.

// Desabilita o Trigger para todos 
If nStatusTrg = 0
	Return .T.
EndIf

// Verifica Tabela de Gatilhos
If Select("HHTRG") = 0
	HHOpenTrg()
EndIf
If nStatusTrg = 1  // Sempre executa os triggers
	lTriggerOn := .T.
ElseIf  nStatusTrg = 2   // Verifica o Trigger por Empresa
	cHtrChave := cEmpFile
ElseIf  nStatusTrg = 3   // Verifica o Trigger por Empresa / Filial
	cHtrChave := cEmpFile + cFilAnt
ElseIf nStatusTrg = 4  // Verifica o Trigger por Empresa / Filial / Alias
	cHtrChave := cEmpFile + cFilAnt + cX2Alias
EndIf

If !lTriggerOn
	If !HHTRG->(dbSeek(cHtrChave)) .Or. Empty(HHTRG->HTR_TRG)
		// Gatilho nao ativado para a empresa
		Return .T.
	EndIf
EndIf

Do Case
	Case cX2Alias = "SM0"
		FldSettrigger( SM0->M0_CODFIL, VM_INSERT, {|cCpo,nOper| U_HHSM0(cCpo,nOper)})
		FldSettrigger( SM0->M0_CODFIL, VM_UPDATE, {|cCpo,nOper| U_HHSM0(cCpo,nOper)})
		FldSettrigger( SM0->M0_CODFIL, VM_DELETE, {|cCpo,nOper| U_HHSM0(cCpo,nOper)})
	Case cX2Alias = "SA3"
		FldSettrigger( SA3->A3_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSA3(cCpo,nOper)})
		FldSettrigger( SA3->A3_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSA3(cCpo,nOper)})
		FldSettrigger( SA3->A3_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSA3(cCpo,nOper)})
	Case cX2Alias = "SCT"
		FldSettrigger( SCT->CT_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSCT(cCpo,nOper)})
		FldSettrigger( SCT->CT_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSCT(cCpo,nOper)})
		FldSettrigger( SCT->CT_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSCT(cCpo,nOper)})
	Case cX2Alias = "SA1"
		FldSettrigger( SA1->A1_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSA1(cCpo,nOper)})
		FldSettrigger( SA1->A1_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSA1(cCpo,nOper)})
		FldSettrigger( SA1->A1_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSA1(cCpo,nOper)})
	Case cX2Alias = "AC8"
		FldSettrigger( AC8->AC8_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHAC8(cCpo,nOper)})
		FldSettrigger( AC8->AC8_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHAC8(cCpo,nOper)})
		FldSettrigger( AC8->AC8_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHAC8(cCpo,nOper)})
	Case cX2Alias = "SE4"
		FldSettrigger( SE4->E4_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSE4(cCpo,nOper)})
		FldSettrigger( SE4->E4_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSE4(cCpo,nOper)})
		FldSettrigger( SE4->E4_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSE4(cCpo,nOper)})
	Case cX2Alias = "SF4"			
		FldSettrigger( SF4->F4_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSF4(cCpo,nOper)})
		FldSettrigger( SF4->F4_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSF4(cCpo,nOper)})
		FldSettrigger( SF4->F4_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSF4(cCpo,nOper)})
	Case cX2Alias = "SE1"
		FldSettrigger( SE1->E1_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSE1(cCpo,nOper)})
		FldSettrigger( SE1->E1_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSE1(cCpo,nOper)})
		FldSettrigger( SE1->E1_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSE1(cCpo,nOper)})
	Case cX2Alias = "SBM"
		FldSettrigger( SBM->BM_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSBM(cCpo,nOper)})
		FldSettrigger( SBM->BM_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSBM(cCpo,nOper)})
		FldSettrigger( SBM->BM_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSBM(cCpo,nOper)})
	Case cX2Alias = "SB1"
		FldSettrigger( SB1->B1_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSB1(cCpo,nOper)})
		FldSettrigger( SB1->B1_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSB1(cCpo,nOper)})
		FldSettrigger( SB1->B1_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSB1(cCpo,nOper)})
	Case cX2Alias = "DA0"
		FldSettrigger( DA0->DA0_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHDA0(cCpo,nOper)})
		FldSettrigger( DA0->DA0_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHDA0(cCpo,nOper)})
		FldSettrigger( DA0->DA0_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHDA0(cCpo,nOper)})
	Case cX2Alias = "DA1"
		FldSettrigger( DA1->DA1_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHDA1(cCpo,nOper)})
		FldSettrigger( DA1->DA1_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHDA1(cCpo,nOper)})
		FldSettrigger( DA1->DA1_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHDA1(cCpo,nOper)})
	Case cX2Alias = "AD7"
		FldSettrigger( AD7->AD7_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHAD7(cCpo,nOper)})
		FldSettrigger( AD7->AD7_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHAD7(cCpo,nOper)})
		FldSettrigger( AD7->AD7_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHAD7(cCpo,nOper)})
	Case cX2Alias = "SA4"
		FldSettrigger( SA4->A4_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSA4(cCpo,nOper)})
		FldSettrigger( SA4->A4_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSA4(cCpo,nOper)})
		FldSettrigger( SA4->A4_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSA4(cCpo,nOper)})
	Case cX2Alias = "ACQ"
		FldSettrigger( ACQ->ACQ_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHACQ(cCpo,nOper)})
		FldSettrigger( ACQ->ACQ_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHACQ(cCpo,nOper)})
		FldSettrigger( ACQ->ACQ_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHACQ(cCpo,nOper)})
	Case cX2Alias = "ACR"
		FldSettrigger( ACR->ACR_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHACR(cCpo,nOper)})
		FldSettrigger( ACR->ACR_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHACR(cCpo,nOper)})
		FldSettrigger( ACR->ACR_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHACR(cCpo,nOper)})
	Case cX2Alias = "ACO"
		FldSettrigger( ACO->ACO_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHACO(cCpo,nOper)})
		FldSettrigger( ACO->ACO_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHACO(cCpo,nOper)})
		FldSettrigger( ACO->ACO_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHACO(cCpo,nOper)})
	Case cX2Alias = "ACP"
		FldSettrigger( ACP->ACP_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHACP(cCpo,nOper)})
		FldSettrigger( ACP->ACP_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHACP(cCpo,nOper)})
		FldSettrigger( ACP->ACP_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHACP(cCpo,nOper)})
	Case cX2Alias = "ACS"
		FldSettrigger( ACS->ACS_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHACS(cCpo,nOper)})
		FldSettrigger( ACS->ACS_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHACS(cCpo,nOper)})
		FldSettrigger( ACS->ACS_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHACS(cCpo,nOper)})
	Case cX2Alias = "ACT"
		FldSettrigger( ACT->ACT_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHACT(cCpo,nOper)})
		FldSettrigger( ACT->ACT_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHACT(cCpo,nOper)})
		FldSettrigger( ACT->ACT_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHACT(cCpo,nOper)})
	Case cX2Alias = "SC5"
		FldSettrigger( SC5->C5_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSC5(cCpo,nOper)})
		FldSettrigger( SC5->C5_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSC5(cCpo,nOper)})
		FldSettrigger( SC5->C5_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSC5(cCpo,nOper)})
	Case cX2Alias = "SC9"
		FldSettrigger( SC9->C9_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSC9(cCpo,nOper)})
		FldSettrigger( SC9->C9_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSC9(cCpo,nOper)})
		FldSettrigger( SC9->C9_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSC9(cCpo,nOper)})
	Case cX2Alias = "SD2"
		FldSettrigger( SD2->D2_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSD2(cCpo,nOper)})
		FldSettrigger( SD2->D2_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSD2(cCpo,nOper)})
		FldSettrigger( SD2->D2_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSD2(cCpo,nOper)})
	Case cX2Alias = "SB2"
		FldSettrigger( SB2->B2_FILIAL, VM_INSERT, {|cCpo,nOper| U_HHSB2(cCpo,nOper)})
		FldSettrigger( SB2->B2_FILIAL, VM_UPDATE, {|cCpo,nOper| U_HHSB2(cCpo,nOper)})
		FldSettrigger( SB2->B2_FILIAL, VM_DELETE, {|cCpo,nOper| U_HHSB2(cCpo,nOper)})
EndCase

Return .T.

User Function HHACQ(cCpo,nOper)
Local cIntr  := ""
Local cAlias := Alias()
Local cId    := HHCheckID("HCQ")
Local nMaxVer := 0

// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("HCQ")
dbSetOrder(1)
lFound := dbSeek(xFilial("ACQ") + ACQ->ACQ_CODREG)

ChkIntr(nOper, @cIntr, "HCQ", lFound)

RecLock("HCQ", !lFound)
HCQ->HCQ_FILIAL := xFilial("ACQ")
HCQ->HCQ_ID     := cId
HCQ->HCQ_CODREG := ACQ->ACQ_CODREG
HCQ->HCQ_DESCRI := ACQ->ACQ_DESCRI
HCQ->HCQ_CODCLI := ACQ->ACQ_CODCLI
HCQ->HCQ_LOJA   := ACQ->ACQ_LOJA
HCQ->HCQ_CODTAB := ACQ->ACQ_CODTAB
HCQ->HCQ_CONDPG := ACQ->ACQ_CONDPG
HCQ->HCQ_FORMPG := ACQ->ACQ_FORMPG
HCQ->HCQ_CODPRO := ACQ->ACQ_CODPRO
HCQ->HCQ_QUANT := ACQ->ACQ_QUANT
HCQ->HCQ_TPRGBN := ACQ->ACQ_TPRGBN
HCQ->HCQ_INTR := cIntr
HCQ->HCQ_VER := nMaxVer := HHGenericUpd(, "HCQ")
HCQ->(MsUnlock())
HCQ->(dbCommit())

HHAtuCtr(, "HCQ", nMaxVer)

dbSelectArea(cAlias)
Return .T.


User Function HHACR(cCpo,nOper)
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HCR")
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("HCR")
dbSetOrder(1)
lFound := dbSeek(xFilial("ACR") + ACR->ACR_CODREG+ACR->ACR_ITEM)

ChkIntr(nOper, @cIntr, "HCR", lFound)
RecLock("HCR", !lFound)

HCR->HCR_FILIAL := xFilial("ACR")
HCR->HCR_ID := cId
HCR->HCR_CODREG := ACR->ACR_CODREG
HCR->HCR_ITEM := ACR->ACR_ITEM
HCR->HCR_CODPRO := ACR->ACR_CODPRO
HCR->HCR_GRUPO := ACR->ACR_GRUPO
HCR->HCR_LOTE := ACR->ACR_LOTE
HCR->HCR_INTR := cIntr
HCR->HCR_VER := nMaxVer := HHGenericUpd(, "HCR")
HCR->(MsUnlock())
HCR->(dbCommit())

HHAtuCtr(, "HCR", nMaxVer)
dbSelectArea(cAlias)
Return .T.


User Function HHACS(cCpo,nOper)
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HCS")
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("HCS")
dbSetOrder(1)
lFound := dbSeek(xFilial("ACS") + ACS->ACS_CODREG)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

HCS->HCS_FILIAL := xFilial("ACS")
HCS->HCS_ID := cId
HCS->HCS_CODREG := ACS->ACS_CODREG
HCS->HCS_DESCRI := ACS->ACS_DESCRI
HCS->HCS_CODCLI := ACS->ACS_CODCLI
HCS->HCS_LOJA := ACS->ACS_LOJA
HCS->HCS_INTR := cIntr
HCS->HCS_VER := nMaxVer := HHGenericUpd(, "HCS")
HCS->(MsUnlock())
HCS->(dbCommit())

HHAtuCtr(, "HCS", nMaxVer)
dbSelectArea(cAlias)
Return .T.


User Function HHACT(cCpo,nOper)
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HCT")
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("HCT")
dbSetOrder(1)

lFound := dbSeek(xFilial("ACT") + ACT->ACT_CODREG+ACT->ACT_ITEM)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

HCT->HCT_FILIAL := xFilial("ACT")
HCT->HCT_ID := cId
HCT->HCT_CODREG := ACT->ACT_CODREG
HCT->HCT_ITEM := ACT->ACT_ITEM
HCT->HCT_CODTAB := ACT->ACT_CODTAB
HCT->HCT_CONDPG := ACT->ACT_CONDPG
HCT->HCT_FORMPG := ACT->ACT_FORMPG
HCT->HCT_TPRGNG := ACT->ACT_TPRGNG
HCT->HCT_INTR := cIntr
HCT->HCT_VER  := nMaxVer := HHGenericUpd(, "HCT")
HCT->(MsUnlock())
HCT->(dbCommit())
HHAtuCtr(, "HCT", nMaxVer)
dbSelectArea(cAlias)
Return .T.


User Function HHACO(cCpo,nOper)  //OK
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HCO")
Local nMaxVer := 0  
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("HCO")
dbSetOrder(1)
lFound := dbSeek(xFilial("ACO") + ACO->ACO_CODREG)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

HCO->HCO_FILIAL := xFilial("ACO")
HCO->HCO_ID := cId
HCO->HCO_CODREG := ACO->ACO_CODREG
HCO->HCO_DESCRI := ACO->ACO_DESCRI
HCO->HCO_CODCLI := ACO->ACO_CODCLI
HCO->HCO_LOJA := ACO->ACO_LOJA
HCO->HCO_CODTAB := ACO->ACO_CODTAB
HCO->HCO_CONDPG := ACO->ACO_CONDPG
HCO->HCO_FORMPG := ACO->ACO_FORMPG
HCO->HCO_FAIXA := ACO->ACO_FAIXA
HCO->HCO_MOEDA := ACO->ACO_MOEDA
HCO->HCO_PERDES := ACO->ACO_PERDES
HCO->HCO_CFAIXA := ACO->ACO_CFAIXA
HCO->HCO_INTR := cIntr
HCO->HCO_VER := nMaxVer := HHGenericUpd(, "HCO")
HCO->(MsUnlock())
HCO->(dbCommit())
HHAtuCtr(, "HCO", nMaxVer)
dbSelectArea(cAlias)
Return .T.

User Function HHACP(cCpo,nOper)  //OK
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HCP")
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf
 
dbSelectArea("HCP")
dbSetOrder(1)
lFound := dbSeek(xFilial("ACP") + ACP->ACP_CODREG+ACP->ACP_ITEM)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

HCP->HCP_FILIAL := xFilial("ACP")
HCP->HCP_ID := cId
HCP->HCP_CODREG := ACP->ACP_CODREG
HCP->HCP_ITEM := ACP->ACP_ITEM
HCP->HCP_CODPRO := ACP->ACP_CODPRO
HCP->HCP_GRUPO := ACP->ACP_GRUPO
HCP->HCP_PERDES := ACP->ACP_PERDES
HCP->HCP_FAIXA := ACP->ACP_FAIXA
HCP->HCP_CFAIXA := ACP->ACP_CFAIXA
HCP->HCP_INTR := cIntr
HCP->HCP_VER  := nMaxVer := HHGenericUpd(, "HCP")
HCP->(MsUnlock())
HCP->(dbCommit())
HHAtuCtr(, "HCP", nMaxVer)
dbSelectArea(cAlias)
Return .T.


User Function HHSM0(cCpo,nOper) //OK
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HM0")
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("HM0")
dbSetOrder(1)
lFound := dbSeek(cId + SM0->M0_CODIGO+SM0->M0_CODFIL)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

HM0->HM0_ID := cId
HM0->HM0_COD     := SM0->M0_CODIGO
HM0->HM0_FILIAL  := SM0->M0_CODFIL
HM0->HM0_NOME    := SM0->M0_NOME
HM0->HM0_NOMCOM  := SM0->M0_NOMECOM
HM0->HM0_ENDCOB  := SM0->M0_ENDCOB
HM0->HM0_BAICOB  := SM0->M0_BAIRCOB
HM0->HM0_CIDCOB  := SM0->M0_CIDCOB
HM0->HM0_ESTCOB  := SM0->M0_ESTCOB
HM0->HM0_CEPCOB  := SM0->M0_CEPCOB
HM0->HM0_CGC     := SM0->M0_CGC
HM0->HM0_INSC    := SM0->M0_INSC
HM0->HM0_TEL     := SM0->M0_TEL
HM0->HM0_EMP     := SM0->M0_CODIGO
HM0->HM0_INTR    := cIntr
HM0->HM0_VER     := nMaxVer := HHGenericUpd(, "HM0")
HM0->(MsUnlock())
HM0->(dbCommit())

HHAtuCtr(, "HM0", nMaxVer)
dbSelectArea(cAlias)
Return .T.

User Function HHSA3(cCpo,nOper) // OK
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HA3", "SA3")
Local nMaxVer := 0

// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("HA3")
dbSetOrder(1)
lFound := dbSeek(xFilial("SA3") + cId + SA3->A3_COD)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

HA3->HA3_FILIAL := xFilial("SA3")
HA3->HA3_ID := cId
HA3->HA3_COD := SA3->A3_COD
HA3->HA3_NREDUZ := SA3->A3_NREDUZ
HA3->HA3_COMISS := SA3->A3_COMIS
//HA3->HA3_SALDO := SA3->A3_SALDO
HA3->HA3_SENHA := SA3->A3_SENHA
HA3->HA3_MSGVEN := SA3->A3_MENS1
HA3->HA3_MSGEMP := SA3->A3_MENS2
//HA3->HA3_MSGDIA := SA3->A3_MSGDIA
HA3->HA3_PEDINI := If(Empty(SA3->A3_PEDINI), "000000", SA3->A3_PEDINI)
HA3->HA3_PEDFIM := If(Empty(SA3->A3_PEDFIM), "999999", SA3->A3_PEDFIM)
HA3->HA3_CLIINI := If(Empty(SA3->A3_CLIINI), "000000", SA3->A3_CLIINI)
HA3->HA3_CLIFIM := If(Empty(SA3->A3_CLIFIM), "999999", SA3->A3_CLIFIM)
HA3->HA3_PROPED := SA3->A3_PROXPED
HA3->HA3_PROCLI := SA3->A3_PROXCLI
HA3->HA3_INTR := cIntr
HA3->HA3_VER := nMaxVer := HHGenericUpd(SA3->A3_COD, "HA3")
HA3->(MsUnlock())
HA3->(dbCommit())

// Atualiza a tabela HHCTR
HHAtuCtr(SA3->A3_COD, "HA3", nMaxVer)

dbSelectArea(cAlias)
Return .T.


User Function HHSA1(cCpo,nOper) //OK
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HA1", "SA1")
Local nMaxVer := 0
Local lExcCli := .F.
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	lExcCli := .T.
	If !lExcCli
		Return .T.
	EndIf
EndIf

If OLDSA1->A1_VEND != cId .Or. lExcCli
	If HA1->(dbSeek(xFilial("SA1") + OLDSA1->A1_VEND + SA1->A1_COD+SA1->A1_LOJA))	
		RecLock("HA1", .F.)
		HA1->HA1_INTR := "E"
		HA1->HA1_VER := nMaxVer := HHGenericUpd(OLDSA1->A1_VEND, "HA1")
		HA1->(MsUnlock())
		HA1->(dbCommit())
		HHAtuCtr(OLDSA1->A1_VEND, "HA1", nMaxVer)
	EndIf
	If lExcCli
		Return .T.
	EndIf
EndIf


dbSelectArea("HA1")
dbSetOrder(1)

lFound := HA1->(dbSeek(xFilial("SA1") + cId + SA1->A1_COD+SA1->A1_LOJA))

ChkIntr(nOper, @cIntr, Alias(), lFound)

RecLock(Alias(), !lFound)

HA1->HA1_FILIAL := xFilial("SA1")
HA1->HA1_ID     := cId
HA1->HA1_COD    := SA1->A1_COD
HA1->HA1_LOJA   := SA1->A1_LOJA
HA1->HA1_CGC    := SA1->A1_CGC
HA1->HA1_NOME   := SA1->A1_NOME
HA1->HA1_NREDUZ := SA1->A1_NREDUZ
HA1->HA1_TIPO   := SA1->A1_TIPO
HA1->HA1_END    := SA1->A1_END
HA1->HA1_MUN    := SA1->A1_MUN
HA1->HA1_EST    := SA1->A1_EST
HA1->HA1_BAIRRO := SA1->A1_BAIRRO
HA1->HA1_CEP    := SA1->A1_CEP
HA1->HA1_TEL    := SA1->A1_TEL
HA1->HA1_FAX    := SA1->A1_FAX
HA1->HA1_INSCR  := SA1->A1_INSCR
HA1->HA1_INSCRM := SA1->A1_INSCRM
HA1->HA1_VEND := SA1->A1_VEND
HA1->HA1_REGIAO := SA1->A1_REGIAO
HA1->HA1_TRANSP := SA1->A1_TRANSP
HA1->HA1_TPFRET := SA1->A1_TPFRET
HA1->HA1_COND := SA1->A1_COND
HA1->HA1_RISCO := SA1->A1_RISCO
HA1->HA1_LC := SA1->A1_LC
HA1->HA1_VENCLC := SA1->A1_VENCLC
HA1->HA1_MCOMPR := SA1->A1_MCOMPRA
HA1->HA1_METR := SA1->A1_METR
HA1->HA1_MSALDO := SA1->A1_MSALDO
HA1->HA1_NROCOM := SA1->A1_NROCOM
HA1->HA1_PRICOM := SA1->A1_PRICOM
HA1->HA1_ULTCOM := SA1->A1_ULTCOM
HA1->HA1_ULTVIS := SA1->A1_ULTVIS
HA1->HA1_NROPAG := SA1->A1_NROPAG
HA1->HA1_SALDUP := SA1->A1_SALDUP
HA1->HA1_SALPDL := SA1->A1_SALPEDL
HA1->HA1_ATR := SA1->A1_ATR
HA1->HA1_VACUM := SA1->A1_VACUM
HA1->HA1_SALPED := SA1->A1_SALPED
HA1->HA1_TITPRO := SA1->A1_TITPROT
HA1->HA1_DTULTI := SA1->A1_DTULTIT
HA1->HA1_CHQDEV := SA1->A1_CHQDEVO
HA1->HA1_DTULCH := SA1->A1_DTULCHQ
HA1->HA1_MATR := SA1->A1_MATR
HA1->HA1_MAIDUP := SA1->A1_MAIDUPL
HA1->HA1_TABELA := SA1->A1_TABELA
HA1->HA1_PAGATR := SA1->A1_PAGATR
HA1->HA1_RG := SA1->A1_RG
HA1->HA1_DTNASC := SA1->A1_DTNASC
HA1->HA1_EMAIL := SA1->A1_EMAIL
HA1->HA1_STATUS := "P"
HA1->HA1_FLGVIS := ""
HA1->HA1_OCO := ""
HA1->HA1_CNDFIX := If(SA1->(FieldPos("A1_CNDFIX"))>0, SA1->A1_CNDFIX,2)
HA1->HA1_FORPAG := If(SA1->(FieldPos("A1_FORPAG"))>0, SA1->A1_FORPAG,"")
HA1->HA1_INTR := cIntr
HA1->HA1_VER := nMaxVer := HHGenericUpd(SA1->A1_VEND, "HA1")
HA1->(MsUnlock())
HA1->(dbCommit())

HHAtuCtr(SA1->A1_VEND, "HA1", nMaxVer)

dbSelectArea(cAlias)
Return .T.

User Function HHAC8(cCpo,nOper)  // OK
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HU5", "SA1")
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("SU5")
dbSetorder(1)
If dbSeek(xFilial("SU5")+AC8->AC8_CODCON) .And. SU5->U5_ATIVO = "1"
	dbSelectArea("HU5")
	dbSetOrder(1)
	lFound := dbSeek(xFilial("SU5") + cId + SA1->A1_COD+SA1->A1_LOJA+SU5->U5_CODCONT)

	ChkIntr(nOper, @cIntr, Alias(), lFound)
	RecLock(Alias(), !lFound)

	HU5->HU5_FILIAL := xFilial("SU5")
	HU5->HU5_ID := cId
	HU5->HU5_CLIENT := SA1->A1_COD
	HU5->HU5_LOJA := SA1->A1_LOJA
	HU5->HU5_CODCON := SU5->U5_CODCONT
	HU5->HU5_CONTAT := SU5->U5_CONTAT
	HU5->HU5_CPF := SU5->U5_CPF
	HU5->HU5_FUNCAO := SU5->U5_FUNCAO
	HU5->HU5_FONE := SU5->U5_FONE
	HU5->HU5_CEL := SU5->U5_CELULAR
	HU5->HU5_EMAIL := SU5->U5_EMAIL
	HU5->HU5_DTNASC := CtoD("  /  /  ")
	HU5->HU5_RG := ""
	HU5->HU5_STATUS := "P"
	HU5->HU5_INTR := cIntr
	HU5->HU5_VER := nMaxVer := HHGenericUpd(SA1->A1_VEND, "HU5")
	HU5->(MsUnlock())
	HU5->(dbCommit())

	HHAtuCtr(SA1->A1_VEND, "HU5", nMaxVer)
EndIf		
dbSelectArea(cAlias)
Return .T.

User Function HHSE4(cCpo,nOper)  // OK
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HE4")
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

If ((ExistBlock("PLMCND01")))
	lOkCnd := ExecBlock("PLMCND01",.F.,.F.)
	If !lOkCnd
		dbSelectArea(cAlias)	
		Return .T.
	EndIf
EndIf

dbSelectArea("HE4")
dbSetOrder(1)
lFound := dbSeek(xFilial("SE4") + cId + SE4->E4_CODIGO)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

HE4->HE4_FILIAL := xFilial("SE4")
HE4->HE4_ID := cId
HE4->HE4_CODIGO := SE4->E4_CODIGO
HE4->HE4_DESCRI  := SE4->E4_DESCRI
HE4->HE4_INTR    := cIntr
HE4->HE4_VER    := nMaxVer := HHGenericUpd(, "HE4")
HE4->(MsUnlock())
HE4->(dbCommit())
HHAtuCtr(, "HE4", nMaxVer)
dbSelectArea(cAlias)
Return .T.


User Function HHSF4(cCpo,nOper)  // OK
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HF4")
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

// Devem ser enviados os TES de Saída
If Val(SF4->F4_CODIGO) < 501
	dbSelectArea(cAlias)
	Return .T.
EndIf

If ((ExistBlock("PLMTES01")))
	lOkTes := ExecBlock("PLMTES01",.F.,.F.)
	If !lOkTes
		dbSelectArea(cAlias)
		Return .T.
	EndIf
EndIf

dbSelectArea("HF4")
dbSetOrder(1)
lFound := dbSeek(xFilial("SF4") + cId + SF4->F4_CODIGO)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

HF4->HF4_FILIAL := xFilial("SF4")
HF4->HF4_ID := cId
HF4->HF4_CODIGO := SF4->F4_CODIGO
HF4->HF4_TEXTO  := SF4->F4_TEXTO
HF4->HF4_INTR    := cIntr
HF4->HF4_VER    := nMaxVer := HHGenericUpd(, "HF4")
HF4->(MsUnlock())
HF4->(dbCommit())

HHAtuCtr(, "HF4", nMaxVer)

dbSelectArea(cAlias)
Return .T.

User Function HHSE1(cCpo,nOper)  // OK
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HE1", "SE1")
Local nMaxVer := 0
//ConOut("HHSE1 - 1 - " + Time())
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

If SE1->E1_SALDO > 0
	dbSelectArea("HE1")
	dbSetOrder(1)
	lFound := dbSeek(xFilial("SE1") + cId + SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
	
	ChkIntr(nOper, @cIntr, Alias(), lFound)
	RecLock(Alias(), !lFound)

	HE1->HE1_FILIAL := xFilial("SE1")
	HE1->HE1_ID := cId
	HE1->HE1_CLI := SE1->E1_CLIENTE
	HE1->HE1_LOJA := SE1->E1_LOJA
	HE1->HE1_TIPO := SE1->E1_TIPO
	HE1->HE1_EMISS := SE1->E1_EMISSAO
	HE1->HE1_VENCTO := SE1->E1_VENCTO
	HE1->HE1_SALDO := SE1->E1_SALDO
	HE1->HE1_NUM := SE1->E1_NUM
	HE1->HE1_PARCEL := SE1->E1_PARCELA
	HE1->HE1_INTR := cIntr
	HE1->HE1_VER := nMaxVer := HHGenericUpd(SE1->E1_VEND1, "HE1")
	HE1->(MsUnlock())
	HE1->(dbCommit())
	
	HHAtuCtr(SE1->E1_VEND1, "HE1", nMaxVer)
EndIf		
dbSelectArea(cAlias)
//ConOut("HHSE1 - 2 - " + Time())
Return .T.



User Function HHSB1(cCpo,nOper)  //OK
Local cIntr := ""
Local cAlias := Alias()
Local cTipProd := GetMv("MV_PLMTPPR",, "PA")
//Local cValEst     := GetMv("MV_PLVLEST",,"T")   // T = valor do Estoque, F = Posicao
//Local cLocalEst   := GetMv("MV_PLLCEST",,"T")   // T = Todos os Almoxarifados, P = Local Padrao
//Local cEst := ""
//Local nSaldo := 0
Local cId := HHCheckID("HB1")
Local lOkPrd := .F.
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

//Local PUALIAS := POpenUser()
///ConOut("TRIGGER SB1")
If !SB1->B1_TIPO $ cTipProd
	dbSelectArea(cAlias)
	Return .T.
EndIf

If ((ExistBlock("PLMPRD03")))
	lOkPrd := ExecBlock("PLMPRD03",.F.,.F.)
	If !lOkPrd
		dbSelectArea(cAlias)
		Return .T.
	EndIf
EndIf

dbSelectArea("HB1")
dbSetOrder(1)
lFound := dbSeek(xFilial("SB1") + cId + SB1->B1_COD)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

HB1->HB1_FILIAL := xFilial("SB1")
HB1->HB1_ID     := cId
HB1->HB1_GRUPO  := SB1->B1_GRUPO
HB1->HB1_COD    := SB1->B1_COD
HB1->HB1_DESC   := SB1->B1_DESC
HB1->HB1_UM     := SB1->B1_UM
HB1->HB1_PICM   := SB1->B1_PICM
HB1->HB1_IPI    := SB1->B1_IPI
HB1->HB1_ALQISS := SB1->B1_ALIQISS
HB1->HB1_QE     := SB1->B1_PE
HB1->HB1_COMIS  := SB1->B1_COMIS
HB1->HB1_CODBAR := SB1->B1_CODBAR
HB1->HB1_LOCPAD := SB1->B1_LOCPAD
HB1->HB1_EST    := ""
HB1->HB1_TS     := SB1->B1_TS
HB1->HB1_PRV1   := SB1->B1_PRV1
HB1->HB1_DESMAX := 0 //SB1->B1_DESCMAX
HB1->HB1_SEGUM  := SB1->B1_SEGUM
HB1->HB1_PBRUTO := SB1->B1_PESBRU
HB1->HB1_TIPCON := SB1->B1_TIPCONV
HB1->HB1_CONV   := SB1->B1_CONV
HB1->HB1_INTR   := cIntr
HB1->HB1_VER    := nMaxVer := HHGenericUpd(, "HB1")
HB1->(MsUnlock())
HB1->(dbCommit())

HHAtuCtr(, "HB1", nMaxVer)

dbSelectArea(cAlias)
Return .T.


User Function HHDA0(cCpo,nOper)  //OK
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HTC")
Local lOkTab := .T.
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

If DA0->DA0_ATIVO = "1" .And. (!Empty(DA0->DA0_DATATE) .Or. DA0->DA0_DATATE <= dDatabase)
	If ((ExistBlock("HANHPR02")))
		lOkTab := ExecBlock("HANHPR02",.F.,.F.)
		If !lOkTab
			dbSelectArea(cAlias)		
			Return .T.
		EndIf
	EndIf

	dbSelectArea("HTC")
	dbSetOrder(1)
	lFound := dbSeek(xFilial("DA0") + cId + DA0->DA0_CODTAB)
	
	ChkIntr(nOper, @cIntr, Alias(), lFound)
	RecLock(Alias(), !lFound)

	HTC->HTC_FILIAL := xFilial("DA0")
	HTC->HTC_ID := cId
	HTC->HTC_TAB := DA0->DA0_CODTAB
	HTC->HTC_DESCRI := DA0->DA0_DESCRI
	HTC->HTC_COND := DA0->DA0_CONDPG
	HTC->HTC_VER := nMaxVer := HHGenericUpd(, "HTC")
	HTC->HTC_INTR := cIntr
	HTC->(MsUnlock())
	HTC->(dbCommit())

	HHAtuCtr(, "HTC", nMaxVer)
EndIf
dbSelectArea(cAlias)
Return .T.

User Function HHDA1(cCpo,nOper)  // OK
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HPR")
Local lOkTab := .T.
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1") + DA1->DA1_CODPRO))

dbSelectArea("HPR")
dbSetOrder(1)
lFound := dbSeek(xFilial("DA1") + cId + DA1->DA1_CODPRO + DA1->DA1_CODTAB)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

If DA1->DA1_ATIVO = "1" .And. (Empty(DA1->DA1_DATVIG) .Or. DA1->DA1_DATVIG <= dDatabase)
	If ((ExistBlock("HANHPR02")))
		lOkTab := ExecBlock("HANHPR02",.F.,.F.)
		If !lOkTab
			dbSelectArea(cAlias)
			Return .T.
		EndIf
	EndIf

	HPR->HPR_FILIAL := xFilial("DA1")
	HPR->HPR_ID     := cId
	HPR->HPR_GRUPO  := SB1->B1_GRUPO
	HPR->HPR_PROD   := DA1->DA1_CODPRO
	HPR->HPR_TAB    := DA1->DA1_CODTAB
	HPR->HPR_UNI    := DA1->DA1_PRCVEN
	HPR->HPR_DESMAX := If(DA1->(FieldPos("DA1_DESMAX")) > 0, DA1->DA1_DESMAX, 0)
	HPR->HPR_VER    := nMaxVer := HHGenericUpd(, "HPR")
	HPR->HPR_INTR   := cIntr
	HPR->(MsUnlock())
	HPR->(dbCommit())

	HHAtuCtr(, "HPR", nMaxVer)
EndIf
dbSelectArea(cAlias)
Return .T.

User Function HHSBM(cCpo,nOper)  //OK
Local cIntr := ""
Local cAlias := Alias()
Local cQuery := ""
Local cTipProd    := GetMv("MV_PLMTPPR",,"PA")
Local cLista := ""
Local cId := HHCheckID("HBM")
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

cLista   := "'"
cTipProd := AllTrim(cTipProd) + ","
nPos     := At(",", cTipProd)
While nPos > 0
	cLista   += Substr(cTipProd, 1, nPos - 1) + "','"
	cTipProd := Substr(cTipProd, nPos + 1, Len(cTipProd))
	nPos := At(",", cTipProd)
End
cLista := Subs(cLista, 1, Len(cLista)-2)
    
cQuery := "SELECT COUNT(B1_COD) QTDREC FROM " + RetSqlName("SB1")
cQuery += " WHERE B1_GRUPO = '" + SBM->BM_GRUPO + "' AND B1_TIPO IN (" + cLista + ")" 

cQuery := ChangeQuery(cQuery)
			
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QTDPROD",.F.,.T.)
nQtdRec := QTDPROD->QTDREC
QTDPROD->(dbCloseArea())

If nQtdRec > 0
	dbSelectArea("HBM")
	dbSetOrder(1)

	lFound := dbSeek(xFilial("SBM") + cId + SBM->BM_GRUPO)
	
	ChkIntr(nOper, @cIntr, Alias(), lFound)
	RecLock(Alias(), !lFound)

	HBM->HBM_FILIAL := xFilial("SBM")
	HBM->HBM_ID     := cId
	HBM->HBM_GRUPO  := SBM->BM_GRUPO
	HBM->HBM_DESC   := SBM->BM_DESC
	HBM->HBM_INTR   := cIntr
	HBM->HBM_VER := nMaxVer := HHGenericUpd(, "HBM")
	HBM->(MsUnlock())
	HBM->(dbCommit())

	HHAtuCtr(, "HBM", nMaxVer)
EndIf 
dbSelectArea(cAlias)
Return .T.


User Function HHSCT(cCpo,nOper)  
Local cIntr := ""
Local cAlias := Alias()
Local cQuery := ""       
Local cId := HHCheckID("HMT", "SCT")
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

If !Empty(SCT->CT_VEND)
	cQuery :=  "SELECT SUM(SD2.D2_QUANT) QTD, SUM(SD2.D2_TOTAL) VLR FROM " + RetSqlName("SD2") + " SD2 "
	cQuery += "WHERE SD2.D2_COD = '" + SCT->CT_PRODUTO + "' AND "
	cQuery += "SUBSTRING(SD2.D2_EMISSAO,1,6) = '" + Str(Year( SCT->CT_DATA ),4 )  + StrZero(Month(SCT->CT_DATA),2)  + "'"

	cQuery := ChangeQuery(cQuery)
				
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"HHMETA",.F.,.T.)

	/// ??????????? Acertar Indice
	dbSelectArea("HMT")
	dbSetOrder(1)
	lFound := dbSeek(xFilial("SCT") + cId + SCT->CT_GRUPO)
	
	ChkIntr(nOper, @cIntr, Alias(), lFound)
	RecLock(Alias(), !lFound)

	HMT->HMT_FILIAL := xFilial("SCT")
	HMT->HMT_ID := cId
	HMT->HMT_DATA := Str(Year( SCT->CT_DATA ),4 )  + StrZero(Month(SCT->CT_DATA),2) 
	HMT->HMT_GRUPO := SCT->CT_GRUPO
	HMT->HMT_PROD := SCT->CT_PRODUTO
	HMT->HMT_QTD := SCT->CT_QUANT
	HMT->HMT_QTDR := HHMETA->QTD
	HMT->HMT_VALOR := SCT->CT_VALOR
	HMT->HMT_VALORR := HHMETA->VLR
	HMT->HMT_INTR := cIntr
	HMT->HMT_VER := nMaxVer := HHGenericUpd(SCT->CT_VEND, "HMT")
	HMT->(MsUnlock())
	HMT->(dbCommit())
	
	HHMETA->(dbCloseArea())

	HHAtuCtr(SCT->CT_VEND, "HMT", nMaxVer)
EndIf
dbSelectArea(cAlias)
Return .T.
/*
User Function HHAD7(cCpo,nOper)
Local cIntr := ""
Local aDow  := {"Dom","Seg","Ter","Qua","Qui","Sex","Sab"}
Local nRecRota := -1
Local nDay := 0
Local cPercur := ""
Local cRota   := ""
Local cQuery := ""
Local cAlias := Alias()
Local cId := HHCheckID("HD7", "AD7")

If !Empty(AD7->AD7_VEND)
	nDay := Dow(AD7->AD7_DATA)

	cPercur := StrZero(nDay,6)
	cRota   := StrZero(nDay,6)

	dbSelectArea("HD7")
	dbSetOrder(3)
	lFound := dbSeek(cFilAnt + cId + DtoS(AD7->AD7_DATA) + AD7->AD7_CODCLI + AD7->AD7_LOJA)

	cQuery := "SELECT MAX(HD7_ORDEM) ORDEM FROM " + RetSqlName("HD7") + " WHERE HD7_ID = '" + AD7->AD7_VEND + "' AND HD7_DATA = '" + DtoS(AD7->AD7_DATA) + "'"
	cQuery := ChangeQuery(cQuery)
			
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"HD7ORD",.F.,.T.)	
	//nOrdem := Val(HD7ORD->ORDEM)
	If HD7ORD->(Eof())
		nOrdem := 1
	Else
		nOrdem := Val(HD7ORD->ORDEM) + 1
	EndIf
	HD7ORD->(dbCloseArea())

	ChkIntr(nOper, @cIntr, Alias(), lFound)
	RecLock(Alias(), !lFound)

	HD7->HD7_FILIAL := cFilAnt
	HD7->HD7_ID := cId
	HD7->HD7_PERCUR := cPercur
	HD7->HD7_ROTA :=  cRota
	//HD7->HD7_DESPER := aDow[nDay] + "-" + Dtoc( AD7->AD7_DATA)
	HD7->HD7_ORDEM := StrZero(nOrdem,4)
	HD7->HD7_CLI := AD7->AD7_CODCLI
	HD7->HD7_LOJA := AD7->AD7_LOJA
	HD7->HD7_DATA := AD7->AD7_DATA
	HD7->HD7_FLGVIS := ""
	HD7->HD7_OCO := ""
	//HD7->HD7_DT :=
	HD7->HD7_INTR := cIntr
	HD7->HD7_VER := nMaxVer := HHGenericUpd(AD7->AD7_VEND, "HD7")
	HD7->(MsUnlock())
	HD7->(dbCommit())

//	PUpdHHCtr(AD7->AD7_VEND, Alias(), 0, .F.)

	If nOper = VM_DELETE
		cQuery := "SELECT COUNT(HD7_ORDEM) ORDEM FROM " + RetSqlName("HD7") + " WHERE HD7_ID = '" + AD7->AD7_VEND + "' AND HD7_DATA = '" + DtoS(AD7->AD7_DATA) + "' AND HD7_INTR <> 'E'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"HD7ORD",.F.,.T.)
		nRecRota := HD7ORD->ORDEM
		HD7ORD->(dbCloseArea())
	EndIf

	If  cIntr $ "IA" .OR. nRecRota = 0
		dbSelectArea("HRT")
		dbSetOrder(1)
		If !dbSeek(cFilAnt + cId + AD7->AD7_VEND+cPercur+cRota)
			RecLock("HRT",.T.)
		Else
			RecLock("HRT",.F.)
		EndIf
		HRT->HRT_FILIAL := cFilAnt
		HRT->HRT_ID := cId
		HRT->HRT_PERCUR := cRota
		HRT->HRT_ROTA   := cRota
		HRT->HRT_DESCR  := aDow[nDay] + " - " + Dtoc(AD7->AD7_DATA)
		HRT->HRT_INTR  := cIntr
		HRT->(MsUnlock())
		HRT->(dbCommit())
	EndIf
EndIf

/////  CRIAR ROTA 
dbSelectArea(cAlias)
Return .T.
*/
User Function HHAD7(cCpo,nOper)
Local cIntr    := ""
Local aDow     := {"Dom","Seg","Ter","Qua","Qui","Sex","Sab"}
Local nRecRota := -1
Local nDay     := 0
Local cPercur  := ""
Local cRota    := ""
Local cQuery   := ""
Local cQuery1  := ""
Local cAlias   := Alias()
Local cId      := HHCheckID("HD7", "AD7")
Local cGetDb   := Upper(TcGetDb())
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

If Empty(AD7->AD7_VEND)
	dbSelectArea(cAlias)
	Return .T.
EndIf

nDay := Dow(AD7->AD7_DATA)
 
dbSelectArea("HD7")
dbSetOrder(3)
lFound := dbSeek(xFilial("AD7") + cId + DtoS(AD7->AD7_DATA) + AD7->AD7_CODCLI + AD7->AD7_LOJA)

If cGetDb $ "MSSQL"
	cQuery := "SELECT TOP 1 HD7_ORDEM ORDEM,HD7_ROTA ROTA FROM " + RetSqlName("HD7") 
Else
	cQuery := "SELECT HD7_ORDEM ORDEM,HD7_ROTA ROTA FROM " + RetSqlName("HD7") 
Endif
cQuery += " WHERE HD7_ID = '" + AD7->AD7_VEND + "' AND HD7_DATA = '" + DtoS(AD7->AD7_DATA) + "'"
If cGetDb $ "ORACLE"
	cQuery += "AND Rownum <=1 "
EndIf
cQuery += " ORDER BY HD7_ROTA DESC"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"HD7ORD",.F.,.T.) 
 
If HD7ORD->(Eof())
	If cGetDb $ "MSSQL"
  		cQuery1 := "SELECT TOP 1 HRT_ROTA ROTA FROM " + RetSqlName("HRT") + " WHERE HRT_ID = '" + AD7->AD7_VEND + "'"
	Else
		cQuery1 := "SELECT HRT_ROTA ROTA FROM " + RetSqlName("HRT") + " WHERE HRT_ID = '" + AD7->AD7_VEND + "'"
	EndIf
	If cGetDb $ "ORACLE"
		cQuery1 += "AND Rownum <=1 "
	EndIf	
	cQuery1 += " ORDER BY HRT_ROTA DESC"
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery1),"HRTNEW",.F.,.T.) 
	cQuery1 := ChangeQuery(cQuery1)
	If HRTNEW->(Eof())
		cRota := "000001"
	Else
		cRota := StrZero(Val(HRTNEW->ROTA) + 1,6)
	Endif  
	cPercur := cRota
	nOrdem := 1
	HRTNEW->(dbCloseArea())
Else
	cRota := HD7ORD->ROTA
	cPercur := cRota
	nOrdem := Val(HD7ORD->ORDEM) + 1
EndIf
HD7ORD->(dbCloseArea())

dbSelectArea("HD7")
ChkIntr(nOper, @cIntr, "HD7", lFound)
RecLock("HD7", !lFound)
 
HD7->HD7_FILIAL   := xFilial("AD7")
HD7->HD7_ID       := cId
HD7->HD7_PERCUR   := cPercur
HD7->HD7_ROTA     := cRota
//HD7->HD7_DESPER   := aDow[nDay] + "-" + Dtoc( AD7->AD7_DATA)
HD7->HD7_ORDEM    := StrZero(nOrdem,4)
HD7->HD7_CLI      := AD7->AD7_CODCLI
HD7->HD7_LOJA     := AD7->AD7_LOJA
HD7->HD7_DATA     := AD7->AD7_DATA
HD7->HD7_FLGVIS   := ""
HD7->HD7_OCO      := ""
//HD7->HD7_DT     :=
HD7->HD7_INTR     := cIntr
HD7->HD7_VER      := nMaxVer := HHGenericUpd(AD7->AD7_VEND, "HD7")

HD7->(MsUnlock())
HD7->(dbCommit())
 
HHAtuCtr(AD7->AD7_VEND, "HD7", nMaxVer)
 
If nOper = VM_DELETE
	cQuery := "SELECT COUNT(HD7_ORDEM) ORDEM FROM " + RetSqlName("HD7") + " WHERE HD7_ID = '" + AD7->AD7_VEND + "' AND HD7_DATA = '" + DtoS(AD7->AD7_DATA) + "' AND HD7_INTR <> 'E'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"HD7ORD",.F.,.T.)
	nRecRota := HD7ORD->ORDEM
	HD7ORD->(dbCloseArea())
EndIf

If  cIntr $ "IA" .Or. nRecRota = 0
	dbSelectArea("HRT")
	dbSetOrder(1)
	If !dbSeek(xFilial("AD7") + cId + AD7->AD7_VEND+cPercur+cRota)
		RecLock("HRT",.T.)
	Else
	   RecLock("HRT",.F.)
	EndIf
	HRT->HRT_FILIAL := xFilial("AD7")
  	HRT->HRT_ID     := cId
	HRT->HRT_PERCUR := cRota
	HRT->HRT_ROTA   := cRota
	HRT->HRT_DESCR  := aDow[nDay] + " - " + Dtoc(AD7->AD7_DATA)
	HRT->HRT_INTR   := cIntr
	HRT->(MsUnlock())
	HRT->(dbCommit())
	HHAtuCtr(AD7->AD7_VEND, "HRT", nMaxVer)
EndIf

dbSelectArea(cAlias)
Return .T.


User Function HHSA4(cCpo,nOper)
Local cIntr := ""
Local cAlias := Alias()
Local cId := HHCheckID("HA4")
Local nMaxVer := 0
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("HA4")
dbSetOrder(1)

lFound := dbSeek(xFilial("SA4") + cId + SA4->A4_COD)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

HA4->HA4_FILIAL := xFilial("SA4")
HA4->HA4_ID := cId
HA4->HA4_COD    := SA4->A4_COD
HA4->HA4_NOME := SA4->A4_NOME
HA4->HA4_INTR   := cIntr
HA4->HA4_VER  := nMaxVer := HHGenericUpd(, "HA4")
HA4->(MsUnlock())
HA4->(dbCommit())

HHAtuCtr(, "HA4", nMaxVer)

dbSelectArea(cAlias)
Return .T.


User Function HHSC5(cCpo,nOper)

Local cIntr := ""
Local cAlias := Alias()
Local aStatus := {}
Local aStru := {}
Local cStatus := ""
Local nValPed := 0
Local nValFat := 0
Local nQtdPed     := GetMv("MV_QTPEDPM",,1)  // Quantidade de Pedidos a serem enviados para o Palm
Local cQuery := ""
Local ni := 1
Local nRecsHC5 := 0
Local nRecsHC6 := 0
Local cId := HHCheckID("HC5", "SC5")
Local nMaxVer := 0

// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("HC5")
dbSelectArea("HC6")

If nOper = VM_INSERT
	// Verifica quantos pedido existem no handheld
	cQuery := "SELECT COUNT(*) QTDPED FROM " + RetSqlName("HC5") + " HC5 "
	cQuery += "WHERE HC5.HC5_FILIAL = '" + xFilial("SC5") + "' "
	cQuery += "AND HC5.HC5_CLI = '" + SC5->C5_CLIENTE + "' "
	cQuery += "AND HC5.HC5_LOJA = '" + SC5->C5_LOJACLI + "' "
	cQuery += "AND HC5.HC5_ID = '" + SC5->C5_VEND1 + "' "

	cQuery := ChangeQuery(cQuery)
		
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QTDHHPED",.F.,.F.)	
	nQtdHHPed := QTDHHPED->QTDPED
	QTDHHPED->(dbCloseArea())

	// Apaga os registros mais velhos
	If nQtdHHPed >= nQtdPed
		cQuery := "SELECT HC5_NUM, HC5.HC5_EMISS, HC5.HC5_CLI, HC5.HC5_LOJA FROM " + RetSqlName("HC5") + " HC5 "
		cQuery += "WHERE HC5.HC5_FILIAL = '" + xFilial("SC5") + "' "
		cQuery += "AND HC5.HC5_CLI = '" + SC5->C5_CLIENTE + "' "
		cQuery += "AND HC5.HC5_LOJA = '" + SC5->C5_LOJACLI + "' "
		cQuery += "AND HC5.HC5_ID = '" + cId + "' "
		cQuery += "ORDER BY HC5.HC5_EMISS, HC5.HC5_CLI, HC5.HC5_LOJA"

		cQuery := ChangeQuery(cQuery)

		Memowrite("HC5TRG.txt", cQuery)
				
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"HC5UPD",.F.,.T.)	
		//HC5UPD->(dbGoTop())
		For ni := 1 To nQtdHHPed - (nQtdPed - 1)
			If HC5->(dbSeek(xFilial("SC5") + cId + HC5UPD->HC5_NUM))
				RecLock("HC5", .F.)
				HC5->HC5_INTR := "E"
				HC5->HC5_VER := HHGenericUpd(SC5->C5_VEND1, "HC5")
				HC5->(MsUnlock())  
				HC5->(dbCommit())
			EndIf
			
	 		cDelQuery := "UPDATE " + RetSqlName("HC6") + " SET HC6_INTR = 'E', HC6_VER = "+ Str(HC5->HC5_VER,10,0) + " WHERE HC6_NUM = '" + HC5UPD->HC5_NUM + "'"
			Memowrite("HC6UPD.txt", cDelQuery)
			TCSqlExec(cDelQuery)

			cQuery := "SELECT COUNT(*) QTDPED FROM " + RetSqlName("HC6") + " HC6 "
			cQuery += "WHERE HC6.HC6_FILIAL = '" + xFilial("SC6") + "' "
			cQuery += "AND HC6.HC6_NUM = '" + HC5UPD->HC5_NUM + "' "
			cQuery += "AND HC6.HC6_INTR = 'E' "

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"HC6UPD",.F.,.T.)	
			nRecsHC6 += HC6UPD->QTDPED
			HC6UPD->(dbCloseArea())

			HC5UPD->(dbSkip())
		Next
		HC5UPD->(dbCloseArea())
		nRecsHC5 := nQtdHHPed - (nQtdPed - 1)
		
	EndIf
EndIf

// Verifica Status do Pedido
dbSelectArea("SC6")
dbSetOrder(1)
dbSeek(xFilial("SC6")+SC5->C5_NUM)
While !SC6->(Eof()) .AND. SC6->C6_NUM = SC5->C5_NUM
	If SC6->C6_QTDENT = SC6->C6_QTDVEN
		nPos := aScan(aStatus,{|x| x[1] = "E"})
		If(nPos = 0, aadd(aStatus, {"E", 1}), aStatus[nPos,2] += 1)
	ElseIf SC6->C6_QTDENT != 0 .And. SC6->C6_QTDENT < SC6->C6_QTDVEN
		nPos := aScan(aStatus,{|x| x[1] = "PE"})
		If(nPos = 0, aadd(aStatus, {"PE", 1}), aStatus[nPos,2] += 1)
	Else
   		dbSelectArea("SC9")
	   	dbSetOrder(1)
   		If dbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM)
			If Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLEST) //Item Liberado
				nPos := aScan(aStatus,{|x| x[1] = "L"})
				If(nPos = 0, aadd(aStatus, {"L", 1}), aStatus[nPos,2] += 1)					
			ElseIf(!Empty(SC9->C9_BLCRED) .And. SC9->C9_BLCRED != "10") .And. (!Empty(SC9->C9_BLEST) .And. SC9->C9_BLEST != "10") //Bloqueado por Estoque e Credito
				nPos := aScan(aStatus,{|x| x[1] = "B"})
				If(nPos = 0, aadd(aStatus, {"B", 1}), aStatus[nPos,2] += 1)
			ElseIf !Empty(SC9->C9_BLCRED) .And. SC9->C9_BLCRED != "10"  //Bloqueado por Credito
				nPos := aScan(aStatus,{|x| x[1] = "BC"})
				If(nPos = 0, aadd(aStatus, {"BC", 1}), aStatus[nPos,2] += 1)
			ElseIf !Empty(SC9->C9_BLEST) .And. SC9->C9_BLEST != "10"    //Bloqueado por Estoque
				nPos := aScan(aStatus,{|x| x[1] = "BE"})
				If(nPos = 0, aadd(aStatus, {"BE", 1}), aStatus[nPos,2] += 1)
			EndIf
		Else
   			If SC6->C6_BLQ = "R"
				nPos := aScan(aStatus,{|x| x[1] = "R"})
				If(nPos = 0, aadd(aStatus, {"R", 1}), aStatus[nPos,2] += 1)
   			Else
				nPos := aScan(aStatus,{|x| x[1] = "A"})
				If(nPos = 0, aadd(aStatus, {"A", 1}), aStatus[nPos,2] += 1)
   			EndIf
   		Endif
   	EndIf                     
   	dbSelectArea("SC6")
   	dbSkip()
EndDo
// Ordena Array de Status pela quantidade
aStatus := aSort(aStatus,,,{|x, y| x[2] > y[2]})          	
            	         	
If Len(aStatus) > 0
	If Len(aStatus) = 1
		cStatus := aStatus[1,1]
	Else
		If Left(aStatus[1,1],1) != "P"
			cStatus := "P" + aStatus[1,1]
		Else
			cStatus := aStatus[1,1]
		EndIf
	EndIf            	
EndIf

// Posiciona NF caso exista
If !Empty(SC5->C5_NOTA)
	dbSelectArea("SF2")
	dbSetOrder(1)
	dbSeek(xFilial("SF2")+SC5->C5_NOTA)

	// Calcula Valor Faturado do Pedido
	nValFat := 0
	dbSelectArea("SD2")
	dbSetOrder(8)
	dbSeek(xFilial("SD2")+SC5->C5_NUM)
	While !Eof() .And. xFilial() = xFilial("SD2") .And. SD2->D2_PEDIDO = SC5->C5_NUM
		nValFat += SD2->D2_TOTAL
		SD2->(dbSkip())
	EndDo
EndIf

// Calcula o Total do Pedido
nValPed := 0
dbSelectArea("SC6")
dbSetOrder(1)
dbSeek(xFilial("SC6")+SC5->C5_NUM)
While !Eof() .And. xFilial() = xFilial("SC6") .And. SC6->C6_NUM = SC5->C5_NUM
	nValPed += SC6->C6_VALOR
	SC6->(dbSkip())
EndDo

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)

dbSelectArea("HC5")
dbSetOrder(1)
//lFound := dbSeek(xFilial("SC5") + cId + If(!Empty(SC5->C5_COTACAO),SC5->C5_COTACAO,SC5->C5_NUM))
lFound := dbSeek(xFilial("SC5") + cId + SC5->C5_NUM)
ConOut(xFilial("SC5") + cId + SC5->C5_NUM)
ConOut(lFound)
ConOut(nOper)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

HC5->HC5_FILIAL := xFilial("SC5")
HC5->HC5_ID     := cId
HC5->HC5_COTAC  := If(!Empty(SC5->C5_COTACAO),SC5->C5_COTACAO,SC5->C5_NUM)
HC5->HC5_CLI    := SC5->C5_CLIENTE
HC5->HC5_LOJA   := SC5->C5_LOJACLI
HC5->HC5_TRANSP := SC5->C5_TRANSP
HC5->HC5_TIPO   := SC5->C5_TIPO
HC5->HC5_COND   := SC5->C5_CONDPAG
HC5->HC5_VEND1  := SC5->C5_VEND1
HC5->HC5_MENOTA := SC5->C5_MENNOTA
HC5->HC5_EMISS  := SC5->C5_EMISSAO
HC5->HC5_TAB    := SC5->C5_TABELA
HC5->HC5_STATUS := cStatus
HC5->HC5_TIPOCL := SC5->C5_TIPOCLI
HC5->HC5_ASSINA := ""
HC5->HC5_TPPAG  := ""
HC5->HC5_TPFRET := SC5->C5_TPFRETE
HC5->HC5_NOTA   := SC5->C5_NOTA
HC5->HC5_SERIE  := SC5->C5_SERIE
HC5->HC5_NUM    := SC5->C5_NUM
HC5->HC5_DUPLI  := SF2->F2_DUPL
HC5->HC5_VALOR  := nValPed
HC5->HC5_FAT    := nValFat
HC5->HC5_DTPED  := SF2->F2_EMISSAO
HC5->HC5_QTDITE := 0
HC5->HC5_DESCON := 0
HC5->HC5_FORMPG := If(SC5->(FieldPos("C5_FORMAPG")) <> 0, SC5->C5_FORMAPG, "")
HC5->HC5_INTR   := cIntr
HC5->HC5_VER    := nMaxVer := HHGenericUpd(SC5->C5_VEND1, "HC5")
HC5->(MsUnlock())
HC5->(dbCommit())

HHAtuCtr(SC5->C5_VEND1, "HC5", nMaxVer)

dbSelectArea("SC6")
dbSetOrder(1)
If dbSeek(xFilial("SC6")+SC5->C5_NUM)
	While !SC6->(Eof()) .And. xFilial("SC6") = SC6->C6_FILIAL .And. SC5->C5_NUM = SC6->C6_NUM
		If SC6->C6_QTDENT = 0
	   		dbSelectArea("SC9")
		   	dbSetOrder(1)
		   	If dbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM, .F.)
				If Empty(C9_BLCRED) .And. Empty(C9_BLEST) //Liberado
					cStatus := "L"
	   		    ElseIf (!Empty(C9_BLCRED) .And. C9_BLCRED <> "10") .And. (!Empty(C9_BLEST) .And. C9_BLEST <> "10") //Bloqueado por Estoque e Credito
			   		cStatus := "B"
	   			ElseIf !Empty(C9_BLCRED) .And. C9_BLCRED <> "10"  //Bloqueado por Credito
	   				cStatus := "BC"
		   		ElseIf !Empty(C9_BLEST) .And. C9_BLEST <> "10" //Bloqueado por Estoque
		   			cStatus := "BE"
   				EndIf
	   		Else
   				If SC6->C6_BLQ = "R"
   					cStatus := "R"
   				Else
   					cStatus := "A"
	   			EndIf
   			EndIf		            	
		ElseIf SC6->C6_QTDENT < SC6->C6_QTDVEN
			cStatus := "PE"
		ElseIf SC6->C6_QTDENT = SC6->C6_QTDVEN
			cStatus := "E"
		EndIf

		dbSelectArea("HC6")
		dbSetOrder(1) 
		
		lFound := dbSeek(xFilial("SC6") + cId + SC6->C6_NUM+SC6->C6_ITEM)
		
		ChkIntr(nOper, @cIntr, Alias(), lFound)
		RecLock(Alias(), !lFound)
	
		HC6->HC6_FILIAL := xFilial("SC6")
		HC6->HC6_ID := cId
		HC6->HC6_COTAC := If(!Empty(SC5->C5_COTACAO),SC5->C5_COTACAO,SC5->C5_NUM)
		HC6->HC6_NUM := SC6->C6_NUM
		HC6->HC6_ITEM := SC6->C6_ITEM
		HC6->HC6_PROD := SC6->C6_PRODUTO
		HC6->HC6_GRUPO := SB1->B1_GRUPO
		HC6->HC6_QTDVEN := SC6->C6_QTDVEN
		HC6->HC6_PRCVEN := SC6->C6_PRCVEN
		HC6->HC6_VALOR := SC6->C6_VALOR
		HC6->HC6_QTDLIB := SC6->C6_QTDLIB
		HC6->HC6_ENTREG := SC6->C6_ENTREG
		HC6->HC6_UM := SC6->C6_UM
		HC6->HC6_TES := SC6->C6_TES
		HC6->HC6_LOCAL := SC6->C6_LOCAL
		HC6->HC6_QTDENT := SC6->C6_QTDENT
		HC6->HC6_DESC := SC6->C6_DESCONT
		HC6->HC6_ICMS := 0
		HC6->HC6_IPI := SC6->C6_IPIDEV
		HC6->HC6_TABELA := SC5->C5_TABELA
		HC6->HC6_STATUS := cStatus
		HC6->HC6_BONIF := 0
		HC6->HC6_INTR :=  cIntr
		HC6->HC6_VER := nMaxVer := HHGenericUpd(SC5->C5_VEND1, "HC6")
		HC6->(MsUnlock())
		HC6->(dbCommit())
		SC6->(dbSkip())
	EndDo

	HHAtuCtr(SC5->C5_VEND1, "HC6", nMaxVer)
EndIf
dbSelectArea(cAlias)
//ConOut("HHSC5 - 2 - " + Time())

Return .T.

User Function HHSD2(cCpo,nOper) //OK
Local cIntr := ""
Local cAlias := Alias()
Local cMes := StrZero(Month(dDatabase),2)
Local cAno := Str(Year(dDatabase),4,0)
Local cMesAnt := StrZero(If(Month(dDatabase) - 1=0,12,Month(dDatabase) - 1),2)
Local cAnoAnt := Str(Year(dDatabase) - 1,4,0)
Local cMesNF := ""
Local cAnoNF := ""
Local cVendedor := ""
Local cId := ""
Local nMaxVer := 0
//ConOut("HHSD2 - 1 - " + Time())

dbSelectArea("HCN")

//dbSelectArea("SD2")
//dbSetOrder(3)
//dbSeek(xFilial("SD2")+SF2->F2_DOC)
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+SD2->D2_CLIENTE + SD2->D2_LOJA)
cId := HHCheckID("HCN", "SA1")
cVendedor := SA1->A1_VEND

// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("SF2")
dbSetOrder(1)
dbSeek(xFilial("SF2")+SF2->F2_DOC)

cMesNF := StrZero(Month(SF2->F2_EMISSAO),4)
cAnoNF := Str(Year(SF2->F2_EMISSAO),4,0)

dbSelectArea("HCN")
dbSetOrder(1)
lFound := dbSeek(xFilial("SF2") + cId + SF2->F2_CLIENTE + SF2->F2_LOJA +  SD2->D2_COD)

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)

HCN->HCN_FILIAL := xFilial("SF2")
HCN->HCN_ID := cId
HCN->HCN_CLIENT := SF2->F2_CLIENTE
HCN->HCN_LOJA := SF2->F2_LOJA
HCN->HCN_GRUPO := SD2->D2_GRUPO
HCN->HCN_PROD := SD2->D2_COD
HCN->HCN_ULTQTD := SD2-> D2_QUANT
HCN->HCN_DTULT := SD2-> D2_EMISSAO
HCN->HCN_VLULT  := SD2-> D2_TOTAL
If cIntr = "I"
	If  (cAno+cMes) = (cAnoNF + cMesNF)
		HCN->HCN_MESATU += SD2-> D2_QUANT	
	ElseIf (cAno+cMesAnt) = (cAnoNF + cMesNF)
		HCN->HCN_MESANT += SD2-> D2_QUANT	
	ElseIf (cAnoAnt+cMes) = (cAnoNF + cMesNF)
		HCN->HCN_ANOANT += SD2-> D2_QUANT	
	EndIf
ElseIf cIntr = "A"
/*
    OLDSD2->(dbSetOrder(3))
	If OLDSD2->(dbSeek(xFilial("SD2") + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_COD + SD2->D2_ITEM)
	If  (cAno+cMes) = (cAnoNF + cMesNF)
		HCN->HCN_MESATU -= SD2-> D2_QUANT	
	ElseIf (cAno+cMesAnt) = (cAnoNF + cMesNF)
		HCN->HCN_MESANT -= SD2-> D2_QUANT	
	ElseIf (cAnoAnt+cMes) = (cAnoNF + cMesNF)
		HCN->HCN_ANOANT -= SD2-> D2_QUANT	
	EndIf

	If  (cAno+cMes) = (cAnoNF + cMesNF)
		HCN->HCN_MESATU += SD2-> D2_QUANT	
	ElseIf (cAno+cMesAnt) = (cAnoNF + cMesNF)
		HCN->HCN_MESANT += SD2-> D2_QUANT	
	ElseIf (cAnoAnt+cMes) = (cAnoNF + cMesNF)
		HCN->HCN_ANOANT += SD2-> D2_QUANT	
	EndIf		
	*/
ElseIf cIntr = "E"
	If  (cAno+cMes) = (cAnoNF + cMesNF)
		HCN->HCN_MESATU -= SD2-> D2_QUANT	
	ElseIf (cAno+cMesAnt) = (cAnoNF + cMesNF)
		HCN->HCN_MESANT -= SD2-> D2_QUANT	
	ElseIf (cAnoAnt+cMes) = (cAnoNF + cMesNF)
		HCN->HCN_ANOANT -= SD2-> D2_QUANT	
	EndIf
EndIf
HCN->HCN_INTR := cIntr
HCN->HCN_VER := nMaxVer := HHGenericUpd(SA1->A1_VEND, "HCN")
HCN->(MsUnlock())
HCN->(dbCommit())
HHAtuCtr(SA1->A1_VEND, "HCN", nMaxVer)

dbSelectArea(cAlias)
//ConOut("HHSD2 - 1 - " + Time())
Return .T.

User Function HHSB2(cOper, nOper)
Local cAlias := Alias()
Local cId := HHCheckID("HB2")
Local cIntr := ""
Local lFound := .T.
Local cTipProd := GetMv("MV_PLMTPPR",, "PA")
//Local cValEst     := GetMv("MV_PLVLEST",,"T")   // T = valor do Estoque, F = Posicao
Local cLocalEst   := GetMv("MV_PLLCEST",,"T")   // T = Todos os Almoxarifados, P = Local Padrao
Local nSaldo := 0
Local nSaldoAnt := 0
Local nSaldoAtu := 0
Local nMaxVer := 0
//ConOut("HHSB2 - 1 - " + Time())
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

SB1->(dbSeek(xFilial("SB1")+SB2->B2_COD))

If !(SB1->B1_TIPO $ cTipProd)
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("HB2")
dbSetOrder(1)
lFound := dbSeek(xFilial("SB2") + cId + SB1->B1_COD)
//ConOut("Found HB2 = " + If(lFound,".T.", ".F."))

If cLocalEst = "T"
	nSaldoAnt += SaldoSB2(,,,,,"OLDSB2")
	nSaldoAtu += SaldoSB2()
	nSaldo := HB2->HB2_QTD - nSaldoAnt + nSaldoAtu
Else
	If SB2->B2_LOCAL = SB1->B1_LOCPAD
		nSaldo := SaldoSB2()
	EndIf
EndIf			

ChkIntr(nOper, @cIntr, Alias(), lFound)
RecLock(Alias(), !lFound)
HB2->HB2_FILIAL := xFilial("SB2")
HB2->HB2_ID := cId
HB2->HB2_COD := SB1->B1_COD
HB2->HB2_LOCAL := If(cLocalEst = "T", "", SB1->B1_LOCPAD)
HB2->HB2_DATA := Date()
HB2->HB2_QTD := nSaldo
HB2->HB2_VER   := nMaxVer := HHGenericUpd(, "HB2")
HB2->HB2_INTR   := cIntr
HB2->(MsUnlock())
HB2->(dbCommit())

HHAtuCtr(, "HB2", nMaxVer)
dbSelectArea(cAlias)



//ConOut("HHSB2 - 2 - " + Time())
Return .T.

User Function HHSC9(cOper, nOper)
Local cAlias := Alias()
Local cId := HHCheckID("HC5", "SC5")
Local cIntr := ""
Local cStatus := ""
Local nMaxVer := 0
//ConOut("HHSC9 - 1 - " + Time())
// Validacao do ID, caso "0" nao grava o registro
If cId == "0"
	dbSelectArea(cAlias)
	Return .T.
EndIf

dbSelectArea("HC6")
dbSetOrder(1)
lFound := dbSeek(xFilial("SC6") + cId + SC9->C9_PEDIDO + SC9->C9_ITEM)
If lFound
	ChkIntr(nOper, @cIntr, "HC6", lFound)

	If SC6->C6_QTDENT	= 0
		If Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLEST) //Liberado
			cStatus := "L"
		ElseIf (!Empty(SC9->C9_BLCRED) .And. SC9->C9_BLCRED <> "10") .And. (!Empty(SC9->C9_BLEST) .And. SC9->C9_BLEST <> "10") //Bloqueado por Estoque e Credito
			cStatus := "B"
		ElseIf !Empty(SC9->C9_BLCRED) .And. SC9->C9_BLCRED <> "10"  //Bloqueado por Credito
		 	cStatus := "BC"
		ElseIf !Empty(SC9->C9_BLEST) .And. SC9->C9_BLEST <> "10" //Bloqueado por Estoque
			cStatus := "BE"
		EndIf
	ElseIf SC6->C6_QTDENT < SC6->C6_QTDVEN
		cStatus := "PE"
	ElseIf SC6->C6_QTDENT = SC6->C6_QTDVEN
		cStatus := "E"
	EndIf
	RecLock("HC6", !lFound)
	HC6->HC6_STATUS := cStatus
	HC6->HC6_VER   := nMaxVer := HHGenericUpd(SC5->C5_VEND1, "HC6")
	HC6->HC6_INTR := cIntr
	HC6->(MsUnlock())
	HC6->(dbCommit())

	HHAtuCtr(SC5->C5_VEND1, "HC6", nMaxVer)
EndIf 
dbSelectArea(cAlias)
//ConOut("HHSC9 - 2 - " + Time())
Return .T.
