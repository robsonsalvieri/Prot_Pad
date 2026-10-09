#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#Include "Protheus.ch"
#INCLUDE "VEIA351.CH"
/*/{Protheus.doc} VEIA351
Remitos de Entrega Futura em Outras Filiais - VV0_FILREM

@author Andre Luis Almeida
@since 15/09/2025
@type function
/*/
Function VEIA351()
	Local aSize   := FWGetDialogSize( oMainWnd )
	Local cTitFil := Alltrim(STR0002+": "+xFilial("SD2")) // Filial
	//	
	Local oBrowseA // A - Atendimentos de Outras Filiais aguardando Remito de Entrega
	Local cQueryA := VA3510011_QueryBrowse("A") // Query Browse A
	Local aIndexA := VA3510021_IndexBrowse("A") // Indices Browse A
	Local aSeeksA := VA3510031_SeeksBrowse("A") // Seeks Browse A
	Local aColumA := VA3510041_ColunBrowse("A") // Colunas Browse A
	//
	Local oBrowseB // B - Remito de Entrega já realizados
	Local cQueryB := VA3510011_QueryBrowse("B") // Query Browse B
	Local aIndexB := VA3510021_IndexBrowse("B") // Indices Browse B
	Local aSeeksB := VA3510031_SeeksBrowse("B") // Seeks Browse B
	Local aColumB := VA3510041_ColunBrowse("B") // Colunas Browse B

	If cPaisLoc <> "ARG"
		FMX_HELP("VEIA351ERR01",STR0017) // Rotina disponível apenas para Argentina.
		Return
	EndIf

	oVEIA351 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cTitFil+" - "+STR0001, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Remitos de Entrega Futura em Outras Filiais

		oFldVA351 := TFolder():New(001,001,{cTitFil+" - "+STR0003,cTitFil+" - "+STR0004},{}, oVEIA351 ,,,,.t.,.f.,100,100) // Atendimentos de Outras Filiais aguardando Remito de Entrega / Remito de Entrega já realizados
		oFldVA351:Align := CONTROL_ALIGN_ALLCLIENT

		// A - Atendimentos de Outras Filiais aguardando Remito de Entrega
		oBrowseA := FWFormBrowse():New( )
		oBrowseA:SetOwner(oFldVA351:aDialogs[1])
		oBrowseA:SetDataQuery(.T.)
		oBrowseA:SetAlias("TEMPA")
		oBrowseA:SetQueryIndex(aIndexA)
		oBrowseA:SetQuery(cQueryA)
		oBrowseA:SetSeek(,aSeeksA)
		oBrowseA:SetDescription( cTitFil+" - "+STR0003 ) // Atendimentos de Outras Filiais aguardando Remito de Entrega
		oBrowseA:SetMenuDef("")
		oBrowseA:AddButton( STR0006 , {|| IIf(!Empty(TEMPA->VV9_NUMATE),Processa( { || VA3510051_GerarRemito(oBrowseA,oBrowseB) } ),.t.) },,2,2) // Gerar Remito de Entrega
		oBrowseA:AddButton( STR0005 , {|| IIf(!Empty(TEMPA->VVA_CHASSI),VEIVC140(TEMPA->VVA_CHASSI,),.t.) },,2,2) // Rastreamento Veículo/Máquina
		oBrowseA:DisableDetails()
		oBrowseA:DisableConfig()
		oBrowseA:SetUseFilter(.t.)
		oBrowseA:SetColumns(aColumA)
		oBrowseA:ForceQuitButton(.T.)
		oBrowseA:Activate()

		// B - Remito de Entrega já realizados
		oBrowseB := FWFormBrowse():New( )
		oBrowseB:SetOwner(oFldVA351:aDialogs[2])
		oBrowseB:SetDataQuery(.T.)
		oBrowseB:SetAlias("TEMPB")
		oBrowseB:SetQueryIndex(aIndexB)
		oBrowseB:SetQuery(cQueryB)
		oBrowseB:SetSeek(,aSeeksB)
		oBrowseB:SetDescription( cTitFil+" - "+STR0004 ) // Remito de Entrega já realizados
		oBrowseB:SetMenuDef("")
		oBrowseB:AddButton( STR0007 , {|| IIf(!Empty(TEMPB->VV9_NUMATE),Processa( { || VA3510061_CancelarRemito(oBrowseA,oBrowseB) } ),.t.) },,2,2) // Cancelar Remito de Entrega
		oBrowseB:AddButton( STR0005 , {|| IIf(!Empty(TEMPB->VVA_CHASSI),VEIVC140(TEMPB->VVA_CHASSI,),.t.) },,2,2) // Rastreamento Veículo/Máquina
		oBrowseB:AddButton( STR0021 , {|| IIf(!Empty(TEMPB->VV9_NUMATE),Processa( { || VA3510071_DevolverRemito(oBrowseA,oBrowseB) } ),.t.) },,2,2) // Devolver Remito
		oBrowseB:DisableDetails()
		oBrowseB:DisableConfig()
		oBrowseB:SetUseFilter(.t.)
		oBrowseB:SetColumns(aColumB)
		oBrowseB:ForceQuitButton(.T.)
		oBrowseB:Activate()

    oVEIA351:Activate( , , , , , , ) //ativa a janela

Return .t.

/*/{Protheus.doc} VA3510011_QueryBrowse
	Retorna a Query dos Browses A e B ( browse em SQL )

	@author Andre Luis Almeida
	@since 15/09/2025
/*/
Static Function VA3510011_QueryBrowse(cTp)
Local cQuery := ""
cQuery := "SELECT * FROM ( SELECT "
cQuery += "VV9.VV9_FILIAL , VV9.VV9_NUMATE , VV0.VV0_DATMOV , "
cQuery += "VVA.VVA_CHASSI , VVA.VVA_CHAINT , VVA.VVA_CODMAR , VVA.VVA_MODVEI , "
cQuery += "VV0.VV0_NUMNFI , VV0.VV0_SERNFI , "
If cTp == "B" // Browse B - Remito de Entrega já realizados
	cQuery += "VV0.VV0_REMITO , VV0.VV0_SERREM , "
