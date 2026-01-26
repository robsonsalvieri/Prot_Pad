#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA500.CH"

Static cAgenPerg := ''
Static cGridFocus:= '' 
Static aDadosProc:= {} 
Static lNewTot   := .F.
Static lHabFilBrw:= .F.
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA500
Fechamento da arrecadação
@author  Renan Ribeiro Brando
@since   20/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA500()

Local oBrowse := Nil
Local cQuery  := ''

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

    lHabFilBrw := GTPGetRules("HABFILUSR",,,.F.)
	
    If lHabFilBrw
        cQuery := " G59_AGENCI IN (SELECT G9X_CODGI6 FROM " + RetSqlName("G9X") 
        cQuery += " WHERE G9X_FILIAL = '" + xFilial('G9X') + "' "
        cQuery += " AND G9X_CODUSR = '" + __cUserId + "' "
        cQuery += " AND D_E_L_E_T_ = ' ' ) "    
    EndIF 
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("G59")
    oBrowse:SetDescription(STR0001) // "Fechamento da Arrecadação"
    
    oBrowse:AddLegend("!G59_STATUS" , "GREEN"   , STR0002, "G59_STATUS") // "Aberto"
    oBrowse:AddLegend("G59_STATUS"  , "RED"     , STR0003, "G59_STATUS") // "Fechado"
    If G59->(FieldPos('G59_STFINA')) > 0
        oBrowse:AddLegend("G59_STFINA == '0'", "BR_BRANCO"      , 'Aguard.Fech.'          , "G59_STFINA")     //'Aguard.Fech.'
        oBrowse:AddLegend("G59_STFINA == '1'", "BR_VERDE"       , 'Financ.Gerado'         , "G59_STFINA")     //'Financ.Gerado'
        oBrowse:AddLegend("G59_STFINA == '2'", "BR_AMARELO"     , 'Inconsistência Financ.', "G59_STFINA")     //'Inconsistência Financ.' 
        oBrowse:AddLegend("G59_STFINA == ' '", "BR_AZUL_CLARO"  , 'Sem legenda'           , "G59_STFINA")     //'Sem legenda.' 
    EndIF    

    If lHabFilBrw
        oBrowse:SetFilterDefaut("@" + cQuery)     
    EndIf         
    oBrowse:Activate()
    aSize(aDadosProc,0)
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu do Fechamento
@author  Renan Ribeiro Brando
@since   20/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GTPA500" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005 ACTION "ExcGTPA500()"    OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0007 ACTION "GA500Acert()"    OPERATION 3 ACCESS 0 //"Acerto"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GTPA500" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0008 ACTION "GA500Fech()"     OPERATION 4 ACCESS 0 //"Fechar"
ADD OPTION aRotina TITLE STR0009 ACTION "GA500Abre()"     OPERATION 4 ACCESS 0 //"Abrir"
ADD OPTION aRotina TITLE STR0045 ACTION "GA500VRMD()"     OPERATION 4 ACCESS 0 // "RMD"
ADD OPTION aRotina TITLE STR0046 ACTION "G500GerTit()"    OPERATION 4 ACCESS 0 // "Gera Títulos Cartão POS"
ADD OPTION aRotina TITLE STR0051 ACTION "G500OpTit('1',.t.)"  OPERATION 4 ACCESS 0 // "Gera Títulos Receita"
ADD OPTION aRotina TITLE STR0052 ACTION "G500OpTit('2',.t.)"  OPERATION 4 ACCESS 0 // "Gera Títulos Despesa"
ADD OPTION aRotina TITLE STR0158 ACTION "G500Reproc()"    OPERATION 4 ACCESS 0 // "Reprocessa Tit.Receita/Despesa"


Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo de Dados do Fechamento
@author  Renan Ribeiro Brando
@since   20/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruG59     := FWFormStruct(1, "G59") //Tabela de Fechamento da Arrecadação
Local oStruGIC     := FWFormStruct(1, "GIC") //Tabela de Bilhetes 
Local oStruG57     := FWFormStruct(1, "G57") //Tabela de Taxas
Local oStruGZGD    := FWFormStruct(1, "GZG") //Tabela de Receita e despesa
Local oStruGZGE    := FWFormStruct(1, "GZG") //Tabela de Receita e despesa
Local oStruGQW     := FWFormStruct(1, "GQW") //Tabela de Requisição
Local oStruG99     := FWFormStruct(1, "G99") //Tabela de Conhecimento
Local oStruGQM     := FWFormStruct(1, "GQM") //Tabela de pos
Local oStruGQL     := FWFormStruct(1, "GQL") //Tabela de pos
Local bPosvalid	   := {|oModel| PosValid(oModel)}
Local bCommit	   := {|oModel| GA500Commit(oModel)}
Local bVldActivate := {|oModel| VldActivate(oModel)}
Local bActivate    := {|oModel| Activate(oModel)}
Local aModels      := {}
Local nCont        := 0
Local oModel       
lNewTot   := G59->(FieldPos('G59_VLTODE')) > 0 .And. G59->(FieldPos('G59_VLTOES')) > 0  .And. G59->(FieldPos('G59_VLDIFE')) > 0 .And. G59->(FieldPos('G59_VLFICH')) > 0 

oModel := MPFormModel():New("GTPA500", /*bPreValidMdl*/, bPosvalid, /*bCommit*/, /*bCancel*/ )
SetModelStruct(oStruG59,oStruGIC,oStruG57,oStruGQL,oStruGQM,oStruGZGD,oStruGZGE,oStruGQW,oStruG99,oModel)
oModel:SetCommit(bCommit)
oModel:SetDescription(STR0001) //"Fechamento da Arrecadação"

oModel:AddFields("G59MASTER", ,oStruG59)

oModel:AddGrid("GICDETAIL", "G59MASTER", oStruGIC, , , , ,)
oModel:GetModel("GICDETAIL"):SetDescription(STR0054) //"Bilhetes"

oModel:AddGrid("G57DETAIL", "G59MASTER", oStruG57, , , , ,)
oModel:GetModel("G57DETAIL"):SetDescription(STR0055) //"Taxas"

oModel:AddGrid("G99DETAIL", "G59MASTER", oStruG99, , , , ,)
oModel:GetModel("G99DETAIL"):SetDescription(STR0056) //"Conhecimento"

oModel:AddGrid("GQLDETAIL", "G59MASTER", oStruGQL, , , , ,)
oModel:GetModel("GQLDETAIL"):SetDescription(STR0057) //"Vendas POS"

oModel:AddGrid("GQMDETAIL", "GQLDETAIL", oStruGQM, , , , ,)
oModel:GetModel("GQMDETAIL"):SetDescription(STR0057) //"Vendas POS"

oModel:AddGrid("GZGDETAILD", "G59MASTER", oStruGZGD, , , , ,)
oModel:GetModel("GZGDETAILD"):SetDescription(STR0058)//"Receita"

oModel:AddGrid("GZGDETAILE", "G59MASTER", oStruGZGE, , , , ,)
oModel:GetModel("GZGDETAILE"):SetDescription(STR0059)//"Despesa"

oModel:AddGrid("GQWDETAIL", "G59MASTER", oStruGQW, , , , ,)
oModel:GetModel("GQWDETAIL"):SetDescription(STR0060) //"Requisição"

oModel:SetRelation( 'GICDETAIL', { { 'GIC_FILIAL', 'xFilial( "GIC" )' }, { 'GIC_AGENCI' , 'G59_AGENCI' } ,{ 'GIC_NUMFCH', 'G59_NUMFCH' } }, GIC->(IndexKey(1)))
oModel:SetRelation( 'G57DETAIL', { { 'G57_FILIAL', 'xFilial( "G57" )' }, { 'G57_AGENCI', 'G59_AGENCI' } ,{ 'G57_NUMFCH', 'G59_NUMFCH' } }, G57->(IndexKey(1)))
oModel:SetRelation( 'G99DETAIL', { { 'G99_FILIAL', 'xFilial( "G59" )' }, { 'G99_CODEMI', 'G59_AGENCI' } ,{ 'G99_NUMFCH', 'G59_NUMFCH' } } )
oModel:SetRelation( 'GZGDETAILD', { { 'GZG_FILIAL', 'xFilial( "GZG" )' }, { 'GZG_AGENCI', 'G59_AGENCI' } ,{ 'GZG_NUMFCH', 'G59_NUMFCH' },{ 'GZG_TIPO', "'2'" }  } )
oModel:SetRelation( 'GZGDETAILE', { { 'GZG_FILIAL', 'xFilial( "GZG" )' }, { 'GZG_AGENCI', 'G59_AGENCI' } ,{ 'GZG_NUMFCH', 'G59_NUMFCH' },{ 'GZG_TIPO', "'1'" }  } )
oModel:SetRelation( 'GQLDETAIL', { { 'GQL_FILIAL', 'xFilial( "GQL" )' }, { 'GQL_CODAGE', 'G59_AGENCI' } ,{ 'GQL_NUMFCH', 'G59_NUMFCH' } } )
oModel:SetRelation( 'GQMDETAIL' ,{{'GQM_FILIAL' , 'xFilial("GQM")'},{'GQM_CODGQL' , 'GQL_CODIGO'}})

If GQW->(FieldPos('GQW_NUMFCH')) > 0 
    oModel:SetRelation( 'GQWDETAIL', { { 'GQW_FILIAL', 'xFilial( "GQW" )' }, { 'GQW_CODAGE', 'G59_AGENCI' } ,{ 'GQW_NUMFCH', 'G59_NUMFCH' } } )
Endif

oModel:SetVldActivate(bVldActivate)

oModel:SetActivate(bActivate)

//Feito um laço pois não mudaria as propriedades para os modelos
aModels := {"GICDETAIL","G57DETAIL","G99DETAIL","GQLDETAIL","GQMDETAIL","GZGDETAILD","GZGDETAILE","GQWDETAIL"}
For nCont := 1 To Len(aModels)
    oModel:GetModel(aModels[nCont]):SetOnlyQuery(.T.)
    oModel:GetModel(aModels[nCont]):SetNoInsertLine(.T.)
    oModel:GetModel(aModels[nCont]):SetOptional(.T.)
    oModel:GetModel(aModels[nCont]):SetNoDeleteLine( .T. )	
    oModel:GetModel(aModels[nCont]):SetMaxLine(999999)
Next nCont

Return oModel

/*/{Protheus.doc} SetModelStruct(oStruG59,oStruGIC,oStruG57,oStruGQL,oStruGZGD,oStruGZGE,oStruGQW,oStruG99)
    (long_description)
    @type  Static Function
    @author user
    @since 17/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function SetModelStruct(oStruG59,oStruGIC,oStruG57,oStruGQL,oStruGQM,oStruGZGD,oStruGZGE,oStruGQW,oStruG99,oMdl)

Local aNewFlds  := {'GQM_CONFER', 'GQM_DTCONF', 'GQM_USUCON'}
Local lNewFlds  := GTPxVldDic('GQM', aNewFlds, .F., .T.)
Local bTrig     := {|oMdl,cField,uVal| G500Trigger(oMdl,cField,uVal)}
Local bFldVld   := {|oMdl,cField,uNewValue,uOldValue| G500dValid(oMdl,cField,uNewValue,uOldValue)}

oStruGQL:SetProperty("GQL_CODADM", MODEL_FIELD_VALID, bFldVld )
If lNewFlds
    oStruGQL:AddTrigger('GQM_CONFER','GQM_CONFER',{||.T.}, bTrig)
EndIf

oStruG59:SetProperty('G59_DATFIM', MODEL_FIELD_VALID, {|oModel| VldDate(oModel) } )
oStruG59:SetProperty("G59_CODIGO", MODEL_FIELD_INIT , {|| GTPXUnq("G59",1,"G59_CODIGO") }) 

// Estrutura GY3 Demonstrativo de Passagens
oStruGIC:SetProperty("*", MODEL_FIELD_INIT   , {|| "" }) 
oStruGIC:SetProperty('*', MODEL_FIELD_VALID  , {|| .T.})
oStruGIC:SetProperty("*", MODEL_FIELD_OBRIGAT,     .F. )

oStruG99:SetProperty('*', MODEL_FIELD_VALID  , {|| .T.})
oStruG99:SetProperty("*", MODEL_FIELD_OBRIGAT,     .F. )

If GZG->(FieldPos("GZG_CONFER"))
    oStruGZGE:SetProperty("GZG_CONFER", MODEL_FIELD_VALID, bFldVld )

    oStruGZGD:SetProperty("GZG_CONFER", MODEL_FIELD_VALID, bFldVld )
EndIf
 
Return

/*/{Protheus.doc} G500Trigger(oMdl,cField,uVal)
(long_description)
@type function
@author flavio.martins
@since 03/06/2020
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G500Trigger(oMdl,cField,uVal)

If cField == 'GQM_CONFER'

    If uVal != '3'
        oMdl:ClearField('GQM_MOTREJ')
    Endif

Endif

Return

