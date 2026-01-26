#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA470.CH"

/*/{Protheus.doc} OFIA470
	Saida de Serviços Especializados

	@author Andre Luis Almeida
	@since 20/09/2022
/*/
Function OFIA470()
Local aSize       := FWGetDialogSize( oMainWnd )
Local nTamNFI     := GeTSX3Cache("VRR_NUMNFI","X3_TAMANHO")
Private cCadastro := STR0001 // Saida de Serviços Especializados
Private M->C5_ESTPRES := "" // Utilizado na consulta padrão CC2SC5

If !OA4500071_Validar_VRQ_SERINT() // Valida o Tamanho do campo VRQ_SERINT
	Return
EndIf

oDlgOA470 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oBrwVRR := FWMBrowse():New()
oBrwVRR:SetAlias('VRR')
oBrwVRR:SetDescription(cCadastro)
oBrwVRR:SetOwner(oDlgOA470)
oBrwVRR:AddLegend( 'VRR->VRR_STATUS == "0"' , 'BR_BRANCO'   , STR0002 ) // Saida Digitada
oBrwVRR:AddLegend( 'VRR->VRR_STATUS == "3"' , 'BR_LARANJA'  , STR0003 ) // Pendências - Aguadando Liberação
oBrwVRR:AddLegend( 'VRR->VRR_STATUS == "5"' , 'BR_MARROM'   , STR0004 ) // Liberação de Pendências Reprovada
oBrwVRR:AddLegend( 'VRR->VRR_STATUS == "4"' , 'BR_AZUL'     , STR0005 ) // Liberado para Efetivar Saida
oBrwVRR:AddLegend( 'VRR->VRR_STATUS == "1"' , 'BR_VERDE'    , STR0006 ) // Saida Efetivada
oBrwVRR:AddLegend( 'VRR->VRR_STATUS == "2"' , 'BR_VERMELHO' , STR0007 ) // Saida Cancelada
oBrwVRR:AddFilter(STR0008, "@ VRR_NUMNFI <> '"+space(nTamNFI)+"'") // Com Nota Fiscal
oBrwVRR:AddFilter(STR0009, "@ VRR_NUMNFI = '"+space(nTamNFI)+"'") // Sem Nota Fiscal
oBrwVRR:DisableDetails()
oBrwVRR:DisableLocate()
oBrwVRR:SetAmbiente(.F.)
oBrwVRR:SetWalkthru(.F.)
oBrwVRR:SetUseFilter()
oBrwVRR:ForceQuitButton()
oBrwVRR:Activate()

oDlgOA470:Activate( , , , , , , ) //ativa a janela

Return

Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0010 ACTION 'OA4700051_VisualizarSaida()' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.OFIA470' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.OFIA470' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0013 ACTION 'OA4700031_CancelarSaida()' OPERATION 5 ACCESS 0 // Cancelar
	ADD OPTION aRotina TITLE STR0014 ACTION 'OA4700151_ImprimirSaida()' OPERATION 8 ACCESS 0 // Imprimir Dados da Saida
	ADD OPTION aRotina TITLE STR0089 ACTION 'OA470018C_BancoConhecimento()' OPERATION 6 ACCESS 0 // Banco de Conhecimento
	ADD OPTION aRotina TITLE STR0091 ACTION 'OFIA477()' OPERATION 9 ACCESS 0 // Liberações pendentes
	If ExistBlock("ORCSRVE") 
		ADD OPTION aRotina TITLE STR0092 ACTION 'OA470019H_ImprimirOrcamento()' OPERATION 7 ACCESS 0 // Imprimir Orçamento de Venda
	EndIf
Return aRotina


Static Function ModelDef()
Local oStrVRR := FWFormStruct(1,"VRR")
Local oStrVRS := FWFormStruct(1,"VRS")
Local oStrVS9 := FWFormStruct(1,"VS9")

