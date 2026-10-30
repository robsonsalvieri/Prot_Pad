#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA342.CH"

/*/{Protheus.doc} VEIA342

ARGENTINA - FATURAMENTO DIRETO - SAIDAS

Opções do aRotina chamadas pelo VEIXA030
1=Fatura de Saida
2=Remito de Saida

@author Andre Luis Almeida
@since 15/06/2026
/*/
Function VEIA342(nOpcSelec)
Local oProcess // incluído o parâmetro lEnd para controlar o cancelamento da janela
Local lOkExec  := .f.
Local lVV0_STAFDI := ( VV0->(FieldPos("VV0_STAFDI")) > 0 )
Local cOpcSelec := IIf(nOpcSelec==1,"FAT","REM")
Local cTitTela := IIf(nOpcSelec==1,STR0001,STR0002) // Geração da Fatura de Saida / Geração do Remito de Saida
Local aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
					{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil}				,;
					{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }
Private oModel   := FWLoadModel("VEIA342")
Private oView    := FWLoadView("VEIA342")
Private oConf342 := VEIA342Config():New()
//
If VV9->VV9_STATUS <> "F"
	FMX_HELP("VA342ERR001",STR0003,STR0004) // Opção não disponivel / O Faturamento Direto deve estar com o status Finalizado.
	Return
EndIf
//
If lVV0_STAFDI .and. VXA030051_valida_Veiculos(VV9->VV9_FILIAL,VV9->VV9_NUMATE)
	VV0->(DbSetOrder(1))
	VV0->(DbSeek(VV9->VV9_FILIAL+VV9->VV9_NUMATE))
	If nOpcSelec == 1// 1=Fatura de Saida
		If VV0->VV0_STAFDI >= "3"
			FMX_HELP("VA342ERR002",cTitTela+". "+STR0003,STR0005) // Opção não disponivel. / O Faturamento Direto não pode ter Faturas ou Remitos de Saidas já gerados.
			Return
		ElseIf VV0->VV0_STAFDI <> "2"
			FMX_HELP("VA342ERR003",cTitTela+". "+STR0003,STR0006) // Opção não disponivel. / O Faturamento Direto deve possuir as Faturas e Remitos de Entradas já gerados.
			Return
		EndIf
	Else // 2=Remito de Saida
		If VV0->VV0_STAFDI <> "3"
			FMX_HELP("VA342ERR004",cTitTela+". "+STR0003,STR0007) // Opção não disponivel. / O Faturamento Direto deve possuir apenas a Fatura de Saida gerada.
			Return
		EndIf
	EndIf
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA))
	//
	If nOpcSelec == 1// 1=Fatura de Saida
		oModel:GetModel("PARMASTER"):GetStruct():SetProperty( 'F2_TRANSP' , MODEL_FIELD_OBRIGAT, .f.)
		oView:GetViewStruct( 'PARMASTER' ):RemoveField("F2_TRANSP")
	Else // 2=Remito de Saida
		oModel:GetModel("PARMASTER"):GetStruct():SetProperty( 'VVA_CODTES' , MODEL_FIELD_TITULO , RetTitle('VVA_TESREM') )
		oModel:GetModel("PARMASTER"):GetStruct():SetProperty( 'VVA_CODTES' , MODEL_FIELD_VALID  , VA3420051_Valid('VVA_CODTES',.t.,'(Existcpo("SF4",,1).and.MaAvalTes("S",M->VVA_CODTES).and.VX0020101_Valida_TES_ARG("4",M->VVA_CODTES))') )
	EndIf
	//
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModelPar := oModel:GetModel("PARMASTER")
	oModelPar:SetValue("F2_CLIENTE"     , SA1->A1_COD     )
	oModelPar:SetValue("F2_LOJA"        , SA1->A1_LOJA    )
	oModelPar:SetValue("A1_NOME"        , SA1->A1_NOME    )
	oModelPar:SetValue("F2_EST"         , SA1->A1_EST     )
	oModelPar:SetValue("F2_VALBRUT"     , VV0->VV0_VALTOT )
	oModelPar:SetValue("F2_MOEDA"       , VV0->VV0_MOEDA  )
	oModelPar:SetValue("F2_TXMOEDA"     , VV0->VV0_TXMOED )
	// Buscar o ultimo SALVO
	oModelPar:SetValue("F2_TRANSP" ,oConf342:GetValue(cOpcSelec+"_F2_TRANSP" , space(GetSx3Cache("F2_TRANSP" ,"X3_TAMANHO"))) )
	oModelPar:SetValue("F2_PROVENT",oConf342:GetValue(cOpcSelec+"_F2_PROVENT", space(GetSx3Cache("F2_PROVENT","X3_TAMANHO"))) )
	oModelPar:SetValue("F2_NATUREZ",oConf342:GetValue(cOpcSelec+"_F2_NATUREZ", space(GetSx3Cache("F2_NATUREZ","X3_TAMANHO"))) )
	oModelPar:SetValue("VVA_CODTES",oConf342:GetValue(cOpcSelec+"_VVA_CODTES", space(GetSx3Cache("VVA_CODTES","X3_TAMANHO"))) )
	oModelPar:SetValue("VVA_CENCUS",oConf342:GetValue(cOpcSelec+"_VVA_CENCUS", space(GetSx3Cache("VVA_CENCUS","X3_TAMANHO"))) )
	oModelPar:SetValue("VVA_CONTA" ,oConf342:GetValue(cOpcSelec+"_VVA_CONTA" , space(GetSx3Cache("VVA_CONTA" ,"X3_TAMANHO"))) )
	oModelPar:SetValue("VVA_ITEMCT",oConf342:GetValue(cOpcSelec+"_VVA_ITEMCT", space(GetSx3Cache("VVA_ITEMCT","X3_TAMANHO"))) )
	oModelPar:SetValue("VVA_CLVL"  ,oConf342:GetValue(cOpcSelec+"_VVA_CLVL"  , space(GetSx3Cache("VVA_CLVL"  ,"X3_TAMANHO"))) )
	//
	CursorArrow()
	oExec342 := FWViewExec():New()
	oExec342:setModel(oModel)
	oExec342:setView(oView)
	oExec342:setTitle(cTitTela)
	oExec342:setOK( { || VA3420041_TudoOK(nOpcSelec) })
	oExec342:setCancel( { || .T. } )
	oExec342:setOperation(MODEL_OPERATION_UPDATE)
	oExec342:setReduction(10) // Redução de 10% da tela
	oExec342:SetButtons(aButtons)
	oExec342:openView(.f.)
	lOkExec := (oExec342:getButtonPress() == 0)
	oExec342:DeActivate()
	If lOkExec
		oProcess := MsNewProcess():New({|lEnd| VA3420021_Processa( nOpcSelec , @oProcess , @lEnd ) },cTitTela,"",.T.)
		oProcess:Activate()
	EndIf