/*/{Protheus.doc} G500dValid(oMdl,cField,uNewValue,uOldValue)
(long_description)
@type function
@author flavio.martins
@since 03/06/2020
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G500dValid(oMdl,cField,uNewValue,uOldValue)
Local lRet     := .T.
Local cMsgErro := ''
Local cMsgSol  := ''

If cField == 'GQL_CODADM'

    If !GtpExistCpo('SAE',uNewValue)
        lRet        := .F.
        cMsgErro    := STR0073 //"Registro não encontrado ou se encontra bloqueado"
        cMsgSol     := STR0074 //"Verifique os dados informados"
    Endif 
        
Endif

If cField == "GZG_CONFER"
    If oMdl:GetValue("GZG_CARGA")
        lRet        := .F.
    EndIf 
EndIf

If !lRet .and. !Empty(cMsgErro)
	oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"G500dValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View do Fechamento
@author  Renan Ribeiro Brando
@since   20/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel    := ModelDef()
Local oStruG59  := FWFormStruct(2, "G59")
Local oStruGIC  := FWFormStruct(2, "GIC")
Local oStruG57  := FWFormStruct(2, "G57")	
Local oStruG99  := FWFormStruct(2, "G99")
Local oStruGQW  := FWFormStruct(2, "GQW")
Local oStruGQM  := FWFormStruct(2, "GQM")
Local oStruGQL  := FWFormStruct(2, "GQL")
Local oStruGZGD := FWFormStruct(2, "GZG")
Local oStruGZGE := FWFormStruct(2, "GZG")

SetViewStruct(oStruG59,oStruGIC,oStruG57,oStruGQL,oStruGQM,oStruGZGD,oStruGZGE,oStruGQW,oStruG99,oModel)

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_G59",  oStruG59,  "G59MASTER" )
oView:AddGrid("VIEW_GIC",   oStruGIC,  "GICDETAIL" )
oView:AddGrid("VIEW_G57",   oStruG57,  "G57DETAIL" )
oView:AddGrid("VIEW_G99",   oStruG99,  "G99DETAIL" )
oView:AddGrid("VIEW_GQM",   oStruGQM,  "GQMDETAIL" )
oView:AddGrid("VIEW_GQL",   oStruGQL,  "GQLDETAIL" )
oView:AddGrid("VIEW_GQW",   oStruGQW,  "GQWDETAIL" )
oView:AddGrid("VIEW_GZGD",  oStruGZGD, "GZGDETAILD")
oView:AddGrid("VIEW_GZGE",  oStruGZGE, "GZGDETAILE")

oView:CreateHorizontalBox('VIEWTOP'   , 30)
oView:CreateHorizontalBox('VIEWBOTTOM', 70)

//Criação da Visão: Demonstrativos de Passagens
oView:CreateFolder( 'FOLDER1', 'VIEWBOTTOM')
oView:AddSheet('FOLDER1','SHEET1', STR0054) //"Bilhetes"
oView:CreateHorizontalBox( 'BOX1', 100, , , 'FOLDER1', 'SHEET1')

oView:AddSheet('FOLDER1','SHEET2', STR0055)//"Taxas"
oView:CreateHorizontalBox( 'BOX2', 100, , , 'FOLDER1', 'SHEET2')

oView:AddSheet('FOLDER1','SHEET3', STR0056) //"Conhecimento"
oView:CreateHorizontalBox( 'BOX3', 100, , , 'FOLDER1', 'SHEET3')

oView:AddSheet('FOLDER1','SHEET5', STR0057) //"Vendas POS"
//oView:CreateHorizontalBox( 'BOX4', 100, , , 'FOLDER1', 'SHEET5')
oView:CreateVerticalBox( 'BOX1ESQ', 50, , , 'FOLDER1', 'SHEET5') // BOX DE RECEITAS
oView:CreateVerticalBox( 'BOX1DIR', 50, , , 'FOLDER1', 'SHEET5') // BOX DE DESPESAS

oView:AddSheet('FOLDER1','SHEET4', STR0075) //"Receita/Despesa"
oView:CreateVerticalBox( 'BOX2ESQ', 50, , , 'FOLDER1', 'SHEET4') // BOX DE RECEITAS
oView:CreateVerticalBox( 'BOX2DIR', 50, , , 'FOLDER1', 'SHEET4') // BOX DE DESPESAS

oView:AddSheet('FOLDER1','SHEET6', STR0076) //"Requisições"
oView:CreateHorizontalBox( 'BOX5', 100, , , 'FOLDER1', 'SHEET6')

oView:EnableTitleView('VIEW_GZGE' , STR0058) // "Receitas"
oView:EnableTitleView('VIEW_GZGD' , STR0059) // "Despesas"

oView:EnableTitleView('VIEW_GQM' , "Itens Vendas POS")
oView:EnableTitleView('VIEW_GQL' , "Vendas POS")

oView:SetOwnerView("VIEW_G59","VIEWTOP")
oView:SetOwnerView("VIEW_GIC","BOX1")
oView:SetOwnerView("VIEW_G57","BOX2")
oView:SetOwnerView("VIEW_G99","BOX3")
oView:SetOwnerView("VIEW_GQW","BOX5")
oView:SetOwnerView("VIEW_GQM","BOX1DIR")
oView:SetOwnerView("VIEW_GQL","BOX1ESQ")
oView:SetOwnerView("VIEW_GZGD","BOX2DIR")
oView:SetOwnerView("VIEW_GZGE","BOX2ESQ")

//Agrupadores Cabeçalho
oStruG59:AddGroup( "GROUP1","Dados Principais"  , "" , 2 ) // "Dados Principais"
oStruG59:AddGroup( "GROUP2","Totais"            , "" , 2 ) // "Totais"

oStruG59:SetProperty("*" 		  , MVC_VIEW_GROUP_NUMBER, "GROUP1" )

If lNewTot
    oStruG59:SetProperty("G59_VLFICH" , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
    oStruG59:SetProperty("G59_VLDIFE" , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
    oStruG59:SetProperty("G59_VLTODE" , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
    oStruG59:SetProperty("G59_VLTOES" , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
    oStruG59:SetProperty("G59_VLRLIQ" , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
EndIf 

oStruG59:SetProperty("G59_RECBIL" , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
oStruG59:SetProperty("G59_DESBIL" , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
oStruG59:SetProperty("G59_TOTAL"  , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
oStruG59:SetProperty("G59_VLRCTE" , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
oStruG59:SetProperty("G59_VLRREC" , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
oStruG59:SetProperty("G59_VLRDES" , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
oStruG59:SetProperty("G59_VLPOS"  , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
oStruG59:SetProperty("G59_VLREQ"  , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
oStruG59:SetProperty("G59_RECTAX" , MVC_VIEW_GROUP_NUMBER, "GROUP2" )
oStruG59:SetProperty("G59_DESTAX" , MVC_VIEW_GROUP_NUMBER, "GROUP2" )

oStruG59:SetProperty("G59_RECBIL" , MVC_VIEW_ORDEM, '01')
oStruG59:SetProperty("G59_DESBIL" , MVC_VIEW_ORDEM, '02')
oStruG59:SetProperty("G59_RECTAX" , MVC_VIEW_ORDEM, '03')
oStruG59:SetProperty("G59_DESTAX" , MVC_VIEW_ORDEM, '04')
If lNewTot
    oStruG59:SetProperty("G59_VLDIFE" , MVC_VIEW_ORDEM, '05')
EndIf 
oStruG59:SetProperty("G59_TOTAL"  , MVC_VIEW_ORDEM, '06')
oStruG59:SetProperty("G59_VLRCTE" , MVC_VIEW_ORDEM, '07')
oStruG59:SetProperty("G59_VLRREC" , MVC_VIEW_ORDEM, '08')
oStruG59:SetProperty("G59_VLRDES" , MVC_VIEW_ORDEM, '09')
oStruG59:SetProperty("G59_VLPOS"  , MVC_VIEW_ORDEM, '10')
oStruG59:SetProperty("G59_VLREQ"  , MVC_VIEW_ORDEM, '11')
If lNewTot
    oStruG59:SetProperty("G59_VLFICH" , MVC_VIEW_ORDEM, '12')
    oStruG59:SetProperty("G59_VLTODE" , MVC_VIEW_ORDEM, '13')
    oStruG59:SetProperty("G59_VLTOES" , MVC_VIEW_ORDEM, '14')
    oStruG59:SetProperty("G59_VLRLIQ" , MVC_VIEW_ORDEM, '15')
EndIf 

If oModel:GetOperation() == MODEL_OPERATION_VIEW 
    oView:AddUserButton( STR0134 , "", {|oView| GA500View(oView)} )    // 'Consulta Titulo'
    oView:GetViewObj("VIEW_GZGE")[3]:SetGotFocus({||cGridFocus := "V_RECEITA" })
    oView:GetViewObj("VIEW_GZGD")[3]:SetGotFocus({||cGridFocus := "V_DESPESA" })    

EndIf 

Return oView

/*/{Protheus.doc} SetViewStruct(oStruG59,oStruGIC,oStruG57,oStruGQL,oStruGZGD,oStruGZGE,oStruGQW,oStruG99)
(long_description)
@type  Static Function
@author user
@since 17/06/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStruG59,oStruGIC,oStruG57,oStruGQL,oStruGQM,oStruGZGD,oStruGZGE,oStruGQW,oStruG99,oMdl)

Local cFields   := ""
Local aNewFlds  := {'GQM_CONFER', 'GQM_DTCONF', 'GQM_USUCON'}
Local lNewFlds  := GTPxVldDic('GQM', aNewFlds, .F., .T.)

// Configuração dos campos que serão utlizados no fechamento
// Bilhetes
PrepareStruct(@oStruGIC, "GIC_CODIGO|GIC_BILHET|GIC_TIPO|GIC_DTVEND|GIC_TAR|GIC_TAX|";
    +"GIC_PED|GIC_SGFACU|GIC_OUTTOT|GIC_VALTOT|GIC_VLACER|GIC_SERIE|GIC_SUBSER|GIC_NUMCOM|GIC_CONFER";
    +Iif(GIC->(FieldPos('GIC_DTFECH')) > 0,'|GIC_DTFECH',''))

//  Taxas
PrepareStruct(@oStruG57, "G57_SERIE|G57_SUBSER|G57_NUMCOM|G57_CODIGO|G57_TIPO|G57_DESDOC|G57_VALOR|G57_VALACE|")

//  Conhecimento
cFields := "G99_CODIGO|"
cFields += "G99_SERIE|"
cFields += "G99_NUMDOC|"
cFields += "G99_DTEMIS|"
cFields += "G99_HREMIS|"
cFields += "G99_KMFRET|"
cFields += "G99_VALOR|" 
cFields += "G99_TIPCTE|"
cFields += "G99_STAENC|"
cFields += "G99_STATRA|"
If G99->(FIELDPOS( "G99_CONFER" )) > 0
    cFields += "G99_CONFER|"
EndIf
If G99->(FIELDPOS( "G99_VALACE" )) > 0
    cFields += "G99_VALACE|"
EndIf
PrepareStruct(@oStruG99, cFields)
If lNewFlds
    oStruGQM:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
    oStruGQM:SetProperty("GQM_CONFER", MVC_VIEW_CANCHANGE, .T.)
EndIf
If GZG->(FieldPos("GZG_CONFER"))
    oStruGZGE:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
    oStruGZGE:SetProperty("GZG_CONFER", MVC_VIEW_CANCHANGE, .T.)

    oStruGZGD:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
    oStruGZGD:SetProperty("GZG_CONFER", MVC_VIEW_CANCHANGE, .T.)
EndIf
oStruG59:SetProperty("G59_CODIGO", MVC_VIEW_CANCHANGE, .F.)
oStruG59:SetProperty("G59_VLRCTE", MVC_VIEW_CANCHANGE, .F.)
If G59->(FIELDPOS( "G59_VLRREC" )) > 0
    oStruG59:SetProperty("G59_VLRREC", MVC_VIEW_CANCHANGE, .F.)
EndIf

If G59->(FieldPos('G59_STAPRO')) > 0
    oStruG59:RemoveField("G59_STAPRO")    
Endif

oStruGIC:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
oStruG57:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
oStruG99:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
oStruGQW:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
oStruG99:SetProperty("G99_TIPCTE", MVC_VIEW_COMBOBOX, {STR0077,STR0078,STR0080,STR0079 }) //"0=Normal" //"1=Complemento" //"3=Substituição" //"2=Anulação"
oStruG99:SetProperty("G99_STAENC", MVC_VIEW_COMBOBOX, {STR0084,STR0085,STR0081,STR0082,STR0083}) //"3=Em Transbordo" //"4=Recebido" //"5=Retirado" //"1=Aguardando" //"2=Em Transporte"
oStruG99:SetProperty("G99_STATRA", MVC_VIEW_COMBOBOX, {STR0086,STR0088,STR0093,STR0094,STR0095,STR0092,STR0089,STR0090,STR0091,STR0087}) //"0=CTe Não Transmitido" //"9=Documento não preparado para transmissão" //"1=CTe Aguardando" //"6=Doc. de Saída Excluído" //"7=Cancelamento Rejeitado" //"8=CTe Cancelado" //"5=CTe com Falha na Comunicacao" //"2=CTe Autorizado" //"3=CTe Nao Autorizado" //"4=CTe em Contingencia"

cFields := "GQW_CODIGO|GQW_CODORI|GQW_RECDES|GQW_CODCLI|GQW_CODLOJ|GQW_DATEMI|GQW_TOTAL|GQW_TOTDES|"

If GQW->(FieldPos('GQW_CONFCH')) > 0 .And. GQW->(FieldPos('GQW_USUCON')) > 0 .And. GQW->(FieldPos('GQW_MOTREJ')) > 0 
    cFields += "GQW_CONFCH|GQW_USUCON|GQW_MOTREJ|"
Endif

PrepareStruct(@oStruGQW, cFields)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} PrepareStruct(oStruct, cFields)
Remove os campos da estrutura que não estão presente na variável cFields
@author  Renan Ribeiro Brando
@since   22/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function PrepareStruct(oStruct, cFields)

Local aFldStr   := {}
Local nI        := 0
							
aFldStr := aClone(oStruct:GetFields())
			
	For nI := 1 to Len(aFldStr)
			
	    If ( !(aFldStr[nI,1] $ cFields) )
			oStruct:RemoveField(aFldStr[nI,1])
		EndIf
			
	Next nI

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VldActivate(oModel)
Faz validação para criar um periodo de fechamento
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function VldActivate(oModel)

if oModel:GetModel("G59MASTER"):GetOperation() == MODEL_OPERATION_DELETE 
    If G59->G59_STATUS == .T.
        FWAlertHelp(STR0042, STR0014) //"Erro" //"Não é possível excluir um período ja baixado."
        Return .F.
    EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldActivate(oModel)