oModel := MPFormModel():New("OFIA470", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oStrVS9:SetProperty("VS9_TIPPAG", MODEL_FIELD_WHEN, { || .t. })
oStrVS9:SetProperty("VS9_TIPPAG", MODEL_FIELD_VALID, {|oModel,y| .t. })
oStrVS9:SetProperty("VS9_DATPAG", MODEL_FIELD_VALID, {|oModel,y| M->VS9_DATPAG>=DDATABASE })
oStrVS9:SetProperty("VS9_VALPAG", MODEL_FIELD_VALID, {|oModel,y| M->VS9_VALPAG>0 })

oModel:AddFields("VRRMASTER",/*cOwner*/ , oStrVRR)
oModel:AddGrid( "VRSDETAIL" , "VRRMASTER", oStrVRS , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VRSDETAIL", {{'VRS_FILIAL','VRR_FILIAL'}, {'VRS_CODVRR','VRR_CODIGO'}}, VRS->(IndexKey(1)) )
oModel:AddGrid( "VS9DETAIL" , "VRRMASTER", oStrVS9 , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VS9DETAIL", {{'VS9_FILIAL','VRR_FILIAL'}, {'VS9_NUMIDE','VRR_CODIGO'}, {'VS9_TIPOPE','"E"'}}, VS9->(IndexKey(1)) )

oModel:GetModel("VRRMASTER"):SetDescription(STR0001) // Saida de Serviços Especializados
oModel:GetModel("VRSDETAIL"):SetDescription(STR0015) // Serviços Especializados
oModel:GetModel("VRSDETAIL"):SetOptional(.f.) // Não deixa passar com os Serviços em branco
oModel:GetModel("VS9DETAIL"):SetDescription(STR0016) // Parcelas
oModel:GetModel("VS9DETAIL"):SetOptional(.T.) // Deixa passar com as Parcelas em branco

oModel:GetModel("VS9DETAIL"):SetNoInsertLine(.T.) // Nao deixa INCLUIR as linhas do VS9
oModel:GetModel("VS9DETAIL"):SetNoDeleteLine(.T.) // Nao deixa DELETAR as linhas do VS9

oModel:SetDescription(STR0001) // Saida de Serviços Especializados
//oModel:InstallEvent("OFIA470LOG", /*cOwner*/, MVCLOGEV():New("OFIA470") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("OFIA470EVDEF", /*cOwner*/, OFIA470EVDEF():New() )

oModel:AddRules( 'VRRMASTER', 'VRR_LOJCLI', 'VRRMASTER', 'VRR_CODCLI', 3)

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 02/09/2022
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVRR:= FWFormStruct(2,"VRR", { |cCampo| !ALLTRIM(cCampo) $ "VRR_CODIGO/" } )
Local oStrVRS:= FWFormStruct(2,"VRS", { |cCampo| !ALLTRIM(cCampo) $ "VRS_CODIGO/VRS_CODVRR/" } )
Local oStrVS9:= FWFormStruct(2,"VS9", { |cCampo| !ALLTRIM(cCampo) $ "VS9_NUMIDE/VS9_DESPAG/VS9_TIPOPE/VS9_DATBAI/VS9_NATSRV/VS9_TIPFEC/VS9_TIPTIT/VS9_SEQPRO/VS9_ENTRAD/VS9_SEQTAR/VS9_PARCEL/VS9_TIPTEM/VS9_LIBVOO/VS9_PARCVD/VS9_OBSMEM/VS9_OBSPAR/" } )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:SetCloseOnOk({||.T.})

oView:AddField( 'VIEW_VRR', oStrVRR, 'VRRMASTER' )
oView:AddGrid( 'VIEW_VRS' , oStrVRS, 'VRSDETAIL' )
oView:AddGrid( 'VIEW_VS9' , oStrVS9, 'VS9DETAIL' )

oView:SetViewAction( 'DELETELINE', { |oView,cIdView,nNumLine| OA4700061_DeleteLine( oView,cIdView,nNumLine ) } )
oView:SetViewAction( 'UNDELETELINE', { |oView,cIdView,nNumLine| OA4700071_UnDeleteLine( oView,cIdView,nNumLine ) } )

// definição de como será a tela
oView:CreateHorizontalBox('TOPO'  , 40)
oView:CreateHorizontalBox('CENTRO' , 60)

oView:createVerticalBox('CABEC', 55, 'TOPO')
oView:createVerticalBox('PARC' , 45, 'TOPO')

oView:SetOwnerView('VIEW_VRR', 'CABEC' )
oView:SetOwnerView('VIEW_VRS', 'CENTRO')
oView:SetOwnerView('VIEW_VS9', 'PARC' )

oView:EnableTitleView('VIEW_VS9', STR0016 ) // Parcelas

oView:AddUserButton(STR0017,'PRODUTO', {|| OA4700141_VisualizaValorMinimo() }) // Visualiza Valor Desejado x Valor Minimo
oView:AddUserButton("<F4> "+STR0018,'PRODUTO', {|| OA4700101_VerEstoque() }) // Visualiza Estoque do Serviço Especializado posicionado
oView:AddUserButton(STR0014,'IMPRESSAO', {|| OA4700171_ValidaImpressao() }) // Imprimir Dados da Saida
oView:AddUserButton(STR0019,'PRODUTO', {|| OA4700181_VisualizaImpostos() }) // Visualiza Impostos

Return oView

/*/{Protheus.doc} OA4700011_GravaStatusSaida
Grava Status da Saida

@author Andre Luis Almeida
@since 06/09/2022
/*/
Function OA4700011_GravaStatusSaida( cCodigo , cStatus )
Local oModVRR   := FWLoadModel( 'OFIA475' ) // MVC somente para atualizar o cabeçalho VRR
Default cCodigo := ""
Default cStatus := "0" // 0=Saida Digitada
VRR->(DbSetOrder(1))
If VRR->(DbSeek(xFilial("VRR")+cCodigo))
	If cStatus <> VRR->VRR_STATUS
		// Gravar Status
		oModVRR:SetOperation( MODEL_OPERATION_UPDATE )
		If oModVRR:Activate()
			oModVRR:SetValue( "VRRMASTER" , "VRR_STATUS" , cStatus ) // 0=Saida Digitada / 3=Pendências - Aguadando Liberação / 5=Liberação de Pendências Reprovada / 4=Liberado para Efetivar Saida / 1=Saida Efetivada / 2=Saida Cancelada
			If oModVRR:VldData()
				oModVRR:CommitData()
			EndIf
			oModVRR:DeActivate()
		EndIf
	EndIf
EndIf
FreeObj(oModVRR)
Return

/*/{Protheus.doc} OA4700021_IncluirSaida
Incluir a Saida de Servicos Especializados

@author Andre Luis Almeida
@since 06/09/2022
/*/
Function OA4700021_IncluirSaida( cNumero , cSerie , lComNF , lEstoq )
Local lRet    := .f.
Local cPrefAnt := ""
Local cPrefNF := ""
Local cPfSrvE := "OFE" // Prefixo de Origem - F2_PREFORI / E1_PREFORI
Local cFilSD2 := xFilial("SD2")
Local cFilVPY := xFilial("VPY")
Local nCntFor := 0
Local nCntSeq := 0
Local nQtdDiv := 0
Local aCabNFS := {}
Local aIteNFS := {}
Local aTemp   := {}
Local cTipMov := "1" // 1=Saida
Local cPorMov := "0" // 0=Normal
Local cOpeMov := "1" // 1=Venda
Local aSrvMov := {}
Local cQuery  := ""
Local cQAlias := "SQLAUX"
Local cMsgSC9 := ""
Local nTamIte := GeTSX3Cache("C6_ITEM","X3_TAMANHO")
Local lPedXml := VRS->(FieldPos("VRS_PEDXML")) > 0
Local lIteXml := VRS->(FieldPos("VRS_ITEXML")) > 0
Private nVerParFat := 1 // Não mostrar paramtros do Faturamento
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
Default cNumero := ""
Default cSerie  := ""
Default lComNF  := .f.
Default lEstoq  := .f.
//
oProcSaida:SetRegua1(4)
oProcSaida:IncRegua1(STR0020) // Levantando Serviços Especializados...
//
cQuery := "SELECT COUNT(*) "
cQuery += "  FROM " + RetSQLName("VRS")
cQuery += " WHERE VRS_FILIAL = '" + VRR->VRR_FILIAL + "'"
cQuery += "   AND VRS_CODVRR = '" + VRR->VRR_CODIGO + "'"
cQuery += "   AND D_E_L_E_T_ = ' '"
oProcSaida:SetRegua2(FM_SQL(cQuery))
//
DbSelectArea("VRS")
DbSetOrder(2) // VRS_FILIAL + VRS_CODVRR
If DbSeek( VRR->VRR_FILIAL + VRR->VRR_CODIGO )
	lRet := .t.
	Do While !VRS->(Eof()) .and. VRS->VRS_FILIAL == VRR->VRR_FILIAL .and. VRS->VRS_CODVRR == VRR->VRR_CODIGO
		//
		oProcSaida:IncRegua2()
		//
		VPX->(DbSetOrder(1)) // VPX_FILIAL + VPX_SERINT
		VPX->(DbSeek( xFilial("VPX") + VRS->VRS_SERINT ))
		VPV->(DbSetOrder(1)) // VPV_FILIAL + VPV_CODTIP
		VPV->(DbSeek( xFilial("VPV") + VPX->VPX_TIPSER ))
		If VPV->VPV_CTRSLD <> "0" // Se possuir algum tipo de controle de SALDO de ESTOQUE - verificar saldo
			aAdd(aSrvMov,{ VRS->VRS_SERINT , VRS->VRS_QTDSER , VPV->VPV_FILCEN })
		EndIf
		//
		If lComNF .and. !Empty(cNumero)
			//
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+VPV->VPV_CODSB1))
			//
			nTotSrv := ( VRS->VRS_QTDSER * VRS->VRS_VLRUNI )
			//
			nCntSeq++
			aTemp := {}
			aAdd(aTemp,{"C6_ITEM"   , strzero(nCntSeq,nTamIte)            ,Nil})
			aAdd(aTemp,{"C6_PRODUTO", SB1->B1_COD                         ,Nil})
			aAdd(aTemp,{"C6_TES"    , VRS->VRS_CODTES                     ,Nil})
			aAdd(aTemp,{"C6_ENTREG" , dDataBase                           ,Nil})
			aAdd(aTemp,{"C6_UM"     , SB1->B1_UM                          ,Nil})
			aAdd(aTemp,{"C6_LOCAL"  , SB1->B1_LOCPAD                      ,Nil})
			aAdd(aTemp,{"C6_QTDVEN" , VRS->VRS_QTDSER                     ,Nil})
			aAdd(aTemp,{"C6_QTDLIB" , 0                                   ,Nil})
			aAdd(aTemp,{"C6_PRUNIT" , VRS->VRS_VLRUNI                     ,Nil})
			aAdd(aTemp,{"C6_PRCVEN" , VRS->VRS_VLRUNI                     ,Nil})
			aAdd(aTemp,{"C6_VALOR"  , nTotSrv                             ,Nil})
			If VRS->VRS_VALDES > 0
				aAdd(aTemp,{"C6_VALDESC", VRS->VRS_VALDES                 ,Nil})
			ElseIf VRS->VRS_PERDES > 0
				aAdd(aTemp,{"C6_VALDESC", nTotSrv * (VRS->VRS_PERDES/100) ,Nil})
			EndIf
			aAdd(aTemp,{"C6_CLI"    , VRR->VRR_CODCLI                     ,Nil})
			aAdd(aTemp,{"C6_LOJA"   , VRR->VRR_LOJCLI                     ,Nil})
			If lPedXml
				aAdd(aTemp,{"C6_NUMPCOM", VRS->VRS_PEDXML                 ,Nil})
			Endif
			If lIteXml
				aAdd(aTemp,{"C6_ITEMPC" , VRS->VRS_ITEXML                 ,Nil})
			Endif
			aAdd(aIteNFS,aclone(aTemp))
			//
		EndIf
		//
		dbSelectArea("VRS")
		dbSkip()
	Enddo
	//
	BEGIN TRANSACTION
	//
	If lComNF .and. len(aIteNFS) > 0
		//
		If GetNewPar("MV_MIL0182",.F.) // .T. = Faz transferência automática na Venda da quantidade divergente em estoque entre a Filial Centralizadora e a Filial Logada.
			oProcSaida:IncRegua1(STR0021) // Transferindo Estoque dos Serviços Especializados...
			oProcSaida:SetRegua2(len(aSrvMov))
			For nCntFor := 1 to len(aSrvMov)
				oProcSaida:IncRegua2()
				If !Empty(aSrvMov[nCntFor,3]) // Possui Filial Centralizadora
					nQtdDiv := aSrvMov[nCntFor,2] // Pegar TODA a Quantidade Solicitada
					DbSelectArea("VPY")
					DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
					If DbSeek( cFilVPY + VPX->VPX_SERINT + cFilSD2 ) // Estoque Disponivel na Filial Logada
						nQtdDiv := 0
						If aSrvMov[nCntFor,2] > VPY->VPY_QTDEST
							nQtdDiv := aSrvMov[nCntFor,2] - VPY->VPY_QTDEST // Pegar a Quantidade Solicitada - Quantidade Disponivel na Filial Logada
						EndIf
					EndIf
					If nQtdDiv > 0 // Existe divergencia - Não tem todo Estoque na Filial Logada, necessário Transferir a Divergencia da Filial Centralizadora para a Filial Logada
						If !OA4650021_IncluirTransferencia( .t. , .f. , "N" , { aSrvMov[nCntFor,3] , cFilSD2 , aSrvMov[nCntFor,1] , nQtdDiv } ) .or. cDebugMIL == "OFIA470002" // Faz a Transferencia automatica da Divergencia entre a Filial Centralizadora e a Filial Logada
							DisarmTransaction()
							RollBackSX8()
							lRet := .f.
							Exit
						EndIf
					EndIf
				EndIf
			Next
		EndIf
		//
		If lRet
			//
			oProcSaida:IncRegua1(STR0022) // Gerando Nota Fiscal de Saida...
			oProcSaida:SetRegua2(2)
			oProcSaida:IncRegua2()
			//
			SA1->(DbSetOrder(1))
			SA1->(DbSeek( xFilial("SA1") + VRR->VRR_CODCLI + VRR->VRR_LOJCLI ))
			SA3->(DbSetOrder(1))
			SA3->(DbSeek( xFilial("SA3") + VRR->VRR_CODVEN ))
			//
			aAdd(aCabNFS,{"C5_TIPO"   , "N"                                   ,Nil})
			aAdd(aCabNFS,{"C5_CLIENTE", VRR->VRR_CODCLI                       ,Nil})
			aAdd(aCabNFS,{"C5_LOJACLI", VRR->VRR_LOJCLI                       ,Nil})
			aAdd(aCabNFS,{"C5_TIPOCLI", SA1->A1_TIPO                          ,Nil})
			aAdd(aCabNFS,{"C5_CONDPAG", VRR->VRR_FORPAG                       ,Nil})
			aAdd(aCabNFS,{"C5_VEND1"  , VRR->VRR_CODVEN                       ,Nil})
			aAdd(aCabNFS,{"C5_COMIS1" , SA3->A3_COMIS                         ,Nil})
			aAdd(aCabNFS,{"C5_EMISSAO", ddatabase                             ,Nil})
			aAdd(aCabNFS,{"C5_MOEDA"  , 1                                     ,Nil})
			If SC5->(FieldPos("C5_NATUREZ")) <> 0
				aAdd(aCabNFS,{"C5_NATUREZ", IIf(!Empty(VRR->VRR_NATURE),VRR->VRR_NATURE,SA1->A1_NATUREZ) ,Nil}) // Natureza no Pedido
			EndIf
			If VRR->(FieldPos("VRR_ESTPRE")) > 0 .AND. !Empty(VRR->VRR_ESTPRE)
				aAdd(aCabNFS,{"C5_ESTPRES", VRR->VRR_ESTPRE                   ,Nil})
			Endif
			If VRR->(FieldPos("VRR_MUNPRE")) > 0 .AND. !Empty(VRR->VRR_MUNPRE)
				aAdd(aCabNFS,{"C5_MUNPRES", VRR->VRR_MUNPRE                   ,Nil})
			Endif
			If VRR->(FieldPos("VRR_MNNOTS")) > 0 .AND. !Empty(VRR->VRR_MNNOTS)
				aAdd(aCabNFS,{"C5_MENNOTA", VRR->VRR_MNNOTS                   ,Nil})
			EndIf
			If VRR->(FieldPos("VRR_MNPADS")) > 0 .AND. !Empty(VRR->VRR_MNPADS)
				aAdd(aCabNFS,{"C5_MENPAD", VRR->VRR_MNPADS                    ,Nil})
			EndIf
			If cPaisLoc == "BRA" .and. VRR->(FieldPos("VRR_RECISS")) > 0 
				aAdd(aCabNFS,{"C5_RECISS", VRR->VRR_RECISS                    ,Nil})
			EndIf
			If cPaisLoc == "MEX"
				aAdd(aCabNFS,{"C5_TPDOC"  , VRR->VRR_TPDOC                    ,Nil})
				aAdd(aCabNFS,{"C5_USOCFDI", VRR->VRR_USOCFD                   ,Nil})
			EndIf
			//

			OA470020I_ConfereTipo9(@aCabNFS) 

			lMSHelpAuto := .t.
			lMsErroAuto := .f.
			MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabNFS,aIteNFS,3)
			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
				RollBackSX8()
				lRet := .f.
			Else
				ConfirmSx8() // Confirm do Nro NF
			EndIf
			//
			lCredito := .t.
			lEstoque := .t.
			lESTNEG  := .t.
			lLiber   := .t.
			lTransf  := .f.
			SC9->(dbSetOrder(1))
			SC6->(dbSetOrder(1))
			SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM + "01"))
			While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == SC5->C5_NUM
				If !SC9->(dbSeek(xFilial("SC9")+SC5->C5_NUM+SC6->C6_ITEM))
					nQtdLib := SC6->C6_QTDVEN
					nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,(!lESTNEG),lLiber,lTransf)
				EndIf
				SC6->(dbSkip())
			Enddo
			//
		EndIf
	EndIf
	If lRet .and. len(aIteNFS) > 0
		cNumPed := SC5->C5_NUM
		aTitSE1 := {}
		aPvlNfs := {}
		SB1->(dbSetOrder(1))
		SC5->(dbSetOrder(1))
		SC6->(dbSetOrder(1))
		SB5->(dbSetOrder(1))
		SB2->(dbSetOrder(1))
		SF4->(dbSetOrder(1))
		SE4->(dbSetOrder(1))
		SC9->(dbSeek(xFilial("SC9") + cNumPed + "01"))
		While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .and. SC9->C9_PEDIDO == cNumPed
			If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
				SC5->(dbSeek( xFilial("SC5") + SC9->C9_PEDIDO ))
				SC6->(dbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM ))
				SB1->(dbSeek( xFilial("SB1") + SC9->C9_PRODUTO ))
				SB2->(dbSeek( xFilial("SB2") + SB1->B1_COD ))
				SB5->(dbSeek( xFilial("SB5") + SB1->B1_COD ))
				SF4->(MsSeek( xFilial("SF4") + SC6->C6_TES ))
				SE4->(MsSeek( xFilial("SE4") + SC5->C5_CONDPAG ))
				nPrcVen := SC9->C9_PRCVEN
				If ( SC5->C5_MOEDA <> 1 ) .or. cDebugMIL == "OFIA470003"
					nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
				EndIf
				Aadd(aPvlNfs,{ SC9->C9_PEDIDO,;
					SC9->C9_ITEM,;
					SC9->C9_SEQUEN,;
					SC9->C9_QTDLIB,;
					nPrcVen,;
					SC9->C9_PRODUTO,;
					.f.,;
					SC9->(RecNo()),;
					SC5->(RecNo()),;
					SC6->(RecNo()),;
					SE4->(RecNo()),;
					SB1->(RecNo()),;
					SB2->(RecNo()),;
					SF4->(RecNo()) })
			EndIf
			If !Empty(SC9->C9_BLCRED) .or. cDebugMIL == "OFIA470004"
				cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLCRED"))+": "+SC9->C9_BLCRED+CHR(13)+CHR(10)
			EndIf
			If !Empty(SC9->C9_BLEST) .or. cDebugMIL == "OFIA470004"
				cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLEST"))+": "+SC9->C9_BLEST+CHR(13)+CHR(10)
			EndIf
			SC9->(dbSkip())
		Enddo
		//
		If !Empty(cMsgSC9) .or. cDebugMIL == "OFIA470004"
			MsgStop(STR0024+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsgSC9,STR0023) // Existem um ou mais item do pedido de venda (SC5) que não foram liberado! / Atencao
			DisarmTransaction()
			RollBackSX8()
			lRet := .f.
		EndIf
		If ( len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(cNumPed,.t.) ) .or. cDebugMIL == "OFIA470005" // Verifica SC5 bloqueado
			MostraErro()
			DisarmTransaction()
			RollBackSX8()
			lRet := .f.
		EndIf
		If lRet .and. Len(aPvlNfs) > 0
			If nVerParFat <> 1 .or. cDebugMIL == "OFIA470006" // nVerParFat == 2 // Mostrar os Parametros do Faturamento no momento da geracao da NF
				While .t.
					If PERGUNTE("MT460A",.t.)
						Exit
					EndIf
				EndDo
			Else // NAO mostrar os Parametros do Faturamento no momento da geracao da NF
				PERGUNTE("MT460A",.f.)
			EndIf
			//
			nModBkp := nModulo
			cModBkp := cModulo
			nModulo := 5
			cModulo := "FAT"
			cNumero := MaPvlNfs(	aPvlNfs,;			//  1
								cSerie,;			//  2
								(mv_par01 == 1),;	//  3
								(mv_par02 == 1),;	//  4
								(mv_par03 == 1),;	//  5
								(mv_par04 == 1),;	//  6
								.F.,;				//  7
								 0,;				//  8
								 0,; 				//  9
								.T.,;				// 10
								.F.,;				// 11
								,;					// 12
								,;//{ |x| OX100VS9E1(x,cPrefBal,(SE4->E4_TIPO == "9"),lPeriodico,cTipPer) } ,;	// 13
								,;          		// 14
								,;          		// 15
								,)          		// 16
			cNumero := padr(cNumero,GeTSX3Cache("F2_DOC","X3_TAMANHO"))
			nModulo := nModBkp
			cModulo := cModBkp
			If lMsErroauto .or. cDebugMIL == "OFIA470007"
				MostraErro()
				DisarmTransaction()
				RollBackSX8()
				MsUnlockAll()
				lRet := .f.
			EndIf
		EndIf
		If lRet .and. lEstoq
			oProcSaida:IncRegua2()
			oProcSaida:IncRegua1(STR0026) // Atualizando Estoque dos Serviços...
			oProcSaida:SetRegua2(len(aSrvMov))
			For nCntFor := 1 to len(aSrvMov)
				oProcSaida:IncRegua2()
				cSeqMov := OFIA452( aSrvMov[nCntFor,1] , cTipMov , cPorMov , cOpeMov , aSrvMov[nCntFor,2] , VRR->VRR_FILIAL , VRR->VRR_CODIGO ) // Grava a Movimentação de Estoque do Servico Especializado
				If Empty(cSeqMov) .or. cDebugMIL == "OFIA470008"
					lRet := .f.
					DisarmTransaction()
					Exit
				EndIf
			Next
		EndIf
	EndIf
	DbSelectArea("VRR")
	If lRet .and. len(aIteNFS) > 0
		If lComNF .and. !Empty(cNumero)
			dbSelectArea("SF2")
			dbSetOrder(1)
			If dbSeek(xFilial("SF2")+cNumero+cSerie)
				SE4->(DBSetOrder(1))
				SE4->(dbSeek(xFilial("SE4")+SF2->F2_COND))
				cPrefAnt := SF2->F2_PREFIXO
				cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
				dbSelectArea("SF2")
				reclock("SF2",.f.)
				SF2->F2_PREFIXO := cPrefNF
				SF2->F2_PREFORI := cPfSrvE
				If Empty(SF2->F2_DUPL) .and. SE4->E4_TIPO == "A"
					SF2->F2_DUPL := cNumero
				EndIf
				msunlock()
				If !Empty(SF2->F2_DUPL)
					cQuery := "SELECT R_E_C_N_O_ AS RECSE1"
					cQuery += "  FROM "+RetSQLName("SE1")
					cQuery += " WHERE E1_FILIAL  = '"+xFilial("SE1")+"'"
					cQuery += "   AND E1_PREFIXO = '"+cPrefAnt+"'"
					cQuery += "   AND E1_NUM     = '"+SF2->F2_DUPL+"'"
					cQuery += "   AND D_E_L_E_T_ = ' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
					While ( cQAlias )->(!Eof())
						DbSelectArea("SE1")
						DbGoTo(( cQAlias )->RECSE1)
						RecLock("SE1",.f.)
							SE1->E1_PREFIXO := cPrefNF
							SE1->E1_PREFORI := cPfSrvE
						msunlock()
						( cQAlias )->(DbSkip())
					Enddo
					( cQAlias )->( dbCloseArea() )
					DbSelectArea("SE1")
				EndIf
				// Gera Titulo Manualmente
				If SE4->E4_TIPO == "A"
					aFINA040 := {}
					cParcela := ""
					nTamE1PARCELA := GeTSX3Cache("E1_PARCELA","X3_TAMANHO")
					nCntFor := 0
					Pergunte("FIN040",.F.)
					cQuery := "SELECT VS9_TIPPAG, VS9_DATPAG , VS9_VALPAG , VS9_TIPPAG , VS9_NATURE , R_E_C_N_O_ AS RECVS9"
					cQuery += "  FROM " + RetSQLName("VS9")
					cQuery += " WHERE VS9_FILIAL = '" + VRR->VRR_FILIAL + "'"
					cQuery += "   AND VS9_NUMIDE = '" + VRR->VRR_CODIGO + "'"
					cQuery += "   AND VS9_TIPOPE = 'E'"
					cQuery += "   AND D_E_L_E_T_ = ' '"
					cQuery += " ORDER BY VS9_NUMIDE , VS9_DATPAG , VS9_SEQUEN"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
					While !(cQAlias)->(Eof())			
						cParcela := IIf( nTamE1PARCELA == 1 , ConvPN2PC(nCntFor) , Soma1( StrZero(nCntFor,nTamE1PARCELA) ) )
						nCntFor++
						cNatureza := IIf(!Empty((cQAlias)->VS9_NATURE),(cQAlias)->VS9_NATURE,VRR->VRR_NATURE)
						aFINA040 := {;
									{"E1_PREFIXO",cPrefNF                                   , NIL },;
									{"E1_NUM"    ,cNumero                                   , NIL },;
									{"E1_PARCELA",cParcela                                  , NIL },;
									{"E1_TIPO"   ,(cQAlias)->VS9_TIPPAG                     , NIL },;
									{"E1_NATUREZ",cNatureza                                 , NIL },;
									{"E1_CLIENTE",VRR->VRR_CODCLI                           , NIL },;
									{"E1_LOJA"   ,VRR->VRR_LOJCLI                           , NIL },;
									{"E1_EMISSAO",dDataBase                                 , NIL },;
									{"E1_VENCTO" ,StoD((cQAlias)->VS9_DATPAG)               , NIL },;
									{"E1_VENCREA",DataValida(StoD((cQAlias)->VS9_DATPAG))   , NIL },;
									{"E1_VALOR"  ,(cQAlias)->VS9_VALPAG                     , NIL },;
									{"E1_PREFORI",cPfSrvE                                   , NIL },;
									{"E1_PEDIDO" ,cNumPed                                   , NIL },;
									{"E1_NUMNOTA",cNumero                                   , NIL },;
									{"E1_SERIE"  ,cSerie                                    , NIL },;
									{"E1_ORIGEM" ,"MATA460"                                 , NIL },;
									{"E1_VEND1"  ,VRR->VRR_CODVEN                           , NIL },;
									{"E1_LA"     ,"S"                                       , NIL }}
						MSExecAuto({|x| FINA040(x)},aFINA040)
						If lMsErroAuto
							MostraErro()
							DisarmTransaction()
							RollBackSX8()
							MsUnlockAll()
							lRet := .f.
						EndIf
						(cQAlias)->(dbSkip())
					End
					(cQAlias)->(dbCloseArea())
				EndIf
			EndIf
			DbSelectArea("VRR")
		EndIf
	EndIf 
	//
	END TRANSACTION
	//