EndIf
//
Return

Static Function ModelDef()
	Local oModel 
	Local oParametro := VA3420011_Campos_Parametros()
	Local oParamStru := oParametro:GetModel()
	oModel := MPFormModel():New( 'VEIA342', /* bPre */, /* bPost */ , { || .t. } /* bCommit */ , { || .T. } /* bCancel */ )
	oModel:AddFields('PARMASTER', /* cOwner */ , oParamStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )
	oModel:SetDescription(STR0008) // Parametros
	oModel:GetModel('PARMASTER'):SetDescription(STR0008) // Parametros
	oModel:GetModel('PARMASTER'):SetOnlyQuery( .T. )
	oModel:SetPrimaryKey({})
Return oModel

Static Function ViewDef()
	Local oModel	:= FWLoadModel( 'VEIA342' )
	Local oView 	:= Nil
	Local oParametro := VA3420011_Campos_Parametros()
	Local oParamStru := oParametro:GetView()
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_PARAM', oParamStru , 'PARMASTER')
	oView:EnableTitleView('FORM_PARAM',STR0008) // Parametros
	oView:CreateHorizontalBox('TELA_PARAM',100) //,,.t.)
	oView:SetOwnerView('FORM_PARAM','TELA_PARAM')
	oView:SetCloseOnOk({||.T.})
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 
	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL
	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)
Return oView