Valida a ativação do modelo preenchendo as datas com os valores das fichas de remessa.
@author  Renan Ribeiro Brando
@since   01/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function Activate(oModel)
Local oModelG59  := oModel:GetModel("G59MASTER")
Local oModelGIC  := oModel:GetModel("GICDETAIL")
Local oModelG57  := oModel:GetModel("G57DETAIL")
Local oModelG99  := oModel:GetModel("G99DETAIL")
Local oModelGQL  := oModel:GetModel("GQLDETAIL")
Local oModelGQM  := oModel:GetModel("GQMDETAIL")
Local oModelGQW  := oModel:GetModel("GQWDETAIL")
Local oModelDGZG := oModel:GetModel("GZGDETAILD")
Local oModelEGZG := oModel:GetModel("GZGDETAILE")
Local aPeriod    := {}
Local aModels    := {}
Local cAgency    := ""
Local nCont      := 0
Local dIni       := DATE()
Local dFim       := DATE()
Local cAliasGIC  := GetNextAlias()
Local cAliasG57  := GetNextAlias()
Local cAliasG99  := GetNextAlias()
Local cAliasGZGD := GetNextAlias()
Local cAliasGZGE := GetNextAlias()
Local cAliasPos	 := GetNextAlias()
Local cAliasGQM	 := GetNextAlias()
Local cAliasReq  := GetNextAlias()
Local lAcert     := FwIsInCallStack("GA500Acert")
Local lAut       := Isblind()
Local aValores   := {}
Local cCodG6X    := ""
Local cCpoVenda  := ''
Local lGIC_DTFECH:= GIC->(FieldPos('GIC_DTFECH')) > 0
Local nOperacao  := oModel:GetModel("G59MASTER"):GetOperation()
If nOperacao == MODEL_OPERATION_INSERT .OR. nOperacao == MODEL_OPERATION_UPDATE
    if lAut .and. !lAcert
        cAgenPerg := 'AG8500'
    elseif lAut .and. lAcert
        cAgenPerg := 'AG1500'
    endif

    cAgency := cAgenPerg
    aPeriod := GTPFirstPeri(cAgency)

    oModelG59:SetValue("G59_AGENCI", cAgency) 

    If G59->(FieldPos('G59_STFINA')) > 0 .And. nOperacao == MODEL_OPERATION_INSERT
        oModelG59:SetValue("G59_STFINA", '0')
    EndIf 
    // Caso não seja um acerto as datas do fechamento devem ser da última ficha de remessa
    If !lAcert
        dIni :=  aPeriod[3]
        dFim :=  aPeriod[4]
        oModelG59:SetValue("G59_DATINI", dIni)
        oModelG59:SetValue("G59_DATFIM", dFim)
        oModelG59:SetValue("G59_NUMFCH", aPeriod[5])
        cCodG6X := aPeriod[5]
    Else
        DbSelectArea("G6X")
        G6X->(DbSetOrder(3)) //G6X_FILIAL + G6X_AGENCI + G6X_NUMFCH         
        If DbSeek(xFilial("G6X")+MV_PAR02+MV_PAR01)
            dIni := G6X->G6X_DTINI
            dFim := G6X->G6X_DTFIN
            oModelG59:SetValue("G59_DATINI", dIni)
            oModelG59:SetValue("G59_DATFIM", dFim)
            oModelG59:SetValue("G59_NUMFCH", G6X->G6X_NUMFCH)
            cCodG6X := G6X->G6X_NUMFCH
        EndIf

    EndIf

    aModels := {"GICDETAIL","G57DETAIL","G99DETAIL","GQLDETAIL","GQMDETAIL","GZGDETAILD","GZGDETAILE","GQWDETAIL"}
    For nCont := 1 To Len(aModels)
        oModel:GetModel(aModels[nCont]):SetNoInsertLine(.F.)
    Next nCont

    cCpoVenda := "%"
    cCpoVenda += "GIC.GIC_DTVEND,"+Iif(lGIC_DTFECH,'GIC.GIC_DTFECH,','')
    cCpoVenda += "%"

    // Faz a carga dos demonstrativos
    BeginSql Alias cAliasGIC  
        SELECT 
            GIC.GIC_CODIGO,
            GIC.GIC_BILHET, 
            GIC.GIC_TIPO,
            %Exp:cCpoVenda%
            GIC.GIC_TAR,
            GIC.GIC_TAX,
            GIC.GIC_PED,
            GIC.GIC_SGFACU,
            GIC.GIC_OUTTOT,
            GIC.GIC_VALTOT,
            GIC.GIC_VLACER,
            GIC.GIC_SERIE,
            GIC.GIC_SUBSER,
            GIC.GIC_NUMCOM,
            GIC.GIC_CONFER
        FROM 
            %Table:GIC% GIC
        WHERE 
            GIC.GIC_FILIAL = %xFilial:GIC%
            AND GIC.%NotDel%
            AND GIC.GIC_VENDRJ Not In ('BCA','IVP')
            AND NOT(GIC_STATUS = 'C' AND EXISTS(
       			SELECT 1 FROM %Table:GIC% GIC2 
						WHERE GIC2.GIC_FILIAL = %xFilial:GIC%
						AND GIC2.GIC_CODIGO = GIC.GIC_BILREF 
						AND GIC2.%NotDel%
						AND GIC2.GIC_VENDRJ In ('BCA','IVP')  
       		))
            AND GIC.GIC_AGENCI = %Exp:cAgency%
            AND ((%Exp:G421CpoVenda()% BETWEEN  %Exp:dIni% AND %Exp:dFim%
                    AND GIC.GIC_NUMFCH = '')
                    OR  GIC.GIC_NUMFCH = %Exp:cCodG6X%)       
    EndSql

    While ((cAliasGIC)->(!EOF()))
        If (!Empty(FwFldget('GIC_CODIGO')))   
            A500AddLine(oModelGIC)
        EndIf

        oModelGIC:LoadValue("GIC_CODIGO",	(cAliasGIC)->GIC_CODIGO)
        oModelGIC:LoadValue("GIC_BILHET",	(cAliasGIC)->GIC_BILHET)
        oModelGIC:LoadValue("GIC_TIPO"  ,	(cAliasGIC)->GIC_TIPO)
        oModelGIC:LoadValue("GIC_DTVEND",	StoD((cAliasGIC)->GIC_DTVEND))
        oModelGIC:LoadValue("GIC_TAR"   , 	(cAliasGIC)->GIC_TAR)
        oModelGIC:LoadValue("GIC_TAX"   ,	(cAliasGIC)->GIC_TAX)
        oModelGIC:LoadValue("GIC_PED"   ,	(cAliasGIC)->GIC_PED)
        oModelGIC:LoadValue("GIC_SGFACU",	(cAliasGIC)->GIC_SGFACU)
        oModelGIC:LoadValue("GIC_OUTTOT",	(cAliasGIC)->GIC_OUTTOT)
        oModelGIC:LoadValue("GIC_VALTOT",	(cAliasGIC)->GIC_VALTOT)
        oModelGIC:LoadValue("GIC_VLACER",	(cAliasGIC)->GIC_VLACER)
        oModelGIC:LoadValue("GIC_SERIE" ,	(cAliasGIC)->GIC_SERIE)
        oModelGIC:LoadValue("GIC_SUBSER",	(cAliasGIC)->GIC_SUBSER)
        oModelGIC:LoadValue("GIC_NUMCOM",	(cAliasGIC)->GIC_NUMCOM)
        oModelGIC:LoadValue("GIC_CONFER",	(cAliasGIC)->GIC_CONFER)
        If lGIC_DTFECH
            oModelGIC:LoadValue("GIC_DTFECH",	StoD((cAliasGIC)->GIC_DTFECH))
        EndIf 
        (cAliasGIC)->(DbSkip()) 
    End

    (cAliasGIC)->(DbCloseArea()) 


    BeginSql Alias cAliasG57
        
        SELECT 
            G57.G57_NUMMOV,
            G57.G57_SERIE,
            G57.G57_SUBSER,
            G57.G57_NUMCOM,
            G57.G57_CODIGO,
            G57.G57_TIPO,
            G57.G57_VALOR,
            G57.G57_VALACE,
            G57.G57_CONFER,
            G57.G57_DESCRI,
            G57.G57_EMISSA
        FROM 
            %Table:G57% G57
        WHERE 
            G57.G57_FILIAL = %xFilial:G57%
            AND G57.G57_AGENCI   = %Exp:cAgency%
            AND G57.G57_NUMFCH 	= %Exp:cCodG6X%
            AND G57.%NotDel%

    EndSql

    While ((cAliasG57)->(!EOF()))
        If (!Empty(FwFldget('G57_TIPO')))   
            A500AddLine(oModelG57)
        EndIf
        oModelG57:LoadValue("G57_NUMMOV", (cAliasG57)->G57_NUMMOV)
        oModelG57:LoadValue("G57_SERIE" , (cAliasG57)->G57_SERIE)
        oModelG57:LoadValue("G57_SUBSER", (cAliasG57)->G57_SUBSER)
        oModelG57:LoadValue("G57_NUMCOM", (cAliasG57)->G57_NUMCOM)
        oModelG57:LoadValue("G57_CODIGO", (cAliasG57)->G57_CODIGO)
        oModelG57:LoadValue("G57_TIPO"  , (cAliasG57)->G57_TIPO)
        oModelG57:LoadValue("G57_VALOR" , (cAliasG57)->G57_VALOR)
        oModelG57:LoadValue("G57_VALACE", (cAliasG57)->G57_VALACE)
        oModelG57:LoadValue("G57_CONFER", (cAliasG57)->G57_CONFER)
        oModelG57:LoadValue("G57_DESCRI", (cAliasG57)->G57_DESCRI)
        oModelG57:LoadValue("G57_EMISSA", STOD((cAliasG57)->G57_EMISSA))

        (cAliasG57)->(DbSkip()) 
    End

    (cAliasG57)->(DbCloseArea())
    
    If CHKFILE("G99") .AND. G99->(FIELDPOS( "G99_VALACE" )) > 0 .AND. G99->(FIELDPOS( "G99_CONFER" )) > 0
        BeginSql Alias cAliasG99
        
            SELECT  G99_CODIGO,
                    G99_SERIE,
                    G99_NUMDOC,
                    G99_DTEMIS,
                    G99_HREMIS,
                    G99_KMFRET,
                    G99_VALOR , 
                    G99_TIPCTE,
                    G99_STAENC,
                    G99_STATRA,
                    G99_CONFER,
                    G99_VALACE
            FROM %Table:G99% G99
            WHERE G99.G99_FILIAL = %xFilial:G99%
            AND (
                    (G99.G99_CODEMI = %Exp:cAgency% AND G99.G99_TOMADO IN ('0','1')) OR 
                    (G99.G99_CODREC = %Exp:cAgency% AND G99.G99_TOMADO IN ('3','1') AND G99_STAENC = '5')
                ) 
            AND (
                    (
                        G99.G99_DTEMIS BETWEEN  %Exp:dIni% AND %Exp:dFim%
                        AND G99.G99_NUMFCH = ''
                    )
                    OR  G99.G99_NUMFCH = %Exp:cCodG6X%
                )
            AND G99.G99_STATRA = '2'
            AND G99_TIPCTE != '2' 
            AND G99_COMPLM != 'I'
            AND G99.%NotDel%

        EndSql

        While ((cAliasG99)->(!EOF()))
            If (!Empty(FwFldget('G99_CODIGO')))   
                A500AddLine(oModelG99)
            EndIf
            oModelG99:LoadValue("G99_CODIGO", (cAliasG99)->G99_CODIGO      )
            oModelG99:LoadValue("G99_SERIE" , (cAliasG99)->G99_SERIE       )
            oModelG99:LoadValue("G99_NUMDOC", (cAliasG99)->G99_NUMDOC      )
            oModelG99:LoadValue("G99_HREMIS", (cAliasG99)->G99_HREMIS      )
            oModelG99:LoadValue("G99_KMFRET", (cAliasG99)->G99_KMFRET      )
            oModelG99:LoadValue("G99_VALOR" , (cAliasG99)->G99_VALOR       )
            oModelG99:LoadValue("G99_TIPCTE", (cAliasG99)->G99_TIPCTE      )
            oModelG99:LoadValue("G99_STAENC", (cAliasG99)->G99_STAENC      )
            oModelG99:LoadValue("G99_STATRA", (cAliasG99)->G99_STATRA      )
            oModelG99:LoadValue("G99_CONFER", (cAliasG99)->G99_CONFER      )
            oModelG99:LoadValue("G99_VALACE", (cAliasG99)->G99_VALACE      )
            oModelG99:LoadValue("G99_DTEMIS", STOD((cAliasG99)->G99_DTEMIS))

            (cAliasG99)->(DbSkip()) 
        End

        (cAliasG99)->(DbCloseArea())
    EndIf
    If CHKFILE("GQM") .AND. GQM->(FIELDPOS( "GQM_CONFER" )) > 0 .And. GQM->(FIELDPOS( "GQM_VLACER" )) > 0
        BeginSql Alias cAliasPOS

            SELECT GQL.GQL_DTMOVI,
                GQL.GQL_TPDDOC,
                GQL.GQL_NUMFCH,
                GQL.GQL_DTVEND,
                GQL.GQL_CODLAN,
                GQL.GQL_VLRTOT,
                GQL.GQL_FILIAL,
                GQL.GQL_CODAGE,
                GQL.GQL_CODIGO,
                GQL.GQL_CODADM,
                GQL.GQL_IDECNT,
                GQL.GQL_TPVEND
            FROM %Table:GQL% GQL
            WHERE GQL.GQL_FILIAL = %xFilial:GQL% 
                AND GQL.GQL_CODAGE = %Exp:cAgency%
                AND GQL.GQL_NUMFCH = %Exp:cCodG6X%
                AND GQL.%NotDel%

        EndSql

        While !(cAliasPos)->(Eof())

            If (!Empty(FwFldget('GQL_CODAGE')))
                oModelGQL:SetNoInsertLine(.F.)
                oModelGQL:AddLine()
            Endif

            oModelGQL:LoadValue('GQL_DTMOVI', STOD((cAliasPOS)->GQL_DTMOVI))
            oModelGQL:LoadValue('GQL_TPDDOC', (cAliasPOS)->GQL_TPDDOC)
            oModelGQL:LoadValue('GQL_DESDOC', POSICIONE("GYA",1,XFILIAL("GYA")+(cAliasPOS)->GQL_TPDDOC,"GYA_DESCRI"))
            oModelGQL:LoadValue('GQL_NUMFCH', (cAliasPOS)->GQL_NUMFCH)
            oModelGQL:LoadValue('GQL_CODAGE', (cAliasPOS)->GQL_CODAGE)
            oModelGQL:LoadValue('GQL_DESCAG', POSICIONE("GI6",1,XFILIAL("GI6")+(cAliasPOS)->GQL_CODAGE,"GI6_DESCRI"))
            oModelGQL:LoadValue('GQL_CODADM', (cAliasPOS)->GQL_CODADM)
            oModelGQL:LoadValue('GQL_DESCAD', POSICIONE("SAE",1,XFILIAL("SAE")+(cAliasPOS)->GQL_CODADM,"AE_DESC"))
            oModelGQL:LoadValue('GQL_IDECNT', (cAliasPOS)->GQL_IDECNT)
            oModelGQL:LoadValue('GQL_TPVEND', (cAliasPOS)->GQL_TPVEND)
            oModelGQL:LoadValue('GQL_CODIGO', (cAliasPOS)->GQL_CODIGO)
            oModelGQL:LoadValue('GQL_FILIAL', (cAliasPOS)->GQL_FILIAL)
            
                BeginSql Alias cAliasGQM

                    SELECT  GQM.GQM_CODIGO,
                            GQM.GQM_CODGQL,
                            GQM.GQM_NUMDOC,
                            GQM.GQM_CODNSU,
                            GQM.GQM_CODAUT,
                            GQM.GQM_DTVEND,
                            GQM.GQM_QNTPAR,
                            GQM.GQM_VALOR ,
                            GQM.GQM_FILIAL,
                            GQM.GQM_ESTAB ,
                            GQM.GQM_FILTIT,
                            GQM.GQM_MOTREJ,
                            GQM.GQM_CONFER,
                            GQM.GQM_DTCONF,
                            GQM.GQM_USUCON,
                            GQM.GQM_VLACER
                    FROM %Table:GQM% GQM
                    INNER JOIN %Table:GQL% GQL
                        ON GQL.GQL_FILIAL = %xFilial:GQL% 
                        AND GQL.GQL_CODAGE = %Exp:(cAliasPOS)->GQL_CODAGE%
                        AND GQL.GQL_NUMFCH = %Exp:(cAliasPOS)->GQL_NUMFCH%
                        AND GQL.GQL_CODIGO = %Exp:(cAliasPOS)->GQL_CODIGO%
                        AND GQL.%NotDel%
                    WHERE GQM.GQM_FILIAL = GQL.GQL_FILIAL
                        AND GQM.GQM_CODGQL = GQL.GQL_CODIGO
                        AND GQM.%NotDel%

                EndSql

                While !(cAliasGQM)->(Eof())

                    If (!Empty(FwFldget('GQM_CODGQL')))
                        oModelGQM:SetNoInsertLine(.F.)
                        oModelGQM:AddLine()
                    Endif

                    oModelGQM:LoadValue('GQM_CODIGO', (cAliasGQM)->GQM_CODIGO)
                    oModelGQM:LoadValue('GQM_CODGQL', (cAliasGQM)->GQM_CODGQL)
                    //oModelGQM:LoadValue('GQM_NUMDOC', (cAliasGQM)->GQM_NUMDOC)
                    oModelGQM:LoadValue('GQM_CODNSU', (cAliasGQM)->GQM_CODNSU)
                    oModelGQM:LoadValue('GQM_CODAUT', (cAliasGQM)->GQM_CODAUT)
                    oModelGQM:LoadValue('GQM_DTVEND', STOD((cAliasGQM)->GQM_DTVEND))
                    oModelGQM:LoadValue('GQM_QNTPAR', (cAliasGQM)->GQM_QNTPAR)
                    oModelGQM:LoadValue('GQM_VALOR ', (cAliasGQM)->GQM_VALOR )
                    oModelGQM:LoadValue('GQM_FILIAL', (cAliasGQM)->GQM_FILIAL)
                    oModelGQM:LoadValue('GQM_ESTAB ', (cAliasGQM)->GQM_ESTAB )
                    oModelGQM:LoadValue('GQM_FILTIT', (cAliasGQM)->GQM_FILTIT)
                    oModelGQM:LoadValue('GQM_MOTREJ', (cAliasGQM)->GQM_MOTREJ)
                    oModelGQM:LoadValue('GQM_CONFER', (cAliasGQM)->GQM_CONFER)
                    oModelGQM:LoadValue('GQM_DTCONF', STOD((cAliasGQM)->GQM_DTCONF))
                    oModelGQM:LoadValue('GQM_USUCON', (cAliasGQM)->GQM_USUCON)
                    oModelGQM:LoadValue('GQM_VLACER ', (cAliasGQM)->GQM_VLACER)
                    
                    (cAliasGQM)->(dbSkip())

                End

                (cAliasGQM)->(DbCloseArea())

            (cAliasPos)->(dbSkip())

        End

        (cAliasPos)->(DbCloseArea())
        oModelGQL:GoLine(1)
        oModelGQM:GoLine(1)
    EndIf
    
    If GZG->(FIELDPOS( "GZG_CONFER" )) > 0 .AND. GZG->(FIELDPOS( "GZG_DTCONF" )) > 0 .AND.;
      GZG->(FIELDPOS( "GZG_VLACER" )) > 0
        BeginSql Alias cAliasGZGD
            
            SELECT 
                GZG.GZG_FILIAL,
                GZG.GZG_SEQ   ,
                GZG.GZG_AGENCI,
                GZG.GZG_NUMFCH,
                GZG.GZG_COD   ,
                GZG.GZG_TIPO  ,
                GZG.GZG_DESCRI,
                GZG.GZG_VALOR ,
                GZG.GZG_CQVINC,
                GZG.GZG_CARGA ,
                GZG.GZG_CONFER,
                GZG.GZG_DTCONF,
                GZG.GZG_USUCON,
                GZG.GZG_FILTIT,
                GZG.GZG_PRETIT,
                GZG.GZG_NUMTIT,
                GZG.GZG_PARTIT,
                GZG.GZG_TIPTIT,
                GZG.GZG_MOTREJ,
                GZG.GZG_STATIT,
                GZG.GZG_VLACER
            FROM 
                %Table:GZG% GZG
            WHERE 
                GZG.GZG_FILIAL = %xFilial:GZG%
                AND GZG.GZG_AGENCI   = %Exp:cAgency%
                AND GZG.GZG_NUMFCH 	= %Exp:cCodG6X%
                AND GZG.GZG_TIPO 	= "2"
                //AND GZG.GZG_CARGA   = 'F' 
                AND GZG.%NotDel%

        EndSql

        While ((cAliasGZGD)->(!EOF()))
            If (!Empty(FwFldget('GZG_SEQ')))   
                A500AddLine(oModelDGZG)
            EndIf
            oModelDGZG:LoadValue("GZG_SEQ"   , (cAliasGZGD)->GZG_SEQ   )
            oModelDGZG:LoadValue("GZG_AGENCI", (cAliasGZGD)->GZG_AGENCI)
            oModelDGZG:LoadValue("GZG_COD"   , (cAliasGZGD)->GZG_COD   )
            oModelDGZG:LoadValue("GZG_TIPO"  , (cAliasGZGD)->GZG_TIPO  )
            oModelDGZG:LoadValue("GZG_DESCRI", (cAliasGZGD)->GZG_DESCRI)
            oModelDGZG:LoadValue("GZG_VALOR" , (cAliasGZGD)->GZG_VALOR )
            oModelDGZG:LoadValue("GZG_CQVINC", (cAliasGZGD)->GZG_CQVINC)
            oModelDGZG:LoadValue("GZG_CARGA" , IIF((cAliasGZGD)->GZG_CARGA == "T",.T.,.F.) )
            oModelDGZG:LoadValue("GZG_CONFER", (cAliasGZGD)->GZG_CONFER)
            oModelDGZG:LoadValue("GZG_DTCONF", STOD((cAliasGZGD)->GZG_DTCONF))
            oModelDGZG:LoadValue("GZG_USUCON", (cAliasGZGD)->GZG_USUCON)
            oModelDGZG:LoadValue("GZG_FILTIT", (cAliasGZGD)->GZG_FILTIT)
            oModelDGZG:LoadValue("GZG_PRETIT", (cAliasGZGD)->GZG_PRETIT)
            oModelDGZG:LoadValue("GZG_NUMTIT", (cAliasGZGD)->GZG_NUMTIT)
            oModelDGZG:LoadValue("GZG_PARTIT", (cAliasGZGD)->GZG_PARTIT)
            oModelDGZG:LoadValue("GZG_TIPTIT", (cAliasGZGD)->GZG_TIPTIT)
            oModelDGZG:LoadValue("GZG_MOTREJ", (cAliasGZGD)->GZG_MOTREJ)
            oModelDGZG:LoadValue("GZG_STATIT", (cAliasGZGD)->GZG_STATIT)
            oModelDGZG:LoadValue("GZG_VLACER", (cAliasGZGD)->GZG_VLACER)

            (cAliasGZGD)->(DbSkip()) 
        End

        (cAliasGZGD)->(DbCloseArea())

        BeginSql Alias cAliasGZGE
            
            SELECT 
                GZG.GZG_FILIAL,
                GZG.GZG_SEQ   ,
                GZG.GZG_AGENCI,
                GZG.GZG_NUMFCH,
                GZG.GZG_COD   ,
                GZG.GZG_TIPO  ,
                GZG.GZG_DESCRI,
                GZG.GZG_VALOR ,
                GZG.GZG_CQVINC,
                GZG.GZG_CARGA ,
                GZG.GZG_CONFER,
                GZG.GZG_DTCONF,
                GZG.GZG_USUCON,
                GZG.GZG_FILTIT,
                GZG.GZG_PRETIT,
                GZG.GZG_NUMTIT,
                GZG.GZG_PARTIT,
                GZG.GZG_TIPTIT,
                GZG.GZG_MOTREJ,
                GZG.GZG_STATIT,
                GZG.GZG_VLACER
            FROM 
                %Table:GZG% GZG
            WHERE 
                GZG.GZG_FILIAL = %xFilial:GZG%
                AND GZG.GZG_AGENCI   = %Exp:cAgency%
                AND GZG.GZG_NUMFCH 	= %Exp:cCodG6X%
                AND GZG.GZG_TIPO 	= "1"
                //AND GZG.GZG_CARGA   = 'F'
                AND GZG.%NotDel%

        EndSql

        While ((cAliasGZGE)->(!EOF()))
            If (!Empty(oModelEGZG:GetValue("GZG_SEQ")))   
                A500AddLine(oModelEGZG)
            EndIf
            oModelEGZG:LoadValue("GZG_SEQ"   , (cAliasGZGE)->GZG_SEQ   )
            oModelEGZG:LoadValue("GZG_AGENCI", (cAliasGZGE)->GZG_AGENCI)
            oModelEGZG:LoadValue("GZG_COD"   , (cAliasGZGE)->GZG_COD   )
            oModelEGZG:LoadValue("GZG_TIPO"  , (cAliasGZGE)->GZG_TIPO  )
            oModelEGZG:LoadValue("GZG_DESCRI", (cAliasGZGE)->GZG_DESCRI)
            oModelEGZG:LoadValue("GZG_VALOR" , (cAliasGZGE)->GZG_VALOR )
            oModelEGZG:LoadValue("GZG_CQVINC", (cAliasGZGE)->GZG_CQVINC)
            oModelEGZG:LoadValue("GZG_CARGA" , IIF((cAliasGZGE)->GZG_CARGA == "T",.T.,.F.) )
            oModelEGZG:LoadValue("GZG_CONFER", (cAliasGZGE)->GZG_CONFER)
            oModelEGZG:LoadValue("GZG_DTCONF", STOD((cAliasGZGE)->GZG_DTCONF))
            oModelEGZG:LoadValue("GZG_USUCON", (cAliasGZGE)->GZG_USUCON)
            oModelEGZG:LoadValue("GZG_FILTIT", (cAliasGZGE)->GZG_FILTIT)
            oModelEGZG:LoadValue("GZG_PRETIT", (cAliasGZGE)->GZG_PRETIT)
            oModelEGZG:LoadValue("GZG_NUMTIT", (cAliasGZGE)->GZG_NUMTIT)
            oModelEGZG:LoadValue("GZG_PARTIT", (cAliasGZGE)->GZG_PARTIT)
            oModelEGZG:LoadValue("GZG_TIPTIT", (cAliasGZGE)->GZG_TIPTIT)
            oModelEGZG:LoadValue("GZG_MOTREJ", (cAliasGZGE)->GZG_MOTREJ)
            oModelEGZG:LoadValue("GZG_STATIT", (cAliasGZGE)->GZG_STATIT)
            oModelEGZG:LoadValue("GZG_VLACER", (cAliasGZGE)->GZG_VLACER)

            (cAliasGZGE)->(DbSkip()) 
        End

        (cAliasGZGE)->(DbCloseArea())
    EndIf

    // Conferência de Requisição
    If CHKFILE("GQW") .AND. GQW->(FIELDPOS( "GQW_TOTAL" )) > 0 .AND.;
       GQW->(FIELDPOS( "GQW_CONFCH" )) > 0 .And. GQW->(FIELDPOS( "GQW_NUMFCH" )) > 0
        BeginSql Alias cAliasREQ
        SELECT 
            GQW.GQW_CODIGO,
            GQW.GQW_REQDES,
            GQW.GQW_CODCLI,
            GQW.GQW_CODLOJ,
            GQW.GQW_CODAGE,
            GQW.GQW_DATEMI,
            GQW.GQW_TOTAL ,
            GQW.GQW_STATUS,
            GQW.GQW_CONFER,
            GQW.GQW_CODLOT,
            GQW.GQW_CODORI,
            GQW.GQW_TOTDES,
            GQW.GQW_CONFCH,
            GQW.GQW_USUCON
        FROM 
            %Table:GQW% GQW
        WHERE
            GQW.GQW_FILIAL = %xFilial:GQW%
            AND GQW.GQW_CODAGE   = %Exp:cAgency%
            AND GQW.GQW_NUMFCH   = %Exp:cCodG6X%
            AND GQW.%NotDel%
        EndSql


        While ((cAliasREQ)->(!EOF()))
            If (!Empty(FwFldget('GQW_CODIGO')))   
                A500AddLine(oModelGQW)
            EndIf
            oModelGQW:LoadValue("GQW_CODIGO", (cAliasREQ)->GQW_CODIGO)
            oModelGQW:LoadValue("GQW_REQDES", (cAliasREQ)->GQW_REQDES)
            oModelGQW:LoadValue("GQW_CODCLI", (cAliasREQ)->GQW_CODCLI)
            oModelGQW:LoadValue("GQW_CODLOJ", (cAliasREQ)->GQW_CODLOJ)
            oModelGQW:LoadValue("GQW_NOMCLI", POSICIONE("SA1",1,XFILIAL("SA1")+(cAliasREQ)->GQW_CODCLI+(cAliasREQ)->GQW_CODLOJ,"A1_NOME"))
            oModelGQW:LoadValue("GQW_CODAGE", (cAliasREQ)->GQW_CODAGE)
            oModelGQW:LoadValue("GQW_DATEMI", STOD((cAliasREQ)->GQW_DATEMI))
            oModelGQW:LoadValue("GQW_TOTAL ", (cAliasREQ)->GQW_TOTAL )
            oModelGQW:LoadValue("GQW_STATUS", (cAliasREQ)->GQW_STATUS)
            oModelGQW:LoadValue("GQW_CONFER", (cAliasREQ)->GQW_CONFER)
            oModelGQW:LoadValue("GQW_CODLOT", (cAliasREQ)->GQW_CODLOT)
            oModelGQW:LoadValue("GQW_CODORI", (cAliasREQ)->GQW_CODORI)
            oModelGQW:LoadValue("GQW_TOTDES", (cAliasREQ)->GQW_TOTDES)
            oModelGQW:LoadValue("GQW_CONFCH", (cAliasREQ)->GQW_CONFCH)
            oModelGQW:LoadValue("GQW_USUCON", (cAliasREQ)->GQW_USUCON)

            (cAliasREQ)->(DbSkip()) 
        End

        (cAliasREQ)->(DbCloseArea()) 
    EndIf

    aModels := {"GICDETAIL","G57DETAIL","G99DETAIL","GQLDETAIL","GQMDETAIL","GZGDETAILD","GZGDETAILE","GQWDETAIL"}
    For nCont := 1 To Len(aModels)
        oModel:GetModel(aModels[nCont]):SetNoInsertLine(.T.)
    Next nCont

    If nOperacao == MODEL_OPERATION_INSERT
        FWMsgRun(,{|| GA500Confer(dIni, dFim, .T., oModel)}, STR0131, STR0132)  //"Aguarde enquanto os documentos estão sendo consultados..." //"Consultando documentos"        
    endif

    If lNewTot
        aValores:=  GetAdvFval("G6X",{'G6X_VLTODE','G6X_VLTOES','G6X_VLRLIQ'},xFilial("G6X")+cAgency+aPeriod[5],3)
        oModelG59:SetValue("G59_VLTODE", aValores[1])   //Tot.Depósito
        oModelG59:SetValue("G59_VLTOES", aValores[2])   //Tot. Estorno
        oModelG59:SetValue("G59_VLFICH", aValores[3])   //Valor Ficha
        oModelG59:SetValue("G59_VLDIFE", aValores[3] - oModelG59:GetValue("G59_TOTAL") )   //Dif.Ficha e Arrecadação
        oModelG59:SetValue("G59_VLRLIQ", aValores[3] - aValores[1] + aValores[2] )   //Dif.Ficha e Arrecadação
    EndIf        

EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GA500Acert()
Realiza o acerto do período.
@author  Renan Ribeiro Brando
@since   23/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GA500Acert()
	
If Pergunte("GTPA500", .T., STR0007) //"Acerto"
    DbSelectArea("G6X")
    G6X->(DbSetOrder(3)) //G6X_FILIAL + G6X_AGENCI + G6X_NUMFCH         
    If DbSeek(xFilial("G6X")+MV_PAR02+MV_PAR01)
        If VldUsrAgencia(MV_PAR02)
            If (aInvalid := VldPeriod(G6X->G6X_DTINI, G6X->G6X_DTFIN))[1]
                FWExecView(STR0096, "VIEWDEF.GTPA500", MODEL_OPERATION_INSERT, , , , , ) //"Acerto de Período"
            Else
                FWAlertHelp(STR0016, STR0098 + " " + DTOC(G6X->G6X_DTINI) + " " + STR0097 + " " + DTOC(G6X->G6X_DTFIN))  //" até " //"Intervalo de " //"Este período já foi cadastrado!"
            EndIf
        EndIf 
    EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GA500Abre()
Realiza o fechamento do período.
@author  Renan Ribeiro Brando
@since   23/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GA500Abre()

    FWMsgRun(,{|| GA500ProAbert()}, STR0023, STR0099)  //"Aguarde enquanto os documentos estão sendo conferidos..." //"Processando Fechamento"

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GA500Fech()
Realiza o fechamento do período.
@author  Renan Ribeiro Brando
@since   23/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GA500Fech()
    Local cBlock := cValToChar(G59->(Recno()))

    If ! LockByName(cBlock, .T., .F.)
        FWAlertWarning("Processamento já iniciado por outro usuário, função não pode ser executada!", "Atenção")
        Return .F. 
    EndIf

    FWMsgRun(,{|| GA500ProFech()}, STR0023, STR0099)  //"Aguarde enquanto os documentos estão sendo conferidos..." //"Processando Fechamento"

    UnlockByName(cBlock, .T., .F., .F.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GA500ProAbert()
Realiza a abertura do período da arrecadação
@author  Renan Ribeiro Brando
@since   23/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GA500ProAbert()
Local lRet      := .T.
Local aProc     := {}
Local nProc     := 0
Local lFalha    := .F.

    If G59->G59_STATUS

        If Existblock("GTP500VLD")
            lRet := ExecBlock("GTP500VLD",.F.,.F.)
            lRet := IIF(ValType(lRet) == "L",lRet,.T.)
        EndIf

        // Pede confirmação do ususário para a abertura
        If lRet .AND. (IsBlind() .or. MSGYESNO(STR0024, STR0018)) //"Atenção" //"Toda a apuração desse período será zerada e deverá ser processada novamente, deseja prosseguir?"
            
            If  GA500ConfFich("2")
                
                lRet := StartJob("GTPA421G",GetEnvServer(),.F.,.T.,cEmpAnt,cFilAnt,G59->G59_AGENCI, G59->G59_NUMFCH, G59->G59_CODIGO)                              
            
            Else
                FwAlertError(STR0041, STR0014) //"Erro" //"Ficha de remessa não está entregue."
            EndIf        

            For nProc:=1 To Len(aProc)
                If !lRet .And. aProc[nProc][1] == 1
                    Loop
                EndIf 
                If aProc[nProc][1] == 2
                    lFalha := .T.
                EndIf 
                //Posiciona no registro GZG
                GZG->(DbGoTo(aProc[nProc][2]))
                GTPA500C(aProc[nProc][1],aProc[nProc][3])    
            Next nProc 

            If G59->(FieldPos('G59_STFINA')) > 0
                RECLOCK('G59',.F.)
                    G59->G59_STFINA := Iif(lFalha,'2','0')
                G59->(MSUNLOCK())
            EndIf 

        EndIf
    Else
        MSGALERT(STR0037, STR0168) // "Processo não permitido ", "Status atual não permite a reabertura da arrecadação"
    EndIf

    If !lRet 
        FWAlertWarning(STR0136, STR0134) // "Houve inconsistência(s) no(s) título(s). Consulte o título para maiores informações" 'Consulta Titulo'
    EndIf 

    aSize(aProc,0)
    aProc := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GA500ProFech()
Realiza a conferência dos documentos na arrecadação
@author  Renan Ribeiro Brando
@since   23/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GA500ProFech()
Local aRes      := {}
Local lRet      := .T.

    If !G59->G59_STATUS
        lRet := (aRes := GA500Confer())[1]
        If lRet

            Begin Transaction
            
            If GA500ConfFich("1")
                RECLOCK('G59',.F.)
                    G59->G59_STATUS := .T.
                G59->(MSUNLOCK())

                FWMsgRun(,{|| GA500RunRMD()}, STR0101, STR0100) //"Aguarde enquanto o sistema verifica e gera os RMD dessa arrecadação..."      //"Processando RMD"
                
                If G59->(FieldPos('G59_STAPRO')) > 0 
                    lRet := G500OpTit('3') // gera os titulos financeiros das despesas e receitas                    
                Else

                    If !lRet     
                        RECLOCK('G59',.F.)
                            G59->G59_STATUS := .F.
                        G59->(MSUNLOCK())

                        G6X->(DbSetOrder(3)) //G6X_FILIAL + G6X_AGENCI + G6X_NUMFCH         
                        If G6X->(DbSeek(xFilial("G6X")+G59->G59_AGENCI+G59->G59_NUMFCH))
                            RECLOCK('G6X',.F.)
                                G6X->G6X_STATUS := '2'
                            G6X->(MSUNLOCK())
                        Endif

                    Endif                 

                Endif
               
            Else
                lRet := .F.
                FwAlertError(STR0040, STR0014) //"Erro" //"Houve erro na conferência da ficha de remessa."
            EndIf
            
            If !lRet 
                DisarmTransaction()
            EndIf                 
            End Transaction

        Else
            if !IsBlind()
                MostraErro()
            endif
        EndIf

        SetStatusArrec(lRet)

        If lRet             
            FwAlertSuccess(STR0038, STR0037) //"Sucesso" //"Ficha de remessa conferida com sucesso."                                    
        EndIf

    Else
        MSGALERT(STR0167, STR0169) // "Processo não permitido ", "Status atual não permite o fechamento da arrecadação"
    EndIf
    aDadosProc := {}
    aSize(aRes,0)
    aRes := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDate(oModel)
Valida data de fechamento com data inical
@author  Renan Ribeiro Brando
@since   23/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function VldDate(oModel)

Local dDtIni := oModel:GetValue("G59_DATINI")
Local dDtFim := oModel:GetValue("G59_DATFIM")

    If dDtFim < dDtIni
        Return .F.
    EndIf

Return .T.


//------------------------------------------------------------------------------
/*/{Protheus.doc} A500AddLine(oModel)
Função para adicionar linha com status bloqueado

@author SIGAGTP | Renan Ribeiro Brando
@since 27/11/2017
@version 
/*/
//------------------------------------------------------------------------------
Static Function A500AddLine(oModel,lBloq)

Local lRet := .F.

Default lBloq := .T.

oModel:SetNoInsertLine(.F.)
lRet := oModel:AddLine()
oModel:SetNoInsertLine(lBloq)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPeriod(dIni, dFim)
Pega a próxima data disponível para o inicio do período
@author  Renan Ribeiro Brando
@since   23/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function VldPeriod(dIni, dFim)

Local cAliasTemp := GetNextAlias()

	BeginSql Alias cAliasTemp
        SELECT
            G59.G59_CODIGO, G59.G59_DATINI,
            G59.G59_DATFIM, G59.G59_STATUS
        FROM
            %Table:G59% G59
        WHERE
            G59.G59_FILIAL = %xFilial:G59%
            AND G59.%NotDel%
            ORDER BY G59.G59_DATINI 
	EndSql

    // Verifica registro por registro se a data de intervalo corresponde a um período utilizado
    While ((cAliasTemp)->(!EOF()))
        If (dIni >= STOD((cAliasTemp)->G59_DATINI)  .AND. dIni <= STOD((cAliasTemp)->G59_DATFIM)) .OR. ;
        (dFim >= STOD((cAliasTemp)->G59_DATINI)  .AND. dFim <= STOD((cAliasTemp)->G59_DATFIM))
            Return ACLONE({.F., STOD((cAliasTemp)->G59_DATINI), STOD((cAliasTemp)->G59_DATFIM)})
        End
        (cAliasTemp)->(DbSkip()) 
    End

    (cAliasTemp)->(DbCloseArea()) 

Return ACLONE({.T., dIni, dFim})  


//-------------------------------------------------------------------
/*/{Protheus.doc} GA500Confer(dBegin, dEnd,lInclui,oModel)
Realiza a conferência de documentos que foram verificados nos demonstrativos
@author  Renan Ribeiro Brando   
@since   24/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GA500Confer(dBegin, dEnd,lInclui,oModel)

Local cAliasTkt := GetNextAlias()
Local cAliasTax := GetNextAlias()
Local cAliasCte := GetNextAlias()
Local cAliasPos := GetNextAlias()
Local cAliasRec := GetNextAlias()
Local cAliasDes := GetNextAlias()
Local cAliasReq := GetNextAlias()
Local aTickets := {}
Local aTaxes   := {}
Local aConheci := {}
Local aPOS     := {}
Local aRec     := {}
Local aDes     := {}
Local aReq     := {}
Local nRecBil  := 0
Local nDesBil  := 0
Local nRecTax  := 0
Local nDesTax  := 0
Local nRecCTE  := 0
Local nRecPOS  := 0
Local nDesPOS  := 0
Local nRecREC  := 0
Local nDesREC  := 0
Local nRecDES  := 0
Local nDesDES  := 0
Local nRecREQ  := 0
Local cNumFch  := G59->G59_NUMFCH
Local cAgenci  := G59->G59_AGENCI
Local dIni 	   := G59->G59_DATINI
Local dFim 	   := G59->G59_DATFIM
Local oModelG59  := Nil
Local lRet      := .T.
Private lAutoErrNoFile := .F.

DEFAULT lInclui := .F.

    IF lInclui        
        oModelG59  := oModel:GetModel("G59MASTER")
        cNumFch    := oModelG59:GetValue("G59_NUMFCH")
        cAgenci    := oModelG59:GetValue("G59_AGENCI")
        dIni 	   := oModelG59:GetValue("G59_DATINI")
        dFim 	   := oModelG59:GetValue("G59_DATFIM")
        lAutoErrNoFile := .T.
    ENDIF

    // Conferência de bilhetes
    BeginSql Alias cAliasTkt
        SELECT 
            GIC.GIC_CODIGO,
            GIC.GIC_VALTOT,
            GIC.GIC_VLACER,
            GIC.GIC_CONFER    
        FROM 
	        %Table:GIC% GIC 
        WHERE
            GIC.GIC_FILIAL = %xFilial:GIC%
            AND GIC.GIC_AGENCI = %Exp:cAgenci%
            AND GIC.%NotDel% 
            AND GIC.GIC_VENDRJ Not In ('BCA','IVP')
            AND (GIC.GIC_NUMFCH = %Exp:cNumFch%
                 OR (%Exp:G421CpoVenda()% BETWEEN %Exp:dIni% AND %Exp:dFim% 
                 AND GIC.GIC_NUMFCH = ''))
            AND GIC.GIC_STATUS NOT IN ('C','D')
            AND NOT (GIC.GIC_TIPO = 'P' AND GIC_STATUS = 'V') 
	EndSql

    // Se não achar nenhuma informação de bilhetes o usuário deve ser avisado
    If ((cAliasTkt)->(BOF()))
        AutoGrLog(STR0029) //"Não existem bilhetes para apuração no período."
        lRet := .F.
    EndIf

    // Verifica registo a registro se o documento foi conferido para bilhetes 
    While ((cAliasTkt)->(!EOF()))
        // Se for conferido gera receita
        If (cAliasTkt)->GIC_CONFER <> "1"
            // Se houver valor de acerto deverá ser tratado como receita ou despesa
			If (cAliasTkt)->GIC_CONFER == "2"            
	            If (cAliasTkt)->GIC_VLACER <> 0
    	            // Se o valor de acerto for maior que o original, a diferença deve entrar como receita
       	            If (cAliasTkt)->GIC_VLACER >= (cAliasTkt)->GIC_VALTOT
           	         nRecBil += (cAliasTkt)->GIC_VLACER 
              	  // Se o valor de acerto for menor que o original, a diferença deve entrar como despesa
	                ElseIf (cAliasTkt)->GIC_VLACER <= (cAliasTkt)->GIC_VALTOT
    	                nRecBil += (cAliasTkt)->GIC_VALTOT
       	                nDesBil += (cAliasTkt)->GIC_VALTOT - (cAliasTkt)->GIC_VLACER 
           	        Else
              	        nRecBil += (cAliasTkt)->GIC_VALTOT
	                EndIf
    	        Else
       	            nRecBil += (cAliasTkt)->GIC_VALTOT
           	    EndIf
            Endif
        // Caso contrário gera log de bilhete não conferido
        Else
            AutoGrLog(STR0030 + " " + (cAliasTkt)->GIC_CODIGO + " " + STR0031) //"não conferido." //"Bilhete"
            lRet := .F.
            AADD(aTickets, (cAliasTkt)->GIC_CODIGO)
        EndIf
        (cAliasTkt)->(DbSkip()) 
    End
    (cAliasTkt)->(DbCloseArea()) 

    // Conferência de taxas buscando dentro dos demonstrativos taxa a taxa do período
    BeginSql Alias cAliasTax
        SELECT 
            G57.G57_CODIGO,
            G57.G57_VALOR, 
            G57.G57_VALACE,
            G57.G57_CONFER
        FROM 
            %Table:G57% G57 
        WHERE
            G57.G57_FILIAL = %xFilial:G57%
            AND G57.%NotDel% 
            AND G57.G57_AGENCI = %Exp:cAgenci%
            AND G57.G57_NUMFCH = %Exp:cNumFch% 
            
	EndSql


    // Se não achar nenhuma informação de taxas o usuário deve ser avisado
    If ((cAliasTax)->(BOF()))
        AutoGrLog(STR0032) //"Não existem taxas para apuração no período"
        lRet := .F.
    EndIf

    // Verifica registo a registro se o documento foi conferido para bilhetes 
    While ((cAliasTax)->(!EOF()))
        // Caso for conferido gera despesa
        If (cAliasTax)->G57_CONFER <> "1"
            If (cAliasTax)->G57_CONFER == "2"
                // Se houver acerto deve-se considear
                If (cAliasTax)->G57_VALACE <> 0
                    If (cAliasTax)->G57_VALACE >= (cAliasTax)->G57_VALOR
                        nRecTax += (cAliasTax)->G57_VALACE
                    ElseIf (cAliasTax)->G57_VALACE <= (cAliasTax)->G57_VALOR
                        nRecTax += (cAliasTax)->G57_VALOR
                        nDesTax += (cAliasTax)->G57_VALOR - (cAliasTax)->G57_VALACE
                    Else
                        nRecTax += (cAliasTax)->G57_VALOR
                    EndIf
                Else
                    nRecTax += (cAliasTax)->G57_VALOR
                EndIf
            EndIf
        // Caso contrário gera log de taxa não conferida
        Else
            AutoGrLog(STR0033 + " " + (cAliasTax)->G57_CODIGO + " " + STR0034) //"não conferida." //"Taxa"
            lRet := .F.
            AADD(aTaxes, (cAliasTax)->G57_CODIGO)
        EndIf
        (cAliasTax)->(DbSkip()) 
    End

    (cAliasTax)->(DbCloseArea()) 

    // Conferência de conhecimentos
    If CHKFILE("G99") .AND. G99->(FIELDPOS( "G99_VALACE" )) > 0 .AND. G99->(FIELDPOS( "G99_CONFER" )) > 0
        BeginSql Alias cAliasCte
        SELECT 
            G99.G99_CODIGO,
            G99.G99_VALOR, 
            G99.G99_VALACE,
            G99.G99_CONFER
        FROM 
            %Table:G99% G99 
        WHERE
            G99.G99_FILIAL = %xFilial:G99%
            AND G99.%NotDel% 
            AND (
                    (G99.G99_CODEMI = %Exp:cAgenci% AND G99.G99_TOMADO IN ('0','1')) OR 
                    (G99.G99_CODREC = %Exp:cAgenci% AND G99.G99_TOMADO IN ('3','1') AND G99_STAENC = '5')
                )
            AND G99.G99_NUMFCH = %Exp:cNumFch% 
            
        EndSql

        // Verifica registo a registro se o documento foi conferido para bilhetes 
        While ((cAliasCte)->(!EOF()))
        // Caso for conferido gera despesa
        If (cAliasCte)->G99_CONFER <> "1"
            // Se houver acerto deve-se considear
            If (cAliasCte)->G99_CONFER == "2"
                If (cAliasCte)->G99_VALACE <> 0
                    If (cAliasCte)->G99_VALACE >= (cAliasCte)->G99_VALOR
                        nRecCTE += (cAliasCte)->G99_VALACE
                    ElseIf (cAliasCte)->G99_VALACE <= (cAliasCte)->G99_VALOR
                        nRecCTE += (cAliasCte)->G99_VALOR - (cAliasCte)->G99_VALACE
                    Else
                        nRecCTE += (cAliasCte)->G99_VALOR
                    EndIf
                Else
                    nRecCTE += (cAliasCte)->G99_VALOR
                EndIf
            EndIf
        // Caso contrário gera log de taxa não conferida
        Else
            AutoGrLog(STR0105 + (cAliasCte)->G99_CODIGO + " " + STR0104) //"não conferido" //"Conhecimento "
            AADD(aConheci, (cAliasCte)->G99_CODIGO)
        EndIf
        (cAliasCte)->(DbSkip()) 
        End

        (cAliasCte)->(DbCloseArea()) 
    EndIf

    // Conferência de POS
    If CHKFILE("GQM") .AND. GQM->(FIELDPOS( "GQM_VALOR" )) > 0 .AND.;
     GQM->(FIELDPOS( "GQM_CONFER" )) > 0 .And. GQM->(FIELDPOS( "GQM_VLACER")) > 0
        BeginSql Alias cAliasPos
        SELECT 
            GQM.GQM_CODIGO,
            GQM.GQM_VALOR, 
            GQM.GQM_CONFER, 
            GQM.GQM_VLACER
        FROM 
            %Table:GQM% GQM 
        INNER JOIN %Table:GQL% GQL 
            ON GQL.GQL_FILIAL = GQM.GQM_FILIAL
            AND GQL.GQL_CODIGO = GQM.GQM_CODGQL
            AND GQL.GQL_NUMFCH = %Exp:cNumFch%
            AND GQL.GQL_CODAGE = %Exp:cAgenci%
            AND GQL.%NotDel%
        WHERE
            GQM.GQM_FILIAL = %xFilial:GQM%
            AND GQM.%NotDel% 
            
        EndSql

        // Verifica registo a registro se o documento foi conferido para bilhetes 
        While ((cAliasPos)->(!EOF()))
        // Caso for conferido gera despesa
        If (cAliasPos)->GQM_CONFER <> "1"
            // Se houver acerto deve-se considear
            If (cAliasPos)->GQM_CONFER == "2"
	            If (cAliasPos)->GQM_VLACER <> 0
    	            // Se o valor de acerto for maior que o original, a diferença deve entrar como receita
       	            If (cAliasPos)->GQM_VLACER >= (cAliasPos)->GQM_VALOR
           	         nRecPOS += (cAliasPos)->GQM_VLACER 
              	  // Se o valor de acerto for menor que o original, a diferença deve entrar como despesa
	                ElseIf (cAliasPos)->GQM_VLACER <= (cAliasPos)->GQM_VALOR
    	                nRecPOS += (cAliasPos)->GQM_VALOR
       	                nDesPOS += (cAliasPos)->GQM_VALOR - (cAliasPos)->GQM_VLACER 
           	        Else
              	        nRecPOS += (cAliasPos)->GQM_VALOR
	                EndIf
    	        Else
       	            nRecPOS += (cAliasPOS)->GQM_VALOR
           	    EndIf
            Endif

        // Caso contrário gera log de taxa não conferida
        Else
            AutoGrLog(STR0108 + (cAliasPos)->GQM_CODIGO + " " + STR0104) //"POS " //"não conferido"
            AADD(aPos, (cAliasPos)->GQM_CODIGO)
        EndIf
        (cAliasPos)->(DbSkip()) 
        End

        (cAliasPos)->(DbCloseArea()) 
    EndIf

    // Conferência de Receita
    If CHKFILE("GZG") .AND. GZG->(FIELDPOS( "GZG_VALOR" )) > 0 .AND.;
     GZG->(FIELDPOS( "GZG_CONFER" )) > 0 .AND. GZG->(FIELDPOS( "GZG_VLACER" )) > 0
        BeginSql Alias cAliasREC
        SELECT 
            GZG.GZG_SEQ,
            GZG.GZG_VALOR, 
            GZG.GZG_VLACER,
            GZG.GZG_CONFER
        FROM 
            %Table:GZG% GZG
        WHERE
            GZG.GZG_FILIAL = %xFilial:GZG%
            AND GZG.GZG_AGENCI   = %Exp:cAgenci%
            AND GZG.GZG_NUMFCH 	= %Exp:cNumFch%
            AND GZG.GZG_TIPO 	= "1"
            AND GZG.%NotDel%
        EndSql

        // Verifica registo a registro se o documento foi conferido para bilhetes 
        While ((cAliasREC)->(!EOF()))
        // Caso for conferido gera despesa
        If (cAliasREC)->GZG_CONFER <> "1"
            // Se houver acerto deve-se considear
            If (cAliasREC)->GZG_CONFER == "2"
	            If (cAliasREC)->GZG_VLACER <> 0
    	            // Se o valor de acerto for maior que o original, a diferença deve entrar como receita
       	            If (cAliasREC)->GZG_VLACER >= (cAliasREC)->GZG_VALOR
           	         nRecREC += (cAliasREC)->GZG_VLACER 
              	  // Se o valor de acerto for menor que o original, a diferença deve entrar como despesa
	                ElseIf (cAliasREC)->GZG_VLACER <= (cAliasREC)->GZG_VALOR
    	                nRecREC += (cAliasREC)->GZG_VALOR
       	                nDesREC += (cAliasREC)->GZG_VALOR - (cAliasREC)->GZG_VLACER 
           	        Else
              	        nRecREC += (cAliasREC)->GZG_VALOR
	                EndIf
    	        Else
       	            nRecREC += (cAliasREC)->GZG_VALOR
           	    EndIf
            EndIf
        // Caso contrário gera log de taxa não conferida
        Else
            AutoGrLog(STR0111 + (cAliasREC)->GZG_SEQ + " " + STR0104) //"não conferido" //"Receita "
            AADD(aRec, (cAliasREC)->GZG_SEQ)
        EndIf
        (cAliasREC)->(DbSkip()) 
        End
        (cAliasREC)->(DbCloseArea()) 
    EndIf

    // Conferência de Despesa
    If CHKFILE("GZG") .AND. GZG->(FIELDPOS( "GZG_VALOR" )) > 0 .AND.;
      GZG->(FIELDPOS( "GZG_CONFER" )) > 0 .AND. GZG->(FIELDPOS( "GZG_VLACER" )) > 0
        BeginSql Alias cAliasDES
        SELECT 
            GZG.GZG_SEQ,
            GZG.GZG_VALOR, 
            GZG.GZG_VLACER,
            GZG.GZG_CONFER
        FROM 
            %Table:GZG% GZG
        WHERE
            GZG.GZG_FILIAL = %xFilial:GZG%
            AND GZG.GZG_AGENCI   = %Exp:cAgenci%
            AND GZG.GZG_NUMFCH 	= %Exp:cNumFch%
            AND GZG.GZG_TIPO 	= "2"
            AND GZG.%NotDel%
        EndSql

        // Verifica registo a registro se o documento foi conferido para bilhetes 
        While ((cAliasDES)->(!EOF()))
        // Caso for conferido gera despesa
        If (cAliasDES)->GZG_CONFER <> "1"
            // Se houver acerto deve-se considear
            If (cAliasDES)->GZG_CONFER == "2"
	            If (cAliasDES)->GZG_VLACER <> 0
    	            // Se o valor de acerto for maior que o original, a diferença deve entrar como receita
       	            If (cAliasDES)->GZG_VLACER >= (cAliasDES)->GZG_VALOR
           	         nRecDES += (cAliasDES)->GZG_VLACER 
              	  // Se o valor de acerto for menor que o original, a diferença deve entrar como despesa
	                ElseIf (cAliasDES)->GZG_VLACER <= (cAliasDES)->GZG_VALOR
    	                nRecDES += (cAliasDES)->GZG_VALOR
       	                nDesDES += (cAliasDES)->GZG_VALOR - (cAliasDES)->GZG_VLACER 
           	        Else
              	        nRecDES += (cAliasDES)->GZG_VALOR
	                EndIf
    	        Else
       	            nRecDES += (cAliasDES)->GZG_VALOR
           	    EndIf
            Endif
        // Caso contrário gera log de taxa não conferida
        Else
            AutoGrLog(STR0114 + (cAliasDES)->GZG_SEQ + " " + STR0104) //"não conferido" //"Despesa "
            AADD(aDes, (cAliasDES)->GZG_SEQ)
        EndIf
        (cAliasDES)->(DbSkip()) 
        End

        (cAliasDES)->(DbCloseArea()) 
    EndIf

    // Conferência de Requisição
    If CHKFILE("GQW") .AND. GQW->(FIELDPOS( "GQW_TOTAL" )) > 0 .AND.;
     GQW->(FIELDPOS( "GQW_CONFCH" )) > 0 .AND. GQW->(FIELDPOS( "GQW_NUMFCH" )) > 0
        BeginSql Alias cAliasREQ
        SELECT 
            GQW.GQW_CODIGO,
            GQW.GQW_TOTAL, 
            GQW.GQW_CONFCH
        FROM 
            %Table:GQW% GQW
        WHERE
            GQW.GQW_FILIAL = %xFilial:GQW%
            AND GQW.GQW_CODAGE   = %Exp:cAgenci%
            AND GQW.GQW_NUMFCH  = %Exp:cNumFch%
            AND GQW.%NotDel%
        EndSql

        // Verifica registo a registro se o documento foi conferido para bilhetes 
        While ((cAliasREQ)->(!EOF()))
        // Caso for conferido gera despesa
        If (cAliasREQ)->GQW_CONFCH <> "1"
            // Se houver acerto deve-se considear
            If (cAliasREQ)->GQW_CONFCH == "2"
                nRecREQ += (cAliasREQ)->GQW_TOTAL
            EndIf
        // Caso contrário gera log de taxa não conferida
        Else
            AutoGrLog(STR0117 + (cAliasREQ)->GQW_CODIGO + " " + STR0104) //"não conferido" //"Requisição "
            AADD(aReq, (cAliasREQ)->GQW_CODIGO)
        EndIf
        (cAliasREQ)->(DbSkip()) 
        End

        (cAliasREQ)->(DbCloseArea()) 
    EndIf

    IF !lInclui        // Grava os valores de receita e despesa

        G59->(RECLOCK('G59',.F.))
        G59->G59_RECBIL := nRecBil
        G59->G59_DESBIL := nDesBil
        G59->G59_RECTAX := nRecTax
        G59->G59_DESTAX := nDesTax
        If CHKFILE("G99") .AND. G99->(FIELDPOS( "G99_VALACE" )) > 0 .AND. G99->(FIELDPOS( "G99_CONFER" )) > 0
            G59->G59_VLRCTE := nRecCTE
        EndIf
        If CHKFILE("GQM") .AND. G59->(FIELDPOS( "G59_VLPOS" )) > 0 .AND. GQM->(FIELDPOS( "GQM_CONFER" )) > 0
            G59->G59_VLPOS := nRecPOS - nDesPOS
        EndIf
        If CHKFILE("GZG") .AND. G59->(FIELDPOS( "G59_VLRREC" )) > 0 .AND. GZG->(FIELDPOS( "GZG_CONFER" )) > 0
            G59->G59_VLRREC := nRecREC - nDesREC
        EndIf
        If CHKFILE("GZG") .AND. G59->(FIELDPOS( "G59_VLRDES" )) > 0 .AND. GZG->(FIELDPOS( "GZG_CONFER" )) > 0
            G59->G59_VLRDES := nRecDES - nDesDES
        EndIf
        If CHKFILE("GQW") .AND. G59->(FIELDPOS( "G59_VLREQ" )) > 0 .AND. GQW->(FIELDPOS( "GQW_CONFCH" )) > 0
            G59->G59_VLREQ := nRecREQ
        EndIf
        
        G59->G59_TOTAL := (nRecBil-nDesBil) + (nRecTax-nDesTax) + nRecCTE + nRecPOS + nRecREC - nRecDES + nRecREQ
        G59->(MSUNLOCK())

        cTipoAgenc := POSICIONE("GI6",1,G59->G59_FILIAL + G59->G59_AGENCI,"GI6_TITPRO")
        If cTipoAgenc == "2" 
            StartJob("GTPA026C",GetEnvServer(),.F.,.T.,cEmpAnt,cFilAnt,G59->G59_AGENCI, G59->G59_NUMFCH)	
        EndIf

        If (!EMPTY(aTickets) .OR. !EMPTY(aTaxes) .OR. !EMPTY(aConheci);
            .OR. !EMPTY(aPOS) .OR. !EMPTY(aREC) .OR. !EMPTY(aDES);
            .OR. !EMPTY(aREQ))
            Return {.F., aTickets, aTaxes, aConheci,aPOS,aREC,aDES,aREQ}
        EndIf

    ELSE 
        oModelG59:SetValue("G59_DESCAG", GetAdvFVal("GI6","GI6_DESCRI",xFilial("GI6")+cAgenci,1,"")) 
        oModelG59:SetValue("G59_RECBIL", nRecBil)
        oModelG59:SetValue("G59_DESBIL", nDesBil)
        oModelG59:SetValue("G59_RECTAX", nRecTax)
        oModelG59:SetValue("G59_DESTAX", nDesTax)
        oModelG59:SetValue("G59_VLRCTE", nRecCTE)
        oModelG59:SetValue("G59_VLREQ",  nRecREQ)
        oModelG59:SetValue("G59_VLPOS",  nRecPOS - nDesPOS)
        oModelG59:SetValue("G59_VLRREC", nRecREC - nDesREC)
        oModelG59:SetValue("G59_VLRDES", nRecDES - nDesDES)
        oModelG59:SetValue("G59_TOTAL", (nRecBil-nDesBil) + (nRecTax-nDesTax) + nRecCTE + nRecPOS + nRecREC - nRecDES + nRecREQ)
        
    ENDIF

Return {lRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} PosValid(oModel)
Pos validação do modelo
@author  Renan Ribeiro Brando
@since   10/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function PosValid(oModel)

if oModel:GetOperation() == 3 
    
    // Validação de chave duplicada
    if !ExistChav("G59", oModel:GetValue("G59MASTER", "G59_CODIGO")) 
        
        if !oModel:SetValue("G59MASTER", GTPXUnq( "G59", 1, "G59_CODIGO" ))
        
            FWAlertHelp(STR0120, STR0119)  //"Altere para um numero posterior." //"O código de arrecadacao ja existe"
            Return .F.
        
        EndIf
        
    EndIf
    
    //Caso mais de um usuáo esteja com a tela aberta para a mesma agencia, se a primeira confirmar os demais n conseguir.
    if ExistArr( oModel:GetValue("G59MASTER", "G59_AGENCI"), oModel:GetValue("G59MASTER", "G59_DATINI"), oModel:GetValue("G59MASTER", "G59_DATFIM") )
    
        FWAlertHelp(STR0016, STR0098 + " " + DTOC(oModel:GetValue("G59MASTER", "G59_DATINI")) + " " + STR0097 + " " + DTOC(oModel:GetValue("G59MASTER", "G59_DATFIM")))  //" até " //"Este período já foi cadastrado!" //"Intervalo de "
        
        Return .F.
    EndIf

EndIf
    
Return .T. 
//-------------------------------------------------------------------
/*/{Protheus.doc} GA500ConfFich(cOperation)
Muda o status da ficha de acordo com abertura ou fechamento do período
@author  Renan Ribeiro Brando   
@since   08/11/2017 
@version P12
/*/
//-------------------------------------------------------------------
Static Function GA500ConfFich(cOperation)

    Local oModel := FWLoadModel("GTPA421")
    Local oModelG6X := oModel:GetModel("G6XMASTER")
    Local lRet := .F.

    DbSelectArea("G6X")
    G6X->(DbSetOrder(3)) //G6X_FILIAL + G6X_AGENCI + G6X_NUMFCH         
    
    If DbSeek(xFilial("G6X")+G59->G59_AGENCI+G59->G59_NUMFCH)

        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()  

        If cOperation == "1"
            // Se a ficha foi entregue
            If oModelG6X:GetValue("G6X_STATUS") == '2'
                oModelG6X:LoadValue("G6X_STATUS", "3") // Ficha Conferida
            Else 
                Return .F.
            EndIf
        ElseIf cOperation == "2" 
            If oModelG6X:GetValue("G6X_STATUS") == '3'
                oModelG6X:LoadValue("G6X_STATUS", "2") // Ficha Entregue
            Else 
                Return .F.
            EndIf
        EndIf

        If (lRet := oModel:VldData())
            lRet := oModel:CommitData()
        EndIf

        oModel:Deactivate()  
        oModel:Destroy()

    EndIf

    FreeObj(oModelG6X)
    FreeObj(oModel)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GA500Commit(oModel)
Função responsável pelo commit do período de arrecadação referente aos
modelos 

@author SIGAGTP | Renan Ribeiro Brando
@since 24/11/2017
@version 

@type function
/*/
//-------------------------------------------------------------------

Static Function GA500Commit(oModel)
Local cCodArr    := oModel:GetModel('G59MASTER'):GetValue("G59_CODIGO")
Local lRet 		 := .T. 
Local nOperation := oModel:GetOperation()

If nOperation == 5
	GZU->(DbSetOrder(1))
	If GZU->(DbSeek(xFilial("GZU")+ PADR(G59->G59_CODIGO,TAMSX3("G59_CODIGO")[1])))
		While GZU->(!Eof()) .AND. GZU->(GZU_FILIAL+GZU_CODG59 ) == xFilial("GZU")+PADR(G59->G59_CODIGO,TAMSX3("G59_CODIGO")[1])
			RecLock("GZU",.F.)
			GZU->(DbDelete())
			GZU->(MsUnlock())	
			GZU->(dbSkip())
		EndDo
						
	EndIf

EndIf

If (lRet)
    // Faz o commit do modelo todo 
    FWFormCommit(oModel)  
    UnLockByName(cCodArr)
        
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ExistArr
verifica se existe uma arrecadação criada para a agencia no mesmo periodo
@type function
@author crisf
@since 28/12/2017
@version 1.0
@param cCodAge, character, (Descrição do parametro)
@param dDtIni, data, (Descrição do parametro)
@param dDtFim, data, (Descrição do parametro)
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------
Static Function ExistArr( cCodAge, dDtIni, dDtFim )

	Local lExist	:= .F.
	Local cTmpG59	:= GetNextAlias()
	
		BeginSql Alias cTmpG59
		
			SELECT  G59.G59_CODIGO
			FROM %Table:G59% G59
			WHERE G59.G59_FILIAL = %xFilial:G59%
			  AND G59.G59_AGENCI = %exp:cCodAge%
			  AND G59.G59_DATINI = %exp:Dtos(dDtIni)%
			  AND G59.G59_DATFIM = %exp:Dtos(dDtFim)%
			  AND G59.%NOTDEL%
			  
		EndSql
		
		if !(cTmpG59)->(Eof())
		
			lExist	:= .T.
			
		EndIf
		
		(cTmpG59)->(dbCloseArea())
		
		
Return lExist


Static Function GA500VldRMD()
Local lRet	:= .t.

//Verifica se a arrecadação possui ficha de remessa com bilhetes de DAPE,
//Caso possua, DENTRO DO PERÍODO DA FICHA (que pode ser mais que um dia) deverá possuir, para cada dia, um documento RMD (GZU).
//Se o período da ficha não possui um dia sequer de RMD, então não pode prosseguir com o fechamento.
//Caso a arrecadação, não possua ficha com DAPEs, poderá prosseguir com o fechamento    
Return(lRet)


Static Function GA500RunRMD()
Local lRet		:= .t.
Local oModelGZU := FWLoadModel("GTPA428")
Local oModelIT 	:= oModelGZU:GetModel("ITDETAIL")
Local oModelCab	:= oModelGZU:GetModel("CABMASTER")
Local cAliasRMD	:= GetNextAlias()
Local cAgenci  	:= G59->G59_AGENCI
Local cNumFch  	:= G59->G59_NUMFCH
Local cCodG59  	:= G59->G59_CODIGO
Local cSubSeGZU	:= Substr(cAgenci,4,3)
Local cSerieGZU	:= ''
Local cDocGZU	:= ''
Local cContaCtbl:= GTPGetRules("CTACTBL")
Local aDtRMD	:= {}

cSerieGZU	:= GTPGetRules('SERIRMD')

BeginSql Alias cAliasRMD
    SELECT 
        GIC.GIC_DTVEND,
        SUM(GIC.GIC_VALTOT) VALTOT,
        SUM(GIC.GIC_VLBICM) VALBICM,
        SUM(GIC.GIC_VLICMS) VALICMS,
        SUM(GIC.GIC_VLPIS) VALPIS,
        SUM(GIC.GIC_VLCOF) VALCOF
           
    FROM 
        %Table:GIC% GIC 
    WHERE
        GIC.GIC_FILIAL = %xFilial:GIC%
        AND GIC.GIC_AGENCI = %Exp:cAgenci%
        AND GIC.%NotDel% 
        AND GIC.GIC_NUMFCH = %Exp:cNumFch%
        AND GIC.GIC_STATUS NOT IN ('C','D')
        AND GIC.GIC_TIPO IN ('M','E') 
        AND GIC.GIC_ORIGEM = '1'
        AND GIC.GIC_CONFER <> '3' 
        AND GIC.GIC_VENDRJ Not In ('BCA','IVP')
    Group By GIC.GIC_DTVEND
    Order By GIC.GIC_DTVEND
EndSql

oModelGZU:SetOperation(MODEL_OPERATION_INSERT)
oModelGZU:Activate()
oModelCab:LoadValue("GZUAGENCI"	, cAgenci				)
oModelCab:LoadValue("GZUCODG59"	, cCodG59				)
While  (cAliasRMD)->(!EOF())
    If (!Empty(FwFldget('GZU_DOC')))   
		oModelIT:AddLine()
	EndIf
	cDocGZU	:= GetNextDoc(cAgenci)
	
	oModelIT:LoadValue("GZU_FILIAL"	, xFilial("GZU")		)
	oModelIT:LoadValue("GZU_AGENCI"	, cAgenci				)
	oModelIT:LoadValue("GZU_SERIE"	, cSerieGZU				)
	oModelIT:LoadValue("GZU_SUBSER"	, cSubSeGZU				)
	oModelIT:LoadValue("GZU_DOC"	, cDocGZU				)
	oModelIT:LoadValue("GZU_DTMOV"	, STOD((cAliasRMD)->GIC_DTVEND)		)
	oModelIT:LoadValue("GZU_SITUAC"	, '00'		)
	oModelIT:LoadValue("GZU_CODG59"	, cCodG59				)	
    oModelIT:LoadValue("GZU_VLDOC"	, (cAliasRMD)->VALTOT	)
    oModelIT:LoadValue("GZU_VLSERV"	, (cAliasRMD)->VALTOT	)
    oModelIT:LoadValue("GZU_VLBASE"	, (cAliasRMD)->VALBICM	)
    oModelIT:LoadValue("GZU_VLICMS"	, (cAliasRMD)->VALICMS	)
    oModelIT:LoadValue("GZU_VLPIS"	, (cAliasRMD)->VALPIS	)
    oModelIT:LoadValue("GZU_COFINS"	, (cAliasRMD)->VALCOF	)
    oModelIT:LoadValue("GZU_CONTA"	, cContaCtbl)
    
    AADD(aDtRMD, {(cAliasRMD)->GIC_DTVEND,cAgenci,cDocGZU,cNumFch})
   (cAliasRMD)->(DbSkip())
End
(cAliasRMD)->(dbCloseArea())		

lRet	:= oModelGZU:VldData() 
If lRet 
	lRet	:= oModelGZU:CommitData()
EndIf
If lRet
	AtuGICRMD(aDtRMD)
Endif
oModelGZU:DeActivate()
oModelGZU:Destroy()
//Verifica se a arrecadação possui ficha de remessa com bilhetes de DAPE,
//Caso possua, DENTRO DO PERÍODO DA FICHA (que pode ser mais que um dia) deverá possuir, para cada dia, um documento RMD (GZU).
//Se o período da ficha não possui um dia sequer de RMD, então não pode prosseguir com o fechamento.
//Caso a arrecadação, não possua ficha com DAPEs, poderá prosseguir com o fechamento    
Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} GetNextDoc
Função para criar uma sugestão do numero do inicio do documento
seguindo a sequência do ultimo numero do tipo do documento
@sample	GetNextDoc(cAgenci)
@param 	cTpDoc    Caracter Tipo do Documento