EndIf
If lRet .and. len(aIteNFS) > 0
	If lComNF .and. !Empty(cNumero)
		OA4700041_GravaNroNFSaida( VRR->VRR_CODIGO , cNumero , cSerie ) // Grava o Nro e Serie da NF
	EndIf
	OA4700011_GravaStatusSaida( VRR->VRR_CODIGO , "1" ) // Mudar Status para 1=Saida Efetivada
	OA4500051_ZeraCustoMedio( "S" , VRR->VRR_FILIAL , VRR->VRR_CODIGO ) // Zera Custo Medio se a Saida Zerar o Estoque dos Serviços
EndIf
dbSelectArea("SX6")
MsRUnLock()
Return lRet

/*/{Protheus.doc} OA4700031_CancelarSaida
Opção CANCELAR do aRotina do OFIA470 - Saida de Servicos Especializados

@author Andre Luis Almeida
@since 06/09/2022
/*/
Function OA4700031_CancelarSaida()
Local cMsgAvi  := ""
Local nOpcCan  := 0
Local lRet     := .t.
Local cQuery   := ""
Local cQAlias  := "SQLAUX"
Local cSrvAux  := ""
Local cSeqMov  := "NAOCONTROLA" // Necessario conteudo para iniciar o While
Local cTipMov  := "0" // 0=Entrada
Local cPorMov  := "1" // 1=Por Cancelamento
Local cOpeMov  := "1" // 1=Venda
Local nCntFor  := 0
Local cFilSD2  := xFilial("SD2")
Local cNumPed  := ""
Local cPrefNF  := ""
Local cNumTit  := ""
Local cPrefOri := ""
Local aRegSD2  := {}
Local aRegSE1  := {}
Local aRegSE2  := {}
Local aSrvMov  := {}
Local aParcelas     := {}
Local aMata410Cab   := {}
Local aMata410Itens := {}
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
If VRR->VRR_STATUS == "2" // 2=Saida Cancelada
	Help("",1,"OA4700031_CancelarSaida",,STR0027,1,0) // Saida já Cancelada. Impossível continuar.
