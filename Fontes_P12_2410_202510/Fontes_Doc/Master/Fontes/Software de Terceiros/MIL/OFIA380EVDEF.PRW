#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "OFIA380.CH"

CLASS OFIA380EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD FieldPreVld()
	METHOD VldActivate()
	METHOD ModelPosVld()
	METHOD GridLinePreVld()

ENDCLASS


// New //
METHOD New() CLASS OFIA380EVDEF
RETURN .T.


// Campos Validação //
METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS OFIA380EVDEF
Local lRet    := .t.
Local aFilAtu := {} // Filial Atual
Local aFilAux := {} // Filiais da Empresa logada
If cModelId == "VPVMASTER"
	Do Case
		Case cId == "VPV_CTRSLD"
			If cAction == "SETVALUE" // Valid do campo
				If xValue == "0" // Não Controla Saldo
					oSubModel:SetValue( "VPV_FILCEN" , space(FWSizeFilial()) )
				Else // Controla Saldo
					oSubModel:SetValue( "VPV_RELSAI" , "0" )
				EndIf
			EndIf
		Case cId == "VPV_FILCEN"
			If cAction == "SETVALUE" // Valid do campo
				If !Empty(xValue)
					If oSubModel:GetValue("VPV_CTRSLD") <> "0" // Controla Saldo
						aFilAtu := FWArrFilAtu()
						aFilAux := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Retorna Todas as Filiais da Empresa logada						
						If !FWFilExist(cEmpAnt,xValue) .or. aScan(aFilAux,xValue) == 0
							Help("",1,"VPV_FILCEN",,STR0008,1,0) // Filial não encontrada na Empresa logada!
							lRet := .f.
						EndIf
					EndIf
				EndIf
			EndIf
		Case cId == "VPV_CODSB1"
			If cAction == "SETVALUE" // Valid do campo
				oSubModel:SetValue( "VPV_GRUITE" , '' )
				oSubModel:SetValue( "VPV_CODITE" , '' )
				oSubModel:SetValue( "VPV_DESITE" , '' )
				If !Empty( xValue )
					DbSelectArea("SB1")
					DbSetOrder(1)
					If DbSeek( xFilial("SB1") + xValue ) .and. Type("_Grupos_Filtro") <> "U" .and. SB1->B1_GRUPO $ _Grupos_Filtro // Somente Grupos possiveis
						oSubModel:SetValue( "VPV_GRUITE" , SB1->B1_GRUPO )
						oSubModel:SetValue( "VPV_CODITE" , SB1->B1_CODITE )
						oSubModel:SetValue( "VPV_DESITE" , left(SB1->B1_DESC,GeTSX3Cache("VPV_DESITE","X3_TAMANHO")) )
					Else
						Help("",1,"FIELDPREVLD VPV_CODSB1",,STR0009,1,0) // Produto não encontrado para relacionar com o Serviço Especializado!
						lRet := .f.
					EndIf
				EndIf
			EndIf

	EndCase
EndIf
RETURN lRet


// Campos Itens VRV //
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFIA380EVDEF
Local lRet    := .t.
If cModelId == "VRVDETAIL"
	If cAction == "SETVALUE" // Valid do campo
		Do Case
			Case cId == "VRV_DATINI"
				If Empty(xValue)
					oSubModel:LoadValue( "VRV_DATFIN" , xValue )
				EndIf
				If oSubModel:GetValue( "VRV_DATFIN" ) < xValue
					oSubModel:LoadValue( "VRV_DATFIN" , xValue )
				EndIf
			Case cId == "VRV_DATFIN"
				If Empty(xValue)
					oSubModel:LoadValue( "VRV_DATINI" , xValue )
				EndIf
				If xValue < oSubModel:GetValue( "VRV_DATINI" )
					Help("",1,"GRIDLINEPREVLD VRV_DATFIN",,STR0010,1,0) // Impossível informar Data Final menor que a Data Inicial.
					lRet := .f.
				EndIf
			Case cId == "VRV_ESTCLI"
				DbSelectArea("SX5")
				DbSetOrder(1)
				If !Empty(xValue) .and. !DbSeek( xFilial("SX5") + "12" + xValue )
					Help("",1,"GRIDLINEPREVLD VRV_ESTCLI",,STR0011,1,0) // UF não existente!
					lRet := .f.
				EndIf
			Case cId == "VRV_PERSUG"
				If xValue > 0 // Com % Sugerido de Venda
					oSubModel:SetValue( "VRV_SUGVDA" , 0 ) // Limpa Valor Sugerido de Venda
				EndIf
			Case cId == "VRV_SUGVDA"
				If xValue > 0 // Com Valor Sugerido de Venda
					oSubModel:SetValue( "VRV_PERSUG" , 0 ) // Limpa % Sugerido de Venda
				EndIf
			Case cId == "VRV_PERMIN"
				If xValue > 0 // Com % Minimo
					oSubModel:SetValue( "VRV_VLRMIN" , 0 ) // Limpa Valor Minimo
				EndIf
			Case cId == "VRV_VLRMIN"
				If xValue > 0 // Com Valor Minimo
					oSubModel:SetValue( "VRV_PERMIN" , 0 ) // Limpa % Minimo
				EndIf
		EndCase
	EndIf
EndIf
RETURN lRet


// Validação antes da Abertura da Tela //
METHOD VldActivate(oModel, cModelId) CLASS OFIA380EVDEF

	Local lRet := .T.
	
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		If OA3800011_TipoUsado(VPV->VPV_CODTIP)
			Help("",1,"DELETE_VPV",,STR0012,1,0) // Tipo de Serviço Especializado já utilizado. Impossível excluir.
			lRet := .f.
		EndIf
	EndIf

RETURN lRet


// Tudo OK da Tela //
METHOD ModelPosVld(oModel, cId) CLASS OFIA380EVDEF
	Local lRet      := .t.
	Local oModelVPV := oModel:GetModel("VPVMASTER")
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		DbSelectArea("SB1")
		DbSetOrder(1)
		If DbSeek( xFilial("SB1") + oModelVPV:GetValue("VPV_CODSB1") ) .and. Type("_Grupos_Filtro") <> "U" .and. SB1->B1_GRUPO $ _Grupos_Filtro // Somente Grupos possiveis
			// OK - Produto relacionado corretamente
		Else
			Help("",1,"MODELPOSVLD VPV_CODSB1",,STR0013,1,0) // Informe corretamente o Produto relacionado ao Serviço Especializado.
			lRet := .f.
		EndIf
	EndIf
RETURN lRet
