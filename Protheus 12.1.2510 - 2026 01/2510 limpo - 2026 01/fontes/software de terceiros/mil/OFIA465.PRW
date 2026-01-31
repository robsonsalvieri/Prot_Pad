#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA465.CH"

/*/{Protheus.doc} OFIA465
	Transferência de Serviços Especializados

	@author Andre Luis Almeida
	@since 12/09/2022
/*/
Function OFIA465()
Local aSize       := FWGetDialogSize( oMainWnd )
Local cAuxAlias   := "SQLAUX"
Local cQuery      := ""
Local aFilOri     := {}
Local aFilDes     := {}
Local nCntFor     := 0
Private cCadastro := STR0001 // Transferência de Serviços Especializados
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")

If !OA4500071_Validar_VRQ_SERINT() // Valida o Tamanho do campo VRQ_SERINT
	Return
EndIf

cQuery := "SELECT DISTINCT VRT_FILORI "
cQuery += "  FROM " + RetSQLName("VRT")
cQuery += " WHERE VRT_FILIAL =  '" + xFilial("VRT") + "'"
cQuery += "   AND D_E_L_E_T_ =  ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	aAdd(aFilOri,{ (cAuxAlias)->(VRT_FILORI) , FWFilialName(,(cAuxAlias)->(VRT_FILORI)) })
	(cAuxAlias)->(DbSkip())
EndDo
(cAuxAlias)->(DbCloseArea())

cQuery := "SELECT DISTINCT VRT_FILDES "
cQuery += "  FROM " + RetSQLName("VRT")
cQuery += " WHERE VRT_FILIAL =  '" + xFilial("VRT") + "'"
cQuery += "   AND D_E_L_E_T_ =  ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	aAdd(aFilDes,{ (cAuxAlias)->(VRT_FILDES) , FWFilialName(,(cAuxAlias)->(VRT_FILDES)) })
	(cAuxAlias)->(DbSkip())
EndDo
(cAuxAlias)->(DbCloseArea())

DbSelectArea("VRT")

oDlgOA465 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oBrwVRT := FWMBrowse():New()
oBrwVRT:SetAlias('VRT')
oBrwVRT:SetOwner(oDlgOA465)
oBrwVRT:SetDescription(cCadastro)
oBrwVRT:lChgAll := .f. // nao apresentar a tela para escolher a filial
oBrwVRT:AddLegend( 'VRT->VRT_STATUS == "0"' , 'BR_BRANCO'   , STR0002 ) // Transferência Digitada
oBrwVRT:AddLegend( 'VRT->VRT_STATUS == "1"' , 'BR_VERDE'    , STR0003 ) // Transferência Efetivada
oBrwVRT:AddLegend( 'VRT->VRT_STATUS == "2"' , 'BR_VERMELHO' , STR0004 ) // Transferência Cancelada
oBrwVRT:AddFilter(STR0005+": "+STR0006, "@ VRT_TIPTRA = '0'") // Tipo de Transferência / Manual
oBrwVRT:AddFilter(STR0005+": "+STR0007, "@ VRT_TIPTRA = '1'") // Tipo de Transferência / Automática
For nCntFor := 1 to len(aFilOri)
	oBrwVRT:AddFilter(STR0008+": "+Alltrim(aFilOri[nCntFor,1])+" - "+aFilOri[nCntFor,2], "@ VRT_FILORI = '"+aFilOri[nCntFor,1]+"'") // Filial de Origem
Next
For nCntFor := 1 to len(aFilDes)
	oBrwVRT:AddFilter(STR0009+": "+Alltrim(aFilDes[nCntFor,1])+" - "+aFilDes[nCntFor,2], "@ VRT_FILDES = '"+aFilDes[nCntFor,1]+"'") // Filial de Destino
Next
oBrwVRT:DisableDetails()
oBrwVRT:DisableLocate()
oBrwVRT:SetAmbiente(.F.)
oBrwVRT:SetWalkthru(.F.)
oBrwVRT:SetUseFilter()
oBrwVRT:ForceQuitButton()
oBrwVRT:Activate()

oDlgOA465:Activate( , , , , , , ) //ativa a janela

Return

Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.OFIA465' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.OFIA465' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.OFIA465' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0013 ACTION 'OA4650031_CancelarTransferencia()' OPERATION 5 ACCESS 0 // Cancelar
	ADD OPTION aRotina TITLE STR0014 ACTION 'VIEWDEF.OFIA465' OPERATION 8 ACCESS 0 // Imprimir