Else
	cQuery := "SELECT VRQ.R_E_C_N_O_ "
	cQuery += "  FROM " + RetSqlName("VRS") + " VRS "
	cQuery += "  JOIN " + RetSqlName("VRQ") + " VRQ ON VRQ.VRQ_FILVRS = VRS.VRS_FILIAL AND VRQ.VRQ_CODVRS = VRS.VRS_CODIGO AND VRQ.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN " + RetSqlName("VRP") + " VRP ON VRP.VRP_FILIAL = VRQ.VRQ_FILIAL AND VRP.VRP_CODIGO = VRQ.VRQ_CODVRP AND VRP.VRP_STATUS <> '2' AND VRP.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VRS.VRS_FILIAL = '"+VRR->VRR_FILIAL+"'"
	cQuery += "   AND VRS.VRS_CODVRR = '"+VRR->VRR_CODIGO+"'"
	cQuery += "   AND VRS.D_E_L_E_T_ = ' '"
	If FM_SQL(cQuery) > 0 .or. cDebugMIL == "OFIA470009"
		lRet := .f.
		Help("",1,"OA4700031_CancelarSaida",,STR0028,1,0) // Existe Entrada relacionada a esta Saida. Impossível Cancelar.
	EndIf
	If lRet
		If VRR->VRR_STATUS == "0" .or. VRR->VRR_STATUS == "1" // 0=Saida Digitada ou 1=Saida Efetivada
			nOpcCan := 1 // Cancelar
			If !MsgYesNo(STR0085,STR0023) // Confirma o Cancelamento da Saida? / Atenção
				lRet := .f.
			EndIf
		Else
			cMsgAvi := CHR(13)+CHR(10)+STR0025+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Cancelamento da Saida
			cMsgAvi += "- "+STR0081+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Confirmar Cancelamento
			cMsgAvi += "- "+STR0083 // Voltar Status para Saida Digitada
			nOpcCan := Aviso(STR0001,cMsgAvi,{STR0082,STR0084,STR0086},3) // Saida de Serviços Especializados / Confirmar / Voltar / Fechar
			lRet := ( nOpcCan == 1 .or. nOpcCan == 2 ) // 1=Confirmar ou 2=Voltar
		EndIf
	EndIf
	If lRet
		BEGIN TRANSACTION
		If VRR->VRR_STATUS == "1" // 1=Saida Efetivada
			DbSelectArea("VRS")
			DbSetOrder(2) // VRS_FILIAL + VRS_CODVRR
			DbSeek( VRR->VRR_FILIAL + VRR->VRR_CODIGO )
			Do While !VRS->(Eof()) .and. VRS->VRS_FILIAL == VRR->VRR_FILIAL .and. VRS->VRS_CODVRR == VRR->VRR_CODIGO
				//
				VPX->(DbSetOrder(1)) // VPX_FILIAL + VPX_SERINT
				VPX->(DbSeek( xFilial("VPX") + VRS->VRS_SERINT ))
				VPV->(DbSetOrder(1)) // VPV_FILIAL + VPV_CODTIP
				VPV->(DbSeek( xFilial("VPV") + VPX->VPX_TIPSER ))
				//				
				If VPV->VPV_CTRSLD == "1" // Controla SALDO de ESTOQUE UNITARIO
					cQuery := "SELECT SUM(VPY_QTDEST) AS QTDTOT "
					cQuery += "  FROM " + RetSQLName("VPY")
					cQuery += " WHERE VPY_FILIAL = '" + xFilial("VPY") + "'"
					cQuery += "   AND VPY_SERINT = '" + VRS->VRS_SERINT + "'"
					cQuery += "   AND D_E_L_E_T_ = ' '"
					If FM_SQL(cQuery) > 0 .or. cDebugMIL == "OFIA470010"
						lRet := .f.
						cSrvAux := CHR(13)+CHR(10)+CHR(13)+CHR(10)+Alltrim(VPX->VPX_GRUSER)+" "+Alltrim(VPX->VPX_CODSER)+CHR(13)+CHR(10)+Alltrim(VPX->VPX_DESSER)+" ("+Alltrim(VPX->VPX_TIPSER)+")"
						Help("",1,"OA4700031_CancelarSaida",,STR0029+cSrvAux,1,0) // Este Serviço Especializado tem controle de Saldo Unitário e o mesmo já existe no Estoque! Impossível Cancelar.
						Exit
					EndIf
				EndIf
				//
				If VPV->VPV_CTRSLD <> "0" // Se possuir algum tipo de controle de SALDO de ESTOQUE - verificar saldo
					aAdd(aSrvMov,{ VRS->VRS_SERINT , VRS->VRS_QTDSER , VPV->VPV_FILCEN })
				EndIf
				//
				dbSelectArea("VRS")
				dbSkip()
			Enddo
			If lRet
				For nCntFor := 1 to len(aSrvMov)
					cSeqMov := OFIA452( aSrvMov[nCntFor,1] , cTipMov , cPorMov , cOpeMov , aSrvMov[nCntFor,2] , VRR->VRR_FILIAL , VRR->VRR_CODIGO ) // Grava a Movimentação de Estoque do Servico Especializado
					If Empty(cSeqMov) .or. cDebugMIL == "OFIA470011"
						Exit
					EndIf
				Next
				If !Empty(cSeqMov)
					If !Empty(VRR->VRR_NUMNFI) // Possui NF
						DbSelectArea("SF2")
						DbSetOrder(1)
						If DbSeek(xFilial("SF2") + VRR->VRR_NUMNFI + VRR->VRR_SERNFI )
							cPrefNF  := SF2->F2_PREFIXO
							cNumTit  := SF2->F2_DUPL
							cPrefOri := SF2->F2_PREFORI
							SD2->(dbSetOrder(3))
							SD2->(dbSeek( SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE ))
							cNumPed := SD2->D2_PEDIDO
							If !MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2) .or. cDebugMIL == "OFIA470012" // Verifica se o estorno do documento de saida pode ser feito
								MostraErro()
								DisarmTransaction()
								lRet := .f.
							Else
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Estorna o documento de saida                                   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								PERGUNTE("MTA521",.f.)
								SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1))) // Excluir NF (SF2)
							EndIf
							If lRet
								SC5->(dbGoTop())
								SC6->(dbGoTop())
								SC9->(dbGoTop())
								lMsErroAuto := .f.
								DbSelectArea("SC5")
								DbSetOrder(1)
								If DbSeek(xFilial("SC5")+cNumPed)
									aMata410Cab   := {{"C5_NUM"      , cNumPed,Nil}}   //Numero do pedido SC5
									aMata410Itens := {{"C6_NUM"      , cNumPed,Nil}}   //Numero do Pedido SC6
									//Exclui Pedido
									SC9->(dbSetOrder(1))
									SC9->(dbSeek(xFilial("SC9")+cNumPed))
									While ( !SC9->(Eof()) .And. xFilial("SC9") == SC9->C9_FILIAL .and. cNumPed == SC9->C9_PEDIDO ) .or. cDebugMIL == "OFIA470013"
										SC9->(a460Estorna())
										SC9->(dbSkip())
									EndDo
									MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5) // Excluir Pedido (SC5/SC6)
								EndIf
/*								If !lMsErroAuto // Cancelou o Pedido Normalmente - Não ocorreu erro
									// Cancelar TITULOS -> CONTAS A RECEBER ( SE1 )
									cQuery := "SELECT E1_PREFIXO , E1_NUM , E1_PARCELA , E1_TIPO "
									cQuery +=  " FROM " + RetSQLName("SE1")
									cQuery += " WHERE E1_FILIAL  = '" + xFilial("SE1") + "'"
									cQuery += "   AND E1_NUM     = '"+cNumTit+"'"
									cQuery += "   AND E1_PREFIXO = '"+cPrefNF+"'"
									cQuery += "   AND E1_PREFORI = '"+cPrefOri+"'"
									cQuery += "   AND E1_ORIGEM  = 'MATA460'"
									cQuery += "   AND D_E_L_E_T_ = ' '"
									dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
									While !(cQAlias)->(Eof())
										If (cQAlias)->(E1_TIPO) $ MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT .or. cDebugMIL == "OFIA470014" // Nao leva para a exclusao os Titulo de Abatimento de Impostos
											(cQAlias)->(DbSkip())
											Loop
										EndIf
										aAdd(aParcelas,{{"E1_PREFIXO" , (cQAlias)->( E1_PREFIXO ) ,nil},;
														{"E1_NUM"     , (cQAlias)->( E1_NUM )     ,nil},;
														{"E1_PARCELA" , (cQAlias)->( E1_PARCELA ) ,nil},;
														{"E1_TIPO"    , (cQAlias)->( E1_TIPO )    ,nil},;
														{"E1_ORIGEM"  , "MATA460"                    ,nil}})
										(cQAlias)->(DbSkip())
									Enddo	
									(cQAlias)->(DbCloseArea())
									DbSelectArea("SE1")
									Pergunte("FIN040",.F.)
									For nCntFor := 1 to len(aParcelas)
										lMsErroAuto := .f.
										MSExecAuto({|x,y| FINA040(x,y)},aParcelas[nCntFor],5) // Excluir Titulos (SE1)
*/										If lMsErroAuto .or. cDebugMIL == "OFIA470015"
											MostraErro()
											DisarmTransaction()
											lRet := .f.
//											Exit
										EndIf
