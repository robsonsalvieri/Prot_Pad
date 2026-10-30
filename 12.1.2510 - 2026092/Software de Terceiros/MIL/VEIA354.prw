#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA354.CH"

/*/{Protheus.doc} VEIA354

ARGENTINA - TRANSFERENCIA PARA ENTREGA EM OUTRA FILIAL - REMITO DE SAIDA

@author Andre Luis Almeida
@since 21/06/2026
/*/
Function VEIA354(oBrwVV0,cBkpFil)
Local oProcess // incluído o parâmetro lEnd para controlar o cancelamento da janela
Local lOkExec  := .f.
Local cTitTela := STR0001+" - "+STR0013+": "+cBkpFil // Geração do Remito de Saida / Filial
Local aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
					{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil}				,;
					{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }
Private oModel   := FWLoadModel("VEIA354")
Private oView    := FWLoadView("VEIA354")
Private oConf354 := VEIA354Config():New()
Private aAreaSM0 := SM0->(GetArea())

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
oModelPar := oModel:GetModel("PARMASTER")
// Buscar o ultimo SALVO
oModelPar:SetValue("F2_TRANSP" ,oConf354:GetValue("F2_TRANSP" , space(GetSx3Cache("F2_TRANSP" ,"X3_TAMANHO"))) )
if cPaisLoc == "ARG"
	oModelPar:SetValue("F2_PROVENT",oConf354:GetValue("F2_PROVENT", space(GetSx3Cache("F2_PROVENT","X3_TAMANHO"))) )
	oModelPar:SetValue("F2_NATUREZ",oConf354:GetValue("F2_NATUREZ", space(GetSx3Cache("F2_NATUREZ","X3_TAMANHO"))) )
endif
oModelPar:SetValue("VVA_TESREM",oConf354:GetValue("VVA_TESREM", space(GetSx3Cache("VVA_TESREM","X3_TAMANHO"))) )
oModelPar:SetValue("VVA_CENCUS",oConf354:GetValue("VVA_CENCUS", space(GetSx3Cache("VVA_CENCUS","X3_TAMANHO"))) )
oModelPar:SetValue("VVA_CONTA" ,oConf354:GetValue("VVA_CONTA" , space(GetSx3Cache("VVA_CONTA" ,"X3_TAMANHO"))) )
oModelPar:SetValue("VVA_ITEMCT",oConf354:GetValue("VVA_ITEMCT", space(GetSx3Cache("VVA_ITEMCT","X3_TAMANHO"))) )
oModelPar:SetValue("VVA_CLVL"  ,oConf354:GetValue("VVA_CLVL"  , space(GetSx3Cache("VVA_CLVL"  ,"X3_TAMANHO"))) )
//
CursorArrow()
oExec354 := FWViewExec():New()
oExec354:setModel(oModel)
oExec354:setView(oView)
oExec354:setTitle(cTitTela)
oExec354:setOK( { || VA3540031_TudoOK() })
oExec354:setCancel( { || .T. } )
oExec354:setOperation(MODEL_OPERATION_UPDATE)
oExec354:setReduction(10) // Redução de 10% da tela
oExec354:SetButtons(aButtons)
oExec354:openView(.f.)
lOkExec := (oExec354:getButtonPress() == 0)
oExec354:DeActivate()
If lOkExec
	oProcess := MsNewProcess():New({|lEnd| VA3540021_Processa( oBrwVV0 , cBkpFil , @oProcess , @lEnd ) },cTitTela,"",.T.)
	oProcess:Activate()
EndIf
//
Return lOkExec

Static Function ModelDef()
	Local oModel 
	Local oParametro := VA3540011_Campos_Parametros()
	Local oParamStru := oParametro:GetModel()
	oModel := MPFormModel():New( 'VEIA354', /* bPre */, /* bPost */ , { || .t. } /* bCommit */ , { || .T. } /* bCancel */ )
	oModel:AddFields('PARMASTER', /* cOwner */ , oParamStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )
	oModel:SetDescription(STR0002) // Parametros
	oModel:GetModel('PARMASTER'):SetDescription(STR0002) // Parametros
	oModel:GetModel('PARMASTER'):SetOnlyQuery( .T. )
	oModel:SetPrimaryKey({})
Return oModel