EndIf
cQuery += "VV0.VV0_CODCLI , VV0.VV0_LOJA , SA1.A1_NOME , SA1.A1_MUN , SA1.A1_EST "
cQuery += "  FROM "+RetSqlName("VV9")+" VV9 "
cQuery += "  JOIN "+RetSqlName("VV0")+" VV0 "
cQuery += "    ON VV0.VV0_FILIAL = VV9.VV9_FILIAL "
cQuery += "   AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE "
cQuery += "   AND VV0.VV0_SITNFI = '1'" // 1=Saida Valida
cQuery += "   AND VV0.VV0_GERFIN = '1'" // 1=Gerou Financeiro (Titulos)
If cTp == "A" // Browse A - Atendimentos de Outras Filiais aguardando Remito de Entrega
	cQuery += "   AND VV0.VV0_REMITO = ' '"
Else // Browse B - Remito de Entrega já realizados
	cQuery += "   AND VV0.VV0_REMITO <> ' '"
EndIf
cQuery += "   AND VV0.VV0_FILREM = '"+xFilial("SD2")+"'"
cQuery += "   AND VV0.D_E_L_E_T_ = ' '"
cQuery += "  JOIN "+RetSqlName("VVA")+" VVA "
cQuery += "    ON VVA.VVA_FILIAL = VV9.VV9_FILIAL "
cQuery += "   AND VVA.VVA_NUMTRA = VV9.VV9_NUMATE "
cQuery += "   AND VVA.D_E_L_E_T_ = ' '"
cQuery += "  JOIN "+RetSqlName("SA1")+" SA1 "
cQuery += "    ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"
cQuery += "   AND SA1.A1_COD     = VV0.VV0_CODCLI "
cQuery += "   AND SA1.A1_LOJA    = VV0.VV0_LOJA "
cQuery += "   AND SA1.D_E_L_E_T_ = ' '"
cQuery += " WHERE VV9.VV9_FILIAL <> '"+xFilial("VV9")+"'"
If cTp == "A" // Browse A - Atendimentos de Outras Filiais aguardando Remito de Entrega
    cQuery += "  AND VV9.VV9_STATUS = 'F'"
Else // Browse B - Remito de Entrega já realizados
    cQuery += "  AND VV9.VV9_STATUS <> 'C' "
EndIf
cQuery += "   AND VV9.D_E_L_E_T_ = ' '"
cQuery += ") TEMP"+cTp
Return cQuery

/*/{Protheus.doc} VA3510021_IndexBrowse
	Retorna os Indices dos Browses A e B ( browse em SQL )

	@author Andre Luis Almeida
	@since 16/09/2025
/*/
Static Function VA3510021_IndexBrowse(cTp)
Local aIndex := {}
Aadd( aIndex, "VV9_FILIAL+VV9_NUMATE")
Aadd( aIndex, "VV0_DATMOV")
Aadd( aIndex, "VVA_CHASSI" )
Aadd( aIndex, "VVA_CHAINT" )
Aadd( aIndex, "VVA_CODMAR+VVA_MODVEI" )
Aadd( aIndex, "VV0_CODCLI+VV0_LOJA" )
Aadd( aIndex, "VV0_NUMNFI+VV0_SERNFI" )
If cTp == "B" // Browse B - Remito de Entrega já realizados
	Aadd( aIndex, "VV0_REMITO+VV0_SERREM" )
EndIf
Return aClone(aIndex)

/*/{Protheus.doc} VA3510031_SeeksBrowse
	Retorna os Seek dos Browses A e B ( browse em SQL )

	@author Andre Luis Almeida
	@since 16/09/2025
/*/
Static Function VA3510031_SeeksBrowse(cTp)
Local aSeek := {}
Aadd( aSeek, { Alltrim(RetTitle("VV9_FILIAL")) + " + " + Alltrim(RetTitle("VV9_NUMATE")) , {{"","C",TamSX3("VV9_FILIAL")[1],0, Alltrim(RetTitle("VV9_FILIAL")),,},{"","C",TamSX3("VV9_NUMATE")[1],0,Alltrim(RetTitle("VV9_NUMATE")),,}}})
Aadd( aSeek, { Alltrim(RetTitle("VV0_DATMOV")), {{"","D",TamSX3("VV0_DATMOV")[1],0,Alltrim(RetTitle("VV0_DATMOV")),,}} } )
Aadd( aSeek, { Alltrim(RetTitle("VVA_CHASSI")), {{"","C",TamSX3("VVA_CHASSI")[1],0,Alltrim(RetTitle("VVA_CHASSI")),,}} } )
Aadd( aSeek, { Alltrim(RetTitle("VVA_CHAINT")), {{"","C",TamSX3("VVA_CHAINT")[1],0,Alltrim(RetTitle("VVA_CHAINT")),,}} } )
Aadd( aSeek, { Alltrim(RetTitle("VVA_CODMAR")) + " + " + Alltrim(RetTitle("VVA_MODVEI")) , {{"","C",TamSX3("VVA_CODMAR")[1],0, Alltrim(RetTitle("VVA_CODMAR")),,},{"","C",TamSX3("VVA_MODVEI")[1],0,Alltrim(RetTitle("VVA_MODVEI")),,}}})
Aadd( aSeek, { Alltrim(RetTitle("VV0_CODCLI")) + " + " + Alltrim(RetTitle("VV0_LOJA"))   , {{"","C",TamSX3("VV0_CODCLI")[1],0, Alltrim(RetTitle("VV0_CODCLI")),,},{"","C",TamSX3("VV0_LOJA")[1]  ,0,Alltrim(RetTitle("VV0_LOJA"))  ,,}}})
Aadd( aSeek, { Alltrim(RetTitle("VV0_NUMNFI")) + " + " + Alltrim(RetTitle("VV0_SERNFI")) , {{"","C",TamSX3("VV0_NUMNFI")[1],0, Alltrim(RetTitle("VV0_NUMNFI")),,},{"","C",TamSX3("VV0_SERNFI")[1],0,Alltrim(RetTitle("VV0_SERNFI")),,}}})
If cTp == "B" // Browse B - Remito de Entrega já realizados
	Aadd( aSeek, { Alltrim(RetTitle("VV0_REMITO")) + " + " + Alltrim(RetTitle("VV0_SERREM")) , {{"","C",TamSX3("VV0_REMITO")[1],0, Alltrim(RetTitle("VV0_REMITO")),,},{"","C",TamSX3("VV0_SERREM")[1],0,Alltrim(RetTitle("VV0_SERREM")),,}}})
