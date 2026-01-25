#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA332C.CH"

#DEFINE WMSA332C01 "WMSA332C01"

Static oMovimento := WMSDTCMovimentosServicoArmazem():New()

Function WMSA332C()
Return Nil

Static Function ModelDef()
Local oStruCBA := FWFormStruct(1,'CBA',/*bAvalCampo*/,/*lViewUsado*/)
Local oModel   := MPFormModel():New('WMSA332C',/*bPreValidacao*/,{|oModel| PosVldMdl(oModel) },{|oModel| CommitMdl(oModel) },/*bCancel*/)

	oStruCBA:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	oStruCBA:SetProperty('*',MODEL_FIELD_VALID  ,FWBuildFeature( STRUCT_FEATURE_VALID, '' ))
	oStruCBA:SetProperty('*',MODEL_FIELD_WHEN   ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".T." ))
	oStruCBA:SetProperty('*',MODEL_FIELD_INIT   ,FWBuildFeature( STRUCT_FEATURE_INIPAD, '' ))
	

	oStruCBA:SetProperty('CBA_LOCALI',MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'WMS332VEnd(A,B)' ) ) 
	oStruCBA:SetProperty('CBA_CODINV'  ,MODEL_FIELD_INIT ,{|| GetSXENum("CBA","CBA_CODINV") })
	
	oModel:AddFields('CBAMASTER',/*cOwner*/,oStruCBA )
	oModel:GetModel('CBAMASTER'):SetDescription( STR0001 ) //"Mestre de Inventário"
	
	oModel:SetActivate({|oModel| InitFields(oModel) } )
Return oModel

Static Function ViewDef()
Local oStruCBA := FWFormStruct( 2, 'CBA' )
Local oModel   := FWLoadModel( 'WMSA332C' )
Local oView    := FWFormView():New()

	oStruCBA:setproperty("*" ,MVC_VIEW_CANCHANGE,.F.)
	oStruCBA:setproperty("CBA_LOCALI" ,MVC_VIEW_CANCHANGE,.T.)
	oStruCBA:setproperty("CBA_CONTS" , MVC_VIEW_CANCHANGE,.T.)
	oStruCBA:setproperty("CBA_AUTREC" , MVC_VIEW_CANCHANGE,.T.)
	oStruCBA:setproperty("CBA_CLASSA" , MVC_VIEW_CANCHANGE,.T.)
	oStruCBA:setproperty("CBA_CLASSB" , MVC_VIEW_CANCHANGE,.T.)
	oStruCBA:setproperty("CBA_CLASSC" , MVC_VIEW_CANCHANGE,.T.)
	
	oView:SetModel( oModel )
	oView:AddField( 'CBAVIEW', oStruCBA, 'CBAMASTER' )
   
Return oView

Static Function InitFields(oModel)
Local oModelCBA := oModel:GetModel('CBAMASTER')
	
	oModelCBA:LoadValue("CBA_DATA"  ,dDataBase)
	oModelCBA:LoadValue("CBA_CONTS" ,2)
	oModelCBA:LoadValue("CBA_TIPINV","2")
	oModelCBA:LoadValue("CBA_CONTR" ,0)
	oModelCBA:LoadValue("CBA_STATUS","0")
	oModelCBA:LoadValue("CBA_AUTREC","1")
	oModelCBA:LoadValue("CBA_CLASSA","2")
	oModelCBA:LoadValue("CBA_CLASSB","2")
	oModelCBA:LoadValue("CBA_CLASSC","2")
	
	oMovimento:GoToD12( D12->(Recno()) )
	If oMovimento:oMovServic:GetTipo() == "1" // Movimento de entrada
		// Seta o armazem destino do inventario
		oModelCBA:LoadValue("CBA_LOCAL" ,oMovimento:oMovEndDes:GetArmazem())
		oModelCBA:LoadValue("CBA_LOCALI" ,oMovimento:oMovEndDes:GetEnder())
	ElseIf oMovimento:oMovServic:GetTipo() $ "2|3" // Movimento de saida/interno 
		// Seta o armazem origem do inventario
		oModelCBA:LoadValue("CBA_LOCAL" ,oMovimento:oMovEndOri:GetArmazem())
		oModelCBA:LoadValue("CBA_LOCALI" ,oMovimento:oMovEndOri:GetEnder())
	EndIf
Return .T.

Function WMS332VEnd(oModel,cField)
Local lRet := .T.
	If cField == "CBA_LOCALI"
		If Empty(oModel:GetValue("CBA_LOCALI"))
			lRet := .F.
		Else
			oMovimento:SetEndInv(oModel:GetValue("CBA_LOCALI"))
			If oMovimento:VldEndInv()
				cArmazem := oMovimento:GetArmInv()
				lRet := .T.
			Else
				oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', '', oMovimento:GetErro(), "", '', '')
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
Return lRet

Static Function CommitMdl(oModel)
	If __lSX8
		ConfirmSX8()
	EndIf
Return FWFormCommit(oModel)

Static Function PosVldMdl(oModel)
Local nOp     := oModel:GetOperation()
Local lRet    := .T.
Local cAliasQry := Nil
Local oModelCBA := oModel:GetModel('CBAMASTER')

    If nOp == MODEL_OPERATION_INSERT
       //verificar se ja existe um inventário em aberto
       cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DISTINCT 1 
			FROM %Table:CBA% CBA
			WHERE CBA_FILIAL = %xFilial:CBA%
			AND CBA_LOCAL = %Exp:oModelCBA:GetValue("CBA_LOCAL")%
			AND CBA_LOCALI = %Exp:oModelCBA:GetValue("CBA_LOCALI")%
			AND CBA_STATUS <> '5'
			AND CBA_DATA = %Exp:Date()%
			AND CBA.%NotDel%
		EndSql
		IF (cAliasQry)->(!Eof())
			oModel:GetModel():SetErrorMessage( , , oModel:GetId() , '', '',STR0002 , "", '', '') //"Existe inventário ainda não processado para a data atual e endereço informado."
			lRet := .F.
		EndIf
    EndIf
   
return lRet
        