//									Next
//								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			If lRet
				If GetNewPar("MV_MIL0182",.F.) // .T. = Faz transferência automática na Venda da quantidade divergente em estoque entre a Filial Centralizadora e a Filial Logada.
					// Voltar Estoque para a Filial Centralizadora
					For nCntFor := 1 to len(aSrvMov)
						If !Empty(aSrvMov[nCntFor,3]) // Tem Filial Centralizadora
							If !OA4650021_IncluirTransferencia( .t. , .f. , "E" , { cFilSD2 , aSrvMov[nCntFor,3] , aSrvMov[nCntFor,1] , aSrvMov[nCntFor,2] } ) .or. cDebugMIL == "OFIA470016" // Faz a Transferencia automatica da Divergencia entre a Filial Centralizadora e a Filial Logada
								DisarmTransaction()
								RollBackSX8()
								lRet := .f.
								Exit
							EndIf
						EndIf
					Next
				EndIf
			EndIf
		EndIf
		If lRet
			OA4710051_DesativarSolicitacoes( VRR->VRR_FILIAL , VRR->VRR_CODIGO , 0 ) // Marcar 0=NAO ATIVO para todas as Solicitações da Saida VRR
			OA4700011_GravaStatusSaida( VRR->VRR_CODIGO , IIf(nOpcCan==1,"2","0") ) // Mudar Status para 2=Saida Cancelada ou voltar para 0=Saida Digitada
		EndIf
		END TRANSACTION
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OA4700041_GravaNroNFSaida
Grava Numeração/Serie da NF de Saida

@author Andre Luis Almeida
@since 06/09/2022
/*/
Static Function OA4700041_GravaNroNFSaida( cCodigo , cNumNFI , cSerNFI )
Local oModVRR   := FWLoadModel( 'OFIA475' ) // MVC somente para atualizar o cabeçalho VRR
Default cCodigo := ""
VRR->(DbSetOrder(1))
If VRR->(DbSeek(xFilial("VRR")+cCodigo))
	// Gravar Nota Fiscal e Serie
	oModVRR:SetOperation( MODEL_OPERATION_UPDATE )
	If oModVRR:Activate()
		oModVRR:SetValue( "VRRMASTER" , "VRR_NUMNFI" , cNumNFI )
		oModVRR:SetValue( "VRRMASTER" , "VRR_SERNFI" , cSerNFI )
		If oModVRR:VldData()
			oModVRR:CommitData()
		EndIf
		oModVRR:DeActivate()
	EndIf
EndIf
FreeObj(oModVRR)
Return

/*/{Protheus.doc} OA4700051_VisualizarSaida
Visualizar Saida

@author Andre Luis Almeida
@since 09/09/2022
/*/
Function OA4700051_VisualizarSaida()
Local cMsgAvi := ""
Local nOpcAvi := 1
If VRR->VRR_STATUS == "1" .and. !Empty(VRR->VRR_NUMNFI) // Saida Efetivada COM NF
	cMsgAvi += CHR(13)+CHR(10)
	cMsgAvi += "- "+STR0030+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Registro da Saida do Serviço Especializado
	cMsgAvi += "- "+STR0031 // Nota Fiscal de Saida do Serviço Especializado
	nOpcAvi := Aviso(STR0010,cMsgAvi,{STR0032,STR0033,STR0013},3) // Visualizar / Reg.Saida / Nota Fiscal / Cancelar
EndIf
If nOpcAvi == 1 // Visualizar Cadastro VRR
	DbSelectArea("VRR")
	oExecView := FWViewExec():New()
	oExecView:SetTitle(STR0010) // Visualizar
	oExecView:SetSource("OFIA470")
	oExecView:SetOperation(MODEL_OPERATION_VIEW)
	oExecView:OpenView(.T.)
ElseIf nOpcAvi == 2 // Visualizar a NF Saida
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(xFilial("SF2")+VRR->VRR_NUMNFI+VRR->VRR_SERNFI+VRR->VRR_CODCLI+VRR->VRR_LOJCLI))
	Mc090Visual("SF2",SF2->(RecNo()),2) // Consultar NF ( MATC090 )
EndIf
Return

/*/{Protheus.doc} OA4700061_DeleteLine
Delete nas Grids

@author Andre Luis Almeida
@since 22/09/2022
/*/
Function OA4700061_DeleteLine( oView , cIdView , nNumLine )
Local oModel
If cIdView == "VRSDETAIL"
	oModel  := FWModelActive()
	OA4700081_CalculaParcelas( oModel:GetValue( "VRRMASTER" , "VRR_FORPAG" ) )
EndIf
Return

/*/{Protheus.doc} OA4700071_UnDeleteLine
UnDelete nas Grids

@author Andre Luis Almeida
@since 22/09/2022
/*/
Function OA4700071_UnDeleteLine( oView , cIdView , nNumLine )
Local oModel
Local oVRSMod
If cIdView == "VRSDETAIL"
	oModel  := FWModelActive()
	oVRSMod := oModel:GetModel("VRSDETAIL")
	OA4700091_ValidaEstoque( oVRSMod:GetValue( "VRS_SERINT" ) , oVRSMod:GetValue( "VRS_QTDSER" ) )
	OA4700081_CalculaParcelas( oModel:GetValue( "VRRMASTER" , "VRR_FORPAG" ) )
EndIf
Return

/*/{Protheus.doc} OA4700081_CalculaParcelas
Calcula Parcelas VS9

@author Andre Luis Almeida
@since 22/09/2022
/*/
Function OA4700081_CalculaParcelas( cCondic )
Local nCntFor   := 1 
Local aParcelas := {}
Local cTpFix    := ""
Local nVlrTot   := 0
Local oModel    := FWModelActive()
Local oView     := FWViewActive()
Local oVRRMod   := oModel:GetModel("VRRMASTER")
Local oVRSMod   := oModel:GetModel("VRSDETAIL")
Local oVS9Mod   := oModel:GetModel("VS9DETAIL")
Local nVRSLin   := oVRSMod:nLine
Local nTamSeq   := GeTSX3Cache("VS9_SEQUEN","X3_TAMANHO")
Default cCondic := ""
//
oVS9Mod:SetNoInsertLine(.T.) // Nao deixa INCLUIR as linhas do VS9
oVS9Mod:SetNoDeleteLine(.T.) // Nao deixa DELETAR as linhas do VS9
For nCntFor := 1 to oVRSMod:Length()
	oVRSMod:GoLine(nCntFor)
	If !oVRSMod:IsDeleted()
		nVlrTot += oVRSMod:GetValue("VRS_VLRTOT")
	EndIf
Next
oVRRMod:SetValue("VRR_VLRTOT",nVlrTot)
If !Empty(cCondic)
	SE4->(DbSetOrder(1))
	SE4->(DbSeek(xFilial("SE4")+cCondic))
	cTpFix := IIf(!Empty(SE4->E4_FORMA),SE4->E4_FORMA,"DP")
	oVS9Mod:SetNoInsertLine(.F.) // Deixa INCLUIR as linhas do VS9
	oVS9Mod:SetNoUpdateLine(.F.) // Deixa ALTERAR as linhas do VS9
	oVS9Mod:SetNoDeleteLine(.F.) // Deixa DELETAR as linhas do VS9
	If !(SE4->E4_TIPO $ "A.9")
		For nCntFor := 1 to oVS9Mod:Length()
			oVS9Mod:GoLine(nCntFor)
			oVS9Mod:LoadValue("VS9_TIPPAG","")
			oVS9Mod:LoadValue("VS9_DATPAG",ctod(""))
			oVS9Mod:LoadValue("VS9_VALPAG",0)
			oVS9Mod:LoadValue("VS9_REFPAG","")
			oVS9Mod:LoadValue("VS9_SEQUEN","")
			If !oVS9Mod:IsDeleted()
				oVS9Mod:DeleteLine()
			EndIf
		Next
		aParcelas := condicao(nVlrTot,cCondic,,dDataBase)
		For nCntFor := 1 to len(aParcelas)
			If oVS9Mod:Length() >= nCntFor
				oVS9Mod:GoLine(nCntFor)
				If oVS9Mod:IsDeleted()
					oVS9Mod:UnDeleteLine()
				EndIf
			Else
				oVS9Mod:AddLine()
			EndIf
			oVS9Mod:LoadValue("VS9_NUMIDE", oVRRMod:GetValue("VRR_CODIGO") )
			oVS9Mod:LoadValue("VS9_TIPOPE", "E" ) // Servicos Especializados
			oVS9Mod:LoadValue("VS9_TIPPAG",padr(cTpFix,GeTSX3Cache("VS9_TIPPAG","X3_TAMANHO")))
			oVS9Mod:LoadValue("VS9_DATPAG",aParcelas[nCntFor,1])
			oVS9Mod:LoadValue("VS9_VALPAG",aParcelas[nCntFor,2])
			oVS9Mod:LoadValue("VS9_REFPAG",strzero(nCntFor,3)+"/"+strzero(len(aParcelas),3))
			oVS9Mod:LoadValue("VS9_SEQUEN",strzero(nCntFor,nTamSeq))
		Next
		oVS9Mod:SetNoInsertLine(.T.) // Nao deixa INCLUIR as linhas do VS9
		oVS9Mod:SetNoDeleteLine(.T.) // Nao deixa DELETAR as linhas do VS9
	EndIf
EndIf
oVRSMod:GoLine(nVRSLin)
oVS9Mod:GoLine(1)
oView:Refresh("VS9DETAIL")
Return

/*/{Protheus.doc} OA4700091_ValidaEstoque
Valida o Estoque do Serviço Especializado

@author Andre Luis Almeida
@since 27/09/2022
/*/
Function OA4700091_ValidaEstoque( cSerInt , nQtdMov )
Local lRet    := .t.
Local nTotEst := 0
Local cSrvAux := ""
DbSelectArea("VPX")
DbSetOrder(1) // VPX_FILIAL + VPX_SERINT
If DbSeek( xFilial("VPX") + cSerInt )
	cSrvAux := CHR(13)+CHR(10)+CHR(13)+CHR(10)+Alltrim(VPX->VPX_GRUSER)+" "+Alltrim(VPX->VPX_CODSER)+CHR(13)+CHR(10)+Alltrim(VPX->VPX_DESSER)+" ("+Alltrim(VPX->VPX_TIPSER)+")"
	DbSelectArea("VPV")
	DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
	DbSeek( xFilial("VPV") + VPX->VPX_TIPSER )
	If VPV->VPV_CTRSLD <> "0" // Tipo de Serviço Especializado controla SALDO de ESTOQUE
		lRet := .f.
		If VPV->VPV_CTRSLD == "1" .and. nQtdMov > 1 // UNITARIO
			Help("",1,"OA4700091_ValidaEstoque",,STR0034+cSrvAux,1,0) // Este Serviço Especializado só pode ser Vendido unitariamente!
		Else
			nTotEst := 0
			DbSelectArea("VPY")
			DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
			If DbSeek( xFilial("VPY") + VPX->VPX_SERINT + xFilial("SD2") ) // Estoque Disponivel na Filial Logada
				nTotEst += VPY->VPY_QTDEST
			EndIf
			If GetNewPar("MV_MIL0182",.F.) // .T. = Faz transferência automática na Venda da quantidade divergente em estoque entre a Filial Centralizadora e a Filial Logada.
				If nTotEst < nQtdMov .and. !Empty(VPV->VPV_FILCEN)
					If DbSeek( xFilial("VPY") + VPX->VPX_SERINT + VPV->VPV_FILCEN ) // Estoque Disponivel na Filial Centralizadora
						nTotEst += VPY->VPY_QTDEST
					EndIf
				EndIf
			EndIf
			If nTotEst >= nQtdMov // Tem no Estoque para atender ?
				lRet := .t.
			EndIf
			If !lRet
				If VPY->VPY_QTDEST == 0
					Help("",1,"OA4700091_ValidaEstoque",,STR0035+cSrvAux,1,0) // Não existe estoque disponivel para este Serviço Especializado!
				Else
					Help("",1,"OA4700091_ValidaEstoque",,STR0036+cSrvAux,1,0) // Quantidade desejada não esta disponível para este Serviço Especializado!
				EndIf
			EndIf
		EndIf
	EndIf
Else
	lRet := .f.
	Help("",1,"OA4700091_ValidaEstoque",,STR0037+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cSerInt,1,0) // Serviço Especializado não encontrado!
EndIf
Return lRet

/*/{Protheus.doc} OA4700101_VerEstoque
Ver o Estoque do Serviço Especializado posicionado

