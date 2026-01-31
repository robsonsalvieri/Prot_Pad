#Include 'PROTHEUS.CH'
#Include "FWMVCDEF.CH"
#Include "MATA600.CH"

Static __RpoRelease := GetRPORelease()
Static jFld600 	    := Nil
Static __aD2Opers	:= {}

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA600()
Esta rotina é responsável pela inclusão de Notas Fiscais
de Débito e Crédito, conforme LC 214/25

@author CRM/Faturamento
@since 09/2025
@Params
	cTipo =  1 = Crédito / 2 = Débito
	cOper =  1 = Entrada / 2 = Saída
/*/
//-------------------------------------------------------------------
Function MATA600()
	Local  oBrowse		:= Nil
	Private jDocRef     := Nil // -- Memória dos documentos vinculados quando NF de crédito ou débito.
	Private oModelNCND 	:= Nil

	If !VldArtNCND()
		Return
	EndIf

	// Inicializa o objeto jFld600
	A600IniObj()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SF2')

	oBrowse:SetDescription(STR0001) // Notas de Débito
	oBrowse:SetFilterDefault( "F2_TIPO=='6'" )

	oBrowse:Activate()		

	FwFreeObj(jFld600)
	jFld600 := Nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional da Rotina 

@author CRM/Faturamento
@since 09/2025
/*/
//-------------------------------------------------------------------
Static Function MenuDef() as Array

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002		ACTION 'VIEWDEF.MATA600'	    OPERATION MODEL_OPERATION_INSERT	ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE STR0003 		ACTION 'VIEWDEF.MATA600'		OPERATION MODEL_OPERATION_VIEW 		ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0004	    ACTION 'VIEWDEF.MATA600' 		OPERATION MODEL_OPERATION_DELETE    ACCESS 0 // 'Excluir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Estrutura de Visualização

@author CRM/Faturamento
@since 09/2025
/*/
//-------------------------------------------------------------------
Static Function ViewDef() as Object
	Local oStrCab 	:= Nil  
	Local oStrIte 	:= Nil
	Local oStrTot   := Nil
	Local bAcao1 := {||A600F4()}
	Local bAcao2 := {||A600F12()}

	Private oView 	:= Nil

	oModelNCND 	:= FWLoadModel('MATA600')

	oStrCab := FWFormStruct( 2, 'SF2',  {|cCampo| AllTrim(cCampo)$ "F2_TIPO|F2_TPCOMPL|F2_DOC|F2_SERIE|F2_LOJA|F2_COND|F2_CODA1U"} )
	oStrIte := FWFormStruct( 2, 'SD2' , {|cCampo| AllTrim(cCampo)$ "D2_ITEM|D2_COD|D2_UM|D2_SEGUM|D2_QUANT|D2_PRCVEN|D2_TOTAL|D2_TES|D2_CF|D2_LOCAL|D2_TP|D2_QTSEGUM"} )
	oStrTot := FWFormStruct( 2, 'SF2',  {|cCampo| AllTrim(cCampo)$ "F2_VALMERC|F2_VALBRUT"} )

	oStrCab:AddField('F2_CLIENTE', '01', STR0034, STR0034,, 'C' , PesqPict("SF2","F2_CLIENTE") , ,  , .T., , , , , , .T., , ) 
	oStrIte:AddField('D2_OPER', '07', GetSX3Cache('C6_OPER', 'X3_TITULO'), GetSX3Cache('C6_OPER', 'X3_TITULO'),, 'C' , PesqPict("SC6","C6_OPER") , ,  , .T., , , , , , .T., , ) 
    //Executa a tecla F4 do teclado
    SetKey(VK_F4,bAcao1)

    //Executa a tecla F12 do teclado
    SetKey(VK_F12,bAcao2)

	oView:= FWFormView():New() 

	oView:SetModel( oModelNCND )

	// ---------------------------------------------------------------
	// Remoção da exibição do folder padrão do cadastro de Operadores   
	// ---------------------------------------------------------------
	oStrCab:SetNoFolder()

	// ----------------------------------------------------------
	// DEFINIÇÃO VISUAL DE LAYOUT - TELA DE TRANSFÊRENCIA    
	// ----------------------------------------------------------
	oView:AddField( 'VIEW_CAB' , oStrCab, 'CABMASTER' ) 
	oView:AddGrid( 'VIEW_ITENS' , oStrIte, 'ITENSDETAIL' )  

	oView:CreateHorizontalBox( 'SUPERIOR'   , 030 )   
	oView:CreateHorizontalBox( 'MEIO1'  	   , 045 )
	oView:CreateHorizontalBox( 'INFERIOR1'  , 025 )

	oView:SetOwnerView( 'VIEW_CAB', 'SUPERIOR'	)

	oView:SetOwnerView( 'VIEW_ITENS', 'MEIO1'	)  

	oView:CreateFolder( 'ABAS', 'INFERIOR1' )// Crio folder ABAS e vinculo ao Box Inferior1

	//-- Criação da Aba IMPOSTOS
	oView:CreateHorizontalBox( 'TOTAIS' , 100,,, 'ABAS', 'V3') // Crio uma box dentro do Folder ABAS com ID V3
	oView:AddSheet( 'ABAS', 'V3', 'Totais')
	oView:AddGrid( 'VIEW_IMP' , oStrTot, 'TOTAIS' )
	oView:SetOwnerView('VIEW_IMP' , 'TOTAIS' )

	oView:EnableTitleView('VIEW_ITENS','Itens'	)

	oStrCab:AddGroup( 'GRP_MATA600_000', 'Tipo', '', 2 )
	oStrCab:AddGroup( 'GRP_MATA600_001', 'Cabeçalho', '', 2 )
	oStrCab:AddGroup( 'GRP_MATA600_002', 'Outros', '', 2 )

	oStrCab:SetProperty( 'F2_TIPO'      , MVC_VIEW_GROUP_NUMBER, 'GRP_MATA600_001' )
	oStrCab:SetProperty( 'F2_TPCOMPL'   , MVC_VIEW_GROUP_NUMBER, 'GRP_MATA600_001' )
	oStrCab:SetProperty( 'F2_DOC'       , MVC_VIEW_GROUP_NUMBER, 'GRP_MATA600_001' )
	oStrCab:SetProperty( 'F2_SERIE'     , MVC_VIEW_GROUP_NUMBER, 'GRP_MATA600_001' )
	oStrCab:SetProperty( 'F2_CLIENTE'   , MVC_VIEW_GROUP_NUMBER, 'GRP_MATA600_001' )
	oStrCab:SetProperty( 'F2_LOJA'      , MVC_VIEW_GROUP_NUMBER, 'GRP_MATA600_001' )
	oStrCab:SetProperty( 'F2_COND'      , MVC_VIEW_GROUP_NUMBER, 'GRP_MATA600_001' )
	oStrCab:SetProperty( 'F2_CODA1U'	, MVC_VIEW_GROUP_NUMBER, 'GRP_MATA600_001' )
		
	oStrCab:SetProperty('F2_TIPO'      ,MVC_VIEW_ORDEM,'01')
	oStrCab:SetProperty('F2_TPCOMPL'   ,MVC_VIEW_ORDEM,'02')
	oStrCab:SetProperty('F2_DOC'       ,MVC_VIEW_ORDEM,'03')
	oStrCab:SetProperty('F2_SERIE'     ,MVC_VIEW_ORDEM,'04')
	oStrCab:SetProperty('F2_CLIENTE'   ,MVC_VIEW_ORDEM,'05')
	oStrCab:SetProperty('F2_LOJA'      ,MVC_VIEW_ORDEM,'06')
	oStrCab:SetProperty('F2_COND'      ,MVC_VIEW_ORDEM,'07')
	oStrCab:SetProperty('F2_CODA1U'    ,MVC_VIEW_ORDEM,'08')
	
	oStrIte:SetProperty('D2_ITEM'     	,MVC_VIEW_ORDEM,'01')
	oStrIte:SetProperty('D2_COD'   		,MVC_VIEW_ORDEM,'02')
	oStrIte:SetProperty('D2_UM'   		,MVC_VIEW_ORDEM,'03')
	oStrIte:SetProperty('D2_QUANT'   	,MVC_VIEW_ORDEM,'04')
	oStrIte:SetProperty('D2_PRCVEN'     ,MVC_VIEW_ORDEM,'05')
	oStrIte:SetProperty('D2_TOTAL'      ,MVC_VIEW_ORDEM,'06')
	oStrIte:SetProperty('D2_TES'   		,MVC_VIEW_ORDEM,'07')
	oStrIte:SetProperty('D2_CF'      	,MVC_VIEW_ORDEM,'08')
	oStrIte:SetProperty('D2_LOCAL'    	,MVC_VIEW_ORDEM,'09')
	oStrIte:SetProperty('D2_SEGUM'    	,MVC_VIEW_ORDEM,'10')
	oStrIte:SetProperty('D2_QTSEGUM'    ,MVC_VIEW_ORDEM,'11')

	oStrCab:RemoveField('F2_CLIENT')

	oStrCab:SetProperty("F2_CLIENTE", MVC_VIEW_LOOKUP, { || F600LOOKUP("F2_CLIENTE") } )
	oStrCab:SetProperty("F2_CODA1U", MVC_VIEW_LOOKUP, { || F600LOOKUP("F2_CODA1U") } )
	oStrIte:SetProperty("D2_LOCAL", MVC_VIEW_LOOKUP, { || F600LOOKUP("D2_LOCAL") } )

	oView:AddUserButton(STR0005 ,'',{|| A600DOCREF(1) },,,{MODEL_OPERATION_INSERT},.T.) //"Vincular"

	oView:AddUserButton(STR0006 ,'',{|oModelNCND| M600Impos(oModelNCND) },,,,.T.) //"Impostos" 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Estrutura do Modelo de Dados

@author CRM/Faturamento
@since 09/2025
/*/
//-------------------------------------------------------------------
Static Function ModelDef() as Object

	Local oStrCab := FWFormStruct( 1, 'SF2' )	// -- Estrutura do Cabeçalho
	Local oStrIte := FWFormStruct( 1, 'SD2' )	// -- Estrutura da grid dos Itens
	Local oStrTot := FWFormStruct( 1, 'SF2' )	// -- Estrutura dos Totais

	oModelNCND := MPFormModel():New('MATA600',, {|oModelNCND| ValidInsert(oModelNCND)},{|oModelNCND| A600Commit(oModelNCND)},{|oModelNCND| A600Cancel(oModelNCND)} )

	oModelNCND:AddFields( 'CABMASTER', /*cOwner*/ , oStrCab) 
	oModelNCND:AddGrid( 'ITENSDETAIL', 'CABMASTER', oStrIte, { |oModelNCND,nLin,cAcao,cCampo, xVlr, xOldValue| PreLinSD2(oModelNCND, nLin, cAcao, cCampo, xVlr, xOldValue) },  ,,, )

	oModelNCND:SetRelation('ITENSDETAIL', { { 'D2_FILIAL', 'fwxFilial("SF2")' },{ 'D2_TIPO', 'F2_TIPO' } , { 'D2_DOC', 'F2_DOC' }, { 'D2_SERIE', 'F2_SERIE' }, { 'D2_CLIENTE', 'F2_CLIENTE' }, { 'D2_LOJA', 'F2_LOJA' } }, SD2->(IndexKey(1)) ) // D2_FILIAL, D2_TIPO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA

	oModelNCND:AddGrid( "TOTAIS", 'CABMASTER', oStrTot,,,,, /*bLoadFil*/)
	oModelNCND:GetModel( 'TOTAIS' ):SetDescription( STR0007 ) //Totais

	oModelNCND:SetRelation('TOTAIS', { { 'F2_FILIAL', 'FWXFILIAL("SF2")' } , { 'F2_DOC', 'F2_DOC' }, { 'F2_SERIE', 'F2_SERIE' } }, SF2->(IndexKey(1)) ) // F2_FILIAL, F2_DOC, F2_SERIE
	oModelNCND:GetModel( 'TOTAIS' ):SetOnlyView()

	oModelNCND:GetModel( 'CABMASTER' ):SetDescription( STR0008 ) //"Cabeçalho"

	oStrCab:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)	// TIRA A OBRIGATORIEDADE DE TODOS OS CAMPOS
	oStrIte:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)	// TIRA A OBRIGATORIEDADE DE TODOS OS CAMPOS
	oStrTot:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)	// TIRA A OBRIGATORIEDADE DE TODOS OS CAMPOS

	//---------------Cabeçalho SF2----------------

	oStrCab:SetProperty("F2_TIPO"		, MODEL_FIELD_INIT, {||F600INIT()})

	oStrCab:SetProperty("F2_CLIENTE"	, MODEL_FIELD_VALID, {||A600Cpos("CABMASTER", "F2_CLIENTE") .And. A600Valid() }) 
	oStrCab:SetProperty("F2_LOJA"		, MODEL_FIELD_VALID, {||A600Cpos("CABMASTER", "F2_LOJA") .And. A600Valid() }) 

	oStrCab:SetProperty("F2_TIPO"		, MODEL_FIELD_WHEN, {|| .F. })
	oStrCab:SetProperty("F2_DOC"		, MODEL_FIELD_WHEN, {|| .F. })
	oStrCab:SetProperty("F2_SERIE"		, MODEL_FIELD_WHEN, {|| .F. })

	oStrCab:SetProperty("F2_TIPO"		, MODEL_FIELD_OBRIGAT, .T.)
	oStrCab:SetProperty("F2_TPCOMPL"	, MODEL_FIELD_OBRIGAT, .T.)
	oStrCab:SetProperty("F2_CLIENTE"	, MODEL_FIELD_OBRIGAT, .T.)
	oStrCab:SetProperty("F2_LOJA"		, MODEL_FIELD_OBRIGAT, .T.)
	oStrCab:SetProperty("F2_COND"		, MODEL_FIELD_OBRIGAT, .T.)
	oStrCab:SetProperty("F2_CODA1U"		, MODEL_FIELD_VALID, {||A600Cpos("CABMASTER", "F2_CODA1U")}) 

	//---------------Itens SD2----------------
	oStrIte:SetProperty("D2_ITEM"	, MODEL_FIELD_VALID, {|| .T. })
	oStrIte:SetProperty("D2_ITEM"   , MODEL_FIELD_INIT, {|o|F600Cpos(o,'D2_ITEM')})
	oStrIte:SetProperty("D2_ITEM"   , MODEL_FIELD_WHEN, {|| .F. })

	oStrIte:SetProperty("D2_COD"	, MODEL_FIELD_VALID, {|| ValidProd() .And. A600Cpos("ITENSDETAIL", "D2_COD")})
	oStrIte:SetProperty("D2_COD"	, MODEL_FIELD_OBRIGAT, .T.)

	oStrIte:SetProperty("D2_QUANT"	, MODEL_FIELD_VALID, {|| ValidQuant() })
	oStrIte:SetProperty("D2_QUANT"  , MODEL_FIELD_WHEN, {||F600When("D2_QUANT") })
	oStrIte:SetProperty("D2_QUANT"  , MODEL_FIELD_OBRIGAT, F600When("D2_QUANT"))
	oStrIte:AddTrigger("D2_QUANT"  , "D2_TOTAL",{|| .T. },{||TriPrcVen() })

	oStrIte:SetProperty("D2_PRCVEN"	, MODEL_FIELD_VALID, {|| .T. })
	oStrIte:SetProperty("D2_PRCVEN"	, MODEL_FIELD_OBRIGAT,.T.)
	oStrIte:AddTrigger("D2_PRCVEN"  , "D2_TOTAL",{|| .T. },{||TriPrcVen() })

	oStrIte:SetProperty("D2_TOTAL"	, MODEL_FIELD_VALID, {|| .T. })
	oStrIte:SetProperty("D2_TOTAL"	, MODEL_FIELD_OBRIGAT,.T.)
	oStrIte:SetProperty("D2_TOTAL"  , MODEL_FIELD_WHEN, {|| .F. })

	oStrIte:AddField("Tp.Operação", GetSX3Cache('C6_OPER', 'X3_TITULO'), 'D2_OPER', 'C', 2, , , , , , , .F., , , )
	oStrIte:AddTrigger("D2_OPER"  , "D2_TES",{|| .T. },{||MaTesInt(2,,M->F2_CLIENTE,M->F2_LOJA,If(M->F2_TPCOMPL=='7',"F","C"),FwFldGet("D2_COD"))})

	oStrIte:SetProperty("D2_TES"	, MODEL_FIELD_VALID, {||A600Cpos("ITENSDETAIL", "D2_TES") .And. A600TES()})
	oStrIte:SetProperty("D2_TES"	, MODEL_FIELD_OBRIGAT,.T.)

	oStrIte:SetProperty("D2_LOCAL"	, MODEL_FIELD_VALID, {||A600Cpos("ITENSDETAIL", "D2_LOCAL") .And. A600Local()})
	oStrIte:SetProperty("D2_QTSEGUM", MODEL_FIELD_VALID, {||ValidSEGUM() })
	oStrIte:SetProperty("D2_QTSEGUM", MODEL_FIELD_WHEN,  {||F600When("D2_QTSEGUM") })

	//---------------Totais SF2----------------
	oStrTot:SetProperty("F2_VALBRUT", MODEL_FIELD_VALID, {|| .T. })
	oStrTot:SetProperty("F2_VALBRUT", MODEL_FIELD_WHEN, {|| .F. })

	oStrTot:SetProperty("F2_VALMERC", MODEL_FIELD_VALID, {|| .T. })
	oStrTot:SetProperty("F2_VALMERC", MODEL_FIELD_WHEN, {|| .F. })

	oStrTot:SetProperty("*", MODEL_FIELD_VIRTUAL,.T.)// TORNAR TODOS OS CAMPOS VIRTUAIS

	//---------------Ativa o modelo----------------
	oModelNCND:SetVldActivate( {|| .T. } )

