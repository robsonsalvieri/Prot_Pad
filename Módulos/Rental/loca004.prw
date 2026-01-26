#INCLUDE "loca004.ch" 
#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDEF.ch' 

#DEFINE PULALINHA Chr(13) + Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA004
@description	"Cadastro de usuários analisadores de promoções"
@author			José Eulálio
@since     		06/10/2022
/*/			
//-------------------------------------------------------------------

function LOCA004()
Local oBrowse 

aRotina := MenuDef() 
oBrowse := FWMBrowse():New()  
oBrowse:SetAlias('FQ1')  
oBrowse:SetDescription(STR0001) // "Cadastro de usuários analisadores de promoções"

oBrowse:Activate() 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@description	Definição do Menu
@author			José Eulálio
@since     		06/10/2022
/*/			
//-------------------------------------------------------------------
Static Function MenuDef() 
Local aRotina := {} 

ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.LOCA004' OPERATION 2 ACCESS 0  // 'Visualizar'
ADD OPTION aRotina TITLE STR0003 	ACTION 'VIEWDEF.LOCA004' OPERATION 3 ACCESS 0 // 'Incluir'
ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.LOCA004' OPERATION 4 ACCESS 0 //'Alterar' 
ADD OPTION aRotina TITLE STR0005   	ACTION 'VIEWDEF.LOCA004' OPERATION 8 ACCESS 0 // 'Imprimir'
 
Return aRotina	

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description	Definição do Modelo de Dados
@author			José Eulálio
@since     		06/10/2022
/*/			
//-------------------------------------------------------------------
Static Function ModelDef()
Local aFQ1Rel	:= {}
Local oModel 
Local oStruFQ1Cb := FWFormStruct(1,"FQ1",{ |cCampo|  ALLTRIM(cCampo) $ 'FQ1_FILIAL|FQ1_CODUSR|FQ1_NOME' } ) 
//Local oStruFQ1It := FWFormStruct(1,"FQ1",{ |cCampo| !ALLTRIM(cCampo) $ 'FQ1_FILIAL|FQ1_CODUSR|FQ1_NOME' } ) 
Local oStruFQ1It := FWFormStruct(1,"FQ1" ) 
Local aGatPor	:= {}

//Estancia array com estrutura para os gatilhos
aGatPor := FwStruTrigger( 	"FQ1_CODUSR"        ,; 		// Campo Dominio        
							"FQ1_NOME"          ,; 		// Campo de Contradominio        
							"LOCA00404()") // Regra de Preenchimento

oStruFQ1Cb:AddTrigger(	aGatPor[1]  , ;    // [01] Id do campo de origem   
						aGatPor[2]  , ;    // [02] Id do campo de destino   
						aGatPor[3]  , ;    // [03] Bloco de codigo de validação da execução do gatilho   
						aGatPor[4]  )      // [04] Bloco de codigo de execução do gatilho

//Instancia Modelo
oModel := MPFormModel():New("MDCAD49")  

oModel:SetDescription(STR0001)    
oModel:addFields('MASTERFQ1',,oStruFQ1Cb)
oModel:AddGrid('DETAILFQ1','MASTERFQ1',oStruFQ1It, NIL, NIL)

oStruFQ1Cb:SetProperty( 'FQ1_CODUSR', MODEL_FIELD_VALID   	, FWBuildFeature( STRUCT_FEATURE_VALID  , 'LOCA00402()' ) )
oStruFQ1Cb:SetProperty( 'FQ1_CODUSR', MODEL_FIELD_WHEN    	, FWBuildFeature( STRUCT_FEATURE_WHEN   , 'LOCA00403()' ) )
oStruFQ1It:SetProperty( 'FQ1_CODUSR', MODEL_FIELD_INIT		, FWBuildFeature( STRUCT_FEATURE_INIPAD	, 'LOCA00405()' ) )

aAdd(aFQ1Rel, {'FQ1_FILIAL'		, 'xFilial("FQ1")' } )
aAdd(aFQ1Rel, {'FQ1_CODUSR'		, 'FQ1_CODUSR' } )
 
//Criando o relacionamento
oModel:SetRelation('DETAILFQ1', aFQ1Rel, FQ1->(IndexKey(1)))
      
oModel:SetPrimaryKey({"FQ1_FILIAL","FQ1_CODUSR"}) 
oModel:SetDescription(STR0001)

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description	Definição da Visualização da Interface
@author			José Eulálio
@since     		06/10/2022
/*/			
//------------------------------------------------------------------- 
Static Function ViewDef() 
Local oView 
Local oModel 		:= ModelDef() 
Local oStrFQ1Tot	:= FWFormStruct(2, 'FQ1', { |cCampo|  ALLTRIM(cCampo) $ 'FQ1_FILIAL|FQ1_CODUSR|FQ1_NOME' })
Local oStrFQ1Ite	:= FWFormStruct(2, 'FQ1', { |cCampo| !ALLTRIM(cCampo) $ 'FQ1_FILIAL|FQ1_CODUSR|FQ1_NOME' })
 