Static Function ViewDef()
	Local oModel	:= FWLoadModel( 'VEIA354' )
	Local oView 	:= Nil
	Local oParametro := VA3540011_Campos_Parametros()
	Local oParamStru := oParametro:GetView()
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_PARAM', oParamStru , 'PARMASTER')
	oView:EnableTitleView('FORM_PARAM',STR0002) // Parametros
	oView:CreateHorizontalBox('TELA_PARAM',100) //,,.t.)
	oView:SetOwnerView('FORM_PARAM','TELA_PARAM')
	oView:SetCloseOnOk({||.T.})
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 
	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL
	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)
Return oView

/*/
{Protheus.doc} VA3540011_Campos_Parametros
Monta Campos da Grid de Parametros

@author Andre Luis Almeida
@since 21/06/2026
/*/
Static Function VA3540011_Campos_Parametros()
Local oRetorno := OFDMSStruct():New()
if cPaisLoc == "ARG"
	oRetorno:AddFieldDictionary( "VV0" , "VV0_FILREM" , { { 'bValid' , VA3540041_Valid('VV0_FILREM',.t.,'VX001003B_ValidaFilial(xFilial("SD2"),M->VV0_FILREM,aAreaSM0)') } , { 'cTitulo' , STR0003 } , { 'cLookUp' , "SM0" } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } ) // Filial Destino
endif
oRetorno:AddFieldDictionary( "SF2" , "F2_TRANSP"  , { { 'bValid' , VA3540041_Valid('F2_TRANSP' ,.t.,'ExistCpo("SA4",,1)') } , { 'lCanChange' , .t. } , { 'lObrigat' , .f. } } )
if cPaisLoc == "ARG"
	oRetorno:AddFieldDictionary( "SF2" , "F2_PROVENT" , { { 'bValid' , VA3540041_Valid('F2_PROVENT',.t.,'ExistCpo("SX5","12"+M->F2_PROVENT)') } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } )
	oRetorno:AddFieldDictionary( "SF2" , "F2_NATUREZ" , { { 'bValid' , VA3540041_Valid('F2_NATUREZ',.t.,'ExistCpo("SED",,1)') } , { 'lCanChange' , .t. } , { 'cLookUp' , "SED" } , { 'lObrigat' , .t. } } )
	oRetorno:AddFieldDictionary( "VVA" , "VVA_TESREM" , { { 'bValid' , VA3540041_Valid('VVA_TESREM',.t.,'(Existcpo("SF4",,1).and.MaAvalTes("S",M->VVA_TESREM).and.VX0020101_Valida_TES_ARG("4",M->VVA_TESREM))') } , { 'lCanChange' , .t. } , { 'lObrigat' , .t. } } )
endif
oRetorno:AddFieldDictionary( "VVA" , "VVA_CENCUS" , { { 'bValid' , VA3540041_Valid('VVA_CENCUS',.t.,'ExistCpo("CTT",,1)') } , { 'lCanChange' , .t. } } )
oRetorno:AddFieldDictionary( "VVA" , "VVA_CONTA"  , { { 'bValid' , VA3540041_Valid('VVA_CONTA' ,.t.,'ExistCpo("CT1",,1)') } , { 'lCanChange' , .t. } } )
oRetorno:AddFieldDictionary( "VVA" , "VVA_ITEMCT" , { { 'bValid' , VA3540041_Valid('VVA_ITEMCT',.t.,'ExistCpo("CTD",,1)') } , { 'lCanChange' , .t. } } )
oRetorno:AddFieldDictionary( "VVA" , "VVA_CLVL"   , { { 'bValid' , VA3540041_Valid('VVA_CLVL'  ,.t.,'ExistCpo("CTH",,1)') } , { 'lCanChange' , .t. } } )
Return oRetorno