/*/
{Protheus.doc} VA3420011_Campos_Parametros
Monta Campos da Grid de Parametros

@author Andre Luis Almeida
@since 15/06/2026
/*/
Static Function VA3420011_Campos_Parametros()
Local oRetorno := OFDMSStruct():New()
oRetorno:AddFieldDictionary( "SF2" , "F2_CLIENTE" , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF2" , "F2_LOJA"    , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SA1" , "A1_NOME"    , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF2" , "F2_EST"     , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF2" , "F2_VALBRUT" , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF2" , "F2_MOEDA"   , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF2" , "F2_TXMOEDA" , { { 'lCanChange' , .f. } } )
oRetorno:AddFieldDictionary( "SF2" , "F2_TRANSP"  , { { 'bValid' , VA3420051_Valid('F2_TRANSP' ,.t.,'ExistCpo("SA4",,1)') } , { 'lCanChange' , .t. } , { 'lObrigat' , .f. } } )
if cPaisLoc == "ARG"
	oRetorno:AddFieldDictionary( "SF2" , "F2_PROVENT" , { { 'bValid' , VA3420051_Valid('F2_PROVENT',.t.,'ExistCpo("SX5","12"+M->F2_PROVENT)') } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } )
	oRetorno:AddFieldDictionary( "SF2" , "F2_NATUREZ" , { { 'bValid' , VA3420051_Valid('F2_NATUREZ',.t.,'ExistCpo("SED",,1)') } , { 'lCanChange' , .t. } , { 'cLookUp' , "SED" } , { 'lObrigat' , .t. } } )
endif
oRetorno:AddFieldDictionary( "VVA" , "VVA_CODTES" , { { 'bValid' , VA3420051_Valid('VVA_CODTES',.t.,'(Existcpo("SF4",,1).and.MaAvalTes("S",M->VVA_CODTES).and.VX0020101_Valida_TES_ARG("1",M->VVA_CODTES))') } , { 'cTitulo' , RetTitle('VVA_CODTES') } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } )
oRetorno:AddFieldDictionary( "VVA" , "VVA_CENCUS" , { { 'bValid' , VA3420051_Valid('VVA_CENCUS',.t.,'ExistCpo("CTT",,1)') } , { 'lCanChange' , .t. } } )
oRetorno:AddFieldDictionary( "VVA" , "VVA_CONTA"  , { { 'bValid' , VA3420051_Valid('VVA_CONTA' ,.t.,'ExistCpo("CT1",,1)') } , { 'lCanChange' , .t. } } )
oRetorno:AddFieldDictionary( "VVA" , "VVA_ITEMCT" , { { 'bValid' , VA3420051_Valid('VVA_ITEMCT',.t.,'ExistCpo("CTD",,1)') } , { 'lCanChange' , .t. } } )
oRetorno:AddFieldDictionary( "VVA" , "VVA_CLVL"   , { { 'bValid' , VA3420051_Valid('VVA_CLVL'  ,.t.,'ExistCpo("CTH",,1)') } , { 'lCanChange' , .t. } } )
Return oRetorno

/*/
{Protheus.doc} VA3420021_Processa
Processa

@author Andre Luis Almeida
@since 15/06/2026
/*/
Static Function VA3420021_Processa( nOpcSelec , oProcess , lEnd )
Local lOkExec     := .f.
Local lOkTit      := .f.
Local cNroDoc     := ""
Local cSerDoc     := ""
Local cProcesso   := IIf(nOpcSelec==1,STR0009,STR0010) // Gerando Fatura de Saida / Gerando Remito de Saida
Local nRecVV0     := VV0->(RecNo())
Local cQuery      := ""
Local cSQLAlias   := "SQLVVAVV1"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros da Rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cLocxNFPV := ""
Private cIdPV     := ""
Private cIdPVArg  := "" // variavel utilizada dentro do A462ANGera
Private cPV410    := ""
Private lLocxAuto := .F.
//
oProcess:SetRegua1(0)
oProcess:IncRegua1(STR0011) // Processando...
oProcess:SetRegua2(4)
oProcess:IncRegua2(STR0012) // Ponto de Venda
//
If nOpcSelec == 1 // 1=Fatura de Saida
	cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_FAT_FATDIRETO") // Fatura
Else // 2=Remito de Saida
	cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_FATDIRETO") // Remito
EndIf
If Empty(cLocxNFPV)
	If Pergunte("PVXARG",.T.) .and. !Empty(MV_PAR01)
		cLocxNFPV := MV_PAR01
	EndIf
