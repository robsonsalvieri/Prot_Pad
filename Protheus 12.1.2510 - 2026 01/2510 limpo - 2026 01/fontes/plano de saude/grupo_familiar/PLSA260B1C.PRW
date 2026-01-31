#include "protheus.ch"
#include "fwmvcdef.ch"
//-------------------------------------------------------------------
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
	local oStruB1C := fwFormStruct(1, "B1C") as object
    Local aCamposBJK	:= {"BJK_CODOPE","BJK_CODEMP","BJK_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposB1C	:= {"B1C_CODOPE","B1C_CODEMP","B1C_MATRIC"} // Campos a serem adicionado na estrutura

	oModel := MPFormModel():new("PLSA260B1C")
    // Cria os campos na estrutura que estão como não usados no dicionario
	oStruBJK := PLAddFldStruct(1,oStruBJK,aCamposBJK, .T.) 

	oStruB1C := PLAddFldStruct(1,oStruB1C,aCamposB1C, .T.) 


	oModel:addFields("BJKMASTER", , oStruBJK)
	oModel:addGrid("B1CDETAIL", "BJKMASTER", oStruB1C)

	oModel:GetModel( "B1CDETAIL" ):SetOptional(.T.)

	oModel:GetModel( 'BJKMASTER' ):SetOnlyQuery(.T.)
    oModel:GetModel( 'BJKMASTER' ):SetOnlyView(.T.)

	oModel:setRelation("B1CDETAIL", {{"B1C_FILIAL", "xFilial('B1C')"},; 
                                     {"B1C_CODOPE", "BJK_CODOPE"},;
									 {"B1C_CODEMP", "BJK_CODEMP"},;
                                     {"B1C_MATRIC", "BJK_MATRIC"},;
                                     {"B1C_CODFOR", "BJK_CODFOR"}},;
                                     B1C->(indexKey( )))

	oModel:SetDescription( FunDesc() )	

	oModel:GetModel('B1CDETAIL'):SetDescription('Faixa Salárial' )										
		
	oModel:setPrimaryKey({})

	oStruB1C:SetProperty('B1C_CODFOR' , MODEL_FIELD_INIT  , { || oModel:GetValue('BJKMASTER','BJK_CODFOR')})
	oStruB1C:SetProperty('B1C_CODFAI' , MODEL_FIELD_INIT  , { || PlsIncreMVC(oModel,"B1CDETAIL","B1C_CODFAI")})
	oStruB1C:SetProperty('B1C_FAIFAM' , MODEL_FIELD_INIT  , { || If(BJ1->BJ1_FAIFAM == "1", "1", "0") })
    oStruB1C:SetProperty('B1C_VLSLIN' , MODEL_FIELD_VALID , { || PlVerFSMvc('B1C_VLSLIN', 'B1C_VLSLFN', 1, oModel)})
    oStruB1C:SetProperty('B1C_VLSLFN' , MODEL_FIELD_VALID , { || PlVerFSMvc('B1C_VLSLIN', 'B1C_VLSLFN', 2, oModel)})
    oStruB1C:SetProperty('B1C_TIPUSR' , MODEL_FIELD_VALID , { || If(Empty(oModel:GetValue('B1CDETAIL','B1C_TIPUSR')),.T.,ExistCpo("BIH",oModel:GetValue('B1CDETAIL','B1C_TIPUSR'),1))})
	oStruB1C:SetProperty('B1C_GRAUPA' , MODEL_FIELD_VALID , { || If(Empty(oModel:GetValue('B1CDETAIL','B1C_GRAUPA')),.T.,ExistCpo("BRP",oModel:GetValue('B1CDETAIL','B1C_GRAUPA'),1))})		
	oStruB1c:SetProperty('B1C_GRAUPA' , MODEL_FIELD_WHEN  , { || oModel:GetValue('B1CDETAIL', 'B1C_FAIFAM') == '0'})
	oStruB1c:SetProperty('B1C_SEXO'   , MODEL_FIELD_WHEN  , { || oModel:GetValue('B1CDETAIL', 'B1C_FAIFAM') == '0'})
	oStruB1c:SetProperty('B1C_TIPUSR' , MODEL_FIELD_WHEN  , { || oModel:GetValue('B1CDETAIL', 'B1C_FAIFAM') == '0'})

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
	Local oStruB1C := FWFormStruct(2,'B1C') as object
    Local oModel   := FWLoadModel( 'PLSA260B1C') as object

    oView := FWFormView():New()
	
	oView:SetModel( oModel )

    oView:AddField( 'VIEW_BJK' , oStruBJK, 'BJKMASTER' )
    oView:AddGrid(  'VIEW_B1C' , oStruB1C, 'B1CDETAIL' )

   	oStruBJK:SetNoFolder()
	oStruB1C:SetNoFolder()

    //Removo campos que são preenchidos automaticamente da tela
	oStruB1C:RemoveField('B1C_CODFOR')
		
	oView:CreateHorizontalBox( 'SUPERIOR', 20) 
	oView:CreateHorizontalBox( 'MEIO'	 , 80) 

	oView:SetOwnerView('VIEW_BJK', 'SUPERIOR')
	oView:SetOwnerView('VIEW_B1C', 'MEIO')	

	oView:EnableTitleView('VIEW_BJK','Forma de Cobrança')
	oView:EnableTitleView('VIEW_B1C','Faixas Etárias Famílias')
return oView

/*/ {Protheus.doc} PLVERFSMVC
 Função para retorna os dados da forma de cobrança quando for faixa salarial
@author Gabriela Cattin
@since 12/12/2023
@version 2410
/*/
Function PlVerFSMvc(cCampoI, cCampoF, nTipo, oModel)

Local nTmpI := 0
Local nTmpF := 0
Local nContI := 0
Local nContF := 0
Local lAcabou := .F.
Local cChave 

BA3->(DbSetOrder(1))
BA3->(MsSeek(xFilial('BA3')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
cChave := BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_FORPAG)

If nTipo == 1 
	nContI := oModel:GetValue('B1CDETAIL', 'B1C_VLSLIN')
	B1C->(dbSetOrder(1))
	If B1C->(MsSeek(xFilial('B1C')+cChave))
		While !B1C->(EoF()) .And. B1C->(B1C_CODOPE+B1C_CODEMP+B1C_MATRIC+B1C_CODFOR) == cChave
			nTmpI := B1C->B1C_VLSLIN
			nTmpF := B1C->B1C_VLSLFN

			If nTmpI <= nContI .And. nContI <= nTmpF
				lAcabou := .T.
				MsgAlert("O valor do Salário Inicial é inválido")
			EndIf
			B1C->(DbSkip())
		EndDo
	EndIf
Else
	nContI := oModel:GetValue('B1CDETAIL', 'B1C_VLSLIN')
	nContF := oModel:GetValue('B1CDETAIL', 'B1C_VLSLFN')
	If nContF > 0 .And. nContI > nContF 
		lAcabou := .T.
		MsgAlert("O valor do Salário Final é menor que o valor do Salário Inicial")
	EndIf
	If B1C->(MsSeek(xFilial('B1C')+cChave))
		While !B1C->(EoF()) .And. B1C->(B1C_CODOPE+B1C_CODEMP+B1C_MATRIC+B1C_CODFOR) == cChave
			nTmpI := B1C->B1C_VLSLIN
			nTmpF := B1C->B1C_VLSLFN
			If nTmpI <= nContF .And. nContF <= nTmpF
				lAcabou := .T.
				MsgAlert('O valor do Salário Final é inválido')
			EndIf
			B1C->(DbSkip())
		Enddo
	EndIf
EndIf

Return(!lAcabou)