/*/
{Protheus.doc} VA3540021_Processa
Processa

@author Andre Luis Almeida
@since 22/06/2026
/*/
Static Function VA3540021_Processa( oBrwVV0 , cBkpFil , oProcess , lEnd )
Local lOkExec     := .f.
Local cProcesso   := STR0004 // Gerando Remito de Saida
Local ni        := 0
Local cGruVei   := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cNumPed   := ""
Local cLocVei   := ""
Local cQuery    := ""
Local cPrefixo  := space(TamSX3("E1_PREFIXO")[1])
Local cPreTit   := &(GetNewPar("MV_PTITVEI","''")) // Prefixo dos Titulos de Veiculos
Local cPrefVEI  := GetNewPar("MV_PREFVEI","VEI")
Local aItePv    := {}
Local aBloqueio := {}
Local oFilHlp   := DMS_FilialHelper():New()
Local aCliLjDest:= {}
Local aVWC      := {}
Private aCabPv    := {}
Private aIteTPv   := {}
Private cLocxNFPV := ""
Private lLocxAuto := .F.
Private cIdPVArg  := ""
Private cPV410    := ""
Private cIdPV     := ""
//
VV9->(DbSetOrder(1))
VV9->(DbSeek(TEMPVV0->VV9_FILIAL+TEMPVV0->VV9_NUMATE))
nRecVV9 := VV9->(RecNo()) // Salvar o RecNo do VV9 para voltar
//
VV0->(DbSetOrder(1))
VV0->(DbSeek(TEMPVV0->VV9_FILIAL+TEMPVV0->VV9_NUMATE))
nRecVV0 := VV0->(RecNo()) // Salvar o RecNo do VV0 para voltar
//
VVA->(DbSetOrder(1))
VVA->(DbSeek(TEMPVV0->VV9_FILIAL+TEMPVV0->VV9_NUMATE+TEMPVV0->VVA_CHASSI))
nRecVVA := VVA->(RecNo()) // Salvar o RecNo do VVA para voltar
//
SA3->(DbSetOrder(1))
SA3->(DbSeek(xFilial("SA3")+VV0->VV0_CODVEN))
//
FGX_VV1SB1("CHASSI", VVA->VVA_CHASSI , /* cMVMIL0010 */ , cGruVei )	 // Posiciona no VV1 com o CHASSI
nRecVV1 := VV1->(RecNo()) // Salvar o RecNo do VV1 para voltar
//
aCliLjDest := oFilHlp:GetCodCli(M->VV0_FILREM, .T.) //  Busca Codigo e Loja de Cliente da Filial Destino (Remito)
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+aCliLjDest[1]+aCliLjDest[2]))
nRecSA1 := SA1->(RecNo()) // Salvar o RecNo do SA1 para voltar
//
cFilAnt := cBkpFil
//
cNota  := ""
cSerie := ""
//
VISUALIZA := .f.
INCLUI 	  := .t.
ALTERA 	  := .f.
EXCLUI 	  := .f.
//
oProcess:SetRegua1(0)
oProcess:IncRegua1(STR0005) // Processando...
oProcess:SetRegua2(4)
oProcess:IncRegua2(STR0006) // Ponto de Venda
//
cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_TRANSFER") // Remito ( mesmo Ponto de Venda da Transferencia de Veiculos )
If Empty(cLocxNFPV)
	If Pergunte("PVXARG",.T.) .and. !Empty(MV_PAR01)
		cLocxNFPV := MV_PAR01
	Else
		Return .f.
	EndIf
EndIf
cPV410   := cLocxNFPV // Variavel Private utilizada no a468nFatura
cIdPVArg := cIdPV := Posicione("CFH",1, xFilial("CFH")+cLocxNFPV,"CFH_IDPV")
lOkExec := F083ExtSFP(cLocxNFPV, .T.)
If !lOkExec
	Return .f.
EndIf
//
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
	FMX_HELP("VEIA352ERR01",STR0007) // Atendimento não esta mais disponível para geração de Remito de Transferência.
	// Refresh nos Browses
	oBrwVV0:GoTop()
	oBrwVV0:Refresh()
	Return .f.