EndIf
If !Empty(cLocxNFPV)
	cPV410    := cLocxNFPV // Variavel Private utilizada no a468nFatura
	lLocxAuto := .F.
	cIdPVArg := cIdPV := POSICIONE("CFH",1, xFilial("CFH")+cLocxNFPV,"CFH_IDPV")
	lOkExec := F083ExtSFP(cLocxNFPV, .T.)
Endif
If !lOkExec
	Return .f.
EndIf
//
Begin Transaction
	oProcess:IncRegua2(cProcesso)
	oProcess:IncRegua2(cProcesso)
	DbSelectArea("VV0")
	DbGoTo(nRecVV0)
	RecLock("VV0",.f.)
		If nOpcSelec == 2 // 2=Remito de Saida
			VV0->VV0_CODTRA := M->F2_TRANSP
		EndIf
		VV0->VV0_PROVEN := M->F2_PROVENT
		VV0->VV0_NATFIN := M->F2_NATUREZ
	VV0->(MsUnLock())
	cQuery := "SELECT VVA.R_E_C_N_O_ RECVVA "
	cQuery += "  FROM "+RetSQLName("VVA")+" VVA "
	cQuery += " WHERE VVA.VVA_FILIAL='"+VV0->VV0_FILIAL+"'"
	cQuery += "   AND VVA.VVA_NUMTRA='"+VV0->VV0_NUMTRA+"'"
	cQuery += "   AND VVA.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		VVA->(DbGoTo( (cSQLAlias)->( RECVVA ) ))
		RecLock("VVA",.f.)
			If nOpcSelec == 1 // 1=Fatura de Saida
				VVA->VVA_CODTES := M->VVA_CODTES 
			Else // 2=Remito de Saida
				VVA->VVA_TESREM := M->VVA_CODTES 
			EndIf
			VVA->VVA_CENCUS := M->VVA_CENCUS
			VVA->VVA_CONTA  := M->VVA_CONTA
			VVA->VVA_ITEMCT := M->VVA_ITEMCT
			VVA->VVA_CLVL   := M->VVA_CLVL
		VVA->(MsUnLock())
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	DbSelectArea("VVA")
	lOkExec := VA3420031_gerar_Saida(nOpcSelec)
	If lOkExec
		oProcess:IncRegua2(STR0013) // Atualizando Faturamento Direto
		// VV0 //
		DbSelectArea("VV0")
		DbGoTo(nRecVV0)
		If nOpcSelec == 1 // 1=Fatura de Saida
			cNroDoc := VV0->VV0_NUMNFI // Numero da Fatura
			cSerDoc := VV0->VV0_SERNFI // Serie da Fatura
		Else // 2=Remito de Saida
			cNroDoc := VV0->VV0_REMITO // Numero do Remito
			cSerDoc := VV0->VV0_SERREM // Serie do Remito
		EndIf
		RecLock("VV0",.f.)
			If nOpcSelec == 1 // 1=Fatura de Saida
				VV0->VV0_STAFDI := "3" // Gerou Fatura de Saida
			Else // 2=Remito de Saida
				VV0->VV0_STAFDI := "4" // Gerou Remito de Saida
			EndIf
		VV0->(MsUnLock())
	EndIf
End Transaction
If lOkExec
	If nOpcSelec == 1 // 1=Fatura de Saida
		Begin Transaction
			lOkTit := VA3420031_gerar_Saida(3) // 3=Gerar Titulos da Fatura de Saida
			DbSelectArea("VV0")
			DbGoTo(nRecVV0)
			RecLock("VV0",.f.)
				VV0->VV0_GERFIN := IIf(lOkTit,"1","0") // Gerou Financeiro (Titulos)? ( 1=Sim / 0=Nao, deu problema na geracao )
			VV0->(MsUnLock())
		End Transaction
		If !lOkTit
			FMX_HELP("VA342ERR005",STR0014+CHR(13)+CHR(10)+Alltrim(cNroDoc)+"-"+Alltrim(cSerDoc),STR0015) // Problema na geração dos Titulos relacionados a Fatura de Saida. / Favor verificar.
		EndIf
	EndIf
	FMX_TELAINF( "1" , { { Alltrim(cSerDoc) , Alltrim(cNroDoc) , STR0016 } } ) // GERADO
