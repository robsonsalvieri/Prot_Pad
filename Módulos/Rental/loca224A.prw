#INCLUDE "LOCA224.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSMGADD.CH"


/*/{PROTHEUS.DOC} ViewDef
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - DEFINICAO DA INTERFACE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 18/03/2024
@HISTORY 18/03/2024, FRANK ZWARG FUGA, TRANSFORMAÇÃO EM MVC
/*/

Static Function ViewDef()
Local oModel    := FWLoadModel("LOCA224A")
Local oStPai    := FWFormStruct(2, "ST9")
Local oStFilho  := FWFormStruct(2, "FQ4")
Local oStFilh2
Local oView     := Nil
Local bVldPre   := {|| LOCA224O(2)}

    oStFilh2  := FWFormStruct(2, "FQF")

    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
    //oView:setOperation(MODEL_OPERATION_UPDATE)

    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField("VIEW_ST9",oStPai,"ST9MASTER")
    oView:AddGrid("VIEW_FQ4",oStFilho,"FQ4DETAIL")

    oView:AddGrid("VIEW_FQF",oStFilh2,"FQFDETAIL")

    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox("CABEC",30)
    oView:CreateHorizontalBox("BOX3" ,70)
    oView:CreateFolder( 'FOLDER1', 'BOX3')
    oView:AddSheet('FOLDER1','SHEET1', STR0014) // movimentações
    oView:AddSheet('FOLDER1','SHEET2', STR0016) // sub-status
    oView:CreateHorizontalBox( 'PASTA1A', 100, , , 'FOLDER1', 'SHEET1')
    oView:CreateHorizontalBox( 'PASTA1B', 100, , , 'FOLDER1', 'SHEET2')
    oView:SetOwnerView('VIEW_ST9','CABEC')
    oView:SetOwnerView('VIEW_FQ4','PASTA1A')
    oView:SetOwnerView('VIEW_FQF','PASTA1B')
    oView:EnableTitleView("VIEW_ST9",STR0015) // "Detalhamento do bem"
    oView:EnableTitleView("VIEW_FQ4",STR0014) // "Movimentação"
    oView:EnableTitleView("VIEW_FQF",STR0016) // "Sub-Status"
    oView:SetViewProperty("VIEW_ST9", "ONLYVIEW")

    oView:AddUserButton( STR0022, STR0022 , {|oView| LOCA224D() } ) // "Visualizar o projeto"
    oView:SetViewCanActivate(bVldPre)

Return oView

/*/{PROTHEUS.DOC} ModelDef
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - DEFINICAO DO MODELO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 18/03/2024
@HISTORY 18/03/2024, FRANK ZWARG FUGA, TRANSFORMAÇÃO EM MVC
/*/

Static Function ModelDef()
Local oModel    := Nil
Local oStPai    := FWFormStruct(1, "ST9")
Local oStFilho  := FWFormStruct(1, "FQ4")
Local oStFilh2
Local bVldPos   := {|| LOCA224E()}
Local bFLSLinPRE := {|oModelGrid, nLine, cAction, cField| FLSLINPRE(oModelGrid,nLine,cAction,cField)}

    oStFilh2 := FWFormStruct(1, "FQF")

    //Criando o modelo e os relacionamentos
    //oModel := MPFormModel():New("LOCA224",bVldPre,bVldPos)
    oModel := MPFormModel():New("LOCA224",,bVldPos)

    oModel:AddFields("ST9MASTER",,oStPai)
    oModel:AddGrid("FQ4DETAIL","ST9MASTER",oStFilho,,,,,)
