#include "protheus.ch"
#include "fwmvcdef.ch"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSA260.CH"
//--------------------------------------------------------------------plsa260
/*/{Protheus.doc} modelDef
Modelo de dados do folder dados do plano do beneficiário

@type function
@version Protheus 12.1.2310 
@author gabriela.cattin
@since 30/11/2023
@return object, retorna o modelo de dados criado
@obs Para utilizar o modelo de dados é necessário está com o registro da BA1, BA3 posicionado
/*/
static function modelDef()

	local oModel as object
	local oStruBJK := fwFormStruct(1, "BJK", { |cCampo| AllTrim(cCampo) $ 'BJK_FILIAL|BJK_CODFOR|BJK_DESFOR|BJK_AUTOMA|'}) as object
	local oStruBBU := fwFormStruct(1, "BBU") as object
    local oStruBFY := fwFormStruct(1, "BFY") as object
    Local aCamposBJK	:= {"BJK_CODOPE","BJK_CODEMP","BJK_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBBU	:= {"BBU_CODOPE","BBU_CODEMP","BBU_MATRIC"} // Campos a serem adicionado na estrutura
    Local aCamposBFY	:= {"BFY_CODOPE","BFY_CODEMP","BFY_MATRIC"} // Campos a serem adicionado na estrutura

	oModel := MPFormModel():new("PLSA260BBU")
    // Cria os campos na estrutura que estão como não usados no dicionario
	oStruBJK := PLAddFldStruct(1,oStruBJK,aCamposBJK, .T.) 

	oStruBBU := PLAddFldStruct(1,oStruBBU,aCamposBBU, .T.) 

	oStruBFY := PlAddFldStruct(1,oStruBFY,aCamposBFY, .T.) 

	oModel:addFields("BJKMASTER", , oStruBJK)
	oModel:addGrid("BBUDETAIL", "BJKMASTER", oStruBBU)
    oModel:addGrid("BFYDETAIL", "BBUDETAIL", oStruBFY)

	oModel:GetModel( "BBUDETAIL" ):SetOptional(.T.)
	oModel:GetModel( "BFYDETAIL" ):SetOptional(.T.)

	oModel:GetModel( 'BJKMASTER' ):SetOnlyQuery(.T.)
    oModel:GetModel( 'BJKMASTER' ):SetOnlyView(.T.)

	oModel:setRelation("BBUDETAIL", {{"BBU_FILIAL", "xFilial('BBU')"},; 
                                     {"BBU_CODOPE", "BJK_CODOPE"},;
									 {"BBU_CODEMP", "BJK_CODEMP"},;
                                     {"BBU_MATRIC", "BJK_MATRIC"},;
                                     {"BBU_CODFOR", "BJK_CODFOR"}},;
                                     BBU->(indexKey( )))

	oModel:SetRelation( 'BFYDETAIL', { { 'BFY_FILIAL' 	, 'xFilial( "BFY" )'},;
									{ 'BFY_CODOPE'	, 'BBU_CODOPE'       },;
									{ 'BFY_CODEMP'	, 'BBU_CODEMP'       },;
									{ 'BFY_MATRIC'	, 'BBU_MATRIC'       },;
									{ 'BFY_CODFOR'	, 'BBU_CODFOR'       },;
									{ 'BFY_CODFAI'	, 'BBU_CODFAI'} },;
									BFY->( IndexKey(  ) ) ) 

	oModel:SetDescription( FunDesc() )	

	oModel:GetModel('BBUDETAIL'):SetDescription('Faixa Etaria' )	
	oModel:GetModel('BFYDETAIL'):SetDescription('Desconto' )									
		
	oModel:setPrimaryKey({})

	oStruBBU:SetProperty('BBU_TIPUSR' , MODEL_FIELD_VALID , { || If(Empty(oModel:GetValue('BBUDETAIL','BBU_TIPUSR')),.T.,ExistCpo("BIH",oModel:GetValue('BBUDETAIL','BBU_TIPUSR'),1))})
	oStruBBU:SetProperty('BBU_GRAUPA' , MODEL_FIELD_VALID , { || If(Empty(oModel:GetValue('BBUDETAIL','BBU_GRAUPA')),.T.,ExistCpo("BRP",oModel:GetValue('BBUDETAIL','BBU_GRAUPA'),1))})
	oStruBBU:SetProperty('BBU_IDAINI' , MODEL_FIELD_VALID , { || .T.}) // Falta fazer PlVerFai
	oStruBBU:SetProperty('BBU_IDAFIN' , MODEL_FIELD_VALID , { || .T.}) // Falta fazer PlVerFai
	oStruBBU:SetProperty('BBU_QTDMIN' , MODEL_FIELD_VALID , { || .T.}) // Falta fazer PlVerFai
	oStruBBU:SetProperty('BBU_QTDMAX' , MODEL_FIELD_VALID , { || .T.}) // Falta fazer PlVerFai	
	oStruBBU:SetProperty('BBU_CODFOR' , MODEL_FIELD_INIT  , { || oModel:GetValue('BJKMASTER','BJK_CODFOR')})
	oStruBBU:SetProperty('BBU_CODFAI' , MODEL_FIELD_INIT  , { || PlsIncreMVC(oModel,"BBUDETAIL","BBU_CODFAI")})
	oStruBBU:SetProperty('BBU_FAIFAM' , MODEL_FIELD_INIT  , { || If(BJ1->BJ1_FAIFAM == "1", "1", "0") })
	oStruBBU:SetProperty('BBU_TIPUSR' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	oStruBBU:SetProperty('BBU_GRAUPA' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	oStruBBU:SetProperty('BBU_SEXO'   , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	oStruBBU:SetProperty('BBU_IDAINI' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	oStruBBU:SetProperty('BBU_IDAFIN' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	oStruBBU:SetProperty('BBU_FAIFAM' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	oStruBBU:SetProperty('BBU_QTDMIN' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	oStruBBU:SetProperty('BBU_QTDMAX' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	
	
	// Substitui o dicionario da tabela BFY para MVC
	oStruBFY:SetProperty('BFY_CODFOR' , MODEL_FIELD_INIT  , { || oModel:GetValue('BJKMASTER', 'BJK_CODFOR')})
	oStruBFY:SetProperty('BFY_CODFAI' , MODEL_FIELD_INIT  , { || oModel:GetValue('BBUDETAIL','BBU_CODFAI')})
	oStruBFY:SetProperty('BFY_TIPUSR' , MODEL_FIELD_INIT  , { || oModel:GetValue('BBUDETAIL','BBU_TIPUSR')})

	oStruBFY:SetProperty('BFY_GRAUPA' , MODEL_FIELD_INIT  , { || oModel:GetValue('BBUDETAIL','BBU_GRAUPA')})

	oStruBFY:SetProperty('BFY_PERCEN' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BFYDETAIL','BFY_VALOR') == 0})
	oStruBFY:SetProperty('BFY_VALOR'  , MODEL_FIELD_WHEN  , { || oModel:GetValue('BFYDETAIL','BFY_PERCEN') == 0})
	

return oModel

/*/{Protheus.doc} viewDef
Tela de visualização dos dados do plano do beneficiário

@type function
@version Protheus 12.1.2310 
@author gabriela.cattin
@since 30/11/2023
@return object, retorna a tela de visualização do modelo de dados criado
/*/
static function viewDef() 

	Local oView as object
	Local oStruBJK := FWFormStruct(2,'BJK', { |cCampo| AllTrim(cCampo) $ 'BJK_CODFOR|BJK_DESFOR|BJK_AUTOMA|' } ) as object
	Local oStruBBU := FWFormStruct(2,'BBU') as object
    Local oStruBFY := FWFormStruct(2,'BFY') as object
    Local oModel   := FWLoadModel( 'PLSA260BBU') as object

    oView := FWFormView():New()
	
	oView:SetModel( oModel )

    oView:AddField( 'VIEW_BJK' , oStruBJK, 'BJKMASTER' )
    oView:AddGrid(  'VIEW_BBU' , oStruBBU, 'BBUDETAIL' )
	oView:AddGrid(  'VIEW_BFY' , oStruBFY, 'BFYDETAIL' ) 

   	oStruBJK:SetNoFolder()
	oStruBBU:SetNoFolder()
	oStruBFY:SetNoFolder()

    //Removo campos que são preenchidos automaticamente da tela
	oStruBBU:RemoveField('BBU_CODFOR')
	oStruBFY:RemoveField('BFY_CODFOR')
		
	oView:CreateHorizontalBox( 'SUPERIOR', 20) 
	oView:CreateHorizontalBox( 'MEIO'	 , 40) 
	oView:CreateHorizontalBox( 'INFERIOR1', 40)

	oView:SetOwnerView('VIEW_BJK', 'SUPERIOR')
	oView:SetOwnerView('VIEW_BBU', 'MEIO')	
	oView:SetOwnerView('VIEW_BFY', 'INFERIOR1')  

	oView:EnableTitleView('VIEW_BJK','Forma de Cobrança')
	oView:EnableTitleView('VIEW_BBU','Faixas Etárias Famílias')
	oView:EnableTitleView('VIEW_BFY','Forma para Família de Desconto')  
return oView