oView := FWFormView():New()  

oView:SetModel(oModel)    
oView:AddGrid('FORM_ITE'  , oStrFQ1Ite,'DETAILFQ1' )
oView:AddField('FORM_TOT' , oStrFQ1Tot,'MASTERFQ1' )  

oView:CreateHorizontalBox( 'BOX_FORM_TOT', 15) 
oView:CreateHorizontalBox( 'BOX_FORM_ITE', 85) 
 
oView:SetOwnerView('FORM_TOT','BOX_FORM_TOT')
oView:SetOwnerView('FORM_ITE','BOX_FORM_ITE')

Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA00402
@description	valid do campo FQ1_CODUSR
@author			José Eulálio
@since     		06/10/2022
/*/			
//-------------------------------------------------------------------
Function LOCA00402()
Local lRet      := .T.
Local oModel    := FwModelActive()
Local nOperAtu  := oModel:GetOperation()

//se localizar o usuário deverá entrar como alteração
If nOperAtu == MODEL_OPERATION_INSERT
    If lRet := UsrExist(FwFldGet("FQ1_CODUSR"))                                                                                                         
        If FQ1->(DbSeek(xFilial("FQ1") + FwFldGet("FQ1_CODUSR"))) 
            lRet  := .F.
            Help(NIL, NIL, "LOCA00402_01", NIL, STR0006, 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0007}) // "Já incluído" ####  "O usuário selecionado já foi incluído."
        EndIf
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA00403
@description	When o campo FQ1_CODUSR no cabeçalho
@author			José Eulálio
@since     		06/10/2022
/*/			
//-------------------------------------------------------------------
Function LOCA00403()
Local lRet      := .T.
Local oModel    := FwModelActive()
Local nOperAtu  := oModel:GetOperation()

If nOperAtu <> MODEL_OPERATION_INSERT
    lRet  := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA00404
@description	Gatilho do campo o campo FQ1_CODUSR
@author			José Eulálio
@since     		06/10/2022
/*/			
//-------------------------------------------------------------------
Function LOCA00404()
Local oModel    := FwModelActive()
Local oModFQ1M	:= oModel:GetModel("MASTERFQ1")
Local oModFQ1D	:= oModel:GetModel("DETAILFQ1")
Local cRet 		:= UsrRetName(oModFQ1M:GetValue("FQ1_CODUSR"))
Local nX		:= 0

//Roda Grid para atualizar com o mesmo usuário
For nX := 1 To oModFQ1D:Length()
	oModFQ1D:GoLine(nX)
	If !(oModFQ1D:IsDeleted())
		oModFQ1D:LoadValue("FQ1_CODUSR",oModFQ1M:GetValue("FQ1_CODUSR")	)
	EndIf
Next nX

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA00405
@description	Inicializador padrão campo o campo FQ1_CODUSR na Grid
@author			José Eulálio
@since     		06/10/2022
/*/			
//------------------------------------------------------------------- 
Function LOCA00405()
Local oModel    := FwModelActive()
Local oModFQ1M	:= oModel:GetModel("MASTERFQ1")
Local cRet 		:= oModFQ1M:GetValue("FQ1_CODUSR")	

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA004CC
@description	Retorna lista de Centros de Custo por usuário x Rotina
@author			José Eulálio
@since     		06/10/2022
/*/			
//-------------------------------------------------------------------
Function LOCA004CC(cUserRef,cRotRef)
Local cRet		:= ""
Local cChave	:= ""

FQ1->(dbSetOrder(1)) //FQ1_FILIAL+FQ1_CODUSR+FQ1_NOMPRO
If FQ1->(dbSeek(xFilial("FQ1") + cUserRef + cRotRef))
	cChave := FQ1->(FQ1_FILIAL+FQ1_CODUSR+FQ1_NOMPRO)
	While !(FQ1->(EoF())) .And. cChave == FQ1->(FQ1_FILIAL+FQ1_CODUSR+FQ1_NOMPRO)
		If !Empty(cRet)
			cRet += ";"
		EndIf
		cRet += AllTrim(FQ1->FQ1_CC)
		FQ1->(DbSkip())
	EndDo
EndIf
Return cRet