Return oModelNCND

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinSD2				  	
Executa a verificação da edição da linha no grido dos atendentes

@sample 	PreLinSD2(oMdlG, nLine, cAcao, cCampo)

@param 		oMdlG, Objeto, objeto do grid em validação
@param 		nLine, Numerico, linha em ação
@param 		cAcao, Caracter, tipo da ação (DELETE, UNDELETE, etc)
@param 		cCampo, Caracter, campo da ação

@return	Nil 
@author 	CRM/Faturamento
@since 		09/2025
/*/
//------------------------------------------------------------------------------
Static Function PreLinSD2(oModelNCND, nLine, cAcao, cCampo, xVlr, xOldValue) as Logical
	Local oMdlSF2		:= oModelNCND:GetModel("CABMASTER")
	Local oMdlSD2		:= oMdlSF2:GetModel("ITENSDETAIL")
	Local oMdlTot 		:= oMdlSF2:GetModel("TOTAIS")
	Local nTot 			:= 0
	Local nX 			:= 1
	Local lIsNotDel     := .F.

	Default oModelNCND  := FwModelActive()
	Default nLine	:= 0
	Default cAcao 	:= ""
	Default cCampo  := ""

	if cAcao == "DELETE" .or. cAcao == "UNDELETE" .or. (cAcao == "SETVALUE" .And. cCampo == "D2_TOTAL")
		For nX := 1 to oMdlSD2:Length()
			If nx == nLine .And. cAcao == "DELETE"
				Loop
			EndIf
			lIsNotDel :=	(!oMdlSD2:IsDeleted(nX) .And. nX != nLine) ;
							.Or. (nX == nLine)	// Esta condição vai servir para SETVALUE ou o UNDELETE, porque o DELETE foi tratado anteriormente.
			If (lIsNotDel)
				nTot := nTot + IIf(cAcao == "SETVALUE" .And. nx == nLine, xVlr, oMdlSD2:GetValue("D2_TOTAL", nX))
			EndIf
		Next nX
		oMdlTot:LoadValue("F2_VALBRUT", nTot)
		oMdlTot:LoadValue("F2_VALMERC", nTot)
		RefrView()
	EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600Commit
Função de commit do modelo 

@return		lRet
@author 	CRM/Faturamento
@since 		09/2025
/*/
//------------------------------------------------------------------------------
Static Function A600Commit(oModelNCND)
	Local aArea	  	:= GetArea()
	Local aAliasSA1	:= SA1->(GetArea())
	Local aAliasSF4	:= SF4->(GetArea())
	Local nValMer	:= 0
	Local nValBru	:= 0
	Local oMdlSF2	:= oModelNCND:GetModel("CABMASTER")
	Local oMdlSD2	:= oModelNCND:GetModel("ITENSDETAIL")
	Local oMdlTot 	:= oModelNCND:GetModel("TOTAIS")
	Local aCabs     := {} 
	Local aItens    := {} 
	Local aItensAux := {}
	Local aStruItem := {}
	Local aStruSF2  := {} 
	Local aStruSD2  := {} 
	Local nX        :=  1  
	Local aDocOri   := {}
	Local bFiscalSF2:= {|| .T.}
	Local bFiscalSD2:= {|| .T.}
	Local cNF       := ""
	Local cDoc      := ""
	Local cEstado   := ""
	Local nLinSD2	:= 0
	Local nOpc 		:=  oModelNCND:GetOperation()
	Local cMarca	:= ""
	Local aNotas	:= {}
	Local lDocRef	:= FWAliasInDic("DKN") .and. ChkFile("DKN") .and. findFunction("FATDOCREF") // -- Tabela e interface de documentos referenciados
	Local cFilSD2	:= FwxFilial("SD2")

	Local lMostraCtb := .F.
	Local lAglutCtb	 := .F.
	Local lCtbOnLine := .F.

	Local lContinua := .T.
	Local jFatVinc	:= GetJVAdt()

	//Variaveis de posição dos campos
	Local nF2FILIAL   := 0
	Local nF2TIPO     := 0
	Local nF2SERIE    := 0   
	Local nF2EMISSAO  := 0
	Local nF2CLIENTE  := 0
	Local nF2LOJA     := 0
	Local nF2CLIENT   := 0
	Local nF2LOJENT   := 0
	Local nF2TIPOCLI  := 0
	Local nF2COND     := 0
	Local nF2DTDIGIT  := 0
	Local nF2EST      := 0
	Local nF2UFORIG   := 0
	Local nF2UFDEST   := 0  
	Local nF2VALMERC  := 0
	Local nF2TPCOMPL  := 0
	Local nF2CODA1U	  := 0
	Local nD2FILIAL   := 0
	Local nD2DOC      := 0
	Local nD2SERIE    := 0
	Local nD2CLIENTE  := 0
	Local nD2LOJA     := 0
	Local nD2EMISSAO  := 0
	Local nD2TIPO     := 0
	Local nD2ITEM     := 0
	Local nD2CF       := 0
	Local nD2COD      := 0
	Local nD2UM       := 0
	Local nD2QUANT    := 0
	Local nD2PRCVEN   := 0
	Local nD2PRUNIT   := 0
	Local nD2TOTAL    := 0
	Local nD2LOCAL    := 0
	Local nD2TP       := 0
	Local nD2SEGUM    := 0
	Local nD2QTSEGUM  := 0
	Local nD2TES      := 0
	Local nD2ESTOQUE  := 0				


	PRIVATE lMsErroAuto := .F. 

	Pergunte("MT600A",.F.)
	
	lMostraCtb := (MV_PAR01 == 1)
	lAglutCtb  := (MV_PAR02 == 1)
	lCtbOnLine := (MV_PAR03 == 1)
	__aD2Opers   := {}

	If nOpc == MODEL_OPERATION_INSERT

		nValMer := oMdlTot:GetValue("F2_VALMERC")
		nValBru	:= oMdlTot:GetValue("F2_VALBRUT")

		If nValMer > 0 .And. nValBru > 0
			oMdlSF2:LoadValue("F2_VALMERC", nValMer)
			oMdlSF2:LoadValue("F2_VALBRUT", nValBru)
		EndIf

		aStruSF2    :=  SF2->(dbStruct())       
		
		//Montagem do cabeçalho do Documento Fiscal
		nF2FILIAL   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_FILIAL"})  
		nF2TIPO     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_TIPO"})
		nF2SERIE    := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_SERIE"})   
		nF2EMISSAO  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_EMISSAO"}) 
		nF2CLIENTE  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CLIENTE"})
		nF2LOJA     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_LOJA"})
		nF2CLIENT   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CLIENT"})
		nF2LOJENT   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_LOJENT"})
		nF2TIPOCLI  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_TIPOCLI"})
		nF2COND     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_COND"})
		nF2DTDIGIT  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_DTDIGIT"}) 
		nF2EST      := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_EST"})
		nF2UFORIG   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_UFORIG"})
		nF2UFDEST   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_UFDEST"})  
		nF2VALMERC  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_VALMERC"})
		nF2TPCOMPL  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_TPCOMPL"})
		nF2CODA1U   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CODA1U"})
		
		//Estado de origem a ser considerado na emissão nota 
		cEstado     := SuperGetMV("MV_ESTADO")
		
		For nX := 1 To Len(aStruSF2)
			If aStruSF2[nX][2] $ "C/M"
				Aadd(aCabs,"")
			ElseIf aStruSF2[nX][2] == "N"
				Aadd(aCabs,0)
			ElseIf aStruSF2[nX][2] == "D"
				Aadd(aCabs,CtoD("  /  /  "))
			ElseIf aStruSF2[nX][2] == "L"
				Aadd(aCabs,.F.)
			EndIf
		Next nX

		aCabs[nF2FILIAL]    := FwxFilial("SF2")
		aCabs[nF2TIPO]      := jFld600["F2_TIPO"]
		aCabs[nF2SERIE]     := jFld600["F2_SERIE"]
		aCabs[nF2EMISSAO]   := dDataBase
		aCabs[nF2CLIENTE]   := jFld600["A1_COD"]
		aCabs[nF2LOJA]      := jFld600["A1_LOJA"]
		aCabs[nF2CLIENT]    := jFld600["A1_COD"]
		aCabs[nF2LOJENT]    := jFld600["A1_LOJA"]
		aCabs[nF2TIPOCLI]   := jFld600["A1_TIPO"]
		aCabs[nF2COND]      := oMdlSF2:GetValue("F2_COND") 
		aCabs[nF2DTDIGIT]   := dDataBase
		aCabs[nF2EST]       := jFld600["A1_EST"]
		aCabs[nF2UFORIG]    := cEstado
		aCabs[nF2UFDEST]    := jFld600["A1_EST"]
		aCabs[nF2VALMERC]   := oMdlSF2:GetValue("F2_VALMERC") 
		aCabs[nF2TPCOMPL]   := oMdlSF2:GetValue("F2_TPCOMPL") 
		aCabs[nF2CODA1U]	:= oMdlSF2:GetValue("F2_CODA1U")

		aStruSD2    :=  SD2->(dbStruct())
		
		//Montagem dos itens do Documento Fiscal
		nD2FILIAL   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_FILIAL"})
		nD2DOC      := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DOC"})
		nD2SERIE    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_SERIE"})
		nD2CLIENTE  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CLIENTE"})
		nD2LOJA     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOJA"})
		nD2EMISSAO  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_EMISSAO"})
		nD2TIPO     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TIPO"})
		nD2ITEM     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ITEM"})
		nD2CF       := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CF"})
		nD2COD      := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_COD"})
		nD2UM       := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_UM"})
		nD2QUANT    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_QUANT"})
		nD2PRCVEN   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PRCVEN"})
		nD2PRUNIT   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PRUNIT"})
		nD2TOTAL    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TOTAL"})
		nD2LOCAL    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOCAL"})
		nD2TP       := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TP"})
		nD2SEGUM    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_SEGUM"})
		nD2QTSEGUM  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_QTSEGUM"})
		nD2TES      := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TES"})
		If GetSX3Cache('D2_ESTOQUE', 'X3_VISUAL') != "V"
			nD2ESTOQUE  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ESTOQUE"})				
		EndIf

		aAdd(aStruItem, {})
		nPos := Len(aStruItem)
		
		For nX := 1 To Len(aStruSD2)
			If  aStruSD2[nX][2]$"C/M"
				aAdd(aStruItem[nPos],"")
			ElseIf aStruSD2[nX][2]=="D"
				aAdd(aStruItem[nPos],CToD(""))
			ElseIf aStruSD2[nX][2]=="N"
				aAdd(aStruItem[nPos],0)
			ElseIf aStruSD2[nX][2]=="L"
				aAdd(aStruItem[nPos],.T.)
			EndIf
		Next nX
		
		For nLinSD2 := 1 To oMdlSD2:Length()

			aAdd(aDocOri,0)
			aItensAux := aClone(aStruItem)

			oMdlSD2:GoLine(nLinSD2)
			If !oMdlSD2:IsDeleted(nLinSD2)
				aItensAux[nPos][nD2FILIAL]   := cFilSD2
				aItensAux[nPos][nD2DOC]      := cDoc
				aItensAux[nPos][nD2SERIE]    := jFld600["F2_SERIE"]
				aItensAux[nPos][nD2CLIENTE]  := jFld600["A1_COD"]	
				aItensAux[nPos][nD2LOJA]     := jFld600["A1_LOJA"]
				aItensAux[nPos][nD2EMISSAO]  := dDataBase
				aItensAux[nPos][nD2TIPO]     := jFld600["F2_TIPO"]
				aItensAux[nPos][nD2ITEM]     := oMdlSD2:GetValue("D2_ITEM")
				aItensAux[nPos][nD2CF]       := oMdlSD2:GetValue("D2_CF")
				aItensAux[nPos][nD2COD]      := oMdlSD2:GetValue("D2_COD")
				aItensAux[nPos][nD2UM]       := oMdlSD2:GetValue("D2_UM")
				aItensAux[nPos][nD2QUANT]    := oMdlSD2:GetValue("D2_QUANT")
				aItensAux[nPos][nD2PRCVEN]   := oMdlSD2:GetValue("D2_PRCVEN")
				aItensAux[nPos][nD2TOTAL]    := oMdlSD2:GetValue("D2_TOTAL")
				aItensAux[nPos][nD2LOCAL]    := oMdlSD2:GetValue("D2_LOCAL")
				aItensAux[nPos][nD2TP]       := oMdlSD2:GetValue("D2_TP")
				aItensAux[nPos][nD2SEGUM]    := oMdlSD2:GetValue("D2_SEGUM")
				aItensAux[nPos][nD2QTSEGUM]  := oMdlSD2:GetValue("D2_QTSEGUM")
				aItensAux[nPos][nD2TES]      := oMdlSD2:GetValue("D2_TES")
				If nD2ESTOQUE > 0
					aItensAux[nPos][nD2ESTOQUE]  := Posicione("SF4",1,FWxFilial("SF4")+oMdlSD2:GetValue("D2_TES"),"F4_ESTOQUE")
				EndIf
				
				aAdd(aItens, aItensAux[nPos])
				aAdd(__aD2Opers,{oMdlSD2:GetValue("D2_ITEM"),oMdlSD2:GetValue("D2_OPER")})
			EndIf

		Next nLinSD2

		cNF :=	MaNfs2Nfs(Nil,;  			//Serie do Documento de Origem
							Nil,;        	//Numero do Documento de Origem
		/*cClieFor*/        jFld600["A1_COD"],;		//Cliente/Fornecedor do documento do origem
		/*cLoja*/           jFld600["A1_LOJA"],; 		//Loja do Documento de origem
		/*cSerie*/   		jFld600["F2_SERIE"],;		//Serie do Documento a ser gerado
		/*lMostraCtb*/      lMostraCtb,; 	//Mostra Lct.Contabil (OPC)
		/*lAglutCtb*/       lAglutCtb,; 	//Aglutina Lct.Contabil (OPC)
		/*lCtbOnLine*/      lCtbOnLine,; 	//Contabiliza On-Line (OPC)
		/*lCtbCusto*/       Nil,;       	//Contabiliza Custo On-Line (OPC)
		/*lReajusta*/       Nil,;       	//Reajuste de preco na nota fiscal (OPC)
		/*nCalAcrs*/        Nil,;       	//Tipo de Acrescimo Financeiro (OPC)
		/*nArredPrcLis*/    Nil,;       	//Tipo de Arredondamento (OPC)
		/*lAtuSA7*/         Nil,;       	//Atualiza Amarracao Cliente x Produto (OPC)
		/*lECF*/            Nil,;       	//Cupom Fiscal (OPC)
		/*bFilSD2*/         Nil,;       	//CodeBlock de Selecao do SD2 (OPC)
		/*bSD2*/            Nil,;       	//CodeBlock a ser executado para o SD2 (OPC)
		/*bSF2*/            Nil,;       	//CodeBlock a ser executado para o SF2 (OPC)
		/*bTTS*/            Nil,;       	//CodeBlock a ser executado no final da transacao (OPC)
		/*aDocOri*/         aDocOri,;   	//Array com os Recnos do SF2 (OPC)
		/*aItemOri*/        aItens,;    	//Array com os itens do SD2 (OPC)
		/*aSF2*/            aCabs,;     	//Array com os dados do SF2 (OPC)
		/*lNoFiscal*/       .F.,;       	//Calculo Fiscal - Desabilita o calculo fiscal pois as informacoes ja foram passadas nos campos do SD2 e SF2 (OPC)
		/*bFiscalSF2*/      bFiscalSF2,;	//CodeBlock para tratamento do fiscal - SF2 (OPC)
		/*bFiscalSD2*/      bFiscalSD2,;	//CodeBlock para tratamento do fiscal - SD2 (OPC)
		/*bFatSE1*/         Nil,;       	//CodeBlock para tratamento do fiscal - SE1 (OPC)
		/*cNumNFS*/         Nil,;			//Numero do documento fiscal (OPC)
		/*lVerSE1*/  		Nil,;
		/*lGTPSub*/  		Nil,;
		/*cTpOper*/  		Nil,;
		/*cTypeDoc*/		Nil)			//Tratar o cTypeDoc quando implementar o novo controle de numeração 

		If !Empty(cNf)
			jFld600["F2_DOC"] := cNf

			If  lDocRef
				If jDocRef <> Nil//-- Grava documentos referenciados
					A600GRVREF()						
				EndIf
				If aCabs[nF2TIPO] == "6" .And. aCabs[nF2TPCOMPL] == "6" .And. jFatVinc <> Nil//-- Grava documentos referenciados
					FatPrepGrv()						
				EndIf
			EndIf
		Else
			lContinua := .F.
		EndIf

	ElseIf nOpc == MODEL_OPERATION_DELETE
		If !isBlind()
			jFld600["F2_DOC"]     := oMdlSF2:GetValue("F2_DOC") 
        	jFld600["F2_SERIE"]   := oMdlSF2:GetValue("F2_SERIE") 
        	jFld600["F2_CLIENTE"] := oMdlSF2:GetValue("F2_CLIENTE") 
        	jFld600["F2_LOJA"]    := oMdlSF2:GetValue("F2_LOJA")
		EndIf

		//Recebe a marca que sera gravada nos campos F2_OK
		cMarca := GetMark(,"SF2","F2_OK") 

		//Dados das notas que serão excluidas
		AADD(aNotas,{jFld600["F2_DOC"],jFld600["F2_SERIE"],jFld600["F2_CLIENTE"],jFld600["F2_LOJA"]})

		//Função que marca as notas que serão excluidas
		MarkExcNF(@cMarca,aNotas)

		//Exclusão do documento de saída
		lContinua := Mata521A(.T.,"SF2",cMarca,1)

		FwFreeArray(aNotas)
	EndIf

	FwFreeArray(__aD2Opers)
	FwFreeObj(jFld600)
	FwFreeObj(jDocRef)
	FwFreeObj(jFatVinc)
	// Inicializa o objeto jFld600 para a próxima execução
	A600IniObj()
	jDocRef := Nil
	jFatVinc := Nil

	RestArea(aAliasSF4)
	RestArea(aAliasSA1)
	RestArea(aArea)

