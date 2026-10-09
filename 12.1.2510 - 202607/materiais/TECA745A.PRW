#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA745A.CH'

//Status do orcamento de servicos
#DEFINE DEF_TFJ_ATIVO     "1"			//TFJ_STATUS Contrato Gerado
#DEFINE DEF_TFJ_EMREVISAO "2"			//TFJ_STATUS Em Revisão
#DEFINE DEF_TFJ_REVISADO  "3"			//TFJ_STATUS Revisado
#DEFINE DEF_TFJ_AGDAPROVA "4"			//TFJ_STATUS Aguardando Aprovação
#DEFINE DEF_TFJ_ENCERRADO "5"			//TFJ_STATUS Encerrado
#DEFINE DEF_TFJ_CANCELADO "6"			//TFJ_STATUS Cancelado
#DEFINE DEF_TFJ_INATIVO   "7"			//TFJ_STATUS Inativo

Static aSkip      := {} // Variável para controlar as linhas que já passaram pela validação para não perguntar novamente
 
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA745A
@description Browse Orcamento de Reserva Tecnica

@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Function TECA745A()

Local oBrowse
Local cFiltro := "TFJ_RESTEC == '1'"

If TFJ->(ColumnPos("TFJ_RESTEC"))>0 
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('TFJ')
	oBrowse:SetDescription(STR0001) //'Orçamento de Reserva Tecnica'
	oBrowse:DisableDetails()
	oBrowse:SetFilterDefault(cFiltro)
	oBrowse:Activate()
Else
	Alert(STR0002) //"Atualizar dicionario e rodar UPDDISTR para criar o campo TFJ_RESTEC."
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
@description Construção do Menu

@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Static Function Menudef()
Local aRotina := {}

aRotina := FwMVCMenu('TECA745A')

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description Definição do modelo de Dados

