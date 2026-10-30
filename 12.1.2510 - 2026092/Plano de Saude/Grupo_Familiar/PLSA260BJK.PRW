#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BJK
Funcao para abrir a tela de cadastro da Forma de Cobrança
@author DEV TOTVS
@since 26/07/19
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260BJK(lAutomato)

	Local oBrowse
	Default lAutomato := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BJK' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BJK 
@author  DEV TOTVS
@version P12
@since   26/07/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260BJK 
@author  DEV TOTVS
@version P12
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()	

	Local oModel	
	Local oStruBA3 		:= FWFormStruct(1,'BA3', { |cCampo| AllTrim(cCampo) $ 'BA3_CODINT|BA3_CODEMP|BA3_MATRIC|BA3_FORPAG' } )
	Local oStruBJK 		:= FWFormStruct(1,'BJK', { |cCampo| AllTrim(cCampo) $ 'BJK_FILIAL|BJK_CODFOR|BJK_DESFOR|BJK_AUTOMA|' })	
	Local aCamposBJK	:= {"BJK_CODOPE","BJK_CODEMP","BJK_MATRIC"} // Campos a serem adicionado na estrutura
	local bLinePos := {|oModelGrid, nlinha, cAction| PlDelForCob(oModelGrid, nLinha, cAction)}	
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BJK')
	
	// Cria os campos na estrutura que estão como não usados no dicionario
	oStruBJK := PLAddFldStruct(1,oStruBJK,aCamposBJK, .T.) 
	
	// Adiciona as estruturas no modelo
	oModel:addFields('BA3MASTER' , , oStruBA3) 
	oModel:AddGrid('BJKDETAIL','BA3MASTER',oStruBJK, /* bLinePre */ , /* bLinePost */ , bLinePos, /* bPost */, /* bLoad */)

	oModel:GetModel( "BJKDETAIL" ):SetOptional(.T.)

	oModel:GetModel( 'BA3MASTER' ):SetOnlyQuery(.T.)
    oModel:GetModel( 'BA3MASTER' ):SetOnlyView(.T.)

	// Relacionamento entre as tabelas
	oModel:SetRelation( 'BJKDETAIL', { { 'BJK_FILIAL' 	, 'xFilial( "BJK" )'},;
									{ 'BJK_CODOPE'	, 'BA3_CODINT'       },;
									{ 'BJK_CODEMP'	, 'BA3_CODEMP'       },;
									{ 'BJK_MATRIC'	, 'BA3_MATRIC'       }},;									
									BJK->( IndexKey(  ) ) )  								
	
    oModel:SetDescription( FunDesc() )	

	// Controle de repetição de linha
	oModel:GetModel( 'BJKDETAIL' ):SetUniqueLine( { 'BJK_CODFOR' } ) 
	
	oModel:GetModel('BA3MASTER'):SetDescription('Familia' )
    oModel:GetModel('BJKDETAIL'):SetDescription('Forma de Cobrança' )	
	
	// Chave primaria
	oModel:SetPrimaryKey({"BJK_FILIAL","BJK_CODOPE","BJK_CODEMP","BJK_MATRIC","BJK_CODFOR"})
	
	// Substitui o dicionario da tabela BJK para MVC
	oStruBJK:SetProperty('BJK_CODFOR' , MODEL_FIELD_VALID , { || PlsVldCbMVC("1", "2","BJK_DESFOR",,oModel) })
	oStruBJK:SetProperty('BJK_CODFOR' , MODEL_FIELD_WHEN  , { || PlM260NAlMVC(oModel, "BJK") } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view da aplicação 
@author  DEV TOTVS
@version P12?
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  

	Local oStruBA3 := FWFormStruct(2,'BA3', { |cCampo| AllTrim(cCampo) $ 'BA3_CODINT|BA3_CODEMP|BA3_MATRIC|' } )
	Local oStruBJK := FWFormStruct(2,'BJK', { |cCampo| AllTrim(cCampo) $ 'BJK_CODFOR|BJK_DESFOR|BJK_AUTOMA|' } )	
    Local oModel   := FWLoadModel( 'PLSA260BJK')
	Local oView

	oView := FWFormView():New()
	
	oView:SetModel( oModel )
	
    oView:AddField( 'VIEW_BA3' , oStruBA3, 'BA3MASTER' )
    oView:AddGrid(  'VIEW_BJK' , oStruBJK, 'BJKDETAIL' )

    oStruBA3:SetNoFolder()
   	oStruBJK:SetNoFolder()

	oView:CreateHorizontalBox( 'SUPERIOR', 20) 
	oView:CreateHorizontalBox( 'MEIO'	 , 80) 

	oView:SetOwnerView('VIEW_BA3', 'SUPERIOR')
	oView:SetOwnerView('VIEW_BJK', 'MEIO')	

	oView:AddUserButton("Propriedades"     ,"", {|| PL260FORCOB()  },,,,.T./*lShowBar*/ )
	
	oView:EnableTitleView('VIEW_BA3','Familia')
	oView:EnableTitleView('VIEW_BJK','Forma de Cobrança')
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsIncreMVC
Gera o próximo numero para o campo
@author  DEV TOTVS
@version P12
@since   02/09/19
/*/
//-------------------------------------------------------------------
Function PlsIncreMVC(oModel,cDETAIL,cCampo)

	Local cCodFai   := "000"
	Local nTam	
	Local nNX	
	Local cMaior	:= "000" 

	nTam := TamSX3(cCampo)[1]

	If oModel:GetModel(cDETAIL):nLine == 0
		cCodFai := Padl(Soma1(cCodFai),nTam,'0')
	Else
		// Busco o ultimo codFai digitado
		For nNx := 1 To oModel:GetModel(cDETAIL):Length()
			oModel:GetModel(cDETAIL):GoLine(nNx)
			If !oModel:GetModel(cDETAIL):IsDeleted() // Verifica se a linha esta deletada
				If VAL(oModel:GetValue(cDETAIL,cCampo)) > VAL(cMaior)
						cMaior := oModel:GetValue(cDETAIL,cCampo)
				EndIf
			EndIf
		Next

		cCodFai := PadL(Soma1(cMaior), nTam,'0')	
	EndIf

Return cCodFai

/*/ {Protheus.doc} Pl260FORCOB
 Função para exibir as propriedades da forma de cobrança
@author Gabriela Cattin
@since 05/12/2023
@version 2410
/*/
Function PL260FORCOB()
	Local oModel     := FWModelActive()
	Local nOperation := oModel:GetOperation()
	Local cCodOpe := oModel:GetValue( "BA3MASTER",  'BA3_CODINT')
	Local cCodEmp := oModel:GetValue( "BA3MASTER",  'BA3_CODEMP')
	Local cMatric := oModel:GetValue( "BA3MASTER",  'BA3_MATRIC')
	Local cForCob := oModel:GetValue( "BJKDETAIL",  'BJK_CODFOR')

	BJK->(dbSetOrder(2))
	If BJK->(MsSeek(xFilial('BJK')+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cForCob))
		If cForCob == "108"
			FWExecView('Incluir','PLSA260B1C', nOperation,, { || .T. } )
		Else
			FWExecView('Incluir','PLSA260BBU', nOperation,, { || .T. } )
		EndIf
	Else
		MsgAlert("É Necessário Salvar a Forma de Cobrança Para Visualizar as Propriedades")
	EndIf

Return

/*/ {Protheus.doc} PlDelForCob
 Função para deletar os dados da forma de cobrança
@author Gabriela Cattin
@since 12/12/2023
@version 2410
/*/
Static Function PlDelForCob(oModelGrid, nLinha, cAction)
Local cCodInt := BA3->BA3_CODINT
Local cCodEmp := BA3->BA3_CODEMP
Local cMatric := BA3->BA3_MATRIC
local aAreaBA3 := {}
local oModelBBU := Nil
Local lDelete := .f.
Local lIsHolder := BA1->BA1_TIPUSU == getNewPar("MV_PLCDTIT", "T")
local lSucess := .F.

If cAction == 'DELETE'
	If lIsHolder
		lDelete := MsgYesNo(OemtoAnsi("ATENÇÃO!!! Ao excluir a Forma de Cobrança, automaticamente a Faixa Etária ou Faixa Salárial e o Desconto serão excluidos. Deseja realmente excluir a Forma de Cobrança?"))
	EndIf

	If lDelete
		BJK->(DbSetOrder(1))
		If BJK->(MsSeek(xFilial('BJK')+cCodInt+cCodEmp+cMatric+cCodFor))
			If BJK->BJK_CODFOR == '108'
				B1C->(DbSetOrder(1))
				If B1C->(MsSeek(xFilial('B1C')+cCodInt+cCodEmp+cMatric+BJK->BJK_CODFOR))
					aAreaBA3 := BA3->(getArea())

					oModelB1C := FWLoadModel("PLSA260B1C")
					oModelB1C:setOperation(MODEL_OPERATION_DELETE)
					oModelB1C:activate()

					lSucess := oModelB1C:vldData()
					If lSucess
						oModelB1C:commitData()
					EndIf
						
					freeObj(oModelB1C)
					restArea(aAreaBA3)
				EndIf
			Else
				BBU->(DbSetOrder(1))
				If BBU->(MsSeek(xFilial('BBU')+cCodInt+cCodEmp+cMatric+BJK->BJK_CODFOR))
					oModelBBU := FWLoadModel("PLSA260BBU")
					oModelBBU:setOperation(MODEL_OPERATION_DELETE)
					oModelBBU:activate()

					lSucess := oModelBBU:vldData()
					If lSucess
						oModelBBU:commitData()
					EndIf
				EndIf
				
			EndIf
		EndIf
	EndIf 
EndIf
Return