Return lContinua

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600Cancel
Validação para o cancelamento do formulário

@return		lRet
@author 	CRM/Faturamento
@since 		11/2025
/*/
//------------------------------------------------------------------------------
Static Function A600Cancel(oModelNCND)

	Local lRetorno := .T.

	Default oModelNCND := Nil

	If jDocRef <> Nil
		FwFreeObj(jDocRef)
	EndIF

	If jFld600 <> Nil
		FwFreeObj(jFld600)
	EndIF

	// Inicializa o objeto jFld600 para a próxima execução
	A600IniObj()
	jDocRef := Nil

	lRetorno := FwFormCancel(oModelNCND)

Return lRetorno

//------------------------------------------------------------------------------
/*/{Protheus.doc}F665IncItem
Incrementa automaticamente os itens

@author CRM/Faturamento
@since 09/2025
/*/
//------------------------------------------------------------------------------
Function F600Cpos(oModelNCND, cCampo) as Character
	Local cRet	:= ""

	If cCampo == 'D2_ITEM'
		If oModelNCND:Length() > 0 
			oModelNCND:GoLine( oModelNCND:Length() )
			cRet := Soma1(oModelNCND:GetValue(cCampo))
		Else
			cRet := '01' 
		EndIf	
	EndIf

Return cRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} F114When
Função para retorno do WHEN de campos D2_QUANT para inibir o campoa 
ao selecionar uma nota de débito do tipo 7 (7=Perda em estoque).

@author CRM/Faturamento
@since 09/2025
/*/
//-------------------------------------------------------------------
Static Function F600When(cCampo as character) as Logical
	Local lRet    	:= .F.
	Local nPosQtd 	:= aScan(oModelNCND:AALLSUBMODELS[1]:ADATAMODEL[1],{|x| Alltrim(x[1])== "F2_TPCOMPL"})
	Local cSegUM    := ""
	
	If ValType(oModelNCND) == "O" .And. nPosQtd > 0 .And. (oModelNCND:AALLSUBMODELS[1]:ADATAMODEL[1][nPosQtd][2] == "6" .Or. oModelNCND:AALLSUBMODELS[1]:ADATAMODEL[1][nPosQtd][2] == "7")
		If cCampo == 'D2_QTSEGUM'
			cSegUM := oModelNCND:GetModel("ITENSDETAIL"):GetValue("D2_SEGUM")
			If !Empty(cSegUM)
				lRet := .T.
			EndIf
		ElseIf cCampo == 'D2_QUANT'
			lRet := .T.
		EndIf
	EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} CboTpCompl