EndIf
Return lOkExec

/*/{Protheus.doc} VA3420031_gerar_Saida
Gerar:
1=Fatura de Saida
2=Remito de Saida
3=Titulos da Fatura de Saida

@author Andre Luis Almeida
@since 15/06/2026
/*/
Static Function VA3420031_gerar_Saida(nOpcSelec)
Local lRet   := .f.
Local cSerie := ""
Pergunte("VXA018",.f.)
Private cTpOperNov := MV_PAR01 // Tipo de Operacao para Veiculos Novos
Private cTpOperUsa := MV_PAR02 // Tipo de Operacao para Veiculos Usados
Private cCliPadrao := MV_PAR03 // Cliente Padrao
Private cLojPadrao := MV_PAR04 // Loja do Cliente Padrao
Private cVenVdaDir := PadR(GetNewPar("MV_MIL0050",""),TamSX3("A3_COD")[1]," ") // Codigo do Vendedor que sera enviado na integracao com o Venda Direta
Private cTESDefNov := MV_PAR09 // TES default para Veiculos Novos quando nao existir a regra no TES inteligente.
Private cTESDefUsa := MV_PAR10 // TES default para Veiculos Usados quando nao existir a regra no TES inteligente.
Private nVerParFat := MV_PAR11 // Mostrar Parametros do Faturamento no momento da geracao da NF
Private lImpCCO   := .f. // variavel utiliza dentro do Fiscal do Mercado Internacional - IMPGENER.PRX
Private lImpSFC   := .f. // variavel utiliza dentro do Fiscal do Mercado Internacional - IMPGENER.PRX
Private aImpCCO   := {}  // variavel utiliza dentro do Fiscal do Mercado Internacional - IMPGENER.PRX
Private aImpSFC   := {}  // variavel utiliza dentro do Fiscal do Mercado Internacional - IMPGENER.PRX
Do Case
	Case nOpcSelec == 1 // 1=Fatura de Saida
		lRet := VEIXI002(VV9->VV9_NUMATE,.t.,.t.,.f.,cSerie,.f.,"F", .t., , "1") // Geracao de Pedido (.T.) , NF (.T.) e Titulos (.F.)
	Case nOpcSelec == 2 // 2=Remito de Saida
		lRet := VEIXI002(VV9->VV9_NUMATE,.t.,.t.,.f.,cSerie,.f.,"F", .t., , "2") // Geracao de Pedido (.T.) , NF (.T.) e Titulos (.F.)
	Case nOpcSelec == 3 // 3=Titulos da Fatura de Saida
		lRet := VEIXI002(VV9->VV9_NUMATE,.f.,.f.,.t.,cSerie,.f.,"F", .f., , "1") // Geracao de Pedido (.F.) , NF (.F.) e Titulos (.T.)
EndCase
Return lRet