@author		Inovação
@since		20/06/2018
@version	P12
/*/
Function GetNextDoc(cAgenci)

Local cAliasTmp	:= GetNextAlias()
Local cDocGZU		:= "000000"

 	If Select(cAliasTmp) > 0
		(cAliasTmp)->(DbCloseArea())
	Endif
	
	BeginSql Alias cAliasTmp
	SELECT MAX(GZU_DOC) AS GZUPROX FROM %Table:GZU% GZU 
			WHERE 
				GZU.GZU_FILIAL = %xFilial:GZU% 
			 	AND GZU_AGENCI  = %Exp:cAgenci%			 	
			AND GZU.%NotDel% 
	EndSql
	
	If !(cAliasTmp)->(EOF())
		cDocGZU := (cAliasTmp)->GZUPROX 
		cDocGZU := SOMA1(cDocGZU)
	Else
		cDocGZU := SOMA1(cDocGZU)
	EndIf

(cAliasTmp)->(DbCloseArea())

Return(cDocGZU)

Static Function AtuGICRMD(aDtRMD)

Local cAliasGIC	:= GetNextAlias()
Local nA		:= 0

For nA := 1 to Len(aDtRMD)
	BeginSql Alias cAliasGIC
	    SELECT 
	        GIC.R_E_C_N_O_ RECGIC           
	    FROM 
	        %Table:GIC% GIC 
	    WHERE
	        GIC.GIC_FILIAL = %xFilial:GIC%
	        AND GIC.GIC_AGENCI = %Exp:aDtRMD[nA][2]%
	        AND GIC.GIC_DTVEND = %Exp:aDtRMD[nA][1]%
	        AND GIC.%NotDel% 
	        AND GIC.GIC_NUMFCH = %Exp:aDtRMD[nA][4]%
	        AND GIC.GIC_STATUS NOT IN ('C','D')
	        AND GIC.GIC_TIPO IN ('M','E')  
	        AND GIC.GIC_ORIGEM = '1'	
	        AND GIC.GIC_CONFER <> '3'
            AND GIC.GIC_VENDRJ Not In ('BCA','IVP')
	    Order By GIC.GIC_DTVEND
	EndSql
	
	While  (cAliasGIC)->(!EOF())
		GIC->(DbGoTo((cAliasGIC)->RECGIC))
		GIC->(RecLock("GIC",.F.))
		GIC->GIC_CODRMD := aDtRMD[nA][3]
		GIC->(MsUnlock())
		
		(cAliasGIC)->(DbSkip())
		
	End
	
	(cAliasGIC)->(DbCloseArea())

Next nA
	
Return


Function GA500VRMD()

GZU->(DbSetOrder(1))

If GZU->(DbSeek(xFilial("GZU")+G59->G59_CODIGO ))	
	FWExecView( STR0045 , "VIEWDEF.GTPA428", MODEL_OPERATION_VIEW, /*oDlg*/, {|| .T. } ,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ ) //"RMD"
