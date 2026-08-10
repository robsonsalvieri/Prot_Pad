#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA090.CH"

#DEFINE WMSA09001 'WMSA09001'
#DEFINE WMSA09002 'WMSA09002'
#DEFINE WMSA09003 'WMSA09003'

//---------------------------------------------------------------------------
/*/{Protheus.doc} WMSA090
Cadastro de complementos de produto para WMS

@author Wander Horongoso
@since 16/10/2020
@version 1.0
@obs  A tabela de complementos de produto (SB5) estourou a quantidade máxima de campos (255).
Por este motivo, foi necessário criar uma tabela nova e um programa específico para manipulá-la.
/*/
//---------------------------------------------------------------------------
Function WMSA090()
Local oBrowse    := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("D1A")         // Alias da tabela utilizada
	oBrowse:SetMenuDef("WMSA090")   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) // Descrição do browse "Complementos de Produto WMS"
	oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
	oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
	oBrowse:Activate()

Return NIL

/*---------------------------------------------------------------------------
---MenuDef
---MenuDef com as rotinas do Browse
---Wander Horongoso 16/10/2020
---------------------------------------------------------------------------*/
Static Function MenuDef()
Private aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002    ACTION "PesqBrw"         OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0003    ACTION "VIEWDEF.WMSA090" OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.WMSA090" OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.WMSA090" OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.WMSA090" OPERATION 5 ACCESS 0 // Excluir
		
Return (aRotina)


/*---------------------------------------------------------------------------
---ModelDef
---Modelo de dados
---Wander Horongoso 16/10/2020
---------------------------------------------------------------------------*/
Static Function ModelDef()
Local oModel := Nil
Local oStruD1A := FwFormStruct( 1, "D1A" )
Local bPosValid := { |oModel| PosVldMdl(oModel) }

	oModel:= MpFormModel():New("WMSA090", , bPosValid)
	oModel:SetDescription(STR0001) // Complemento de Produto WMS

	oModel:AddFields("D1AMASTER",Nil,oStruD1A)
	oModel:SetPrimaryKey({"D1A_FILIAL","D1A_COD"})
	
Return oModel

/*---------------------------------------------------------------------------
---ViewDef
---Exibe browse de acordo com a estrutura
---Wander Horongoso 16/10/2020
---------------------------------------------------------------------------*/
Static Function ViewDef()
Local oModel := FwLoadModel("WMSA090")
Local oStruD1A := FwFormStruct (2, "D1A")
Local oView := Nil

	oView := FwFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VwFieldD1A', oStruD1A, 'D1AMASTER')

Return oView

Static Function PosVldMdl(oModel)
Local lRet := .T.
Local oModelD1A := oModel:GetModel("D1AMASTER")
Local lCtlSaas := !Empty(D1A->(FieldPos("D1A_WSAAS"))) .And. oModelD1A:GetValue('D1A_WSAAS')
	
	If Empty(oModelD1A:GetValue('D1A_SEREPR')) .And. Empty(oModelD1A:GetValue('D1A_ENDEPR')) .And. !lCtlSaas
		oModel:SetErrorMessage('D1AMASTER',,,,WMSA09001, STR0007, STR0008) //'Serviço de entrada de produção e endereço de entrada de produção não informados.' //'Deve-se informar serviço de entrada de produção, endereço de produção ou ambos.' 
		lRet := .F.
	EndIf

	If lCtlSaas .And. Localiza(oModelD1A:GetValue('D1A_COD'))
		oModel:SetErrorMessage('D1AMASTER',,,,WMSA09002, STR0009, STR0010) //'Para habilitar controle do WMS Saas, produto não pode ter controle de localização ativa no Protheus.' //'Verificar cadastro de produtos.' 
		lRet := .F.
	EndIf

	If lCtlSaas .And. GetAdvFVal("SB5", "B5_CTRWMS", xFilial("SB5")+oModelD1A:GetValue('D1A_COD'), 1, "") == "S"
		oModel:SetErrorMessage('D1AMASTER',,,,WMSA09003, STR0011, STR0012) //'Para habilitar controle do WMS Saas, produto não pode ter controle de WMS ativo no Protheus.' //'Verificar complemento do cadastro de produtos.' 
		lRet := .F.
	EndIf

	If lCtlSaas .And. WMSA90SUB(oModelD1A:GetValue('D1A_COD'))
        oModel:SetErrorMessage('D1AMASTER',,,,WMSA09003, STR0013) //"Produto possui controle de Sublote. Não é possível integrar o produto com o WMS SaaS." 
        lRet := .F.
    EndIF

Return lRet

/*---------------------------------------------------------------------------
---WMSA90SUB
---Retorna se produto controla sublote
---equipe WMS 14/10/2024
---------------------------------------------------------------------------*/
Static Function WMSA90SUB(cProduto)
Local lRet := .F.
Local aArea := GetArea()

    lRet := Rastro(cProduto,'S')

RestArea(aArea)

Return lRet