//    oModel:AddGrid("FQFDETAIL","FQ4DETAIL",oStFilh2,,,,,)
    oModel:AddGrid("FQFDETAIL","FQ4DETAIL",oStFilh2,bFLSLinPRE,,,,)

    oModel:SetRelation('FQ4DETAIL', { { 'FQ4_FILIAL', "xFilial('FQ4')" }, { 'FQ4_CODBEM', 'T9_CODBEM'  } }, FQ4->(IndexKey(1)) )

    oModel:SetRelation('FQFDETAIL', { { 'FQF_FILIAL', "xFilial('FQF')" }, { 'FQF_SEQ', 'FQ4_SEQ' } }, FQF->(IndexKey(1)) )
    oModel:SetPrimaryKey({})

    //Setando as descrições
    oModel:SetDescription(STR0004) // "Gerenciamento de Bens"
    oModel:GetModel("ST9MASTER"):SetDescription(STR0015) // "Detalhamento do bem"
    oModel:GetModel("FQ4DETAIL"):SetDescription(STR0014) // "Movimentação"
    oModel:GetModel("FQFDETAIL"):SetDescription(STR0016) // "Sub-Status"
    oModel:GetModel('FQFDETAIL'):SetOptional(.T.)

    oModelFQ4 := oModel:GetModel("FQ4DETAIL")
    oModelFQ4:SetNoInsertLine(.T.)
    oModelFQ4:SetNoUpdateLine(.T.)
    oModelFQ4:SetNoDeleteLine(.T.)

    oStFilh2:SetProperty("FQF_AS",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'oModelFQ4:GetValue("FQ4_AS")'))
    oStFilh2:SetProperty("FQF_CODBEM",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'ST9->T9_CODBEM'))
    //oStFilh2:SetProperty("FQF_CONRES",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'ST9->T9_POSCONT'))
    oStFilh2:SetProperty("FQF_CONTA",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'ST9->T9_POSCONT'))
    oStFilh2:SetProperty("FQF_PROJET",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'oModelFQ4:GetValue("FQ4_PROJET")'))
    oStFilh2:SetProperty("FQF_SEQ",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'oModelFQ4:GetValue("FQ4_SEQ")'))
    oStFilh2:SetProperty("FQF_STATUS",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'oModelFQ4:GetValue("FQ4_STATUS")'))
    oStFilh2:SetProperty("FQF_DESBEM",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'ST9->T9_NOME'))
    oStFilh2:SetProperty("FQF_DESSTA",MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'oModelFQ4:GetValue("FQ4_DESTAT")'))
    oStFilh2:AddTrigger( "FQF_CODBEM" , "FQF_CONTA", {|| .T. }, {|oModel| Posicione("ST9",1,xFilial("ST9")+FWFldGet("FQF_CODBEM"), "T9_POSCONT") } )
    oStFilh2:AddTrigger( "FQF_BEMRES" , "FQF_CONRES", {|| .T. }, {|oModel| Posicione("ST9",1,xFilial("ST9")+FWFldGet("FQF_BEMRES"), "T9_POSCONT") } )

Return oModel

/*/{PROTHEUS.DOC} ExeC224a
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - CHAMADA DO AROTINA DO LOCA224
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 18/03/2024
@HISTORY 18/03/2024, FRANK ZWARG FUGA, TRANSFORMAÇÃO EM MVC
/*/

Function ExeC224a(nOpc)
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
Local nRet 
    nRegOri := ST9->(Recno())

    If nOpc == 2
        FWExecView(STR0016,'LOCA224A', MODEL_OPERATION_VIEW, , { || .T. }, , ,aButtons ) // Sub-Status
    Else
        If FWExecView(STR0016,'LOCA224A', MODEL_OPERATION_UPDATE, , { || .T. }, , ,aButtons ) == 0
        	If ExistBlock("LC224A1")
                EXECBLOCK("LC224A1",.F.,.F.,{})
            EndIf
        EndIf
    EndIf
Return

//------------------------------------------------------------
/*/{Protheus.doc} FLSLINPRE
Função para validar se as linhas da Grid poderão ser alteradas 

@author Pedro Alencar	
@since 28/10/2013	
@version 11.90 
@param oModelGrid, Grid do Modelo de Dados
@param nLine, Linha posicionada na grid
@param cAction, Ação que está sendo realizada na linha
@param cField, Campo posicionado
@return lRet, Se .T. a linha poderá ser editada, se .F. não 
/*/
//------------------------------------------------------------
Static Function FLSLINPRE (oModelGrid,nLine,cAction,cField)
	Local lRet := .T. 
	
	If cAction=="CANSETVALUE" 
		If oModelGrid:IsInserted()
			If nLine < oModelGrid:Length()
//				lRet := .F.			
			Endif
		Else
			lRet := .F.
		Endif
	Endif

	If cAction=="DELETE"
		If nLine = oModelGrid:Length()
        Else
    		lRet := .F.			
		Endif
	Endif


Return lRet

