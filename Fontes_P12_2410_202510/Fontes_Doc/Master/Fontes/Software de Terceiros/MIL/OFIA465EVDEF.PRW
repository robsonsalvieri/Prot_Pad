#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "OFIA465.CH"

CLASS OFIA465EVDEF FROM FWModelEvent

	DATA lEstoq  // Atualiza Estoque ?

	METHOD New() CONSTRUCTOR
	METHOD Activate()
	METHOD FieldPreVld()
	METHOD ModelPosVld()
	METHOD VldActivate()
	METHOD AfterTTS()
	METHOD DeActivate()

ENDCLASS


// New //
METHOD New() CLASS OFIA465EVDEF
	::lEstoq  := .f. // NAO atualizar Estoque
RETURN .T.


// Abertura TELA //
METHOD Activate(oModel, lCopy) CLASS OFIA465EVDEF
	::lEstoq  := .f. // NAO atualizar Estoque
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE // Alteração
		oModel:SetValue( "VRTMASTER", "VRT_CODIGO", VRT->VRT_CODIGO ) // Necessario para possibilitar dar OK sem precisar alterar os dados na Alteração
	EndIf
	//
	SetKey(VK_F4,{|| OA4650051_VerEstoque() })
	//
RETURN .T.


// Campos Cabeçalho VRT //
METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS OFIA465EVDEF
Local lRet    := .t.
Local cMsgHlp := ""
Local cFilSD2 := ""
Local aFilAtu := {} // Filial Atual
Local aFilAux := {} // Filiais da Empresa logada
If cModelId == "VRTMASTER"
	If cAction == "SETVALUE" // Valid do campo
		Do Case
			Case cId == "VRT_FILDES"
				oSubModel:LoadValue( "VRT_NOMDES" , '' )
				If xValue == oSubModel:GetValue( "VRT_FILORI" )
					Help("",1,"FIELDPREVLD VRT_FILDES",,STR0024,1,0) // Filial de Destino e Origem não podem ser iguais!
					lRet := .f.
				ElseIf !Empty(xValue)
					aFilAtu := FWArrFilAtu()
					aFilAux := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Retorna Todas as Filiais da Empresa logada
					If !FWFilExist(cEmpAnt,xValue) .or. aScan(aFilAux,xValue) == 0
						Help("",1,"FIELDPREVLD VRT_FILDES",,STR0025,1,0) // Filial não encontrada na Empresa logada!
						lRet := .f.
					Else
						oSubModel:LoadValue( "VRT_NOMDES" , padr(FWFilialName(,xValue),GeTSX3Cache("VRT_NOMDES","X3_TAMANHO")) )
					EndIf
				EndIf

			Case cId == "VRT_SERINT"
				oSubModel:LoadValue( "VRT_GRUSER" , '' )
				oSubModel:LoadValue( "VRT_CODSER" , '' )
				oSubModel:LoadValue( "VRT_DESSER" , '' )
				oSubModel:LoadValue( "VRT_TIPSER" , '' )
				oSubModel:LoadValue( "VRT_QTDSER" ,  0 )
				If !Empty( xValue )
					DbSelectArea("VPX")
					DbSetOrder(1)
					If DbSeek( xFilial("VPX") + xValue )
						DbSelectArea("VPV")
						DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
						DbSeek( xFilial("VPV") + VPX->VPX_TIPSER )
						If VPV->VPV_CTRSLD == "0" // NAO Controla Saldo
							Help("",1,"FIELDPREVLD VRT_SERINT",,STR0026,1,0) // Serviço Especializado não Controla Saldo! Impossível continuar.
							lRet := .f.
						Else
							oSubModel:LoadValue( "VRT_GRUSER" , VPX->VPX_GRUSER )
							oSubModel:LoadValue( "VRT_CODSER" , VPX->VPX_CODSER )
							oSubModel:LoadValue( "VRT_DESSER" , padr(VPX->VPX_DESSER,GeTSX3Cache("VRT_DESSER","X3_TAMANHO")) )
							oSubModel:LoadValue( "VRT_TIPSER" , VPX->VPX_TIPSER )
						EndIf
					Else
						Help("",1,"FIELDPREVLD VRT_SERINT",,STR0027,1,0) // Serviço Especializado não encontrado! Impossível continuar.
						lRet := .f.
					EndIf
				EndIf

			Case cId == "VRT_QTDSER"
				If xValue > 0
					cFilSD2 := xFilial("SD2")
					DbSelectArea("VPY")
					DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
					If !DbSeek( xFilial("VPY") + oSubModel:GetValue( "VRT_SERINT" ) + cFilSD2 ) .or. VPY->VPY_QTDEST < xValue // NAO possui Estoque para a Quantidade desejada
						cMsgHlp := STR0028+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Serviço Especializado não existe em estoque na Filial de Origem com a quantidade desejada! Impossível continuar.
						cMsgHlp += STR0029+": "+Transform(VPY->VPY_QTDEST,GeTSX3Cache("VRT_QTDSER","X3_PICTURE")) // Quantidade em Estoque
						Help("",1,"FIELDPREVLD VRT_QTDSER",,cMsgHlp,1,0)
						lRet := .f.
					EndIf
				EndIf

		EndCase
	EndIf
