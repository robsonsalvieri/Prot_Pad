#include "protheus.ch"
#include "fwmvcdef.ch"
#include "pls260bf1mvc.ch"

#define K_OK 1
#define K_CANCEL 2

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS260BF1MVC
Funcao para abrir a tela de cadastro de Opcionais da Familia
@author DEV TOTVS.
@since 05/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PLS260BF1MVC(lAutomato)
Local oBrowse
Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLS260BF1MVC' )
	If(!lAutomato,oBrowse:Activate(),)

Return (Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLS260BF1MVC 
@author DEV TOTVS
@version P12
@since   05/04/2020
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260BH5 
@author DEV TOTVS
@version P12
@since   16/08/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA3		:= FWFormStruct(1,'BA3', { |cCampo| AllTrim(cCampo) $ 'BA3_CODINT|BA3_CODEMP|BA3_MATRIC|' } )
	Local oStruBF1 		:= FWFormStruct(1,'BF1')	
    Local oStruBK0		:= FWFormStruct(1,'BK0')	
    Local oStruBBY 		:= FWFormStruct(1,'BBY')	
    Local oStruBG0 		:= FWFormStruct(1,'BG0')	
    Local cVerOpc  		:= BF1->BF1_VERSAO
	Local cCodOpc  		:= BF1->BF1_CODPRO
	Local aCamposBF1	:= {"BF1_CODINT","BF1_CODEMP","BF1_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBK0	:= {"BK0_CODOPE","BK0_CODEMP","BK0_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBBY	:= {"BBY_CODOPE","BBY_CODEMP","BBY_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBG0	:= {"BG0_CODOPE","BG0_CODEMP","BG0_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx
    Local oEvent		:= Nil   
	
	BI3->(DbSetOrder(1))
	BI3->(DbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CODPLA)	))
	
	oEvent := PL260BF1EVDEF():New()	
	oModel := MPFormModel():New('PLS260BF1MVC')

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBF1)
		oStruBF1 := CriaCampMVC(1,oStruBF1,aCamposBF1[nNx]) 
	Next

	For nNx := 1 To Len(aCamposBK0)
		oStruBK0 := CriaCampMVC(1,oStruBK0,aCamposBK0[nNx]) 
	Next

	For nNx := 1 To Len(aCamposBBY)
		oStruBBY := CriaCampMVC(1,oStruBBY,aCamposBBY[nNx]) 
	Next

	For nNx := 1 To Len(aCamposBG0)
		oStruBG0 := CriaCampMVC(1,oStruBG0,aCamposBG0[nNx]) 
	Next
    
	oModel:addFields('BA3MASTER' , ,oStruBA3) 
   	oModel:AddGrid('BF1DETAIL' , 'BA3MASTER', oStruBF1 )
    oModel:AddGrid('BK0DETAIL' , 'BF1DETAIL', oStruBK0 )
    oModel:AddGrid('BBYDETAIL' , 'BK0DETAIL', oStruBBY )
    oModel:AddGrid('BG0DETAIL' , 'BBYDETAIL', oStruBG0 )

	oModel:GetModel('BF1DETAIL'):SetOptional(.T.)
	oModel:GetModel('BK0DETAIL'):SetOptional(.T.)
	oModel:GetModel('BBYDETAIL'):SetOptional(.T.)
	oModel:GetModel('BG0DETAIL'):SetOptional(.T.)

	oModel:SetRelation( 'BF1DETAIL', { { 'BF1_FILIAL' , 'xFilial( "BF1" )' },;
									{ 'BF1_CODINT'	  , 'BA3_CODINT'       },;
									{ 'BF1_CODEMP'	  , 'BA3_CODEMP'       },;
									{ 'BF1_MATRIC'	  , 'BA3_MATRIC'       } },;
									BF1->( IndexKey(1) ) ) 

	oModel:SetRelation( 'BK0DETAIL', { { 'BK0_FILIAL', 'xFilial( "BK0" )' },;
									{ 'BK0_CODOPE'	 , 'BF1_CODINT'       },;
									{ 'BK0_CODEMP'	 , 'BF1_CODEMP'       },;
									{ 'BK0_MATRIC'	 , 'BF1_MATRIC'       },;
									{ 'BK0_CODOPC'	 , 'BF1_CODPRO'       },;
									{ 'BK0_VEROPC'	 , 'BF1_VERSAO'       } },;																	
									BK0->( IndexKey(1) ) )  

	oModel:SetRelation( 'BBYDETAIL', { { 'BBY_FILIAL', 'xFilial( "BBY" )' },;
									{ 'BBY_CODOPE'	 , 'BK0_CODOPE'       },;
									{ 'BBY_CODEMP'	 , 'BK0_CODEMP'       },;
									{ 'BBY_MATRIC'	 , 'BK0_MATRIC'       },;
									{ 'BBY_CODOPC'	 , 'BK0_CODOPC'       },;
									{ 'BBY_VEROPC'	 , 'BK0_VEROPC'       },;
									{ 'BBY_CODFOR'	 , 'BK0_CODFOR'       } },;
									BBY->( IndexKey(1) ) )
    
    oModel:SetRelation( 'BG0DETAIL', { { 'BG0_FILIAL', 'xFilial( "BG0" )' },;
									{ 'BG0_CODOPE'	 , 'BBY_CODOPE'       },;
									{ 'BG0_CODEMP'	 , 'BBY_CODEMP'       },;
									{ 'BG0_MATRIC'	 , 'BBY_MATRIC'       },;
									{ 'BG0_CODOPC'	 , 'BBY_CODOPC'       },;
									{ 'BG0_VEROPC'	 , 'BBY_VEROPC'       },;
									{ 'BG0_CODFOR'	 , 'BBY_CODFOR'       } },;									
									BG0->( IndexKey(1) ) )                                    
	
    oModel:SetDescription("Dados cadastrais da família - Opcionais")	
	
	oModel:GetModel( 'BA3MASTER' ):SetDescription( 'Familia' )
    oModel:GetModel( 'BF1DETAIL' ):SetDescription( 'Opcionais da Familia' )	
    oModel:GetModel( 'BK0DETAIL' ):SetDescription( 'Forma de Cobrança do opcional' )	
    oModel:GetModel( 'BBYDETAIL' ):SetDescription( 'Faixa Etárias Famílias' )	
    oModel:GetModel( 'BG0DETAIL' ):SetDescription( 'Descontos Família Opcional' )	

	oModel:GetModel( 'BA3MASTER' ):SetOnlyQuery(.T.)
    oModel:GetModel( 'BA3MASTER' ):SetOnlyView(.T.)	
	    
	oModel:SetPrimaryKey({})
	
	oStruBF1:setProperty( 'BF1_CODINT', MODEL_FIELD_INIT , { || BA3->BA3_CODINT } )
	oStruBF1:setProperty( 'BF1_CODEMP', MODEL_FIELD_INIT , { || BA3->BA3_CODEMP } )
	oStruBF1:setProperty( 'BF1_MATRIC', MODEL_FIELD_INIT , { || BA3->BA3_MATRIC } )
	oStruBF1:setProperty( 'BF1_CODPRO', MODEL_FIELD_VALID, { || PL260ValMVC('BF1_CODPRO',oModel,,oModel:GetModel('BF1DETAIL'):GetValue('BF1_CODPRO'))} )
	oStruBF1:setProperty( 'BF1_DATBAS', MODEL_FIELD_VALID, { || PLChkOpcMvc(1, oModel)} )
	oStruBF1:setProperty( 'BF1_MOTBLO', MODEL_FIELD_VALID, { || ExistCpo("BG1",oModel:GetModel('BF1DETAIL'):GetValue('BF1_MOTBLO'),1) .And. PLSBLOAUT(oModel:GetModel('BF1DETAIL'):GetValue('BF1_MOTBLO'),2) } )
	oStruBF1:setProperty( 'BF1_MOTBLO', MODEL_FIELD_WHEN , {|| .T. } )
	oStruBF1:setProperty( 'BF1_DATBLO', MODEL_FIELD_WHEN , {|| .T. } )                                     
	
	oStruBK0:setProperty( 'BK0_CODOPC', MODEL_FIELD_INIT, { || cCodOpc } )
	oStruBK0:setProperty( 'BK0_VEROPC', MODEL_FIELD_INIT, { || cVerOpc} )
	oStruBK0:setProperty( 'BK0_CODOPE', MODEL_FIELD_INIT, { || BA3->BA3_CODINT} )
	oStruBK0:setProperty( 'BK0_CODEMP', MODEL_FIELD_INIT, { || BA3->BA3_CODEMPT} )
	oStruBK0:setProperty( 'BK0_CODFOR', MODEL_FIELD_WHEN , {|| .T. } )
	oStruBK0:SetProperty( 'BK0_CODFOR', MODEL_FIELD_VALID , { || PlsVldCbMVC("3", "3","BK0_CODFOR",,oModel)  })
		
	oStruBBY:setProperty( 'BBY_CODOPE', MODEL_FIELD_INIT , { || BA3->BA3_CODINT } )
	oStruBBY:setProperty( 'BBY_CODEMP', MODEL_FIELD_INIT , { || BA3->BA3_CODEMP } )
	oStruBBY:setProperty( 'BBY_MATRIC', MODEL_FIELD_INIT , { || BA3->BA3_MATRIC } )
	oStruBBY:setProperty( 'BBY_CODOPC', MODEL_FIELD_INIT, { || oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODPRO")} )
	oStruBBY:setProperty( 'BBY_VEROPC', MODEL_FIELD_INIT, { || oModel:GetModel("BF1DETAIL"):GetValue("BF1_VERSAO")} )
	oStruBBY:setProperty( 'BBY_CODFOR', MODEL_FIELD_INIT, { || oModel:GetModel("BK0DETAIL"):GetValue("BK0_CODOPC")} )
	oStruBBY:setProperty( 'BBY_IDAINI', MODEL_FIELD_VALID, { || .T.} )
	oStruBBY:setProperty( 'BBY_IDAFIN', MODEL_FIELD_VALID, { || .T.} )
	oStruBBY:setProperty(  '*' ,MODEL_FIELD_WHEN, {|| .T. }  )
	oStruBBY:setProperty( 'BBY_VLSLFN', MODEL_FIELD_VALID, { || PL260BF1Valid(oModel)} )
	oStruBBY:setProperty( 'BBY_TIPUSR', MODEL_FIELD_VALID, { || PL260BF1Valid(oModel)} )
	oStruBBY:setProperty( 'BBY_GRAUPA', MODEL_FIELD_VALID, { || PL260BF1Valid(oModel)} )
	oStruBBY:setProperty( 'BBY_IDAFIN', MODEL_FIELD_VALID, { || PL260BF1Valid(oModel)} )
	oStruBBY:setProperty( 'BBY_VALFAI', MODEL_FIELD_VALID, { || PL260BF1Valid(oModel)} )

	oStruBG0:setProperty( 'BG0_CODOPC', MODEL_FIELD_INIT, { || oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODPRO")} )
	oStruBG0:setProperty( 'BG0_VEROPC', MODEL_FIELD_INIT, { || oModel:GetModel("BF1DETAIL"):GetValue("BF1_VERSAO")} )
	oStruBG0:setProperty( 'BG0_CODFOR', MODEL_FIELD_INIT, { || oModel:GetModel("BBYDETAIL"):GetValue("BBY_CODFOR")} )
	oStruBG0:setProperty(  '*' ,MODEL_FIELD_WHEN, {|| .T. }  )
		
    //Instala o evento padrão do programa.
	oModel:InstallEvent("PL260BF1EVDEF",/*cOwner*/,oEvent)
		
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view da aplicação 
@author DEV TOTVS
@version P2
@since   16/08/19
/*/
//-------------------------------------------------------------------
Static Function ViewDef()     

    Local oStruBA3 := FWFormStruct(2,'BA3', { |cField| AllTrim(cField) $ 'BA3_CODINT|BA3_CODEMP|BA3_MATRIC|' } )
	Local oStruBF1 := FWFormStruct(2,'BF1')	
    Local oStruBK0 := FWFormStruct(2,'BK0')	
    Local oStruBBY := FWFormStruct(2,'BBY')	
    Local oStruBG0 := FWFormStruct(2,'BG0')	
	Local oModel := FWLoadModel( 'PLS260BF1MVC' )
	Local oView := nil
	
	oView := FWFormView():New()

	oStruBK0:RemoveField( 'BK0_CODOPC' )
	oStruBK0:RemoveField( 'BK0_VEROPC' )


	oStruBBY:RemoveField( 'BBY_CODOPC' )
	oStruBBY:RemoveField( 'BBY_VEROPC' )
	oStruBBY:RemoveField( 'BBY_CODFOR' )
	
	oStruBG0:RemoveField( 'BG0_CODOPC' )
	oStruBG0:RemoveField( 'BG0_VEROPC' )
	oStruBG0:RemoveField( 'BG0_CODFOR' )


	oView:SetModel( oModel )

	oView:addField('VIEW_BA3', oStruBA3, 'BA3MASTER') 
   	oView:AddGrid('VIEW_BF1', oStruBF1, 'BF1DETAIL' )
    oView:AddGrid('VIEW_BK0', oStruBK0, 'BK0DETAIL' )
    oView:AddGrid('VIEW_BBY', oStruBBY, 'BBYDETAIL' )
    oView:AddGrid('VIEW_BG0', oStruBG0, 'BG0DETAIL' )

    oStruBA3:SetNoFolder()
    oStruBF1:SetNoFolder()
   	oStruBK0:SetNoFolder()
	oStruBBY:SetNoFolder()
	oStruBG0:SetNoFolder()

   	oView:CreateHorizontalBox( 'SUPERIOR', 20) 
	oView:CreateHorizontalBox( 'MEIO'	 , 25) 
	oView:CreateHorizontalBox( 'INFERIOR', 20)
    oView:CreateHorizontalBox( 'RODAPE'  , 35)

    oView:CreateFolder( 'ABA', 'RODAPE' ) //Cria estrutura de abas

    oView:CreateHorizontalBox( 'A', 100,,, 'ABA', 'T1'  ) 
    oView:CreateHorizontalBox( 'B', 100,,, 'ABA', 'T2'  ) 

    oView:AddSheet( 'ABA', 'T1', '' ) 
    oView:AddSheet( 'ABA', 'T2', '' ) 

    oView:SetOwnerView('VIEW_BA3', 'SUPERIOR')
    oView:SetOwnerView('VIEW_BF1' , 'MEIO')
    oView:SetOwnerView('VIEW_BK0' , 'INFERIOR')
    oView:SetOwnerView('VIEW_BBY' , 'A') 
	oView:SetOwnerView('VIEW_BG0' , 'B') 

	oView:EnableTitleView('VIEW_BA3', STR0001) // 'Familia'
	oView:EnableTitleView('VIEW_BF1', STR0002) // 'Opcionais da Familia'
	oView:EnableTitleView('VIEW_BK0', STR0003) // 'Forma de Cobrança do opcional'
	oView:EnableTitleView('VIEW_BBY', STR0004) // 'Faixa Etárias Famílias'
	oView:EnableTitleView('VIEW_BG0', STR0005) // 'Descontos Família Opcional'

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Atualiza inicializadores da tabela BK0 
@author DEV TOTVS
@version P2
@since   05/04/2020
/*/
//-------------------------------------------------------------------

Function PL260BF1Valid(oModel)

oModel:SetValue("BK0DETAIL","BK0_CODOPE" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODINT")) 
oModel:SetValue("BK0DETAIL","BK0_CODEMP" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODEMP")) 
oModel:SetValue("BK0DETAIL","BK0_MATRIC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_MATRIC")) 
oModel:SetValue("BK0DETAIL","BK0_CODOPC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODPRO")) 
oModel:SetValue("BK0DETAIL","BK0_VEROPC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_VERSAO")) 


oModel:SetValue("BBYDETAIL","BBY_CODOPE" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODINT")) 
oModel:SetValue("BBYDETAIL","BBY_CODEMP" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODEMP")) 
oModel:SetValue("BBYDETAIL","BBY_MATRIC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_MATRIC")) 
oModel:SetValue("BBYDETAIL","BBY_CODOPC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODPRO")) 
oModel:SetValue("BBYDETAIL","BBY_VEROPC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_VERSAO")) 
oModel:SetValue("BBYDETAIL","BBY_CODFOR" ,oModel:GetModel("BK0DETAIL"):GetValue("BK0_CODFOR")) 


oModel:SetValue("BG0DETAIL","BG0_CODOPE" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODINT")) 
oModel:SetValue("BG0DETAIL","BG0_CODEMP" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODEMP")) 
oModel:SetValue("BG0DETAIL","BG0_MATRIC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_MATRIC")) 
oModel:SetValue("BG0DETAIL","BG0_CODOPC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODPRO")) 
oModel:SetValue("BG0DETAIL","BG0_VEROPC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_VERSAO")) 
oModel:SetValue("BG0DETAIL","BG0_CODFOR" ,oModel:GetModel("BBYDETAIL"):GetValue("BBY_CODFOR")) 



Return .t.

/*/{Protheus.doc} PlGfOptProd
Consulta especifica para buscar os produtos do opcional da família e
do beneficiário

@type function
@version protheus 12.1.2310 
@author vinicius.queiros
@since 08/08/2023
@return logical, se o usuário confirmou ou cancelou
@obs substitui a função PLSPESPROD
/*/
function PlGfOptProd()

	local oModel := fwModelActive() as object
	local cFldNumCon := PFldGetBA3("BA3_CONEMP", oModel) as character
	local cFldCodInt := PFldGetBA3("BA3_CODINT", oModel) as character
	local cFldCodEmp := PFldGetBA3("BA3_CODEMP", oModel) as character
	local cFldCodPla := PFldGetBA3("BA3_CODPLA", oModel) as character
	local cFldVersao := PFldGetBA3("BA3_VERSAO", oModel) as character
	local cFldSubCon := PFldGetBA3("BA3_SUBCON", oModel) as character
	local nOption := 0 as numeric
	local nLine := 0 as numeric
	local oBrwOptProd as object
	local oDlgOptProd as object
	local aBrwOptProd := {{"", "", ""}} as array
	local bOkButton as codeblock
	local bCancelButton as codeblock
	local cBkpCadastro := iif(type("cCadastro") <> "U", cCadastro, "") as character
	local aPDFields := {} as array
	local oFldLGPD := CENFUNLGP():new() as object

	bOkButton := { || nLine := iif(valType(oBrwOptProd:nAt) == "N", oBrwOptProd:nAt, 0), iif(len(aBrwOptProd) > 0 .and. !empty(aBrwOptProd[1][1]), nOption := K_OK, nOption := K_CANCEL), oDlgOptProd:end()}
	bCancelButton := { || nOption := K_CANCEL, oDlgOptProd:end()}

	cCadastro := STR0006 // 'Pesquisa de Produtos Opcionais'
	
	DEFINE MSDIALOG oDlgOptProd TITLE STR0006 FROM 008.2, 000 TO 026,100.3 OF getWndDefault() // 'Pesquisa de Produtos Opcionais'

		oBrwOptProd := TcBrowse():new(036,006,388,092,nil,nil,nil,oDlgOptProd,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.f.,nil,.t.,nil,.f.)

		oBrwOptProd:addColumn(TcColumn():new(STR0007,{ || aBrwOptProd[oBrwOptProd:nAt,1]},nil,nil,nil,nil,040,.f.,.f.,nil,nil,nil,.f.,nil)) // 'Código'
		oBrwOptProd:addColumn(TcColumn():new(STR0008,{ || aBrwOptProd[oBrwOptProd:nAt,2]},nil,nil,nil,nil,040,.f.,.f.,nil,nil,nil,.f.,nil)) // 'Versão'
		oBrwOptProd:AddColumn(TcColumn():New(STR0009,{ || aBrwOptProd[oBrwOptProd:nAt,3]},nil,nil,nil,nil,120,.f.,.f.,nil,nil,nil,.f.,nil)) // 'Descrição'

		// Tratamento para LGPD
		if oFldLGPD:isLGPDAt()
			aPDFields := oFldLGPD:getTcBrw({"BT3_CODPLA+BHS_CODPLA", "BT3_VERPLA+BHS_VERPLA", "BI3_DESCRI"})
			oBrwOptProd:aObfuscatedCols := aPDFields
		endif

		// Atualiza os dados do array no browser
		aBrwOptProd := PlGetOptProd(cFldCodInt, cFldCodEmp, cFldNumCon, cFldSubCon, cFldCodPla, cFldVersao, oModel)

		oBrwOptProd:setArray(aBrwOptProd)
		oBrwOptProd:refresh()
		oBrwOptProd:blDblClick := bOkButton

	ACTIVATE MSDIALOG oDlgOptProd ON INIT eval({ || enchoiceBar(oDlgOptProd, bOkButton, bCancelButton, .f.)})
	
	if !empty(cBkpCadastro)
		cCadastro := cBkpCadastro
	endif

	if nOption == K_OK .and. len(aBrwOptProd) > 0 .and. nLine > 0
		BI3->(dbSetOrder(1))
		BI3->(msSeek(xFilial("BI3")+cFldCodInt+aBrwOptProd[nLine][1]+aBrwOptProd[nLine][2]))
	endif

return nOption == K_OK

/*/{Protheus.doc} PlGetOptProd
Retorna os produtos do opcional do beneficiário ou família no produto saúde
para empresa pessoa física e no produto do subcontrato para empresa pesssoa
juridica

@type function
@version protheus 12.1.2310 
@author vinicius.queiros
@since 08/08/2023
@param cFldCodInt, character, código da operadora
@param cFldCodEmp, character, código da empresa
@param cFldNumCon, character, código do contrato
@param cFldSubCon, character, código do subcontrato
@param cFldCodPla, character, código do produto saúde
@param cFldVersao, character, versão do produto saúde
@param oModel, object, modelo de dados ativo
@param cCodOptional, character, código do opcional para filtro
@return array, lista de produtos do opcional encontrado
@obs substitui a função PLSAPPRDPq
/*/
function PlGetOptProd(cFldCodInt, cFldCodEmp, cFldNumCon, cFldSubCon, cFldCodPla, cFldVersao, oModel, cCodOptional)

	local cAliasTemp := "" as character
	local aListOptProd := {} as array
	local lIsOptBenef := .f. as logical
	local lIsFilterOpt := .f. as logical
	local lIsModel := .f. as logical

	default oModel := fwModelActive()
	default cCodOptional := ""

	if !empty(cCodOptional)
		lIsFilterOpt := .t.
	endif

	lIsModel := valType(oModel) <> "U" .and. oModel:isActive()

	BG9->(dbSetOrder(1))
	if BG9->(msSeek(xFilial("BG9")+cFldCodInt+cFldCodEmp))
		if BG9->BG9_TIPO == "1" // 1 = Pessoa Fisica
			lIsOptBenef := type("M->BF4_CODPRO") <> 'U' .or. (valType(oModel) <> "U" .and. oModel:getId() == "PLSA260BF4")

			if lIsOptBenef
				if lIsModel
					if !empty(PFldGetBA1("BA1_CODPLA", oModel))
						cFldCodPla := PFldGetBA1("BA1_CODPLA", oModel)
						cFldVersao := PFldGetBA1("BA1_VERSAO", oModel)
					endif
				else
					if type("oBrwUsr") <> "U" .and. !empty(oBrwUsr:aCols[oBrwUsr:linha(), oBrwUsr:PlRetPos("BA1_CODPLA")])
						cFldCodPla := oBrwUsr:aCols[oBrwUsr:linha(), oBrwUsr:PlRetPos("BA1_CODPLA")]
						cFldVersao := oBrwUsr:aCols[oBrwUsr:linha(), oBrwUsr:PlRetPos("BA1_VERSAO")]
					endif
				endif
			endif
		endif

		cAliasTemp := getNextAlias()

		if BG9->BG9_TIPO == "1" // Pessoa Fisica		
			beginSql alias cAliasTemp	
				SELECT DISTINCT BT3.BT3_CODPLA, BT3.BT3_VERPLA, BI3.BI3_DESCRI 
				FROM %table:BT3% BT3 

				INNER JOIN %table:BI3% BI3
				ON BI3.BI3_FILIAL =  %xFilial:BI3%
				AND BI3.BI3_CODIGO = BT3.BT3_CODPLA
				AND BI3.BI3_VERSAO = BT3.BT3_VERPLA
				AND BI3.%notDel%

				WHERE BT3_FILIAL = %xFilial:BT3%	
					AND BT3_CODIGO = %exp:cFldCodInt+cFldCodPla%
					AND BT3_VERSAO = %exp:cFldVersao%
					AND BT3_CODPLA IN 
					(SELECT BI3IN.BI3_CODIGO FROM %table:BI3% BI3IN 
						INNER JOIN %table:BE5% BE5 
						 ON BE5.BE5_FILIAL = %xFilial:BE5% 
						AND BE5.BE5_CODGRU = BI3IN.BI3_GRUPO
						AND (BE5.BE5_PEROPC = '1' OR BE5.BE5_PERAGR = '1')
						AND BE5.%notDel%
					WHERE BI3IN.BI3_FILIAL = %xFilial:BI3%
						AND BI3IN.BI3_STATUS <> '2'
						AND BI3IN.%notDel%)
					AND BT3.%notDel%
				ORDER BY BT3.BT3_CODPLA, BT3.BT3_VERPLA
			endSql
			
			while !(cAliasTemp)->(Eof())
				if lIsFilterOpt
					if alltrim(cCodOptional) == alltrim((cAliasTemp)->BT3_CODPLA)
						aAdd(aListOptProd, {(cAliasTemp)->BT3_CODPLA,;
										    (cAliasTemp)->BT3_VERPLA,;
										    alltrim((cAliasTemp)->BI3_DESCRI)})
						exit
					endif			
				else
					aAdd(aListOptProd, {(cAliasTemp)->BT3_CODPLA,;
										(cAliasTemp)->BT3_VERPLA,;
										alltrim((cAliasTemp)->BI3_DESCRI)})
				endif
			
				(cAliasTemp)->(dbSkip())
			enddo
		else // Pessoa Juridica
			beginSql alias cAliasTemp
				SELECT DISTINCT BHS.BHS_CODPLA, BHS.BHS_VERPLA, BI3.BI3_DESCRI
				FROM %table:BHS% BHS

				INNER JOIN %table:BI3% BI3
				ON BI3.BI3_FILIAL = %xFilial:BI3%
				AND BI3.BI3_CODINT = BHS.BHS_CODINT
				AND BI3.BI3_CODIGO = BHS.BHS_CODPLA
				AND BI3.BI3_VERSAO = BHS.BHS_VERPLA
				AND BI3.%notDel%

				INNER JOIN %table:BE5% BE5
				ON BE5.BE5_FILIAL = %xFilial:BE5%
				AND BE5.BE5_CODGRU = BI3.BI3_GRUPO
				AND BE5.BE5_PEROPC = '1'
				AND BE5.%notDel%

				WHERE BHS.BHS_FILIAL = %xFilial:BHS%
				AND BHS.BHS_CODINT = %exp:cFldCodInt%
				AND BHS.BHS_CODIGO = %exp:cFldCodEmp%
				AND BHS.BHS_NUMCON = %exp:cFldNumCon%
				AND BHS.BHS_SUBCON = %exp:cFldSubCon%
				AND BHS.BHS_CODPRO = %exp:cFldCodPla%
				AND BHS.BHS_VERPRO = %exp:cFldVersao%
				AND BHS.%notDel%
			endSql

			while !(cAliasTemp)->(Eof())
				if lIsFilterOpt
					if alltrim(cCodOptional) == alltrim((cAliasTemp)->BHS_CODPLA)
						aAdd(aListOptProd, {(cAliasTemp)->BHS_CODPLA,;
											(cAliasTemp)->BHS_VERPLA,;
											alltrim((cAliasTemp)->BI3_DESCRI)})
						exit
					endif			
				else
					aAdd(aListOptProd, {(cAliasTemp)->BHS_CODPLA,;
										(cAliasTemp)->BHS_VERPLA,;
										alltrim((cAliasTemp)->BI3_DESCRI)})
				endif
						
				(cAliasTemp)->(dbSkip())
			enddo
		endif

		(cAliasTemp)->(dbCloseArea())
	endif

return aListOptProd

/*/{Protheus.doc} PlGetVerOpt
Retorna a versão do código do opcional de acordo com o nivel configurado no
produto saúde (Física) ou subcontrato (Juridica)

@type function
@version protheus 12.1.2310 
@author vinicius.queiros
@since 08/08/2023
@param cCodOptional, character, campo para preencher o valor
@return logical, se o valor foi preenchido com sucesso
/*/
function PlGetVerOpt(cCodOptional)

	local aArea := getArea()
	local oModel := fwModelActive() as object
	local cVersion := "" as character	
	local cFldCodInt := PFldGetBA3("BA3_CODINT", oModel) as character
	local cFldCodEmp := PFldGetBA3("BA3_CODEMP", oModel) as character
	local cFldNumCon := PFldGetBA3("BA3_CONEMP", oModel) as character
	local cFldSubCon := PFldGetBA3("BA3_SUBCON", oModel) as character
	local cFldCodPla := PFldGetBA3("BA3_CODPLA", oModel) as character
	local cFldVersao := PFldGetBA3("BA3_VERSAO", oModel) as character
	local aListOptinals := {} as array

	aListOptinals := PlGetOptProd(cFldCodInt, cFldCodEmp, cFldNumCon, cFldSubCon, cFldCodPla, cFldVersao, oModel, cCodOptional)

	if len(aListOptinals) > 0
		cVersion := aListOptinals[1][2]
	endif

	restArea(aArea)
		
return cVersion

/*/{Protheus.doc} PFldGetBF1
Retorna o valor do campo informado, sendo para o grupo familiar antigo o valor de memória e 
para o grupo familiar em MVC o valor do modelo.

@type function
@version Protheus 12.1.2310
@author vinicius.queiros
@since 08/08/2023
@param xFields, variant, Campos para busca do valor
@param oModel, object, modelo de dados já instanciado
@return xFieldValue, Retornar o valor dos campos informados concatenados
/*/
function PFldGetBF1(xFields, oModel)	

	local xFieldValue := nil
	local nCont as numeric
	local lIsModel := .f. as logical
	
	default oModel := fwModelActive()

	lIsModel := valType(oModel) <> "U" .and. oModel:isActive() .and. oModel:getId() == "PLS260BF1MVC"

	if valType(xFields) == "A"
		xFieldValue := ""

		for nCont := 1 to len(xFields)
			if lIsModel
				xFieldValue += oModel:getValue("BF1DETAIL", xFields[nCont])
			else
				xFieldValue += iif(valType(&("M->"+xFields[nCont])) == "U", "", &("M->"+xFields[nCont]))
			endif
		next nCont
	else
		if lIsModel
			xFieldValue := oModel:getValue("BF1DETAIL", xFields)
		else
			xFieldValue := &("M->"+xFields)
		endif
	endif

return xFieldValue