Rertorna as validações dos campos X3_CBOX e X3_RELACAO dos campos 
F2_TIPO e F2_TPCOMPL.

@return	cCbox 
@author CRM/Faturamento
@since 09/2025
/*/
//------------------------------------------------------------------------------
Function CboTpCompl(nVal) as Character
	Local 	cCbox		:= "" 
	Local	l600Fat		:= FwIsInCallStack("MATA600")
	
	Default nVal		:= 0

	If l600Fat.And. nVal = 1
		If MV_PAR01 == 2
			cCbox   := STR0011 //1=Trânsferência de Créditos para Cooperativas; 2=Anulação de Crédito por Saídas Imunes/Isentas; 3=Débitos de notas fiscais não processadas na apuração
			cCbox   += STR0012 //4=Multa e juros; 5=Transferência de crédito de sucessão; 6=Pagamento antecipado; 7=Perda em estoque; 8=Desenquadramento do SN	
		ElseIf MV_PAR01 == 1
			cCbox   := STR0013 //1=Multa e juros; 2=Apropriação de crédito presumido de IBS sobre saldo devedor ZFM; 3=Retorno; 4=Redução de Valores; 5=Transferência de crédito na sucessão
		EndIf                                                                              
	ElseIf l600Fat .And. nVal = 2
        If MV_PAR01 == 2
            cCbox   := STR0014 //6=Debito
        ElseIf MV_PAR01 == 1
            cCbox   := STR0015 //5=Credito
        EndIf
    ElseIf l600Fat .And. nVal = 3
        If MV_PAR01 == 2
            cCbox   := '"6"'
        ElseIf MV_PAR01 == 1
            cCbox   := '"5"'
        EndIf
    EndIf

Return(cCbox)

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkExcNF
Marca a nota a ser excluida
@since 19/01/2016
/*/
//-------------------------------------------------------------------
Static Function MarkExcNF(cMarca, aNotas)
	Local cDoc			:= ""
	Local cSerie		:= ""
	Local cCliFor		:= ""
	Local cLoja			:= ""
	Local nX 			:= ""
	Local aArea         := GetArea()
	Local nTmDOC		:= GetSX3Cache("F2_DOC",     "X3_TAMANHO")
	Local nTmSERIE		:= GetSX3Cache("F2_SERIE",   "X3_TAMANHO")
	Local nTmCLIENTE	:= GetSX3Cache("F2_CLIENTE", "X3_TAMANHO")
	Local nTmLOJA		:= GetSX3Cache("F2_LOJA",    "X3_TAMANHO")
	Local cQuery        := ""
	Local lVerifMarc    := .T.
	Local cAliasVerM    := GetNextAlias()

	Default cMarca	:= GetMark(,"SF2", "F2_OK")
	Default aNotas	:= {}

	While lVerifMarc
		
		//Verifica se a marca pode ser utilizada
		cQuery := "SELECT COUNT(1) QTD "
		cQuery += "FROM "+RetSqlName("SF2")+" SF2 "
		cQuery += "WHERE SF2.F2_FILIAL='"+FwxFilial("SF2")+"' AND "
		cQuery += "SF2.F2_OK='"+cMarca+"' AND "
		cQuery += "SF2.D_E_L_E_T_=' '"
		cQuery := ChangeQuery(cQuery)

		DBUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVerM,.T.,.T.)

		//Apenas sai do while (lVerifMarc := .F.) quando não encontrar registros na SF2 com o campo F2_OK com conteúdo gerado pela função GetMark().
		If ((cAliasVerM)->QTD == 0)
			lVerifMarc := .F.
		Else
			cMarca	:= GetMark(,"SF2", "F2_OK")
		EndIf

		(cAliasVerM)->(DbCloseArea())
	EndDo

	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))
	For nX := 1 to Len(aNotas)
		cDoc 	:= PADR(aNotas[nX][1], nTmDOC)
		cSerie  := PADR(aNotas[nX][2], nTmSERIE)
		cCliFor := PADR(aNotas[nX][3], nTmCLIENTE)
		cLoja 	:= PADR(aNotas[nX][4], nTmLOJA)
		If SF2->(MsSeek(cFilAnt+cDoc+cSerie+cCliFor+cLoja))
			SF2->(RecLock("SF2",.F.))
			SF2->F2_OK := cMarca
			SF2->(MsUnlock())
		EndIf
	Next nX

	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F600LOOKUP()
Estrutura do Modelo de Dados