EndIf
//
Begin Transaction
//
oProcess:IncRegua2(cProcesso)
//
cNumPed := CriaVar("C5_NUM")
aAdd(aCabPv,{"C5_NUM"    ,cNumPed			,Nil})				// Numero do pedido
aAdd(aCabPv,{"C5_TIPO"   ,"N"           	,Nil}) 				// Tipo de pedido
aAdd(aCabPv,{"C5_CLIENTE",SA1->A1_COD  		,Nil})				// Codigo do cliente
aAdd(aCabPv,{"C5_LOJACLI",SA1->A1_LOJA 		,Nil})				// Loja do cliente
aAdd(aCabPv,{"C5_TABELA" ,space(TamSX3("C5_TABELA")[1]),Nil})	// Tabela de Preco
aAdd(aCabPv,{"C5_CONDPAG",RetCondVei()		,Nil}) 				// Codigo da condicao de pagamento
aAdd(aCabPv,{"C5_VEND1"  ,VV0->VV0_CODVEN	,Nil}) 				// Codigo do vendedor
aAdd(aCabPv,{"C5_EMISSAO",dDataBase     	,Nil})				// Data de emissao
aAdd(aCabPv,{"C5_TRANSP" ,M->F2_TRANSP		,Nil})				// Transportadora
aAdd(aCabPv,{"C5_DESC1"  ,0             	,Nil}) 				// Percentual de Desconto
aAdd(aCabPv,{"C5_BANCO"  ,VV0->VV0_CODBCO	,Nil})				// Banco
aAdd(aCabPv,{"C5_TIPLIB" ,"2"           	,Nil})				// Liberacao por Pedido de Venda
aAdd(aCabPv,{"C5_MOEDA"  ,IIf(VV0->VV0_MOEDA>0.and.VV0->VV0_MOEDA<=MoedFin(),VV0->VV0_MOEDA,1),Nil})				// Moeda
aAdd(aCabPv,{"C5_TXMOEDA",VV0->VV0_TXMOED	,Nil})				// Moeda
if SC5->(FieldPos("C5_PAISENT")) > 0 .and. !Empty(SA1->A1_PAIS) // Caso o país de entrega esteja preenchido é necessário informar o país no pedido
	aAdd(aCabPv,{"C5_PAISENT", Alltrim(SA1->A1_PAIS), NIL})
endif
aAdd(aCabPv,{"C5_LIBEROK","S"           	,Nil})	// Liberacao Total
aAdd(aCabPv,{"C5_COMIS1" ,SA3->A3_COMIS 	,Nil})	// Percentual de Comissao
aAdd(aCabPv,{"C5_TIPOCLI",SA1->A1_TIPO		,Nil})	// Tipo de Cliente
aAdd(aCabPv,{"C5_PROVENT",M->F2_PROVENT		,Nil}) 	// Loja do cliente de entrega
aAdd(aCabPv,{"C5_NATUREZ",M->F2_NATUREZ		, Nil } ) // Natureza no Pedido
aAdd(aCabPv,{"C5_DOCGER" , "2" , Nil } ) // Tipo de Documento ( 1 = Fatura / 2 = Remito  )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Almoxarifado de movimentacao do veiculo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLocVei := VV1->VV1_LOCPAD
If Empty(VV1->VV1_LOCPAD)
	cLocVei := IIf(VV1->VV1_ESTVEI<>"1",GETMV("MV_LOCVEIN"),GETMV("MV_LOCVEIU")) //Novo/Usado
	cLocVei := IIf(VV1->VV1_SITVEI=="4",GETMV("MV_LOCVEIC"),cLocVei) //Consignado
EndIf
//		
SF4->(DbSetOrder(1))
SF4->(MsSeek(xFilial("SF4")+M->VVA_TESREM))
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
aAdd(aIteTPv,{"C6_TES"    ,M->VVA_TESREM	,Nil}) // Tipo de Entrada/Saida do Item
aAdd(aIteTPv,{"C6_LOCAL"  ,cLocVei			,Nil}) // Almoxarifado
aAdd(aIteTPv,{"C6_CLASFIS",SB1->B1_ORIGEM+SF4->F4_SITTRIB ,Nil}) // Classificacao Fiscal			
aAdd(aIteTPv,{"C6_COMIS1" ,SA3->A3_COMIS	,Nil}) // Comissao Vendedor
aAdd(aIteTPv,{"C6_DESCRI" ,SB1->B1_DESC		,Nil}) // Descricao do Produto
If SC6->(FieldPos("C6_CHASSI")) > 0
	aAdd(aIteTPv,{"C6_CHASSI" ,VV1->VV1_CHASSI,Nil}) // Chassi do Veiculo -  Descricao do Produto
Endif
If SC6->(FieldPos("C6_CONTA"))>0 .and. VVA->(FieldPos("VVA_CONTA"))>0
	aAdd(aIteTPv,{"C6_CONTA" , M->VVA_CONTA , Nil})
Endif
If SC6->(FieldPos("C6_CC"))>0 .and. VVA->(FieldPos("VVA_CENCUS"))>0
	aAdd(aIteTPv,{"C6_CC" , M->VVA_CENCUS 	, Nil})
