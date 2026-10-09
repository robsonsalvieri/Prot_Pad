#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "OFIA550.CH"

#DEFINE nLimiteArq 40 // tratamento de leitura interna da SCANIA

/*/{Protheus.doc} OFIA550
SCANIA - DSM Global Cadastro de Ajustes de Estoque
@author Andre Luis Almeida
@since 03/01/2023
/*/
Function OFIA550(nTp)
	Local   aSize     := FWGetDialogSize( oMainWnd )
	local   oDlgADSMG
	local   oBrwVL4
	Local   oDSMParametros := OFDSMParametros():New()
	Local   aGrpTotal	 := oDSMParametros:grupos()
	Private aRotina   := menuDef()
	Private cCadastro := STR0001 // SCANIA - DSM Global - Ajustes de Estoque
	Private cGrupo    := "SCG" // Utilizada na Consulta B20
	Default nTp       := 0

	if ValType(aGrpTotal) == "A" .and. len(aGrpTotal) > 0
		cGrupo := ArrTokStr( aGrpTotal, "," )
	endif

	If nTp == 0
		oDlgADSMG := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )
		oBrwVL4 := FWMBrowse():New()
		oBrwVL4:SetAlias('VL4')
		oBrwVL4:SetDescription(cCadastro)
		oBrwVL4:SetOwner(oDlgADSMG)
		oBrwVL4:AddLegend( 'VL4->VL4_STATUS == "0"' , 'BR_BRANCO'   , STR0002 )	// Ajuste Digitado
		oBrwVL4:AddLegend( 'VL4->VL4_STATUS == "1"' , 'BR_VERDE'    , STR0003 )	// Ajuste Efetivado
		oBrwVL4:AddLegend( 'VL4->VL4_STATUS == "2"' , 'BR_VERMELHO' , STR0004 )	// Ajuste Cancelado
		oBrwVL4:DisableDetails()
		oBrwVL4:DisableLocate()
		oBrwVL4:SetAmbiente(.F.)
		oBrwVL4:SetWalkthru(.F.)
		oBrwVL4:SetUseFilter()
		oBrwVL4:Activate()
		oDlgADSMG:Activate( , , , , , , )
	ElseIf nTp == 1
		OA5500021_Efetivar(1)	// Efetivar Posicionado
	ElseIf nTp == 2
		OA5500021_Efetivar(0)	// Efetivar Todos Digitados
	ElseIf nTp == 3
		OA5500031_Cancelar()
	EndIf
return nil


/*/{Protheus.doc} MenuDef
Definição do menuDef
@author Andre Luis Almeida
@since 02/09/2022
@version 1.0
@Return oModel
/*/
static function MenuDef()
local aRotina := {}
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.OFIA550' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.OFIA550' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0007 ACTION 'OFIA550(1)'      OPERATION 4 ACCESS 0 // Efetivar Posicionado
	ADD OPTION aRotina TITLE STR0008 ACTION 'OFIA550(2)'      OPERATION 4 ACCESS 0 // Efetivar Todos Digitados
	ADD OPTION aRotina TITLE STR0009 ACTION 'OFIA550(3)'      OPERATION 5 ACCESS 0 // Cancelar
return aRotina


