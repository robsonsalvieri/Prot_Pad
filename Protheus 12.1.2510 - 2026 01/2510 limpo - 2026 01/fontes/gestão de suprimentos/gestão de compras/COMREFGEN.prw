#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "COMREFGEN.CH"

Static cOperVinc 	:= "1" // Vinculo de pagamentos atencipados(Nota de débito - Pgto Antecipado)

#DEFINE OP_VINC_PA	 "1" //  Vinculo de pagamentos atencipados

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

	if cOperVinc == OP_VINC_PA
		oStrCab	:= REFGENSTRM(1)
		oStrFil := REFGENSTRM(2,2)
		oStrSel := REFGENSTRM(2,3)
		cDesc 	:= STR0001//"Vinculo de Pagamentos Atencipados"
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
	
	if !l103Visual .And. !lDocRefXml
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
	Local lVisual  := (l103Visual .Or. lDocRefXml)
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
	endif

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

	Local oStructMn	:= FWFormModelStruct():New()
	Local aTamSX3	:= {}
	Local cTitle    := ""
	Local lVisual := (l103Visual .Or. lDocRefXml)

	Default nOpc := 1
	Default nGrid := 2

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

	endif

	FwFreeArray(aTamSX3)
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
	Local lVisual   := (l103Visual .Or. lDocRefXml)

	Default nOpc := 1
	Default nGrid := 2

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

	endif

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

Local oMdlCab    := nil as object
Local oMdlSel 	 := nil as object
Local nX 		 := 1 as numeric
Local aAreaSE2	 := SE2->(GetArea())
Local lVisual    := (l103Visual .Or. lDocRefXml)
Local jDados 	 := nil as Json
Local cChvSE2 	 := "" as character

Default oModel := FwModelActive()

cOrigem := iif( FwIsInCallStack("COMXCOL"), "COMXCOL", "MATA103") // Variável para armazenar a origem da chamada da rotina

oMdlCab := oModel:GetModel('CABMASTER')
oMdlSel := oModel:GetModel('SELECTDETAIL')

if cOperVinc == OP_VINC_PA

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

endif

if l103Visual .Or. lDocRefXml
	oMdlSel:SetNoDeleteLine(.T.)
	oMdlSel:SetNoInsertLine(.T.)
	oMdlSel:SetOnlyView("VIEW_SELECT")
	oMdlCab:SetOnlyView("VIEW_CAB")
endif

SE2->(RestArea(aAreaSE2))

FwFreeArray(aAreaSE2)

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

Local oMdlCab  as object
Local oMdlSel  as object
Local nX 	   := 1 as numeric
Local jDados   := nil as Json

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

endif


    
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

	Local oMdlCab   as object
	Local oMdlFil   as object
	Local nX 		as numeric
	Local cNum 		:= "" as character
	Local cPrefix   := "" as character
	Local cForn		:= "" as character
	Local cLoja 	:= "" as character
	Local dIniEmi  	:= CtoD("")
	Local dFimEmi  	:= CtoD("")
	Local jParam    := nil as Json
	Local jResponse := nil as Json
	Local nPage 	:= 0 as numeric
	Local lHasNext 	:= .F. as boolean


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