EndIf
Return aClone(aSeek)

/*/{Protheus.doc} VA3510041_ColunBrowse
	Retorna as Colunas dos Browses A e B ( browse em SQL )

	@author Andre Luis Almeida
	@since 15/09/2025
/*/
Static Function VA3510041_ColunBrowse(cTp)
Local nCol     := 0
Local aColTot  := {}
Local aColumns := {}
aAdd(aColTot,{"VV9_FILIAL"      ,"VV9_FILIAL",10})
aAdd(aColTot,{"VV9_NUMATE"      ,"VV9_NUMATE",10})
aAdd(aColTot,{"Stod(VV0_DATMOV)","VV0_DATMOV", 8})
aAdd(aColTot,{"VVA_CHASSI"      ,"VVA_CHASSI",30})
aAdd(aColTot,{"VVA_CHAINT"      ,"VVA_CHAINT", 8})
aAdd(aColTot,{"VVA_CODMAR"      ,"VVA_CODMAR", 5})
aAdd(aColTot,{"VVA_MODVEI"      ,"VVA_MODVEI",13})
aAdd(aColTot,{"VV0_NUMNFI"      ,"VV0_NUMNFI",10})
aAdd(aColTot,{"VV0_SERNFI"      ,"VV0_SERNFI", 5})
If cTp == "B" // Browse B - Remito de Entrega já realizados
	aAdd(aColTot,{"VV0_REMITO"  ,"VV0_REMITO",10})
	aAdd(aColTot,{"VV0_SERREM"  ,"VV0_SERREM", 5})
EndIf
aAdd(aColTot,{"VV0_CODCLI"      ,"VV0_CODCLI",10})
aAdd(aColTot,{"VV0_LOJA"        ,"VV0_LOJA"  , 5})
aAdd(aColTot,{"A1_NOME"         ,"A1_NOME"   ,17})
aAdd(aColTot,{"A1_MUN"          ,"A1_MUN"    ,17})
aAdd(aColTot,{"A1_EST"          ,"A1_EST"    , 7})
For nCol := 1 to len(aColTot)
	aAdd(aColumns,FWBrwColumn():New())
		aColumns[nCol]:SetData( &("{|| "+aColTot[nCol,1]+" }") )
		aColumns[nCol]:SetTitle(RetTitle(aColTot[nCol,2]))
		aColumns[nCol]:SetSize(aColTot[nCol,3]) // %
Next
Return aClone(aColumns)

/*/{Protheus.doc} VA3510051_GerarRemito
	Gerar Remito de Entrega na Filial Logada

	@author Andre Luis Almeida
	@since 16/09/2025
/*/
Static Function VA3510051_GerarRemito(oBrowseA,oBrowseB)
Local ni        := 0
Local cGruVei   := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cNatureza := ""
Local cNumPed   := ""
Local cLocVei   := ""
Local cQuery    := ""
Local l1DUPNATAlt := ( "C5_NATUREZ" $ Upper(SuperGetMv("MV_1DUPNAT",.F.,"")) ) .and. SC5->(FieldPos("C5_NATUREZ")) <> 0
Local cPrefixo  := space(TamSX3("E1_PREFIXO")[1])
Local cPreTit   := &(GetNewPar("MV_PTITVEI","''")) // Prefixo dos Titulos de Veiculos
Local cPrefVEI  := GetNewPar("MV_PREFVEI","VEI")
Local aItePv    := {}
Local aUltMov   := {}
Local aParamBox := {}
Local aRet      := {}
Local lTelaTES  := .t.
Local cTESRem   := ""
Local aBloqueio := {}
Private aCabPv    := {}
Private aIteTPv   := {}
Private cLocxNFPV := ""
Private lLocxAuto := .F.
Private cIdPVArg  := ""
Private cPV410    := ""
Private cIdPV     := ""
//
If !MsgYesNo(STR0008+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Confirma a geração do Remito de Entrega?
			STR0009+": "+TEMPA->VVA_CHASSI,; // Chassi
			STR0002+": "+xFilial("SD2")) // Filial
	Return
EndIf
//
cNota  := ""
cSerie := ""
//
VISUALIZA := .f.
INCLUI 	  := .t.
ALTERA 	  := .f.
EXCLUI 	  := .f.
//
ProcRegua(3)
//
IncProc(STR0006) // Gerar Remito de Entrega
//
VV9->(DbSetOrder(1))
VV9->(DbSeek(TEMPA->VV9_FILIAL+TEMPA->VV9_NUMATE))
nRecVV9 := VV9->(RecNo()) // Salvar o RecNo do VV9 para voltar
//
VV0->(DbSetOrder(1))
VV0->(DbSeek(TEMPA->VV9_FILIAL+TEMPA->VV9_NUMATE))
nRecVV0 := VV0->(RecNo()) // Salvar o RecNo do VV0 para voltar
//
VVA->(DbSetOrder(1))
VVA->(DbSeek(TEMPA->VV9_FILIAL+TEMPA->VV9_NUMATE+TEMPA->VVA_CHASSI))
nRecVVA := VVA->(RecNo()) // Salvar o RecNo do VVA para voltar
//
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA))
//
SA3->(DbSetOrder(1))
SA3->(DbSeek(xFilial("SA3")+VV0->VV0_CODVEN))
//
FGX_VV1SB1("CHASSI", VVA->VVA_CHASSI , /* cMVMIL0010 */ , cGruVei )	 // Posiciona no VV1 com o CHASSI
nRecVV1 := VV1->(RecNo()) // Salvar o RecNo do VV1 para voltar
//
cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_ATENDVEI") // Remito
If Empty(cLocxNFPV)
	If Pergunte("PVXARG",.T.) .and. !Empty(MV_PAR01)
		cLocxNFPV := MV_PAR01
	Else
		Return
	EndIf
