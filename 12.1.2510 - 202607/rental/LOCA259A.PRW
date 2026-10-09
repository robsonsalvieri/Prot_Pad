#Include "loca259a.ch"
#Include "TOTVS.CH"
#include "FWMVCDEF.CH"


/*/{Protheus.doc} MODELDEF
Definicão do modelo de Capa da demanda
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo de Cabeçalho de Demanda
/*/
STATIC FUNCTION MODELDEF()
Local oStruFQT := FWFormStruct( 1, 'FQT', /*bAvalCampo*/,/*lViewUsado*/ )

oModel := MPFormModel():New( 'LOCA259A', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New( 'COMP012MODEL', /*bPreValidacao*/, { | oMdl | COMP012POS( oMdl ) } , /*bCommit*/, /*bCancel*/ )

oStruFQT:AddTrigger( "FQT_PROJET" , "FQT_PROJET"  , {|| .T. }  , {|| LOCA259TGA() } )
oStruFQT:AddTrigger( "FQT_OBRA"   , "FQT_OBRA"	  , {|| .T. }  , {|| LOCA259TGB() } )
// Tirar a validação conforme o dicionario for liberado
oSTruFQT:SetProperty("FQT_PRAZOH",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'Vazio() .or. AtVldHora(M->FQT_PRAZOH)'))
oSTruFQT:SetProperty("FQT_PROJET",MODEL_FIELD_WHEN, {|| Empty(M->FQT_PROJET) .or. !FwIsInCallStack("Loca259DGD") } )
oSTruFQT:SetProperty("FQT_OBRA",MODEL_FIELD_WHEN, {|| Empty( M->FQT_OBRA) .or. !FwIsInCallStack("Loca259DGD") } )


// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FQTMASTER', /*cOwner*/, oStruFQT, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0002 ) //'Gestão de Demandas'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FQTMASTER' ):SetDescription( STR0001 ) //'Demanda'
oModel:SetPrimaryKey({"FQT_FILIAL","FQT_DEMAND"})
// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActive( { | oModel | COMP012ACT( oModel ) }
oModel:AddRules('FQTMASTER', "FQT_OBRA", 'FQTMASTER', "FQT_PROJET", 3)

Return oModel


/*/{Protheus.doc} ViewDef
Define a View da Demanda
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Retorna a view da demanda
/*///-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOCA259A' )
Local oStruFQT := FWFormStruct( 2, 'FQT', /*bAvalCampo*/,/*lViewUsado*/ )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQT', oStruFQT, 'FQTMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FQT', 'TELA' )

Return oView

/*/{Protheus.doc} LOCA259TGA
Gatilho do campo FQT_PROJETO
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, retorna .t.
/*/
Static function LOCA259TGA()
Local aArea := GetArea()
LOcal lRet  := .T.
Local oModel   := FWModelActive()
Local oModelFQT:= oModel:GetModel("FQTMASTER")

dbSelectArea("FP0")
dbSetOrder(1)
dbSeek(xFilial("FP0")+oModelFQT:GetValue("FQT_PROJET"))
oModelFQT:LoadValue("FQT_CLIPRO", FP0->FP0_CLI)
oModelFQT:LoadValue("FQT_LOJPRO", FP0->FP0_LOJA)
oModelFQT:LoadValue("FQT_NOMPRO", FP0->FP0_CLINOM)
RestArea(aArea)
return lRet

/*/{Protheus.doc} LOCA259TGB
Gatilho do campo FQT_OBRA
@type function
@version 24.10
@author Alexandre Circenis
@since 2/12/2025
@return variant, return_true
/*/
Static function LOCA259TGB()
Local aArea := GetArea()
LOcal lRet := .T.
Local oModel   := FWModelActive()
Local oModelFQT:= oModel:GetModel("FQTMASTER")

dbSelectArea("FP1")
dbSetOrder(1)
dbSeek(xFilial("FP1")+oModelFQT:GetValue("FQT_PROJET")+oModelFQT:GetValue("FQT_OBRA"))
oModelFQT:LoadValue("FQT_CLIOBR", FP1->FP1_CLIORI)
oModelFQT:LoadValue("FQT_LOJOBR", FP1->FP1_LOJORI)
oModelFQT:LoadValue("FQT_NOMOBR", FP1->FP1_NOMORI)
RestArea(aArea)
return lRet

/*/{Protheus.doc} Loca259AVP
Valida o projeto informado na demanda
@type function
@version 24.10
@author Alexandre Circenis
@since 3/6/2025
@return variant, .T. se o projeto for valido 
/*/
Function Loca259AVP()
Local lRet := .T.
Local oModel   := FWModelActive()

if !(Posicione("FP0",1,xFilial("FP0")+M->FQT_PROJET,"FP0_STATUS") $ "15" )
   	oModel:SetErrorMessage("","","","","LOCA259A_02",STR0003,) //"Contrato tem que estar ativo para gerar demanda."
	lRet := .F.
elseif EMPTY(ALLTRIM(GETADVFVAL("FQ5", "FQ5_SOT",XFILIAL("FQ5") + M->FQT_PROJET,08,"")))
	oModel:SetErrorMessage("","","","","LOCA259A_01",STR0004,) //"Contrato não possui A.S. geradas."
	lRet := .F.
endif

Return lRet
