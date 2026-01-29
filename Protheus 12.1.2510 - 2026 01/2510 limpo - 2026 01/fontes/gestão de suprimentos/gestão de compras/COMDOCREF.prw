#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "COMDOCREF.CH"

Static cOperVinc 	:= "1" // 1 =  Vinculo de documento // 2 = Vinculo de item de documento
Static cTipo 		:= "1" // 1 = Credito/Debito -  2 = Tipo normal - Vinc com ND Pgto Antecipado - 3 = Compra Governamental
Static lCsdXML 	 	:= SuperGetMV( 'MV_CSDXML', .F., .F. ) .and. FWSX3Util():GetFieldType( "D1_ITXML" ) == "C" .and. ChkFile("DKA") .and. ChkFile("DKB") .and. ChkFile("DKC") .and. ChkFile("D3Q")
Static cOrigem   	:= ""
Static lOrigSF2		:= .F.
Static cForCli		:= "F1_FORNECE"
Static lSDcRefXml	:= .F.
Static lP103View	:= .F.

#DEFINE OP_VINC_NF	 "1" //  Vinculo de documento
#DEFINE OP_VINC_ITEM "2" //  Vinculo de item de documento

//-------------------------------------------------------------------
/*/{Protheus.doc} COMDOCREF
Interface responsável pelo vínculo de documentos de referência
em notas de crédito e débito no mata103.

A interface pode vincular itens por NF ou por Item a depender
da variável cOperVinc definida na função DOCREFSetVinc.

É acionada no menu de outras ações do documento de entrada.

@author Leandro Fini
@since 09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function COMDOCREF()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model da tela
@author Leandro Fini
@since 09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStrCab := DOCREFSTRM(1)
	Local oStrIte := DOCREFSTRM(3)
	Local oStrFil := DOCREFSTRM(2,2)
	Local oStrSel := DOCREFSTRM(2,3)
	Local oModel  := nil

	oModel := MPFormModel():New('COMDOCREF',/*bPreVld*/, /*{|oModel| PosValid(oModel)}*/, {|oModel| DOCREFCommit(oModel)}) 

	oModel:SetDescription(STR0001) //"Documentos de origem"

	oModel:AddFields( 'CABMASTER', , oStrCab,,, )
	oModel:GetModel( 'CABMASTER' ):SetDescription(STR0002)//"Cabeçalho"

	if cOperVinc == OP_VINC_ITEM
		oModel:AddGrid( 'ITENSDETAIL', 'CABMASTER', oStrIte, /*bLinPre*/, /*bLinPos*/ ,,, )
		oModel:GetModel( 'ITENSDETAIL' ):SetDescription(STR0003) //"Itens"

		oModel:AddGrid( 'SELECTDETAIL', 'ITENSDETAIL', oStrSel, /*bLinPre*/, /*bLinPos*/ ,,, )
		oModel:GetModel( 'SELECTDETAIL' ):SetDescription(STR0004) //"Documentos Selecionados"
		oModel:SetRelation('ITENSDETAIL', { { 'D1_FILIAL', 'fwxFilial("SD1")' }, { 'D1_DOC', 'D1_DOC' }, { 'D1_SERIE', 'D1_SERIE' }, { 'D1_FORNECE', 'D1_FORNECE' }, { 'D1_LOJA', 'D1_LOJA'}, { 'D1_COD', 'D1_COD' } }, SD1->(IndexKey(1)) ) // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA
	else 
		oModel:AddGrid( 'SELECTDETAIL', 'CABMASTER', oStrSel, /*bLinPre*/, /*bLinPos*/ ,,, )
		oModel:GetModel( 'SELECTDETAIL' ):SetDescription(STR0005)//"Documentos Vinculados"
	endif

	oModel:GetModel( 'SELECTDETAIL' ):SetOptional(.T.)
	
	if !lP103View .And. !lSDcRefXml
		oModel:AddGrid( 'FILTDETAIL', 'CABMASTER', oStrFil, /*bLinPre*/, /*bLinPos*/ ,,, )
		oModel:GetModel( 'FILTDETAIL' ):SetDescription(STR0006) //"Resultado dos Filtros"
		oModel:GetModel('FILTDETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('FILTDETAIL'):SetNoDeleteLine(.T.)
		oModel:GetModel( 'FILTDETAIL' ):SetOptional(.T.)
	endif

	oStrIte:SetProperty( "*" , MODEL_FIELD_OBRIGAT, .F. )
	oStrFil:SetProperty( "*" , MODEL_FIELD_OBRIGAT, .F. )
	oStrSel:SetProperty( "*" , MODEL_FIELD_OBRIGAT, .F. )
	oModel:SetPrimaryKey({'DOC', 'SERIE','FORNECLI','LOJA'})

	if cOperVinc == OP_VINC_ITEM
		oModel:GetModel('ITENSDETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('ITENSDETAIL'):SetNoInsertLine(.T.)
	endif
	
	
	oModel:SetVldActivate( {|| .T. } )

	//--------------------------------------
	//		Realiza carga dos grids antes da exibicao
	//--------------------------------------
	oModel:SetActivate( { |oModel| DOCREFGetData( oModel ) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional da Rotina 

@author Leandro Fini
@since 09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   
	Local aRotina := {}

	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.COMDOCREF' OPERATION 3 ACCESS 0 //-- Incluir
Return(aRotina) 


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface com usuário
@author Leandro Fini
@since 09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel("COMDOCREF") 
	Local oView    := FWFormView():New() 
	Local oStrCab  := DOCREFSTRV(1) 
	Local oStrIte  := DOCREFSTRV(3) 
	Local oStrFil  := DOCREFSTRV(2,2) 
	Local oStrSel  := DOCREFSTRV(2,3) 
	Local lVisual  := (lP103View .Or. lSDcRefXml)

	oStrCab:SetProperty("FORNECLI",MVC_VIEW_CANCHANGE, .F.)
	oStrCab:SetProperty("LOJA",MVC_VIEW_CANCHANGE, .F.)
	oStrIte:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)
	oStrFil:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)
	oStrSel:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)

	if !lVisual
		oStrFil:SetProperty("D1_YOK",MVC_VIEW_CANCHANGE, .T.)
		oStrSel:SetProperty("D1_YOK",MVC_VIEW_CANCHANGE, .T.)
	endif
	oView:SetModel(oModel)
	oView:AddField('VIEW_CAB'	, oStrCab, 'CABMASTER')

	if !lVisual
		oView:AddGrid( 'VIEW_FILT' , oStrFil, 'FILTDETAIL' )
	endif

	oView:AddGrid( 'VIEW_SELECT' , oStrSel, 'SELECTDETAIL' )

	if cOperVinc == OP_VINC_ITEM

		oView:CreateHorizontalBox( 'SUPERIOR'   , 030 )   
		oView:CreateHorizontalBox( 'INFERIOR'   , 030 )
		oView:CreateHorizontalBox( 'INFERIOR2'   , 040 )

		oView:AddGrid( 'VIEW_ITENS' , oStrIte, 'ITENSDETAIL' )
		oView:SetOwnerView( 'VIEW_ITENS', 'INFERIOR')
		oView:EnableTitleView('VIEW_ITENS','Itens'	)

		oView:SetViewProperty('VIEW_ITENS', 'CHANGELINE', {{ |oView| changeItLin(oView) }})
	else 
		oView:CreateHorizontalBox( 'SUPERIOR'   , 030 )   
		oView:CreateHorizontalBox( 'INFERIOR2'   , 070 )
	endif

	oView:SetOwnerView( 'VIEW_CAB', 'SUPERIOR') 

	if !lVisual
		oView:CreateVerticalBox("FILTRO", 50,'INFERIOR2')
		oView:CreateVerticalBox("SELECT", 50, 'INFERIOR2')
	else 
		oView:CreateVerticalBox("SELECT", 100, 'INFERIOR2')
	endif

	if !lVisual
		oView:SetOwnerView( 'VIEW_FILT', 'FILTRO')
	endif
	oView:SetOwnerView( 'VIEW_SELECT', 'SELECT') 
	 
	if !lVisual
		oView:AddUserButton("Buscar Documentos" ,'',{|| FWMsgRun(, {|| DOCREFORIG(oModel) }, STR0008, STR0009) } ) // "Aguarde" "Carregando Documentos..."
	endif
	
	oView:EnableTitleView('VIEW_SELECT',STR0004) //"Documentos Selecionados"
	
	if !lVisual
		oView:EnableTitleView('VIEW_FILT',STR0006) //"Resultado dos Filtros"
	endif

	oStrCab:AddGroup( 'GRP_COMDOCREF_001',STR0010, '', 2 )//"Filtros"

	oStrCab:SetProperty( '*'            , MVC_VIEW_GROUP_NUMBER, 'GRP_COMDOCREF_001' )

	oView:showInsertMsg(.F.) // -- Desativa a mensagem registro inserido.
	oView:SetViewAction('ASKONCANCELSHOW', {|oView| .F.}) // -- Desativa mensagem de "há alterações não salvas"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DOCREFSTRM
Campos do modelo
@author Leandro Fini
@since 09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
static function DOCREFSTRM(nOpc,nGrid)

	Local oStructMn	:= FWFormModelStruct():New()
	Local aTamSX3	:= {}
	Local cTitle    := ""
	Local lVisual := (lP103View .Or. lSDcRefXml)

	Default nOpc := 1
	Default nGrid := 2

	if nOpc == 1 //-- Estrutura do Modelo - CABEÇALHO 

		aTamSX3	:= TamSX3(cForCli)
		cTitle := GetSX3Cache(cForCli, 'X3_TITULO')
		oStructMn:AddField(cTitle, cTitle, 'FORNECLI', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) 

		aTamSX3	:= TamSX3("F1_LOJA")
		cTitle := GetSX3Cache('F1_LOJA', 'X3_TITULO')
		oStructMn:AddField(cTitle, cTitle, 'LOJA', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)

		aTamSX3	:= TamSX3("F1_DOC")
		cTitle := GetSX3Cache('F1_DOC', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'DOC'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) 

		aTamSX3	:= TamSX3("F1_SERIE")
		cTitle := GetSX3Cache('F1_SERIE', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'SERIE' , 'C', aTamSX3[1], aTamSX3[2], /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)

		aTamSX3	:= TamSX3("F1_EMISSAO")
		oStructMn:AddField(STR0011, STR0011, 'DTDE', 'D', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) //"Ini Emissão"

		aTamSX3	:= TamSX3("F1_EMISSAO")
		oStructMn:AddField(STR0012, STR0012, 'DTATE', 'D', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)//"Fim Emissão"
		
		aTamSX3	:= TamSX3("F1_CHVNFE")
		oStructMn:AddField(STR0013, STR0013, 'CHVNFE', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)//"Chave NF"

	elseif nOpc == 2 //-- Estrutura do Modelo - ITENS 

		if nGrid == 2  .and. !lVisual// -- Grid de filtro
			aTamSX3	:= TamSX3("AL_DOCAE")
			oStructMn:AddField(STR0014, STR0014, 'D1_YOK'  , 'L', aTamSX3[1], aTamSX3[2]    , {|| setVinc()}, {|| .T.}, {}, .T., , .F., .T., .T.) //Seleciona
		elseif nGrid == 3 .and. !lVisual // -- Grid de Documentos vinculados
			aTamSX3	:= TamSX3("AL_DOCAE")
			oStructMn:AddField(STR0015, STR0015, 'D1_YOK'  , 'L', aTamSX3[1], aTamSX3[2]    , {|| delVinc()}, {|| .T.}, {}, .T., , .F., .T., .T.)//"Remover"
		endif

		if cOperVinc == OP_VINC_ITEM

			aTamSX3	:= TamSX3("D1_ITEM")
			cTitle := GetSX3Cache('D1_ITEM', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'D1_ITEM'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("D1_ITXML")
			cTitle := GetSX3Cache('D1_ITXML', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'D1_ITXML'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("D1_DOC")
			cTitle := GetSX3Cache('D1_DOC', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'D1_DOC'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("D1_SERIE")
			cTitle := GetSX3Cache('D1_SERIE', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'D1_SERIE'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("D1_FORNECE")
			cTitle := GetSX3Cache('D1_FORNECE', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'D1_FORNECE'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("D1_LOJA")
			cTitle := GetSX3Cache('D1_LOJA', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'D1_LOJA'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("A2_NREDUZ")
			cTitle := GetSX3Cache('A2_NREDUZ', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'D1_FORDES'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("D1_COD")
			cTitle := GetSX3Cache('D1_COD', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'D1_COD' , 'C', aTamSX3[1], aTamSX3[2], /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.)

			aTamSX3	:= TamSX3("D1_QUANT")
			cTitle := GetSX3Cache('D1_QUANT', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'D1_QUANT' , 'N', aTamSX3[1], aTamSX3[2], /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.)

			aTamSX3	:= TamSX3("D1_VUNIT")
			cTitle := GetSX3Cache('D1_VUNIT', 'X3_TITULO')
			oStructMn:AddField(cTitle, cTitle, 'D1_VUNIT', 'N', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("D1_TOTAL")
			cTitle := GetSX3Cache('D1_TOTAL', 'X3_TITULO')
			oStructMn:AddField(cTitle, cTitle, 'D1_TOTAL', 'N', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.)

			aTamSX3	:= TamSX3("D1_EMISSAO")
			cTitle := GetSX3Cache('D1_EMISSAO', 'X3_TITULO')
			oStructMn:AddField(cTitle, cTitle, 'D1_EMISSAO', 'D', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.)
		
			aTamSX3	:= TamSX3("F1_CHVNFE")
			cTitle := GetSX3Cache('F1_CHVNFE', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'CHVNFE'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 
		else

			aTamSX3	:= TamSX3("F1_DOC")
			cTitle := GetSX3Cache('F1_DOC', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'DOC'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("F1_SERIE")
			cTitle := GetSX3Cache('F1_SERIE', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'SERIE'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("F1_EMISSAO")
			cTitle := GetSX3Cache('F1_EMISSAO', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'F1_EMISSAO'  , 'D', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("F1_EST")
			cTitle := GetSX3Cache('F1_EST', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'F1_EST'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("F1_VALMERC")
			cTitle := GetSX3Cache('F1_VALMERC', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'F1_VALMERC'  , 'N', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

			aTamSX3	:= TamSX3("F1_CHVNFE")
			cTitle := GetSX3Cache('F1_CHVNFE', 'X3_TITULO')
			oStructMn:AddField(cTitle , cTitle , 'CHVNFE'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

		endif
	
	elseif nOpc == 3 // -- Grid de itens

		aTamSX3	:= TamSX3("D1_ITEM")
		cTitle := GetSX3Cache('D1_ITEM', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'D1_ITEM'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

		aTamSX3	:= TamSX3("D1_COD")
		cTitle := GetSX3Cache('D1_COD', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'D1_COD'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

		aTamSX3	:= TamSX3("B1_DESC")
		cTitle := GetSX3Cache('B1_DESC', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'D1_PRODESC'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

	endif

	FwFreeArray(aTamSX3)
return oStructMn


//-------------------------------------------------------------------
/*/{Protheus.doc} NF030SDEVW
Campos da View
@author Leandro Fini
@since 09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
static function DOCREFSTRV(nOpc, nGrid)
	Local oStructMn	:= FWFormViewStruct():New()
	Local cTitle    := ""
	Local lVisual   := (lP103View .Or. lSDcRefXml)
	Local cTabela	:= "SA2"
	Local cTabel2	:= "SF1"

	Default nOpc := 1
	Default nGrid := 2

	if (lOrigSF2)
		cTabela := "SA1"
		cTabel2 := "SF2"
	endif

	if nOpc == 1 // -- Estrutura da VIEW - Cabeçalho 

		cTitle := GetSX3Cache(cForCli, 'X3_TITULO')
		oStructMn:AddField('FORNECLI', '01', cTitle, cTitle,, 'C' , PesqPict(cTabel2, cForCli) , , cTabela , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('F1_LOJA', 'X3_TITULO')
		oStructMn:AddField('LOJA'  , '02', cTitle , cTitle ,, 'C' , PesqPict("SF1","F1_LOJA"    ) , , '' , .T., , , , , , .T., , )

		cTitle := GetSX3Cache('F1_DOC', 'X3_TITULO')
		oStructMn:AddField('DOC'  , '03', cTitle , cTitle ,, 'C' , PesqPict("SF1","F1_DOC"    ) , , '' , .T., , , , , , .T., , )

		cTitle := GetSX3Cache('F1_SERIE', 'X3_TITULO')
		oStructMn:AddField('SERIE' , '04', cTitle , cTitle ,, 'C' , PesqPict("SF1","F1_SERIE"   ) , , '' , .T., , , , , , .T., , ) 

		oStructMn:AddField('DTDE'  , '05', STR0011, STR0011 ,, 'D' , PesqPict("SF1","F1_EMISSAO"    ) , , '' , .T., , , , , , .T., , ) //"Ini Emissão"

		oStructMn:AddField('DTATE' , '06', STR0012, STR0012 ,, 'D' , PesqPict("SF1","F1_EMISSAO"    ) , , '' , .T., , , , , , .T., , )//"Fim Emissão"

		cTitle := GetSX3Cache('F1_CHVNFE', 'X3_TITULO')
		oStructMn:AddField('CHVNFE' , '07', cTitle , cTitle ,, 'C' , PesqPict("SF1","F1_CHVNFE"   ) , , '' , .T., , , , , , .T., , ) 

	elseif nOpc == 2 // Estrutura da VIEW - Filtro

		if nGrid == 2 .and. !lVisual // -- Grid de filtro
			oStructMn:AddField('D1_YOK'  , '01', STR0014 , STR0014 ,, 'L' , PesqPict("SAL","AL_DOCAE"    ) , , '' , .T., , , , , , .T., , ) //"Seleciona"
		elseif nGrid == 3 .and. !lVisual // -- Grid de Documentos vinculados 
			oStructMn:AddField('D1_YOK'  , '01', STR0015 , STR0015 ,, 'L' , PesqPict("SAL","AL_DOCAE"    ) , , '' , .T., , , , , , .T., , ) // "Remover"
		endif

		if cOperVinc == OP_VINC_ITEM //-- Quando o vínculo for por item
			cTitle := GetSX3Cache('D1_ITEM', 'X3_TITULO')
			oStructMn:AddField('D1_ITEM'  , '02', cTitle , cTitle ,, 'C' , PesqPict("SD1","D1_ITEM"    ) , , '' , .T., , , , , , .T., , )

			cTitle := GetSX3Cache('D1_ITXML', 'X3_TITULO')
			oStructMn:AddField('D1_ITXML'  , '03', cTitle , cTitle ,, 'C' , PesqPict("SD1","D1_ITXML"    ) , , '' , .T., , , , , , .T., , )

			cTitle := GetSX3Cache('D1_DOC', 'X3_TITULO')
			oStructMn:AddField('D1_DOC'  , '04', cTitle , cTitle ,, 'C' , PesqPict("SD1","D1_DOC"    ) , , '' , .T., , , , , , .T., , ) 

			cTitle := GetSX3Cache('D1_SERIE', 'X3_TITULO')
			oStructMn:AddField('D1_SERIE'  , '05', cTitle , cTitle ,, 'C' , PesqPict("SD1","D1_SERIE"    ) , , '' , .T., , , , , , .T., , ) 

			cTitle := GetSX3Cache('D1_FORNECE', 'X3_TITULO')
			oStructMn:AddField('D1_FORNECE'  , '06', cTitle , cTitle ,, 'C' , PesqPict("SD1","D1_FORNECE"    ) , , '' , .T., , , , , , .T., , ) 

			cTitle := GetSX3Cache('D1_LOJA', 'X3_TITULO')
			oStructMn:AddField('D1_LOJA'  , '07', cTitle , cTitle ,, 'C' , PesqPict("SD1","D1_LOJA"    ) , , '' , .T., , , , , , .T., , ) 

			oStructMn:AddField('D1_FORDES'  , '08', "Desc Forn" , "Desc Forn" ,, 'C' , PesqPict("SA2","A2_NREDUZ"    ) , , '' , .T., , , , , , .T., , )

			cTitle := GetSX3Cache('D1_COD', 'X3_TITULO')
			oStructMn:AddField('D1_COD'  , '09', cTitle , cTitle ,, 'C' , PesqPict("SD1","D1_COD"    ) , , '' , .T., , , , , , .T., , ) 

			cTitle := GetSX3Cache('D1_QUANT', 'X3_TITULO')
			oStructMn:AddField('D1_QUANT' , '10', cTitle , cTitle ,, 'N' , PesqPict("SD1","D1_QUANT"   ) , , '' , .T., , , , , , .T., , )

			cTitle := GetSX3Cache('D1_VUNIT', 'X3_TITULO')
			oStructMn:AddField('D1_VUNIT'  , '11', cTitle , cTitle ,, 'N' , PesqPict("SD1","D1_VUNIT"    ) , , '' , .T., , , , , , .T., , )  

			cTitle := GetSX3Cache('D1_TOTAL', 'X3_TITULO')
			oStructMn:AddField('D1_TOTAL', '12', cTitle, cTitle,, 'N' , PesqPict("SD1","D1_TOTAL") , ,       , .T., , , , , , .T., , ) 

			cTitle := GetSX3Cache('D1_EMISSAO', 'X3_TITULO')
			oStructMn:AddField('D1_EMISSAO', '13', cTitle, cTitle,, 'D' , PesqPict("SD1","D1_EMISSAO") , ,       , .T., , , , , , .T., , ) 
		
			cTitle := GetSX3Cache('F1_CHVNFE', 'X3_TITULO')
			oStructMn:AddField('CHVNFE' , '14', cTitle , cTitle ,, 'C' , PesqPict("SF1","F1_CHVNFE"   ) , , '' , .T., , , , , , .T., , ) 
		else

			cTitle := GetSX3Cache('F1_DOC', 'X3_TITULO')
			oStructMn:AddField('DOC'  , '02', cTitle , cTitle ,, 'C' , PesqPict("SF1","F1_DOC"    ) , , 'SF1' , .T., , , , , , .T., , ) 

			cTitle := GetSX3Cache('F1_SERIE', 'X3_TITULO')
			oStructMn:AddField('SERIE' , '03', cTitle , cTitle ,, 'C' , PesqPict("SF1","F1_SERIE"   ) , , '' , .T., , , , , , .T., , )

			cTitle := GetSX3Cache('F1_EMISSAO', 'X3_TITULO')
			oStructMn:AddField('F1_EMISSAO', '04', cTitle, cTitle,, 'D' , PesqPict("SF1","F1_EMISSAO") , ,       , .T., , , , , , .T., , ) 

			cTitle := GetSX3Cache('F1_EST', 'X3_TITULO')
			oStructMn:AddField('F1_EST', '05', cTitle, cTitle,, 'C' , PesqPict("SF1","F1_EST") , ,       , .T., , , , , , .T., , )

			cTitle := GetSX3Cache('F1_VALMERC', 'X3_TITULO')
			oStructMn:AddField('F1_VALMERC', '06', cTitle, cTitle,, 'N' , PesqPict("SF1","F1_VALMERC") , ,       , .T., , , , , , .T., , )

			cTitle := GetSX3Cache('F1_CHVNFE', 'X3_TITULO')
			oStructMn:AddField('CHVNFE' , '07', cTitle , cTitle ,, 'C' , PesqPict("SF1","F1_CHVNFE"   ) , , '' , .T., , , , , , .T., , ) 
		endif 
		
	elseif nOpc == 3 // -- Grid de itens

		cTitle := GetSX3Cache('D1_ITEM', 'X3_TITULO')
		oStructMn:AddField('D1_ITEM'  , '02', cTitle , cTitle ,, 'C' , PesqPict("SD1","D1_ITEM"    ) , , '' , .T., , , , , , .T., , )

		cTitle := GetSX3Cache('D1_COD', 'X3_TITULO')
		oStructMn:AddField('D1_COD'  , '03', cTitle , cTitle ,, 'C' , PesqPict("SD1","D1_COD"    ) , , '' , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('B1_DESC', 'X3_TITULO')
		oStructMn:AddField('D1_PRODESC'  , '04', cTitle , cTitle ,, 'C' , PesqPict("SB1","B1_DESC"    ) , , '' , .T., , , , , , .T., , ) 

	endif

return oStructMn

//--------------------------------------------------------------------
/*/{Protheus.doc} DOCREFGetData()
Realiza a carga de dados de acordo com a operação

@author Leandro Fini
@since 08/2025
@return NIL
/*/
//--------------------------------------------------------------------
Static Function DOCREFGetData(oModel)

Local oMdlCab  	:= nil
Local oMdlItens	:= nil
Local oMdlSel 	:= nil
Local nX 		:= 1
Local nZ 		:= 1
Local nPos 		:= 1
Local nPosProd 	:= GdFieldPos("D1_COD" )
Local nPosItem 	:= GdFieldPos("D1_ITEM" )
Local aDados  	:= {}
Local aItVinc  	:= {}
Local aAreaSF1	:= SF1->(GetArea())
Local aAreaSD1 	:= SD1->(GetArea())
Local aAreaSF2	:= SF2->(GetArea())
Local aAreaSD2 	:= SD2->(GetArea())
Local cFilSF1	:= fwxFilial("SF1")
Local cFilSD1	:= fwxFilial("SD1")
Local cFilSF2	:= fwxFilial("SF2")
Local cFilSD2	:= fwxFilial("SD2")
Local cFilSB1	:= fwxFilial("SB1")
Local lVisual	:= (lP103View .Or. lSDcRefXml)
Local cFilSA2	:= fwxFilial("SA2")
Local cFilSA1	:= fwxFilial("SA1")

Default oModel := FwModelActive()

cOrigem := iif( FwIsInCallStack("COMXCOL"), "COMXCOL", "MATA103") // Variável para armazenar a origem da chamada da rotina

//Controle da posição do item e codigo quando a chamada vier do Monitor
If cOrigem == "COMXCOL"
	nPosProd := GdFieldPos("DT_COD")
	nPosItem := GdFieldPos("DT_ITEM")
Endif

oMdlCab := oModel:GetModel('CABMASTER')
oMdlSel := oModel:GetModel('SELECTDETAIL')

oMdlCab:GetStruct():SetProperty("FORNECLI",MVC_VIEW_CANCHANGE, .T.)
oMdlCab:GetStruct():SetProperty("LOJA",MVC_VIEW_CANCHANGE, .T.)

if type("oJDocOrig") == "J" .And. oJDocOrig:hasproperty('fornecedor') .And. oJDocOrig:hasproperty('loja') .And.; 
	!Empty(oJDocOrig["fornecedor"]) .And. !Empty(oJDocOrig["loja"])
	oMdlCab:SetValue('FORNECLI',oJDocOrig['fornecedor'])
	oMdlCab:SetValue('LOJA', oJDocOrig['loja'])
else 
	oMdlCab:SetValue('FORNECLI', Alltrim(cA100For))
	oMdlCab:SetValue('LOJA', Alltrim(cLoja))
Endif

oMdlCab:GetStruct():SetProperty("FORNECLI",MVC_VIEW_CANCHANGE, .F.)
oMdlCab:GetStruct():SetProperty("LOJA",MVC_VIEW_CANCHANGE, .F.)
 
if cOperVinc == OP_VINC_ITEM

	oMdlItens  := oModel:GetModel("ITENSDETAIL")

	oMdlItens:SetNoInsertLine(.F.)

	For nX := 1 to len(aCols)

		If !aCols[nX][Len(aCols[nX])] // Último campo = flag de exclusão

			if nX > 1
				oMdlItens:AddLine()
			endif

			oMdlItens:LoadValue('D1_ITEM', aCols[nX][nPosItem])
			oMdlItens:LoadValue('D1_COD',  aCols[nX][nPosProd])
			oMdlItens:LoadValue('D1_PRODESC', Alltrim(getAdvFval("SB1", "B1_DESC", cFilSB1 + aCols[nX][nPosProd], 1)))

			// -- Reabertura de tela, o Json já tem dados vinculados.
			if !lVisual .and. oJDocOrig <> nil .and. oJDocOrig:hasproperty('itens') .and.  len(oJDocOrig['itens']) > 0
				aDados := oJDocOrig["itens"]
				nPos := aScan(aDados, {|x| x['item'] + x['produto'] == aCols[nX][nPosItem] + aCols[nX][nPosProd] })
				if nPos > 0
					aItVinc := oJDocOrig["itens"][nPos]['documentos']
					for nZ := 1 to len(aItVinc)

						if nZ > 1
							oMdlSel:AddLine()
						endif
						oMdlSel:LoadValue("D1_YOK", .F.)
						oMdlSel:LoadValue("D1_ITEM", 		aItVinc[nZ]['item'])
						oMdlSel:LoadValue("D1_ITXML", 		aItVinc[nZ]['itemxml'])
						oMdlSel:LoadValue("D1_COD", 		oJDocOrig["itens"][nPos]['produto'])
						oMdlSel:LoadValue("D1_DOC", 		aItVinc[nZ]['documento'])
						oMdlSel:LoadValue("D1_SERIE", 		aItVinc[nZ]['serie'])
						oMdlSel:LoadValue("D1_FORNECE", 	aItVinc[nZ]['fornecedor'])
						oMdlSel:LoadValue("D1_LOJA", 		aItVinc[nZ]['loja'])
						oMdlSel:LoadValue("D1_FORDES", 		aItVinc[nZ]['nomefor'])			
						oMdlSel:LoadValue("D1_VUNIT", 		aItVinc[nZ]['valorunit'])
						oMdlSel:LoadValue("D1_QUANT", 		aItVinc[nZ]['quantidade'])
						oMdlSel:LoadValue("D1_TOTAL", 		aItVinc[nZ]['valortotal'])
						oMdlSel:LoadValue("D1_EMISSAO", 	aItVinc[nZ]['emissao'])
						oMdlSel:LoadValue("CHVNFE", 		aItVinc[nZ]['chave'])

					next nZ
				endif
			else 
				DbSelectArea("DKN")
				DKN->(DbSetOrder(2)) // -- DKN_FILIAL+DKN_DOC+DKN_SERIE+DKN_CLIFOR+DKN_LOJA+DKN_ITEMNF+DKN_TPMOV
				if DKN->(DbSeek(fwxFilial("DKN") + cNFiscal + cSerie + cA100for + cLoja + aCols[nX][nPosItem]))
					nZ := 1
					if (lOrigSF2)
						SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
						SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
					endif
					While DKN->(!Eof()) .and. Alltrim(DKN->(DKN_DOC+DKN_SERIE)) == Alltrim(cNFiscal + cSerie) .and. Alltrim(DKN->(DKN_CLIFOR+DKN_LOJA)) == Alltrim(cA100for + cLoja) .and. Alltrim(DKN->DKN_ITEMNF) == aCols[nX][nPosItem]
						if DKN->DKN_TPMOV == "1" .And. !(cOrigem == "COMXCOL") //Entrada

							if ( Alltrim(DKN->DKN_ORIGEM) == cOrigem )	
								SF1->(Msseek(cFilSF1 + DKN->( DKN_DOCREF+DKN_SERREF+DKN_PARREF+DKN_LOJREF ) ))
								SD1->(Msseek(cFilSD1 + DKN->( DKN_DOCREF+DKN_SERREF+DKN_PARREF+DKN_LOJREF)+aCols[nX][nPosProd]+DKN->DKN_ITNFRE )) //--D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM

								if nZ > 1
									oMdlSel:AddLine()
								endif

								oMdlSel:LoadValue("D1_ITEM", 		aCols[nX][nPosItem])
							    oMdlSel:LoadValue("D1_ITXML", 		DKN->DKN_ITXML)
								oMdlSel:LoadValue("D1_COD", 		aCols[nX][nPosProd])
								oMdlSel:LoadValue("D1_DOC", 		DKN->DKN_DOCREF)
								oMdlSel:LoadValue("D1_SERIE", 		DKN->DKN_SERREF)
								oMdlSel:LoadValue("D1_FORNECE", 	ca100For)
								oMdlSel:LoadValue("D1_LOJA", 		cLoja)
								oMdlSel:LoadValue("D1_FORDES", 		getAdvFval("SA2", "A2_NREDUZ", cFilSA2 + ca100For + cLoja, 1))			
								oMdlSel:LoadValue("D1_VUNIT", 		SD1->D1_VUNIT)
								oMdlSel:LoadValue("D1_QUANT", 		SD1->D1_QUANT)
								oMdlSel:LoadValue("D1_TOTAL", 		SD1->D1_TOTAL)
								oMdlSel:LoadValue("D1_EMISSAO", 	SD1->D1_EMISSAO)
								oMdlSel:LoadValue("CHVNFE", 		SF1->F1_CHVNFE)

								nZ++
							Endif

						elseif DKN->DKN_TPMOV == "2" .AND. !(cOrigem == "COMXCOL")
							SF2->(Msseek(cFilSF2 + DKN->( DKN_DOCREF+DKN_SERREF+DKN_PARREF+DKN_LOJREF ) ))
							SD2->(Msseek(cFilSD2 + DKN->( DKN_DOCREF+DKN_SERREF+DKN_PARREF+DKN_LOJREF)+aCols[nX][nPosProd]+DKN->DKN_ITNFRE ))
							
							if nZ > 1
								oMdlSel:AddLine()
							endif

							oMdlSel:LoadValue("D1_ITEM", 		DKN->DKN_ITNFRE)
							oMdlSel:LoadValue("D1_ITXML", 		DKN->DKN_ITXML)
							oMdlSel:LoadValue("D1_COD", 		aCols[nX][nPosProd])
							oMdlSel:LoadValue("D1_DOC", 		DKN->DKN_DOCREF)
							oMdlSel:LoadValue("D1_SERIE", 		DKN->DKN_SERREF)
							oMdlSel:LoadValue("D1_FORNECE", 	SD2->D2_CLIENTE)
							oMdlSel:LoadValue("D1_LOJA", 		SD2->D2_LOJA)
							oMdlSel:LoadValue("D1_FORDES", 		getAdvFval("SA1", "A1_NREDUZ", cFilSA1 + SD2->D2_CLIENTE + SD2->D2_LOJA,1))			
							oMdlSel:LoadValue("D1_VUNIT", 		SD2->D2_PRUNIT)
							oMdlSel:LoadValue("D1_QUANT", 		SD2->D2_QUANT)
							oMdlSel:LoadValue("D1_TOTAL", 		SD2->D2_TOTAL)
							oMdlSel:LoadValue("D1_EMISSAO", 	SD2->D2_EMISSAO)
							oMdlSel:LoadValue("CHVNFE", 		SF2->F2_CHVNFE)

							nZ++
						elseIf cOrigem == "COMXCOL"

							if ( Alltrim(DKN->DKN_ORIGEM) == cOrigem )	

								SF1->(Msseek(cFilSF1 + DKN->( DKN_DOCREF+DKN_SERREF+DKN_PARREF+DKN_LOJREF ) ))
								SD1->(Msseek(cFilSD1 + DKN->( DKN_DOCREF+DKN_SERREF+DKN_PARREF+DKN_LOJREF)+aCols[nX][nPosProd]+DKN->DKN_ITNFRE )) //--D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM

								if nZ > 1
									oMdlSel:AddLine()
								endif

								oMdlSel:LoadValue("D1_ITEM", 		aCols[nX][nPosItem])
								oMdlSel:LoadValue("D1_ITXML",       DKN->DKN_ITXML)
								oMdlSel:LoadValue("D1_COD", 		aCols[nX][nPosProd])
								oMdlSel:LoadValue("D1_DOC", 		DKN->DKN_DOCREF)
								oMdlSel:LoadValue("D1_SERIE", 		DKN->DKN_SERREF)
								oMdlSel:LoadValue("D1_FORNECE", 	ca100For)
								oMdlSel:LoadValue("D1_LOJA", 		cLoja)
								oMdlSel:LoadValue("D1_FORDES", 		getAdvFval("SA2", "A2_NREDUZ", cFilSA2 + ca100For + cLoja, 1))			
								oMdlSel:LoadValue("D1_VUNIT", 		SD1->D1_VUNIT)
								oMdlSel:LoadValue("D1_QUANT", 		SD1->D1_QUANT)
								oMdlSel:LoadValue("D1_TOTAL", 		SD1->D1_TOTAL)
								oMdlSel:LoadValue("D1_EMISSAO", 	SD1->D1_EMISSAO)
								oMdlSel:LoadValue("CHVNFE", 		SF1->F1_CHVNFE)

								nZ++
							Endif
						Endif

						DKN->(DbSkip())
					EndDo	
				endif
			endif
		endif

	next nX

	oMdlItens:GoLine(1)
	oMdlItens:SetNoInsertLine(.T.)

else 

	// -- Reabertura de tela, o Json já tem dados vinculados.
	if !lVisual .and. oJDocOrig <> nil .and. oJDocOrig:hasproperty('documentos') .and. len(oJDocOrig['documentos']) > 0
		aDados := oJDocOrig["documentos"]
		for nX := 1 to len(oJDocOrig["documentos"])

			if nX > 1
				oMdlSel:AddLine()
			endif

			oMdlSel:LoadValue("DOC", aDados[nX]['documento'])
			oMdlSel:LoadValue("SERIE", aDados[nX]['serie'])
			oMdlSel:LoadValue("CHVNFE", aDados[nX]['chave'])
			oMdlSel:LoadValue("F1_VALMERC", aDados[nX]['valor'])
			oMdlSel:LoadValue("F1_EST", aDados[nX]['estado'])			
			oMdlSel:LoadValue("F1_EMISSAO", aDados[nX]['emissao'])
		next nX
	else 
		DbSelectArea("DKN")
		DKN->(DbSetOrder(1)) // -- DKN_FILIAL+DKN_DOC+DKN_SERIE+DKN_CLIFOR+DKN_LOJA+DKN_DOCREF+DKN_SERREF+DKN_PARREF+DKN_LOJREF+DKN_ITNFRE+DKN_TPMOV
		if DKN->(DbSeek(fwxFilial("DKN") + cNFiscal + cSerie + cA100for + cLoja))
			While DKN->(!Eof()) .and. Alltrim(DKN->(DKN_DOC+DKN_SERIE)) == Alltrim(cNFiscal + cSerie) .and. Alltrim(DKN->(DKN_CLIFOR+DKN_LOJA)) == Alltrim(cA100for + cLoja)
				
				if ( Alltrim(DKN->DKN_ORIGEM) == cOrigem )
					if (DKN->DKN_TPMOV == "1" )//Entrada
					
						SF1->(Msseek(fwxFilial("SF1") + DKN->( DKN_DOCREF+DKN_SERREF+DKN_PARREF+DKN_LOJREF ) ))

						oMdlSel:GoLine(1)
						if !empty(oMdlSel:GetValue("DOC"))
							oMdlSel:AddLine()
						endif

						oMdlSel:LoadValue("DOC", DKN->DKN_DOCREF)
						oMdlSel:LoadValue("SERIE", DKN->DKN_SERREF)
						oMdlSel:LoadValue("CHVNFE", SF1->F1_CHVNFE)
						oMdlSel:LoadValue("F1_VALMERC", SF1->F1_VALMERC)
						oMdlSel:LoadValue("F1_EST", SF1->F1_EST)			
						oMdlSel:LoadValue("F1_EMISSAO", SF1->F1_EMISSAO)
					endif
				endif
				DKN->(DbSkip())
			EndDo
		endif
	endif

endif

if lP103View .Or. lSDcRefXml
	oMdlSel:SetNoDeleteLine(.T.)
	oMdlSel:SetNoInsertLine(.T.)
	oMdlSel:SetOnlyView("VIEW_SELECT")
	oMdlCab:SetOnlyView("VIEW_CAB")
endif

SD1->(RestArea(aAreaSD1))
SF1->(RestArea(aAreaSF1))

SF2->(RestArea(aAreaSF2))
SD2->(RestArea(aAreaSD2))

FwFreeArray(aAreaSD1)
FwFreeArray(aAreaSF1)
FwFreeArray(aAreaSF2)
FwFreeArray(aAreaSD2)

//Caso sejam eliminados com FwFreeArray o elemento pai (oJDocOrig) será limpo perdendo a exibição dos dados em tela.
aItVinc := {}
aDados  := {}

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} DOCREFCommit
Função de commit do modelo
@author Leandro Fini
@since 08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function DOCREFCommit(oModel)

Local oMdlCab  as object
Local oMdlIte  as object
Local oMdlSel  as object
Local aDocVinc as array
Local aItemVinc as array
Local nX 	   as numeric
Local nZ 	   as numeric 

aDocVinc 	:= {}
aItemVinc	:= {}
nX 		 	:= 1
nZ 		 	:= 1

oJDocOrig := JsonObject():New()

oMdlCab  := oModel:GetModel("CABMASTER")
oMdlSel  := oModel:GetModel("SELECTDETAIL")

if cOperVinc == OP_VINC_NF

	oJDocOrig['numero'] 	:= Alltrim(cNFiscal)
	oJDocOrig['serie'] 		:= Alltrim(cSerie)
	oJDocOrig['fornecedor'] := oMdlCab:GetValue("FORNECLI")
	oJDocOrig['loja'] 		:= oMdlCab:GetValue("LOJA")
	oJDocOrig['documentos'] := {}

	For nX := 1 to oMdlSel:Length()
		oMdlSel:GoLine(nX)

		if !oMdlSel:IsDeleted()
			aAdd(aDocVinc, JsonObject():New())
			aDocVinc[len(aDocVinc)]["documento"]   	:= oMdlSel:GetValue("DOC")
			aDocVinc[len(aDocVinc)]["serie"]   		:= oMdlSel:GetValue("SERIE")
			aDocVinc[len(aDocVinc)]["chave"]   		:= oMdlSel:GetValue('CHVNFE')
			aDocVinc[len(aDocVinc)]["valor"]   		:= oMdlSel:GetValue('F1_VALMERC')
			aDocVinc[len(aDocVinc)]["estado"]  		:= oMdlSel:GetValue('F1_EST')
			aDocVinc[len(aDocVinc)]["emissao"] 		:= oMdlSel:GetValue('F1_EMISSAO')
			aDocVinc[len(aDocVinc)]["forclirf"]		:= oMdlCab:GetValue("FORNECLI")
			aDocVinc[len(aDocVinc)]["lojarf"]		:= oMdlCab:GetValue("LOJA")
		endif

	Next nX

	oJDocOrig['documentos'] := aClone(aDocVinc)

else

	oMdlIte  := oModel:GetModel("ITENSDETAIL")

	oJDocOrig['numero'] 	:= Alltrim(cNFiscal)
	oJDocOrig['serie'] 		:= Alltrim(cSerie)
	oJDocOrig['fornecedor'] := oMdlCab:GetValue("FORNECLI")
	oJDocOrig['loja'] 		:= oMdlCab:GetValue("LOJA")
	oJDocOrig['itens'] 		:= {}

	For nZ := 1 to oMdlIte:Length()
		oMdlIte:GoLine(nZ)

		oMdlSel:GoLine(1)
		if !empty(oMdlSel:GetValue('D1_DOC')) //-- Se tiver ao menos um vinculo.

			aAdd(aItemVinc, JsonObject():New())
			aItemVinc[len(aItemVinc)]["item"]   	:= oMdlIte:GetValue('D1_ITEM')
			aItemVinc[len(aItemVinc)]["produto"]   	:= oMdlIte:GetValue('D1_COD')

			For nX := 1 to oMdlSel:Length()
				oMdlSel:GoLine(nX)

				if !oMdlSel:IsDeleted()
					aAdd(aDocVinc, JsonObject():New())
					aDocVinc[len(aDocVinc)]["item"]   		:= oMdlSel:GetValue('D1_ITEM')
					aDocVinc[len(aDocVinc)]["itemxml"]		:= oMdlSel:GetValue('D1_ITXML')
					aDocVinc[len(aDocVinc)]["documento"]   	:= oMdlSel:GetValue('D1_DOC')
					aDocVinc[len(aDocVinc)]["serie"]   		:= oMdlSel:GetValue('D1_SERIE')
					aDocVinc[len(aDocVinc)]["fornecedor"]  	:= oMdlSel:GetValue('D1_FORNECE')
					aDocVinc[len(aDocVinc)]["loja"]   		:= oMdlSel:GetValue('D1_LOJA')
					aDocVinc[len(aDocVinc)]["nomefor"]  	:= oMdlSel:GetValue('D1_FORDES')
					aDocVinc[len(aDocVinc)]["valorunit"]  	:= oMdlSel:GetValue('D1_VUNIT')
					aDocVinc[len(aDocVinc)]["quantidade"]  	:= oMdlSel:GetValue('D1_QUANT')
					aDocVinc[len(aDocVinc)]["valortotal"]  	:= oMdlSel:GetValue('D1_TOTAL')
					aDocVinc[len(aDocVinc)]["emissao"]  	:= oMdlSel:GetValue('D1_EMISSAO')
					aDocVinc[len(aDocVinc)]["chave"]  		:= oMdlSel:GetValue('CHVNFE')
					aDocVinc[len(aDocVinc)]["forclirf"]		:= oMdlSel:GetValue('D1_FORNECE')
					aDocVinc[len(aDocVinc)]["lojarf"]		:= oMdlSel:GetValue('D1_LOJA')
				endif

			Next nX

			aItemVinc[len(aItemVinc)]["documentos"] := aClone(aDocVinc)
			aDocVinc  := {}
		endif
	next nZ

	oJDocOrig['itens'] := aClone(aItemVinc)

endif

FwFreeArray(aItemVinc)
FwFreeArray(aDocVinc)
    
return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DOCREFPROC
Função de filtro para preenchimento da grid de documentos.
@author Leandro Fini
@since 09/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DOCREFORIG(oModel)

	Local cQuery  	As character
	Local oQuery  	As object
	Local cAliasTmp As character
	Local oMdlCab   as object
	Local oMdlIte   as object
	Local oMdlFil   as object
	Local nX 		as numeric
	Local cDoc 		as character
	Local cSerie    as character
	Local cForn     as character
	Local cLoja 	as character
	Local dIniEmi  	as character
	Local dFimEmi  	as character
	Local cCodProd 	as character
	Local cChvNFE	as character

	Default oModel := FwModelActive()

	oMdlCab  := oModel:GetModel("CABMASTER")
	oMdlFil  := oModel:GetModel("FILTDETAIL")
	nX 		 := 1
	cDoc 	 := oMdlCab:GetValue("DOC")
	cSerie   := oMdlCab:GetValue("SERIE")
	cForn    := oMdlCab:GetValue("FORNECLI")
	cLoja 	 := oMdlCab:GetValue("LOJA")
	dIniEmi  := DtoS(oMdlCab:GetValue("DTDE"))
	dFimEmi  := DtoS(oMdlCab:GetValue("DTATE"))
	cChvNFE  := oMdlCab:GetValue("CHVNFE")

	oMdlFil:clearData()
	oMdlFil:SetNoInsertLine(.F.)

	if (lOrigSF2)
		if cOperVinc == OP_VINC_ITEM
			oMdlIte  := oModel:GetModel("ITENSDETAIL")
			cCodProd := oMdlIte:GetValue('D1_COD')

			cQuery := "SELECT * FROM ("
			cQuery += "	SELECT SD2.D2_FILIAL D1_FILIAL, SD2.D2_DOC D1_DOC, SD2.D2_SERIE D1_SERIE, SD2.D2_CLIENTE D1_FORNECE, SD2.D2_LOJA D1_LOJA, SD2.D2_COD D1_COD, SD2.D2_PRCVEN D1_VUNIT, SD2.D2_ITEM D1_ITEM, SF2.F2_EMISSAO F1_EMISSAO, SF2.F2_CHVNFE CHVNFE, "

			cQuery += " SD2.D2_QUANT D1_QUANT,  SD2.D2_TOTAL D1_TOTAL, "
			
			cQuery += " ROW_NUMBER() OVER ( ORDER BY SF2.F2_EMISSAO desc) AS LINHA"
			cQuery += " FROM " + RetSQLName("SD2") + " SD2 "

			cQuery += "	JOIN " + RetSQLName("SF2") + " SF2 "
			cQuery += "	 ON SF2.F2_FILIAL = ? "
			cQuery += "	AND SF2.F2_DOC = SD2.D2_DOC "
			cQuery += "	AND SF2.F2_SERIE = SD2.D2_SERIE "
			cQuery += "	AND SF2.D_E_L_E_T_ = ' ' "
			cQuery += "		WHERE SD2.D2_FILIAL = ? "
			cQuery += "		AND SD2.D2_TIPO = 'N' "

			if !empty(cDoc)
				cQuery += "	  AND SD2.D2_DOC = ? "
			endif
			if !empty(cSerie)
				cQuery += "	  AND SD2.D2_SERIE = ? "
			endif
			if !empty(cForn)
				cQuery += "	  AND SD2.D2_CLIENTE = ? "
			endif
			if !empty(cLoja)
				cQuery += "	  AND SD2.D2_LOJA = ? "
			endif
			if !empty(cCodProd)
				cQuery += "	  AND SD2.D2_COD = ? "
			endif
			if !empty(dIniEmi)
				cQuery += "	AND SF2.F2_EMISSAO >= ? "
			endif
			if !empty(dFimEmi)
				cQuery += "	AND SF2.F2_EMISSAO <= ? "
			endif
			if !empty(cChvNFE)
				cQuery += "	AND SF2.F2_CHVNFE = ? "
			endif
			
			cQuery += "	  AND SD2.D_E_L_E_T_ = ' ' "
			cQuery += " ) T "
			cQuery += " WHERE LINHA >= 1 AND LINHA <= 300 " //-- limita o resultado devido a performance e filtros disponíveis.

			oQuery := FwExecStatement():New(cQuery)

			oQuery:SetString(nX++, FWxFilial('SF2'))
			oQuery:SetString(nX++, FWxFilial('SD2'))
			
			if !empty(cDoc)
				oQuery:SetString(nX++, cDoc)
			endif
			if !empty(cSerie)
				oQuery:SetString(nX++, cSerie)	
			endif
			if !empty(cForn)
				oQuery:SetString(nX++, cForn)
			endif
			if !empty(cLoja)
				oQuery:SetString(nX++, cLoja)
			endif
			if !empty(cCodProd)
				oQuery:SetString(nX++, cCodProd)
			endif
			if !empty(dIniEmi)
				oQuery:SetString(nX++, dIniEmi)
			endif
			if !empty(dFimEmi)
				oQuery:SetString(nX++, dFimEmi)
			endif
			if !empty(cChvNFE)
				oQuery:SetString(nX++, cChvNFE)
			endif

			cAliasTmp := oQuery:OpenAlias()
			nX := 1
			While !(cAliasTmp)->(Eof())

				if nX > 1
					oMdlFil:AddLine()
				endif
				
				oMdlFil:LoadValue("D1_ITEM", (cAliasTmp)->D1_ITEM)
				oMdlFil:LoadValue("D1_ITXML", (cAliasTmp)->D1_ITEM)
				oMdlFil:LoadValue("D1_QUANT", (cAliasTmp)->D1_QUANT )
				oMdlFil:LoadValue("D1_TOTAL", (cAliasTmp)->D1_TOTAL)
				oMdlFil:LoadValue("D1_COD", (cAliasTmp)->D1_COD)
				oMdlFil:LoadValue("D1_DOC", (cAliasTmp)->D1_DOC)
				oMdlFil:LoadValue("D1_SERIE", (cAliasTmp)->D1_SERIE)
				oMdlFil:LoadValue("D1_FORNECE", (cAliasTmp)->D1_FORNECE)
				oMdlFil:LoadValue("D1_LOJA", (cAliasTmp)->D1_LOJA)
				oMdlFil:LoadValue("D1_FORDES", getAdvFval("SA1","A1_NREDUZ",fwxFilial("SA1") + (cAliasTmp)->D1_FORNECE + (cAliasTmp)->D1_LOJA,1))
				oMdlFil:LoadValue("D1_VUNIT", (cAliasTmp)->D1_VUNIT)
				oMdlFil:LoadValue("D1_EMISSAO", StoD((cAliasTmp)->F1_EMISSAO))
				oMdlFil:LoadValue("CHVNFE", (cAliasTmp)->CHVNFE)

				nX++
				(cAliasTmp)->(DbSkip())
			enddo
			(cAliasTmp)->(DbCloseArea())

		endif

	//SF1 - padrão
	else
		if cOperVinc == OP_VINC_NF		

			cQuery := " SELECT * FROM ("
			cQuery += " SELECT F1_FILIAL, F1_DOC DOC, F1_SERIE SERIE, F1_CHVNFE CHVNFE, F1_EST, F1_VALMERC, F1_EMISSAO, ROW_NUMBER() OVER (ORDER BY SF1.F1_EMISSAO DESC) AS LINHA "
			cQuery += " FROM " + RetSQLName("SF1") + " SF1 "
			if lCsdXML
				cQuery += " WHERE EXISTS "
				cQuery += "	(SELECT DKA_DOC "
				cQuery += "	FROM " + RetSQLName("DKA") + " DKA "
				cQuery += "	WHERE SF1.F1_FILIAL = DKA.DKA_FILIAL "
				cQuery += "	AND SF1.F1_DOC = DKA.DKA_DOC "
				cQuery += "	AND SF1.F1_SERIE = DKA.DKA_SERIE "
				cQuery += "	AND DKA.D_E_L_E_T_ = ' ') "
				cQuery += "	  AND SF1.F1_FILIAL = ? "
			else 
				cQuery += "	  WHERE SF1.F1_FILIAL = ? "
			endif
			if cTipo == "2" // Filtro de ND Pagamento Antecipado
				cQuery += "	  AND SF1.F1_TIPO = '6' "
				cQuery += "	  AND SF1.F1_TPCOMPL = '6' "
			else 
				cQuery += "	  AND SF1.F1_TIPO = 'N' "
			endif 
					
			if ( cTipo == "3")
				cQuery += "	  AND SF1.F1_CPGOVE = '1' "
				cQuery += "	  AND SF1.F1_OPGOV  = '1' "
			else
				cQuery += "	  AND ( SF1.F1_CPGOVE = '0' OR SF1.F1_CPGOVE = ' ' ) "	
			endif

			if !empty(cDoc)
				cQuery += "	  AND SF1.F1_DOC = ? "
			endif
			if !empty(cSerie)
				cQuery += "	  AND SF1.F1_SERIE = ? "
			endif
			if !empty(cForn)
				cQuery += "	  AND SF1.F1_FORNECE = ? "
			endif
			if !empty(cLoja)
				cQuery += "	  AND SF1.F1_LOJA = ? "
			endif
			if !empty(dIniEmi)
				cQuery += "	  AND SF1.F1_EMISSAO >= ? "
			endif
			if !empty(dFimEmi)
				cQuery += "	  AND SF1.F1_EMISSAO <= ? "
			endif
			if !empty(cChvNFE)
				cQuery += "	  AND SF1.F1_CHVNFE = ? "
			endif
			cQuery += "	  AND SF1.F1_STATUS <> ' ' "
			cQuery += "	  AND SF1.D_E_L_E_T_ = ' ' "
			cQuery += ") T"
			cQuery += " WHERE LINHA >= 1 AND LINHA <= 300 " //-- limita o resultado devido a performance e filtros disponíveis.

			oQuery := FwExecStatement():New(cQuery)
			oQuery:SetString(nX++, FWxFilial('SF1'))

			if !empty(cDoc)
				oQuery:SetString(nX++, cDoc)
			endif
			if !empty(cSerie)
				oQuery:SetString(nX++, cSerie)	
			endif
			if !empty(cForn)
				oQuery:SetString(nX++, cForn)
			endif
			if !empty(cLoja)
				oQuery:SetString(nX++, cLoja)
			endif
			if !empty(dIniEmi)
				oQuery:SetString(nX++, dIniEmi)
			endif
			if !empty(dFimEmi)
				oQuery:SetString(nX++, dFimEmi)
			endif
			if !empty(cChvNFE)
				oQuery:SetString(nX++, cChvNFE)
			endif

			cAliasTmp := oQuery:OpenAlias()
			nX := 1
			While !(cAliasTmp)->(Eof())

				if nX > 1
					oMdlFil:AddLine()
				endif
				
				oMdlFil:LoadValue("DOC", (cAliasTmp)->DOC)
				oMdlFil:LoadValue("SERIE", (cAliasTmp)->SERIE)
				oMdlFil:LoadValue("CHVNFE", (cAliasTmp)->CHVNFE)
				oMdlFil:LoadValue("F1_VALMERC", (cAliasTmp)->F1_VALMERC)
				oMdlFil:LoadValue("F1_EST", (cAliasTmp)->F1_EST)			
				oMdlFil:LoadValue("F1_EMISSAO", StoD((cAliasTmp)->F1_EMISSAO))

				nX++
				(cAliasTmp)->(DbSkip())
			enddo
			(cAliasTmp)->(DbCloseArea())

		else

			oMdlIte  := oModel:GetModel("ITENSDETAIL")
			cCodProd := oMdlIte:GetValue('D1_COD')

			cQuery := "SELECT * FROM ("
			cQuery += "	SELECT SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SD1.D1_VUNIT, SD1.D1_ITEM, SF1.F1_EMISSAO, SF1.F1_CHVNFE CHVNFE, "

			if lCsdXML
				cQuery += " DKC.DKC_ITXML,  DKA.DKA_QUANT, DKA.DKA_VLRTOT, "
			else 
				cQuery += " SD1.D1_QUANT,  SD1.D1_TOTAL, SD1.D1_ITXML, "
			endif
			
			cQuery += " ROW_NUMBER() OVER ( ORDER BY SF1.F1_EMISSAO desc) AS LINHA"
			cQuery += " FROM " + RetSQLName("SD1") + " SD1 "

			if lCsdXML
				cQuery += "	JOIN " + RetSQLName("DKC") + " DKC "
				cQuery += "	 ON DKC.DKC_FILIAL = ? "
				cQuery += "	AND DKC.DKC_DOC = SD1.D1_DOC "
				cQuery += "	AND DKC.DKC_SERIE = SD1.D1_SERIE "
				cQuery += "	AND DKC.DKC_FORNEC = SD1.D1_FORNECE "
				cQuery += "	AND DKC.DKC_LOJA = SD1.D1_LOJA "
				cQuery += "	AND DKC.DKC_ITEMNF = SD1.D1_ITEM "
				cQuery += "	AND DKC.D_E_L_E_T_ = ' ' "
				cQuery += " JOIN " + RetSQLName("DKA") + " DKA "
				cQuery += " ON DKA.DKA_FILIAL = ? "
				cQuery += " AND DKA.DKA_DOC = DKC.DKC_DOC "
				cQuery += " AND DKA.DKA_SERIE = DKC.DKC_SERIE "
				cQuery += " AND DKA.DKA_FORNEC = DKC.DKC_FORNEC "
				cQuery += " AND DKA.DKA_LOJA = DKC.DKC_LOJA "
				cQuery += " AND DKA.DKA_ITXML = DKC.DKC_ITXML "
				cQuery += " AND DKA.D_E_L_E_T_ = ' ' "
			endif
			cQuery += "	JOIN " + RetSQLName("SF1") + " SF1 "
			cQuery += "	 ON SF1.F1_FILIAL = ? "
			cQuery += "	AND SF1.F1_DOC = SD1.D1_DOC "
			cQuery += "	AND SF1.F1_SERIE = SD1.D1_SERIE "
			cQuery += "	AND SF1.D_E_L_E_T_ = ' ' "
			cQuery += "		WHERE SD1.D1_FILIAL = ? "
			cQuery += "		AND SD1.D1_TIPO = 'N' "

			if !empty(cDoc)
				cQuery += "	  AND SD1.D1_DOC = ? "
			endif
			if !empty(cSerie)
				cQuery += "	  AND SD1.D1_SERIE = ? "
			endif
			if !empty(cForn)
				cQuery += "	  AND SD1.D1_FORNECE = ? "
			endif
			if !empty(cLoja)
				cQuery += "	  AND SD1.D1_LOJA = ? "
			endif
			if !empty(cCodProd)
				cQuery += "	  AND SD1.D1_COD = ? "
			endif
			if !empty(dIniEmi)
				cQuery += "	AND SF1.F1_EMISSAO >= ? "
			endif
			if !empty(dFimEmi)
				cQuery += "	AND SF1.F1_EMISSAO <= ? "
			endif
			if !empty(cChvNFE)
				cQuery += "	AND SF1.F1_CHVNFE = ? "
			endif
			
			cQuery += "	  AND SD1.D_E_L_E_T_ = ' ' "
			cQuery += " ) T "
			cQuery += " WHERE LINHA >= 1 AND LINHA <= 300 " //-- limita o resultado devido a performance e filtros disponíveis.

			oQuery := FwExecStatement():New(cQuery)

			if lCsdXML
				oQuery:SetString(nX++, FWxFilial('DKC'))
				oQuery:SetString(nX++, FWxFilial('DKA'))
			endif
			oQuery:SetString(nX++, FWxFilial('SF1'))
			oQuery:SetString(nX++, FWxFilial('SD1'))
			
			if !empty(cDoc)
				oQuery:SetString(nX++, cDoc)
			endif
			if !empty(cSerie)
				oQuery:SetString(nX++, cSerie)	
			endif
			if !empty(cForn)
				oQuery:SetString(nX++, cForn)
			endif
			if !empty(cLoja)
				oQuery:SetString(nX++, cLoja)
			endif
			if !empty(cCodProd)
				oQuery:SetString(nX++, cCodProd)
			endif
			if !empty(dIniEmi)
				oQuery:SetString(nX++, dIniEmi)
			endif
			if !empty(dFimEmi)
				oQuery:SetString(nX++, dFimEmi)
			endif
			if !empty(cChvNFE)
				oQuery:SetString(nX++, cChvNFE)
			endif
			
			cAliasTmp := oQuery:OpenAlias()
			nX := 1
			While !(cAliasTmp)->(Eof())

				if nX > 1
					oMdlFil:AddLine()
				endif
				
				oMdlFil:LoadValue("D1_ITEM", (cAliasTmp)->D1_ITEM)
				if lCsdXML
					oMdlFil:LoadValue("D1_ITXML", (cAliasTmp)->DKC_ITXML)
					oMdlFil:LoadValue("D1_QUANT", (cAliasTmp)->DKA_QUANT )
					oMdlFil:LoadValue("D1_TOTAL", (cAliasTmp)->DKA_VLRTOT)
				else 
					oMdlFil:LoadValue("D1_QUANT", (cAliasTmp)->D1_QUANT )
					oMdlFil:LoadValue("D1_TOTAL", (cAliasTmp)->D1_TOTAL)
					oMdlFil:LoadValue("D1_ITXML", (cAliasTmp)->D1_ITXML)
				endif
				oMdlFil:LoadValue("D1_COD", (cAliasTmp)->D1_COD)
				oMdlFil:LoadValue("D1_DOC", (cAliasTmp)->D1_DOC)
				oMdlFil:LoadValue("D1_SERIE", (cAliasTmp)->D1_SERIE)
				oMdlFil:LoadValue("D1_FORNECE", (cAliasTmp)->D1_FORNECE)
				oMdlFil:LoadValue("D1_LOJA", (cAliasTmp)->D1_LOJA)
				oMdlFil:LoadValue("D1_FORDES", getAdvFval("SA2","A2_NREDUZ",fwxFilial("SA2") + (cAliasTmp)->D1_FORNECE + (cAliasTmp)->D1_LOJA,1))
				oMdlFil:LoadValue("D1_VUNIT", (cAliasTmp)->D1_VUNIT)
				oMdlFil:LoadValue("D1_EMISSAO", StoD((cAliasTmp)->F1_EMISSAO))
				oMdlFil:LoadValue("CHVNFE", (cAliasTmp)->CHVNFE)

				nX++
				(cAliasTmp)->(DbSkip())
			enddo
			(cAliasTmp)->(DbCloseArea())

		endif
	endif

	oMdlFil:SetNoInsertLine(.T.)
	oMdlFil:GoLine(1)
	oQuery:Destroy()
    FreeObj(oQuery)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} setVinc
Função para trazer o documento selecionado para os documentos vinculados.
@author Leandro Fini
@since 08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function setVinc()

	Local oModel     as object
	Local oMdlVinc   as object
	Local oMdlFil    as object
	
	oModel := FwModelActive()

	oMdlVinc  := oModel:GetModel("SELECTDETAIL")
	oMdlFil   := oModel:GetModel("FILTDETAIL")

	oMdlVinc:SetNoInsertLine(.F.)

	if cOperVinc == OP_VINC_NF

		if !(oMdlVinc:SeekLine({{"DOC",oMdlFil:GetValue("DOC")},{"SERIE",oMdlFil:GetValue("SERIE")}}))

			oMdlVinc:GoLine(1)
			if !empty(oMdlVinc:GetValue("DOC"))
				oMdlVinc:AddLine()
			endif

			oMdlVinc:LoadValue("D1_YOK", .F.)
			oMdlVinc:LoadValue("DOC", 			oMdlFil:GetValue("DOC"))
			oMdlVinc:LoadValue("SERIE", 		oMdlFil:GetValue("SERIE"))
			oMdlVinc:LoadValue("CHVNFE", 		oMdlFil:GetValue("CHVNFE"))
			oMdlVinc:LoadValue("F1_VALMERC", 	oMdlFil:GetValue("F1_VALMERC"))
			oMdlVinc:LoadValue("F1_EST", 		oMdlFil:GetValue("F1_EST"))			
			oMdlVinc:LoadValue("F1_EMISSAO", 	oMdlFil:GetValue("F1_EMISSAO"))
		else 
			oMdlFil:LoadValue('D1_YOK', .F.)
			Help(NIL, NIL, "DOCREFDUPLIC", NIL, STR0016, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0017}) //"Este documento já se encontra vinculado. Selecione outro documento para vínculo."
		endif
	else 

		if !(oMdlVinc:SeekLine({{"D1_DOC",oMdlFil:GetValue("D1_DOC")},{"D1_SERIE",oMdlFil:GetValue("D1_SERIE")},;
								{"D1_FORNECE",oMdlFil:GetValue("D1_FORNECE")},{"D1_LOJA",oMdlFil:GetValue("D1_LOJA")},;
								{"D1_COD",oMdlFil:GetValue("D1_COD")}})) .and. !(CDSameItem(oMdlFil:GetValue("D1_COD"), oMdlFil:GetValue("D1_DOC"), oMdlFil:GetValue("D1_SERIE"), oMdlFil:GetValue("D1_ITEM") ))
			oMdlVinc:GoLine(1)
			if !empty(oMdlVinc:GetValue("D1_DOC"))
				oMdlVinc:AddLine()
			endif

			oMdlVinc:LoadValue("D1_YOK", .F.)
			oMdlVinc:LoadValue("D1_ITEM", 		oMdlFil:GetValue("D1_ITEM"))
			oMdlVinc:LoadValue("D1_ITXML", 		oMdlFil:GetValue("D1_ITXML"))
			oMdlVinc:LoadValue("D1_COD", 		oMdlFil:GetValue("D1_COD"))
			oMdlVinc:LoadValue("D1_DOC", 		oMdlFil:GetValue("D1_DOC"))
			oMdlVinc:LoadValue("D1_SERIE", 		oMdlFil:GetValue("D1_SERIE"))
			oMdlVinc:LoadValue("D1_FORNECE", 	oMdlFil:GetValue("D1_FORNECE"))
			oMdlVinc:LoadValue("D1_LOJA", 		oMdlFil:GetValue("D1_LOJA"))
			oMdlVinc:LoadValue("D1_FORDES", 	oMdlFil:GetValue("D1_FORDES"))			
			oMdlVinc:LoadValue("D1_VUNIT", 		oMdlFil:GetValue("D1_VUNIT"))
			oMdlVinc:LoadValue("D1_QUANT", 		oMdlFil:GetValue("D1_QUANT"))
			oMdlVinc:LoadValue("D1_TOTAL", 		oMdlFil:GetValue("D1_TOTAL"))
			oMdlVinc:LoadValue("D1_EMISSAO", 	oMdlFil:GetValue("D1_EMISSAO"))
			oMdlVinc:LoadValue("CHVNFE", 		oMdlFil:GetValue("CHVNFE"))
		else 
			oMdlFil:LoadValue('D1_YOK', .F.)
			Help(NIL, NIL, "DOCREFDUPLIC", NIL, STR0016, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0017}) //"Este documento já se encontra vinculado. Selecione outro documento para vínculo."
		endif

	endif

	oMdlVinc:SetNoInsertLine(.T.)
	oMdlVinc:GoLine(1)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} delVinc
Função para deletar a linha do vínculo ao documento/item
@author Leandro Fini
@since 08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function delVinc()

	Local oModel     as object
	Local oMdlVinc   as object
	Local oMdlFil    as object
	
	oModel := FwModelActive()

	oMdlVinc  := oModel:GetModel("SELECTDETAIL")
	oMdlFil   := oModel:GetModel("FILTDETAIL")

	oModel:GetModel('SELECTDETAIL'):SetNoDeleteLine(.F.)

	if cOperVinc == OP_VINC_NF		

		if (oMdlVinc:SeekLine({{"DOC",oMdlVinc:GetValue("DOC")},{"SERIE",oMdlVinc:GetValue("SERIE")}}))
			oMdlVinc:DeleteLine(.T.)

			if (oMdlFil:SeekLine({{"DOC",oMdlVinc:GetValue("DOC")},{"SERIE",oMdlVinc:GetValue("SERIE")}}))
				oMdlFil:LoadValue('D1_YOK', .F.)// -- Encontra o documento que foi removido (se o filtro ainda existir) e restaura para não selecionado.
			endif
		endif

	else 

		if oMdlVinc:SeekLine({{"D1_DOC",oMdlVinc:GetValue("D1_DOC")},{"D1_SERIE",oMdlVinc:GetValue("D1_SERIE")},;
							{"D1_FORNECE",oMdlVinc:GetValue("D1_FORNECE")},{"D1_LOJA",oMdlVinc:GetValue("D1_LOJA")},;
							{"D1_COD",oMdlVinc:GetValue("D1_COD")}})

			oMdlVinc:DeleteLine(.T.)

			if oMdlFil:SeekLine({{"D1_DOC",oMdlVinc:GetValue("D1_DOC")},{"D1_SERIE",oMdlVinc:GetValue("D1_SERIE")},;
								{"D1_FORNECE",oMdlVinc:GetValue("D1_FORNECE")},{"D1_LOJA",oMdlVinc:GetValue("D1_LOJA")},;
								{"D1_COD",oMdlVinc:GetValue("D1_COD")}})
				oMdlFil:LoadValue('D1_YOK', .F.) // -- Encontra o documento que foi removido (se o filtro ainda existir) e restaura para não selecionado.
			endif
		endif

	endif

	oModel:GetModel('SELECTDETAIL'):SetNoDeleteLine(.T.)


Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} DOCREFSetVinc()
Determina o tipo de vínculo para abertura da tela

cOperVinc = 1 -> Vinculo por NF
cOperVinc = 2 -> Vinculo por Item

cTipo = 1 -> Nota de crédito e débito - Busca por NFs tipo Normal
cTipo = 2 -> Nota normal - Busca por NFs de Débito Pagamento antecipado
cTipo = 3 -> Nota de compra governamental - Busca por NFs de Recebimento 

lViewSF2 -> Deve buscar e apresentar dados relativos a nota de saída (SF2/SD2). O padrão é .F., e só ativa se: Crédito (5) e Complemento (3).

@author Leandro Fini
@since 08/2025
@return NIL
/*/
//--------------------------------------------------------------------
Function DOCREFSetVinc( cId, cTp, lViewSF2 )

	Default cId 		:= "1"
	Default cTp 		:= "1"
	Default lViewSF2	:= .F.

	cOperVinc	:= cId
	cTipo 		:= cTp
	lOrigSF2	:= lViewSF2
	cForCli 	:= "F1_FORNECE"
	lSDcRefXml	:= .F.
	lP103View	:= .F.

	if (lOrigSF2)
		cForCli := "F2_CLIENTE"
	endif

	if (type("lDocRefXml") == "L")
		lSDcRefXml := lDocRefXml
	endif

	if (type("l103Visual") == "L")
		lP103View := l103Visual
	endif
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} changeItLin()
Realiza a limpeza do filtro carregado quando o usuário
trocar a linha do item/produto posicionado.

Essa limpeza do filtro previne que o usuario vincule um item + documento
posicionado no produto errado.

@author Leandro Fini
@since 08/2025
@return NIL
/*/
//--------------------------------------------------------------------
Static Function changeItLin(oView)

Local oModel  := FwModelActive()
Local oMdlFil := nil
Local lVisual := (lP103View .Or. lSDcRefXml)

Default oView 		:= FwViewActive()

if !lVisual

	oMdlFil := oModel:GetModel('FILTDETAIL')

	if ValType(oView) == "O" .And. oView:IsActive()
		oMdlFil:ClearData()
		oView:Refresh('VIEW_FILT')
	endif

endif

Return


//--------------------------------------------------------------------
/*/{Protheus.doc} CDSameItem()
Verifica se no grid de itens existe o mesmo código do item atual, com o mesmo documento, série e item para adicionar.
Se retornar true, signifca que sim e impede o processo, para evitar chave duplicada.

@param cCodProd, character, código do produto
@param cDoc, character, número do documento que deve ser verificado
@param cSerie, character, série do documento que deve ser verificado
@param cItem, character, item do documento que deve ser verificado
@return lRet, lógico, se existe outro item no grid com o mesmo documento vinculado.
@author 
@since 12/2025
@return NIL
/*/
//--------------------------------------------------------------------
static function CDSameItem(cCodProd, cDoc, cSerie, cItem)
	Local oModel		:= Nil	As object
	Local oMdlVinc		:= Nil	As object
	Local oMdlFil		:= Nil 	As object
	Local lRet			:= .F.	As logical
	Local nFor			:= 0 	As numeric
	Local nSizeG		:= 0	As numeric
	Default cCodProd	:= ""
	Default cDoc		:= ""
	Default cSerie		:= ""
	Default cItem		:= ""
	
	oModel    	:= FwModelActive()
	oMdlVinc  	:= oModel:GetModel("SELECTDETAIL")
	oMdlFil   	:= oModel:GetModel("FILTDETAIL")
	oMdlItens 	:= oModel:GetModel("ITENSDETAIL")
	nLinha 		:= oMdlItens:getLine()
	nSizeG		:= oMdlItens:Length()

	for nFor := 1 to nSizeG
		oMdlItens:goLine(nFor)
		if oMdlItens:GetValue("D1_COD") == cCodProd .And. nLinha != oMdlItens:getLine()
			if oMdlVinc:SeekLine({{"D1_DOC", cDoc}, {"D1_SERIE", cSerie}, {"D1_ITEM", cItem}})
				lRet := .T.
				exit
			endif
		endif
	next nFor++
	oMdlItens:goLine(nLinha) //Devolve para a linha que estava originalmente.
return lRet