EndIf
cPV410   := cLocxNFPV // Variavel Private utilizada no a468nFatura
cIdPVArg := cIdPV := Posicione("CFH",1, xFilial("CFH")+cLocxNFPV,"CFH_IDPV")
//
cTESRem := VVA->VVA_CODTES
If ExistBlock("VXX02TEA") // Ponto de Entrada para manipular o TES Argentina
	aRet := ExecBlock("VXX02TEA", .f., .f., { "2" , VV0->VV0_FILIAL , VV0->VV0_NUMTRA })
	cTESRem  := aRet[1]
	lTelaTES := aRet[2]
	aRet := {}
EndIf
If lTelaTES
	aParamBox := {}
	AADD(aParamBox,{1,STR0010,cTESRem,"@!","VX0020101_Valida_TES_ARG('4',MV_PAR01,.f.)","SF4",".T.",50,.T.}) // TES para Remito
	If ParamBox(aParamBox,STR0010,@aRet,,,,,,,,.f.) // TES para Remito
		cTESRem := aRet[1] // TES
	Else
		Return .f.
	EndIf
EndIf
If !VX0020101_Valida_TES_ARG("4",cTESRem,.f.)
	Return .f.
EndIf
cQuery += "SELECT VV9.R_E_C_N_O_ "
cQuery += "  FROM "+RetSqlName("VV9")+" VV9 "
cQuery += "  JOIN "+RetSqlName("VV0")+" VV0 "
cQuery += "    ON VV0.VV0_FILIAL = VV9.VV9_FILIAL "
cQuery += "   AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE "
cQuery += "   AND VV0.VV0_SITNFI = '1'" // 1=Saida Valida
cQuery += "   AND VV0.VV0_GERFIN = '1'" // 1=Gerou Financeiro (Titulos)
cQuery += "   AND VV0.VV0_REMITO = ' '"
cQuery += "   AND VV0.VV0_FILREM = '"+xFilial("SD2")+"'"
cQuery += "   AND VV0.D_E_L_E_T_ = ' '"
cQuery += " WHERE VV9.VV9_FILIAL = '"+VV9->VV9_FILIAL+"'"
cQuery += "   AND VV9.VV9_NUMATE = '"+VV9->VV9_NUMATE+"'"
cQuery += "   AND VV9.VV9_STATUS = 'F'"
cQuery += "   AND VV9.D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) == 0
	FMX_HELP("VEIA351ERR02",STR0011) // Atendimento não esta mais disponível para geração de Remito de Entrega.
	// Refresh nos Browses
	oBrowseA:GoTop()
	oBrowseA:Refresh()
	oBrowseB:GoTop()
	oBrowseB:Refresh()
	Return
EndIf
//
Begin Transaction
//
IncProc(STR0012) // Gerando Pedido
//
cNumPed := CriaVar("C5_NUM")
aAdd(aCabPv,{"C5_NUM"    ,cNumPed			,Nil})				// Numero do pedido
aAdd(aCabPv,{"C5_TIPO"   ,"N"           	,Nil}) 				// Tipo de pedido
aAdd(aCabPv,{"C5_CLIENTE",SA1->A1_COD  		,Nil})				// Codigo do cliente
aAdd(aCabPv,{"C5_LOJACLI",SA1->A1_LOJA 		,Nil})				// Loja do cliente
aAdd(aCabPv,{"C5_TABELA" ,space(TamSX3("C5_TABELA")[1]),Nil})	// Tabela de Preco
aAdd(aCabPv,{"C5_CONDPAG",VV0->VV0_FORPAG	,Nil}) 				// Codigo da condicao de pagamento
aAdd(aCabPv,{"C5_VEND1"  ,VV0->VV0_CODVEN	,Nil}) 				// Codigo do vendedor
aAdd(aCabPv,{"C5_EMISSAO",dDataBase     	,Nil})				// Data de emissao
aAdd(aCabPv,{"C5_TRANSP" ,VV0->VV0_CODTRA	,Nil})				// Transportadora
aAdd(aCabPv,{"C5_DESC1"  ,0             	,Nil}) 				// Percentual de Desconto
aAdd(aCabPv,{"C5_BANCO"  ,VV0->VV0_CODBCO	,Nil})				// Banco
aAdd(aCabPv,{"C5_TIPLIB" ,"2"           	,Nil})				// Liberacao por Pedido de Venda
aAdd(aCabPv,{"C5_MOEDA"  ,IIf(VV0->VV0_MOEDA>0.and.VV0->VV0_MOEDA<=MoedFin(),VV0->VV0_MOEDA,1),Nil})				// Moeda
aAdd(aCabPv,{"C5_TXMOEDA",VV0->VV0_TXMOED	,Nil})				// Moeda
if SC5->(FieldPos("C5_PAISENT")) > 0 .and. !Empty(SA1->A1_PAIS) // Caso o país de entrega esteja preenchido é necessário informar o país no pedido
	aAdd(aCabPv,{"C5_PAISENT", Alltrim(SA1->A1_PAIS), NIL})
endif
aAdd(aCabPv,{"C5_LIBEROK","S"           	,Nil})				// Liberacao Total
aAdd(aCabPv,{"C5_COMIS1" ,SA3->A3_COMIS 	,Nil}) 				// Percentual de Comissao
aAdd(aCabPv,{"C5_DESPESA",VV0->VV0_DESACE	,Nil})				// Despesa Acessorio
If !Empty(VV0->VV0_TPFRET)
	aAdd(aCabPv,{"C5_TPFRETE",Alltrim(VV0->VV0_TPFRET),NIL})	// Tipo do Frete
EndIf
aAdd(aCabPv,{"C5_FRETE"  ,VV0->VV0_VALFRE 	,Nil})				// Valor Frete
If VV0->(FieldPos("VV0_PESOL")) > 0 .and. VV0->VV0_PESOL > 0
	aAdd(aCabPv,{"C5_PESOL",VV0->VV0_PESOL,Nil})				// Peso Liquido
