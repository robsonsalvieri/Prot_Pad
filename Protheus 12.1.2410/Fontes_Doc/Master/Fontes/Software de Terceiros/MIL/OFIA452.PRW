#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA452.CH"

/*/{Protheus.doc} OFIA452
MVC - Atualizar o Estoque de um determinado Servico Especializado

@author Andre Luis Almeida
@since 25/08/2022
/*/
Function OFIA452( cSerInt , cTipMov , cPorMov , cOpeMov , nQtdMov , cFilRel , cCodRel )
Local oModVPY    := FWLoadModel( 'OFIA452' )
Local lOk        := .t.
Local lCriaVPY   := .t.
Local nQtdEst    := 0
Local cSrvAux    := ""
Local cFilMov    := xFilial("SD2") // Filial da Movimentação
Local cVPYCODEST := ""
Default cSerInt  := ""
Default cTipMov  := "0" // 0=Entrada
Default cPorMov  := "0" // 0=Normal
Default cOpeMov  := "0" // 0=Compra
Default nQtdMov  := 0
Default cFilRel  := ""
Default cCodRel  := ""
Private cVPZSERINT := cSerInt // Necessario dentro do fonte de Evento
Private cVPZFILMOV := cFilMov // Necessario dentro do fonte de Evento
Private cVPZTIPMOV := cTipMov // Necessario dentro do fonte de Evento
Private cVPZPORMOV := cPorMov // Necessario dentro do fonte de Evento
Private cVPZOPEMOV := cOpeMov // Necessario dentro do fonte de Evento
Private nVPZQTDMOV := nQtdMov // Necessario dentro do fonte de Evento
Private cVPZFILREL := cFilRel // Necessario dentro do fonte de Evento
Private cVPZCODREL := cCodRel // Necessario dentro do fonte de Evento
If !Empty(cSerInt)
	// Cadastro de Servicos Especializados
	DbSelectArea("VPX")
	DbSetOrder(1) // VPX_FILIAL + VPX_SERINT
	If DbSeek( xFilial("VPX") + cSerInt )
		// Cadastro de Tipos de Servicos Especializados
		DbSelectArea("VPV")
		DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
		DbSeek( xFilial("VPV") + VPX->VPX_TIPSER )
		If VPV->VPV_CTRSLD <> "0" // Tipo de Serviço Especializado controla SALDO de ESTOQUE ?
			// Estoque do Servico Especializado
			DbSelectArea("VPY")
			DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
			If DbSeek( xFilial("VPY") + cSerInt + cFilMov )
				lCriaVPY := .f.
				nQtdEst  := VPY->VPY_QTDEST
			EndIf
			cSrvAux := CHR(13)+CHR(10)+CHR(13)+CHR(10)+Alltrim(VPX->VPX_GRUSER)+" "+Alltrim(VPX->VPX_CODSER)+CHR(13)+CHR(10)+Alltrim(VPX->VPX_DESSER)+" ("+Alltrim(VPX->VPX_TIPSER)+")"
			lOk := OA4520011_ValidaSaldo( cTipMov , VPV->VPV_CTRSLD , nQtdMov , nQtdEst , cSrvAux )
			If lOk
				If lCriaVPY
					oModVPY:SetOperation( MODEL_OPERATION_INSERT )
					oModVPY:Activate()
					oModVPY:SetValue( "VPYMASTER", "VPY_SERINT", cSerInt )
					oModVPY:SetValue( "VPYMASTER", "VPY_FILEST", cFilMov )
					oModVPY:SetValue( "VPYMASTER", "VPY_QTDEST", nQtdMov )
				Else
					oModVPY:SetOperation( MODEL_OPERATION_UPDATE )
					oModVPY:Activate()
					If cTipMov == "0" // 0=Entrada
						oModVPY:SetValue( "VPYMASTER", "VPY_QTDEST", nQtdEst + nQtdMov ) // somar no estoque
					ElseIf cTipMov == "1" // 1=Saida
						oModVPY:SetValue( "VPYMASTER", "VPY_QTDEST", nQtdEst - nQtdMov ) // baixar do estoque
					EndIf
				EndIf
				oModVPY:VldData()
				oModVPY:CommitData()
				oModVPY:DeActivate()
				cVPYCODEST := VPY->VPY_CODEST
			EndIf
		Else
			cVPYCODEST := "NAOCONTROLA"
		EndIf
	EndIf