Endif
If SC6->(FieldPos("C6_ITEMCTA"))>0 .and. VVA->(FieldPos("VVA_ITEMCT"))>0
	aAdd(aIteTPv,{"C6_ITEMCTA" , M->VVA_ITEMCT , Nil})
Endif
If SC6->(FieldPos("C6_CLVL"))>0 .and. VVA->(FieldPos("VVA_CLVL"))>0
	aAdd(aIteTPv,{"C6_CLVL" , M->VVA_CLVL 	, Nil})
Endif
aAdd(aIteTPv,{"C6_TES"    ,M->VVA_TESREM	,Nil}) // Tipo de Entrada/Saida do Item
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
oProcess:IncRegua2(cProcesso)
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
	FMX_HELP("VEIA352ERR02",STR0008,STR0009) // Ocorreu um bloqueio na liberação dos ítens durante a geração do Remito. / Por favor, verifique!
	DisarmTransaction()
	break
EndIf
oProcess:IncRegua2(cProcesso)
// Voltar o RecNo do SA1/VV9/VV0/VVA/VV1
SA1->(DbGoTo(nRecSA1))
VV9->(DbGoTo(nRecVV9))
VV0->(DbGoTo(nRecVV0))
VVA->(DbGoTo(nRecVVA))
VV1->(DbGoTo(nRecVV1))
// Atualiza Nota Fiscal
VXI020051_Atualiza_SF2( "2" , "" , cPrefVEI , cPreTit , SF2->F2_VALBRUT )
If SD2->(FieldPos("D2_CHASSI")) > 0
	VXI020061_Atualiza_D2_CHASSI( cNumPed+"01" , VVA->VVA_CHASSI ) // Atualiza SD2 CHASSI
EndIf

dbSelectarea("VV0")
RecLock("VV0",.f.)
	VV0->VV0_FILREM := "**" // ** PARA FICAR AGUARDANDO ENTRADA E NAO DEIXAR ENTREGAR
VV0->(MsUnLock())

aAdd(aVWC,{ "VWC_FILTRA" , VV0->VV0_FILIAL })
aAdd(aVWC,{ "VWC_NUMTRA" , VV0->VV0_NUMTRA })
aAdd(aVWC,{ "VWC_FILSAI" , xFilial("SD2") })
aAdd(aVWC,{ "VWC_REMSAI" , cNota })
aAdd(aVWC,{ "VWC_SRESAI" , cSerie })
aAdd(aVWC,{ "VWC_CLISAI" , SA1->A1_COD })
aAdd(aVWC,{ "VWC_LOJSAI" , SA1->A1_LOJA })
aAdd(aVWC,{ "VWC_PEDSAI" , cNumPed })
aAdd(aVWC,{ "VWC_DATSAI" , dDataBase })
aAdd(aVWC,{ "VWC_HORSAI" , val(substr(time(),1,2)+substr(time(),4,2)) })
aAdd(aVWC,{ "VWC_USRSAI" , __cUserID })
aAdd(aVWC,{ "VWC_FILENT" , M->VV0_FILREM })
aAdd(aVWC,{ "VWC_STATUS" , "1" }) // 1=Saida Efetivada aguardando Entrada
VA3530011_MVC_CAD_VWC( 0 , aVWC )

End Transaction
//
If !Empty(cNota) // Tela informando o Remito Gerado
	FMX_TELAINF( "1" , { { Alltrim(cSerie) , Alltrim(cNota) , STR0010 } } ) // GERADO
EndIf
// Refresh nos Browses
oBrwVV0:GoTop()
oBrwVV0:Refresh()
Return(!Empty(cNota))

/*/
{Protheus.doc} VA3540031_TudoOK
Tudo Ok Tela

@author Andre Luis Almeida
@since 21/06/2026
/*/
Static Function VA3540031_TudoOK()
Local jJson := JsonObject():New()
// SALVAR INFORMACOES PARA PROXIMA EXECUCAO
jJson["VV0_FILREM"] := M->VV0_FILREM
jJson["F2_TRANSP"]  := M->F2_TRANSP 
jJson["F2_PROVENT"] := M->F2_PROVENT
jJson["F2_NATUREZ"] := M->F2_NATUREZ
jJson["VVA_TESREM"] := M->VVA_TESREM
jJson["VVA_CENCUS"] := M->VVA_CENCUS
jJson["VVA_CONTA"]  := M->VVA_CONTA 
jJson["VVA_ITEMCT"] := M->VVA_ITEMCT
jJson["VVA_CLVL"]   := M->VVA_CLVL  
oConf354:Save(jJson)
Return .t.