@author CRM/Faturamento
@since 09/2025
/*/
//-------------------------------------------------------------------
Static Function F600LOOKUP(cCampo) as Character
	Local cF3 := ""
	
	Default cCampo := ""

	If cCampo == "F2_CLIENTE"
		cF3 := "SA1"
		If FwFldGet("F2_TPCOMPL") == "7"
			cF3 := "FOR"
		EndIf
	ElseIf cCampo == "F2_CODA1U"
		cF3 := "A1U"
	ElseIf cCampo == "D2_LOCAL"
		cF3 := "NNR"
	EndIf

Return cF3

//-------------------------------------------------------------------
/*/{Protheus.doc} F600INIT()
Estrutura do Modelo de Dados
@author CRM/Faturamento
@since 09/2025
/*/
//-------------------------------------------------------------------
Static Function F600INIT() as Character
	Local cRet := ""
	
	SetMvValue("MTA600", "MV_PAR01", 2)
	Pergunte("MTA600",.F.)

	If MV_PAR01 == 1
		cRet := "5"
	Else
		cRet := "6"
	EndIf

	jFld600["F2_TIPO"] := cRet

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} M600Impos                 
Executa a verificação da edição da linha no grid dos atendentes

@sample     Grv600Imp(oModelNCND)

oModelNCND -> Carrega o modelo informado pelo MVC

@return     lRet -> .T. 
@author     CRM/Faturamento
/*/
//------------------------------------------------------------------------------
Static Function M600Impos(oModelNCND) as Logical
    Local lRet          := .T.
    Local oMdlSF2       := oModelNCND:GetModel("CABMASTER")
    Local oMdlSD2       := oModelNCND:GetModel("ITENSDETAIL")
    Local oDados        := Nil
    Local oDlg          := Nil
    Local jData         := JsonObject():New() 
    Local jHeader       := JsonObject():New() 
    Local jItem         := Nil
    Local aTitles       := {STR0006} //Impostos
    Local aItens        := {} 
    Local nLinSD2       := 0
    Local nOpc          := oModelNCND:GetOperation() //Inclusão, Visualização ou Exclusão
    Local aAliasSA1     := {}
	Local aAliasSA2     := {}
    Local cTpPart       := "" //Tipo do participante C-Cliente ou F-Fornecedor
    Local cCatPart      := "" //Categoria do Cliente ou Fornecedor

    Default oModelNCND  := FwModelActive()

    If nOpc == 3 //Inclusão 
        If (oMdlSF2:GetValue("F2_TPCOMPL") <> "7" .And. oMdlSF2:GetValue("F2_TIPO") == '6') .Or. oMdlSF2:GetValue("F2_TIPO") == '5'
			aAliasSA1     := SA1->(GetArea())

            //Posiciona no cliente 
            dbSelectArea("SA1")
            dbSetOrder(1)
            dbSeek(FwxFilial("SA1") + oMdlSF2:GetValue("F2_CLIENTE") + oMdlSF2:GetValue("F2_LOJA"))

            cTpPart     := "C"
            cCatPart    := SA1->A1_TIPO

			RestArea(aAliasSA1)
        Else
			aAliasSA2     := SA2->(GetArea())

            //Posiciona no fornecedor
            dbSelectArea("SA2")
            dbSetOrder(1)
            dbSeek(FwxFilial("SA2") + oMdlSF2:GetValue("F2_CLIENTE") + oMdlSF2:GetValue("F2_LOJA"))

            cTpPart     := "F"
            cCatPart    := SA2->A2_TIPO

			RestArea(aAliasSA2)
        EndIf

        //Preenche cabeçalho
        jHeader["codParticipante"]          := oMdlSF2:GetValue("F2_CLIENTE")
        jHeader["lojaParticipante"]         := oMdlSF2:GetValue("F2_LOJA")
        jHeader["tipoParticipante"]         := cTpPart
        jHeader["tipoOperacao"]             := oMdlSF2:GetValue("F2_TIPO") 
        jHeader["categoriaParticipante"]    := cCatPart
        jHeader["frete"]                    := 0
        jHeader["desconto"]                 := 0
        jHeader["despesa"]                  := 0
        jHeader["seguro"]                   := 0

        jData["cabecalho"] := jHeader

        For nLinSD2 := 1 To oMdlSD2:Length()

            oMdlSD2:GoLine(nLinSD2)
			If !oMdlSD2:IsDeleted(nLinSD2)
            	jItem                   := JsonObject():New()
            	jItem["codigo"]         := oMdlSD2:GetValue("D2_COD")
            	jItem["tes"]            := oMdlSD2:GetValue("D2_TES")
            	jItem["quantidade"]     := oMdlSD2:GetValue("D2_QUANT")
            	jItem["valorUnitario"]  := oMdlSD2:GetValue("D2_PRCVEN")
            	jItem["desconto"]       := 0
            	jItem["nfOri"]          := ""
            	jItem["serieOri"]       := ""
            	jItem["recnoOri"]       := ""
            	jItem["frete"]          := 0
            	jItem["despesa"]        := 0
            	jItem["seguro"]         := 0
            	jItem["freteAutonomo"]  := 0
            	jItem["valorTotal"]     := oMdlSD2:GetValue("D2_TOTAL")
            	jItem["cfop"]           := oMdlSD2:GetValue("D2_CF")
            	jItem["origemProduto"]  := ""
				jItem["tpOper"]			:= oMdlSD2:GetValue("D2_OPER")
	
            	aadd(aItens, jItem)
			EndIf
        Next nLinSD2

        jData["itens"] := aItens

        //Instancia da classe TaxCalculationService com os dados do jSon da nota
        oDados:= totvs.protheus.backoffice.fiscal.calculation.TaxCalculationService():New(jData)

        //Subir a Matxfis
        oDados:startCalculationEngine(.T.)
        oDados:runCalculationEngine()

        //Monta a tela de exibicao dos valores fiscais
        DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM 09,00 TO 28,80 //"Impostos"
        oFolder := TFolder():New(001,001,aTitles,{"HEADER"},oDlg,,,, .T., .F.,315,140)

        //Carrega a tela com impostos do fiscal
        MaFisRodape(1,oFolder:aDialogs[1],,{005,001,310,112},Nil,.T.)

        ACTIVATE MSDIALOG oDlg CENTERED ON INIT CursorArrow()

        //Descer a Matxfis
        oDados:finishCalculationEngine()

        oDados:destroy()
        FreeObj(oDados)
        aSize(aItens,0)
    ElseIf nOpc == 1 .Or. nOpc == 5 //Visualizar ou Excluir

        //A função carrega as notas fiscais para a MATXFIS a partir das tabelas SF2/SD2 
        MaFisIniNF(2,SF2->(RecNo()))

        //Monta a tela de exibicao dos valores fiscais
        DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) FROM 09,00 TO 28,80 //"Impostos"
        oFolder := TFolder():New(001,001,aTitles,{"HEADER"},oDlg,,,, .T., .F.,315,140)

        //Carrega a tela com impostos do fiscal
        MaFisRodape(1,oFolder:aDialogs[1],,{005,001,310,112},Nil,.T.)

        ACTIVATE MSDIALOG oDlg CENTERED ON INIT CursorArrow()

        //Finaliza todo o uso da MATXFIS limpando TODOS os seus arrays internos
        MaFisEnd()
    EndIf

	FwFreeArray(aTitles)
	FwFreeArray(aItens )
	RestArea(aAliasSA1)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldTPCompl                 
Valid do campo F2_TPCOMPL

@sample     M600Vld()

@return     lRet
@author     CRM/Faturamento

/*/
//------------------------------------------------------------------------------
Function VldTPCompl() as Logical
	Local l600Fat 	:= FwIsInCallStack("MATA600")
	Local lRet 		:= .F.
	Local cTipo 	:= ""
	Local cTpCompl 	:= ""
	Local oMdlSF2 	:= Nil
	Local oMdlSD2   := Nil
	Local jFatVinc  := GetJVAdt()

	If l600Fat 
		oMdlSF2	:= oModelNCND:GetModel("CABMASTER")
		oMdlSD2   := oModelNCND:GetModel("ITENSDETAIL")

		If (jDocRef <> Nil .And. jDocRef:hasproperty('documentos')) .Or.( jFatVinc <> Nil .And. jFatVinc:hasproperty('identification'))
            jDocRef := Nil
            jFatVinc['identification'] := {}
            SetJVAdt(jFatVinc)
        EndIf

		cTipo := M->F2_TIPO
		cTpCompl := M->F2_TPCOMPL

		If (cTipo == "5" .And. cTpCompl $ "1245" ) .Or.  (cTipo == "6" .And. cTpCompl $ "12345678" ) 
			lRet := .T.
			jFld600["F2_TPCOMPL"] := cTpCompl
		ElseIf cTipo == "5" .And. cTpCompl == "3"
			Help(NIL, NIL, , NIL, STR0037, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0038}) 
			// STR0037 "Não é permitido incluir uma nota de crédito com 'Tipo de Complemento' '3 - Retorno' em movimentação de saída." 
			// STR0038 "Para incluir uma nota tipo crédito e 'Tipo de Complemento' '3 - Retorno' é necessário utilizar a rotina Documento de Entrada (MATA103)."
		EndIf
		RefrView()

		//Caso o usuário estiver no tipo 7 (Perda em estoque) e alterar para outro tipo
		//zera os campos D2_QUANT, D2_PRCVEN e D2_TOTAL
		If !IsBlind() .And. ValType(jFld600["F2_ANT_TPCOMPL"]) <> "U" .And. ;
			 ((jFld600["F2_ANT_TPCOMPL"] == "7" .And. cTpCompl $ "1234568") .Or. ;
			 (jFld600["F2_ANT_TPCOMPL"] $ "1234568" .And. cTpCompl == "7")) .And. ;
			 oMdlSD2:CanClearData()
			
			M->F2_CLIENTE := ''
			M->F2_LOJA := ''
			oMdlSD2:ClearData(.T.)

			RefrView()
		EndIf

		//Campo de controle de alteração do F2_TPCOMPL, gravando 
		//o conteúdo anterior da alteração do campo.
		jFld600["F2_ANT_TPCOMPL"] := cTpCompl
	Else
		lRet := .T.
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600TES                 
Valid do campo F2_TPCOMPL

@sample     A600TES()

@return     lRet
@author     CRM/Faturamento

/*/
//------------------------------------------------------------------------------
Static Function A600TES() as Logical
	Local aArea 	:= GetArea()
	Local aAreaSF4	:= SF4->(GetArea())
	Local oMdlSD2	:= oModelNCND:GetModel("ITENSDETAIL")
	Local aDadosCfo := {}
	Local cCfop		:= ""
	Local cTES		:= oMdlSD2:GetValue("D2_TES")
	Local lLimpTes  := .F.

	If ReadVar() == "M->D2_COD"
		lLimpTes := .T.
	EndIf

	If !lLimpTes .And. !Empty(cTES)
		SF4->( DBSetOrder(1) )
		If SF4->( MsSeek(FWxFilial("SF4") + cTES,.F.) )
			// -- Validações de Nf de Crédito(E) ou Débito(S)
			If SF4->F4_DUPLIC == 'S'
				Help(Nil, Nil, "NCNDDUPLIC", Nil, STR0009, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0010}) //"Para Nota de Crédito/Débito é obrigatório selecionar uma TES configurada para não gerar duplicata."##"Selecione outra TES ou cadastre uma nova no cadastro de 'Tipo de entrada e saída' com o campo 'Gera Dupl' = N."
				lLimpTes := .T.
			EndIf

			If !lLimpTes .And. SF4->F4_ESTOQUE == 'S'
				Help(Nil, Nil, "NCNDESTOQ", Nil, STR0051, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0052}) //"Para Nota de Crédito/Débito é obrigatório selecionar uma TES configurada para não movimentar estoque."##"Selecione outra TES ou cadastre uma nova no cadastro de 'Tipo de entrada e saída' com o campo 'Atu.Estoque' = N."
				lLimpTes := .T.
			EndIf

			If !lLimpTes .And. cTES < "501"
				Help(NIL, NIL, "NOTTESENT", NIL, STR0041, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0042}) //"Não é permitido utilizar uma TES de entrada em uma movimentação de saída."##"Selecione outra TES ou cadastre uma nova no cadastro de 'Tipo de saída' com o campo 'Codigo' maior que 500."
				lLimpTes := .T.
			EndIf 
			
			If !lLimpTes
				If SF4->F4_PODER3 == "N"
					Aadd(aDadosCfo,{"OPERNF","S"})
					Aadd(aDadosCfo,{"TPCLIFOR", jFld600["A1_TIPO"]})
					Aadd(aDadosCfo,{"UFDEST", jFld600["A1_EST"]})
					Aadd(aDadosCfo,{"INSCR", jFld600["A1_INSCR"]})
					Aadd(aDadosCfo,{"CONTR", jFld600["A1_CONTRIB"]})
					Aadd(aDadosCfo,{"FRETE", ""})

					cCfop := MaFisCfo(,SF4->F4_CF,aDadosCfo)
					
					If cCfop <> oMdlSD2:GetValue("D2_CF")
						oMdlSD2:LoadValue("D2_CF", cCfop)
					EndIf
				Else
					Help(NIL, NIL, "NOTPODER3", NIL, STR0043, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0044}) //"Não é permitido utilizar uma TES que controla poder de terceiros."##"Selecione outra TES ou cadastre uma nova no cadastro de 'Tipo de saída' com o campo 'Poder Terc.' = N."
					lLimpTes := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	If lLimpTes
		oMdlSD2:LoadValue("D2_TES", "")
	EndIf

	RestArea(aAreaSF4)
	RestArea(aArea)

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600Valid                 