Else
	Help( ,, STR0121,"GTPA428",STR0123 + G59->G59_CODIGO + STR0122, 1, 0 )	 //'Help' //" não possui RMD" //" A arrecadação "
EndIF

Return .T.

/*/
 * {Protheus.doc} ExcGTPA500()
 * Validação para inclusão.
 * type    Function
 * author  Eduardo Ferreira
 * since   27/01/2020
 * version 12.25
 * param   Não há
 * return  Não há
/*/
Function ExcGTPA500()

If Pergunte('GTPA500B')
    aPeriod   := GTPFirstPeri(MV_PAR01)
    cAgenPerg := MV_PAR01
    If !VldUsrAgencia(cAgenPerg)
        Return .F.
    EndIf 	
Else
    Return .F.
EndIf

// Se não existir uma ficha de remessa no mês corrente
If !aPeriod[1]
    // Se o status da for 0 não existem fichas de remessa criadas
    If aPeriod[2] == "0"
        if !IsBlind()
            MSGSTOP(STR0013, STR0014) //"Erro" //"Não existem fichas de remessa criadas"
        endif

        Return .F.
    // Alertar o usuário que ele está criando um período de fechamento de uma ficha que não está no mês corrente 
    ElseIf IsBlind() .or. !MSGYESNO(STR0015, STR0018) //"Atenção" //"Não existe ficha de remessa para o mês corrente, deseja prosseguir com a criação de um período de fechamento de arrecadação?"
        Return .F.
    EndIf 
