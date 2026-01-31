#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM927.CH"

#define  CRLF chr(13)+chr(10)
/*/{Protheus.doc} GPEM927
Visualização de Histórico - Integrações Quirons
@since	04/12/2023
@autor	martins.marcio
@version P12
/*/
Function GPEM927(nOpcAuto)
	Private oBrwRJP

	oBrwRJP:= FWmBrowse():New()
	oBrwRJP:SetDescription( OemToAnsi(STR0001) )	// "Visualizar Histórico"
	oBrwRJP:SetAlias( "RJP" )
	oBrwRJP:SetMenuDef( 'GPEM927' )
	oBrwRJP:Activate()

Return Nil


/*/{Protheus.doc} ³ModelDef
Definicao do modelo de dados da Visualização de Histórico de Integrações Quirons
@since	04/12/2023
@autor	martins.marcio
@version P12
/*/
Static Function ModelDef()
	Local cCampo	:= ""
	Local oStructRJP
	Local oStructRU7
	Local oModel

	oModel:= MpFormModel():New("GPEM927",/*Pre-Validacao*/,  /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oStructRJP := FWFormStruct(1,"RJP", {|cCampo| AllTrim(cCampo)+"|" $ "RJP_FILIAL|RJP_FIL|RJP_MAT|RJP_TAB|RJP_OPER|RJP_KEY|"})
	oModel:AddFields("GPEM927_RJP", /*cOwner*/, oStructRJP , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:SetPrimaryKey( { "RJP_FILIAL", "RJP_FIL", "RJP_MAT", "RJP_TAB", "RJP_OPER", "RJP_KEY" } )
	oModel:GetModel("GPEM927_RJP"):SetOnlyView( .T. )
	oModel:GetModel("GPEM927_RJP"):SetOnlyQuery( .T. )

	oStructRU7 := FWFormStruct(1,"RU7")
	oModel:AddGrid("GPEM927_RU7", "GPEM927_RJP"/*cOwner*/, oStructRU7 , /*bLinePre*/,  /*bLinePost*/, /*bPre*/,  /*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey( { "RU7_FILIAL", "RU7_ID", "RU7_DTIN", "RU7_HORAIN", "RU7_SEQ" } )
	oModel:SetRelation("GPEM927_RU7",{{"RU7_FILIAL",'xFilial("RU7",RJP->RJP_FILIAL)'},{"RU7_ID","RJP_FIL + RJP_MAT + RJP_TAB + RJP_OPER"} },RU7->(IndexKey()))
	oModel:GetModel("GPEM927_RU7"):SetForceLoad(.T.)

Return(oModel)


/*/{Protheus.doc} ViewDef
Definicao da tela da Visualização de Histórico de Integrações Quirons
@since	04/12/2023
@autor	martins.marcio
@version P12
/*/
Static Function ViewDef()
	Local oModel		:= FwLoadModel("GPEM927")
	Local oStructRJP	:= Nil
	Local oStructRU7	:= Nil
	Local oView			:= FWFormView():New()

	oView:SetModel(oModel)

	oStructRJP := FWFormStruct(2,"RJP", {|cCampo| AllTrim(cCampo)+"|" $ "RJP_FILIAL|RJP_FIL|RJP_TAB|RJP_KEY|"})
	oStructRJP:SetNoFolder()
	oStructRU7 := FWFormStruct(2,"RU7",{|cCampo| !(AllTrim(cCampo)+"|" $ "RU7_FILIAL|")})

	oView:AddField( "GPEM927_RJP" , oStructRJP )
	oView:AddGrid(  "GPEM927_RU7" , oStructRU7 )

	oView:SetViewProperty("GPEM927_RJP","OnlyView") 

	oView:CreateHorizontalBox("FORMFIELD",20)
	oView:CreateHorizontalBox("GRID"     ,80)

	oView:SetOwnerView( "GPEM927_RJP","FORMFIELD")
	oView:SetOwnerView( "GPEM927_RU7","GRID")
	oView:SetOperation(1)

	oView:AddUserButton(OemToAnsi(STR0006),'',{|oModel| Gp927Exc(oModel) }) // "Excluir"

	oView:SetCloseOnOk({ || .T. })

Return(oView)

/*/{Protheus.doc} MenuDef
Opções de Menu
@since	04/12/2023
@autor	martins.marcio
@version P12
/*/
Static Function MenuDef()
	Local aRotina :=  {}

	ADD OPTION aRotina TITLE OemToAnsi(STR0002) 	ACTION 'PesqBrw'          	OPERATION 1 ACCESS 0 DISABLE MENU	// "Pesquisar"
	ADD OPTION aRotina TITLE OemToAnsi(STR0003) 	ACTION 'VIEWDEF.GPEM927'	OPERATION 2 ACCESS 0 DISABLE MENU	// "Visualizar"

Return aRotina

/*/{Protheus.doc} Gp927Exc
Exclui o registro posicionado no grid
@since	04/12/2023
@autor	martins.marcio
@version P12
/*/
Static Function Gp927Exc(oModel, oView)
	
	Local lRet := .T.
	Local oGrid := oModel:GetModel("GPEM927_RU7")
	
	//ATENÇÃO: Após a confirmação a linha atual será excluída e NÃO SERÁ POSSÍVEL DESFAZER ESSA OPERAÇÃO!"
	lRet := MsgNoYes( OemToAnsi(STR0004) + CRLF + CRLF + OemToAnsi(STR0005)) //"Confirma a exclusão ?" + CRLF + CRLF + "Após a confirmação a linha atual será excluída e NÃO SERÁ POSSÍVEL DESFAZER ESSA OPERAÇÃO!"
	If lRet 
		RU7->(DbSetOrder(2))
		If RU7->(DbSeek(oGrid:GetValue("RU7_FILIAL") + oGrid:GetValue("RU7_ID") + oGrid:GetValue("RU7_SEQ") + DTOS(oGrid:GetValue("RU7_DTIN")) + oGrid:GetValue("RU7_HORAIN"))) 
			If Reclock("RU7", .F.)
				RU7->(DbDelete())
				RU7->(MsUnlock())
			EndIf

			oModel:DeActivate()
			oGrid:ClearData( .F., .F.) 
			DbSelectArea("RJP")
			oModel:Activate()
		EndIf
	EndIf

Return lRet
