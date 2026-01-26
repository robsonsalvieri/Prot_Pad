#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA601.CH"

/*/{Protheus.doc} GTPA601
	(Cadastro de Clientes Faturados para viagens Eventuais
	Permite que alguns clientes possam executar em formato de faturamento onde os clientes realizam
	a viagem e o pagamento é feito posteriormente. Sendo realizado as devidas consistências no 
	momento da execução da viagem. )
	@type  Function
	@author marcelo.adente
	@since 04/10/2022
	@version 1.0
	@return oBrowse, object, Objeto com FWMBrowse da rotina
	/*/
Function GTPA601()

Local oBrowse    := Nil
Local aFieldsH6H := {}
Local cMsgErro   := ""

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

	oBrowse    := FWMBrowse():New()
	aFieldsH6H := {'H6H_FILIAL','H6H_CODIGO','H6H_CODLOJ'}
	
	If GTPxVldDic("H6H",aFieldsH6H,.T.,.T.,@cMsgErro)
	    oBrowse:SetAlias('H6H')
	    oBrowse:SetDescription(STR0001)
	    If !isBlind()
	        oBrowse:Activate()
	    EndIf
	    oBrowse:Destroy()
	EndIf

	If !(EMPTY(cMsgErro))
	    FwAlertWarning(cMsgErro)
	EndIf

EndIf

Return oBrowse

/*/{Protheus.doc} MenuDef()
Menu da Rotina
@author marcelo.adente
@since   25/05/2017
@version 1.0
@return aRotina, array, Array contendo itens do menu
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002	ACTION "VIEWDEF.GTPA601" OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0003	ACTION "VIEWDEF.GTPA601" OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.GTPA601" OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0005	ACTION "VIEWDEF.GTPA601" OPERATION 5 ACCESS 0 // Excluir

Return aRotina

/*/{Protheus.doc} ModelDef()
Modelo de Dados da Rotina
@author marcelo.adente
@since   04/10/2022
@version 1.0
@return oModel, object, Retorna o Modelo da rotina
/*/
Static Function ModelDef()
Local oModel
Local oStruH6H  := FWFormStruct(1,"H6H")

oModel 	:= MPFormModel():New("GTPA601",/*bPreValidMdl*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

//Função utilizada para ajustes na estrutura de campos
Ga601Struc('M',oStruH6H)
oModel:SetDescription(STR0001) // Parâmetros de Clientes
oModel:AddFields("FIELDH6H",,oStruH6H)
oModel:GetModel('FIELDH6H'):SetDescription(STR0001)	// Parâmetros de Clientes

Return oModel

/*/{Protheus.doc} ViewDef()
View da Rotina
@author marcelo.adente
@since   04/10/2022
@version 1.0
@return oView, object, Retorna o a View da rotina
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA601')
Local oView		:= FWFormView():New()
Local oStruH6H	:= FWFormStruct(2, "H6H")

oView:SetModel(oModel)
oView:SetDescription(STR0001)///'Parâmetros do Cliente'

oView:AddField("VIEW_H6H", oStruH6H, "FIELDH6H")

oView:CreateHorizontalBox( "SUPERIOR", 90)
oView:CreateHorizontalBox( "INFERIOR", 10)
oView:SetOwnerView("VIEW_H6H","SUPERIOR")

oView:EnableTitleView('VIEW_H6H'	,STR0001)	//'Parâmetros do Cliente'

Return oView

/*/{Protheus.doc} GA601VldCli()
Validação do dicionario parta cliente e loja 
@author marcelo.adente
@since   04/10/2022
@version 1.0
@return lRet, boolean, Retorna validação do cliente para validação do modelo
/*/
Function GA601VldCli()

Local lRet := .T.

IF !Empty(FWFldGet("H6H_CODLOJ")) .and. !ExistChav("H6H", FWFldGet("H6H_CODIGO") + FWFldGet("H6H_CODLOJ")) 
	lRet := .F.
EndIf

If lRet .and. !ExistCpo("SA1", FWFldGet("H6H_CODIGO")+AllTrim(FWFldGet("H6H_CODLOJ")))
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} Ga601Struc()
Alteração da estrutura do modelo
@author marcelo.adente
@since   04/10/2022
@version 1.0
/*/
Static Function Ga601Struc(cTipo,oStruH6H)
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit	    := {|oMdl,cField,uVal| FieldInit(oMdl,cField,uVal)}
If cTipo == 'M'
		oStruH6H:AddTrigger("H6H_CODLOJ", "H6H_CODLOJ" , {||.T.}, bFldTrig) 
		oStruH6H:SetProperty("H6H_NOMCLI" , MODEL_FIELD_INIT, bInit)
EndIf
  
Return

/*/{Protheus.doc} FieldTrigger
//TODO Ação da Trigger dos campos.
@author marcelo.adente
@since   04/10/2022
@version 1.0
@type function
/*/
Static Function FieldTrigger(oMdl,cField,uVal)

If cField == 'H6H_CODLOJ'
	 oMdl:LoadValue('H6H_NOMCLI', Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('H6H_CODIGO')+oMdl:GetValue('H6H_CODLOJ'),'A1_NOME'))
Endif

Return

/*/{Protheus.doc} FieldInit
//TODO Ação de Inicialização de campos 
@author marcelo.adente
@since   04/10/2022
@version 1.0
@return uRet, Retorna o critério de inicialização
@type function
/*/
Static Function FieldInit(oMdl,cField,uVal)
Local uRet      := nil
Local aArea     := GetArea()

Do Case
Case cField == "H6H_NOMCLI"
	uRet := Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('H6H_CODIGO')+oMdl:GetValue('H6H_CODLOJ'),'A1_NOME')
EndCase

RestArea(aArea)

Return uRet