EndIf

// Valida se o periodo ja não cadastrado para inclusão
If ExistArr( cAgenPerg, aPeriod[3], aPeriod[4] )
    FWAlertHelp(STR0016, STR0098 + " " + DTOC(aPeriod[3]) + " " + STR0097 + " " + DTOC(aPeriod[4])) //"Este período já foi cadastrado!" //"Intervalo de " //" até "
    Return .F.
EndIf

if !isBlind()
    FWExecView(STR0124,"VIEWDEF.GTPA500",MODEL_OPERATION_INSERT,,{|| .T.}) //"Arrecadação"
endif 

Return .T.

/*/
 * {Protheus.doc} G500GerTit()
 * Faz a chamada para a função de geração de titulos POS
 * type    Function
 * author  flavio.martins
 * since   04/06/2020
 * param   Não há
 * return  Não há
/*/
Function G500GerTit()
Local lJob       := .T.
Local aNewFlds   := {'GQM_CONFER', 'GQM_DTCONF', 'GQM_USUCON', 'GQM_FILTIT'}
Local lNewFlds   := GTPxVldDic('GQM', aNewFlds, .F., .T.)

If !(G59->G59_STATUS)
    FwAlertHelp(STR0018, STR0047 ) //"Para gerar os títulos é necessário que o período esteja fechado" //"Atenção"
ElseIf !(lNewFlds)   
    FwAlertHelp(STR0049, STR0050) //"Atualize o dicionário para utilizar esta rotina" //"Dicionário desatualizado"
ElseIf MsgYesNo(STR0048, STR0018) //"Atenção" //"Confirma a geração dos títulos?"
    StartJob("GTPA026C",GetEnvServer(),.F.,lJob,cEmpAnt,cFilAnt,G59->G59_AGENCI, G59->G59_NUMFCH)	
Endif

Return

/*/
 * {Protheus.doc} G500OpTit()
 * Faz a chamada para a função de geração de titulos de Receita e Despesa
 * type        Function
 * author  henrique.toyada
 * since   09/06/2020
 * param   Não há
 * return  Não há
/*/
Function G500OpTit(cTipoOp, lMenuDef)
//Local lJob      := .T.
Local aNewFlds   := {'GZG_CONFER', 'GZG_DTCONF', 'GZG_USUCON', 'GZG_FILTIT'}
Local lNewFlds   := GTPxVldDic('GZG', aNewFlds, .F., .T.)
Local lRetorno   := .T.
Local lProc      := .T.

Default cTipoOp  := "" 
Default lMenuDef := .F.

If !(G59->G59_STATUS)
    FwAlertHelp(STR0018, STR0047 ) //"Para gerar os títulos é necessário que o período esteja fechado" //"Atenção"
ElseIf !(lNewFlds)   
    FwAlertHelp(STR0049, STR0050) //"Atualize o dicionário para utilizar esta rotina" //"Dicionário desatualizado"
Else   
    If lMenuDef 
        lProc := MsgYesNo(STR0048, STR0018) // "Atenção", "Confirma a geração dos títulos?"
    EndIf 
    If lProc 
        If lMenuDef
            FWMsgRun(,{|| lRetorno := GTPA421D(.F.,cEmpAnt,cFilAnt,G59->G59_AGENCI, G59->G59_NUMFCH,cTipoOp)}, STR0146, Iif(cTipoOp=='1',STR0143,STR0144))  
        Else 
            lRetorno := StartJob("GTPA421D",GetEnvServer(),.F.,.T.,cEmpAnt,cFilAnt,G59->G59_AGENCI, G59->G59_NUMFCH,cTipoOp, G59->G59_CODIGO)
        EndIf             
    EndIf 
Endif

//If lMenuDef
    SetStatusArrec(lRetorno)
//EndIf 
Return lRetorno 

/*
 {Protheus.doc} Gtp500CancBaix()
 Faz o estorno de baixa de títulos gerados (a receber/a pagar)
 type    Function
 author  José Carlos
 since   22/05/2024
 param   Não há
 return  Não há
*/
Static Function Gtp500CancBaix(cAgencia, cNumFech, aProc)
    Local cAliasQry     := GetNextAlias()
    Local aTitulo       := {}
    Local cMsgErro      := ""
    Local lRetorno      := .T.
    
    private lMsErroAuto := .F.
    FwClearHlp()
    BEGIN TRANSACTION

        //Contas a Pagar
        SE2->(DbSetOrder(1))
        BEGINSQL ALIAS cAliasQry

            SELECT 
                GZG_AGENCI          
                , GZG_NUMFCH          
                , GZG_TIPO          
                , GZG_FILTIT          
                , GZG_PRETIT          
                , GZG_NUMTIT          
                , GZG_PARTIT          
                , GZG_TIPTIT  
                , GZG.R_E_C_N_O_ RECNO_GZG         
                , GI6_CLIENT          
                , GI6_LJCLI          
                , GI6_FORNEC          
                , GI6_LOJA          
                , GI6_FILRES          
            FROM %table:GZG% GZG           
            INNER JOIN %table:GI6% GI6           
                ON GI6.GI6_FILIAL = %xfilial:GI6%          
                AND GI6.GI6_CODIGO = GZG.GZG_AGENCI          
                AND GI6.%notDel%          
            WHERE GZG.GZG_FILIAL = %xfilial:GZG%  
                AND GZG.GZG_AGENCI = %exp:cAgencia%        
                AND GZG.GZG_NUMFCH = %exp:cNumFech%        
                AND GZG.GZG_TIPO = '2'          
                AND GZG.GZG_CONFER = '2'          
                AND GZG.GZG_STATIT IN ('1','2')
                AND GZG.%notDel%     
        ENDSQL

        While (cAliasQry)->(!Eof()) 

            aTitulo :=	{;
                            { "E2_PREFIXO"	, (cAliasQry)->GZG_PRETIT   , Nil },; //Prefixo 
                            { "E2_NUM"		, (cAliasQry)->GZG_NUMTIT	, Nil },; //Numero
                            { "E2_TIPO"		, (cAliasQry)->GZG_TIPTIT	, Nil },; //Tipo
                            { "E2_PARCELA"	, (cAliasQry)->GZG_PARTIT	, Nil },; //Parcela
                            { "E2_FORNECE"	, (cAliasQry)->GI6_FORNEC	, Nil },; //Fornecedor
                            { "E2_LOJA"		, (cAliasQry)->GI6_LOJA		, Nil }; //Loja
                        }
            
            lMsErroAuto := .F.
            SE2->(DbSeek((cAliasQry)->(GZG_FILTIT+GZG_PRETIT+GZG_NUMTIT+GZG_PARTIT+GZG_TIPTIT+GI6_FORNEC+GI6_LOJA)))                                        
            MsExecAuto( { |x,y| Fina080(x,y)}, aTitulo, 6) // 3-Inclusao,4-Alteração,5-Cancelamento de baixa,6-Exclusão de baixa

            GZG->(DbGoTo((cAliasQry)->RECNO_GZG))
            If lMsErroAuto
                cMsgErro := GetLogError()
                Aadd(aProc,{2,(cAliasQry)->RECNO_GZG,cMsgErro})
                lRetorno := .F.
            Else 
                lMsErroAuto := .F.
                //Exclui titulo
                MSExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,5)// 3-Inclusao,4-Alteração,5-Exclusão

                If lMsErroAuto
                    cMsgErro := GetLogError()
                    Aadd(aProc,{2,(cAliasQry)->RECNO_GZG,cMsgErro})
                    lRetorno := .F.
                Else 
                    Aadd(aProc,{1,(cAliasQry)->RECNO_GZG,''})
                EndIf 
            EndIf 

            If !lRetorno
                DisarmTransaction()
                Break                
            Endif

            (cAliasQry)->(dbSkip())

        EndDo 

        If Select(cAliasQry) > 0
            (cAliasQry)->(dbCloseArea())
        Endif

        //Contas a Receber
        SE1->(DbSetOrder(2))
        cAliasQry     := GetNextAlias()
        BEGINSQL ALIAS cAliasQry

            SELECT 
                GZG_AGENCI          
                , GZG_NUMFCH          
                , GZG_TIPO          
                , GZG_FILTIT          
                , GZG_PRETIT          
                , GZG_NUMTIT          
                , GZG_PARTIT          
                , GZG_TIPTIT  
                , GZG. R_E_C_N_O_ RECNO_GZG        
                , GI6_CLIENT          
                , GI6_LJCLI          
                , GI6_FORNEC          
                , GI6_LOJA          
                , GI6_FILRES          
            FROM %table:GZG% GZG           
            INNER JOIN %table:GI6% GI6           
                ON GI6.GI6_FILIAL = %xfilial:GI6%          
                AND GI6.GI6_CODIGO = GZG.GZG_AGENCI          
                AND GI6.%notDel%          
            WHERE GZG.GZG_FILIAL = %xfilial:GZG%  
                AND GZG.GZG_AGENCI = %exp:cAgencia%        
                AND GZG.GZG_NUMFCH = %exp:cNumFech%        
                AND GZG.GZG_TIPO = '1'          
                AND GZG.GZG_CONFER = '2'          
                AND GZG.GZG_STATIT IN ('1','2')
                AND GZG.%notDel%     
        ENDSQL

        While (cAliasQry)->(!Eof()) 

            aTitulo :=	{;
                            { "E1_FILIAL"	, (cAliasQry)->GZG_FILTIT   , Nil },; //Filial
                            { "E1_PREFIXO"	, (cAliasQry)->GZG_PRETIT   , Nil },; //Prefixo 
                            { "E1_NUM"		, (cAliasQry)->GZG_NUMTIT	, Nil },; //Numero
                            { "E1_PARCELA"	, (cAliasQry)->GZG_PARTIT	, Nil },; //Parcela
                            { "E1_TIPO"		, (cAliasQry)->GZG_TIPTIT	, Nil },; //Tipo
                            { "E1_CLIENT"	, (cAliasQry)->GI6_CLIENT	, Nil },; //Cliente
                            { "E1_LOJA"		, (cAliasQry)->GI6_LJCLI	, Nil };  //Loja
                        }

            lMsErroAuto := .F.
            SE1->(DbSeek((cAliasQry)->(GZG_FILTIT+GI6_CLIENT+GI6_LJCLI+GZG_PRETIT+GZG_NUMTIT+GZG_PARTIT+GZG_TIPTIT)))                                         
            MsExecAuto( { |x,y| Fina070(x,y)}, aTitulo, 6) // 3-Inclusao,4-Alteração,5-Cancelamento de baixa,6-Exclusão de baixa

            GZG->(DbGoTo((cAliasQry)->RECNO_GZG))
            If lMsErroAuto
                cMsgErro := GetLogError()
                Aadd(aProc,{2,(cAliasQry)->RECNO_GZG,cMsgErro})
                lRetorno := .F.
            Else 
                lMsErroAuto := .F.
                //Exclui titulo
                MsExecAuto( { |x,y| Fina040(x,y)}, aTitulo, 5) // 3-Inclusao,4-Alteração,5-Exclusão

                If lMsErroAuto
                    cMsgErro := GetLogError()
                    Aadd(aProc,{2,(cAliasQry)->RECNO_GZG,cMsgErro})
                    lRetorno := .F.
                Else 
                    Aadd(aProc,{1,(cAliasQry)->RECNO_GZG,''})
                EndIf 

            EndIf 

            If !lRetorno
                DisarmTransaction()
                Break                
            Endif

            (cAliasQry)->(dbSkip())

        EndDo 

        If Select(cAliasQry) > 0
            (cAliasQry)->(dbCloseArea())
        Endif

    END TRANSACTION

    aSize(aTitulo,0)
    aTitulo := Nil

