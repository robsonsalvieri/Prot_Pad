#Include "loca259j.ch"
#INCLUDE 'TOTVS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} MODELDEF
Definicão do modelo de Troca de Bens Quantificaveis na Demanda
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo do romaneio
/*/
STATIC FUNCTION MODELDEF()
Local oModel   := MPFormModel():New( 'LOCA259J', /*bPreValidacao*/, /*bPosValidacao*/ , /*bCommit*/, /*bCancel*/ )
Local oStruFQT := FWFormStruct( 1, 'FQT', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFQ5 := FWFormStruct( 1, 'FQ5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFH2 := FWFormStruct( 1, 'FH2', /*bAvalCampo*/,/*lViewUsado*/ )

oStruFQ5:AddField( STR0001, ' ', 'B1_DESC', 'C', TamSx3("B1_DESC")[1], 0, , , {}, .F.)   //'Descricao'
oStruFQ5:AddField(STR0002, ' ', 'QTDNEW', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.)   //'Separada'

oStruFQ5:SetProperty('B1_DESC'   , MODEL_FIELD_INIT,{|| Posicione("SB1",1,xFilial("SB1")+FQ5->FQ5_XPROD,"B1_DESC")} )
oStruFQ5:SetProperty('QTDNEW' , MODEL_FIELD_INIT,{||FQ5->FQ5_XQTD} )

oStruFH2:AddField("Item", ' ', 'ITEM', 'C', 3, 0, , , {}, .F.)


// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FQTMASTER', /*cOwner*/, oStruFQT, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por Grid
oModel:AddGrid( 'FQ5PAT', 'FQTMASTER', oStruFQ5, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'FH2QTD', 'FQ5PAT', oStruFH2, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:GetModel( 'FQ5PAT' ):SetDescription(STR0003)  //STR0001 //'Itens do Romaneio' //"Bens Quantificaveis"
oModel:GetModel( 'FH2QTD' ):SetDescription(STR0004)  //'Itens do Romaneio' //'ID dos Quantificaveis' //"I.D. dos Itens separados"
//Setando a chave primária da rotina
oModel:SetRelation( 'FQ5PAT', { { 'FQ5_FILIAL', 'xFilial("FQ5")' },{'FQ5_DEMAND','FQT_DEMAND'},{'FQ5_STATUS', "'6'"}}, FQ5->( IndexKey( 1 ) ) )
oModel:SetRelation( 'FH2QTD', { { 'FH2_FILIAL', 'xFilial("FH2")' },{'FH2_AS','FQ5_AS'} }, FH2->( IndexKey( 1 ) ) )

oModel:GetModel( 'FQ5PAT'):SetLoadFilter( , " EXISTS ( SELECT B1_COD FROM "+ RetSqlName("SB1") + " SB1 INNER JOIN "+ RetSqlName("SBM") + " SBM ON BM_FILIAL = '"+xFilial("SBM")+"' and BM_GRUPO = B1_GRUPO and BM_XACESS = '3' and SBM.D_E_L_E_T_ = ' ' WHERE B1_FILIAL = '"+xFilial('SB1')+"' and B1_COD = FQ5_XPROD and SB1.D_E_L_E_T_ = ' ')" )   

oModel:GetModel( 'FQ5PAT' ):SetNoInserLine(.T.)
oModel:GetModel( 'FQ5PAT' ):SetNoDeleteLine(.T.)

oModel:GetModel('FQ5PAT'):SetOptional(.T.)
oModel:GetModel('FH2QTD'):SetOptional(.T.)
// Liga a validação da ativacao do Modelo de Dados
oModel:SetVldActivate({|oModel| Loca259JVM(oModel)})

oModel:SetOnlyQuery('FQ5PAT', .T.)
oModel:SetOnlyQuery('FH2QTD', .T.)
oModel:SetOnlyQuery('FQTMASTER', .T.)
oModel:GetModel('FQTMASTER'):SetOnlyView()
oModel:GetModel('FQ5PAT'):SetLPost({|| LOCA229JQ5()})
oModel:GetModel("FH2QTD"):SetLPre({|oGrid,nLinha,cAcao| Loca259LPV(oGrid,nLinha,cAcao)})

Return oModel


/*/{Protheus.doc} ViewDef
Define a View da Demanda
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Retorna a view da demanda
/*///-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOCA259J' )
Local oStruFQT := FWFormStruct( 2, 'FQT', {|cCampo| cCampo $ "FQT_DEMAND FQT_PROJET FQT_OBRA   FQT_DESC   "},/*lViewUsado*/ )
Local oStruFQ5 := FWFormStruct( 2, 'FQ5', {|cCampo| cCampo $ "FQ5_AS     FQ5_XPROD  FQ5_XQTD  "},/*lViewUsado*/ )
Local oStruFH2 := FWFormStruct( 2, 'FH2', {|cCampo| cCampo $ "FH2_CODBEM FH2_NOMBEM "}/*bAvalCampo*/,/*lViewUsado*/ )
Local oView
Local cPictQtd  := X3Picture("FQ5_XQTD")

oStruFQ5:AddField("B1_DESC"   , '003 ', STR0001, STR0005, {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/)   //'Descricao' //"Descricao do Produto"
oStruFQ5:AddField("QTDNEW"    , '005 ', STR0002, STR0006, {}, "G", cPictQtd ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/)   //'Quantidade Separada' //'Separada'

oStruFQ5:SetProperty("FQ5_AS"    , MVC_VIEW_CANCHANGE, .F.)
oStruFQ5:SetProperty("FQ5_XPROD" , MVC_VIEW_CANCHANGE, .F.)
oStruFQ5:SetProperty("FQ5_XQTD"  , MVC_VIEW_CANCHANGE, .F.)
oStruFQ5:SetProperty("FQ5_AS"     , MVC_VIEW_ORDEM, '001')
oStruFQ5:SetProperty("FQ5_XPROD"  , MVC_VIEW_ORDEM, '002')
oStruFQ5:SetProperty("FQ5_XQTD"   , MVC_VIEW_ORDEM, '004')

oStruFQT:SetProperty("FQT_DEMAND", MVC_VIEW_GROUP_NUMBER, " " )
oStruFQT:SetProperty("FQT_PROJET", MVC_VIEW_GROUP_NUMBER, " ")
oStruFQT:SetProperty("FQT_DESC", MVC_VIEW_GROUP_NUMBER, " ")
oStruFQT:SetProperty("FQT_OBRA", MVC_VIEW_GROUP_NUMBER, " ")

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oStruFH2:AddField("ITEM", '01 ', STR0007, STR0007, {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/, .F./*lCanChange*/,"1"/*cFolder*/) //'Item'

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQT', oStruFQT, 'FQTMASTER' )
oView:AddGrid( 'VIEW_FQ5', oStruFQ5, 'FQ5PAT' )
oView:AddGrid( 'VIEW_FH2', oStruFH2, 'FH2QTD' )

oView:addIncrementField("VIEW_FH2","ITEM")

oView:EnableTitleView('VIEW_FQ5',  STR0008) //"A.S. Devolvidas" //"A.S. Quantificaveis"
oView:EnableTitleView('VIEW_FH2',  STR0009) //"I.D. Retornados" //"I.D. Separadas"

oView:AddOtherObject('LeituraDEL', {|oPanel,oView| LOCA229JCD(oPanel, 'FQ5PAT', 'FH2QTD')})
oView:AddOtherObject('LeituraINS', {|oPanel,oView| LOCA229JCI(oPanel, 'FQ5PAT', 'FH2QTD')})
oView:EnableTitleView('LeituraDEL',  STR0010) //"Remover"
oView:EnableTitleView('LeituraINS',  STR0019)  //"Adicionar"

oView:SetViewProperty('FQ5PAT', 'GRIDSEEK'  , {.T.})
oView:SetViewProperty('FQ5PAT', 'GRIDFILTER', {.T.})
oView:SetViewProperty('FH2QTD', 'GRIDSEEK'  , {.T.})
oView:SetViewProperty('FH2QTD', 'GRIDFILTER', {.T.})
// Altura das Linhas
oView:SetViewProperty("*", "GRIDROWHEIGHT", {20})

// Criar um 'box' horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'CABEC' , 20 )
oView:CreateHorizontalBox( 'ITENS' , 80 )
oView:CreateVerticalBox('FQ5IT',60,'ITENS')
oView:CreateVerticalBox('IDS',40,'ITENS')
oView:CreateHorizontalBox( 'FH2IT' , 80 , 'IDS')

oView:CreateHorizontalBox( 'CODBAR' , 20 , 'IDS')
oView:CreateVerticalBox('ID_DEL',50,'CODBAR')
oView:CreateVerticalBox('ID_INS',50,'CODBAR')

// Relaciona o ID da View com o 'box' para exibicao
oView:SetOwnerView( 'VIEW_FQT', 'CABEC' )
oView:SetOwnerView( 'VIEW_FQ5', "FQ5IT" )
oView:SetOwnerView( 'VIEW_FH2', 'FH2IT' )
oView:SetOwnerView( 'LeituraDEL', 'ID_DEL' )
oView:SetOwnerView( 'LeituraINS', 'ID_INS' )

oView:SetViewAction("BUTTONOK", { |oView| LOCA229JPR( oView ) } )
//Definindo que não irá usar o "Salvar e Criar Novo"
oView:SetCloseOnOk({|| .T.})
oView:EnableControlBar(.T.)
oView:SetProgressBar(.T.)
oView:setUpdateMessage(STR0012,STR0011)  //"Processo finalizado com sucesso" //"Troca de I.D."

Return oView


/*/{Protheus.doc} LOCA259JVM
Valida se o Model de troca de itens poderá ser ativado
@type function
@version 25.10
@author Alexandre Circenis
@since 19/01/2026
@param oModel, object, Model de troca de itens
@return variant, Retorna .T. se o model puder ser ativado
/*/
Function LOCA259JVM(oModel)
Local lRet     := .T.
Local aArea    := GetArea()
Local aFH2

	if FQT->FQT_ITENS = 0
		oModel:SetErrorMessage("","","","","LOCA259J_01",STR0021)  //"A demanda está vazia, não há itens para alterar"
		lRet := .F.
	endif

	if lRet .and. FQT->FQT_FATURA = FQT->FQT_QTDPRO
		oModel:SetErrorMessage("","","","","LOCA259J_03",STR0022)  //"A Demanda já possui NF ou Pedido emitidos, portanto não é possível realizar alterações nos itens."
		lRet := .F.
	endif

	if lRet
		aFH2 := LOCA259JH2(FQT->FQT_DEMAND)
		if aFH2[1] = 0 // Não há registros na FH2 
			oModel:SetErrorMessage("","","","","LOCA259J_04",STR0023)   //"Não há Bens Quantificaveis aptos para realizar a atualização de ID."
			lRet := .F.
		elseif aFH2[2] = 0 // Não há FH2 sem pedido gerado
			oModel:SetErrorMessage("","","","","LOCA259J_05",STR0024)  //"A Demanda já possui NF ou Pedido emitidos, portanto não é possível realizar alterações nos itens." //"Todos os Bens Quantificaveis estão com remessa gerada não permitindo alterações."
			lRet := .F.
		endif
	endif
	
	RestArea(aArea)

RETURN lRet

/*/{Protheus.doc} LOCA259JH2
Avalia as cuantidades de itens do tipo Bem Quantaificavel que passiveis de manutenção dentro da Demanda.
Condições: 
O item da demanda deve estar separado
O item que que ser de um grupo que tenha o campo BM_XACESS = '3' (Bem Quantificavel)
Serão contatos o numero de ITens na FH2 e o numero de itens da FH2 sem pedido gerado

@type function
@version  25.10
@author Alexandre Circenis
@since 17/04/2026
@param cDemanda, character, Codigo da Demanda
@return variant, Array contendo O numero de registros da FH2 e o numero de registros da FH2 sem pedido gerado
/*/
Function LOCA259JH2(cDemanda)
Local aRet := {0,0}
Local cQuery
Local aArea := GetArea()
Local aBindParam := {}


 	cQuery := " SELECT Count(*) TOTREG, "
	cQuery += " Count( CASE WHEN FH2_PEDIDO = ' ' THEN 1 END ) TOTFAT"
    cQuery += " FROM " + RETSQLNAME("FQ5") + " FQ5 "
	cQuery += " INNER JOIN " + RETSQLNAME("SB1") + " SB1 "
	cQuery += " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " AND SB1.B1_COD = FQ5.FQ5_XPROD "
	cQuery += " INNER JOIN " + RETSQLNAME("SBM") + " SBM "
	cQuery += " ON SBM.BM_FILIAL = '"+xFilial("SBM")+"' "
	cQuery += " AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += " AND SBM.BM_GRUPO = SB1.B1_GRUPO "
	cQuery += " AND SBM.BM_XACESS = '3'"
	cQuery += " LEFT JOIN " + RETSQLNAME("FH2") + " FH2 "
	cQuery += " ON FH2.FH2_FILIAL = '"+xFilial("FH2")+"' "
	cQuery += " AND FH2.D_E_L_E_T_ = ' ' "
	cQuery += " AND FH2.FH2_AS = FQ5_AS "
    
    cQuery += " WHERE FQ5.FQ5_FILIAL = '"+xFilial("FQ5")+"' "
	cQuery += " AND FQ5.FQ5_STDEMA = '2' "
	cQuery += " AND FQ5.D_E_L_E_T_ = ' ' "
	cQuery += " AND FQ5.FQ5_DEMAND = ? "
    Aadd( aBindParam, cDemanda )
  
    cQuery := CHANGEQUERY(cQuery)
    MPSysOpenQuery(cQuery,"TRBFQ5",,,aBindParam)

	aRet[1] := TRBFQ5->TOTREG
	aRet[2] := TRBFQ5->TOTFAT

	RestArea(aArea)

Return aRet