@sample     A600Valid()

@return     lRet
@author     CRM/Faturamento

/*/
//------------------------------------------------------------------------------
Static Function A600Valid() as Logical
	Local aArea 	:= GetArea()
	Local aAreaSA1	:= ""
	Local aAreaSA2	:= ""
	Local oMdlSF2	:= oModelNCND:GetModel("CABMASTER")
	Local oMdlSD2	:= oModelNCND:GetModel("ITENSDETAIL")

	cCliFor  := oMdlSF2:GetValue("F2_CLIENTE")
	cLoja    := oMdlSF2:GetValue("F2_LOJA")

	If cCliFor <> M->F2_CLIENTE .Or. cLoja <> M->F2_LOJA
		If oMdlSF2:GetValue("F2_TIPO") == "6" .And. oMdlSF2:GetValue("F2_TPCOMPL") == "7"
			aAreaSA2	:= SA2->(GetArea())
			dbSelectArea("SA2")
			dbSetOrder(1)
			If SA2->(dbSeek(FwxFilial("SA2") + cCliFor + AllTrim(cLoja)))
				jFld600["A1_COD"]:= SA2->A2_COD
				jFld600["A1_LOJA" ]:= SA2->A2_LOJA
				jFld600["A1_TIPO" ]:= SA2->A2_TIPO
				jFld600["A1_EST"  ]:= SA2->A2_EST
				jFld600["A1_INSCR"]:=  SA2->A2_INSCR
				jFld600["A1_CONTRIB"] :=  SA2->A2_CONTRIB
				jFld600["A1_TIPO"] :=  SA2->A2_TIPO

				If !Empty(oMdlSD2:GetValue("D2_TES"))
					A600TES()
				EndIf

				oMdlSF2:LoadValue("F2_LOJA", SA2->A2_LOJA)
			EndIf
			RestArea(aAreaSA2)
		Else
			aAreaSA1	:= SA1->(GetArea())
			dbSelectArea("SA1")
			dbSetOrder(1)
			If SA1->(dbSeek(FWxFilial("SA1") + cCliFor + AllTrim(cLoja)))
				jFld600["A1_COD"]:= SA1->A1_COD
				jFld600["A1_LOJA" ]:= SA1->A1_LOJA
				jFld600["A1_TIPO" ]:= SA1->A1_TIPO
				jFld600["A1_EST"  ]:= SA1->A1_EST
				jFld600["A1_INSCR"] :=  SA1->A1_INSCR
				jFld600["A1_CONTRIB"] :=  SA1->A1_CONTRIB
				jFld600["A1_TIPO"] :=  SA1->A1_TIPO

				If !Empty(oMdlSD2:GetValue("D2_TES"))
					A600TES()
				EndIf

				oMdlSF2:LoadValue("F2_LOJA", SA1->A1_LOJA)
			EndIf
			RestArea(aAreaSA1)
		EndIf

		RefrView()
		M->F2_CLIENTE := cCliFor
	EndIf

	RestArea(aArea)

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600DOCREF
 Realiza a chamada da interface de vínculo da Nota de Crédito/Débito com a origem.

@param nOpc = 1 -> Inclusão de vínculo / 2 = Visualização de vínculo
@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function A600DOCREF(nOpc)
	Local aButtons := { {.F., Nil},;            //- Copiar
							{.F., Nil},;            //- Recortar
							{.F., Nil},;            //- Colar
							{.F., Nil},;            //- Calculadora
							{.F., Nil},;            //- Spool
							{.F., Nil},;            //- Imprimir
							if(nOpc==1,{.T., STR0016},{.F., Nil}),;        //- "Enviar"
							{.T., STR0017},;        //- "Cancelar"
							{.F., Nil},;            //- WalkThrough
							{.F., Nil},;            //- Ambiente
							{.F., Nil},;            //- Mashup
							{.F., Nil},;            //- Help
							{.F., Nil},;            //- Formulário HTML
							{.F., Nil},;            // - ECM
							{.F., Nil}}             // - Desabilitar o botão Salvar e Criar Novo

	Local lIncBkp := INCLUI
	Local oMdlSD2 := Nil

	Default nOpc := 1

	If jFld600["F2_TIPO"] $ "5|6" 
		oMdlSD2	:= oModelNCND:GetModel("ITENSDETAIL")

		If !Empty(jFld600["A1_COD"]) .And. !Empty(jFld600["A1_LOJA"]) .And. !Empty(oMdlSD2:GetValue("D2_COD"))
			If jFld600["F2_TIPO"] == "6" .and. jFld600["F2_TPCOMPL"] $ '47'
				FATDOCREFSetVinc("2") //-- Vinculo por item
				FWExecView(STR0023, "FATDOCREF", MODEL_OPERATION_INSERT, /*oDlg*/, {||.T.}, /*bOk*/, 10, aButtons, /*bCancel*/, /*cOperatId*/, /*cToolBar*/, )
			ElseIf jFld600["F2_TIPO"] == "6" .and. jFld600["F2_TPCOMPL"] == '6'
				FWExecView(STR0033, 'FATVINCADT', MODEL_OPERATION_INSERT, /*oDlg*/, {||.T.}, {||.T.}, 10, aButtons, /*bCancel*/, /*cOperatId*/, /*cToolBar*/, )
			Else
				FATDOCREFSetVinc("1") //-- Todos os demais tipos são vínculo por NF
				FWExecView(STR0023, "FATDOCREF", MODEL_OPERATION_INSERT, /*oDlg*/, {||.T.}, /*bOk*/, 10, aButtons, /*bCancel*/, /*cOperatId*/, /*cToolBar*/, )
			EndIf
		Else 
			Help(Nil, Nil, "A600DOCREF", Nil, STR0024, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0025}) //"Faltam informações para buscar o Documento Referenciado." ## "Para utilizar esta opção, deve selecionar o tipo da Nota, Cliente/Fornecedor, Loja e adicionar ao menos um item."
		EndIf		
	EndIf

	If !lIncBkp //-- Restauro o valor da variável global INCLUI alterada pelo execview.
		INCLUI := .F.
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600GRVREF
	Realiza a gravação dos documentos referênciados
	da Nota de Crédito/Débito na tabela DKN