/*/
{Protheus.doc} VA3420041_TudoOK
Tudo Ok Tela

@author Andre Luis Almeida
@since 15/06/2026
/*/
Static Function VA3420041_TudoOK(nOpcSelec)
Local cOpcSelec := ""
Local nCntFor   := 0
Local lRet      := .t.
Local jJson     := JsonObject():New()
If lRet // SALVAR INFORMACOES PARA PROXIMA EXECUCAO
	For nCntFor := 1 to 2
		cOpcSelec := IIf(nCntFor==1,"FAT","REM")
		jJson[cOpcSelec+"_F2_TRANSP"]  := IIf( nCntFor == nOpcSelec , M->F2_TRANSP  , oConf342:GetValue(cOpcSelec+"_F2_TRANSP" , space(GetSx3Cache("F2_TRANSP" ,"X3_TAMANHO"))) )
		jJson[cOpcSelec+"_F2_PROVENT"] := IIf( nCntFor == nOpcSelec , M->F2_PROVENT , oConf342:GetValue(cOpcSelec+"_F2_PROVENT", space(GetSx3Cache("F2_PROVENT","X3_TAMANHO"))) )
		jJson[cOpcSelec+"_F2_NATUREZ"] := IIf( nCntFor == nOpcSelec , M->F2_NATUREZ , oConf342:GetValue(cOpcSelec+"_F2_NATUREZ", space(GetSx3Cache("F2_NATUREZ","X3_TAMANHO"))) )
		jJson[cOpcSelec+"_VVA_CODTES"] := IIf( nCntFor == nOpcSelec , M->VVA_CODTES , oConf342:GetValue(cOpcSelec+"_VVA_CODTES", space(GetSx3Cache("VVA_CODTES","X3_TAMANHO"))) )
		jJson[cOpcSelec+"_VVA_CENCUS"] := IIf( nCntFor == nOpcSelec , M->VVA_CENCUS , oConf342:GetValue(cOpcSelec+"_VVA_CENCUS", space(GetSx3Cache("VVA_CENCUS","X3_TAMANHO"))) )
		jJson[cOpcSelec+"_VVA_CONTA"]  := IIf( nCntFor == nOpcSelec , M->VVA_CONTA  , oConf342:GetValue(cOpcSelec+"_VVA_CONTA" , space(GetSx3Cache("VVA_CONTA" ,"X3_TAMANHO"))) )
		jJson[cOpcSelec+"_VVA_ITEMCT"] := IIf( nCntFor == nOpcSelec , M->VVA_ITEMCT , oConf342:GetValue(cOpcSelec+"_VVA_ITEMCT", space(GetSx3Cache("VVA_ITEMCT","X3_TAMANHO"))) )
		jJson[cOpcSelec+"_VVA_CLVL"]   := IIf( nCntFor == nOpcSelec , M->VVA_CLVL   , oConf342:GetValue(cOpcSelec+"_VVA_CLVL"  , space(GetSx3Cache("VVA_CLVL"  ,"X3_TAMANHO"))) )
	Next
	oConf342:Save(jJson)
EndIf
Return lRet

/*/
{Protheus.doc} VA3420051_Valid
Monta o VALID do prw e carrega VALIDUSER dos campos

@author Andre Luis Almeida
@since 15/06/2026
/*/
Static Function VA3420051_Valid(cCpo,lVazio,cVldPRW)
Local cVldRet := IIf(lVazio,'vazio().or.(','')
Local cVldUsr := Alltrim(GetSx3Cache(cCpo,"X3_VLDUSER"))
If !Empty(cVldPRW)
	cVldRet += cVldPRW // VALID do campo
EndIf
If !Empty(cVldUsr)
	cVldRet += IIf(!Empty(cVldPRW),'.and.('+cVldUsr+')',cVldUsr)
EndIf
cVldRet += IIf(cVldRet=='vazio().or.(',".t.","")
cVldRet += IIf(lVazio,')','')
cVldRet := IIf(!Empty(cVldRet),cVldRet,'.T.')
Return FWBuildFeature(STRUCT_FEATURE_VALID,cVldRet)

/*/
{Protheus.doc} VA3420061_Cancelar_Saida
Cancelar Saida

@author Andre Luis Almeida
@since 17/06/2026
/*/
Function VA3420061_Cancelar_Saida(nFatRem,nRECVV0)
Local cVV0_STAFDI := ""
Local cPrefOri    := GetNewPar("MV_PREFVEI","VEI")
Local cNumTit     := "V"+Right(VV9->VV9_NUMATE,TamSx3("E1_NUM")[1]-1)
Local lOkExec     := .f.
Local aInfo       := {}
If VV0->VV0_STAFDI == "3" .and. nFatRem == 3 // 3=Fatura de Saida
	AAdd(aInfo, { Alltrim(VV0->VV0_SERNFI) , Alltrim(VV0->VV0_NUMNFI) , STR0017 } ) // CANCELADO
	DbSelectArea("SF2")
	DbSetOrder(1)
	DbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
	lOkExec := VXI010101_cancelar_SE1(.f.,cNumTit,"",VV0->VV0_NUMNFI,SF2->F2_PREFIXO,cPrefOri,.t.,.f.)
	If lOkExec
		lOkExec := VX0010058_CancNFArg(VV0->VV0_NUMNFI,VV0->VV0_SERNFI,"1") // 1=Nota Normal / 2=Remito
		If lOkExec
			lOkExec := VXI010051_cancela_Pedido_SC5_SC6( VV0->VV0_NUMPED )
		EndIf
	EndIf
	cVV0_STAFDI := "2" // Volta para apenas as ENntradas geradas