@author Andre Luis Almeida
@since 27/09/2022
/*/
Function OA4700101_VerEstoque()
Local oModel  := FWModelActive()
Local oVRSMod := oModel:GetModel("VRSDETAIL")
Local cFilSD2 := xFilial("SD2")
//
SetKey(VK_F4, Nil )
DbSelectArea("VPY")
DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
If DbSeek( xFilial("VPY") + oVRSMod:GetValue( "VRS_SERINT" ) + cFilSD2 ) .or. DbSeek( xFilial("VPY") + oVRSMod:GetValue( "VRS_SERINT" ) ) // Pega qualquer Filial
	OFIA451( VPY->VPY_FILIAL , VPY->VPY_CODEST , .f. )
EndIf
SetKey(VK_F4,{|| OA4700101_VerEstoque() })
//
Return

/*/{Protheus.doc} OA4700111_AvancaFaseSaida
Avançar a Fase da Saida do Serviço Especializado

@author Andre Luis Almeida
@since 28/09/2022
/*/
Function OA4700111_AvancaFaseSaida()
Local oModel  := FWModelActive()
Local oVRRMod := oModel:GetModel("VRRMASTER")
Local oVRSMod := oModel:GetModel("VRSDETAIL")
Local cCodVRR := oVRRMod:GetValue( "VRR_CODIGO" )
Local cCodCli := oVRRMod:GetValue( "VRR_CODCLI" )
Local cLojCli := oVRRMod:GetValue( "VRR_LOJCLI" )
Local nCntFor := 0
Local nQtdSrv := 0 // Quantidade do Servico
Local nVlrSrv := 0 // Valor do Servico (unitario)
Local nVlrTot := 0 // Total do Servico
Local nTotSai := 0 // Total da Saida para NF ( soma de Todos os Servicos )
Local nDivMin := 0 // Total da Divergencia ( soma de Todos os Servicos com Valores Desejados abaixo do Minimo Permitido )
Local aLimCre := {}
Local aVlrMin := {}
Local nVlrMin := 0
Local cStatus := "4" // 4 - Liberado para Efetivar Saida
Local lOkAvan := .t.
Local cMVCPNCLC := GetNewPar("MV_CPNCLC","")
//
For nCntFor := 1 to oVRSMod:Length()
	oVRSMod:GoLine(nCntFor)
	If !oVRSMod:IsDeleted()
		nQtdSrv := oVRSMod:GetValue( "VRS_QTDSER" ) // Quantidade do Servico
		nVlrTot := oVRSMod:GetValue( "VRS_VLRTOT" ) // Total do Servico
		nVlrSrv := ( nVlrTot / nQtdSrv ) // Valor do Servico (unitario)
		nTotSai += nVlrTot // Total da Saida para NF ( soma de Todos os Servicos )
		VPX->(DbSetOrder(1))
		VPX->(DbSeek(xFilial("VPX")+oVRSMod:GetValue( "VRS_SERINT" )))
		If VPX->VPX_SUGVDA > 0 .or. VPX->VPX_VLRMIN > 0
			nVlrMin := IIf( VPX->VPX_VLRMIN > 0 , VPX->VPX_VLRMIN , OA3800041_Valor( "2" , VPX->VPX_SERINT , VPX->VPX_TIPSER , VPX->VPX_GRUSER , cCodCli , cLojCli , VPX->VPX_CUSMED ) ) // Retorna o Valor Minimo do Serviço
			If nVlrMin > nVlrSrv
				cStatus := "3" // 3 - Pendencias
				nDivMin += ( ( nVlrMin - nVlrSrv ) * nQtdSrv )
			EndIf
			aAdd(aVlrMin,{	( nVlrMin <= nVlrSrv ) ,;
							VPX->VPX_GRUSER ,;
							VPX->VPX_CODSER ,;
							VPX->VPX_DESSER ,;
							VPX->VPX_TIPSER ,;
							nVlrMin ,;
							nVlrSrv ,;
							nQtdSrv ,;
							nVlrTot })
		Endif
	EndIf
Next
If oVRSMod:Length() > 0
	oVRSMod:GoLine(1)
EndIf
//
If Empty(cMVCPNCLC) .or. !AllTrim(oVRRMod:GetValue( "VRR_FORPAG" )) $ cMVCPNCLC
	If "E" $ GetMv("MV_CHKCRE") // Checar Limite de Credito nos Servicos Especializados ?
		SA1->( DbSetOrder(1) )
		If GetMv("MV_CREDCLI") == "C"
			SA1->( DbSeek( xFilial("SA1") + cCodCli ) )
			aAdd(aLimCre,{ .t. , cCodCli , SA1->A1_NOME })
		Else
			SA1->( DbSeek( xFilial("SA1") + cCodCli + cLojCli ) )
			aAdd(aLimCre,{ .t. , cCodCli+"-"+cLojCli , SA1->A1_NOME })
		EndIf
		If !FGX_AVALCRED( SA1->A1_COD , SA1->A1_LOJA , nTotSai , .t. )
			cStatus := "3" // 3 - Pendencias
			aLimCre[1,1] := .f.
		EndIf
	EndIf
EndIf
//
If cStatus == "3" // Possui Pendencia de Valor Minimo dos Serviços e/ou de Limite de Crédito do Cliente
	lOkAvan := OA4710011_InclusaoSolicitacao( cCodVRR , aLimCre , aVlrMin , nTotSai , nDivMin ) // Gravar Tabela de Solicitação e Liberação de Pendencias
EndIf
//
If lOkAvan
	oModel:SetValue( "VRRMASTER", "VRR_STATUS", cStatus ) // Atribui o Status NOVO
EndIf
//
Return lOkAvan

/*/{Protheus.doc} OA4700121_ValidaCamposObrigatorios
Valida se foi informada a Data de Vigencia, Nro de Serie e CHASSI/PIN do Servico Especializado

@author Andre Luis Almeida
@since 07/10/2022
/*/
Function OA4700121_ValidaCamposObrigatorios( cSerInt , cTipSer , dDtIVig , dDtFVig , cNroSer , cChassi )
Local lRet    := .t.
Local cSrvAux := ""
DbSelectArea("VPV")
DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
If DbSeek( xFilial("VPV") + cTipSer ) 
	DbSelectArea("VPX")
	DbSetOrder(1) // VPX_FILIAL + VPX_SERINT
	DbSeek( xFilial("VPX") + cSerInt )
	cSrvAux := CHR(13)+CHR(10)+CHR(13)+CHR(10)+Alltrim(VPX->VPX_GRUSER)+" "+Alltrim(VPX->VPX_CODSER)+CHR(13)+CHR(10)+Alltrim(VPX->VPX_DESSER)+" ("+Alltrim(VPX->VPX_TIPSER)+")"
	If VPV->VPV_DATVIG == "1" .and. ( Empty(dDtIVig) .or. Empty(dDtFVig) ) // Data de Vigencia Obrigatoria
		Help("",1,"OA4700121_ValidaCamposObrigatorios",,STR0038+cSrvAux,1,0) // Necessário informar a Data de Vigência para o Serviço Especializado.
		lRet := .f.
	EndIf
	If VPV->VPV_NROSER == "1" .and. Empty(cNroSer) // Nro.Serie Obrigatorio
		Help("",1,"OA4700121_ValidaCamposObrigatorios",,STR0039+cSrvAux,1,0) // Necessário informar o Nro. de Serie para o Serviço Especializado.
		lRet := .f.
	EndIf
	If VPV->VPV_VINCCP == "1" .and. Empty(cChassi) // Chassi/PIN Obrigatorio
		Help("",1,"OA4700121_ValidaCamposObrigatorios",,STR0040+cSrvAux,1,0) // Necessário informar o Chassi/PIN para o Serviço Especializado.
		lRet := .f.
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OA4700131_StatusSaida
Status de Saida do Servico Especializado - Utilizado no COMBOBOX (SX3) do VRR_STATUS

@author Andre Luis Almeida
@since 11/10/2022
/*/
Function OA4700131_StatusSaida()
Local cRetStatus := ""
//
cRetStatus += "0="+STR0002+";" // Saida Digitada
cRetStatus += "3="+STR0003+";" // Pendências - Aguadando Liberação
cRetStatus += "5="+STR0004+";" // Liberação de Pendências Reprovada
cRetStatus += "4="+STR0005+";" // Liberado para Efetivar Saida
cRetStatus += "1="+STR0006+";" // Saida Efetivada
cRetStatus += "2="+STR0007 // Saida Cancelada
//
Return cRetStatus

/*/{Protheus.doc} OA4700141_VisualizaValorMinimo
Visualiza Valor Desejado x Valor Minimo dos Servicos Especializados

@author Andre Luis Almeida
@since 28/10/2022
/*/
Static Function OA4700141_VisualizaValorMinimo()
Local oModel  := FWModelActive()
Local oVRRMod := oModel:GetModel("VRRMASTER")
Local oVRSMod := oModel:GetModel("VRSDETAIL")
Local cCodCli := oVRRMod:GetValue( "VRR_CODCLI" )
Local cLojCli := oVRRMod:GetValue( "VRR_LOJCLI" )
Local aVlrMin := {}
Local nVlrMin := 0
Local nQtdSrv := 0
Local nVlrTot := 0
Local nVlrSrv := 0
Local nCntFor := 0
//
For nCntFor := 1 to oVRSMod:Length()
	oVRSMod:GoLine(nCntFor)
	If !oVRSMod:IsDeleted()
		nQtdSrv := oVRSMod:GetValue( "VRS_QTDSER" ) // Quantidade do Servico
		nVlrTot := oVRSMod:GetValue( "VRS_VLRTOT" ) // Total do Servico
		nVlrSrv := ( nVlrTot / nQtdSrv ) // Valor do Servico (unitario)
		VPX->(DbSetOrder(1))
		VPX->(DbSeek(xFilial("VPX")+oVRSMod:GetValue( "VRS_SERINT" )))
		nVlrMin := IIf( VPX->VPX_VLRMIN > 0 , VPX->VPX_VLRMIN , OA3800041_Valor( "2" , VPX->VPX_SERINT , VPX->VPX_TIPSER , VPX->VPX_GRUSER , cCodCli , cLojCli , VPX->VPX_CUSMED ) ) // Retorna o Valor Minimo do Serviço
		aAdd(aVlrMin,{	( nVlrMin <= nVlrSrv ) ,;
						VPX->VPX_GRUSER ,;
						VPX->VPX_CODSER ,;
						VPX->VPX_DESSER ,;
						VPX->VPX_TIPSER ,;
						nVlrMin ,;
						nVlrSrv ,;
						nQtdSrv ,;
						nVlrTot })
	EndIf