@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel  	:= Nil
	Local oStrTFJ 	:= FWFormStruct(1,'TFJ')
	Local oStrTFL 	:= FWFormStruct(1,'TFL')
	Local oStrTFF 	:= FWFormStruct(1,'TFF')
	Local lGSxRH  	:= SuperGetMV("MV_TECXRH",,.F.) 
	Local oStrABP   := FWFormStruct(1,'ABP')  // NOVO GRID PARA ABP
	Local xAux      := Nil

	// Gatilho para preencher descrição do benefício na grade de ABP
	xAux := FwStruTrigger( 'ABP_BENEFI', 'ABP_DESCRI', 'At740DeBenefi()',.F.)
	oStrABP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	// Gatilho para preencher a verba de acordo com o benefício selecionado na grade de ABP
	xAux := FwStruTrigger( 'ABP_VERBA', 'ABP_DSVERB', 'Posicione("SRV", 1, xFilial("SRV")+M->ABP_VERBA, "RV_DESC" )',.F.)
	oStrABP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'ABP_VERBA', 'ABP_TPVERB', 'At740TpVerb()',.F.)
	oStrABP:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	
	oModel := MPFormModel():New('TECA745A',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

	oModel:AddFields('TFJ_REFER',/*cOwner*/,oStrTFJ,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/,/*bFieldAbp*/)
	oModel:SetDescription(STR0001) //'Orçamento de Reserva Tecnica'

	oModel:SetPrimaryKey({"TFJ_FILIAL","TFJ_CODIGO"})

	oModel:addGrid('TFL_LOC','TFJ_REFER', oStrTFL, {|oMdlG,nLine,cAcao,cCampo, xValor, xValorAnt| PreLinTFL(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt) }, ,{|oMdlG,nLine,cAcao,cCampo, xValor, xValorAnt| PreLinTFL(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt) })

	oModel:SetRelation('TFL_LOC', { { 'TFL_FILIAL', 'xFilial("TFJ")' }, { 'TFL_CODPAI', 'TFJ_CODIGO' } }, TFL->(IndexKey(1)) )

	oModel:addGrid('TFF_RH','TFL_LOC',oStrTFF, {|oMdlG,nLine,cAcao,cCampo, xValor, xValorAnt| PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt) }, ,{|oMdlG,nLine,cAcao,cCampo, xValor, xValorAnt| PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt) })

	oModel:SetRelation('TFF_RH', { { 'TFF_FILIAL', 'xFilial("TFF")' }, { 'TFF_CODPAI', 'TFL_CODIGO' }, { 'TFF_LOCAL', 'TFL_LOCAL' } }, TFF->(IndexKey(1)) )

	oModel:addGrid('ABP_BENEF','TFF_RH',oStrABP, {|oMdlG,nLine,cAcao,cCampo,xValue,xCurrentValue| PreLinABP(oMdlG, nLine, cAcao, cCampo, xValue, xCurrentValue) } ,{|oMdlG,nLine,cAcao,cCampo,xValue,xCurrentValue| PosLinABP(oMdlG, nLine, cAcao, cCampo, xValue, xCurrentValue) })
	oModel:SetRelation('ABP_BENEF', { { 'ABP_FILIAL', 'xFilial("ABP")' }, { 'ABP_ITRH', 'TFF_COD' } }, ABP->(IndexKey(2)) )
	oModel:GetModel( 'ABP_BENEF' ):SetUniqueLine( { 'ABP_BENEFI' } )

	oModel:GetModel( 'ABP_BENEF' ):SetOptional( .T. ) // Deixar a inclusão de benefícios opcional, pois nem todos os itens de RH terão benefícios adicionais.
    oStrABP:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

	oStrABP:SetProperty( "ABP_ITRH"   ,MODEL_FIELD_WHEN, .F. )

	// Campo Tipo 1=Orcamento de Reserva Técnica
	oStrTFJ:SetProperty( "TFJ_RESTEC", MODEL_FIELD_INIT, {||"1"})

	// Campos Codigo/Loja do Cliente
	oStrTFJ:SetProperty( "TFJ_CODENT", MODEL_FIELD_OBRIGAT, .T.)
	oStrTFJ:SetProperty( "TFJ_LOJA",   MODEL_FIELD_OBRIGAT, .T.)
	oStrTFJ:SetProperty( "TFJ_CODENT", MODEL_FIELD_TITULO , STR0003) //'Cliente'
	oStrTFJ:SetProperty( "TFJ_LOJA",   MODEL_FIELD_TITULO , STR0004) //'Loja'
	oStrTFJ:SetProperty( "TFJ_CODENT", MODEL_FIELD_NOUPD  , .F.)
	oStrTFJ:SetProperty( "TFJ_LOJA",   MODEL_FIELD_NOUPD  , .F.)
	oStrTFJ:SetProperty( "TFJ_LOJA",   MODEL_FIELD_VALID  , {|a,b,c,d,e| FWInitCpo(a,b,c,d),lRet := At745VlCli(a),FWCloseCpo(a,b,c,lRet,.T.),lRet})
	oStrTFF:SetProperty('TFF_PERINI',  MODEL_FIELD_VALID  , {|oMdlVld|At740VldDt("TFF_RH","TFF_PERINI","TFF_PERINI","TFF_PERFIM")})
	oStrTFF:SetProperty('TFF_PERFIM',  MODEL_FIELD_VALID  , {|oMdlVld|At740VldDt("TFF_RH","TFF_PERFIM","TFF_PERINI","TFF_PERFIM")})
	oStrTFL:SetProperty('TFL_DTFIM',   MODEL_FIELD_VALID  , {|oMdlVld,cCampo,xValueNew,nLine,xValueOld|At745VldDt(oMdlVld,cCampo,xValueNew,nLine,xValueOld)})
	oStrTFL:SetProperty('TFL_DTINI',   MODEL_FIELD_VALID  , {|oMdlVld,cCampo,xValueNew,nLine,xValueOld|At745VldDt(oMdlVld,cCampo,xValueNew,nLine,xValueOld)})

	// Campos obrigatorios
	oStrTFJ:SetProperty( "TFJ_CONDPG", MODEL_FIELD_OBRIGAT, .F.)
	oStrTFJ:SetProperty( "TFJ_DTPLRV", MODEL_FIELD_OBRIGAT, .F.)
	oStrTFJ:SetProperty( "TFJ_GRPRH" , MODEL_FIELD_OBRIGAT, .F.)
	oStrTFJ:SetProperty( "TFJ_GRPMI" , MODEL_FIELD_OBRIGAT, .F.)
	oStrTFJ:SetProperty( "TFJ_GRPMC" , MODEL_FIELD_OBRIGAT, .F.)
	oStrTFJ:SetProperty( "TFJ_GRPLE" , MODEL_FIELD_OBRIGAT, .F.)
	oStrTFJ:SetProperty( "TFJ_DSCLE" , MODEL_FIELD_OBRIGAT, .F.)
	oStrTFJ:SetProperty( "TFJ_TES"   , MODEL_FIELD_OBRIGAT, .F.)
	oStrTFJ:SetProperty( "TFJ_TESMI" , MODEL_FIELD_OBRIGAT, .F.)
	oStrTFJ:SetProperty( "TFJ_TESMC" , MODEL_FIELD_OBRIGAT, .F.)
	oStrTFJ:SetProperty( "TFJ_TESLE" , MODEL_FIELD_OBRIGAT, .F.)
	oStrTFL:SetProperty( "TFL_CODPAI", MODEL_FIELD_OBRIGAT, .F.)
	oStrTFF:SetProperty( "TFF_CODPAI", MODEL_FIELD_OBRIGAT, .F.)
	oStrTFF:SetProperty( "TFF_LOCAL" , MODEL_FIELD_OBRIGAT, .F.)
	oStrTFF:SetProperty( "TFF_QTDVEN", MODEL_FIELD_OBRIGAT, .F.)
	oStrTFF:SetProperty( "TFF_PRCVEN", MODEL_FIELD_OBRIGAT, .F.)
	oStrTFF:SetProperty( "TFF_COD"   , MODEL_FIELD_OBRIGAT, .T.)
	oStrTFF:SetProperty( "TFF_FUNCAO", MODEL_FIELD_OBRIGAT, lGSxRH)
	oStrTFF:SetProperty( "TFF_ESCALA", MODEL_FIELD_OBRIGAT, .T.)
	oStrTFF:SetProperty( "TFF_TURNO" , MODEL_FIELD_OBRIGAT, .F.)
	If TFJ->(ColumnPos("TFJ_TREINA"))>0
		oStrTFJ:SetProperty( "TFJ_TREINA", MODEL_FIELD_OBRIGAT, .T.)
	EndIf
	oStrABP:SetProperty( "ABP_ITRH",MODEL_FIELD_OBRIGAT, .F.)

	// Campos Descricao
	oStrTFL:SetProperty("TFL_DESLOC",MODEL_FIELD_INIT,{||If(!INCLUI,(Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL, "ABS_DESCRI")),"")})
	oStrTFL:SetProperty("TFL_ESTADO",MODEL_FIELD_INIT,{||If(!INCLUI,(Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL, "ABS_ESTADO")),"")})
	oStrTFL:SetProperty("TFL_MUNIC" ,MODEL_FIELD_INIT,{||If(!INCLUI,(Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL, "ABS_MUNIC" )),"")})
	oStrTFF:SetProperty("TFF_DESCRI",MODEL_FIELD_INIT,{||If(!INCLUI,(Posicione("SB1",1,xFilial("SB1")+TFF->TFF_PRODUT,"B1_DESC"   )),"")})
	oStrTFF:SetProperty("TFF_NOMESC",MODEL_FIELD_INIT,{||If(!INCLUI,(Posicione("TDW",1,xFilial("TDW")+TFF->TFF_ESCALA,"TDW_DESC"  )),"")})
	oStrTFF:SetProperty("TFF_DTURNO",MODEL_FIELD_INIT,{||If(!INCLUI,(Posicione("SR6",1,xFilial("SRJ")+TFF->TFF_TURNO, "R6_DESC"   )),"")})
	oStrABP:SetProperty("ABP_DESCRI",MODEL_FIELD_INIT,{|| At740DscBe()} )
	oStrABP:SetProperty("ABP_TPVERB",MODEL_FIELD_INIT,{|| At740ConvTp( ATINIPADMVC("TECA745A","ABP_BENEF","RV_TIPO","SRV",1, "xFilial('SRV')+ABP->ABP_VERBA") ) } )

	oModel:SetActivate( {|oModel| InitDados( oModel ) } )   

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description Definição da interface