@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function A600GRVREF()

	Local aDados   	 as array 
	Local aItVinc 	 as array
	Local nX   		 as numeric
	Local nZ 		 as numeric
	Local cItem		 as character
	Local oMdlSD2	 as object
	Local cTpMov	 as character

	aDados 		:= {}
	aItVinc 	:= {}
	nX 			:= 1
	nZ 			:= 1
	cItem		:= "00"
	oMdlSD2		:= Nil
	cTpMov		:= "2"

	DbSelectArea("DKN")

	If jFld600["F2_TPCOMPL"] $ "1257"
		cTpMov := "1"
	EndIf

	If jFld600["F2_TIPO"] == "6" .and. jFld600["F2_TPCOMPL"] $ '347' // -- Vinculo por item

		oMdlSD2	:= oModelNCND:GetModel("ITENSDETAIL")

		For nX := 1 To oMdlSD2:Length()

			oMdlSD2:GoLine(nX)
			If !oMdlSD2:IsDeleted(nX)	
				// -- Reabertura de tela, o Json já tem dados vinculados.
				If jDocRef <> Nil .and. jDocRef:hasproperty('itens') .and.  len(jDocRef['itens']) > 0
					aDados := aClone(jDocRef["itens"])
					nPos := aScan(aDados, {|x| x['item'] + alltrim(x['produto'])  == oMdlSD2:GetValue("D2_ITEM") + Alltrim(oMdlSD2:GetValue("D2_COD"))})
					If nPos > 0
						aItVinc := aClone(jDocRef["itens"][nPos]['documentos'])
						For nZ := 1 to len(aItVinc)
							cItem := Soma1(cItem)

							RecLock("DKN",.T.)
							// -- Dados do documento de crédito/débito
							DKN->DKN_FILIAL	:= fwxFilial("DKN")
							DKN->DKN_TPMOV	:= cTpMov //-- 1 - Entrada -- 2 - Saída
							DKN->DKN_DOC	:= jFld600["F2_DOC"]
							DKN->DKN_SERIE	:= jFld600["F2_SERIE"]
							DKN->DKN_CLIfOR	:= jFld600["A1_COD"]
							DKN->DKN_LOJA	:= jFld600["A1_LOJA"]
							DKN->DKN_ITEMNF := cItem

							// -- Dados do documento referênciado
							DKN->DKN_DOCREF := aItVinc[nZ]['documento']
							DKN->DKN_SERREF := aItVinc[nZ]['serie']
							DKN->DKN_PARREF := aItVinc[nZ]['cliente']
							DKN->DKN_LOJREF := aItVinc[nZ]['loja']
							DKN->DKN_CHVNFE := aItVinc[nZ]['chave']				
							DKN->DKN_ITNFRE := aItVinc[nZ]['item']
							DKN->DKN_ITXML := aItVinc[nZ]['itemxml']
							DKN->DKN_ORIGEM := 'MATA600'

							DKN->(MsUnLock())
						Next nZ
					EndIf
				EndIf
			EndIf
		Next nX
	Else //-- Vinculo por nf
		aDados := jDocRef["documentos"]

		For nX := 1 to len(aDados)

			RecLock("DKN",.T.)
			// -- Dados do documento de crédito/débito
			DKN->DKN_FILIAL	:= fwxFilial("DKN")
			DKN->DKN_TPMOV	:= cTpMov //-- 1 - Entrada -- 2 - Saída
			DKN->DKN_DOC	:= jFld600["F2_DOC"]
			DKN->DKN_SERIE	:= jFld600["F2_SERIE"]
			DKN->DKN_CLIFOR	:= jFld600["A1_COD"]
			DKN->DKN_LOJA	:= jFld600["A1_LOJA"]

			// -- Dados do documento referênciado
			DKN->DKN_DOCREF := aDados[nX]['documento']
			DKN->DKN_SERREF := aDados[nX]['serie']
			DKN->DKN_PARREF := aDados[nX]['cliente']
			DKN->DKN_LOJREF := aDados[nX]['loja']
			DKN->DKN_CHVNFE := aDados[nX]['chave']
			DKN->DKN_ORIGEM := 'MATA600'
		Next nX
	EndIf
	FwFreeArray(aDados)
	FwFreeArray(aItVinc)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600F4
Função acionada através da tecla F4

@return		lRet
@author 	CRM/Faturamento
@since 		11/2025
/*/
//------------------------------------------------------------------------------
Static Function A600F4()
	Local aArea     := GetArea()
	Local lGrade    := GetMv("MV_GRADE")
	Local bSetKey   := SetKey(VK_F4,Nil)
	Local cProduto  := ""
	Local cLocal    := ""
	Local cTes      := ""
	Local oModelItem := NIL

	oModelItem := oModelNCND:GetModel("ITENSDETAIL")

	cProduto  := oModelItem:GetValue("D2_COD")
	cLocal    := oModelItem:GetValue("D2_LOCAL")
	cTes      := oModelItem:GetValue("D2_TES")

	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(fwxFilial("SF4")+cTes)

	If ( lGrade )
		MatGrdPrRf(@cProduto)
	EndIf

	Do Case
		Case "D2_QUANT" $ ReadVar()
			MaViewSB2(cProduto,,cLocal)
	EndCase

	SetKey(VK_F4,bSetKey)
	RestArea(aArea)
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidProd
Valiadação do campo Produto (D2_COD)

@return		lRet
@author 	CRM/Faturamento
@since 		11/2025
/*/
//------------------------------------------------------------------------------
Static Function ValidProd() as Logical
	Local aArea        		:= GetArea()
	Local lRet             	:= .T.
	Local oModelItem 		:= NIL
	Local cTes              := ""

	oModelItem := oModelNCND:GetModel("ITENSDETAIL")

	cProduto := oModelItem:GetValue("D2_COD")
	cTes     := oModelItem:GetValue("D2_TES")

	DbSelectArea('SB1')
	SB1->( DBSetOrder( 1 ) )
	If  SB1->( !MsSeek(xFilial("SB1")+cProduto,.F.) )
		Help(" ",1,"D2_COD",,STR0031, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0032})
		lRet  := .F.
	Else
		If  !RegistroOk("SB1")
			lRet  := .F.
		Endif
	EndIf

	SB1->( MsSeek(FwxFilial("SB1")+cProduto,.F.) )
	oModelItem:SetValue("D2_TP", SB1->B1_TIPO)
	oModelItem:LoadValue("D2_SEGUM", SB1->B1_SEGUM)
	oModelItem:LoadValue("D2_TES", "")

	RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidQuant
Validação do campo Quantidade (D2_QUANT)

@return		lRet
@author 	CRM/Faturamento
@since 		11/2025
/*/
//------------------------------------------------------------------------------
Function ValidQuant() as Logical
    Local cProduto      := ""
    Local nQtdVen       := 0
    Local oMdlCabec     := Nil
    Local oModelItem    := Nil
    Local oModelNCND    := FwModelActive()
    Local lRet          := .T.

    oMdlCabec   := oModelNCND:GetModel("CABMASTER")
    oModelItem  := oModelNCND:GetModel("ITENSDETAIL")
    cTpCompl    := oMdlCabec:GetValue("F2_TPCOMPL")
    cProduto    := oModelItem:GetValue("D2_COD")
    nQtdVen     := oModelItem:GetValue("D2_QUANT")

    If cTpCompl == "7" .And. nQtdVen <= 0
        Help(Nil, Nil, "QUANT", Nil, STR0049, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0050}) //"Tipo 7 - Perda em estoque, não permite quantidade zerada ou negativa."##"Informe uma quantidade."
        lRet := .F.
    EndIf

    oModelItem:LoadValue("D2_QTSEGUM",ConvUm(cProduto,nQtdVen,0,2))
    RefrView()
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidSegUM
Validação do campo Segunda Unidade de Medida (D2_QUANT)

@return		lRet
@author 	CRM/Faturamento
@since 		11/2025
/*/
//------------------------------------------------------------------------------
Function ValidSEGUM() as Logical
	Local nDigtQT		:= &(ReadVar())
	Local nQtdConv  	:= 0
	Local lGrade    	:= MaGrade()
	Local cProduto  	:= ""
	Local nQtdVen   	:= 0
	Local oModelItem   	:= Nil

	Default oModelNCND  := FwModelActive()

	oModelItem := oModelNCND:GetModel("ITENSDETAIL")

	cProduto 	:= oModelItem:GetValue("D2_COD")
	nQtdVen    := oModelItem:GetValue("D2_QUANT")

	If ( lGrade )
		MatGrdPrrf(@cProduto)
	EndIf

	nQtdConv  := Round( ConvUm(cProduto,nQtdVen,nDigtQT,1), TamSX3( "D2_QUANT" )[2] )

	oModelItem:SetValue("D2_QUANT", nQtdConv )
	RefrView()
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600Cpos
Função genérica para verificação da existencia do cadastro.

@return		lRet
@author 	CRM/Faturamento
@since 		11/2025
/*/
//------------------------------------------------------------------------------
Static Function A600Cpos(cModel, cCampo)
	Local aArea 	:= GetArea()
	Local lRet		:= .F.
	Local cValCampo	:= ""
	Local cCli  := ""
	Local cLoja := ""

	Default cModel := ""
	Default cCampo := ""

	If !Empty(cCampo) .and. !Empty(cModel)
		cValCampo := oModelNCND:GetModel(cModel):GetValue(cCampo)
	EndIf

	If !Empty(cValCampo)
		Do Case
		Case cCampo == "F2_CLIENTE" .Or. cCampo == "F2_LOJA"
				cCli :=  oModelNCND:GetModel("CABMASTER"):GetValue("F2_CLIENTE")
				cLoja :=  oModelNCND:GetModel("CABMASTER"):GetValue("F2_LOJA")

				If  oModelNCND:GetModel("CABMASTER"):GetValue("F2_TIPO") == "6" .And.  oModelNCND:GetModel("CABMASTER"):GetValue("F2_TPCOMPL") == "7"
					SA2->(DbSetOrder(1))
					If SA2->(dbSeek(FwxFilial("SA2") + cCli + AllTrim(cLoja)))
						lRet := .T.
					ElseIf cCampo == "F2_CLIENTE" .And. SA2->(dbSeek(FwxFilial("SA2") + cCli))
						lRet := .T.
						oModelNCND:GetModel("CABMASTER"):LoadValue("F2_LOJA", SA2->A2_LOJA) 
					EndIf
				Else
					SA1->(DbSetOrder(1))
					If SA1->(dbSeek(FWxFilial("SA1") + cCli + AllTrim(cLoja)))
						lRet := .T.
					ElseIf cCampo == "F2_CLIENTE" .And. SA1->(dbSeek(FWxFilial("SA1") + cCli))
						lRet := .T.
						oModelNCND:GetModel("CABMASTER"):LoadValue("F2_LOJA", SA1->A1_LOJA) 
					EndIf
				EndIf
		Case cCampo == "D2_COD"
			SB1->(DbSetOrder(1))
			If  SB1->( dbSeek(FwxFilial("SB1")+cValCampo,.F.) ) .And. RegistroOk("SB1")
				lRet  := .T.
			EndIf
		Case cCampo == "D2_TES"
			SF4->(DbSetOrder(1))
			If SF4->( dbSeek(FWxFilial("SF4") + cValCampo,.F.) )
				lRet := .T.
			EndIf
		Case cCampo == "D2_LOCAL"
			SB2->(DbSetOrder(1))
			If !Empty(oModelNCND:GetModel(cModel):GetValue("D2_COD"))
				If SB2->( dbSeek(FWxFilial("SB2") + oModelNCND:GetModel(cModel):GetValue("D2_COD") + cValCampo,.F.) )
					lRet := .T.
				EndIf
			EndIf
		Case cCampo == "F2_CODA1U"
			A1U->(DbSetOrder(1))
			If A1U->(dbSeek(FWxFilial("A1U") + cValCampo))
				lRet := .T.
			Endif
		OtherWise
			lRet := .T.
		EndCase
	Else
		lRet := .T.
	EndIf

	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetJfld600
Função para retornar o conteúdo da variável jFld600.

@return		Nil
@author 	CRM/Faturamento
@since 		11/2025
/*/
//------------------------------------------------------------------------------
Function GetJfld600()
Return jFld600

Static Function RefrView()
	Local oView		 	:= FWViewActive()
	If oView <> Nil .And. oView:IsActive()
		oView:Refresh()
	EndIf
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} TriPrcVen                 

@sample     TriPrcVen() - Gatilho do campo D2_PRCVEN
@return     nRet - valor numérico
@author     CRM/Faturamento