EndIf
If VV0->(FieldPos("VV0_PBRUTO")) > 0 .and. VV0->VV0_PBRUTO > 0
	aAdd(aCabPv,{"C5_PBRUTO",VV0->VV0_PBRUTO,Nil})				// Peso Bruto
EndIf
If VV0->(FieldPos("VV0_VOLUME")) > 0 .and. VV0->VV0_VOLUME > 0
	aAdd(aCabPv,{"C5_VOLUME1",VV0->VV0_VOLUME,Nil})			// Volume
EndIf
If VV0->(FieldPos("VV0_ESPECI")) > 0 .and. !Empty(VV0->VV0_ESPECI)
	aAdd(aCabPv,{"C5_ESPECI1",VV0->VV0_ESPECI,Nil})			// Especie
EndIf
If VV0->(FieldPos("VV0_VEICUL")) > 0 .and. !Empty(VV0->VV0_VEICUL)
	aAdd(aCabPv,{"C5_VEICULO",VV0->VV0_VEICUL,Nil})			// Veiculo
EndIf		
If VV0->(FieldPos("VV0_SEGURO")) > 0 .and. VV0->VV0_SEGURO > 0
	aAdd(aCabPv,{"C5_SEGURO",VV0->VV0_SEGURO,Nil})				// Seguro
EndIf
If VV0->(FieldPos("VV0_TIPOCL")) > 0 .and. !Empty(VV0->VV0_TIPOCL) 
	aAdd(aCabPv,{"C5_TIPOCLI",VV0->VV0_TIPOCL ,Nil})			// Tipo de Cliente
Else
	aAdd(aCabPv,{"C5_TIPOCLI",SA1->A1_TIPO    ,Nil})			// Tipo de Cliente
EndIf
If VV0->(FieldPos("VV0_MENNOT")) > 0 .and. !Empty(VV0->VV0_MENNOT)
	aAdd(aCabPv,{"C5_MENNOTA",VV0->VV0_MENNOT ,Nil})			// Mensagem da NF
EndIf
If VV0->(FieldPos("VV0_MENPAD")) > 0 .and. !Empty(VV0->VV0_MENPAD)
	aAdd(aCabPv,{"C5_MENPAD" ,VV0->VV0_MENPAD ,Nil})			// Mensagem Padrao NF
EndIf                
If VV0->(FieldPos("VV0_CLIENT")) > 0 .and. !Empty(VV0->VV0_CLIENT)
	aAdd(aCabPv,{"C5_CLIENT" ,VV0->VV0_CLIENT ,Nil})			// Cliente Entrega
EndIf                
If VV0->(FieldPos("VV0_LOJENT")) > 0 .and. !Empty(VV0->VV0_LOJENT)
	aAdd(aCabPv,{"C5_LOJAENT" ,VV0->VV0_LOJENT ,Nil})			// Loja do cliente de entraga
EndIf                
If VV0->(FieldPos("VV0_PROVEN")) > 0 .and. !Empty(VV0->VV0_PROVEN)
	aAdd(aCabPv,{"C5_PROVENT"  ,VV0->VV0_PROVEN , Nil}) 	// Loja do cliente de entrega
Endif
If l1DUPNATAlt
	cNatureza := VXI02NAT("0","") // Natureza 0=Inicial
	If Empty(cNatureza)
		cNatureza := VXI02NAT("5",cNatureza) // Natureza de 5=Entradas
	EndIf
	aAdd(aCabPv,{"C5_NATUREZ" , cNatureza , Nil } ) // Natureza no Pedido
EndIf
aAdd(aCabPv,{"C5_DOCGER" , "2" , Nil } ) // Tipo de Documento ( 1 = Fatura / 2 = Remito  )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Almoxarifado de movimentacao do veiculo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLocVei := VV1->VV1_LOCPAD
If Empty(VV1->VV1_LOCPAD)
	cLocVei := GETMV("MV_LOCVEIN") //Novo
	If VV1->VV1_ESTVEI == "1"
		cLocVei := GETMV("MV_LOCVEIU") //Usado
	EndIf
	If VV1->VV1_SITVEI == "4" //Consignado
		cLocVei := GETMV("MV_LOCVEIC")
	EndIf
EndIf
//		
SF4->(DbSetOrder(1))
SF4->(MsSeek(xFilial("SF4")+cTESRem))
// ITEM do Pedido de Venda ³
aAdd(aIteTPv,{"C6_NUM"    ,cNumPed			,Nil}) // Numero do Pedido
aAdd(aIteTPv,{"C6_ITEM"   ,"01"				,Nil}) // Numero do Item no Pedido
aAdd(aIteTPv,{"C6_PRODUTO",SB1->B1_COD		,Nil}) // Codigo do Produto
aAdd(aIteTPv,{"C6_QTDVEN" ,1				,Nil}) // Quantidade Vendida
aAdd(aIteTPv,{"C6_PRUNIT" ,VVA->VVA_VALMOV	,Nil}) // Preco Unitario Liquido *
aAdd(aIteTPv,{"C6_PRCVEN" ,VVA->VVA_VALMOV	,Nil}) // Preco Unitario Liquido *
aAdd(aIteTPv,{"C6_VALOR"  ,VVA->VVA_VALMOV	,Nil}) // Valor Total do Item com Impostos
aAdd(aIteTPv,{"C6_CLI"    ,SA1->A1_COD		,Nil}) // Cliente
aAdd(aIteTPv,{"C6_LOJA"   ,SA1->A1_LOJA		,Nil}) // Loja do Cliente
aAdd(aIteTPv,{"C6_ENTREG" ,dDataBase		,Nil}) // Data da Entrega
aAdd(aIteTPv,{"C6_UM"     ,"UN"			   	,Nil}) // Unidade de Medida Primar.
aAdd(aIteTPv,{"C6_TES"    ,cTESRem			,Nil}) // Tipo de Entrada/Saida do Item
aAdd(aIteTPv,{"C6_LOCAL"  ,cLocVei			,Nil}) // Almoxarifado
aAdd(aIteTPv,{"C6_CLASFIS",SB1->B1_ORIGEM+SF4->F4_SITTRIB ,Nil}) // Classificacao Fiscal			
aAdd(aIteTPv,{"C6_COMIS1" ,SA3->A3_COMIS	,Nil}) // Comissao Vendedor
aAdd(aIteTPv,{"C6_DESCRI" ,SB1->B1_DESC		,Nil}) // Descricao do Produto
If SC6->(FieldPos("C6_CHASSI")) > 0
	aAdd(aIteTPv,{"C6_CHASSI" ,VV1->VV1_CHASSI,Nil}) // Chassi do Veiculo -  Descricao do Produto