@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel        := ModelDef()
	Local oView         := NIL
	Local oStrTFJ       := NIL
	Local oStrTFL       := NIL
	Local oStrTFF       := NIL
	Local oStrABP       := NIL

	oStrTFJ  := FWFormStruct(2, 'TFJ', {|cCpo| At745ASelFields( 'TFJ', Alltrim(cCpo) ) } )
	oStrTFL  := FWFormStruct(2, 'TFL', {|cCpo| At745ASelFields( 'TFL', Alltrim(cCpo) ) } )
	oStrTFF  := FWFormStruct(2, 'TFF', {|cCpo| At745ASelFields( 'TFF', Alltrim(cCpo) ) } )
	oStrABP  := FWFormStruct(2, 'ABP', {|cCpo| At745ASelFields( 'ABP', Alltrim(cCpo) ) } ) 

	oView:= FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField('VIEW_REFER', oStrTFJ, 'TFJ_REFER')
	oView:AddGrid('VIEW_LOC'   , oStrTFL, 'TFL_LOC')
	oView:AddGrid('VIEW_RH'    , oStrTFF, 'TFF_RH')
	oView:AddGrid('VIEW_BENEF' , oStrABP, 'ABP_BENEF') //"Verbas Adicionais"

	// Adiciona as visões na tela
	oView:CreateHorizontalBox( 'TOP'   , 30 )
	oView:CreateHorizontalBox( 'MIDDLE', 70 )

	// Define as abas
	oView:CreateFolder( 'ABAS', 'MIDDLE')
	oView:AddSheet('ABAS','ABA01',STR0005) //"Locais de Atendimento"
	oView:AddSheet('ABAS','ABA02',STR0006) //"Recursos Humanos"

	// Cria as abas e sheet para incluir
	oView:CreateHorizontalBox( 'ID_ABA01' , 100,,, 'ABAS', 'ABA01' ) // Define a área de Locais
	oView:CreateHorizontalBox( 'ID_ABA02' , 60,,, 'ABAS', 'ABA02' ) // Define a área de RH
	oView:CreateHorizontalBox( 'ID_ABA02A', 40,,, 'ABAS', 'ABA02' ) // área relacionados com RH

	// cria folder e sheets para Abas de Benefício
	oView:CreateFolder( 'RH_ABAS', 'ID_ABA02A')
	oView:AddSheet('RH_ABAS','RH_ABA02',STR0009) //"Verbas Adicionais"
	oView:CreateVerticalBox( 'ID_RH_02' , 100,,, 'RH_ABAS', 'RH_ABA02' ) // Define a área de Verbas

	// Faz a amarração das VIEWs dos modelos com as divisões na interface
	oView:SetOwnerView('VIEW_REFER'	,'TOP')			// Cabeçalho
	oView:SetOwnerView('VIEW_LOC'	,'ID_ABA01')	// Grid Locais
	oView:SetOwnerView('VIEW_RH'	,'ID_ABA02')	// Grid RH
	oView:SetOwnerView('VIEW_BENEF' ,'ID_RH_02')    // Grid Verbas Adicionais

	// Campo item/contador
	oView:AddIncrementField('VIEW_RH' , 'TFF_ITEM' )
	oView:AddIncrementField('VIEW_BENEF' , 'ABP_ITEM' )

	// Campos Codigo/Loja Cliente
	oStrTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_LOOKUP    , 'SA1' )
	oStrTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_CANCHANGE , .T. )
	oStrTFJ:SetProperty( "TFJ_LOJA"  , MVC_VIEW_CANCHANGE , .T. )
	oStrTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_TITULO    , STR0003 ) //'Cliente'
	oStrTFJ:SetProperty( "TFJ_LOJA"  , MVC_VIEW_TITULO    , STR0004 ) //'Loja'

	oStrTFJ:RemoveField("TFJ_RESTEC")

	// Remove campos de controle da view
	oStrABP:RemoveField("ABP_NICKPO")
	oStrABP:RemoveField("ABP_CONFCA")

	oView:SetCloseOnOk({|| .T.} )
	oView:AddUserButton(STR0007,"",{|oModel| AT352TDX(oModel,.F.)},,,) //"Vinculo de Beneficios"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