Return aRotina


Static Function ModelDef()
Local oStrVRT := FWFormStruct(1,"VRT")

oModel := MPFormModel():New("OFIA465", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VRTMASTER",/*cOwner*/ , oStrVRT)
oModel:GetModel("VRTMASTER"):SetDescription(STR0001) // Transferência de Serviços Especializados
oModel:SetDescription(STR0001) // Transferência de Serviços Especializados
//oModel:InstallEvent("OFIA465LOG", /*cOwner*/, MVCLOGEV():New("OFIA465") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("OFIA465EVDEF", /*cOwner*/, OFIA465EVDEF():New() )

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 12/09/2022
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVRT:= FWFormStruct(2,"VRT")

oStrVRT:RemoveField('VRT_CODIGO')

oView := FWFormView():New()
oView:SetModel(oModel)

oView:SetCloseOnOk({||.T.})

oView:AddField( 'VIEW_VRT', oStrVRT, 'VRTMASTER' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' , 100)
oView:SetOwnerView('VIEW_VRT', 'CABEC' )

oView:AddUserButton("<F4> "+STR0015,'PRODUTO', {|| OA4650051_VerEstoque() }) // Visualiza Estoque do Serviço Especializado posicionado

Return oView

/*/{Protheus.doc} OA4650011_GravaStatusTransferencia
Grava Status da Transferência

@author Andre Luis Almeida
@since 13/09/2022
/*/
Static Function OA4650011_GravaStatusTransferencia( cCodigo , cStatus )
Local oModVRT   := FWLoadModel( 'OFIA466' ) // MVC somente para atualizar o cabeçalho VRT
Default cCodigo := ""
Default cStatus := "0" // 0=Transferência Digitada
VRT->(DbSetOrder(1))
If VRT->(DbSeek(xFilial("VRT")+cCodigo))
	If cStatus <> VRT->VRT_STATUS
		oModVRT:SetOperation( MODEL_OPERATION_UPDATE )
		If oModVRT:Activate()
			oModVRT:SetValue( "VRTMASTER" , "VRT_STATUS" , cStatus ) // 0=Transferência Digitada / 1=Transferência Efetivada / 2=Transferência Cancelada
			If oModVRT:VldData()
				oModVRT:CommitData()
			EndIf
			oModVRT:DeActivate()
		EndIf
	EndIf
EndIf
FreeObj(oModVRT)
Return

/*/{Protheus.doc} OA4650021_IncluirTransferencia
Incluir a Transferência de Servicos Especializados

@author Andre Luis Almeida
@since 06/09/2022
/*/
Function OA4650021_IncluirTransferencia( lEstoq , lRegua , cTipo , aIncluiVRT )
Local oModVRT
Local lRet     := .t.
Local cSlvFil  := cFilAnt
Local cSeqMov  := ""
Local cFilRel  := ""
Local cCodRel  := ""
Local cFilOri  := ""
Local cFilDes  := ""
Local cSerInt  := ""
Local nQtdSer  := 0
Local cVRTDOCD3O := "" // D3_DOC Origem
Local cVRTDOCD3D := "" // D3_DOC Destino
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
Default lEstoq := .f.
Default lRegua := .t.
Default cTipo  := "N" // N=Normal / E=Estorno
Default aIncluiVRT := {}
//
If len(aIncluiVRT) > 0 // Incluir VRT com Status Digitado para ser possivel a Efetivação da Transferência
	oModVRT := FWLoadModel( 'OFIA466' ) // MVC somente para atualizar o cabeçalho VRT
	oModVRT:SetOperation( MODEL_OPERATION_INSERT )
	If oModVRT:Activate()
		oModVRT:LoadValue( "VRTMASTER" , "VRT_STATUS" , "0" ) // Status: 0=Transferência Digitada
		oModVRT:LoadValue( "VRTMASTER" , "VRT_FILORI" , aIncluiVRT[1] ) // Filial de Origem
		oModVRT:LoadValue( "VRTMASTER" , "VRT_FILDES" , aIncluiVRT[2] ) // Filial de Destino
		oModVRT:LoadValue( "VRTMASTER" , "VRT_SERINT" , aIncluiVRT[3] ) // Código Interno do Serviço
		oModVRT:LoadValue( "VRTMASTER" , "VRT_QTDSER" , aIncluiVRT[4] ) // Quantidade da Transferência
		oModVRT:LoadValue( "VRTMASTER" , "VRT_TIPTRA" , "1" ) // Tipo de Transferência: 1=Automatica
		If oModVRT:VldData()
			oModVRT:CommitData()
		EndIf
		oModVRT:DeActivate()
	EndIf
	FreeObj(oModVRT)
EndIf
//
If lRegua
	oProcTran:SetRegua1(2)
	oProcTran:IncRegua1(STR0016) // Levantando Serviço Especializado...
	oProcTran:SetRegua2(1)
	oProcTran:IncRegua2()
EndIf
//
BEGIN TRANSACTION
	If lEstoq
		//
		cFilRel := VRT->VRT_FILIAL
		cCodRel := VRT->VRT_CODIGO
		cSerInt := VRT->VRT_SERINT
		nQtdSer := VRT->VRT_QTDSER
		cFilOri := VRT->VRT_FILORI
		cFilDes := VRT->VRT_FILDES
		//
		If lRegua
			oProcTran:IncRegua1(STR0017) // Gerando Transferência do Serviço Especializado
			oProcTran:SetRegua2(4)
			oProcTran:IncRegua2()
		EndIf
		//
		// Saida na Origem
		cFilAnt := cFilOri
		cSeqMov := OFIA452( cSerInt , "1" , "0" , "2" , nQtdSer , cFilRel , cCodRel ) // Grava a Movimentação de Estoque do Servico Especializado
		If Empty(cSeqMov) .or. cDebugMIL == "OFIA465001"
			lRet := .f.
		Else
			lRet := OA4650061_SD3( 3 , "S" , GetNewPar("MV_MIL0184","") , cSerInt , "" ) // Saida na Origem
			If lRet
				cVRTDOCD3O := SD3->D3_DOC
			EndIf
		EndIf
		If lRegua
			oProcTran:IncRegua2()
		EndIf
		//
		If lRet
			// Entrada no Destino
			cFilAnt := cFilDes
			cSeqMov := OFIA452( cSerInt , "0" , "0" , "2" , nQtdSer , cFilRel , cCodRel ) // Grava a Movimentação de Estoque do Servico Especializado
			If Empty(cSeqMov) .or. cDebugMIL == "OFIA465002"
				lRet := .f.
			Else
				lRet := OA4650061_SD3( 3 , "E" , GetNewPar("MV_MIL0183","") , cSerInt , "" ) // Entrada no Destino
				If lRet
					cVRTDOCD3D := SD3->D3_DOC
				EndIf
			EndIf
		EndIf
		If lRegua
			oProcTran:IncRegua2()
		EndIf
		cFilAnt := cSlvFil
		If !lRet
			DisarmTransaction()
		EndIf
		If lRegua
			oProcTran:IncRegua2()
		EndIf
	EndIf
END TRANSACTION
If lRet
	OA4650071_GravaDOCs( VRT->VRT_CODIGO , cVRTDOCD3O , cVRTDOCD3D ) // Grava DOCs do SD3
	OA4650011_GravaStatusTransferencia( VRT->VRT_CODIGO , "1" ) // Mudar Status para 1=Transferência Efetivada
EndIf
//
Return lRet

/*/{Protheus.doc} OA4650031_CancelarTransferencia
Opção CANCELAR do aRotina do OFIA465 - Transferência de Servicos Especializados

@author Andre Luis Almeida
@since 13/09/2022
/*/
Function OA4650031_CancelarTransferencia()
Local lRet    := .f.
Local cSlvFil := cFilAnt
Local cSeqMov := ""
Local cFilRel := ""
Local cCodRel := ""
Local cFilOri := ""
Local cFilDes := ""
Local cSerInt := ""
Local nQtdSer := 0
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
If VRT->VRT_STATUS == "2" // 2=Transferência Cancelada
	Help("",1,"OA4650031_CancelarTransferencia",,STR0018,1,0) // Transferência já Cancelada. Impossível continuar.
Else
	If xFilial("SD2") <> VRT->VRT_FILORI
		Help("",1,"OA4650031_CancelarTransferencia",,STR0019,1,0) // Origem da Transferência diferente da Filial logada. Impossível continuar.
	Else
		If MsgNoYes(STR0021,STR0020) // Confirma o Cancelamento da Transferência? / Atenção
			lRet := .t.
			BEGIN TRANSACTION
			If VRT->VRT_STATUS == "1" // 1=Transferência Efetivada
				//
				cFilRel := VRT->VRT_FILIAL
				cCodRel := VRT->VRT_CODIGO
				cSerInt := VRT->VRT_SERINT
				nQtdSer := VRT->VRT_QTDSER
				cFilOri := VRT->VRT_FILORI
				cFilDes := VRT->VRT_FILDES
				//
				DbSelectArea("VPY")
				DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
				If !DbSeek( xFilial("VPY") + cSerInt + cFilDes ) .or. VPY->VPY_QTDEST < nQtdSer // NAO possui Estoque
					Help("",1,"OA4650031_CancelarTransferencia",,STR0022,1,0) // Serviço Especializado não se encontra em Estoque! Impossível continuar.
					lRet := .f.
				Else
					// Saida do Destino
					cFilAnt := cFilDes
					cSeqMov := OFIA452( cSerInt , "1" , "1" , "2" , nQtdSer , cFilRel , cCodRel ) // Grava a Movimentação de Estoque do Servico Especializado
					If Empty(cSeqMov) .or. cDebugMIL == "OFIA465003"
						lRet := .f.
					Else
						lRet := OA4650061_SD3( 6 , "E" , "" , cSerInt , VRT->VRT_DOCD3D ) // Estorno da Entrada no Destino
					EndIf
					If lRet
						// Entrada na Origem
						cFilAnt := cFilOri
						cSeqMov := OFIA452( cSerInt , "0" , "1" , "2" , nQtdSer , cFilRel , cCodRel ) // Grava a Movimentação de Estoque do Servico Especializado
						If Empty(cSeqMov) .or. cDebugMIL == "OFIA465004"
							lRet := .f.
						Else
							lRet := OA4650061_SD3( 6 , "S" , "" , cSerInt , VRT->VRT_DOCD3O ) // Estorno da Saida na Origem
						EndIf
					EndIf
				EndIf
			EndIf
			cFilAnt := cSlvFil
			If !lRet
				DisarmTransaction()
			EndIf
			END TRANSACTION
		EndIf
	EndIf
EndIf
If lRet
	OA4650011_GravaStatusTransferencia( VRT->VRT_CODIGO , "2" ) // Mudar Status para 2=Transferência Cancelada
EndIf
Return lRet

/*/{Protheus.doc} OA4650041_VisualizarTransferencia
Visualizar Transferência

@author Andre Luis Almeida
@since 16/09/2022
/*/
Function OA4650041_VisualizarTransferencia()
DbSelectArea("VRT")
oExecView := FWViewExec():New()
oExecView:SetTitle(STR0010) // Visualizar
oExecView:SetSource("OFIA465")
oExecView:SetOperation(MODEL_OPERATION_VIEW)
oExecView:OpenView(.T.)
Return

/*/{Protheus.doc} OA4650051_VerEstoque
Ver o Estoque do Serviço Especializado posicionado

@author Andre Luis Almeida
@since 25/10/2022
/*/
Function OA4650051_VerEstoque()
Local oModel  := FWModelActive()
Local oVRTMod := oModel:GetModel("VRTMASTER")
Local cFilSD2 := xFilial("SD2")
//
SetKey(VK_F4, Nil )
DbSelectArea("VPY")
DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
If DbSeek( xFilial("VPY") + oVRTMod:GetValue( "VRT_SERINT" ) + cFilSD2 ) // Pega a Filial Logada
	OFIA451( VPY->VPY_FILIAL , VPY->VPY_CODEST , .f. )
ElseIf DbSeek( xFilial("VPY") + oVRTMod:GetValue( "VRT_SERINT" ) ) // Pega qualquer Filial
	OFIA451( VPY->VPY_FILIAL , VPY->VPY_CODEST , .f. )
Else
	Help("",1,"OA4650051_VerEstoque",,STR0023,1,0) // Não existe estoque disponivel para esse Serviço Especializado.
EndIf
SetKey(VK_F4,{|| OA4650051_VerEstoque() })
//
Return

/*/{Protheus.doc} OA4650061_SD3
Gera SD3 referente a Transferencia entre Filiais

@author Andre Luis Almeida
@since 01/11/2022
/*/
Static Function OA4650061_SD3( nOpcSD3 , cTipMov , cTM_SD3 , cSerInt , cDocSD3 )
Local lRet     := .t.
Local aCabSD3  := {}
Local aIteSD3  := {}
Local nCusto   := 0
//
lMsHelpAuto := .T.
lMsErroAuto := .F.
//
VPX->(DbSetOrder(1)) // VPX_FILIAL + VPX_SERINT
VPX->(DbSeek( xFilial("VPX") + cSerInt ))
VPV->(DbSetOrder(1)) // VPV_FILIAL + VPV_CODTIP
VPV->(DbSeek( xFilial("VPV") + VPX->VPX_TIPSER ))
SB1->(DbSetOrder(1))
SB1->(DbSeek( xFilial("SB1") + VPV->VPV_CODSB1 ))
//
If nOpcSD3 == 3 // Incluir Transferencia
	//
	nCusto := IIf( VPX->VPX_CUSMED > 0 , VPX->VPX_CUSMED , OA4600131_ValorUltimaEntrada( VPX->VPX_SERINT ) ) // Retorna Custo Medio ou Valor Unitario da Ultima Entrada
	//
	DbSelectArea("SD3")
	//
	aCabSD3 := {{"D3_DOC"    , NextNumero("SD3",2,"D3_DOC",.T.) , NIL },;
				{"D3_TM"     , cTM_SD3        , NIL },;
				{"D3_EMISSAO", dDatabase      , NIL }}
	aIteSD3 := {{"D3_COD"    , SB1->B1_COD    , NIL },;
				{"D3_UM"     , SB1->B1_UM     , NIL },;
				{"D3_QUANT"  , 0              , NIL },;
				{"D3_CUSTO1" , nCusto         , NIL },;
				{"D3_LOCAL"  , SB1->B1_LOCPAD , NIL }}
	MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabSD3,{aIteSD3},3)
	If lMsErroAuto
		Mostraerro()
		lRet := .f.
	EndIf
	//
ElseIf nOpcSD3 == 6 // Estorno da Transferencia
	//
	DbSelectArea("SD3")
	DbSetOrder(2)
	If DbSeek(xFilial("SD3")+cDocSD3+SB1->B1_COD)
		aCabSD3 := { {"D3_DOC"   , SD3->D3_DOC    , NIL }}
		aIteSD3 := {{"D3_COD"    , SD3->D3_COD    , NIL },;
					{"D3_UM"     , SB1->B1_UM     , NIL },;
					{"D3_QUANT"  , 0              , NIL },;
					{"D3_LOCAL"  , SB1->B1_LOCPAD , NIL },;
					{"D3_ESTORNO", "S"            , NIL }}
		MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabSD3,{aIteSD3},6)
		If lMsErroAuto .or. cDebugMIL == "OFIA465005"
			Mostraerro()
			lRet := .f.
		EndIf
	EndIf
	//