/*/
//------------------------------------------------------------------------------
Static Function TriPrcVen() as numeric
	Local oModelNCND    := FwModelActive()
	Local oMdlSD2		:= Nil
	Local nRet          := 0

	oMdlSD2 := oModelNCND:GetModel("ITENSDETAIL")
	nRet 	:= if(oMdlSD2:GetValue("D2_QUANT") > 0,oMdlSD2:GetValue("D2_PRCVEN") * oMdlSD2:GetValue("D2_QUANT"), oMdlSD2:GetValue("D2_PRCVEN"))

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600F12
	Chamada da função pergunte de Contabilização

@author CRM/Faturamento
@since 11/25
/*/
//------------------------------------------------------------------------------
Static Function A600F12()

Pergunte("MT600A",.T.)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600IniObj
Inicializa o objeto jFld600

@return		Nil
@author 	CRM/Faturamento
@since 		11/2025
/*/
//------------------------------------------------------------------------------
Function A600IniObj(jFldExec)
	Local aArea    := GetArea()
	Local aAreaSA2 := {}
	Local aAreaSA1 := {}
	Local cCliFor  := ""
	Local cLoja  := ""
	Default jFldExec := Nil

	jFld600 := JsonObject():new()
	jFld600["F2_DOC"] := ""
	jFld600["F2_SERIE"] := ""

	If jFldExec <> Nil
		jFld600 := jFldExec
	EndIf

	F600INIT()

	If !oModelNCND == Nil
		jFld600["F2_TPCOMPL"] := M->F2_TPCOMPL
		oMdlSF2	:= oModelNCND:GetModel("CABMASTER")
		oMdlSD2	:= oModelNCND:GetModel("ITENSDETAIL")
		cCliFor := jFld600["A1_COD"]  := oMdlSF2:GetValue("F2_CLIENTE")
		cLoja   := jFld600["A1_LOJA" ]:= oMdlSF2:GetValue("F2_LOJA")

		If oMdlSF2:GetValue("F2_TIPO") == "6" .And. oMdlSF2:GetValue("F2_TPCOMPL") == "7"
			aAreaSA2	:= SA2->(GetArea())
			dbSelectArea("SA2")
			dbSetOrder(1)
			If SA2->(dbSeek(FwxFilial("SA2") + cCliFor + AllTrim(cLoja)))
				jFld600["A1_TIPO" ]:= SA2->A2_TIPO
				jFld600["A1_EST"  ]:= SA2->A2_EST
				jFld600["A1_INSCR"]:=  SA2->A2_INSCR
				jFld600["A1_CONTRIB"] :=  SA2->A2_CONTRIB
				jFld600["A1_TIPO"] :=  SA2->A2_TIPO
			EndIf
			RestArea(aAreaSA2)
			FwFreeArray(aAreaSA2)
		Else
			aAreaSA1	:= SA1->(GetArea())
			dbSelectArea("SA1")
			dbSetOrder(1)
			If SA1->(dbSeek(FWxFilial("SA1") + cCliFor + AllTrim(cLoja)))
				jFld600["A1_TIPO" ]:= SA1->A1_TIPO
				jFld600["A1_EST"  ]:= SA1->A1_EST
				jFld600["A1_INSCR"] :=  SA1->A1_INSCR
				jFld600["A1_CONTRIB"] :=  SA1->A1_CONTRIB
				jFld600["A1_TIPO"] :=  SA1->A1_TIPO
			EndIf
			RestArea(aAreaSA1)
			FwFreeArray(aAreaSA1)
		EndIf
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600Local                 
Valid do campo D2_LOCAL (ARMAZEM)

@return     lRet
@author     CRM/Faturamento
@since 		11/2025
/*/
//------------------------------------------------------------------------------
Static Function A600Local() as Logical
	Local aArea 	:= GetArea()
	Local oMdlSD2	:= oModelNCND:GetModel("ITENSDETAIL")
	Local cLocal	:= oMdlSD2:GetValue("D2_LOCAL")
	Local cCq 		:= SuperGetMv("MV_CQ",.F.)
	Local lRet 		:= .T.

	If AllTrim(cLocal) == AllTrim(cCq)
		//STR0035 - "O armazém utilizado não pode ser o mesmo contido no parâmetro MV_CQ"
		//STR0036 - "Utilize um armazém diferente."
		Help(Nil, Nil, "MVCQ", Nil, STR0035, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0036})
		lRet:= .F.
	EndIf

	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidInsert
Pós-validação do modelo.

@return		lContinua
@author 	CRM/Faturamento
@since 		11/2025
/*/
//------------------------------------------------------------------------------
Static Function ValidInsert(oModelNCND)
	Local lContinua  := .T.
	Local jFatVinc   := GetJVAdt()
	//Local oMdlTot 	 := oModelNCND:GetModel("TOTAIS")
	//Local nValTit    := 0
	//Local nValBru	 := oMdlTot:GetValue("F2_VALBRUT")
	Local oModelItem := oModelNCND:GetModel("ITENSDETAIL")
	Local cTipo		 := FwFldGet("F2_TIPO")
	Local cTpComp    := FwFldGet("F2_TPCOMPL")
	Local ljDocRefD  := cTpComp $ "1258" .And. (jDocRef == Nil .Or. !jDocRef:hasproperty('documentos') .Or. jDocRef['documentos'] == Nil .Or. Len(jDocRef['documentos']) <= 0)
    Local ljDocRefI  := cTpComp $ "347" .And. (jDocRef == Nil .Or. !jDocRef:hasproperty('itens') .Or. jDocRef['itens'] == Nil .Or. Len(jDocRef['itens']) <= 0)
	Local ljFatVinc  := cTpComp == "6" .And. (jFatVinc == Nil .Or. !jFatVinc:hasproperty('identification') .Or. jFatVinc['identification'] == Nil .Or. Len(jFatVinc['identification']) <= 0)
	Local lNewInvoic := Iif(__RpoRelease >= '12.1.2410',;
						tlpp.ffunc("backoffice.fat.documento.UsaNewInvoice") .And.;
						tlpp.call('backoffice.fat.documento.UsaNewInvoice()'),.F.)
	Local cSerieId	:= ""
	Local cTypeDoc	:= ""
	Local nPosQuant := aScan(oModelItem:aHeader,{|x|AllTrim(x[2])=="D2_QUANT"})
	Local nX		:= 0
	Local nQtdItens := 0
	Local nQtdVinc  := 0

	If oModelNCND:GetOperation() == 3
		If ljDocRefD .Or. ljDocRefI .Or. ljFatVinc
			Help(Nil, Nil, "NOTVINC", Nil, STR0045, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0046}) //"Para incluir Notas de Débito é necessário vincular pelo menos um documento ou titulo de referência. ##Clique na opção Vincular e selecione os registros para inclusão da Nota."
			lContinua := .F.
		EndIf

		If lContinua .And. cTipo == "6" .And. cTpComp == "7" .And. jDocRef["itens"] <> Nil
			nQtdItens := oModelItem:Length() 
			nQtdVinc := len(jDocRef["itens"])

			If nQtdItens <> nQtdVinc
				For nX := 1 To nQtdItens
					oModelItem:GoLine(nX)
					If !oModelItem:IsDeleted(nX)
						If aScan(jDocRef["itens"], {|x| x['item'] ==StrZero(nX,2)}) == 0
							Help(Nil, Nil, "NOTVINCITEM", Nil, STR0053 + oModelItem:GetValue("D2_ITEM") + STR0054, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0055}) //"O item "##" não possui documento de referência vinculado."##"Vincule pelo menos um documento de referência para esse item."
							lContinua := .F.
							Exit
						EndIf
					EndIF
				Next nX
			EndIf
		EndIf

		If lContinua .And. cTipo == "6" .And. cTpComp == "7"  .And. aScan(oModelItem:aDatamodel,{|x| x[1][1][nPosQuant]==0}) > 0
			Help(Nil, Nil, "QTDZERO", Nil, STR0047, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0048}) //"Quantidade zerada"##"Para nota de Perda em Estoque informe quantidade."
			lContinua := .F.
		EndIf

		//Trecho comentado até fazermos algumas definições sobre a NT.
		/* If lContinua .And. cTipo == "6" .And. cTpComp == "6"
			jFatVinc   := GetJVAdt()
			nValTit    := IIf(jFatVinc:hasproperty('totalTitulos'), jFatVinc["totalTitulos"], 0)

			If nValBru <> nValTit
				lContinua:= .F.
				Help(Nil, Nil, "VALDIF", Nil, STR0039, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0040}) //"Valores inconsistentes"##"Verifique o valor do documento x valor do(s) título(s)."
			EndIf
		EndIf */

		If lContinua .And. !IsBlind()
			If lNewInvoic 
				lContinua := backoffice.fat.documento.TypeSerInvoice(@jFld600["F2_SERIE"],@cTypeDoc)
			ElseIf Empty(jFld600["F2_SERIE"])
				lContinua := Sx5NumNota(@jFld600["F2_SERIE"],SuperGetMV("MV_TPNRNFS"),,,,@cSerieId,dDataBase, ,@cTypeDoc) // O parametro cSerieId deve ser passado para funcao Sx5NumNota afim de tratar a existencia ou nao do mesmo numero na funcao VldSx5Num do MATXFUNA.PRX
			EndIf

			If !lContinua
				Help(Nil, Nil, "CancNumNota", Nil, STR0056, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0057}) //"Não informada a série para geração da nota."##"Favor informar a série."
			EndIf
		EndIf
	EndIf

Return lContinua

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldArtNCND
Validação de utilização da rotina MATA600.

@return		lRet
@author 	CRM/Faturamento
@since 		11/2025
/*/
//------------------------------------------------------------------------------
Function VldArtNCND()
	Local lDocRef 	:= FWAliasInDic("DKN") .And. ChkFile("DKN") .And. FindFunction("FATDOCREF") 
	Local lFatVic 	:= FWAliasInDic("F7Q") .And. ChkFile("F7Q") .And. FindFunction("FATVINCADT") .And. FindClass("totvs.protheus.backoffice.fin.debittaxinvoice") 
	Local lPergunt  := FWSX1Util():ExistPergunte("MTA600") .And. FWSX1Util():ExistPergunte("MT600A") 
	Local lRet 		:= .T.

	If !lDocRef .And. !lFatVic .And. !lPergunt
		Help(Nil, Nil, "A600DOCREF", Nil, STR0026, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0027})
		lRet := .F.
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MT600Oper
Retorno o D2_OPER pela linha

@return		cD2Oper
@author 	CRM/Faturamento
@since 		12/2025
/*/
//------------------------------------------------------------------------------
Function MT600Oper(cItem)

Local cD2Oper		:= ""
Local nPosOper		:= 0

Default cItem 		:= ""

If __aD2Opers != Nil .And. Len(__aD2Opers) > 0  .And. (nPosOper := Ascan(__aD2Opers,{|x| x[1] == cItem})) > 0

	cD2Oper := __aD2Opers[nPosOper][2]
EndIf

Return cD2Oper