@description Bloco de código executado no activate

@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Static Function InitDados( oModel )

Local lRet       := .T.
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT
	oModel:GetModel("TFJ_REFER"):SetValue( "TFJ_ENTIDA", "1" )
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At745ASelFields
@description Filtra os campos de controle da rotina para não serem exibidos na view

@param   	cTab, Caracter, Código da tabela a ter o campo avaliado
@param   	cCpoAval, Caracter, Código do campo a ser avaliado
@return 	lRet, Logico, define se o campo deve ser apresentado na view
@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Function At745ASelFields( cTab, cCpoAval )

	Local lRet := .T.

	If !Empty( cTab ) .And. !Empty( cCpoAval )
		If cTab == 'TFJ' 
			lRet := !( cCpoAval $ 'TFJ_PROPOS#TFJ_PREVIS#TFJ_ENTIDA#TFJ_ITEMRH#TFJ_ITEMMI#TFJ_ITEMMI#TFJ_DESCON#TFJ_DSGCN#TFJ_ORCSIM#TFJ_CODTAB#TFJ_TABREV#'+;
			'TFJ_GRPRH#TFJ_GRPMI#TFJ_GRPMC#TFJ_GRPLE#TFJ_DSCRH#TFJ_DSCMI#TFJ_DSCMC#TFJ_DSCLE#TFJ_TES#TFJ_TESMI#TFJ_TESMC#TFJ_TESLE#'+;
			'TFJ_TOTRH#TFJ_TOTMI#TFJ_TOTMC#TFJ_TOTLE#TFJ_LUCRO#TFJ_ADM#TFJ_GESMAT#TFJ_TPFRET#TFJ_CLIPED#TFJ_GRPCOM#TFJ_ANTECI#TFJ_CNTREC#'+;
			'TFJ_CONDPG#TFJ_DATA#TFJ_AGRUP#TFJ_TIPREV#TFJ_RGMCX#TFJ_VEND#TFJ_DTPLRV#TFJ_CODREL#TFJ_PRDRET#TFJ_APRVOP#TFJ_USAPRO#TFJ_DTAPRO'+;
			'TFJ_TOTUNI#TFJ_TOTARM#TFJ_GERPLA#TFJ_OBSREJ#TFJ_TOTCUS#TFJ_TOTGER')
			lRet := lRet .And. !( cCpoAval $ 'TFJ_ITEMMC#TFJ_ITEMLE#TFJ_CONTRT#TFJ_CONREV#TFJ_STATUS#TFJ_TOTRH#TFJ_TOTMI#TFJ_TOTMC#TFJ_TOTLE#TFJ_CODVIS#TFJ_TABXML' )
		ElseIf cTab == 'TFL' 
			lRet := !( cCpoAval $ 'TFL_CODIGO#TFL_CODPAI#TFL_CONTRT#TFL_CONREV#TFL_CODSUB#TFL_MESRH#TFL_MESMI#TFL_MESMC#'+;
			'TFL_TOTRH#TFL_TOTMI#TFL_TOTMC#TFL_TOTLE#TFL_TOTAL#TFL_ITPLRH#TFL_ITPLMI#TFL_ITPLMC#TFL_ITPLLE#TFL_ENCE'+;
			'TFL_PLAN#TFJ_ITPLRH#TFL_PEDTIT#TFL_OBS#TFL_TOTIMP#TFL_ATCC#TFL_VLPRPA#TFL_MODPLA#TFL_CODREL#TFL_DTENCE#'+;
			'TFL_TOTUNI#TFL_TOTARM#TFL_GERPLA#TFL_PLUCRO')
			lRet := lRet .And. !( cCpoAval $ '' )  
		ElseIf cTab == 'TFF'
			lRet := !( cCpoAval $ 'TFF_LOCAL#TFF_CODPAI#TFF_CONTRT#TFF_CONREV#TFF_CODSUB#TFF_CHVTWO#TFF_ENCE#TFF_PROCES#TFF_ITCNB#TFF_TABXML#TFF_ITEXOP#'+;
			'TFF_TOTMI#TFF_TOTMC#TFF_TOTMES#TFF_TOTAL#TFF_TESPED#TFF_UM#TFF_QTDVEN#TFF_PRCVEN#TFF_SUBTOT#TFF_DFUNC#TFF_CARGO#TFF_DCARGO#'+;
			'TFF_DESCON#TFF_CALEND#TFF_DSCALE#TFF_VALDES#TFF_CALCMD#TFF_LUCRO#TFF_TXLUCR#TFF_ADM#TFF_TXADM#TFF_COBCTR#TFF_NARMA#TFF_NCOLE#TFF_PERMAT#TFF_VLRMAT#TFF_VLRCON#'+;
			'TFF_PLACOD#TFF_PLAREV#TFF_TESPED#TFF_DPLAN#TFF_QTDHRS#TFF_HRSSAL#TFF_VLPRPA#TFF_CODREL#TFF_DTENCE#TFF_GERVAG#TFF_MODPLA#TFF_PRDRET#TFF_QTDVAG#'+;
			'TFF_TOTUNI#TFF_TOTARM#TFF_GERPLA#TFF_TOTPLA#TFF_QTDTIP#TFF_VLRPRP#TFF_VLRCOB#TFF_CODTWO#TFF_ABTINS#TFF_TPCOBR#TFF_DSCCOB#TFF_PLUCRO#TFF_VLFIXO')
		ElseIf cTab == 'ABP'
			lRet := !( cCpoAval $ 'ABP_COD#ABP_REVISA#ABP_CODPRO#ABP_ENTIDA#ABP_ITRH#ABP_ITEMPR#ABP_CODTWO#ABP_CHVTWO' )
		Else	
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At745VlCli
@description Valida Cod/Loja do cliente