/*/{Protheus.doc} ModelDef
Definição do Model
@author Andre Luis Almeida
@since 02/09/2022
@version 1.0
@Return oModel
/*/
static function ModelDef()
local oStrVL4 := FWFormStruct(1,"VL4")
local oModel  := MPFormModel():New("OFIA550", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

	oModel:AddFields("VL4MASTER",/*cOwner*/ , oStrVL4)
	oModel:GetModel("VL4MASTER"):SetDescription( STR0001 ) // SCANIA - DSM Global Cadastro de Ajustes de Estoque
	oModel:SetDescription( STR0001 ) // SCANIA - DSM Global Cadastro de Ajustes de Estoque
return oModel


/*/{Protheus.doc} ViewDef
Definição do interface
@author Andre Luis Almeida
@since 02/09/2022
@version 1.0
@Return oView
/*/
static function ViewDef()
local oView
local oModel  := ModelDef()
local oStrVL4 := FWFormStruct(2,"VL4", { |cCampo| !ALLTRIM(cCampo) $ "VL4_CODIGO/" } )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:SetCloseOnOk({||.T.})
	oView:AddField( 'VIEW_VL4', oStrVL4, 'VL4MASTER' )
	oView:CreateHorizontalBox('CABEC' , 100)
	oView:SetOwnerView('VIEW_VL4', 'CABEC' )
return oView


/*/{Protheus.doc} OA5500011_GravaStatus
Grava Status do Ajuste
@author Andre Luis Almeida
@since 03/01/2023
/*/
static function OA5500011_GravaStatus( cCodigo , cStatus )
Local   oModVL4 := FWLoadModel( 'OFIA550' ) // MVC somente para atualizar o cabeÃ§alho VL4
Default cCodigo := ""
Default cStatus := "0" // 0=Ajuste Digitado

	VL4->(DbSetOrder(1))
	If VL4->(DbSeek(xFilial("VL4")+cCodigo))
		If cStatus <> VL4->VL4_STATUS
			oModVL4:SetOperation( MODEL_OPERATION_UPDATE )
			If oModVL4:Activate()
				oModVL4:SetValue( "VL4MASTER" , "VL4_STATUS" , cStatus ) // 0=Ajuste Digitado / 1=Ajuste Efetivado / 2=Ajuste Cancelado
				If cStatus == "1" // Efetivado
					oModVL4:SetValue( "VL4MASTER" , "VL4_DATEFE" , dDatabase ) // Data
					oModVL4:SetValue( "VL4MASTER" , "VL4_HOREFE" , val(left(time(),2)+substr(time(),4,2)) ) // Hora
					oModVL4:SetValue( "VL4MASTER" , "VL4_USREFE" , __cUserID ) // Usuario
				EndIf
				If oModVL4:VldData()
					oModVL4:CommitData()
				EndIf
				oModVL4:DeActivate()
			EndIf
		EndIf
	EndIf
	FreeObj(oModVL4)
return nil


/*/{Protheus.doc} OA5500021_Efetivar
Efetivar
@author Andre Luis Almeida
@type function
@since 03/01/2023
/*/
Static function OA5500021_Efetivar(nTp)
	Local   cQuery         := ""
	Local   cQAlSQL        := "SQLVL4"
	Local   aRecVL4        := {}
	Local   nCntFor        := 0
	Local   nCntID         := 1
	Local   cXML           := ""
	Local   cDateArq       := dtos(dDataBase)
	Local   cTimeArq       := SUBS(time(),1,2) + SUBS(time(),4,2)
	Local   oDSMParametros := OFDSMParametros():New()
	Local   aBind          := {}
	Local 	lNewRes 	   := GetNewPar("MV_MIL0181", .F.) // Controla nova reserva no ambiente? 
	// variáveis private abaixo utilizadas nas funções chamadas internamente para manter o contexto e compatibilidade
	Private dDtIniRef    := date()
	Private cHrIniRef    := time()
	Private dDtFinRef    := date()
	Private cHrFinRef    := time()
	Private cOperatID    := oDSMParametros:operator_id()
	Private cOwnerID     := oDSMParametros:owner_id()
	Private cWHouseID    := oDSMParametros:filial_warehouse_id()
	Private aGrpTotal	 := oDSMParametros:grupos()
	Private nCntQtd      := 1
	Private cUrlXML      := oDSMParametros:url_xml()
	Private cUserWS      := oDSMParametros:user_webservice()
	Private cPassWS      := oDSMParametros:pass_webservice()
	Private cRodapXML    := OA0300021_SOAP_Rodape()
	Private cNomXML      := "BR_"+cOperatID+'_'+cWHouseID+'_'+dtos(dDtFinRef)+'T'+substr(cHrFinRef,1,2)+substr(cHrFinRef,4,2)
	Private lAgrResBlq   := ( oDSMParametros:agrega_resblq()   == "1" )
	Private lAgrTransi   := ( oDSMParametros:agrega_transito() == "1" )
	Private lEnviaWS     := .t.
	Private nSeqXML      := 0
	Private cDirXML      := oDSMParametros:diretorio_XML()
	Private aIteBalance  := {}
	Private aArmReserv   := {}
	Private cTipoExec	 := "StockAdjustment(OFIA550)"
	Private lSchedule	 := .F.
	Private cCodLogVQL	 := OA030040K_RegistraLOG( {"OA550001", STR0015, "", /*lShowHelp:=*/ .F.}, /*cCodLogVQL*/, /*lClose := .F.*/)

	If lNewRes
		aAdd(aArmReserv, Left(GetMV("MV_MIL0177")+Space(10),Len(SB2->B2_LOCAL)))
		aAdd(aArmReserv, Left(GetMV("MV_MIL0179")+Space(10),Len(SB2->B2_LOCAL)))
		aAdd(aArmReserv, Left(GetMV("MV_MIL0192")+Space(10),Len(SB2->B2_LOCAL)))
	Else
		aAdd(aArmReserv, Left(GetMV("MV_RESITE")+Space(10),Len(SB2->B2_LOCAL)))
	EndIf
	aAdd(aArmReserv, left(GetMV("MV_BLQITE")+space(10),tamSX3("B2_LOCAL")[1]))

	If nTp == 1 // Individual
		aAdd( aRecVL4 , VL4->(RecNo()) )
		cNomXML += '_' + VL4->VL4_CODIGO // Diferenciar os arquivos de estoque gerado por numero de processo de ajuste
	Else
		cQuery := "SELECT R_E_C_N_O_ AS RECVL4 "
		cQuery += " FROM "+RetSqlName("VL4")+" VL4 "
		cQuery += " WHERE VL4_FILIAL = ?"	; aAdd( aBind, { "C", xFilial("VL4") } )
		cQuery += "   AND VL4_STATUS = ?"	; aAdd( aBind, { "C", "0" } )
		cQuery += "   AND D_E_L_E_T_ = ?"	; aAdd( aBind, { "C", " " } )
		OA030037C_ExecQuery( @cQuery, aBind, cQAlSQL, .F. )
		While !( cQAlSQL )->( Eof() )
			aAdd( aRecVL4 , ( cQAlSQL )->( RECVL4 ) )
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		dbSelectArea("VL4")
	EndIf

	For nCntFor := 1 to len(aRecVL4)
		dbSelectArea("VL4")
		dbGoTo(aRecVL4[nCntFor])

		If nCntQtd == nLimiteArq
			OA0300071_GravaXML(cXML)
			nCntQtd := 1
			cXML := ""
		EndIf

		OA030040K_RegistraLOG( {"OA550002", STR0017 + VL4->VL4_CODITE , "", /*lShowHelp:=*/ .F.}, cCodLogVQL, /*lClose := .F.*/)

		cXML += OA0300051_Transaction( .t. , nCntID )
		cXML += '<v11:StockAdjustment stockAdjustmentTime="'+cDateArq+"T"+cTimeArq+'" reasonForAdjustment='
		cXML += '"StockTaking"'
		cXML += ' quantity="'+Alltrim(Transform(VL4->VL4_QTDAJU,"@E 9999999999"))+'">'+CRLF
		cXML += '<v11:AssortmentOperatorId identifier="'+cOperatID+'"/>'+CRLF
		cXML += '<v11:StockId stockId="1" warehouseId="'+cWHouseID+'"/>'+CRLF
		cXML += '<v11:PartId assortmentOwnerId="'+cOwnerID+'" partNumber="'+Alltrim(VL4->VL4_CODITE)+'"/>'+CRLF
		cXML += '</v11:StockAdjustment>'+CRLF
		cXML += OA0300051_Transaction( .f. , 0 )
		nCntID++
		nCntQtd++
		If aScan(aIteBalance, {|x| x[1] + x[2] == cFilAnt + VL4->VL4_CODITE }) == 0 
			aAdd(aIteBalance,{ cFilAnt , VL4->VL4_CODITE , cDateArq+"T"+cTimeArq })
		EndIf
		OA5500011_GravaStatus( VL4->VL4_CODIGO , "1" ) // Mudar Status para 1=Ajuste Efetivado

	Next
	cXML := OA0300261_BalanceEstoque( cWHouseID , @nCntID , cXML )
	OA0300071_GravaXML(cXML)

	OA030040K_RegistraLOG({"OA030003", STR0016,"" ,/*lShowHelp:=*/ .F.}, cCodLogVQL, /*lClose := */.T.)

return nil


/*/{Protheus.doc} OA5500031_Cancelar
Opção CANCELAR do aRotina - Ajuste Estoque
@author Andre Luis Almeida
@since 03/01/2023
/*/
static function OA5500031_Cancelar()

	If VL4->VL4_STATUS == "1"		// 1=Ajuste Efetivado
		FMX_Help( STR0010, STR0011 )	// "Validação Cancelar" # "Ajuste já efetuado, impossível continuar"
	ElseIf VL4->VL4_STATUS == "2"	// 2=Ajuste Cancelado
		FMX_Help( STR0010, STR0012 )	// "Validação Cancelar" # "Ajuste já cancelado, impossível continuar"
	Else							// Digitado
		If FWAlertYesNo( STR0013, STR0014 ) // Confirma o Cancelamento do Ajuste? # Atenção
			OA5500011_GravaStatus( VL4->VL4_CODIGO , "2" )		// Mudar Status para 2=Ajuste Cancelado
		EndIf
	EndIf
return nil