Next
OA4710041_TelaPendencias( {} , aVlrMin , .f. ) // Apenas Visualiza as Pendencias na Tela de Solicitar Liberacao
If oVRSMod:Length() > 0
	oVRSMod:GoLine(1)
EndIf
//
Return

/*/{Protheus.doc} OA4700151_ImprimirSaida
Impressão dos Dados da Saida

@author Andre Luis Almeida
@since 15/12/2022
/*/
Function OA4700151_ImprimirSaida()
Local aArea     := GetArea()
//
oReport := ReportDef()
oReport:PrintDialog()
RestArea( aArea )
//
Return

/*/{Protheus.doc} ReportDef
	ReportDef para tReport

	@author Andre Luis Almeida
	@since 15/12/2022
/*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local oSection3
Local aStrVRR   := FWFormStruct(3,"VRR")
Local aStrVRS   := FWFormStruct(3,"VRS",{ |x| !AllTrim(x) $ "VRS_FILIAL/VRS_CODIGO/VRS_CODVRR/VRS_SERINT/" })
Local aStrVS9   := FWFormStruct(3,"VS9",{ |x| !AllTrim(x) $ "VS9_FILIAL/VS9_NUMIDE/VS9_DESPAG/VS9_TIPOPE/VS9_DATBAI/VS9_NATSRV/VS9_TIPFEC/VS9_TIPTIT/VS9_SEQPRO/VS9_ENTRAD/VS9_SEQTAR/VS9_PARCEL/VS9_TIPTEM/VS9_LIBVOO/VS9_PARCVD/VS9_OBSMEM/VS9_OBSERV/VS9_OBSPAR/" })
Local nCntFor   := 0
Local cCampo    := ""
//
oReport := TReport():New("OFIA470",cCadastro,,{|oReport| OA4700161_TReport( oReport )})
oReport:SetLandscape() // Imprime o relatório em Paisagem
//
oSection1 := TRSection():New(oReport,"Saida",{"VRR","SA1","SE4"}) // Saida
For nCntFor := 1 to Len(aStrVRR[FORM_STRUCT_TABLE_MODEL])
	cCampo := aStrVRR[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]
	If !aStrVRR[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Campos Reais
		TRCell():New(oSection1,cCampo,"VRR",,,)
	Else // Campos Virtuais
		Do Case
			Case cCampo == "VRR_NOMCLI"
				TRCell():New(oSection1,cCampo,"VRR",,,,, {|| cVRR_NOMCLI },,,,,,,,,)
			Case cCampo == "VRR_NOMVEN"
				TRCell():New(oSection1,cCampo,"VRR",,,,, {|| cVRR_NOMVEN },,,,,,,,,)
			Case cCampo == "VRR_DESFPG"
				TRCell():New(oSection1,cCampo,"VRR",,,,, {|| cVRR_DESFPG },,,,,,,,,)
			Case cCampo == "VRR_DATNFI"
				TRCell():New(oSection1,cCampo,"VRR",,,,, {|| dVRR_DATNFI },,,,,,,,,)
			Case cCampo == "VRR_USRNOM"
				TRCell():New(oSection1,cCampo,"VRR",,,,, {|| cVRR_USRNOM },,,,,,,,,)
		EndCase
	EndIf
Next
//
oSection2 := TRSection():New(oReport,STR0015,{"VRS","VPX"}) // Serviços Especializados
For nCntFor := 1 to Len(aStrVRS[FORM_STRUCT_TABLE_MODEL])
	cCampo := aStrVRS[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]
	If !aStrVRS[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Campos Reais
		TRCell():New(oSection2,cCampo,"VRS",,,)
	Else // Campos Virtuais
		Do Case
			Case cCampo == "VRS_GRUSER"
				TRCell():New(oSection2,cCampo,"VRS",,,,, {|| cVRS_GRUSER },,,,,,,,,)
			Case cCampo == "VRS_CODSER"
				TRCell():New(oSection2,cCampo,"VRS",,,,, {|| cVRS_CODSER },,,,,,,,,)
			Case cCampo == "VRS_DESSER"
				TRCell():New(oSection2,cCampo,"VRS",,,,, {|| cVRS_DESSER },,,,,,,,,)
			Case cCampo == "VRS_TIPSER"
				TRCell():New(oSection2,cCampo,"VRS",,,,, {|| cVRS_TIPSER },,,,,,,,,)
		EndCase
	EndIf
Next
//
TRFunction():New(oSection2:Cell("VRS_VLRTOT"),NIL,"SUM") // Totalizador
//
oSection3 := TRSection():New(oReport,STR0016,{"VS9"}) // Parcelas
For nCntFor := 1 to Len(aStrVS9[FORM_STRUCT_TABLE_MODEL])
	If !aStrVS9[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Campos Reais
		cCampo := aStrVS9[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]
		TRCell():New(oSection3,cCampo,"VS9",,,)
	EndIf
Next
//
oReport:SetTotalInLine(.f.)
//
Return oReport

/*/{Protheus.doc} OA4700161_TReport
	Impressao em tReport

	@author Andre Luis Almeida
	@since 15/12/2022
/*/
Static Function OA4700161_TReport( oReport )
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3)
Local cQuery    := ""
Local cVS9_NUMIDE   := ""
Private cVRR_NOMCLI := ""
Private cVRR_NOMVEN := ""
Private cVRR_DESFPG := ""
Private dVRR_DATNFI := ctod("")
Private cVRR_USRNOM := ""
Private cVRS_GRUSER := ""
Private cVRS_CODSER := ""
Private cVRS_DESSER := ""
Private cVRS_TIPSER := ""
//
cQuery := "SELECT COUNT(*) "
cQuery += "  FROM " + RetSqlName("VRS")
cQuery += " WHERE VRS_FILIAL = '" + VRR->VRR_FILIAL + "'"
cQuery += "   AND VRS_CODVRR = '" + VRR->VRR_CODIGO + "'"
cQuery += "   AND D_E_L_E_T_= ' '"
oReport:SetMeter(FM_SQL(cQuery)+4)
//
oReport:IncMeter()
//
oSection1:Init()
cVRR_NOMCLI := Posicione("SA1",1,xFilial("SA1")+VRR->VRR_CODCLI+VRR->VRR_LOJCLI,"A1_NOME")
cVRR_NOMVEN := Posicione("SA3",1,xFilial("SA3")+VRR->VRR_CODVEN,"A3_NOME")
cVRR_DESFPG := Posicione("SE4",1,xFilial("SE4")+VRR->VRR_FORPAG,"E4_DESCRI")
dVRR_DATNFI := Posicione("SF2",1,xFilial("SF2")+VRR->VRR_NUMNFI+VRR->VRR_SERNFI,"F2_EMISSAO")
cVRR_USRNOM := Left(UsrRetName(VRR->VRR_USRINC),25)
oSection1:PrintLine() // VRR
oSection1:Finish()
oReport:SkipLine()
//
oReport:IncMeter()
//
oSection2:Init()
DbSelectArea("VRS")
DbSetOrder(2) // VRS_FILIAL + VRS_CODVRR
DbSeek( VRR->VRR_FILIAL + VRR->VRR_CODIGO )
Do While !VRS->(Eof()) .and. VRS->VRS_FILIAL == VRR->VRR_FILIAL .and. VRS->VRS_CODVRR == VRR->VRR_CODIGO
	oReport:IncMeter()
	VPX->(DbSetOrder(1))
	VPX->(DbSeek( xFilial("VPX") + VRS->VRS_SERINT ))
	cVRS_GRUSER := VPX->VPX_GRUSER
	cVRS_CODSER := VPX->VPX_CODSER
	cVRS_DESSER := VPX->VPX_DESSER
	cVRS_TIPSER := VPX->VPX_TIPSER
	oSection2:PrintLine() // VRS
	dbSelectArea("VRS")
	dbSkip()
EndDo
oReport:SkipLine()
oSection2:Finish()
oReport:SkipLine()
//
oReport:IncMeter()
//
cVS9_NUMIDE := padr(VRR->VRR_CODIGO,GeTSX3Cache("VS9_NUMIDE","X3_TAMANHO"))
oSection3:Init()
DbSelectArea("VS9")
DbSetOrder(1) // VS9_FILIAL + VS9_NUMIDE + VS9_TIPOPE
DbSeek( VRR->VRR_FILIAL + cVS9_NUMIDE + "E" )
Do While !VS9->(Eof()) .and. VS9->VS9_FILIAL == VRR->VRR_FILIAL .and. VS9->VS9_NUMIDE == cVS9_NUMIDE .and. VS9->VS9_TIPOPE == "E"
	oSection3:PrintLine() // VS9
	dbSelectArea("VS9")
	dbSkip()
EndDo
oReport:SkipLine()
oSection3:Finish()
oReport:SkipLine()
//
oReport:IncMeter()
//
Return Nil

/*/{Protheus.doc} OA4700171_ValidaImpressao
Valida se pode Imprimir os Dados da Saida

@author Andre Luis Almeida
@since 15/12/2022
/*/
Function OA4700171_ValidaImpressao()
Local lImprime   := .t.
Local oModel     := FWModelActive()
Local nOperModel := oModel:GetOperation()
If nOperModel == MODEL_OPERATION_INSERT // Inclusão
	lImprime := .f.
	Help("",1,"OA4700171_ValidaImpressao",,STR0041,1,0) // Opção não disponivel na Inclusão da Saida. Necessário SALVAR e acessar a Impressão via MENU ou através da Visualização da Saida.
ElseIf nOperModel == MODEL_OPERATION_UPDATE // Alteração
	If VRR->VRR_STATUS == "0" // Digitado
		lImprime := .f.
		Help("",1,"OA4700171_ValidaImpressao",,STR0042,1,0) // Opção não disponivel na Alteração da Saida com Status Digitada. Acesse a Impressão via MENU ou através da Visualização da Saida.
	EndIf
EndIf
If lImprime
	OA4700151_ImprimirSaida()
EndIf
Return

/*/{Protheus.doc} OA4700181_VisualizaImpostos
Visualiza Impostos

