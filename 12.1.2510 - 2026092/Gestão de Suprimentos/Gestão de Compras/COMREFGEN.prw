#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "COMREFGEN.CH"

Static cOperVinc 	:= "1" // Vinculo de pagamentos atencipados(Nota de débito - Pgto Antecipado)

#DEFINE OP_VINC_PA	 "1" //  Vinculo de pagamentos atencipados
#DEFINE OP_STATLOT	 "2" //  Atualização Status em Lote

//-------------------------------------------------------------------
/*/{Protheus.doc} COMREFGEN
Interface genérica responsável pelo vínculo de documentos no mata103

A interface poderá ter os campos alterados de acordo com 
a variável Static cOperVinc - definida na função REFGenSetOp

É acionada no menu de outras ações do documento de entrada.

@author Leandro Fini
@since 11/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function COMREFGEN()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model da tela
@author Leandro Fini
@since 11/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStrCab := nil
	Local oStrFil := nil
	Local oStrSel := nil
	Local oModel  := nil
	Local cDesc   := ""
	Local cCabDesc:= ""
	Local cDetDesc:= ""
	Local lVisual := .F.

	If Type("l103Visual") <> "L"
		l103Visual := .F.
	Endif

	If Type("lDocRefXml") <> "L"
		lDocRefXml := .F.
	Endif

	if cOperVinc == OP_VINC_PA
		oStrCab	:= REFGENSTRM(1)
		oStrFil := REFGENSTRM(2,2)
		oStrSel := REFGENSTRM(2,3)
		cDesc 	:= STR0001//"Vinculo de Pagamentos Atencipados"
		cCabDesc := STR0002//"Filtros"
		cDetDesc := STR0003//"Documentos"
		lVisual  := !(!l103Visual .And. !lDocRefXml)
	Elseif cOperVinc == OP_STATLOT
		oStrCab	:= REFGENSTRM(3)
		oStrFil := REFGENSTRM(4,2)
		oStrSel := REFGENSTRM(4,3)
		cDesc 	:= STR0017 //"Atualização status em lote - TOTVS Transmite"
		cCabDesc := STR0002//"Filtros"
		cDetDesc := STR0003//"Documentos"
	endif

	oModel := MPFormModel():New('COMREFGEN',/*bPreVld*/, /*{|oModel| PosValid(oModel)}*/, {|oModel| REFGENCommit(oModel)}) 

	oModel:SetDescription(cDesc) //"Documentos de origem"

	oModel:AddFields( 'CABMASTER', , oStrCab,,, )
	oModel:GetModel( 'CABMASTER' ):SetDescription(cCabDesc)//"Cabeçalho"

	oModel:AddGrid( 'SELECTDETAIL', 'CABMASTER', oStrSel, /*bLinPre*/, /*bLinPos*/ ,,, )
	oModel:GetModel( 'SELECTDETAIL' ):SetDescription(cDetDesc)

	oModel:GetModel( 'SELECTDETAIL' ):SetOptional(.T.) 
	
	if !lVisual
		oModel:AddGrid( 'FILTDETAIL', 'CABMASTER', oStrFil, /*bLinPre*/, /*bLinPos*/ ,,, )
		oModel:GetModel( 'FILTDETAIL' ):SetDescription(STR0004) //"Resultado dos Filtros"
		oModel:GetModel('FILTDETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('FILTDETAIL'):SetNoDeleteLine(.T.)
		oModel:GetModel( 'FILTDETAIL' ):SetOptional(.T.)
	endif

	oStrFil:SetProperty( "*" , MODEL_FIELD_OBRIGAT, .F. )
	oStrSel:SetProperty( "*" , MODEL_FIELD_OBRIGAT, .F. )

	if cOperVinc == OP_VINC_PA
		oModel:SetPrimaryKey({'E2_PREFIXO', 'E2_NUM','E2_PARCELA','E2_FORNECE','E2_LOJA'})
	Elseif cOperVinc == OP_STATLOT
		oModel:SetPrimaryKey({'CKO_CHVDOC'})
	endif
	
	oModel:SetVldActivate( {|| .T. } )

	//--------------------------------------
	//		Realiza carga dos grids antes da exibicao
	//--------------------------------------
	oModel:SetActivate( { |oModel| REFGenGetData( oModel ) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional da Rotina 

@author Leandro Fini
@since 11/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()    
	Local aRotina := {}

	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.COMREFGEN' OPERATION 3 ACCESS 0 //-- Incluir
Return(aRotina) 


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface com usuário
@author Leandro Fini
@since 11/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel("COMREFGEN") 
	Local oView    := FWFormView():New() 
	Local oStrCab  := nil
	Local oStrFil  := nil
	Local oStrSel  := nil
	Local lVisual  := .F.
	Local cDesc    := ""
	Local cBtnDesc := ""

	if cOperVinc == OP_VINC_PA
		oStrCab  := REFGENSTRV(1)  
		oStrFil  := REFGENSTRV(2,2) 
		oStrSel  := REFGENSTRV(2,3)
		cDesc	 := STR0006//"Pagamentos Antecipados - Selecionados"
		cBtnDesc := STR0007//"Buscar PAs"

		oStrCab:SetProperty("E2_FORNECE",MVC_VIEW_CANCHANGE, .F.)
		oStrCab:SetProperty("E2_LOJA",MVC_VIEW_CANCHANGE, .F.)

		lVisual  := (l103Visual .Or. lDocRefXml)
	Elseif cOperVinc == OP_STATLOT
		oStrCab  := REFGENSTRV(3)  
		oStrFil  := REFGENSTRV(4,2) 
		oStrSel  := REFGENSTRV(4,3)
		cDesc	 := STR0018 //"Documentos para atualização"
		cBtnDesc := STR0019 //"Buscar Documentos"
	endif

	oStrFil:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)
	oStrSel:SetProperty("*",MVC_VIEW_CANCHANGE, .F.)

	if !lVisual
		oStrFil:SetProperty("D1_YOK",MVC_VIEW_CANCHANGE, .T.)
		oStrSel:SetProperty("D1_YOK",MVC_VIEW_CANCHANGE, .T.)
	Endif

	oView:SetModel(oModel)
	oView:AddField('VIEW_CAB'	, oStrCab, 'CABMASTER')

	if !lVisual
		oView:AddGrid( 'VIEW_FILT' , oStrFil, 'FILTDETAIL' )
	endif

	oView:AddGrid( 'VIEW_SELECT' , oStrSel, 'SELECTDETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR'   , 030 )   
	oView:CreateHorizontalBox( 'INFERIOR2'   , 070 )
	
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
		oView:AddUserButton(cBtnDesc ,'',{|| FWMsgRun(, {|| REFGenSearch(oModel) }, STR0008, STR0009) } ) // "Aguarde" "Carregando Documentos..."
	endif
	
	oView:EnableTitleView('VIEW_SELECT',cDesc) //"Documentos Selecionados"
	
	if !lVisual
		oView:EnableTitleView('VIEW_FILT',STR0010) //"Resultado dos Filtros"
	endif

	oStrCab:AddGroup( 'GRP_COMREFGEN_001',"Filtros", '', 2 )//"Filtros"

	oStrCab:SetProperty( '*'            , MVC_VIEW_GROUP_NUMBER, 'GRP_COMREFGEN_001' )

	oView:showInsertMsg(.F.) // -- Desativa a mensagem registro inserido.
	oView:SetViewAction('ASKONCANCELSHOW', {|oView| .F.}) // -- Desativa mensagem de "há alterações não salvas"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} REFGENSTRM
Campos do modelo
@author Leandro Fini
@since 11/2025
@version 1.0
/*/
//-------------------------------------------------------------------
static function REFGENSTRM(nOpc,nGrid)

	Local oStructMn		:= FWFormModelStruct():New()
	Local aTamSX3		:= {}
	Local cTitle    	:= ""
	Local lVisual 		:= .F.
	Local oComTransmite	:= Nil
	
	Default nOpc := 1
	Default nGrid := 2

	If cOperVinc == OP_VINC_PA
		lVisual := (l103Visual .Or. lDocRefXml)
	Elseif cOperVinc == OP_STATLOT
		oComTransmite := ComTransmite():New()
	Endif

	if nOpc == 1 //-- Estrutura do Modelo - CABEÇALHO 

		//E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_PREFIXO, E2_NUM, E2_EMISSAO

		aTamSX3	:= TamSX3("E2_FORNECE")
		cTitle := GetSX3Cache('E2_FORNECE', 'X3_TITULO')
		oStructMn:AddField(cTitle, cTitle, 'E2_FORNECE', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) 

		aTamSX3	:= TamSX3("E2_LOJA")
		cTitle := GetSX3Cache('E2_LOJA', 'X3_TITULO')
		oStructMn:AddField(cTitle, cTitle, 'E2_LOJA', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)

		aTamSX3	:= TamSX3("E2_PREFIXO")
		cTitle := GetSX3Cache('E2_PREFIXO', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'E2_PREFIXO'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) 

		aTamSX3	:= TamSX3("E2_NUM")
		cTitle := GetSX3Cache('E2_NUM', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'E2_NUM' , 'C', aTamSX3[1], aTamSX3[2], /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)

		aTamSX3	:= TamSX3("E2_EMISSAO")
		oStructMn:AddField(STR0011, STR0011, 'E2_DTDE', 'D', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) //"Ini Emissão"

		aTamSX3	:= TamSX3("E2_EMISSAO")
		oStructMn:AddField(STR0012, STR0012, 'E2_DTATE', 'D', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)//"Fim Emissão"


	elseif nOpc == 2 //-- Estrutura do Modelo - ITENS 

		if nGrid == 2  .and. !lVisual// -- Grid de filtro
			aTamSX3	:= TamSX3("AL_DOCAE")
			oStructMn:AddField(STR0013, STR0013, 'D1_YOK'  , 'L', aTamSX3[1], aTamSX3[2]    , {|| setVinc()}, {|| .T.}, {}, .T., , .F., .T., .T.) //Seleciona
		elseif nGrid == 3 .and. !lVisual // -- Grid de Documentos vinculados
			aTamSX3	:= TamSX3("AL_DOCAE")
			oStructMn:AddField(STR0014, STR0014, 'D1_YOK'  , 'L', aTamSX3[1], aTamSX3[2]    , {|| delVinc()}, {|| .T.}, {}, .T., , .F., .T., .T.)//"Remover"
		endif

		aTamSX3	:= TamSX3("E2_PREFIXO")
		cTitle := GetSX3Cache('E2_PREFIXO', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'E2_PREFIXO'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

		aTamSX3	:= TamSX3("E2_NUM")
		cTitle := GetSX3Cache('E2_NUM', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'E2_NUM'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

		TamSX3	:= TamSX3("E2_PARCELA")
		cTitle := GetSX3Cache('E2_PARCELA', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'E2_PARCELA'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

		aTamSX3	:= TamSX3("E2_EMISSAO")
		cTitle := GetSX3Cache('E2_EMISSAO', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'E2_EMISSAO'  , 'D', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

		aTamSX3	:= TamSX3("E2_VENCTO")
		cTitle := GetSX3Cache('E2_VENCTO', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'E2_VENCTO'  , 'D', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

		aTamSX3	:= TamSX3("E2_MOEDA")
		cTitle := GetSX3Cache('E2_MOEDA', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'E2_MOEDA'  , 'N', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.)

		aTamSX3	:= TamSX3("E2_VALOR")
		cTitle := GetSX3Cache('E2_VALOR', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'E2_VALOR'  , 'N', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.)

		aTamSX3	:= TamSX3("E2_TIPO")
		cTitle := GetSX3Cache('E2_TIPO', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'E2_TIPO'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.) 

		aTamSX3	:= TamSX3("FK7_IDDOC")
		cTitle := GetSX3Cache('FK7_IDDOC', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'FK7_IDDOC'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .T., , .F., .T., .T.)

	Elseif nOpc == 3

		//Data Inicio/Fim Importação
		aTamSX3	:= TamSX3("CKO_DT_IMP")
		oStructMn:AddField(STR0020, STR0020, 'DTDE', 'D', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) //"Dt Ini Importação"
		oStructMn:AddField(STR0021, STR0021, 'DTATE', 'D', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)//"Dt Fim Importação"

		//Tipo Documento
		aTamSX3	:= TamSX3("CKO_CODEDI")
		cTitle := GetSX3Cache('CKO_CODEDI', 'X3_TITULO') 
		oStructMn:AddField(cTitle, cTitle, 'CODEDI', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, oComTransmite:GetCboxCpo("CKO_CODEDI"), .F., , .F., .F., .T.)

		//Documento
		aTamSX3	:= TamSX3("CKO_DOC")
		cTitle := GetSX3Cache('CKO_DOC', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'DOC'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) 
		oStructMn:AddField(cTitle, cTitle, 'E2_FORNECE', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) 

		//Serie
		aTamSX3	:= TamSX3("CKO_SERIE")
		cTitle := GetSX3Cache('CKO_SERIE', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'SERIE' , 'C', aTamSX3[1], aTamSX3[2], /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)

		//NFSe Eletronica
		aTamSX3	:= TamSX3("CKO_NFELET")
		cTitle := GetSX3Cache('CKO_NFELET', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'NFELET'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) 

		//Chave documento
		aTamSX3	:= TamSX3("CKO_CHVDOC")
		cTitle := GetSX3Cache('CKO_CHVDOC', 'X3_TITULO')
		oStructMn:AddField(cTitle, cTitle, 'CHVDOC', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)

		//Recibo
		aTamSX3	:= TamSX3("CKO_RECIBO")
		cTitle := GetSX3Cache('CKO_RECIBO', 'X3_TITULO')
		oStructMn:AddField(cTitle, cTitle, 'RECIBO', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)

		//Status Transmite
		aTamSX3	:= TamSX3("CKO_STRAN")
		cTitle := GetSX3Cache('CKO_STRAN', 'X3_TITULO') 
		oStructMn:AddField(cTitle, cTitle, 'STRAN', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, oComTransmite:GetCboxCpo("CKO_STRAN"), .F., , .F., .F., .T.)

	Elseif nOpc == 4 

		if nGrid == 2  .and. !lVisual// -- Grid de filtro
			aTamSX3	:= TamSX3("AL_DOCAE")
			oStructMn:AddField(STR0013, STR0013, 'D1_YOK'  , 'L', aTamSX3[1], aTamSX3[2]    , {|| setVinc()}, {|| .T.}, {}, .T., , .F., .T., .T.) //Seleciona
		elseif nGrid == 3 .and. !lVisual // -- Grid de Documentos vinculados
			aTamSX3	:= TamSX3("AL_DOCAE")
			oStructMn:AddField(STR0014, STR0014, 'D1_YOK'  , 'L', aTamSX3[1], aTamSX3[2]    , {|| delVinc()}, {|| .T.}, {}, .T., , .F., .T., .T.)//"Remover"
		endif

		//Data Importação
		aTamSX3	:= TamSX3("CKO_DT_IMP")
		cTitle := GetSX3Cache('CKO_DT_IMP', 'X3_TITULO')
		oStructMn:AddField(cTitle, cTitle, 'CKO_DT_IMP', 'D', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)//"Fim Emissão"

		//Status Transmite
		aTamSX3	:= TamSX3("CKO_STRAN") 
		cTitle := GetSX3Cache('CKO_STRAN', 'X3_TITULO')
		oStructMn:AddField(cTitle, cTitle, 'STRAN', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, oComTransmite:GetCboxCpo("CKO_STRAN"), .F., , .F., .F., .T.)//"Chave NF"
		
		//Tipo Documento
		aTamSX3	:= TamSX3("CKO_CODEDI")
		cTitle := GetSX3Cache('CKO_CODEDI', 'X3_TITULO') 
		oStructMn:AddField(cTitle, cTitle, 'CODEDI', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, oComTransmite:GetCboxCpo("CKO_CODEDI"), .F., , .F., .F., .T.)
		
		//Documento
		aTamSX3	:= TamSX3("CKO_DOC")
		cTitle := GetSX3Cache('CKO_DOC', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'DOC'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) 

		//Serie
		aTamSX3	:= TamSX3("CKO_SERIE")
		cTitle := GetSX3Cache('CKO_SERIE', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'SERIE' , 'C', aTamSX3[1], aTamSX3[2], /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)

		//NFSe Eletronica
		aTamSX3	:= TamSX3("CKO_NFELET")
		cTitle := GetSX3Cache('CKO_NFELET', 'X3_TITULO')
		oStructMn:AddField(cTitle , cTitle , 'NFELET'  , 'C', aTamSX3[1]    , aTamSX3[2]    , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) 

		//Chave documento
		aTamSX3	:= TamSX3("CKO_CHVDOC")
		cTitle := GetSX3Cache('CKO_CHVDOC', 'X3_TITULO')
		oStructMn:AddField(cTitle, cTitle, 'CHVDOC', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)//"Chave NF"

		//Recibo
		aTamSX3	:= TamSX3("CKO_RECIBO")
		cTitle := GetSX3Cache('CKO_RECIBO', 'X3_TITULO')
		oStructMn:AddField(cTitle, cTitle, 'RECIBO', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.)//"Chave NF"

		//Arquivo
		aTamSX3	:= TamSX3("CKO_ARQUIV")
		cTitle := GetSX3Cache('CKO_ARQUIV', 'X3_TITULO') 
		oStructMn:AddField(cTitle, cTitle, 'ARQUIV', 'C', aTamSX3[1]  , aTamSX3[2]  , /*{|a,b,c,d| VldFields(a,b,c,d)}*/, {|| .T.}, {}, .F., , .F., .T., .T.) 		

	endif
	FwFreeArray(aTamSX3)
	FreeObj(oComTransmite)
return oStructMn

//-------------------------------------------------------------------
/*/{Protheus.doc} NF030SDEVW
Campos da View
@author Leandro Fini
@since 11/2025
@version 1.0
/*/
//-------------------------------------------------------------------
static function REFGENSTRV(nOpc, nGrid)
	Local oStructMn	:= FWFormViewStruct():New()
	Local cTitle    := ""
	Local lVisual   := .F.
	Local oComTransmite	:= Nil 

	Default nOpc := 1
	Default nGrid := 2

	If cOperVinc == OP_VINC_PA
		lVisual := (l103Visual .Or. lDocRefXml)
	Elseif cOperVinc == OP_STATLOT
		oComTransmite := ComTransmite():New()
	Endif

	if nOpc == 1 // -- Estrutura da VIEW - Cabeçalho 

		cTitle := GetSX3Cache('E2_FORNECE', 'X3_TITULO')
		oStructMn:AddField('E2_FORNECE', '01', cTitle, cTitle,, 'C' , PesqPict("SE2","E2_FORNECE") , , '' , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('E2_LOJA', 'X3_TITULO')
		oStructMn:AddField('E2_LOJA'  , '02', cTitle , cTitle ,, 'C' , PesqPict("SE2","E2_LOJA"    ) , , '' , .T., , , , , , .T., , )

		cTitle := GetSX3Cache('E2_PREFIXO', 'X3_TITULO')
		oStructMn:AddField('E2_PREFIXO'  , '03', cTitle , cTitle ,, 'C' , PesqPict("SE2","E2_PREFIXO"    ) , , '' , .T., , , , , , .T., , )

		cTitle := GetSX3Cache('E2_NUM', 'X3_TITULO')
		oStructMn:AddField('E2_NUM' , '04', cTitle , cTitle ,, 'C' , PesqPict("SE2","E2_NUM"   ) , , '' , .T., , , , , , .T., , ) 

		oStructMn:AddField('E2_DTDE'  , '05', STR0011, STR0011 ,, 'D' , PesqPict("SE2","E2_EMISSAO"    ) , , '' , .T., , , , , , .T., , ) //"Ini Emissão"

		oStructMn:AddField('E2_DTATE' , '06', STR0012, STR0012 ,, 'D' , PesqPict("SE2","E2_EMISSAO"    ) , , '' , .T., , , , , , .T., , )//"Fim Emissão"

	elseif nOpc == 2 // Estrutura da VIEW - Filtro

		if nGrid == 2 .and. !lVisual // -- Grid de filtro
			oStructMn:AddField('D1_YOK'  , '01', STR0013 , STR0013 ,, 'L' , PesqPict("SAL","AL_DOCAE"    ) , , '' , .T., , , , , , .T., , ) //"Seleciona"
		elseif nGrid == 3 .and. !lVisual // -- Grid de Documentos vinculados 
			oStructMn:AddField('D1_YOK'  , '01', STR0014 , STR0014 ,, 'L' , PesqPict("SAL","AL_DOCAE"    ) , , '' , .T., , , , , , .T., , ) // "Remover"
		endif		

		cTitle := GetSX3Cache('E2_PREFIXO', 'X3_TITULO')
		oStructMn:AddField('E2_PREFIXO'  , '02', cTitle , cTitle ,, 'C' , PesqPict("SE2","E2_PREFIXO"    ) , ,  , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('E2_NUM', 'X3_TITULO')
		oStructMn:AddField('E2_NUM' , '03', cTitle , cTitle ,, 'C' , PesqPict("SE2","E2_NUM"   ) , , '' , .T., , , , , , .T., , )

		cTitle := GetSX3Cache('E2_PARCELA', 'X3_TITULO')
		oStructMn:AddField('E2_PARCELA', '04', cTitle, cTitle,, 'C' , PesqPict("SE2","E2_PARCELA") , ,       , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('E2_EMISSAO', 'X3_TITULO')
		oStructMn:AddField('E2_EMISSAO', '05', cTitle, cTitle,, 'D' , PesqPict("SE2","E2_EMISSAO") , ,       , .T., , , , , , .T., , )

		cTitle := GetSX3Cache('E2_VENCTO', 'X3_TITULO')
		oStructMn:AddField('E2_VENCTO', '06', cTitle, cTitle,, 'D' , PesqPict("SE2","E2_VENCTO") , ,       , .T., , , , , , .T., , )

		cTitle := GetSX3Cache('E2_MOEDA', 'X3_TITULO')
		oStructMn:AddField('E2_MOEDA', '07', cTitle, cTitle,, 'N' , PesqPict("SE2","E2_MOEDA") , ,       , .T., , , , , , .T., , )

		cTitle := GetSX3Cache('E2_VALOR', 'X3_TITULO')
		oStructMn:AddField('E2_VALOR' , '08', cTitle , cTitle ,, 'N' , PesqPict("SE2","E2_VALOR"   ) , , '' , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('E2_TIPO', 'X3_TITULO')
		oStructMn:AddField('E2_TIPO' , '09', cTitle , cTitle ,, 'C' , PesqPict("SE2","E2_TIPO"   ) , , '' , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('FK7_IDDOC', 'X3_TITULO')
		oStructMn:AddField('FK7_IDDOC' , '10', cTitle , cTitle ,, 'C' , PesqPict("FK7","FK7_IDDOC"   ) , , '' , .T., , , , , , .T., , ) 

	Elseif nOpc == 3

		//Data Ini/Fim Importação
		oStructMn:AddField('DTDE'  , '01', STR0020, STR0020 ,, 'D' , PesqPict("CKO","CKO_DT_IMP"    ) , , '' , .T., , , , , , .T., , ) //"Ini Importação"
		oStructMn:AddField('DTATE' , '02', STR0021, STR0021 ,, 'D' , PesqPict("CKO","CKO_DT_IMP"    ) , , '' , .T., , , , , , .T., , ) //"Fim Importação"

		cTitle := GetSX3Cache('CKO_CODEDI', 'X3_TITULO')
		oStructMn:AddField('CODEDI'  , '03', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_CODEDI"    ) , , '' , .T., , , oComTransmite:GetCboxCpo("CKO_CODEDI"), , , .T., , ) 

		cTitle := GetSX3Cache('CKO_DOC', 'X3_TITULO')
		oStructMn:AddField('DOC'  , '04', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_DOC"    ) , , '' , .T., , , , , , .T., , )

		cTitle := GetSX3Cache('CKO_SERIE', 'X3_TITULO')
		oStructMn:AddField('SERIE' , '05', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_SERIE"   ) , , '' , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('CKO_NFELET', 'X3_TITULO')
		oStructMn:AddField('NFELET'  , '06', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_NFELET"    ) , , '' , .T., , , , , , .T., , )
		
		cTitle := GetSX3Cache('CKO_CHVDOC', 'X3_TITULO')
		oStructMn:AddField('CHVDOC' , '07', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_CHVDOC"   ) , , '' , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('CKO_RECIBO', 'X3_TITULO')
		oStructMn:AddField('RECIBO' , '08', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_RECIBO"   ) , , '' , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('CKO_STRAN', 'X3_TITULO')
		oStructMn:AddField('STRAN' , '09', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_STRAN"   ) , , '' , .T., , , oComTransmite:GetCboxCpo("CKO_STRAN"), , , .T., , ) 

	Elseif nOpc == 4

		if nGrid == 2 .and. !lVisual // -- Grid de filtro
			oStructMn:AddField('D1_YOK'  , '01', STR0013 , STR0013 ,, 'L' , PesqPict("SAL","AL_DOCAE"    ) , , '' , .T., , , , , , .T., , ) //"Seleciona"
		elseif nGrid == 3 .and. !lVisual // -- Grid de Documentos vinculados 
			oStructMn:AddField('D1_YOK'  , '01', STR0014 , STR0014 ,, 'L' , PesqPict("SAL","AL_DOCAE"    ) , , '' , .T., , , , , , .T., , ) // "Remover"
		endif

		cTitle := GetSX3Cache('CKO_DT_IMP', 'X3_TITULO')
		oStructMn:AddField('CKO_DT_IMP'  , '02', cTitle , cTitle ,, 'D' , PesqPict("CKO","CKO_DT_IMP"    ) , , '' , .T., , , , , , .T., , )

		cTitle := GetSX3Cache('CKO_STRAN', 'X3_TITULO')
		oStructMn:AddField('STRAN'  , '03', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_STRAN"    ) , , '' , .T., , ,oComTransmite:GetCboxCpo("CKO_STRAN") , , , .T., , ) 
		
		cTitle := GetSX3Cache('CKO_CODEDI', 'X3_TITULO')
		oStructMn:AddField('CODEDI'  , '04', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_CODEDI"    ) , , '' , .T., , , oComTransmite:GetCboxCpo("CKO_CODEDI"), , , .T., , ) 
		
		cTitle := GetSX3Cache('CKO_DOC', 'X3_TITULO')
		oStructMn:AddField('DOC'  , '05', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_DOC"    ) , , '' , .T., , , , , , .T., , )

		cTitle := GetSX3Cache('CKO_SERIE', 'X3_TITULO')
		oStructMn:AddField('SERIE'  , '06', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_SERIE"    ) , , '' , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('CKO_NFELET', 'X3_TITULO')
		oStructMn:AddField('NFELET'  , '07', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_NFELET"    ) , , '' , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('CKO_CHVDOC', 'X3_TITULO')
		oStructMn:AddField('CHVDOC'  , '08', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_CHVDOC"    ) , , '' , .T., , , , , , .T., , ) 

		cTitle := GetSX3Cache('CKO_RECIBO', 'X3_TITULO')
		oStructMn:AddField('RECIBO'  , '09', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_RECIBO"    ) , , '' , .T., , , , , , .T., , ) 
		
		cTitle := GetSX3Cache('CKO_ARQUIV', 'X3_TITULO')
		oStructMn:AddField('ARQUIV'  , '10', cTitle , cTitle ,, 'C' , PesqPict("CKO","CKO_ARQUIV"    ) , , '' , .T., , , , , , .T., , )

	endif

	FreeObj(oComTransmite)

return oStructMn

//--------------------------------------------------------------------
/*/{Protheus.doc} REFGenGetData()
Realiza a carga de dados de acordo com a operação

@author Leandro Fini
@since 08/2025
@return NIL
/*/
//--------------------------------------------------------------------
Static Function REFGenGetData(oModel)

Local oMdlCab    	:= nil as object
Local oMdlSel 	 	:= nil as object
Local nX 		 	:= 1 as numeric
Local aAreaSE2	 	:= SE2->(GetArea())
Local lVisual    	:= .F.
Local jDados 	 	:= nil as Json
Local cChvSE2 	 	:= "" as character
Local oComTransmite := Nil as object

Default oModel := FwModelActive()

If Type("l103Visual") <> "L"
	l103Visual := .F.
Endif

If Type("lDocRefXml") <> "L"
	lDocRefXml := .F.
Endif

If Type("cA100For") <> "C"
	cA100For := ""
Endif

If Type("cLoja") <> "C"
	cLoja := ""
Endif

cOrigem := iif( FwIsInCallStack("COMXCOL"), "COMXCOL", "MATA103") // Variável para armazenar a origem da chamada da rotina

oMdlCab := oModel:GetModel('CABMASTER')
oMdlSel := oModel:GetModel('SELECTDETAIL')

if cOperVinc == OP_VINC_PA
	lVisual := (l103Visual .Or. lDocRefXml)

	oMdlCab:GetStruct():SetProperty("E2_FORNECE",MVC_VIEW_CANCHANGE, .T.)
	oMdlCab:GetStruct():SetProperty("E2_LOJA",MVC_VIEW_CANCHANGE, .T.)

	oMdlCab:SetValue('E2_FORNECE', Alltrim(cA100For))
	oMdlCab:SetValue('E2_LOJA', Alltrim(cLoja))

	oMdlCab:GetStruct():SetProperty("E2_FORNECE",MVC_VIEW_CANCHANGE, .F.)
	oMdlCab:GetStruct():SetProperty("E2_LOJA",MVC_VIEW_CANCHANGE, .F.)

	if type("oPAVinc") == "O"
		jDados  := JsonObject():New()
		jDados	:= oPAVinc:getResult()
	elseif lVisual 
		jDados := getF7QData()
	endif

	if valtype(jDados) == "J" .and. jDados:hasProperty("F7Q_IDDOC") .and. len(jDados["F7Q_IDDOC"]) > 0

		oMdlSel:SetNoInsertLine(.F.)

		DbSelectArea("SE2")
		SE2->(DbSetOrder(1)) //-- E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
		for nX := 1 to len(jDados["F7Q_IDDOC"])

			if !empty(jDados["F7Q_IDDOC"][nX])

				cChvSE2 := FinFK7Key( '', jDados["F7Q_IDDOC"][nX])

				if SE2->(DbSeek(cChvSE2))

					if nX > 1
						oMdlSel:AddLine()
					endif

					if !lVisual
						oMdlSel:LoadValue("D1_YOK", .F.)
					endif
					oMdlSel:LoadValue("E2_PREFIXO"  , SE2->E2_PREFIXO)
					oMdlSel:LoadValue("E2_NUM"		, SE2->E2_NUM)
					oMdlSel:LoadValue("E2_PARCELA"  , SE2->E2_PARCELA)
					oMdlSel:LoadValue("E2_MOEDA"	, SE2->E2_MOEDA)
					oMdlSel:LoadValue("E2_EMISSAO"  , SE2->E2_EMISSAO)
					oMdlSel:LoadValue("E2_VENCTO"	, SE2->E2_VENCTO)
					oMdlSel:LoadValue("E2_VALOR"	, SE2->E2_VALOR)
					oMdlSel:LoadValue("E2_TIPO"		, SE2->E2_TIPO)
					oMdlSel:LoadValue("FK7_IDDOC"	, jDados["F7Q_IDDOC"][nX])
				endif
			endif
		next nX

		oMdlSel:SetNoInsertLine(.T.)

	endif
Elseif cOperVinc == OP_STATLOT
	oComTransmite := ComTransmite():New()

	dDtIniTra := oComTransmite:dDataIni
	oMdlCab:GetStruct():SetProperty("*",MVC_VIEW_CANCHANGE, .T.)
	oMdlCab:GetStruct():SetProperty("*",MODEL_FIELD_OBRIGAT, .F.)

	oMdlCab:SetValue('DTDE', dDtIniTra)
	oMdlCab:SetValue('DTATE', dDataBase)
endif

if !lVisual
	oMdlSel:SetNoDeleteLine(.T.)
	oMdlSel:SetNoInsertLine(.T.)
	oMdlSel:SetOnlyView("VIEW_SELECT")
Else 
	oMdlCab:SetOnlyView("VIEW_CAB")
endif

SE2->(RestArea(aAreaSE2))

FwFreeArray(aAreaSE2)
FreeObj(oComTransmite)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} REFGENCommit
Função de commit do modelo
@author Leandro Fini
@since 08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function REFGENCommit(oModel)

Local oMdlCab  	as object
Local oMdlSel  	as object
Local nX 	   	:= 1 as numeric
Local nI 	   	:= 1 as numeric
Local nTpDoc   	:= 1 as numeric
Local nOpc 	   	:= 0 as numeric
Local jDados   	:= nil as Json
Local aDocUpd	:= {}
Local aDocUpdLot:= {}
Local aTpUpd	:= {"2","3","4"}
Local aTpDoc	:= {}

Local oComTransmite as object

oMdlCab  := oModel:GetModel("CABMASTER")
oMdlSel  := oModel:GetModel("SELECTDETAIL")

if cOperVinc == OP_VINC_PA // -- Vinculo de Pagamento atencipado

	if type("oPAVinc") == "O"

		jDados := JsonObject():New()

		jDados['billBranch']        := fwxFilial("SE2", cFilAnt)
        jDados['participantCode']   := oMdlCab:GetValue("E2_FORNECE")
        jDados['participantUnit']   := oMdlCab:GetValue("E2_LOJA")
        jDados['documentNumber']    := Alltrim(cNFiscal)
        jDados['documentSeries']    := Alltrim(cSerie)
        jDados['mainSourceTable']   := "SF1"
        jDados['documentBranch']    := fwxFilial("SF1", cFilAnt)
        jDados['identification']    := {}

		For nX := 1 to oMdlSel:Length()
			oMdlSel:GoLine(nX)

			if !oMdlSel:IsDeleted() .and. !empty(oMdlSel:GetValue("FK7_IDDOC"))
				AADD(jDados['identification'], oMdlSel:GetValue("FK7_IDDOC"))
			endif

		Next nX
        
		oPAVinc:setParameters(jDados)
		oPAVinc:prepareRecordF7Q()
		
		Freeobj(jDados)
	endif

ElseIf cOperVinc == OP_STATLOT

	oComTransmite := ComTransmite():New()

	If "NFE" $ oComTransmite:cMVDOCIMP
        aAdd(aTpDoc,"109")
    Endif
    If "NFS" $ oComTransmite:cMVDOCIMP
        aAdd(aTpDoc,"319")
    Endif
    If "CTE" $ oComTransmite:cMVDOCIMP
        aAdd(aTpDoc,"214")
    Endif
    If "CTO" $ oComTransmite:cMVDOCIMP
        aAdd(aTpDoc,"273")
    Endif

	For nTpDoc := 1 To Len(aTpDoc) //Leitura por Tipo Documento (109/214/273/279)
		
		For nI := 1 To Len(aTpUpd) //Leitura por Status de atualização (2-Exportada/3-Integrada/4-Classificada)
			
			aDocUpd := {}
			
			For nX := 1 to oMdlSel:Length() //Leitura dos arquivos selecionados
				
				oMdlSel:GoLine(nX)

				if !oMdlSel:IsDeleted() .and. !Empty(oMdlSel:GetValue("STRAN")) .And. !Empty(oMdlSel:GetValue("CODEDI"))
					If oMdlSel:GetValue("CODEDI") == aTpDoc[nTpDoc]
						If oMdlSel:GetValue("STRAN") $ "1|2" .And. aTpUpd[nI] == "2" //Pendente ou Exportada
							aAdd(aDocUpd,oMdlSel:GetValue("ARQUIV"))
							aAdd(aDocUpdLot,{oMdlSel:GetValue("ARQUIV"),aTpUpd[nI]})
							nOpc := 5
						Elseif oMdlSel:GetValue("STRAN") == aTpUpd[nI] .And. aTpUpd[nI] == "3"  //Integrada
							aAdd(aDocUpd,oMdlSel:GetValue("ARQUIV"))
							aAdd(aDocUpdLot,{oMdlSel:GetValue("ARQUIV"),aTpUpd[nI]})
							nOpc := 6
						Elseif oMdlSel:GetValue("STRAN") == aTpUpd[nI] .And. aTpUpd[nI] == "4" //Classificada
							aAdd(aDocUpd,oMdlSel:GetValue("ARQUIV"))
							aAdd(aDocUpdLot,{oMdlSel:GetValue("ARQUIV"),aTpUpd[nI]})
							nOpc := 7
						Endif
					Endif
				Endif

			Next nX

			If Len(aDocUpd) > 0
				If oComTransmite:TokenTotvsTransmite()
					oComTransmite:UpdDocStatus(nOpc,aDocUpd)
				Endif
			Endif
		Next nI
	Next nTpDoc

	oComTransmite:IpToolViewUpdLot(aDocUpdLot)
Endif

If cOperVinc == OP_STATLOT
	FreeObj(oComTransmite)
	FwFreeArray(aDocUpd)
	FwFreeArray(aDocUpdLot)
	FwFreeArray(aTpUpd)
	FwFreeArray(aTpDoc)
Endif
    
return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DOCREFPROC
Função de filtro para preenchimento da grid de documentos.
@author Leandro Fini
@since 11/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function REFGenSearch(oModel)

	Local oMdlCab   	as object
	Local oMdlFil   	as object
	Local oComTransmite as object
	Local nX 			as numeric
	Local cNum 			:= "" as character
	Local cSer			:= "" as character
	Local cChvDoc		:= "" as character
	Local cStran		:= "" as character
	Local cRecibo   	:= "" as character
	Local cNFelet   	:= "" as character 
	Local cPrefix   	:= "" as character
	Local cForn			:= "" as character
	Local cLoja 		:= "" as character
	Local cCodEdi		:= "" as character
	Local dIniEmi  		:= CtoD("")
	Local dFimEmi  		:= CtoD("")
	Local jParam    	:= nil as Json
	Local jResponse 	:= nil as Json
	Local nPage 		:= 0 as numeric
	Local lHasNext 		:= .F. as boolean
	Local aDadosFil		:= {} as array

	Default oModel := FwModelActive()

	oMdlCab  := oModel:GetModel("CABMASTER")
	oMdlFil  := oModel:GetModel("FILTDETAIL")

	if cOperVinc == OP_VINC_PA //-- Vinculo de PA

		oMdlFil:clearData()
		oMdlFil:SetNoInsertLine(.F.)

		nX 		 := 1
		nPage	 := 1
		cNum 	 := if(!empty(oMdlCab:GetValue("E2_NUM")),oMdlCab:GetValue("E2_NUM"),"")
		cPrefix  := if(!empty(oMdlCab:GetValue("E2_PREFIXO")),oMdlCab:GetValue("E2_PREFIXO"),"")
		cForn    := oMdlCab:GetValue("E2_FORNECE")
		cLoja 	 := oMdlCab:GetValue("E2_LOJA")
		dIniEmi  := if(!empty(oMdlCab:GetValue("E2_DTDE")),oMdlCab:GetValue("E2_DTDE"),CtoD(""))
		dFimEmi  := if(!empty(oMdlCab:GetValue("E2_DTATE")),oMdlCab:GetValue("E2_DTATE"),CtoD(""))

		// -- Instancio a classe
		if type("oPAVinc") <> "O" .or. ( type("oPAVinc") == "O" .and. !checkPAVinc() )
			oPAVinc := totvs.protheus.backoffice.fin.debittaxinvoice.debittaxinvoice():New()
		endif
		jParam := JsonObject():new()

		// -- Definição de parâmetros de busca
		jParam['billBranch'] := fwxFilial("SE2", cFilAnt) //Obrigatório
		jParam['participantCode'] := cForn //Obrigatório
		jParam['participantUnit'] := cLoja //Obrigatório
		if !empty(cPrefix)
			jParam['billPrefix'] := cPrefix //Opcional
		endif
		if !empty(cNum)
			jParam['billNumber'] := cNum //Opcional
		endif
		if !empty(dIniEmi)
			jParam['FromDate'] := dIniEmi //Opcional
		endif
		if !empty(dFimEmi)
			jParam['ToDate'] := dFimEmi //Opcional
		endif

		// -- Envio os parâmetros de busca
		oPAVinc:setParameters(jParam)

		jResponse := JsonObject():new()

		nPage := 1
		lHasNext := .T.
		while lHasNext
			jResponse := oPAVinc:getAdvancePayments(nPage++)
			if nPage >= 3
				lHasNext := .F.
			endif
			if jResponse:hasProperty('hasNext')
				lHasNext := jResponse['hasNext']
				If !Empty(jResponse['items']) .And. Len(jResponse['items']) > 0
					For nX := 1 to len(jResponse['items'])

					if nX > 1
						oMdlFil:AddLine()
					endif
						
					oMdlFil:LoadValue("E2_PREFIXO", jResponse['items'][nX]["billPrefix"])
					oMdlFil:LoadValue("E2_NUM", jResponse['items'][nX]["billNumber"])
					oMdlFil:LoadValue("E2_PARCELA", jResponse['items'][nX]["billInstallment"])
					oMdlFil:LoadValue("E2_MOEDA", jResponse['items'][nX]["billCurrency"])
					oMdlFil:LoadValue("E2_EMISSAO", CtoD(jResponse['items'][nX]["billIssueDate"]))
					oMdlFil:LoadValue("E2_VENCTO", CtoD(jResponse['items'][nX]["billDueDate"]))
					oMdlFil:LoadValue("E2_VALOR", jResponse['items'][nX]["billValue"])
					oMdlFil:LoadValue("E2_TIPO", jResponse['items'][nX]["billType"])
					oMdlFil:LoadValue("FK7_IDDOC", jResponse['items'][nX]["identification"])

					Next
				endIf
			endIf
		endDo

		oMdlFil:SetNoInsertLine(.T.)
		oMdlFil:GoLine(1)
	ElseIF cOperVinc == OP_STATLOT
		
		dIniEmi  := if(!empty(oMdlCab:GetValue("DTDE")),oMdlCab:GetValue("DTDE"),CtoD(""))
		dFimEmi  := if(!empty(oMdlCab:GetValue("DTATE")),oMdlCab:GetValue("DTATE"),CtoD(""))
		cNum 	 := if(!empty(oMdlCab:GetValue("DOC")),oMdlCab:GetValue("DOC"),"")
		cSer   	 := if(!empty(oMdlCab:GetValue("SERIE")),oMdlCab:GetValue("SERIE"),"")
		cChvDoc  := if(!empty(oMdlCab:GetValue("CHVDOC")),oMdlCab:GetValue("CHVDOC"),"")
		cNFelet	 := if(!empty(oMdlCab:GetValue("NFELET")),oMdlCab:GetValue("NFELET"),"")
		cRecibo	 := if(!empty(oMdlCab:GetValue("RECIBO")),oMdlCab:GetValue("RECIBO"),"")
		cStran	 := if(!empty(oMdlCab:GetValue("STRAN")),oMdlCab:GetValue("STRAN"),"")
		cCodEdi	 := if(!empty(oMdlCab:GetValue("CODEDI")),oMdlCab:GetValue("CODEDI"),"")
		
		oMdlFil:clearData()
		oMdlFil:SetNoInsertLine(.F.)

		oComTransmite := ComTransmite():New()

		aDadosFil := oComTransmite:IPToolFilCKO(dIniEmi,dFimEmi,cNum,cSer,cChvDoc,cNFelet,cRecibo,cStran,cCodEdi)

		For nX := 1 To Len(aDadosFil)
			
			if nX > 1
				oMdlFil:AddLine()
			endif
				
			oMdlFil:LoadValue("CKO_DT_IMP", aDadosFil[nX,1])
			oMdlFil:LoadValue("STRAN", aDadosFil[nX,2])
			oMdlFil:LoadValue("ARQUIV", aDadosFil[nX,3])
			oMdlFil:LoadValue("CODEDI", aDadosFil[nX,4])
			oMdlFil:LoadValue("DOC", aDadosFil[nX,5])
			oMdlFil:LoadValue("SERIE", aDadosFil[nX,6])
			oMdlFil:LoadValue("NFELET", aDadosFil[nX,7])
			oMdlFil:LoadValue("CHVDOC", aDadosFil[nX,8])
			oMdlFil:LoadValue("RECIBO", aDadosFil[nX,9])
			
		Next nX

		oMdlFil:SetNoInsertLine(.T.)
		oMdlFil:GoLine(1)
		
	endif

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

	if cOperVinc == OP_VINC_PA //-- Vinculo de Pagamento antecipado

		if !(oMdlVinc:SeekLine({{"E2_PREFIXO",oMdlFil:GetValue("E2_PREFIXO")},{"E2_NUM",oMdlFil:GetValue("E2_NUM")},{"E2_PARCELA",oMdlFil:GetValue("E2_PARCELA")}}))

			oMdlVinc:GoLine(1)
			if !empty(oMdlVinc:GetValue("E2_NUM"))
				oMdlVinc:AddLine()
			endif

			oMdlVinc:LoadValue("D1_YOK", .F.)
			oMdlVinc:LoadValue("E2_PREFIXO" , oMdlFil:GetValue("E2_PREFIXO"))
			oMdlVinc:LoadValue("E2_NUM"		, oMdlFil:GetValue("E2_NUM"))
			oMdlVinc:LoadValue("E2_PARCELA" , oMdlFil:GetValue("E2_PARCELA"))
			oMdlVinc:LoadValue("E2_MOEDA"	, oMdlFil:GetValue("E2_MOEDA"))
			oMdlVinc:LoadValue("E2_EMISSAO" , oMdlFil:GetValue("E2_EMISSAO"))
			oMdlVinc:LoadValue("E2_VENCTO"	, oMdlFil:GetValue("E2_VENCTO"))
			oMdlVinc:LoadValue("E2_VALOR"	, oMdlFil:GetValue("E2_VALOR"))
			oMdlVinc:LoadValue("E2_TIPO"	, oMdlFil:GetValue("E2_TIPO"))
			oMdlVinc:LoadValue("FK7_IDDOC"	, oMdlFil:GetValue("FK7_IDDOC"))
		else 
			oMdlFil:LoadValue('D1_YOK', .F.)
			Help(NIL, NIL, "PADUPLIC", NIL, STR0015, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0016}) //"Este documento já se encontra vinculado. Selecione outro documento para vínculo."
		endif
	Elseif cOperVinc == OP_STATLOT //-- Vinculo de Pagamento antecipado

		if !(oMdlVinc:SeekLine({{"DOC",oMdlFil:GetValue("DOC")},{"SERIE",oMdlFil:GetValue("SERIE")},{"CHVDOC",oMdlFil:GetValue("CHVDOC")}}))

			oMdlVinc:GoLine(1)
			if !empty(oMdlVinc:GetValue("DOC"))
				oMdlVinc:AddLine()
			endif

			oMdlVinc:LoadValue("D1_YOK", .F.)
			oMdlVinc:LoadValue("CKO_DT_IMP" , oMdlFil:GetValue("CKO_DT_IMP"))
			oMdlVinc:LoadValue("CODEDI"		, oMdlFil:GetValue("CODEDI"))
			oMdlVinc:LoadValue("DOC" 		, oMdlFil:GetValue("DOC"))
			oMdlVinc:LoadValue("SERIE"		, oMdlFil:GetValue("SERIE"))
			oMdlVinc:LoadValue("NFELET" 	, oMdlFil:GetValue("NFELET"))
			oMdlVinc:LoadValue("CHVDOC"		, oMdlFil:GetValue("CHVDOC"))
			oMdlVinc:LoadValue("RECIBO"		, oMdlFil:GetValue("RECIBO"))
			oMdlVinc:LoadValue("STRAN"		, oMdlFil:GetValue("STRAN"))
			oMdlVinc:LoadValue("ARQUIV"		, oMdlFil:GetValue("ARQUIV"))
		else 
			oMdlFil:LoadValue('D1_YOK', .F.)
			Help(NIL, NIL, "CKODUPLIC", NIL, STR0015, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0016}) //"Este documento já se encontra vinculado. Selecione outro documento para vínculo."
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

	if cOperVinc == OP_VINC_PA //-- Vinculo de Pagamento antecipado

		if (oMdlVinc:SeekLine({{"E2_PREFIXO",oMdlVinc:GetValue("E2_PREFIXO")},{"E2_NUM",oMdlVinc:GetValue("E2_NUM")},{"E2_PARCELA",oMdlVinc:GetValue("E2_PARCELA")}}))
			oMdlVinc:DeleteLine(.T.)

			if (oMdlFil:SeekLine({{"E2_PREFIXO",oMdlVinc:GetValue("E2_PREFIXO")},{"E2_NUM",oMdlVinc:GetValue("E2_NUM")},{"E2_PARCELA",oMdlVinc:GetValue("E2_PARCELA")}}))
				oMdlFil:LoadValue('D1_YOK', .F.)// -- Encontra o documento que foi removido (se o filtro ainda existir) e restaura para não selecionado.
			endif
		endif
	Elseif cOperVinc == OP_STATLOT

		if (oMdlVinc:SeekLine({{"DOC",oMdlVinc:GetValue("DOC")},{"SERIE",oMdlVinc:GetValue("SERIE")},{"CHVDOC",oMdlVinc:GetValue("CHVDOC")}}))
			oMdlVinc:DeleteLine(.T.)

			if (oMdlFil:SeekLine({{"DOC",oMdlVinc:GetValue("DOC")},{"SERIE",oMdlVinc:GetValue("SERIE")},{"CHVDOC",oMdlVinc:GetValue("CHVDOC")}}))
				oMdlFil:LoadValue('D1_YOK', .F.)// -- Encontra o documento que foi removido (se o filtro ainda existir) e restaura para não selecionado.
			endif
		endif

	endif

	oModel:GetModel('SELECTDETAIL'):SetNoDeleteLine(.T.)


Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} REFGenSetOp()
Determina o tipo de vínculo para abertura da tela

cOperVinc = 1 -> Vinculo com pagamento antecipado

@author Leandro Fini
@since 11/2025
@return NIL
/*/
//--------------------------------------------------------------------
Function REFGenSetOp( cId )

	Default cId := "1"

	cOperVinc	:= cId
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} getF7QData()

Busca os dados vinculados ao documento sendo aberto para visualização.

@author Leandro Fini
@since 11/2025
@return NIL
/*/
//--------------------------------------------------------------------
Static Function getF7QData()

Local cAliasTmp 	:= ""
Local cQuery		:= ""
Local oQry			:= Nil
Local jDados 		:= nil as Json

cQuery := "SELECT F7Q_IDDOC "
cQuery += " FROM " + RetSqlName("F7Q") + " F7Q "
cQuery += " WHERE F7Q_FILIAL = ? "
cQuery += " AND F7Q_TABORI = ? "
cQuery += " AND F7Q_FILORI = ? "
cQuery += " AND F7Q_SERIE = ? "
cQuery += " AND F7Q_DOC = ? "
cQuery += " AND F7Q_CLIFOR = ? "
cQuery += " AND F7Q_LOJA = ? "
cQuery += " AND D_E_L_E_T_ = ? "

oQry := FwExecStatement():New(cQuery)

oQry:SetString(1, FWxFilial("F7Q"))
oQry:SetString(2, "SF1")
oQry:SetString(3, fwxFilial("SF1", cFilAnt))
oQry:SetString(4, cSerie)
oQry:SetString(5, cNFiscal)
oQry:SetString(6, ca100For)
oQry:SetString(7, cLoja)
oQry:SetString(8, " ")

cAliasTmp := oQry:OpenAlias()

jDados := JsonObject():New()
jDados["F7Q_IDDOC"] := {}

while !(cAliasTmp)->(Eof()) 

	AADD(jDados['F7Q_IDDOC'], (cAliasTmp)->F7Q_IDDOC)

	(cAliasTmp)->(DbSkip()) 
enddo

(cAliasTmp)->(dbCloseArea())
FwFreeObj(oQry)

Return jDados

//--------------------------------------------------------------------
/*/{Protheus.doc} canDeleteF7Q()

Valida se a tabela F7Q (Pagamentos antecipados referenciados)
poderá ser excluída.

@author Leandro Fini
@since 11/2025
@return NIL
/*/
//--------------------------------------------------------------------
Function canDeleteF7Q(cDoc, cSerie, cForn, cLoja, cTab)

    Local jParam     := JsonObject():new() as Json
    Local lCanDelete := .T. as logical
    Local oObj       := Nil as object

	Default cDoc 	:= ""
	Default cSerie  := ""
	Default cForn 	:= ""
	Default cLoja 	:= ""
	Default cTab 	:= ""

	if FwAliasInDic("F7Q")

		DbSelectArea("F7Q")
		F7Q->(DbSetOrder(3))//--F7Q_TABORI, F7Q_FILORI, F7Q_SERIE, F7Q_DOC, F7Q_CLIFOR, F7Q_LOJA

		if F7Q->(DbSeek(cTab + fwxFilial(cTab, cFilAnt) + cSerie + cDoc + cForn + cLoja))
 
			oObj := totvs.protheus.backoffice.fin.debittaxinvoice.debittaxinvoice():new()
		
			jParam['billBranch'] 	   := fwxFilial(cTab, cFilAnt)
			jParam['participantCode']  := cForn
			jParam['participantUnit']  := cLoja
			jParam["mainSourceTable"]  := cTab
			jParam["documentBranch"]   := fwxFilial(cTab, cFilAnt)
			jParam["documentNumber"]   := cDoc
			jParam["documentSeries"]   := cSerie
		
			oObj:setParameters(jParam)
		
			lCanDelete := oObj:validateDeletionF7Q(jParam)

			Freeobj(oObj)
			Freeobj(jParam)
		endif
	endif
  
return lCanDelete

//--------------------------------------------------------------------
/*/{Protheus.doc} DeleteF7Q()

Realiza a exclusão dos registros de Pagamentos Antecipados Referenciados

@author Leandro Fini
@since 11/2025
@return NIL
/*/
//--------------------------------------------------------------------
Function DeleteF7Q(cDoc, cSerie, cForn, cLoja, cTab)

	Local jParam     := JsonObject():new() as Json
    Local lCanDelete := .T. as logical
    Local lDeleted   := .F. as logical
    Local oObj       := Nil as object

	Default cDoc 	:= ""
	Default cSerie  := ""
	Default cForn 	:= ""
	Default cLoja 	:= ""
	Default cTab 	:= ""

	if FwAliasInDic("F7Q")

		DbSelectArea("F7Q")
		F7Q->(DbSetOrder(3))//--F7Q_TABORI, F7Q_FILORI, F7Q_SERIE, F7Q_DOC, F7Q_CLIFOR, F7Q_LOJA

		if F7Q->(DbSeek(cTab + fwxFilial(cTab, cFilAnt) + cSerie + cDoc + cForn + cLoja))
     
			oObj := totvs.protheus.backoffice.fin.debittaxinvoice.debittaxinvoice():new()
		
			jParam['billBranch'] 	   := fwxFilial(cTab, cFilAnt)
			jParam['participantCode']  := cForn
			jParam['participantUnit']  := cLoja
			jParam["mainSourceTable"]  := cTab
			jParam["documentBranch"]   := fwxFilial(cTab, cFilAnt)
			jParam["documentNumber"]   := cDoc
			jParam["documentSeries"]   := cSerie
		
			oObj:setParameters(jParam)
		
			lCanDelete := oObj:validateDeletionF7Q(jParam)
		
			if lCanDelete
				oObj:prepareDeletionF7Q()
				lDeleted := oObj:recordDeletionF7Q()
			endIf

			Freeobj(oObj)
			Freeobj(jParam)
		endif 
	endif
 
return lDeleted

/*/{Protheus.doc} checkPAVinc

	Checa se foi vinculado algum Pagamento Atencipado
	na Nota de Débito - Pgto Antecipado

@author Leandro Fini
@since 11/25
/*/
Function checkPAVinc()

Local jDados   := JsonObject():New() as Json
Local lVinc    := .F. as boolean
	
	jDados	:= oPAVinc:getResult()

	if valtype(jDados) == "J" .and. jDados:hasProperty("F7Q_IDDOC") .and. len(jDados["F7Q_IDDOC"]) > 0
		lVinc := .T.
	endif

	freeObj(jDados)

Return lVinc