EndIf
//
Return lRet

/*/{Protheus.doc} OA4650071_GravaDOCs
Gravar campos de referencia com SD3 - DOC

@author Andre Luis Almeida
@since 01/11/2022
/*/
Static Function OA4650071_GravaDOCs( cCodigo , cVRTDOCD3O , cVRTDOCD3D )
Local oModVRT      := FWLoadModel( 'OFIA466' ) // MVC somente para atualizar o cabeçalho VRT
Local nCusto       := 0
Default cVRTDOCD3O := ""
Default cVRTDOCD3D := ""
VRT->(DbSetOrder(1))
If VRT->(DbSeek(xFilial("VRT")+cCodigo))
	VPX->(DbSetOrder(1)) // VPX_FILIAL + VPX_SERINT
	VPX->(DbSeek( xFilial("VPX") + VRT->VRT_SERINT ))
	nCusto := IIf( VPX->VPX_CUSMED > 0 , VPX->VPX_CUSMED , OA4600131_ValorUltimaEntrada( VPX->VPX_SERINT ) ) // Retorna Custo Medio ou Valor Unitario da Ultima Entrada
	DbSelectArea("VRT")
	oModVRT:SetOperation( MODEL_OPERATION_UPDATE )
	If oModVRT:Activate()
		oModVRT:SetValue( "VRTMASTER" , "VRT_DOCD3O" , cVRTDOCD3O ) // Saida Origem
		oModVRT:SetValue( "VRTMASTER" , "VRT_DOCD3D" , cVRTDOCD3D ) // Entrada Destino
		oModVRT:SetValue( "VRTMASTER" , "VRT_CUSMED" , nCusto ) // Custo Medio
		If oModVRT:VldData()
			oModVRT:CommitData()
		EndIf
		oModVRT:DeActivate()
	EndIf
EndIf
FreeObj(oModVRT)
Return