@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Function At745VlCli(oModel)
Local lRet := .F.
Local aArea := GetArea()

SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD
lRet := SA1->(DbSeek(xFilial("SA1")+oModel:GetValue('TFJ_CODENT')+oModel:GetValue('TFJ_LOJA')))

RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFL
@description Função de Prevalidacao da grade de Locais de Atendimento
@sample 	PreLinTFL(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.
@param		[xValor],Indefinido,Novo valor inserido no campo.
@param		[xValorAnt],Indefinido,Antigo valor do campo.

@since	21/11/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Static Function PreLinTFL(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt)
	Local aArea      := GetArea()
	Local aSaveLines := FWSaveRows()
	Local cAliasQry  := ""
	Local cQry       := ""
	Local lRet       := .T.
	Local nNum       := 1
	Local oStatement := Nil
	
	If oMdlG <> Nil
		If cAcao $ "DELETE|CANSETVALUE"
			If !oMdlG:IsInserted()
				cQry := "SELECT 1 "
				cQry += "FROM   ? ABQ "
				cQry +=        "INNER JOIN ? ABB "
				cQry +=              "ON ABB_FILIAL = ? "
				cQry +=                 "AND ABQ_CODIGO = ABB_CODIGO "
				cQry +=                 "AND ABB.D_E_L_E_T_ = ' ' "				
				cQry +=        "WHERE ABQ.ABQ_FILIAL = ? "
				cQry +=              "AND ABQ.ABQ_FILTFF = ? "
				cQry += 			 "AND ABQ.ABQ_CODTFF = ? "
				cQry +=              "AND ABQ.ABQ_ORIGEM = 'TFJ' "
				cQry +=              "AND ABQ.D_E_L_E_T_ = ' ' "

				nNum := 1
				cQry := ChangeQuery(cQry)
				oStatement := FwExecStatement():New(cQry)

				oStatement:SetUnsafe(nNum++, RetSqlName("ABQ"))
				oStatement:SetUnsafe(nNum++, RetSqlName("ABB"))
				oStatement:SetString(nNum++, FwxFilial("ABB"))				
				oStatement:SetString(nNum++, FwxFilial("ABQ"))
				oStatement:SetString(nNum++, FwxFilial("TFF"))
				oStatement:SetString(nNum++, FwFldGet("TFF_COD"))

				cAliasQry := oStatement:OpenAlias()
				oStatement:Destroy()
				FwFreeObj( oStatement )
				
				If (cAliasQry)->(!EOF())
					lRet := .F.
					Help(,,"PreLinTFL",,STR0008,1,0) // "Não é possivel editar/deletar esse Local de Atendimento, pois existem agendas vinculadas ao posto."
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf
	EndIf

	FWRestRows(aSaveLines)
	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinABP
@description Função de Prevalidacao da grade de Verbas Adicionais.
@sample 	PreLinABP(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.
@param		[xValor],Indefinido,Novo valor inserido no campo.
@param		[xValorAnt],Indefinido,Antigo valor do campo.

@since	06/05/2026
@author Amilton.Pereira
/*/
//------------------------------------------------------------------------------
Static Function PreLinABP(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt)
	Local aArea      := GetArea()
	Local aSaveLines := FWSaveRows()
	Local cAliasQry  := ""
	Local cBenefAnt  := ""
	Local cQry       := ""
	Local lRet       := .T.
	Local nI         := 0
	Local nNum       := 1
	Local oStatement := Nil
	
	If oMdlG <> Nil
		If cAcao $ "DELETE|CANSETVALUE" 
			If !oMdlG:IsInserted()
				cQry := "SELECT 1 "
				cQry += "FROM   ? ABQ "
				cQry += "LEFT JOIN ? ABB "
				cQry +=        "ON ABB_FILIAL = ? "
				cQry +=           "AND ABQ_CODIGO = ABB_CODIGO "
				cQry +=           "AND ABB.ABB_ATENDE = ? " // filtra apenas a agenda que já foi atendida
				cQry +=           "AND ABB.D_E_L_E_T_ = ' ' "
				cQry += "WHERE ABQ.ABQ_FILIAL = ? "
				cQry +=       "AND ABQ.ABQ_FILTFF = ? "
				cQry +=       "AND ABQ.ABQ_CODTFF = ? "
				cQry +=       "AND ABQ.ABQ_ORIGEM = 'TFJ' "
				cQry +=       "AND ABQ.D_E_L_E_T_ = ' ' "

				nNum := 1
				cQry := ChangeQuery(cQry)
				oStatement := FwExecStatement():New(cQry)

				oStatement:SetUnsafe(nNum++, RetSqlName("ABQ"))
				oStatement:SetUnsafe(nNum++, RetSqlName( "ABB" ))
				oStatement:SetString(nNum++, FwxFilial("ABQ"))
				oStatement:SetString(nNum++, "2") // ABB_ATENDE
				oStatement:SetString(nNum++, FwxFilial("ABQ"))
				oStatement:SetString(nNum++, FwxFilial("TFF"))
				oStatement:SetString(nNum++, FwFldGet("TFF_COD"))

				cAliasQry := oStatement:OpenAlias()
				oStatement:Destroy()
				FwFreeObj( oStatement )
				
				If (cAliasQry)->(!EOF())
					lRet := .F.
					Help(,,"PreLinABP",,STR0010,1,0) // "Não é possível editar/deletar esta Verba Adicional, pois existem agendas vinculadas a este posto."
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf
	EndIf

	// Verifica se já existe agenda atendida para o benefício da linha anterior e solicita confirmação antes de gravar uma nova verba na Grid de Verbas Adicionais.
	If oMdlG <> Nil .AND. oMdlG:IsInserted() .AND. nLine > 1 .AND. ASCAN(aSkip, {|x| x == FwFldGet("TFF_COD")}) == 0
   		For nI := nLine - 1 To 1 Step -1 // Busca última linha válida (não deletada)
    		If !oMdlG:IsDeleted(nI)
        		cBenefAnt := oMdlG:GetValue("ABP_BENEFI", nI)
        		Exit  // achou válida, para
    		EndIf
		Next

    	oMdlG:GoLine(nI)

		If !Empty(cBenefAnt)
			cQry := "SELECT 1 "
			cQry += "FROM   ? ABQ "
			cQry += "LEFT JOIN ? ABB "
			cQry +=        "ON ABB.ABB_FILIAL = ? "
			cQry +=           "AND ABQ.ABQ_CODIGO = ABB.ABB_CODIGO "
			cQry +=           "AND ABB.D_E_L_E_T_ = ' ' "
			cQry += "LEFT JOIN ? ABP "
			cQry +=        "ON ABP.ABP_FILIAL = ? "
			cQry +=           "AND ABQ.ABQ_CODTFF = ABP.ABP_ITRH "
			cQry +=           "AND ABP.D_E_L_E_T_ = ' ' "
			cQry += "WHERE ABQ.ABQ_FILIAL = ? "
			cQry +=       "AND ABQ.ABQ_FILTFF = ? "
			cQry +=       "AND ABQ.ABQ_CODTFF = ? "
			cQry +=       "AND ABQ.ABQ_ORIGEM = ? "
			cQry +=       "AND ABP.ABP_BENEFI = ? "
			cQry +=       "AND ABQ.D_E_L_E_T_ = ' ' "

			nNum := 1
			cQry := ChangeQuery(cQry)
			oStatement := FwExecStatement():New(cQry)

			oStatement:SetUnsafe(nNum++, RetSqlName("ABQ"))
			oStatement:SetUnsafe(nNum++, RetSqlName("ABB"))
			oStatement:SetString(nNum++, FwxFilial("ABQ"))
			oStatement:SetUnsafe(nNum++, RetSqlName("ABP"))
			oStatement:SetString(nNum++, FwxFilial("ABP"))
			oStatement:SetString(nNum++, FwxFilial("ABQ"))
			oStatement:SetString(nNum++, FwxFilial("TFF"))
			oStatement:SetString(nNum++, FwFldGet("TFF_COD"))
			oStatement:SetString(nNum++, "TFJ") // ABQ_ORIGEM
			oStatement:SetString(nNum++, cBenefAnt)

			cAliasQry := oStatement:OpenAlias()
			oStatement:Destroy()
			FwFreeObj( oStatement )

			If (cAliasQry)->(!EOF()) // Exibe aviso caso já exista agenda atendida para o benefício.
				If MsgYesNo(STR0011) // "Este benefício já possui agenda atendida. Ao continuar, será gerada uma nova verba sem possibilidade de alteração ou exclusão. Deseja continuar?"
					lRet := .T.
					AAdd(aSkip, FwFldGet("TFF_COD")) // Adiciona o código do posto na lista para não validar novamente.
				Else
					lRet := .F.
				EndIf	
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf

	FWRestRows(aSaveLines)
	RestArea(aArea)
		
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFF
@description Função de Prevalidacao da grade de Recursos Humanos.
@sample 	PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.
@param		[xValor],Indefinido,Novo valor inserido no campo.
@param		[xValorAnt],Indefinido,Antigo valor do campo.

@since	06/05/2026
@author Amilton.Pereira
/*/
//------------------------------------------------------------------------------
Static Function PreLinTFF(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt)
	Local aArea      := GetArea()
	Local aSaveLines := FWSaveRows()
	Local cAliasQry  := ""
	Local cQry       := ""
	Local lRet       := .T.
	Local nNum       := 1
	Local oStatement := Nil
	
	If oMdlG <> Nil
		If cAcao $ "DELETE|CANSETVALUE"
			If !oMdlG:IsInserted()
				cQry := "SELECT 1 "
				cQry += "FROM   ? ABQ "
				cQry +=        "INNER JOIN ? ABB "
				cQry +=                "ON ABB.ABB_FILIAL = ? "
				cQry +=                   "AND ABQ.ABQ_CODIGO = ABB.ABB_CODIGO "
				cQry +=                   "AND ABB.D_E_L_E_T_ = ' ' "       
				cQry +=        "WHERE ABQ.ABQ_FILIAL = ? "
				cQry +=              "AND ABQ.ABQ_FILTFF = ? "
				cQry += 			 "AND ABQ.ABQ_CODTFF = ? "
				cQry +=              "AND ABQ.ABQ_ORIGEM = 'TFJ' "
				cQry +=              "AND ABQ.D_E_L_E_T_ = ' ' "

				nNum := 1
				cQry := ChangeQuery(cQry)
				oStatement := FwExecStatement():New(cQry)

				oStatement:SetUnsafe(nNum++, RetSqlName("ABQ"))
				oStatement:SetUnsafe(nNum++, RetSqlName("ABB"))
				oStatement:SetString(nNum++, FwxFilial("ABB"))
				oStatement:SetString(nNum++, FwxFilial("ABQ"))
				oStatement:SetString(nNum++, FwxFilial("TFF"))
				oStatement:SetString(nNum++, FwFldGet("TFF_COD"))

				cAliasQry := oStatement:OpenAlias()
				oStatement:Destroy()
				FwFreeObj( oStatement )
				
				If (cAliasQry)->(!EOF())
					lRet := .F.
					Help(,,"PreLinTFF",,STR0012,1,0) // "Não é possivel editar/deletar esse Posto, pois existem agendas vinculadas."
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf
	EndIf

	FWRestRows(aSaveLines)
	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinABP
@description Função de Prevalidacao da grade de Recursos Humanos.
@sample 	PosLinABP(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.
@param		[xValor],Indefinido,Novo valor inserido no campo.
@param		[xValorAnt],Indefinido,Antigo valor do campo.
@Return 	lRet, Logico, define se a ação pode ser concluída ou não.

@since	14/05/2026
@author Amilton.Pereira
/*/
//------------------------------------------------------------------------------
Static Function PosLinABP(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt)

	Local lRet := .T.

	If !Empty( oMdlG:GetValue('ABP_BENEFI')) .AND. oMdlG:GetValue('ABP_VALOR') == 0
		Help(,,"PosLinABP",,STR0013,1,0) // "O preenchimento do campo Valor é obrigatório em Verbas Adicionais."
		lRet := .F.
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At745VldDt
@description Função de Validação para os campos de data da rotina da TFL.
@sample 	At745VldDt(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edição
@param		[cAcao],Caractere,Ação sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor está posicionado.
@param		[xValor],Indefinido,Novo valor inserido no campo.
@param		[xValorAnt],Indefinido,Antigo valor do campo.
@Return 	lRet, Logico, define se a ação pode ser concluída ou não.

@since	18/05/2026
@author Amilton.Pereira
/*/
//------------------------------------------------------------------------------
Static Function At745VldDt(oMdlVld,cCampo,xValueNew,nLine,xValueOld)

	Local dDtFm := oMdlVld:GetValue( "TFL_DTFIM")
	Local dDtIn := oMdlVld:GetValue( "TFL_DTINI")
	Local lRet  := .T.

	// Usuário informou a data final antes da inicial 
	If !Empty(dDtFm) .And. Empty(dDtIn)
		Help(,,"At745VldDt",,STR0014,1,0) // Para continuar, informe primeiro a Data Inicial do Local de Atendimento.
		lRet := .F.
	// Data final menor que inicial
	ElseIf !Empty(dDtIn) .And. !Empty(dDtFm) .And. (dDtFm < dDtIn)
		Help(,,"At745VldDt",,STR0015,1,0) // A Data Inicial deve ser menor que a Data Final do Local de Atendimento.
		lRet := .F.
	EndIf

Return lRet	