Return lRetorno

/*
 {Protheus.doc} GA500View()
 Função de pré chamada da visualização do título posicionado na grid quando ação for visualização
 Posicionamento do registro da GRID.
 type    Function
 author  José Carlos
 since   20/06/2025
 param   Não há
 return  Nil
*/
Function GA500View(oVi)
    Local oMdl	    := oVi:GetModel()
    Local oStruGZGD := NIL 
    Local oStruGZGE := NIL 
    Local aAreaGZG  := GZG->(GetArea())
    Local aDados    := {}
    Local cStatusTit:= ''                                                                                       
    Local cFolder 	:= oVi:GetFolderActive("FOLDER1",2)[2] //-- 1= Retorna o ID do folder, 2 = Retorna o titulo do folder. 
    If Upper(Alltrim(cFolder)) == Upper(Alltrim(STR0075)) 

        aAdd( aDados, { GetSX3Cache('GZG_FILTIT', 'X3_DESCRIC'), '' }) //1
        aAdd( aDados, { GetSX3Cache('GZG_PRETIT', 'X3_DESCRIC'), '' }) //2 
        aAdd( aDados, { GetSX3Cache('GZG_NUMTIT', 'X3_DESCRIC'), '' }) //3
        aAdd( aDados, { GetSX3Cache('GZG_PARTIT', 'X3_DESCRIC'), '' }) //4
        aAdd( aDados, { GetSX3Cache('GZG_TIPTIT', 'X3_DESCRIC'), '' }) //5
        aAdd( aDados, { GetSX3Cache('GZG_MOTERR', 'X3_DESCRIC'), '' }) //6

        If cGridFocus == 'V_RECEITA'
            oStruGZGE:= oMdl:GetModel("GZGDETAILE")
            cStatusTit := oStruGZGE:GetValue('GZG_STATIT')
            aDados[1][2] := oStruGZGE:GetValue('GZG_FILTIT') //1
            aDados[2][2] := oStruGZGE:GetValue('GZG_PRETIT') //2 
            aDados[3][2] := oStruGZGE:GetValue('GZG_NUMTIT') //3
            aDados[4][2] := oStruGZGE:GetValue('GZG_PARTIT') //4
            aDados[5][2] := oStruGZGE:GetValue('GZG_TIPTIT') //5
            aDados[6][2] := oStruGZGE:GetValue('GZG_MOTERR') //6

        ElseIf  cGridFocus == 'V_DESPESA'
            oStruGZGD:= oMdl:GetModel("GZGDETAILD")
            cStatusTit := oStruGZGD:GetValue('GZG_STATIT')
            aDados[1][2] := oStruGZGD:GetValue('GZG_FILTIT') //1
            aDados[2][2] := oStruGZGD:GetValue('GZG_PRETIT') //2 
            aDados[3][2] := oStruGZGD:GetValue('GZG_NUMTIT') //3
            aDados[4][2] := oStruGZGD:GetValue('GZG_PARTIT') //4
            aDados[5][2] := oStruGZGD:GetValue('GZG_TIPTIT') //5
            aDados[6][2] := oStruGZGD:GetValue('GZG_MOTERR') //6

        EndIf 
        If cStatusTit <> '0'
            ViewDados(aDados)
        Else 
            FWAlertInfo(STR0137, STR0134)  //  "Não existe título gerado." 'Consulta Titulo'                 
        EndIF  
    Else 
        FWAlertInfo( I18n(STR0012, { STR0075 } ) , STR0134 ) // "Ação disponível apenas quando o foco está na pasta [#1]", "Consulta título"    
    EndIf 

    RestArea(aAreaGZG)

Return Nil

/*
 {Protheus.doc} ViewDados(aDados)
 Função visualização do título posicionado na grid quando ação for visualização
 type    Function
 author  José Carlos
 since   20/06/2025
 param   Não há
 return  Nil
*/
Static Function ViewDados(aDados) 
    Local oModal
    Local oDlg
    Local oP1
    Local oP2
    Local oLbx
    Local aStruct := {}

    aAdd( aStruct, { aDados[1][2] ,;
                     aDados[2][2] ,;
                     aDados[3][2] ,;
                     aDados[4][2] ,; 
                     aDados[5][2] })

    oModal:= FWDialogModal():New()       
    oModal:SetEscClose(.T.)
    oModal:setTitle(STR0134) // 'Consulta Título'
    oModal:setSize(200, 400)
    oModal:createDialog()
    oModal:addCloseButton({|| oModal:DeActivate() }, "OK")

    oDlg:= oModal:getPanelMain()

    oP1:= TPanelCss():New(,,, oDlg)
    oP1:SetCoors(TRect():New(0, 0, 60, 100))
    oP1:Align :=CONTROL_ALIGN_TOP

    @ 002, 002 LISTBOX oLbx FIELDS HEADER Alltrim(aDados[1][1]), Alltrim(aDados[2][1]), Alltrim(aDados[3][1]), Alltrim(aDados[4][1]), Alltrim(aDados[5][1]) SIZE 158,095 PIXEL OF oP1 
    oLbx:Align :=CONTROL_ALIGN_ALLCLIENT
    oLbx:SetArray( aStruct )
    oLbx:bLine := {|| { aStruct[oLbx:nAt,1], aStruct[oLbx:nAt,2], aStruct[oLbx:nAt,3],aStruct[oLbx:nAt,4],aStruct[oLbx:nAt,5]}}
    oLbx:SetFocus()

    oP2:= TPanelCss():New(,,, oDlg)
    oP2:SetCoors(TRect():New(0, 0, 120, 100))
    oP2:Align :=CONTROL_ALIGN_ALLCLIENT  

    @ 002, 010 SAY Alltrim(aDados[6][1]) of oP2 SIZE 150, 18 PIXEL 
    @ 012, 010 GET oMemo Var aDados[6][2] Memo of oP2 SIZE 180, 095 PIXEL 

    oModal:Activate()

Return Nil 

/*
 {Protheus.doc} GetLogError()
 Função para gravação do log do msexecauto para uma variável.
 type    Function
 author  José Carlos
 since   20/06/2025
 param   Não há
 return  cMsg - String
*/
Static Function GetLogError()
    Local cMsg := STR0138 + CRLF    // 'Existe uma inconsistência no titulo.'
    Local nLog := 0
    Local nLin := 0
    Local aLin := {}
    Local aLog := FwGetUltHlp()
    Local cPath:= GetSrvProfString("StartPath","")
    Local cNomeLog:= NomeAutoLog()
    For nLog:= 1 To Len(aLog)
        If ValType(aLog[nLog]) == 'C'
            cMsg += aLog[nLog] + CRLF 
        ElseIf ValType(aLog[nLog]) == 'A'
            aLin := aLog[nLog]
            For nLin := 1 To Len(aLin)
                cMsg += aLin[nLin] + CRLF 
            Next nLin                 
        EndIf 
    Next nLog 
    cMsg += mostraerro(cPath,cNomeLog)
Return cMsg 

/*
 {Protheus.doc} SetLogArrDadosProc(aDados)
 Atualização de váriavel STATIC [aDadosProc]
 type    Function
 author  José Carlos
 since   18/07/2025
 param   aDados - Array contendo dados do registro posicionado bem com os dados dos títulos caso gerados.
 return  Nil
*/
Function SetLogArrDadosProc(aDados)
    
    Aadd( aDadosProc,{  aDados[1],;   //Recno  
                        aDados[2],;   //nAcao   
                        aDados[3],;   //Msg      
                        aDados[4],;   //Filial 
                        aDados[5],;   //Pref 
                        aDados[6],;   //Num 
                        aDados[7],;   //Parc 
                        aDados[8]})   //Tipo

Return 


Static Function SetStatusArrec(lRet)
    Local nProc   := 0
    Local nAcao   := 0
    Local cMsg    := ''
    Local aTit    := {}
    Local nTexto  := 0
    Local aTexto  := {}
    Local oGtpLog := NIL

    If !Empty(aDadosProc)   // .And. !IsBlind()

        // nAcao = 3 Atualização dos campos referentes ao título    
        // nAcao = 2 Falha na geração/baixa titulo
        // nAcao = 1 Rollback dos títulos gerados (limpeza dos campos)

        For nProc:=1 To Len(aDadosProc)

            If !lRet .And. (aDadosProc[nProc][2] == 3 )
                Loop
            EndIf 

            //Posiciona no registro GZG
            GZG->(DbGoTo(aDadosProc[nProc][1]))
            nAcao := aDadosProc[nProc][2]
            cMsg  := aDadosProc[nProc][3]
            aTit  := { aDadosProc[nProc][4], aDadosProc[nProc][5], aDadosProc[nProc][6], aDadosProc[nProc][7], aDadosProc[nProc][8]}
            GTPA500C(nAcao, cMsg, aTit )   

        Next nProc 

        If G59->(FieldPos('G59_STFINA')) > 0
            RECLOCK('G59',.F.)
                G59->G59_STFINA := Iif(!lRet,'2','1')
            G59->(MSUNLOCK())
        EndIf 

        For nTexto:=1 To Len(aDadosProc)
            If !Empty(aDadosProc[nTexto][3]) .And. Ascan(aTexto, {|e| Alltrim(e) == Alltrim(aDadosProc[nTexto][3]) }) == 0
                Aadd( aTexto, aDadosProc[nTexto][3] )
            EndIf 
        Next nTexto

        If !Empty(aTexto) .And. !FwIsInCallStack("G500Reproc")
            oGtpLog	:= GTPLog():New(STR0145,.F.)  //'Fechamento Arrecadação (Inconsistência)'
            For nProc:=1 To Len(aTexto)
                oGtpLog:SetText(aTexto[nProc])		
            Next nProc            
            oGtpLog:ShowLog()
        EndIF 
    EndIf 

    aDadosProc := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} G500Reproc()
Reprocessamento de titulos de receita/despesa
@author  José Carlos
@since   21/07/2025
@version P12
/*/
//-------------------------------------------------------------------
Function G500Reproc()
    Local aParamBox := {}
    Local aRet      := {}
    Local lProcessa := .F.
    Local aMvPar    := {}
    Local nX        := 0

    For nX := 1 To 40
        aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
    Next nX    

    aAdd(aParamBox,{1,STR0147, Space(GetSX3Cache('G59_AGENCI', 'X3_TAMANHO')),"@!", ,"GI6", ,50,.F.})   //"Agência de:"
    aAdd(aParamBox,{1,STR0148, Space(GetSX3Cache('G59_AGENCI', 'X3_TAMANHO')),"@!", ,"GI6", ,50,.F.})   //"Agência ate:"
    aAdd(aParamBox,{1,STR0149, Ctod(Space(8)),"","","","",50,.F.})    //"Data Inicial:"
    aAdd(aParamBox,{1,STR0150, Ctod(Space(8)),"","","","",50,.F.})    //"Data Final:"

    If ParamBox(aParamBox,STR0151,@aRet)     //"Informe os parâmetros..."
        If Empty(aRet[1]) .Or. Empty(aRet[2])
            FWAlertInfo(STR0152, STR0154)     //"Agência não informada!" "Parâmetros"
        ElseIf Empty(aRet[3]) .Or. Empty(aRet[4])            
            FWAlertInfo(STR0153, STR0154)   //"Data não informada!" "Parâmetros"
        Else 
            lProcessa := .T.                 
        EndIF 

    Endif

    If lProcessa 
        FWMsgRun(,{|| ProcReproc( aRet )}, STR0155, STR0146)     //'Selecionado registro(s)' 'Processando...'
    EndIf  

    For nX := 1 To Len( aMvPar )
        &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
    Next nX

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcReproc()
Função de Processamento
@author  José Carlos
@since   21/07/2025
@version P12
/*/
//-------------------------------------------------------------------
Static Function ProcReproc( aRet )
    Local cAliasQuery := GetNextAlias()
    Local lRet        := .F.
    G59->(DbSetOrder(1))

    BeginSql Alias cAliasQuery 
        SELECT 
            G59_CODIGO
        FROM
            %Table:G59% G59
        WHERE    
                G59.G59_FILIAL = %xFilial:G59%  
            AND G59.G59_AGENCI BETWEEN %Exp:aRet[1]% AND %Exp:aRet[2]%  
            AND G59.G59_DATINI BETWEEN %Exp:Dtos(aRet[3])% AND %Exp:Dtos(aRet[4])%
            AND G59.G59_STATUS = 'T'
            AND G59.%NotDel%
    EndSql

    If (cAliasQuery)->(!EOF())
        While (cAliasQuery)->(!EOF())
            If G59->( DbSeek(xFilial("G59") + (cAliasQuery)->G59_CODIGO) )

                lRet := GTPA421D(.F.,cEmpAnt,cFilAnt,G59->G59_AGENCI, G59->G59_NUMFCH,'1')
                SetStatusArrec(lRet)
                lRet := GTPA421D(.F.,cEmpAnt,cFilAnt,G59->G59_AGENCI, G59->G59_NUMFCH,'2')                
                SetStatusArrec(lRet)

            EndIf 
            (cAliasQuery)->(DbSkip())   
        EndDo 
    Else 
        FWAlertInfo(STR0156, STR0157)    //"Não localizado Arrecadação com status fechado." "Reprocessamento"
    EndIf 
    (cAliasQuery)->(DbCloseArea()) 

Return 

/*/
 * {Protheus.doc} ExcGTPA500()
 * Validação de acesso do usuário as agências
 * type    Function
 * author  jose.darocha
 * since   25/08/20205
 * version 12.25
 * param   Não há
 * return  booleano
/*/
Static Function VldUsrAgencia(cAgencia)
    Local lRetorno := .F.
    Local aAreaAtu := GetArea()
    G9X->(DbSetOrder(1))
    lRetorno := G9X->(DbSeek(xFilial("G9X")+__cUserId+cAgencia))
    RestArea( aAreaAtu )

    If !lRetorno .And. !IsBlind()
        Help(NIL, NIL, "VldUsrAgencia", NIL, STR0159, 1 , 0 , NIL , NIL , NIL , NIL , NIL ,{""}) // "Usuário não faz parte do fechamento da agência."
    EndIf 

Return lRetorno 

//-------------------------------------------------------------------
/*/{Protheus.doc} GA500STA()
Opções status X3_CBOX da arrecadação (campo G59_STAPRO)
@author  flavio.martins
@since   08/09/2025
@version P12
/*/
//-------------------------------------------------------------------
Function GA500STA()
Local cOpcoes := ""
 
cOpcoes += '1='+STR0002  // "Aberto;"
cOpcoes += ';2='+STR0161 // "Processando Fechamento;"
cOpcoes += ';3='+STR0162 // "Erro Geração dos Títulos;"
cOpcoes += ';4='+STR0003 // "Fechado;"
cOpcoes += ';5='+STR0164 // "Processando Reabertura;"
cOpcoes += ';6='+STR0165 // "Erro Estorno dos Títulos;"
cOpcoes += ';7='+STR0166 // "Reaberto;"

Return cOpcoes
