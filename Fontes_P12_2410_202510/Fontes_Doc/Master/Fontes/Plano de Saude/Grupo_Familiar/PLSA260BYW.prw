#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do folder dados do plano do beneficiário
@author Jullia Barros
@version 12.1.2310
@since 05/2024  
/*/
//-------------------------------------------------------------------
Static Function ModelDef()	

	Local oModel as object	
	Local oStruBA1 		:= FWFormStruct(1,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_TIPREG' }) as object
	Local oStruBYW 		:= FWFormStruct(1,'BYW') as object
	Local aCamposBYW	:= {"BYW_FILIAL"} // Campos a serem adicionado na estrutura
    Local aCamposBA1    := {'BA1_CODINT','BA1_CODEMP','BA1_MATRIC'}
    Default lAutoma := .F.

    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BYW')

	// Cria os campos na estrutura que estão como não usados no dicionario
	oStruBYW:= PLAddFldStruct(1,oStruBYW,aCamposBYW, .T.) 
	oStruBA1:= PLAddFldStruct(1,oStruBA1,aCamposBA1, .T.) 

	// Adiciona as estruturas no modelo
	oModel:addFields('BA1MASTER' , , oStruBA1) 
	oModel:AddGrid('BYWDETAIL','BA1MASTER',oStruBYW)

	oModel:GetModel( "BYWDETAIL" ):SetOptional(.T.)

	oModel:GetModel( 'BA1MASTER' ):SetOnlyQuery(.T.)
    oModel:GetModel( 'BA1MASTER' ):SetOnlyView(.T.)

	// Relacionamento entre as tabelas
	oModel:SetRelation( 'BYWDETAIL', { { 'BYW_FILIAL' 	, 'xFilial( "BYW" )'},;
									{ 'BYW_CODINT'	, 'BA1_CODINT'       },;
									{ 'BYW_CODEMP'	, 'BA1_CODEMP'       },;
									{ 'BYW_MATRIC'	, 'BA1_MATRIC'       },;	
                                    { 'BYW_TIPREG'	, 'BA1_TIPREG'       }},;								
									BYW->( IndexKey(1) ) )  								
	
    oModel:SetDescription( Fundesc())	

	// Controle de repetição de linha
	oModel:GetModel( 'BYWDETAIL' ):SetUniqueLine( { 'BYW_CODINT', 'BYW_CODEMP', 'BYW_MATRIC', 'BYW_TIPREG' } ) 
	
	oModel:GetModel('BA1MASTER'):SetDescription('Beneficiários' )
    oModel:GetModel('BYWDETAIL'):SetDescription('Cancelamento de Reajuste' )	
	
	// Chave primaria
	oModel:SetPrimaryKey({"BYW_FILIAL","BYW_CODINT","BYW_CODEMP","BYW_MATRIC", "BYW_TIPREG", "BYW_DATINI"})
	
	// Substitui o dicionario da tabela BYW para MVC
    oStruBYW:SetProperty('BYW_DATINC' , MODEL_FIELD_VALID  , { || oModel:GetValue('BYWDETAIL', 'BYW_DATINC') >= Date() })
    oStruBYW:SetProperty('BYW_DATFIN' , MODEL_FIELD_VALID  , { || oModel:GetValue('BYWDETAIL', 'BYW_DATFIN') >= oModel:GetValue('BYWDETAIL', 'BYW_DATINI') })
    oStruBYW:SetProperty('BYW_DATINI' , MODEL_FIELD_VALID  , { || oModel:GetValue('BYWDETAIL', 'BYW_DATINI') >= Date() .and. PLVLBYWMVC() })
	oStruBYW:SetProperty('BYW_TIPREG' , MODEL_FIELD_INIT   , { || BA1->BA1_TIPREG })
	oStruBYW:SetProperty('BYW_DATINC' , MODEL_FIELD_INIT   , { || Date() })

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view da aplicação 
@author Jullia Barros
@version 12.1.2310
@since 05/2024
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  

	Local oView	as object
	Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_TIPREG' } ) as object
	Local oStruBYW := FWFormStruct(2,'BYW')	as object
    Local oModel   := FWLoadModel( 'PLSA260BYW') as object
    Local aCamposBA1    := {'BA1_CODINT','BA1_CODEMP','BA1_MATRIC'}


	oView := FWFormView():New()
	
	oView:SetModel( oModel )
	
    oView:AddField( 'VIEW_BA1' , oStruBA1, 'BA1MASTER' )
    oView:AddGrid(  'VIEW_BYW' , oStruBYW, 'BYWDETAIL' )
    
    oStruBA1:= PLAddFldStruct(2,oStruBA1,aCamposBA1, .T.) 
    oStruBA1:SetNoFolder()
   	oStruBYW:SetNoFolder()

	oView:CreateHorizontalBox( 'SUPERIOR', 20) 
	oView:CreateHorizontalBox( 'MEIO'	 , 80) 

	oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
	oView:SetOwnerView('VIEW_BYW', 'MEIO')	

	
	oView:EnableTitleView('VIEW_BA1','Beneficiários')
	oView:EnableTitleView('VIEW_BYW','Cancelamento de Reajuste')
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVLBYWMVC
Verifica se os campos BYW_DATINI e BYW_DATFIN estão preenchidos
@author Jullia Barros
@version 12.1.2310
@since 05/2024
/*/
//-------------------------------------------------------------------

Function PLVLBYWMVC()

Local oModel    := FWModelActive()
Local lRet      := .T.
Local cDatDe    := oModel:GetValue('BYWDETAIL', 'BYW_DATINI')
Local cDatAte   := oModel:GetValue('BYWDETAIL', 'BYW_DATFIN')

Default lAutoma := .F.

If !Empty(cDatDe) .Or. !Empty(cDatAte)
    lRet := PLSVLDVIGMvc("BYW", oModel)
Endif

if !lAutoma 

	If lRet
		If MsgYesNo("O Cancelamento do Reajuste será contemplado para o período de competência informado na vigência cadastrada entre a Data Inicial e Data Final. Deseja confirmar? ")
			lRet := .T.
		else
			lRet := .F.
		Endif
	Endif
else
	lRet := .T.
endif

Return lRet