Endif
If SC6->(FieldPos("C6_CC"))>0 .and. VVA->(FieldPos("VVA_CENCUS"))>0
	aAdd(aIteTPv,{"C6_CC" , VVA->VVA_CENCUS , Nil})
Endif
       
aAdd(aIteTPv,{"C6_TES"    ,cTESRem	,Nil}) // Tipo de Entrada/Saida do Item
If VV0->VV0_TIPFAT == "1" // Usado
	aUltMov := FM_VEIMOVS( VV1->VV1_CHASSI , "E"  )
	For ni := 1 to Len(aUltMov)                     
		If aUltMov[ni,5] == "0" // Entrada por Compra
			Dbselectarea("VVF")
			DbSetOrder(1)
			If DbSeek(aUltMov[ni,2]+aUltMov[ni,3])
				Dbselectarea("SD1")
				DbSetOrder(1)  
				If DbSeek(VVF->VVF_FILIAL+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD)
					aAdd(aIteTPv,{"C6_NFORI"   ,SD1->D1_DOC,Nil})
					aAdd(aIteTPv,{"C6_SERIORI" ,SD1->D1_SERIE,Nil})
					aAdd(aIteTPv,{"C6_ITEMORI" ,SD1->D1_ITEM,Nil})
				Endif
			EndIf
			Exit
		Endif
	Next
Endif
If ExistBlock("PEDVEI011")
	ExecBlock("PEDVEI011",.f.,.f.)
EndIf
aAdd(aItePv,aClone(aIteTPv))
CTB105MVC(.T.)
lMsErroAuto := .f.
MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItePv,3) //Faz Liberacao do Pedido se LiberOk = "S" e QtdLib = QtdEmp
CTB105MVC(.f.)
If lMsErroauto
	DisarmTransaction()
	RollbackSxe()
	MostraErro()
	break
EndIf
ConfirmSx8()
//		
IncProc(STR0013) // Gerando Remito 
//
SC5->(dbSetOrder(1))
SC5->(MsSeek(xFilial("SC5") + cNumPed ))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ LIBERACAO do Pedido de Venda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lCredito := .t.
lEstoque := .t.
lLiber   := .t.
lTransf  := .f.

SC9->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SC6->(MsSeek(xFilial("SC6") + SC5->C5_NUM + "01"))
While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == SC5->C5_NUM
	If !SC9->(MsSeek(xFilial("SC9")+SC5->C5_NUM+SC6->C6_ITEM))
		nQtdLib := SC6->C6_QTDVEN
		nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf)
	EndIf
	SC6->(dbSkip())
Enddo
//	
SC5->(dbSetOrder(1))
SC5->(MsSeek(xFilial("SC5") + cNumPed ))
SC9->(dbSetOrder(1))
SC9->(dbSeek(FWxFilial("SC9")+cNumPed+"01"))
SC6->(dbSetOrder(1))
SC6->(dbSeek(FWxFilial("SC6")+cNumPed+"01"))
aPvlNfs := {} // Limpar para ser utilizado nas funes abaixo
// Garante a liberao da SC6
Ma410LbNfs(2,@aPvlNfs,@aBloqueio) // verificar o abloqueio antes de chamar novamente  funo para liberar o C9
// Garante a liberao da SC9
Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
if !Empty(aPvlNfs) .And. Empty(aBloqueio) // Registra os itens bloqueados para serem mostrados após a transação
	aReg:={}
	for ni := 1 to Len(aPvlNfs)
		Aadd(aReg, aPvlNfs[ni][8])
	next
	Private lMSAuto := .T. // Para não mostrar a tela com os números das notas a serem geradas
	Pergunte("MT462A",.F.)
	mv_par09 := 2 // Garante que nao aparecerá a tela de lanamentos padro
	aParams := {;
				MV_PAR09,;     // Mostra Lanamentos
				MV_PAR10,;     // Aglutina Lnaamentos
				MV_PAR11,;     // Lanamento On-Line
				MV_PAR12,;     // Aglutina Pedidos
				01,;           // Fatura pedido pela (1) Moeda do Pedido; (2) Moeda Selecionas
				SC5->C5_MOEDA} // Fatura pela 1-Moeda 1; 2-Moeda 2; 3-Moeda 3; ...
	cMarcaSC9 := cMarca := GetMark(,'SC9','C9_OK')
	For ni := 1 To Len(aReg)
		SC9->(DbGoTo(aReg[ni]))
		RecLock("SC9",.F.)
		SC9->C9_OK := cMarca
		SC9->(MsUnLock())
	Next
	SetInvert(.F.)
	if !Empty(aRetMS := A462ANGera(Nil,cMarca,.T.,aReg,.F.,aParams))
		cSerie := aRetMS[1][1]
		cNota  := aRetMS[1][2]
		SF2->(DbSetOrder(1))
		SF2->(DbSeek(xFilial("SF2")+cNota+cSerie))
		cPreTit := SF2->F2_PREFIXO
	EndIf
	cPrefixo := &(GetNewPar("MV_1DUPREF","cSerie"))
	cPreTit := IIf(!Empty(cPreTit),cPreTit,cPrefixo)
	if Empty(cNota)
		DisarmTransaction()
		break
	endIf
else // Se houver bloqueio, não gera a nota fiscal
	FMX_HELP("VEIA351ERR03", STR0014, STR0015) // Ocorreu um bloqueio na liberação dos ítens durante a geração do remito. / Por favor, verifique!
	DisarmTransaction()
	break
