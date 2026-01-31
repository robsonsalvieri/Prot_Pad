#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA460.CH"

/*/{Protheus.doc} OFIA460
	Entrada de Serviços Especializados

	@author Andre Luis Almeida
	@since 02/09/2022
/*/
Function OFIA460()
Local aSize       := FWGetDialogSize( oMainWnd )
Local nTamNFI     := GeTSX3Cache("VRP_NUMNFI","X3_TAMANHO")
Private cCadastro := STR0001 // Entrada de Serviços Especializados
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
Private aColsRATCC := {}
Private cSerie

If !OA4500071_Validar_VRQ_SERINT() // Valida o Tamanho do campo VRQ_SERINT
	Return
EndIf

oDlgOA460 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oBrwVRP := FWMBrowse():New()
oBrwVRP:SetAlias('VRP')
oBrwVRP:SetDescription(cCadastro)
oBrwVRP:SetOwner(oDlgOA460)
oBrwVRP:AddLegend( 'VRP->VRP_STATUS == "0"' , 'BR_BRANCO'   , STR0002 ) // Entrada Digitada
oBrwVRP:AddLegend( 'VRP->VRP_STATUS == "1"' , 'BR_VERDE'    , STR0003 ) // Entrada Efetivada
oBrwVRP:AddLegend( 'VRP->VRP_STATUS == "2"' , 'BR_VERMELHO' , STR0004 ) // Entrada Cancelada
oBrwVRP:AddFilter(STR0005, "@ VRP_NUMNFI <> '"+space(nTamNFI)+"'") // Com Nota Fiscal
oBrwVRP:AddFilter(STR0006, "@ VRP_NUMNFI = '"+space(nTamNFI)+"'") // Sem Nota Fiscal
oBrwVRP:DisableDetails()
oBrwVRP:DisableLocate()
oBrwVRP:SetAmbiente(.F.)
oBrwVRP:SetWalkthru(.F.)
oBrwVRP:SetUseFilter()
oBrwVRP:ForceQuitButton()
oBrwVRP:Activate()

oDlgOA460:Activate( , , , , , , ) //ativa a janela

Return

Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0007 ACTION 'OA4600041_VisualizarEntrada()' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.OFIA460' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.OFIA460' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0010 ACTION 'OA4600031_CancelarEntrada()' OPERATION 5 ACCESS 0 // Cancelar
	ADD OPTION aRotina TITLE STR0011 ACTION 'OA4600061_BancoConhecimento()' OPERATION 4 ACCESS 0 // Banco de Conhecimento
	ADD OPTION aRotina TITLE STR0012 ACTION 'OA4600101_ImprimirEntrada()' OPERATION 8 ACCESS 0 // Imprimir Dados da Entrada

Return aRotina


Static Function ModelDef()
Local oStrVRP := FWFormStruct(1,"VRP")
Local oStrVRQ := FWFormStruct(1,"VRQ")