@author Andre Luis Almeida
@since 20/12/2022
/*/
Function OA4700181_VisualizaImpostos()
Local aSize      := FWGetDialogSize( oMainWnd )
Local oModel     := FWModelActive()
Local nOperModel := oModel:GetOperation()
Local oVRRMod    := oModel:GetModel("VRRMASTER")
Local oVRSMod    := oModel:GetModel("VRSDETAIL")
Local cCodCli    := oVRRMod:GetValue( "VRR_CODCLI" )
Local cLojCli    := oVRRMod:GetValue( "VRR_LOJCLI" )
Local cNature    := oVRRMod:GetValue( "VRR_NATURE" )
Local oFont      := TFont():New( "Arial", 10,14 )
Local nCntFor    := 0
Local nQtdSrv    := 0
Local nVlrTot    := 0
Local nVlrSrv    := 0
Local nVlrImp    := 0
Local nVlrDes    := 0
Local nPerDes    := 0
Local nVlrICM    := 0
Local nVlrISS    := 0
Local nVlrPis    := 0
Local nVlrCof    := 0
Local nVlrIRR    := 0
Local nVlrCSL    := 0
Local nVlrIPI    := 0
Local aImpost    := {}
Private aHeader  := {}         // Variavel necessaria ao MAFISREF
Private aCols    := {}         // Variavel necessaria ao MAFISREF
Private bRefresh := { || .t. } // Variavel necessaria ao MAFISREF
Private N        := 1          // Variavel necessaria ao MAFISREF
Private cCadastro := STR0001+" - "+"Impostos" // Saida de Serviços Especializados / Impostos
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")

If nOperModel == MODEL_OPERATION_INSERT .or. !(VRR->VRR_STATUS $ "12" ) // Inclusão ou NÃO pode ser SAIDA com Status 1-Efetivada ou 2-Cancelada

	DBSelectArea("SA1")
	DBSetOrder(1)
	If Empty(cCodCli+cLojCli) .or. !DBSeek(xFilial("SA1")+cCodCli+cLojCli)
		Help("",1,"OA4700181_VisualizaImpostos",,STR0043,1,0) // Necessário informar um Cliente válido.
		Return
	EndIf

	If MaFisFound('NF') .or. cDebugMIL == "OFIA470017"
		MaFisEnd()
	EndIf

	MaFisIni(cCodCli,cLojCli,'C','N',SA1->A1_TIPO,MaFisRelImp("OF470",{"VRR","VRS"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos Genéricos*/)
	MaFisRef("NF_NATUREZA",, IIf( !Empty(cNature) , cNature , SA1->A1_NATUREZ ) )

	N := 0
	For nCntFor := 1 to oVRSMod:Length()
		oVRSMod:GoLine(nCntFor)
		If !oVRSMod:IsDeleted()
			//
			VPX->(DbSetOrder(1)) // VPX_FILIAL + VPX_SERINT
			VPX->(DbSeek( xFilial("VPX") + oVRSMod:GetValue( "VRS_SERINT" ) ))
			VPV->(DbSetOrder(1)) // VPV_FILIAL + VPV_CODTIP
			VPV->(DbSeek( xFilial("VPV") + VPX->VPX_TIPSER ))
			SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD
			SB1->(DbSeek( xFilial("SB1") + VPV->VPV_CODSB1 ))
			//
			nQtdSrv := oVRSMod:GetValue( "VRS_QTDSER" ) // Quantidade do Servico
			nVlrSrv := oVRSMod:GetValue( "VRS_VLRUNI" ) // Valor do Servico (unitario)
			nVlrTot := ( nVlrSrv * nQtdSrv ) // Total do Servico
			nVlrDes := oVRSMod:GetValue( "VRS_VALDES" ) // Valor Desconto
			If nVlrDes == 0
				nPerDes := oVRSMod:GetValue( "VRS_PERDES" ) // % Desconto
				nVlrDes := IIf( nPerDes > 0 , ( nVlrTot * (nPerDes/100) ) , 0 )
			EndIf
			N++
			MaFisRef("IT_PRODUTO" ,"VRS00",SB1->B1_COD)
			MaFisRef("IT_QUANT"   ,"VRS00",nQtdSrv)
			MaFisRef("IT_TES"     ,"VRS00",oVRSMod:GetValue( "VRS_CODTES" ))
			MaFisRef("IT_PRCUNI"  ,"VRS00",nVlrSrv)
			MaFisRef("IT_VALMERC" ,"VRS00",nVlrTot)
			MaFisRef("IT_DESCONTO","VRS00",nVlrDes)
			//
			nVlrICM += MaFisRet( N ,"IT_VALICM")
			nVlrISS += MaFisRet( N ,"IT_VALISS")
			nVlrPis += MaFisRet( N ,"IT_VALPIS") + MaFisRet( N ,"IT_VALPS2")
			nVlrCof += MaFisRet( N ,"IT_VALCOF") + MaFisRet( N ,"IT_VALCF2")
			nVlrIRR += MaFisRet( N ,"IT_VALIRR")
			nVlrCSL += MaFisRet( N ,"IT_VALCSL")
			nVlrIPI += MaFisRet( N ,"IT_VALIPI")
			//
		EndIf
	Next
	oVRSMod:GoLine(1)

	nVlrTot := MaFisRet(,"NF_TOTAL") - MaFisRet(,"NF_DESCZF")
	nVlrDes := MaFisRet(,"NF_DESCONTO")
	nVlrImp := ( nVlrICM + nVlrISS + nVlrPis + nVlrCof + nVlrIRR + nVlrCSL + nVlrIPI )

	aAdd( aImpost , { STR0044 , nVlrTot + nVlrDes } ) // Total Saida
	IIf( nVlrDes > 0 , aAdd( aImpost , { STR0045 , nVlrDes } ) , .t. ) // Total Desconto
	IIf( nVlrDes > 0 , aAdd( aImpost , { STR0044+" - "+STR0045 , nVlrTot } ) , .t. ) // Total Saida / Total Desconto
	aAdd( aImpost , { STR0046 , nVlrImp } ) // Total Impostos
	IIf( nVlrICM > 0 , aAdd( aImpost , { " - "+STR0047 , nVlrICM } ) , .t. ) // ICMS
	IIf( nVlrISS > 0 , aAdd( aImpost , { " - "+STR0048 , nVlrISS } ) , .t. ) // ISS
	IIf( nVlrPis > 0 , aAdd( aImpost , { " - "+STR0049 , nVlrPis } ) , .t. ) // PIS
	IIf( nVlrCof > 0 , aAdd( aImpost , { " - "+STR0050 , nVlrCof } ) , .t. ) // COFINS
	IIf( nVlrIRR > 0 , aAdd( aImpost , { " - "+STR0051 , nVlrIRR } ) , .t. ) // IRRF
	IIf( nVlrCSL > 0 , aAdd( aImpost , { " - "+STR0052 , nVlrCSL } ) , .t. ) // CSLL
	IIf( nVlrIPI > 0 , aAdd( aImpost , { " - "+STR0053 , nVlrIPI } ) , .t. ) // IPI
	
	MaFisEnd()

	oAuxOA470 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro , , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )
		oLBImpost := TWBrowse():New(1,1,100,100,,,,oAuxOA470,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,)
		oLBImpost:AddColumn( TCColumn():New( STR0001 , { || aImpost[oLBImpost:nAt,1] } ,,,,"LEFT" ,300,.F.,.F.,,,,.F.,) ) // Saida de Serviços Especializados
		oLBImpost:AddColumn( TCColumn():New( STR0054 , { || Transform(aImpost[oLBImpost:nAt,2],"@E 9999,999,999.99") } ,,,,"RIGHT" ,100,.F.,.F.,,,,.F.,) ) // Valor
		oLBImpost:setArray( aImpost )
		oLBImpost:Align := CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oAuxOA470 ON INIT EnchoiceBar(oAuxOA470,{|| oAuxOA470:End() },{|| oAuxOA470:End() },,)

ElseIf VRR->VRR_STATUS == "1" // Saida Efetivada

	Help("",1,"OA4700181_VisualizaImpostos",,STR0055,1,0) // Opção não disponível para Saida Efetivada.

ElseIf VRR->VRR_STATUS == "2" // Saida Cancelada

	Help("",1,"OA4700181_VisualizaImpostos",,STR0056,1,0) // Opção não disponível para Saida Cancelada.

EndIf

Return


/*/{Protheus.doc} OA470018C_BancoConhecimento
Integração com Banco de Conhecimento
@type function
@version 1.0
@author cristiamRossi
@since 5/17/2024
/*/
Function OA470018C_BancoConhecimento()

	If VRR->VRR_STATUS == "1" // Somente EFETIVADA
		dbSelectArea("SF2")
		dbSetOrder(1)
		If dbSeek( xFilial("SF2") + VRR->VRR_NUMNFI + VRR->VRR_SERNFI )
			MsDocument( "SF2", SF2->( Recno() ), 4 )
		EndIf
	Else
		Help("",1,"OA470018C_BancoConhecimento",,STR0090,1,0) // Opção disponível apenas após efetivação da Nota Fiscal
	EndIf

return nil

/*/{Protheus.doc} OA470019H_ImprimirOrcamento
Impressão do Orçamento da Saida de Serviços Especializados
@type function
@version 1.0
@author João Victor Silva
@since 16/04/2025
/*/
Function OA470019H_ImprimirOrcamento()
	
	ExecBlock("ORCSRVE",.f.,.f.,{VRR->VRR_CODIGO})
		
Return

/*/{Protheus.doc} OA470020I_ConfereTipo9
Função para adicionar parcelas ao cabeçalho (SC5) caso a condição de pagamento seja do tipo 9
@type function
@version 1.0
@author João Victor Félix
@since 12/08/2025
/*/

Function OA470020I_ConfereTipo9(aCabNFS)
Local cAliasVS9 := "TVS9"
Local nPosSC5
Local nPosVS9SE1
Local aVS9SE1 := {}

DbSelectArea("SE4")
SE4->(dbSetOrder(1))
SE4->(MsSeek( xFilial("SE4") + M->VRR_FORPAG ))

// Condicao negociada
If SE4->E4_TIPO == "9"

	cParcela := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0" // cParcela igual ao MATA410A, funcao A410Tipo9()
	cSQL := "SELECT VS9_TIPPAG, VS9_DATPAG , VS9_VALPAG"
	cSQL += "  FROM " + RetSQLName("VS9") + " VS9"
	cSQL += " WHERE VS9.VS9_FILIAL = '" + xFilial("VS9") + "'"
	cSQL += "   AND VS9_NUMIDE = '" + VRR->VRR_CODIGO + "'"
	cSQL += "   AND VS9_TIPOPE = 'E'"
	cSQL += "   AND VS9.D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY VS9_NUMIDE , VS9_DATPAG , VS9_SEQUEN"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS9 , .F., .T. )

	While !(cAliasVS9)->(Eof())
		If (nPosVS9SE1 := aScan( aVS9SE1 ,{ |x| x[1] == (cAliasVS9)->VS9_DATPAG .and. x[2] == (cAliasVS9)->VS9_TIPPAG })) == 0
			AADD( aVS9SE1 , { (cAliasVS9)->VS9_DATPAG , (cAliasVS9)->VS9_TIPPAG , "" } )
			nPosVS9SE1 := Len(aVS9SE1)
			aVS9SE1[nPosVS9SE1,3] := SubStr(cParcela,nPosVS9SE1,1)
			
			aAdd(aCabNFS,{"C5_DATA" + aVS9SE1[nPosVS9SE1,3] , StoD((cAliasVS9)->VS9_DATPAG)  , Nil }) // Data da Parcela
			aAdd(aCabNFS,{"C5_PARC" + aVS9SE1[nPosVS9SE1,3] , (cAliasVS9)->VS9_VALPAG        , Nil }) // Valor da Parcela
		Else		
			nPosSC5 := aScan(aCabNFS,{ |x| x[1] == "C5_PARC" + aVS9SE1[nPosVS9SE1,3] })
			aCabNFS[ nPosSC5 , 2 ] += (cAliasVS9)->VS9_VALPAG
		EndIf
		(cAliasVS9)->(dbSkip())
	End
	(cAliasVS9)->(dbCloseArea())
EndIf
Return