EndIf
RETURN lRet

// Tudo OK da Tela //
METHOD ModelPosVld(oModel, cId) CLASS OFIA465EVDEF
	Local lRet       := .t.
	Local cMsgAvi    := ""
	Local cFilOri    := ""
	Local cFilDes    := ""
	Local nOperModel := oModel:GetOperation()
	//
	::lEstoq := .f. // NAO atualizar Estoque
	//
	If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
		If nOperModel == MODEL_OPERATION_UPDATE // Alteração
			lRet := ::VldActivate(oModel, cId)
		EndIf
		If lRet
			cFilOri := oModel:GetValue("VRTMASTER","VRT_FILORI")
			DbSelectArea("VPX")
			DbSetOrder(1)
			DbSeek( xFilial("VPX") + oModel:GetValue( "VRTMASTER" , "VRT_SERINT" ) )
			DbSelectArea("VPV")
			DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
			DbSeek( xFilial("VPV") + VPX->VPX_TIPSER )
			DbSelectArea("VPY")
			DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
			If !DbSeek( xFilial("VPY") + VPX->VPX_SERINT + cFilOri ) .or. VPY->VPY_QTDEST < oModel:GetValue( "VRTMASTER" , "VRT_QTDSER" ) // NAO possui Estoque
				Help("",1,"ModelPosVld",,STR0030,1,0) // Serviço Especializado não se encontra em Estoque na Filial de Origem! Impossível continuar.
				lRet := .f.
			Else
				cFilDes := oModel:GetValue("VRTMASTER","VRT_FILDES")
				cMsgAvi += CHR(13)+CHR(10)
				cMsgAvi += oModel:GetValue("VRTMASTER","VRT_GRUSER")+" - "+oModel:GetValue("VRTMASTER","VRT_CODSER")+CHR(13)+CHR(10)
				cMsgAvi += Alltrim(oModel:GetValue("VRTMASTER","VRT_DESSER"))+" ( "+oModel:GetValue("VRTMASTER","VRT_TIPSER")+" ) "+CHR(13)+CHR(10)+CHR(13)+CHR(10)
				cMsgAvi += Alltrim(RetTitle("VRT_FILORI")) + ": " +cFilOri+" - "+FWFilialName(,cFilOri)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
				cMsgAvi += Alltrim(RetTitle("VRT_FILDES")) + ": " +cFilDes+" - "+FWFilialName(,cFilDes)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
				cMsgAvi += Alltrim(RetTitle("VRT_QTDSER")) + ": " +Transform(oModel:GetValue("VRTMASTER","VRT_QTDSER"),GeTSX3Cache("VRT_QTDSER","X3_PICTURE"))
				nOpcAvi := Aviso(STR0031,cMsgAvi,{STR0032,STR0033},3) // Transferência do Serviço Especializado / Efetivar Transferência / Salvar Digitação
				If nOpcAvi == 1 // Transferir
					::lEstoq := .t. // Atualizar Estoque
				EndIf
			EndIf
		EndIf
	EndIf
RETURN lRet


// Validação antes da Abertura da Tela //
METHOD VldActivate(oModel, cModelId) CLASS OFIA465EVDEF
	Local lRet := .T.
	Local nOperModel := oModel:GetOperation()
	If nOperModel == MODEL_OPERATION_UPDATE
		If VRT->VRT_STATUS == "1" // 1=Transferência Efetivada
			Help("",1,"VLDACTIVATE",,STR0034,1,0) // Transferência já Efetivada. Impossível alterar.
			lRet := .f.
		ElseIf VRT->VRT_STATUS == "2" // 2=Transferência Cancelada
			Help("",1,"VLDACTIVATE",,STR0035,1,0) // Transferência já Cancelada. Impossível alterar.
			lRet := .f.
		EndIf
	EndIf
RETURN lRet


// Chamado apos a Gravação padrão //
METHOD AfterTTS(oModel, cModelId) CLASS OFIA465EVDEF
Local lRet    := .t.
Local nOperModel := oModel:GetOperation()
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	If ::lEstoq // Atualizar Estoque
		oProcTran := MsNewProcess():New({ |lEnd| lRet := OA4650021_IncluirTransferencia( ::lEstoq , .t. , "N" , {} ) }," ","",.f.)
		oProcTran:Activate()
		::lEstoq  := .f. // Volta para NAO atualizar Estoque
	EndIf
EndIf
RETURN lRet


// Fechar Tela
METHOD DeActivate(oModel) CLASS OFIA465EVDEF
	SetKey(VK_F4, Nil )
RETURN .T.