EndIf
FreeObj(oModVPY)
Return cVPYCODEST

/*/{Protheus.doc} MenuDef
Função para criação do menu 

@author Andre Luis Almeida
@since 25/08/2022
/*/
Static Function MenuDef()

	Local aRotina := {}
	aRotina := FWMVCMenu('OFIA452')

Return aRotina

/*/{Protheus.doc} ModelDef
ModelDef

@author Andre Luis Almeida
@since 25/08/2022
/*/
Static Function ModelDef()

	Local oModel
	Local oStrVPY := FWFormStruct(1, "VPY")

	oModel := MPFormModel():New('OFIA452',,,,)
	oModel:AddFields('VPYMASTER',/*cOwner*/ , oStrVPY)
	oModel:SetDescription(STR0001) // Estoque do Serviço Especializado
	oModel:GetModel('VPYMASTER'):SetDescription(STR0001) // Estoque do Serviço Especializado
//	oModel:InstallEvent("OFIA452LOG", /*cOwner*/, MVCLOGEV():New("OFIA452") ) // CONSOLE.LOG para verificar as chamadas dos eventos
	oModel:InstallEvent("OFIA452EVDEF", /*cOwner*/, OFIA452EVDEF():New("OFIA452"))

Return oModel

/*/{Protheus.doc} ViewDef
ViewDef

@author Andre Luis Almeida
@since 25/08/2022
/*/
Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVPY:= FWFormStruct(2, "VPY")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox( 'BOXVPY', 100)
	oView:AddField('VIEW_VPY', oStrVPY, 'VPYMASTER')
	oView:EnableTitleView('VIEW_VPY', STR0001) // Estoque do Serviço Especializado
	oView:SetOwnerView('VIEW_VPY','BOXVPY')

Return oView

/*/{Protheus.doc} OA4520011_ValidaSaldo
Valida Saldo ( UNITARIO )

@author Andre Luis Almeida
@since 24/10/2022
/*/
Function OA4520011_ValidaSaldo( cTipMov , cCtrSld , nQtdMov , nQtdEst , cSrvAux )
Local lOk := .t.
Do Case
	Case cTipMov == "0" .and. cCtrSld == "1" .and. nQtdMov > 1 // Entrada  e  Controla Estoque Unitario  e  Quantidade de Movimentação maior que 1
		Help("",1,"OA4520011_ValidaSaldo",,STR0002+cSrvAux,1,0) // Serviço com controle de Saldo unitário. Impossível efetuar Entrada com quantidade maior que 1.
		lOk := .f.
	Case cTipMov == "0" .and. cCtrSld == "1" .and. nQtdEst > 0 // Entrada  e  Controla Estoque Unitario  e  Já possui Estoque
		Help("",1,"OA4520011_ValidaSaldo",,STR0003+cSrvAux,1,0) // Serviço com controle de Saldo unitário. Impossível inserir devido a já existir no Estoque.
		lOk := .f.
	Case cTipMov == "1" .and. cCtrSld == "1" .and. nQtdMov > 1 // Saida  e  Controla Estoque Unitario  e  Quantidade de Movimentação maior que 1
		Help("",1,"OA4520011_ValidaSaldo",,STR0004+cSrvAux,1,0) // Serviço com controle de Saldo unitário. Impossível efetuar Saida com quantidade maior que 1.
		lOk := .f.
	Case cTipMov == "1" .and. nQtdMov > nQtdEst // Saida  e  Quantidade de Movimentação maior que a Quantidade existente no Estoque
		Help("",1,"OA4520011_ValidaSaldo",,STR0005+cSrvAux,1,0) // Impossível utilizar quantidade maior que a existente em Estoque.
		lOk := .f.
EndCase
Return lOk