/*/
{Protheus.doc} VA3540041_Valid
Monta o VALID do prw e carrega VALIDUSER dos campos

@author Andre Luis Almeida
@since 21/06/2026
/*/
Static Function VA3540041_Valid(cCpo,lVazio,cVldPRW)
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
{Protheus.doc} VA3540051_Cancelar_Saida
Cancelar Remito de Saida

@author Andre Luis Almeida
@since 23/06/2026
/*/
Function VA3540051_Cancelar_Saida()
Local lOkExec := .f.
Local nRecVWC := VWC->(RecNo())
Local nRecVV0 := 0
Local aVWC    := {}
Local aInfo   := {}
//
ProcRegua(3)
IncProc(STR0011) // Cancelamento do Remito de Saida
//
VV0->(DbSetOrder(1))
VV0->(DbSeek(VWC->VWC_FILTRA+VWC->VWC_NUMTRA))
nRecVV0 := VV0->(RecNo()) // Salvar o RecNo do VV0 para voltar
//
If Alltrim(VV0->VV0_FILREM) <> "**"
	FMX_HELP("VEIA352ERR03",STR0012) // Transferência não esta mais disponível para o Cancelamento.
EndIf
//
AAdd(aInfo, { Alltrim(VWC->VWC_SRESAI) , Alltrim(VWC->VWC_REMSAI) , "CANCELADO" } ) // CANCELADO
DbSelectArea("SF2")
DbSetOrder(1)
DbSeek(xFilial("SF2") + VWC->VWC_REMSAI + VWC->VWC_SRESAI )
lOkExec := VX0010058_CancNFArg(VWC->VWC_REMSAI,VWC->VWC_SRESAI,"2") // 1=Nota Normal / 2=Remito
If lOkExec
	IncProc(STR0011) // Cancelamento do Remito de Saida
	lOkExec := VXI010051_cancela_Pedido_SC5_SC6( VWC->VWC_PEDSAI )
EndIf
If lOkExec
	IncProc(STR0011) // Cancelamento do Remito de Saida
	DbSelectArea("VWC")
	DbGoto(nRecVWC)
	DbSelectArea("VV0")
	DbGoto(nRecVV0)
	RecLock("VV0",.f.)
		VV0->VV0_FILREM := VWC->VWC_FILSAI
	VV0->(MsUnLock())
	aAdd(aVWC,{ "VWC_STATUS" , "4" }) // Transferência Cancelada
	VA3530011_MVC_CAD_VWC( nRecVWC , aVWC )
	FMX_TELAINF( "1" , aInfo )
EndIf
Return lOkExec

/*/{Protheus.doc} VEIA354Config
	Transferencia para Entrega em outra Filial - ARGENTINA
	Classe principal para tratar os dados da parametrização da Geração de Remito de Saida
	
	@type class
	@author Andre Luis Almeida
	@since 21/06/2026
/*/
Class VEIA354Config
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
	@since 21/06/2026
/*/
Method New() Class VEIA354Config
	::cCodigo  := "VEIA354"
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
	@since 21/06/2026
/*/
Method GetValue(cLabel, xDef) Class VEIA354Config
	if self:jConfig:hasProperty(cLabel)
		return self:jConfig[cLabel]
	endif
Return xDef

/*/{Protheus.doc} SetValue
	Seta o valor do parametro no json

	@type method
	@author Andre Luis Almeida
	@since 21/06/2026
/*/
Method SetValue(cAttr, xValue) Class VEIA354Config
	self:jConfig[cAttr] := xValue
Return .t.

/*/{Protheus.doc} Save
	salva json com a configuração

	@type method
	@author Andre Luis Almeida
	@since 21/06/2026
/*/
Method Save(jConfig) Class VEIA354Config
	dbselectArea("VRN")
	dbSetOrder(2)
	If dbSeek(xFilial("VRN") + self:cFilConf + self:cCodigo)
		reclock("VRN", .F.)
		VRN->VRN_CONFIG := jConfig:toJSON()
		VRN->(msUnlock())
	EndIf
	self:jConfig := jConfig
Return .t.