EndIf
// Voltar o RecNo do VV9/VV0/VVA/VV1
VV9->(DbGoTo(nRecVV9))
VV0->(DbGoTo(nRecVV0))
VVA->(DbGoTo(nRecVVA))
VV1->(DbGoTo(nRecVV1))
// Atualiza Nota Fiscal
VXI020051_Atualiza_SF2( "2" , "" , cPrefVEI , cPreTit , SF2->F2_VALBRUT )
If SD2->(FieldPos("D2_CHASSI")) > 0
	VXI020061_Atualiza_D2_CHASSI( cNumPed+"01" , VVA->VVA_CHASSI ) // Atualiza SD2 CHASSI
EndIf
// Atualiza Atendimento
VXI020071_Atualiza_VV0( "2" , cNota , cSerie , cNumPed )
// Atualiza TES de Remito
If VVA->(FieldPos("VVA_TESREM")) > 0
	dbSelectarea("VVA")
	RecLock("VVA",.f.)
		VVA->VVA_TESREM := cTESRem
	MsUnlock()
EndIf
//
End Transaction
//
If !Empty(cNota) // Tela informando o Remito Gerado
	FMX_TELAINF( "1" , { { Alltrim(cSerie) , Alltrim(cNota) , STR0016 } } ) // GERADO
	If ExistBlock("NFSAIVEI")
		ExecBlock("NFSAIVEI",.f.,.f.,{cNota,cSerie})
	EndIf
EndIf
// Refresh nos Browses
oBrowseA:GoTop()
oBrowseA:Refresh()
oBrowseB:GoTop()
oBrowseB:Refresh()
Return

/*/{Protheus.doc} VA3510061_CancelarRemito
	Cancelar Remito de Entrega da Filial Logada

	@author Andre Luis Almeida
	@since 16/09/2025
/*/
Static Function VA3510061_CancelarRemito(oBrowseA,oBrowseB)
Local cQuery  := ""
Local cGruVei := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
//
If substr(FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_CANVEI","?"),6,1) $ " /0" // Sem permissão
	FMX_HELP("VEIA351ERR04",STR0018) // Usuário sem permissão para Cancelar.
	Return
EndIf
//
If !MsgYesNo(STR0020+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Confirma o cancelamento do Remito de Entrega?
			STR0009+": "+TEMPB->VVA_CHASSI+CHR(13)+CHR(10)+; // Chassi
			Alltrim(RetTitle("VV0_REMITO"))+": "+Alltrim(TEMPB->VV0_REMITO)+"-"+TEMPB->VV0_SERREM,;
			STR0002+": "+xFilial("SD2")) // Filial
	Return
EndIf
//
ProcRegua(3)
//
IncProc(STR0007) // Cancelar Remito de Entrega
//
VV9->(DbSetOrder(1))
VV9->(DbSeek(TEMPB->VV9_FILIAL+TEMPB->VV9_NUMATE))
//
VV0->(DbSetOrder(1))
VV0->(DbSeek(TEMPB->VV9_FILIAL+TEMPB->VV9_NUMATE))
nRecVV0 := VV0->(RecNo()) // Salvar o RecNo do VV0 para voltar
//
VVA->(DbSetOrder(1))
VVA->(DbSeek(TEMPB->VV9_FILIAL+TEMPB->VV9_NUMATE+TEMPB->VVA_CHASSI))
//
FGX_VV1SB1("CHASSI", VVA->VVA_CHASSI , /* cMVMIL0010 */ , cGruVei )	 // Posiciona no VV1 com o CHASSI
//
cQuery += "SELECT VV9.R_E_C_N_O_ "
cQuery += "  FROM "+RetSqlName("VV9")+" VV9 "
cQuery += "  JOIN "+RetSqlName("VV0")+" VV0 "
cQuery += "    ON VV0.VV0_FILIAL = VV9.VV9_FILIAL "
cQuery += "   AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE "
cQuery += "   AND VV0.VV0_SITNFI = '1'" // 1=Saida Valida
cQuery += "   AND VV0.VV0_GERFIN = '1'" // 1=Gerou Financeiro (Titulos)
cQuery += "   AND VV0.VV0_REMITO = '"+VV0->VV0_REMITO+"'"
cQuery += "   AND VV0.VV0_SERREM = '"+VV0->VV0_SERREM+"'"
cQuery += "   AND VV0.VV0_FILREM = '"+xFilial("SD2")+"'"
cQuery += "   AND VV0.D_E_L_E_T_ = ' '"
cQuery += " WHERE VV9.VV9_FILIAL = '"+VV9->VV9_FILIAL+"'"
cQuery += "   AND VV9.VV9_NUMATE = '"+VV9->VV9_NUMATE+"'"
cQuery += "   AND VV9.VV9_STATUS <> 'C'"
cQuery += "   AND VV9.D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) == 0
	FMX_HELP("VEIA351ERR05",STR0019) // Atendimento não esta mais disponível para cancelar o Remito de Entrega.
	// Refresh nos Browses
	oBrowseA:GoTop()
	oBrowseA:Refresh()
	oBrowseB:GoTop()
	oBrowseB:Refresh()
	Return
EndIf
//
IncProc(STR0007) // Cancelar Remito de Entrega
//
If VX0010058_CancNFArg(VV0->VV0_REMITO, VV0->VV0_SERREM, "2") // 1=Nota Normal / 2=Nota do Remito
	//
	IncProc(STR0007) // Cancelar Remito de Entrega
	//
	Begin Transaction
	If !VXI010051_cancela_Pedido_SC5_SC6( VV0->VV0_PEDREM )
		MostraErro()
		DisarmTransaction()
		break
	Else
		// Limpa os campos do Remito
		DbSelectArea("VV0")
		DbGoTo(nRecVV0)
		RecLock("VV0",.f.)
		VV0->VV0_REMITO := ""
		VV0->VV0_SERREM := ""
		VV0->VV0_PEDREM := ""
		MsUnlock()
		If Empty(VV0->VV0_NUMNFI) // Se não tem Fatura
			DBSelectArea("VV9")
			DBSetOrder(1)
			If DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA)
				Reclock("VV9",.f.)
					VV9->VV9_STATUS := "C" // Atualiza Status do Atendimento para Cancelado
				MsUnLock()
			EndIf
		EndIf
	EndIf
	End Transaction