ElseIf VV0->VV0_STAFDI == "4" .and. nFatRem == 4 // 4=Remito de Saida
	AAdd(aInfo, { Alltrim(VV0->VV0_SERREM) , Alltrim(VV0->VV0_REMITO) , STR0017 } ) // CANCELADO
	DbSelectArea("SF2")
	DbSetOrder(1)
	DbSeek(xFilial("SF2") + VV0->VV0_REMITO + VV0->VV0_SERREM )
	lOkExec := VX0010058_CancNFArg(VV0->VV0_REMITO,VV0->VV0_SERREM,"2") // 1=Nota Normal / 2=Remito
	If lOkExec
		lOkExec := VXI010051_cancela_Pedido_SC5_SC6( VV0->VV0_PEDREM )
	EndIf
	cVV0_STAFDI := "3" // Volta para Fatura de Saida gerada
EndIf
If lOkExec .and. !Empty(cVV0_STAFDI)
	VV0->(DbGoTo(nRECVV0))
	RecLock("VV0",.f.)
		VV0->VV0_STAFDI := cVV0_STAFDI
		If cVV0_STAFDI == "2" // Somente Entradas
			VV0->VV0_NUMNFI := ""
			VV0->VV0_SERNFI := ""
			VV0->VV0_NUMPED := ""
		ElseIf cVV0_STAFDI == "3" // Somente Fatura de Saida
			VV0->VV0_REMITO := ""
			VV0->VV0_SERREM := ""
			VV0->VV0_PEDREM := ""
		EndIf
	VV0->(MsUnLock())
	//
	FMX_TELAINF( "1" , aInfo )
	//
EndIf
Return lOkExec

/*/{Protheus.doc} VEIA342Config
	Faturamento Direto - ARGENTINA
	Classe principal para tratar os dados da parametrização da Geração de Fatura e Remito de Saida
	
	@type class
	@author Andre Luis Almeida
	@since 15/06/2026
/*/
Class VEIA342Config
	Public Data cCodigo
	Public Data cFilConf
	Data jConfig

	Public Method New() CONSTRUCTOR
	Public Method SetValue()
	Public Method GetValue()
	Public Method Save()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type method
	@author Andre Luis Almeida
	@since 15/06/2026
/*/
Method New() Class VEIA342Config
	::cCodigo  := "VEIA342"
	::cFilConf := Padr(cFilAnt,FWSizeFilial()) // Carrega a Filial Logada
	::jConfig  := JsonObject():New()
	dbselectArea("VRN")
	dbSetOrder( 2 ) // Ordem do VRN
	If dbSeek(xFilial("VRN") + ::cFilConf + ::cCodigo)
		::jConfig:FromJson(VRN->VRN_CONFIG)
	Else
		VRN->(reclock("VRN", .T.))
		VRN->VRN_FILIAL := xFilial("VRN")
		VRN->VRN_CODIGO := ::cCodigo
		VRN->VRN_CONFIG := "{}"
		VRN->VRN_FILCON := ::cFilConf
		VRN->(msUnlock())
	EndIf	
Return SELF

/*/{Protheus.doc} GetValue
	retorna o valor contido no json para o parametro passado

	@type method
	@author Andre Luis Almeida
	@since 15/06/2026
/*/
Method GetValue(cLabel, xDef) Class VEIA342Config
	if self:jConfig:hasProperty(cLabel)
		return self:jConfig[cLabel]
	endif
Return xDef

/*/{Protheus.doc} SetValue
	Seta o valor do parametro no json

	@type method
	@author Andre Luis Almeida
	@since 15/06/2026
/*/
Method SetValue(cAttr, xValue) Class VEIA342Config
	self:jConfig[cAttr] := xValue
Return .t.

/*/{Protheus.doc} Save
	salva json com a configuração

	@type method
	@author Andre Luis Almeida
	@since 15/06/2026
/*/
Method Save(jConfig) Class VEIA342Config
	dbselectArea("VRN")
	dbSetOrder(2)
	If dbSeek(xFilial("VRN") + self:cFilConf + self:cCodigo)
		reclock("VRN", .F.)
		VRN->VRN_CONFIG := jConfig:toJSON()
		VRN->(msUnlock())
	EndIf
	self:jConfig := jConfig
Return .t.