oModel := MPFormModel():New("OFIA460", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VRPMASTER",/*cOwner*/ , oStrVRP)
oModel:AddGrid( "VRQDETAIL" , "VRPMASTER", oStrVRQ , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VRQDETAIL", {{'VRQ_FILIAL','VRP_FILIAL'}, {'VRQ_CODVRP','VRP_CODIGO'}}, VRQ->(IndexKey(1)) )

oModel:GetModel("VRPMASTER"):SetDescription(STR0001) // Entrada de Serviços Especializados
oModel:GetModel("VRQDETAIL"):SetDescription(STR0013) // Serviços Especializados
oModel:GetModel("VRQDETAIL"):SetOptional(.f.) // Não deixa passar com os Serviços em branco

oModel:SetDescription(STR0001) // Entrada de Serviços Especializados
//oModel:InstallEvent("OFIA460LOG", /*cOwner*/, MVCLOGEV():New("OFIA460") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("OFIA460EVDEF", /*cOwner*/, OFIA460EVDEF():New() )

oModel:AddRules( 'VRPMASTER', 'VRP_LOJFOR', 'VRPMASTER', 'VRP_CODFOR', 3)

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
Local oStrVRP:= FWFormStruct(2,"VRP", { |cCampo| !ALLTRIM(cCampo) $ "VRP_CODIGO/" } )
Local oStrVRQ:= FWFormStruct(2,"VRQ", { |cCampo| !ALLTRIM(cCampo) $ "VRQ_CODIGO/VRQ_CODVRP/" } )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:SetCloseOnOk({||.T.})

oView:AddField( 'VIEW_VRP', oStrVRP, 'VRPMASTER' )
oView:AddGrid( 'VIEW_VRQ' , oStrVRQ, 'VRQDETAIL' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' , 35)
oView:CreateHorizontalBox('FILHO' , 65)

oView:SetOwnerView('VIEW_VRP', 'CABEC' )
oView:SetOwnerView('VIEW_VRQ', 'FILHO')

oView:AddUserButton("<F4> "+STR0014,'PRODUTO', {|| OA4600051_VerEstoque() }) // Visualiza Estoque do Serviço Especializado posicionado
oView:AddUserButton(STR0012,'IMPRESSAO', {|| OA4600121_ValidaImpressao() }) // Imprimir Dados da Entrada
If cPaisLoc == "BRA" // Opção disponivel apenas no MATA103 Brasil
	oView:AddUserButton(STR0008+" "+STR0061,'RATEIO', {|| OA460014L_RateioCentroCusto() }) // Incluir
	oView:AddUserButton(STR0007+" "+STR0061,'RATEIO', {|| OA4600151_VisualizarRateioCentroCusto() }) // Visualizar
EndIf

Return oView

/*/{Protheus.doc} OA4600011_GravaStatusEntrada
Grava Status da Entrada

@author Andre Luis Almeida
@since 06/09/2022
/*/
Static Function OA4600011_GravaStatusEntrada( cCodigo , cStatus )
Local oModVRP   := FWLoadModel( 'OFIA461' ) // MVC somente para atualizar o cabeçalho VRP
Default cCodigo := ""
Default cStatus := "0" // 0=Entrada Digitada
VRP->(DbSetOrder(1))
If VRP->(DbSeek(xFilial("VRP")+cCodigo))
	If cStatus <> VRP->VRP_STATUS
		// Gravar Status
		oModVRP:SetOperation( MODEL_OPERATION_UPDATE )
		If oModVRP:Activate()
			oModVRP:SetValue( "VRPMASTER" , "VRP_STATUS" , cStatus ) // 0=Entrada Digitada / 1=Entrada Efetivada / 2=Entrada Cancelada
			If oModVRP:VldData()
				oModVRP:CommitData()
			EndIf
			oModVRP:DeActivate()
		EndIf
	EndIf
EndIf
FreeObj(oModVRP)
Return

/*/{Protheus.doc} OA4600021_IncluirEntrada
Incluir a Entrada de Servicos Especializados

@author Andre Luis Almeida
@since 06/09/2022
/*/
Function OA4600021_IncluirEntrada( lEfetEnt )
Local lRet    := .f.
Local nCntFor := 0
Local nTotSrv := 0
Local nCntSeq := 0
Local aCabNFE := {}
Local aIteNFE := {}
Local aTemp   := {}
Local cTipMov := "0" // 0=Entrada
Local cPorMov := "0" // 0=Normal
Local cOpeMov := "0" // 0=Compra
Local aSrvMov := {}
Local cQuery  := ""
Local cNature := ""
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
Default lEfetEnt := .f.
//
oProcEntr:SetRegua1(3)
oProcEntr:IncRegua1(STR0015) // Levantando Serviços...
//
cQuery := "SELECT COUNT(*) "
cQuery += "  FROM " + RetSqlName("VRQ")
cQuery += " WHERE VRQ_FILIAL = '" + VRP->VRP_FILIAL + "'"
cQuery += "   AND VRQ_CODVRP = '" + VRP->VRP_CODIGO + "'"
cQuery += "   AND D_E_L_E_T_= ' '"
oProcEntr:SetRegua2(FM_SQL(cQuery))
//
BEGIN TRANSACTION
	DbSelectArea("VRQ")
	DbSetOrder(2) // VRQ_FILIAL + VRQ_CODVRP
	If DbSeek( VRP->VRP_FILIAL + VRP->VRP_CODIGO )
		lRet := .t.
		Do While !VRQ->(Eof()) .and. VRQ->VRQ_FILIAL == VRP->VRP_FILIAL .and. VRQ->VRQ_CODVRP == VRP->VRP_CODIGO
			//
			oProcEntr:IncRegua2()
			//
			VPX->(DbSetOrder(1)) // VPX_FILIAL + VPX_SERINT
			VPX->(DbSeek( xFilial("VPX") + VRQ->VRQ_SERINT ))
			VPV->(DbSetOrder(1)) // VPV_FILIAL + VPV_CODTIP
			VPV->(DbSeek( xFilial("VPV") + VPX->VPX_TIPSER ))
			If VPV->VPV_CTRSLD <> "0" // Se possuir algum tipo de controle de SALDO de ESTOQUE - verificar saldo
				aAdd(aSrvMov,{ VRQ->VRQ_SERINT , VRQ->VRQ_QTDSER })
			EndIf
			//
			If !Empty(VRP->VRP_NUMNFI)
				//
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+VPV->VPV_CODSB1))
				//
				nCntSeq++
				aTemp := {}
				aAdd(aTemp,{ "D1_DOC"     , VRP->VRP_NUMNFI                       , Nil })
				aAdd(aTemp,{ "D1_SERIE"   , VRP->VRP_SERNFI                       , Nil })
				aAdd(aTemp,{ "D1_ITEM"    , strzero(nCntSeq,TamSX3("D1_ITEM")[1]) , Nil })
				aAdd(aTemp,{ "D1_COD"     , SB1->B1_COD                           , Nil })
				aAdd(aTemp,{ "D1_UM"      , SB1->B1_UM                            , Nil })
				aAdd(aTemp,{ "D1_QUANT"   , VRQ->VRQ_QTDSER                       , Nil })
				aAdd(aTemp,{ "D1_VUNIT"   , VRQ->VRQ_VLRUNI                       , Nil })
				aAdd(aTemp,{ "D1_TOTAL"   , VRQ->VRQ_QTDSER * VRQ->VRQ_VLRUNI     , Nil })
				aAdd(aTemp,{ "D1_EMISSAO" , dDataBase                             , Nil })
				aAdd(aTemp,{ "D1_TES"     , VRQ->VRQ_CODTES                       , Nil })
				aAdd(aTemp,{ "D1_LOCAL"   , SB1->B1_LOCPAD                        , Nil })
				If aScan(aColsRATCC, {|x| x[1] == strzero(nCntSeq,TamSX3("D1_ITEM")[1]) }) > 0 //Se tiver rateio para este item
					aAdd(aTemp,{"D1_RATEIO", 	'1' , Nil})
				EndIf
				aAdd(aIteNFE,aclone(aTemp))
				//
				nTotSrv += ( VRQ->VRQ_QTDSER * VRQ->VRQ_VLRUNI )
				//
			EndIf
			//
			dbSelectArea("VRQ")
			dbSkip()
		Enddo
		//
		If len(aIteNFE) > 0
			//
			oProcEntr:IncRegua1(STR0016) // Efetivando a Nota Fiscal de Entrada...
			oProcEntr:SetRegua2(2)
			oProcEntr:IncRegua2()
			//
			SA2->(DbSetOrder(1))
			SA2->(DbSeek( xFilial("SA2") + VRP->VRP_CODFOR + VRP->VRP_LOJFOR ))
			//
			cNature := IIf( VRP->(FieldPos("VRP_NATURE")) > 0 .AND. !Empty(VRP->VRP_NATURE) , VRP->VRP_NATURE , SA2->A2_NATUREZ )
			//
			aAdd(aCabNFE,{"F1_TIPO"   , "N"             ,Nil})
			aAdd(aCabNFE,{"F1_FORMUL" , "N"             ,Nil})
			aAdd(aCabNFE,{"F1_DOC"    , VRP->VRP_NUMNFI ,Nil})
			aAdd(aCabNFE,{"F1_SERIE"  , VRP->VRP_SERNFI ,Nil})
			aAdd(aCabNFE,{"F1_COND"   , VRP->VRP_FORPAG ,Nil})
			aAdd(aCabNFE,{"F1_EMISSAO", dDataBase       ,Nil})
			aAdd(aCabNFE,{"F1_FORNECE", VRP->VRP_CODFOR ,Nil})
			aAdd(aCabNFE,{"F1_LOJA"   , VRP->VRP_LOJFOR ,Nil})
			aAdd(aCabNFE,{"F1_VALMERC", nTotSrv         ,Nil})
			aAdd(aCabNFE,{"F1_VALBRUT", nTotSrv         ,Nil})
			aAdd(aCabNFE,{"F1_EST"    , SA2->A2_EST     ,Nil})
			aAdd(aCabNFE,{"F1_PLIQUI" , 0               ,Nil})
			aAdd(aCabNFE,{"F1_PBRUTO" , 0               ,Nil})
			aAdd(aCabNFE,{"F1_ESPECI1", ""              ,Nil})
			aAdd(aCabNFE,{"F1_VOLUME1", 0               ,Nil})
			aAdd(aCabNFE,{"F1_ESPECI2", ""              ,Nil})
			aAdd(aCabNFE,{"F1_VOLUME2", 0               ,Nil})
			aAdd(aCabNFE,{"F1_ESPECI3", ""              ,Nil})
			aAdd(aCabNFE,{"F1_VOLUME3", 0               ,Nil})
			aAdd(aCabNFE,{"F1_ESPECI4", ""              ,Nil})
			aAdd(aCabNFE,{"F1_VOLUME4", 0               ,Nil})
			aAdd(aCabNFE,{"F1_ESPECIE", VRP->VRP_ESPEC  ,Nil})
			aAdd(aCabNFE,{"E2_NATUREZ", cNature         ,Nil})
			//
			lMSHelpAuto := .t.
			lMsErroAuto := .f.
			MSExecAuto({|x,y,z,w,r,s,t,u| MATA103(x,y,z,w,r,s,t,u)}, aCabNFE,aIteNFE,3,,,,,aColsRATCC)
			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
				RollBackSX8()
				lRet := .f.
			Else
				ConfirmSx8() // Confirm do Nro NF
			EndIf
			//
		EndIf
		If lRet .and. lEfetEnt
			oProcEntr:IncRegua2()
			oProcEntr:IncRegua1(STR0017) // Atualizando Estoque dos Serviços...
			oProcEntr:SetRegua2(len(aSrvMov))
			For nCntFor := 1 to len(aSrvMov)
				oProcEntr:IncRegua2()
				cSeqMov := OFIA452( aSrvMov[nCntFor,1] , cTipMov , cPorMov , cOpeMov , aSrvMov[nCntFor,2] , VRP->VRP_FILIAL , VRP->VRP_CODIGO ) // Grava a Movimentação de Estoque do Servico Especializado
				If Empty(cSeqMov) .or. cDebugMIL == "OFIA460003"
					lRet := .f.
					DisarmTransaction()
					Exit
				EndIf
			Next
		EndIf
	EndIf
END TRANSACTION
If lRet
	OA4600011_GravaStatusEntrada( VRP->VRP_CODIGO , "1" ) // Mudar Status para 1=Entrada Efetivada
	OA4500041_AjustaCustoMedio( VRP->VRP_FILIAL , VRP->VRP_CODIGO ) // Ajusta Custo Medio dos Serviços da Entrada
EndIf
dbSelectArea("SX6")
MsRUnLock()
Return lRet

/*/{Protheus.doc} OA4600031_CancelarEntrada
Opção CANCELAR do aRotina do OFIA460 - Entrada de Servicos Especializados

@author Andre Luis Almeida
@since 06/09/2022
/*/
Function OA4600031_CancelarEntrada()
Local lRet    := .f.
Local cSeqMov := "NAOCONTROLA" // Necessario conteudo para iniciar o While
Local cTipMov := "1" // 1=Saida
Local cPorMov := "1" // 1=Por Cancelamento
Local cOpeMov := "0" // 0=Compra
Local cFilSD2 := xFilial("SD2")
Local nCntFor := 0
Local aSrvMov := {}
Local aCabNFE := {}
Local aIteNFE := {}
Local aTemp   := {}
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
If VRP->VRP_STATUS == "2" // 2=Entrada Cancelada
	Help("",1,"OA4600031_CancelarEntrada",,STR0018,1,0) // Entrada já Cancelada. Impossível continuar.
Else
	If MsgNoYes(STR0019,STR0020) // Confirma o Cancelamento da Entrada? / Atenção
		lRet := .t.
		BEGIN TRANSACTION
		If VRP->VRP_STATUS == "1" // 1=Entrada Efetivada
			DbSelectArea("VRQ")
			DbSetOrder(2) // VRQ_FILIAL + VRQ_CODVRP
			DbSeek( VRP->VRP_FILIAL + VRP->VRP_CODIGO )
			Do While ( !VRQ->(Eof()) .and. VRQ->VRQ_FILIAL == VRP->VRP_FILIAL .and. VRQ->VRQ_CODVRP == VRP->VRP_CODIGO )
				DbSelectArea("VPX")
				DbSetOrder(1) // VPX_FILIAL + VPX_SERINT
				DbSeek( xFilial("VPX") + VRQ->VRQ_SERINT )
				DbSelectArea("VPV")
				DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
				DbSeek( xFilial("VPV") + VPX->VPX_TIPSER )
				If VPV->VPV_CTRSLD <> "0" // Se possuir algum tipo de controle de SALDO de ESTOQUE - verificar saldo
					DbSelectArea("VPY")
					DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
					If ( !DbSeek( xFilial("VPY") + VRQ->VRQ_SERINT + cFilSD2 ) .or. VPY->VPY_QTDEST < VRQ->VRQ_QTDSER ) // NAO possui Estoque
						Help("",1,"OA4600031_CancelarEntrada",,STR0021,1,0) // Serviço Especializado não se encontra mais no Estoque da Filial logada! Impossível continuar.
						lRet := .f.
						Exit
					EndIf
					aAdd(aSrvMov,{ VRQ->VRQ_SERINT , VRQ->VRQ_QTDSER })
				EndIf
				dbSelectArea("VRQ")
				dbSkip()
			Enddo
			If lRet
				For nCntFor := 1 to len(aSrvMov)
					cSeqMov := OFIA452( aSrvMov[nCntFor,1] , cTipMov , cPorMov , cOpeMov , aSrvMov[nCntFor,2] , VRP->VRP_FILIAL , VRP->VRP_CODIGO ) // Grava a Movimentação de Estoque do Servico Especializado
					If Empty(cSeqMov) .or. cDebugMIL == "OFIA460006"
						Exit
					EndIf
				Next
				lRet := .f.
				If !Empty(cSeqMov)
					lRet := .T.
					If !Empty(VRP->VRP_NUMNFI) // Possui NF
						//Chamar o MATA103 cancelando
						dbSelectArea("SF1")
						dbSetOrder(1)
						If dbSeek(xFilial("SF1") + VRP->VRP_NUMNFI + VRP->VRP_SERNFI + VRP->VRP_CODFOR + VRP->VRP_LOJFOR )
							aCabNFE   := {}
							aAdd(aCabNFE,{"F1_DOC"		,SF1->F1_DOC    ,Nil})
							aAdd(aCabNFE,{"F1_SERIE"	,SF1->F1_SERIE  ,Nil})
							aAdd(aCabNFE,{"F1_FORNECE"	,SF1->F1_FORNECE,Nil})
							aAdd(aCabNFE,{"F1_LOJA" 	,SF1->F1_LOJA   ,Nil})
							aAdd(aCabNFE,{"F1_TIPO"		,SF1->F1_TIPO   ,Nil})
							aAdd(aCabNFE,{"F1_FORMUL"	,SF1->F1_FORMUL ,Nil})
							aAdd(aCabNFE,{"F1_EMISSAO"	,SF1->F1_EMISSAO,Nil})
							aAdd(aCabNFE,{"F1_ESPECIE"	,SF1->F1_ESPECIE,Nil})
							aAdd(aCabNFE,{"F1_COND"		,SF1->F1_COND   ,Nil})
							aAdd(aCabNFE,{"F1_EST"		,SF1->F1_EST    ,Nil})
							dbSelectArea("SD1")
							dbSetOrder(1)
							dbSeek(xFilial("SD1") + VRP->VRP_NUMNFI + VRP->VRP_SERNFI + VRP->VRP_CODFOR + VRP->VRP_LOJFOR )
							While !eof() .and. xFilial("SD1") + VRP->VRP_NUMNFI + VRP->VRP_SERNFI + VRP->VRP_CODFOR + VRP->VRP_LOJFOR == ;
												SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
								aTemp := {}
								aAdd(aTemp,{"D1_DOC"    ,SD1->D1_DOC    ,Nil})
								aAdd(aTemp,{"D1_SERIE"  ,SD1->D1_SERIE  ,Nil})
								aAdd(aTemp,{"D1_FORNECE",SD1->D1_FORNECE,Nil})
								aAdd(aTemp,{"D1_LOJA"   ,SD1->D1_LOJA   ,Nil})
								aAdd(aTemp,{"D1_COD"    ,SD1->D1_COD    ,Nil})
								aAdd(aTemp,{"D1_ITEM"   ,SD1->D1_ITEM   ,Nil})
								aAdd(aIteNFE,aclone(aTemp))
								DBSelectArea("SD1")
								DbSkip()
							enddo
							//
							lMSHelpAuto := .t.
							lMsErroAuto := .f.
							MSExecAuto({|x,y,z|Mata103(x,y,z)},aCabNFE,aIteNFE,5)
							If lMsErroAuto .or. cDebugMIL == "OFIA460007"
								MostraErro()
								DisarmTransaction()
								lRet := .f.
							EndIf
						EndIf
					EndIf

				EndIf
			EndIf
		EndIf
		END TRANSACTION
	EndIf
EndIf
If lRet
	OA4600011_GravaStatusEntrada( VRP->VRP_CODIGO , "2" ) // Mudar Status para 2=Entrada Cancelada
	OA4500051_ZeraCustoMedio( "E" , VRP->VRP_FILIAL , VRP->VRP_CODIGO ) // Zera Custo Medio se o Cancelamento da Entrada Zerar o Estoque dos Serviços
EndIf
Return lRet

/*/{Protheus.doc} OA4600041_VisualizarEntrada
Visualizar Entrada

@author Andre Luis Almeida
@since 09/09/2022
/*/
Function OA4600041_VisualizarEntrada()
Local cMsgAvi := ""
Local nOpcAvi := 1
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
If VRP->VRP_STATUS == "1" .and. !Empty(VRP->VRP_NUMNFI) // Entrada Efetivada COM NF
	cMsgAvi += CHR(13)+CHR(10)
	cMsgAvi += "- "+STR0022+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Registro da Entrada do Serviço Especializado
	cMsgAvi += "- "+STR0023 // Nota Fiscal de Entrada do Serviço Especializado
	nOpcAvi := Aviso(STR0007,cMsgAvi,{STR0024,STR0025,STR0010},3) // Visualizar / Reg.Entrada / Nota Fiscal / Cancelar
EndIf
If nOpcAvi == 1 // Visualizar Cadastro VRP
	DbSelectArea("VRP")
	oExecView := FWViewExec():New()
	oExecView:SetTitle(STR0007) // Visualizar
	oExecView:SetSource("OFIA460")
	oExecView:SetOperation(MODEL_OPERATION_VIEW)
	oExecView:OpenView(.T.)
ElseIf nOpcAvi == 2 // Visualizar a NF Entrada
	SF1->(DbSetOrder(1))
	SF1->(DbSeek(xFilial("SF1")+VRP->VRP_NUMNFI+VRP->VRP_SERNFI+VRP->VRP_CODFOR+VRP->VRP_LOJFOR))
	MATA103(,,2)
EndIf
Return

/*/{Protheus.doc} OA4600051_VerEstoque
Ver o Estoque do Serviço Especializado posicionado

@author Andre Luis Almeida
@since 03/11/2022
/*/
Function OA4600051_VerEstoque()
Local oModel     := FWModelActive()
Local oVRQMod    := oModel:GetModel("VRQDETAIL")
Local nOperModel := oModel:GetOperation()
Local cFilSD2    := xFilial("SD2")
//
SetKey(VK_F4, Nil )
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	SetKey(VK_F7, Nil )
EndIf
DbSelectArea("VPY")
DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
If DbSeek( xFilial("VPY") + oVRQMod:GetValue( "VRQ_SERINT" ) + cFilSD2 ) // Pega a Filial Logada
	OFIA451( VPY->VPY_FILIAL , VPY->VPY_CODEST , .f. )
ElseIf DbSeek( xFilial("VPY") + oVRQMod:GetValue( "VRQ_SERINT" ) ) // Pega qualquer Filial
	OFIA451( VPY->VPY_FILIAL , VPY->VPY_CODEST , .f. )
Else
	Help("",1,"OA4600051_VerEstoque",,STR0026,1,0) // Não existe estoque disponivel para esse Serviço Especializado.
EndIf
SetKey(VK_F4,{|| OA4600051_VerEstoque() })
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	SetKey(VK_F7,{|| OA4600071_RelacionaSaida() })
EndIf
//
Return

/*/{Protheus.doc} OA4600061_BancoConhecimento
Banco de Conhecimento

@author Andre Luis Almeida
@since 06/12/2022
/*/
Function OA4600061_BancoConhecimento()

If VRP->VRP_STATUS == "1" // Somente EFETIVADA
	dbSelectArea("SF1")
	dbSetOrder(1)
	If dbSeek(xFilial("SF1") + VRP->VRP_NUMNFI + VRP->VRP_SERNFI + VRP->VRP_CODFOR + VRP->VRP_LOJFOR )
		MsDocument( "SF1", SF1->( Recno() ), 4 )
	EndIf
Else
	Help("",1,"OA4600061_BancoConhecimento",,STR0027,1,0) // Opção disponível apenas após efetivação da Nota Fiscal.
EndIf

Return

/*/{Protheus.doc} OA4600071_RelacionaSaida
Relaciona a Entrada com a Saida

@author Andre Luis Almeida
@since 07/12/2022
/*/
Function OA4600071_RelacionaSaida()
Local oModel     := FWModelActive()
Local oView      := FWViewActive()
Local nOperModel := oModel:GetOperation()
Local oVRQMod    := oModel:GetModel("VRQDETAIL")
Local nLinhaAt   := oVRQMod:GetLine()
Local cRelacion  := ""
Local nCntFor    := 0
Local nRecVRQ    := 0
Local aRetTela   := {" "," ",0}
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
//
SetKey(VK_F4, Nil )
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	SetKey(VK_F7, Nil )
EndIf
If Empty(oVRQMod:GetValue( "VRQ_CODVRS" ))
	Help("",1,"OA4600071_RelacionaSaida",,STR0028,1,0) // Tipo de Serviço não permite relacionar a Entrada com a Saida.
Else
	If nOperModel == MODEL_OPERATION_UPDATE // Alteração
		nRecVRQ := VRQ->(RecNo())
	EndIf
	For nCntFor := 1 to oVRQMod:Length()
		oVRQMod:GoLine(nCntFor)
		If !oVRQMod:IsDeleted()
			cRelacion += oVRQMod:GetValue("VRQ_FILVRS")+oVRQMod:GetValue("VRQ_CODVRS")+"/"
		EndIf
	Next
	If nRecVRQ > 0
		VRQ->(DbGoTo(nRecVRQ))
	EndIf
	oVRQMod:GoLine(nLinhaAt)
	aRetTela := OA4600081_Saidas( oVRQMod:GetValue("VRQ_SERINT") , oVRQMod:GetValue("VRQ_FILVRS") , oVRQMod:GetValue("VRQ_CODVRS") , oVRQMod:GetValue("VRQ_QTDSER") , cRelacion )
	If nRecVRQ > 0
		VRQ->(DbGoTo(nRecVRQ))
	EndIf
	oVRQMod:GoLine(nLinhaAt)
	oVRQMod:LoadValue( "VRQ_FILVRS" , aRetTela[1] )
	oVRQMod:LoadValue( "VRQ_CODVRS" , aRetTela[2] )
	oVRQMod:SetValue(  "VRQ_QTDSER" , aRetTela[3] )
	oView:Refresh("VRQDETAIL")
EndIf
SetKey(VK_F4,{|| OA4600051_VerEstoque() })
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	SetKey(VK_F7,{|| OA4600071_RelacionaSaida() })
EndIf
//
Return

/*/{Protheus.doc} OA4600081_Saidas
Tela para selecionar o Serviço na Saida

@author Andre Luis Almeida
@since 12/12/2022
/*/
Static Function OA4600081_Saidas( cSerInt , cFilVRS , cCodVRS , nQtdSer , cRelacion )
Local oModel      := FWModelActive()
Local nOperModel  := oModel:GetOperation()
Local cFiltro     := ""
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0029 // Relacionar com a Saida de Serviços Especializados

cFiltro := "@ VRS_SERINT = '"+cSerInt+"'"
cFiltro += " AND EXISTS ("
cFiltro += " SELECT VRR.VRR_CODIGO "
cFiltro += "   FROM " + RetSqlName("VRR") + " VRR "
cFiltro += "  WHERE VRR.VRR_FILIAL = VRS_FILIAL "
cFiltro += "    AND VRR.VRR_CODIGO = VRS_CODVRR "
cFiltro += "    AND VRR.VRR_STATUS = '1' "
cFiltro += "    AND VRR.D_E_L_E_T_ = ' ' )"
cFiltro += " AND NOT EXISTS ("
cFiltro += " SELECT VRQ.VRQ_CODIGO "
cFiltro += "   FROM " + RetSqlName("VRQ") + " VRQ "
cFiltro += "   JOIN " + RetSqlName("VRP") + " VRP ON VRP.VRP_FILIAL=VRQ.VRQ_FILIAL AND VRP.VRP_CODIGO=VRQ.VRQ_CODVRP AND VRP.VRP_STATUS<>'2' AND VRP.D_E_L_E_T_=' ' "
If nOperModel == MODEL_OPERATION_UPDATE // Alteração
	cFiltro += " AND ( VRP.VRP_FILIAL <> '"+VRP->VRP_FILIAL+"' OR VRP.VRP_CODIGO <> '"+VRP->VRP_CODIGO+"' )"
EndIf
cFiltro += "  WHERE VRQ.VRQ_FILVRS = VRS_FILIAL "
cFiltro += "    AND VRQ.VRQ_CODVRS = VRS_CODIGO "
cFiltro += "    AND VRQ.D_E_L_E_T_ = ' ' )"

oAuxOA460 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWorkArea := FWUIWorkArea():New( oAuxOA460 )
oWorkArea:CreateHorizontalBox( "LINE01", 70 , .f. )
oWorkArea:SetBoxCols( "LINE01", { "OBJServico" } )
oWorkArea:CreateHorizontalBox( "LINE02", 30 , .f. )
oWorkArea:SetBoxCols( "LINE02", { "OBJSaida" } )
oWorkArea:Activate()

oBrwVRR := FWMBrowse():New()
oBrwVRR:SetAlias('VRR')
oBrwVRR:SetDescription(STR0030) // Dados da Saida do Serviço Especializado posicionado
oBrwVRR:SetOwner(oWorkarea:GetPanel("OBJSaida"))
oBrwVRR:SetMenuDef( '' )
oBrwVRR:SetDoubleClick( { || OA4600091_VisualizarSaida() } )
oBrwVRR:AddButton(STR0031,{|| OA4600091_VisualizarSaida() },,2,2) // Visualizar Saida
oBrwVRR:DisableDetails()
oBrwVRR:DisableLocate()
oBrwVRR:DisableConfig()
oBrwVRR:DisableSeek()
oBrwVRR:SetAmbiente(.F.)
oBrwVRR:SetWalkthru(.F.)
oBrwVRR:SetUseFilter(.f.)
oBrwVRR:lOptionReport := .f.
oBrwVRR:Activate()

oBrwVRS := FWMBrowse():New()
oBrwVRS:SetAlias('VRS')
oBrwVRS:SetDescription(cCadastro)
oBrwVRS:SetMenuDef( '' )
oBrwVRS:SetOwner(oWorkarea:GetPanel("OBJServico"))
oBrwVRS:AddLegend( 'VRS->VRS_FILIAL == "'+cFilVRS+'" .AND. VRS->VRS_CODIGO == "'+cCodVRS+'"' , 'BR_VERDE'  , STR0032 ) // Selecionado no Serviço posicionado
If !Empty(cRelacion)
	oBrwVRS:AddLegend( 'VRS->VRS_FILIAL+VRS->VRS_CODIGO $ "'+cRelacion+'"' , 'BR_AZUL' , STR0033 ) // Já Relacionado a outro Serviço
EndIf
oBrwVRS:AddLegend( 'VRS->VRS_FILIAL <> "'+cFilVRS+'" .OR. VRS->VRS_CODIGO <> "'+cCodVRS+'"' , 'BR_BRANCO' , STR0034 ) // Não Selecionado
oBrwVRS:SetFilterDefault(cFiltro)
oBrwVRS:SetDoubleClick( { || cFilVRS := VRS->VRS_FILIAL , cCodVRS := VRS->VRS_CODIGO , nQtdSer := VRS->VRS_QTDSER , oAuxOA460:End() } )
oBrwVRS:AddButton(STR0035,{|| cFilVRS := VRS->VRS_FILIAL , cCodVRS := VRS->VRS_CODIGO , nQtdSer := VRS->VRS_QTDSER , oAuxOA460:End() },,2,2) // Selecionar Saida
oBrwVRS:AddButton(STR0036,{|| cFilVRS := "" , cCodVRS := "<F7>" , nQtdSer := 0 , oAuxOA460:End() },,2,2) // Retirar seleção
oBrwVRS:DisableDetails()
oBrwVRS:DisableLocate()
oBrwVRS:DisableConfig()
oBrwVRS:SetAmbiente(.F.)
oBrwVRS:SetWalkthru(.F.)
oBrwVRS:SetUseFilter()
oBrwVRS:ForceQuitButton()
oBrwVRS:lOptionReport := .f.
oBrwVRS:Activate()

oRelac:= FWBrwRelation():New() 
oRelac:AddRelation( oBrwVRS , oBrwVRR , { { "VRR_FILIAL" , "VRS_FILIAL" }, { "VRR_CODIGO" , "VRS_CODVRR" } })
oRelac:Activate()

oAuxOA460:Activate( , , , , , , ) //ativa a janela

cCodVRS := IIf(!Empty(cCodVRS),cCodVRS,"<F7>")

Return { cFilVRS , cCodVRS , nQtdSer }

/*/{Protheus.doc} OA4600091_VisualizarSaida
Chama Visualização da Saida OFIA470

@author Andre Luis Almeida
@since 13/12/2022
/*/
Static Function OA4600091_VisualizarSaida()
Local nRecVRS := VRS->(RecNo())
DbSelectArea("VRR")
DbSetOrder(1)
If DbSeek( VRS->VRS_FILIAL + VRS->VRS_CODVRR )
	OA4700051_VisualizarSaida()
EndIf
DbSelectArea("VRS")
DbGoTo(nRecVRS)
Return()
/*/{Protheus.doc} OA4600101_ImprimirEntrada
Impressão dos Dados da Entrada

@author Andre Luis Almeida
@since 14/12/2022
/*/
Function OA4600101_ImprimirEntrada()
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
	@since 14/12/2022
/*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local aStrVRP   := FWFormStruct(3,"VRP")
Local aStrVRQ   := FWFormStruct(3,"VRQ",{ |x| !AllTrim(x) $ "VRQ_FILIAL/VRQ_CODIGO/VRQ_CODVRP/VRQ_SERINT/VRQ_CODVRS/" })
Local nCntFor   := 0
Local cCampo    := ""
//
oReport := TReport():New("OFIA460",cCadastro,,{|oReport| OA4600111_TReport( oReport )})
oReport:SetLandscape() // Imprime o relatório em Paisagem
//
oSection1 := TRSection():New(oReport,STR0039,{"VRP","SA2","SE4"}) // Entrada
For nCntFor := 1 to Len(aStrVRP[FORM_STRUCT_TABLE_MODEL])
	cCampo := aStrVRP[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]
	If !aStrVRP[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Campos Reais
		TRCell():New(oSection1,cCampo,"VRP",,,)
	Else // Campos Virtuais
		Do Case
			Case cCampo == "VRP_NOMFOR"
				TRCell():New(oSection1,cCampo,"VRP",,,,, {|| cVRP_NOMFOR },,,,,,,,,)
			Case cCampo == "VRP_DESFPG"
				TRCell():New(oSection1,cCampo,"VRP",,,,, {|| cVRP_DESFPG },,,,,,,,,)
			Case cCampo == "VRP_USRNOM"
				TRCell():New(oSection1,cCampo,"VRP",,,,, {|| cVRP_USRNOM },,,,,,,,,)
		EndCase
	EndIf
Next
//
oSection2 := TRSection():New(oReport,STR0013,{"VRQ","VPX"}) // Serviços Especializados
For nCntFor := 1 to Len(aStrVRQ[FORM_STRUCT_TABLE_MODEL])
	cCampo := aStrVRQ[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]
	If !aStrVRQ[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Campos Reais
		TRCell():New(oSection2,cCampo,"VRQ",,,)
	Else // Campos Virtuais
		Do Case
			Case cCampo == "VRQ_GRUSER"
				TRCell():New(oSection2,cCampo,"VRQ",,,,, {|| cVRQ_GRUSER },,,,,,,,,)
			Case cCampo == "VRQ_CODSER"
				TRCell():New(oSection2,cCampo,"VRQ",,,,, {|| cVRQ_CODSER },,,,,,,,,)
			Case cCampo == "VRQ_DESSER"
				TRCell():New(oSection2,cCampo,"VRQ",,,,, {|| cVRQ_DESSER },,,,,,,,,)
			Case cCampo == "VRQ_TIPSER"
				TRCell():New(oSection2,cCampo,"VRQ",,,,, {|| cVRQ_TIPSER },,,,,,,,,)
		EndCase
	EndIf
Next
// Campos Relacionados a Saida
TRCell():New(oSection2,"VRR_NUMNFI","VRR",,,,, {|| cVRR_NUMNFI },,,,,,,,,)
TRCell():New(oSection2,"VRR_SERNFI","VRR",,,,, {|| cVRR_SERNFI },,,,,,,,,)
TRCell():New(oSection2,"VRR_DATNFI","VRR",,,,, {|| dVRR_DATNFI },,,,,,,,,)
TRCell():New(oSection2,"VRS_DTIVIG","VRS",,,,, {|| dVRS_DTIVIG },,,,,,,,,)
TRCell():New(oSection2,"VRS_DTFVIG","VRS",,,,, {|| dVRS_DTFVIG },,,,,,,,,)
TRCell():New(oSection2,"VRS_NROSER","VRS",,,,, {|| cVRS_NROSER },,,,,,,,,)
TRCell():New(oSection2,"VRS_CHASSI","VRS",,,,, {|| cVRS_CHASSI },,,,,,,,,)
//
TRFunction():New(oSection2:Cell("VRQ_VLRTOT"),NIL,"SUM") // Totalizador
//
oReport:SetTotalInLine(.f.)
//
Return oReport

/*/{Protheus.doc} OA4600111_TReport
	Impressao em tReport

	@author Andre Luis Almeida
	@since 14/12/2022
/*/
Static Function OA4600111_TReport( oReport )
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local cQuery    := ""
Private cVRP_NOMFOR := ""
Private cVRP_DESFPG := ""
Private cVRP_USRNOM := ""
Private cVRQ_GRUSER := ""
Private cVRQ_CODSER := ""
Private cVRQ_DESSER := ""
Private cVRQ_TIPSER := ""
Private cVRR_NUMNFI := ""
Private cVRR_SERNFI := ""
Private dVRR_DATNFI := ctod("")
Private dVRS_DTIVIG := ctod("")
Private dVRS_DTFVIG := ctod("")
Private cVRS_NROSER := ""
Private cVRS_CHASSI := ""
//
cQuery := "SELECT COUNT(*) "
cQuery += "  FROM " + RetSqlName("VRQ")
cQuery += " WHERE VRQ_FILIAL = '" + VRP->VRP_FILIAL + "'"
cQuery += "   AND VRQ_CODVRP = '" + VRP->VRP_CODIGO + "'"
cQuery += "   AND D_E_L_E_T_= ' '"
oReport:SetMeter(FM_SQL(cQuery)+3)
//
oReport:IncMeter()
cVRP_NOMFOR := Posicione("SA2",1,xFilial("SA2")+VRP->VRP_CODFOR+VRP->VRP_LOJFOR,"A2_NOME")
cVRP_DESFPG := Posicione("SE4",1,xFilial("SE4")+VRP->VRP_FORPAG,"E4_DESCRI")
cVRP_USRNOM := Left(UsrRetName(VRP->VRP_USRINC),25)
oSection1:Init()
oSection1:PrintLine() // VRP
oSection1:Finish()
oReport:IncMeter()
oReport:SkipLine()
//
oSection2:Init()
DbSelectArea("VRQ")
DbSetOrder(2) // VRQ_FILIAL + VRQ_CODVRP
DbSeek( VRP->VRP_FILIAL + VRP->VRP_CODIGO )
Do While !VRQ->(Eof()) .and. VRQ->VRQ_FILIAL == VRP->VRP_FILIAL .and. VRQ->VRQ_CODVRP == VRP->VRP_CODIGO
	oReport:IncMeter()
	VPX->(DbSetOrder(1))
	VPX->(DbSeek( xFilial("VPX") + VRQ->VRQ_SERINT ))
	cVRQ_GRUSER := VPX->VPX_GRUSER
	cVRQ_CODSER := VPX->VPX_CODSER
	cVRQ_DESSER := VPX->VPX_DESSER
	cVRQ_TIPSER := VPX->VPX_TIPSER
	If !Empty(VRQ->VRQ_FILVRS+VRQ->VRQ_CODVRS)
		VRS->(DbSetOrder(1))
		VRS->(DbSeek( VRQ->VRQ_FILVRS+VRQ->VRQ_CODVRS ))
		VRR->(DbSetOrder(1))
		VRR->(DbSeek( VRS->VRS_FILIAL+VRS->VRS_CODVRR ))
		cVRR_NUMNFI := VRR->VRR_NUMNFI
		cVRR_SERNFI := VRR->VRR_SERNFI
		dVRR_DATNFI := Posicione("SF2",1,xFilial("SF2")+VRR->VRR_NUMNFI+VRR->VRR_SERNFI,"F2_EMISSAO")
		dVRS_DTIVIG := VRS->VRS_DTIVIG
		dVRS_DTFVIG := VRS->VRS_DTFVIG
		cVRS_NROSER := VRS->VRS_NROSER
		cVRS_CHASSI := VRS->VRS_CHASSI
	EndIf
	oSection2:PrintLine() // VRQ
	dbSelectArea("VRQ")
	dbSkip()
EndDo
oReport:SkipLine()
oSection2:Finish()
oReport:SkipLine()
oReport:SkipLine()
oReport:IncMeter()
//
Return Nil

/*/{Protheus.doc} OA4600121_ValidaImpressao
Valida se pode Imprimir os Dados da Entrada

@author Andre Luis Almeida
@since 15/12/2022
/*/
Static Function OA4600121_ValidaImpressao()
Local lImprime   := .t.
Local oModel     := FWModelActive()
Local nOperModel := oModel:GetOperation()
If nOperModel == MODEL_OPERATION_INSERT // Inclusão
	lImprime := .f.
	Help("",1,"OA4600121_ValidaImpressao",,STR0037,1,0) // Opção não disponivel na Inclusão da Entrada. Necessário SALVAR e acessar a Impressão via MENU ou através da Visualização da Entrada.
ElseIf nOperModel == MODEL_OPERATION_UPDATE // Alteração
	If VRP->VRP_STATUS == "0" // Digitado
		lImprime := .f.
		Help("",1,"OA4600121_ValidaImpressao",,STR0038,1,0) // Opção não disponivel na Alteração da Entrada com Status Digitada. Acesse a Impressão via MENU ou através da Visualização da Entrada.
	EndIf
EndIf
If lImprime
	OA4600101_ImprimirEntrada()
EndIf
Return

/*/{Protheus.doc} OA4600131_ValorUltimaEntrada
Retorna Valor Unitario da Ultima Entrada

@author Andre Luis Almeida
@since 23/12/2022
/*/
Function OA4600131_ValorUltimaEntrada( cSerInt )
Local cFilVRP := ""
Local cQAlAux := "SQLAUX"
Local cQuery  := "SELECT DISTINCT VRP_FILIAL FROM "+RetSqlName("VRP")+" WHERE VRP_STATUS = '1' AND D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
While !( cQAlAux )->( Eof() )
	cFilVRP += "'"+( cQAlAux )->( VRP_FILIAL )+"',"
	( cQAlAux )->( dbSkip() )
EndDo
( cQAlAux )->( dbCloseArea() )
cFilVRP := IIf(!Empty(cFilVRP),left(cFilVRP,len(cFilVRP)-1),"'"+xFilial("VRP")+"'")
cQuery := "SELECT VRQ.VRQ_VLRUNI "
cQuery += "  FROM " + RetSQLName("VRQ") + " VRQ "
cQuery += "  JOIN " + RetSQLName("VRP") + " VRP ON ( VRP.VRP_FILIAL = VRQ.VRQ_FILIAL AND VRP.VRP_CODIGO = VRQ.VRQ_CODVRP AND VRP.VRP_STATUS = '1' AND VRP.D_E_L_E_T_ = ' ' ) "
cQuery += " WHERE VRQ.VRQ_FILIAL IN (" + cFilVRP+ ")"
cQuery += "   AND VRQ.VRQ_SERINT = '"+cSerInt+"'"
cQuery += "   AND VRQ.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VRQ.R_E_C_N_O_ DESC"
Return FM_SQL(cQuery)

/*/{Protheus.doc} OA460014L_RateioCentroCusto
Inclusao do Rateio por Centro de Custo

@author Leonardo Solera
@since 12/05/2024
/*/
Static Function OA460014L_RateioCentroCusto()
	Local nCntHead  := 0
	Local nCntFor   := 0
	Local nCntSDE   := 0
	Local aHeadSDE  := {}
	Local aColsSDE  := {}
	Local aStrSDE   := FWFormStruct(3,"SDE",{ |x| !AllTrim(x) $ "DE_CUSTO" })[1]
	Local aStrSD1   := FWFormStruct(3,"SD1",{ |x| AllTrim(x) $ "D1_DOC/D1_SERIE/D1_ITEM/D1_COD/D1_UM/D1_QUANT/D1_VUNIT/D1_TOTAL/D1_TES/D1_EMISSAO/D1_RATEIO/" })[1]
	Local oModel    := FWModelActive()
   	Local oVRQMod   := oModel:GetModel("VRQDETAIL")
	Local nPosLin   := oVRQMod:GetLine()
	Local cCampo    := ""
	Local aItensVRP := {}
	Local aItemRat  := {}
	Private oVRPMod := oModel:GetModel("VRPMASTER")
	Private aCols   := {}
	Private aHeader := {}
	Private cCpoNaoAlt := ""
	Private aRotina := MenuDef()
	Private l103Auto := .F.
	Private cNFiscal := oVRPMod:GetValue("VRP_NUMNFI")
	Private cSerie   := oVRPMod:GetValue("VRP_SERNFI")
	Private cTipo := ""
	Private l116Inclui := .T.
	Private l103Visual := .F.
	Private INCLUI := .T.
	Private ALTERA := .F.
	Private n		:= 1
	If oModel:GetOperation() <> MODEL_OPERATION_INSERT .and. oModel:GetOperation() <> MODEL_OPERATION_UPDATE // Diferente de Inclusão ou Alteração
		FMX_HELP("OA460014L_RateioCentroCusto",STR0062) // Opção disponivel apenas na Inclusão ou Alteração.
		Return()
	EndIf
	For nCntFor := 1 to Len(aStrSD1)
		If !aStrSD1[nCntFor][MODEL_FIELD_VIRTUAL] // Campos Reais
			cCampo := aStrSD1[nCntFor][MODEL_FIELD_IDFIELD]
			AADD(aHeader, { aStrSD1[nCntFor,MODEL_FIELD_TITULO]  ,;
					cCampo ,;
					GetSX3Cache(cCampo,"X3_PICTURE") ,;
					aStrSD1[nCntFor,MODEL_FIELD_TAMANHO] ,;
					aStrSD1[nCntFor,MODEL_FIELD_DECIMAL] ,;
					aStrSD1[nCntFor,MODEL_FIELD_VALID]   ,;
					GetSX3Cache(cCampo,"X3_USADO") ,;
					aStrSD1[nCntFor,MODEL_FIELD_TIPO]    ,;
					GetSX3Cache(cCampo,"X3_F3") ,;
					GetSX3Cache(cCampo,"X3_CONTEXT") ,;
					GetSX3Cache(cCampo,"X3_CBOX") ,;
					aStrSD1[nCntFor,MODEL_FIELD_INIT] })
		EndIf
	Next
	aItensVRP := {}
	aAdd(aItensVRP, {"D1_DOC"	 , 'oVRPMod:GetValue("VRP_NUMNFI")'        , Nil})
	aAdd(aItensVRP, {"D1_SERIE"	 , 'oVRPMod:GetValue("VRP_SERNFI")'        , Nil})
	aAdd(aItensVRP, {"D1_ITEM"	 , 'strzero(nCntFor,TamSx3("D1_ITEM")[1])' , Nil})
	aAdd(aItensVRP, {"D1_COD"	 , 'oVRQMod:GetValue("VRQ_CODIGO")'        , Nil})
	aAdd(aItensVRP, {"D1_UM"     , 'SB1->B1_UM'                            , Nil})
	aAdd(aItensVRP, {"D1_QUANT"	 , 'oVRQMod:GetValue("VRQ_QTDSER")'        , Nil})
	aAdd(aItensVRP, {"D1_VUNIT"	 , 'oVRQMod:GetValue("VRQ_VLRUNI")'        , Nil})
	aAdd(aItensVRP, {"D1_TOTAL"	 , 'oVRQMod:GetValue("VRQ_VLRTOT")'        , Nil})
	aAdd(aItensVRP, {"D1_TES"	 , 'oVRQMod:GetValue("VRQ_CODTES")'        , Nil})
	aAdd(aItensVRP, {"D1_EMISSAO", 'oVRPMod:GetValue("VRP_DATINC")'        , Nil})
	aAdd(aItensVRP, {"D1_RATEIO" , '1'                                     , Nil})
	aAdd(aItensVRP, {"D1_PEDIDO" , ''                                      , Nil})
	aAdd(aItensVRP, {"D1_ITEMPC" , ''                                      , Nil})
	For nCntFor := 1 to oVRQMod:Length() 
		oVRQMod:GoLine(nCntFor) 
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+oVRQMod:GetValue("VRQ_CODIGO")))
		AAdd(aCols, Array(Len(aHeader)+1))
		For nCntHead := 1 to Len(aHeader) 
			nPos := aScan(aItensVRP, {|x| AllTrim(x[1]) == AllTrim(aHeader[nCntHead,2])}) 
			If nPos > 0
				aCols[len(aCols),nCntHead] := &(aItensVRP[nPos,2]) 
			EndIf
		Next
		aCols[len(aCols),len(aHeader)+1] := .F. 
		If len(aColsRATCC) < len(aCols)
			aAdd(aColsRATCC, Array(2))
			aColsRATCC[len(aColsRATCC),1] := strzero(nCntFor,TamSx3("DE_ITEMNF")[1])
			aColsRATCC[len(aColsRATCC),2] := {}
		EndIf
	Next

	For nCntFor := 1 to Len(aStrSDE)
		If !aStrSDE[nCntFor][MODEL_FIELD_VIRTUAL] // somente campos REAIS
			cCampo := aStrSDE[nCntFor][MODEL_FIELD_IDFIELD]
			AADD(aHeadSDE, { aStrSDE[nCntFor,MODEL_FIELD_TITULO]  ,;
					cCampo ,;
					GetSX3Cache(cCampo,"X3_PICTURE") ,;
					aStrSDE[nCntFor,MODEL_FIELD_TAMANHO] ,;
					aStrSDE[nCntFor,MODEL_FIELD_DECIMAL] ,;
					aStrSDE[nCntFor,MODEL_FIELD_VALID]   ,;
					GetSX3Cache(cCampo,"X3_USADO") ,;
					aStrSDE[nCntFor,MODEL_FIELD_TIPO]    ,;
					GetSX3Cache(cCampo,"X3_F3") ,;
					GetSX3Cache(cCampo,"X3_CONTEXT") })
		EndIf
	Next
	If len(aColsRATCC) > 0
		NfeRatCC(aHeadSDE,aColsSDE,.t.)
	EndIf
	
	For nCntSDE := 1 to len(aColsSDE)
		If len(aColsSDE) > 1
			oVRQMod:GoLine(nCntSDE)
			nPosRateio := nCntSDE
		Else
			nPosRateio := nPosLin
		EndIf
		aColsRATCC[nPosRateio,2] := {}
		For nCntFor := 1 to len(aColsSDE[nCntSDE,2])
			aItemRat := {}
			aAdd(aItemRat, {"DE_FILIAL" , xFilial("SDE")                 , Nil})
			aAdd(aItemRat, {"DE_ITEM"   , oVRQMod:GetValue("VRQ_CODIGO") , Nil})
			aAdd(aItemRat, {"DE_DOC"    , oVRPMod:GetValue("VRP_NUMNFI") , Nil})
			aAdd(aItemRat, {"DE_SERIE"  , oVRPMod:GetValue("VRP_SERNFI") , Nil})
			aAdd(aItemRat, {"DE_FORNECE", oVRPMod:GetValue("VRP_CODFOR") , Nil})
			aAdd(aItemRat, {"DE_LOJA"   , oVRPMod:GetValue("VRP_LOJFOR") , Nil})
			aAdd(aItemRat, {"DE_ITEMNF" , aColsRATCC[nPosRateio,1]       , Nil})
			aAdd(aItemRat, {"DE_PERC"   , aColsSDE[nCntSDE,2,nCntFor,2]  , Nil})
			aAdd(aItemRat, {"DE_CC"     , aColsSDE[nCntSDE,2,nCntFor,3]  , Nil})
			aAdd(aColsRATCC[nPosRateio,2], aClone(aItemRat) )
		Next
	Next
	oVRQMod:GoLine(nPosLin)

Return

/*/{Protheus.doc} OA4600151_VisualizarRateioCentroCusto
Visualiza Rateio por Centro de Custo

@author Andre Luis Almeida
@since 13/05/2024
/*/
Static Function OA4600151_VisualizarRateioCentroCusto()
	Local nCntFor  := 0
	Local aAux     := {}
	Local aPerCC   := {}
	Local oModel   := FWModelActive()
	Local oVRPMod  := oModel:GetModel("VRPMASTER")
   	Local oVRQMod  := oModel:GetModel("VRQDETAIL")
	Local nPosLin  := oVRQMod:GetLine()
	Local cPosLin  := strzero(nPosLin,TamSx3("DE_ITEMNF")[1])
	Local cNFiscal := oVRPMod:GetValue("VRP_NUMNFI")
	Local cSerie   := oVRPMod:GetValue("VRP_SERNFI")
	Local cFornec  := oVRPMod:GetValue("VRP_CODFOR")
	Local cLoja    := oVRPMod:GetValue("VRP_LOJFOR")
	Private cCadastro := STR0007 // Visualizar
	If !Empty(cNFiscal+cSerie)
		DbSelectArea("SDE")
		DbSetOrder(1) // DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF+DE_ITEM
		DbSeek( xFilial("SDE") + cNFiscal + cSerie + cFornec + cLoja )
		Do While !SDE->(Eof()) .and. SDE->DE_FILIAL == xFilial("SDE") .and. ( SDE->DE_DOC + SDE->DE_SERIE + SDE->DE_FORNECE + SDE->DE_LOJA + SDE->DE_ITEMNF ) == ( cNFiscal + cSerie + cFornec + cLoja + cPosLin )
			aAdd(aPerCC,{ SDE->DE_CC , SDE->DE_PERC })
			dbSelectArea("SDE")
			dbSkip()
		Enddo
	EndIf
	If len(aPerCC) == 0
		nPosLin := aScan(aColsRATCC, {|x| x[1] == cPosLin })
		If nPosLin > 0
			aAux := aClone(aColsRATCC[nPosLin,2])
			For nCntFor := 1 to len(aAux)
				aAdd(aPerCC,{ aAux[nCntFor,9,2] , aAux[nCntFor,8,2] })
			Next
		EndIf
	EndIf
	If len(aPerCC) > 0 // Mostrar TELA com os Percentuais e Centro de Custo
		DEFINE MSDIALOG oDlgPerCC TITLE ( STR0061 ) FROM  9,20 TO 34,84 OF oMainWnd
		@ 33,02 LISTBOX oLbPerCC FIELDS HEADER RetTitle("DE_CC"),RetTitle("DE_PERC") COLSIZES 100,50 SIZE 250,150 OF oDlgPerCC PIXEL 
		oLbPerCC:SetArray(aPerCC)
		oLbPerCC:bLine := { || { aPerCC[oLbPerCC:nAt,01] , Transform(aPerCC[oLbPerCC:nAt,02],"@E 999999.99") }}
		ACTIVATE MSDIALOG oDlgPerCC CENTER ON INIT EnchoiceBar(oDlgPerCC, { || oDlgPerCC:End() } , { || oDlgPerCC:End() } )
	Else
		FMX_HELP("OA4600151_VisualizarRateioCentroCusto",STR0063) // Não existe Rateio por Centro de Custo
	EndIf
Return