EndIf
// Refresh nos Browses
oBrowseA:GoTop()
oBrowseA:Refresh()
oBrowseB:GoTop()
oBrowseB:Refresh()
Return

/*/{Protheus.doc} VA3510071_DevolverRemito
	Devolver Remito de Entrega da Filial Logada

	@author Andre Luis Almeida
	@since 23/09/2025
/*/
Static Function VA3510071_DevolverRemito(oBrowseA,oBrowseB)
Local cBkpFunName  := FunName()
Local lOkDev       := .t.
Local cQuery       := ""
Local cGruVei      := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local lTemFat      := .t.
Private cBrwCond2  := "" // Variavel utilizada no VEIXA002 - VXA002DEV()
Private cUsaGrVA   := GetNewPar("MV_MIL0010","0") // O Módulo de Veículos trabalhará com Veículos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
Private aRotina    := {}
Private nRecVVFNCC := 0 // Recno do VVF para gerar NCC
Private cCadastro  := STR0021 // Devolver Remito
//
If !MsgYesNo(STR0022+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Confirma a Devolução do Remito de Entrega?
			STR0009+": "+TEMPB->VVA_CHASSI+CHR(13)+CHR(10)+; // Chassi
			Alltrim(RetTitle("VV0_REMITO"))+": "+Alltrim(TEMPB->VV0_REMITO)+"-"+TEMPB->VV0_SERREM,;
			STR0002+": "+xFilial("SD2")) // Filial
	Return
EndIf
//
ProcRegua(3)
//
IncProc(STR0023) // Devolver Remito de Entrega
//
VV9->(DbSetOrder(1))
VV9->(DbSeek(TEMPB->VV9_FILIAL+TEMPB->VV9_NUMATE))
//
VV0->(DbSetOrder(1))
VV0->(DbSeek(TEMPB->VV9_FILIAL+TEMPB->VV9_NUMATE))
nRecVV0 := VV0->(RecNo()) // Salvar o RecNo do VV0 para voltar
lTemFat := !Empty(VV0->VV0_NUMNFI)
//
VVA->(DbSetOrder(1))
VVA->(DbSeek(TEMPB->VV9_FILIAL+TEMPB->VV9_NUMATE+TEMPB->VVA_CHASSI))
//
FGX_VV1SB1("CHASSI", VVA->VVA_CHASSI , /* cMVMIL0010 */ , cGruVei )	 // Posiciona no VV1 com o CHASSI
//
cQuery += "SELECT VV9.R_E_C_N_O_ "
cQuery += "  FROM "+RetSqlName("VV9")+" VV9 "
cQuery += "  JOIN "+RetSqlName("VV0")+" VV0 "
cQuery += "    ON VV0.VV0_FILIAL = VV9.VV9_FILIAL "
cQuery += "   AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE "
cQuery += "   AND VV0.VV0_SITNFI = '1'" // 1=Saida Valida
cQuery += "   AND VV0.VV0_GERFIN = '1'" // 1=Gerou Financeiro (Titulos)
cQuery += "   AND VV0.VV0_REMITO = '"+VV0->VV0_REMITO+"'"
cQuery += "   AND VV0.VV0_SERREM = '"+VV0->VV0_SERREM+"'"
cQuery += "   AND VV0.VV0_FILREM = '"+xFilial("SD2")+"'"
cQuery += "   AND VV0.D_E_L_E_T_ = ' '"
cQuery += " WHERE VV9.VV9_FILIAL = '"+VV9->VV9_FILIAL+"'"
cQuery += "   AND VV9.VV9_NUMATE = '"+VV9->VV9_NUMATE+"'"
cQuery += "   AND VV9.VV9_STATUS <> 'C'"
cQuery += "   AND VV9.D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) == 0
	FMX_HELP("VEIA351ERR06",STR0024) // Atendimento não esta mais disponível para devolver o Remito de Entrega.
	// Refresh nos Browses
	oBrowseA:GoTop()
	oBrowseA:Refresh()
	oBrowseB:GoTop()
	oBrowseB:Refresh()
	Return
EndIf
//
IncProc(STR0023) // Devolver Remito de Entrega
//
// Condição para validar dentro do VEIXA002
cBrwCond2 := "VV0->VV0_OPEMOV=='0' .AND. "
cBrwCond2 := "VV0->VV0_SITNFI=='1' .AND. "
If lTemFat
	cBrwCond2 := "!Empty(VV0->VV0_NUMNFI) .AND. "
EndIf
cBrwCond2 += "!Empty(VV0->VV0_REMITO) .AND. "
cBrwCond2 += "VV0->VV0_FILREM <> VV0->VV0_FILIAL "
//
SetFunName("VEIXA002") 
//
Begin Transaction
	lOkDev := VXA002DEV()
	If lOkDev .and. nRecVVFNCC > 0
		DbSelectArea("VVF")
		DbGoTo(nRecVVFNCC)
		If VVF->VVF_STANCC $ "1/2"
			RecLock("VVF",.f.)
				VVF->VVF_FILNCC := TEMPB->VV9_FILIAL
			MsUnLock()
		EndIf
	EndIf		
End Transaction
//
IncProc(STR0023) // Devolver Remito de Entrega
//
If lOkDev
	// Marca a SAIDA como Devolvida
	DbSelectArea("VV0")
	DbGoTo(nRecVV0)
	RecLock("VV0",.f.)
	VV0->VV0_SITNFI := "2" // Devolvida
	MsUnlock()
	//
	DBSelectArea("VV9")
	DBSetOrder(1)
	If DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA)
		Reclock("VV9",.f.)
			VV9->VV9_STATUS := "C" // Atualiza Status do Atendimento para Cancelado
		MsUnLock()
	EndIf
	//
	If lTemFat
		VX0000129_GeraNCC(nRecVVFNCC)
	EndIf
	//
EndIf
//
SetFunName(cBkpFunName)
//
// Refresh nos Browses
oBrowseA:GoTop()
oBrowseA:Refresh()
oBrowseB:GoTop()
oBrowseB:Refresh()
Return
