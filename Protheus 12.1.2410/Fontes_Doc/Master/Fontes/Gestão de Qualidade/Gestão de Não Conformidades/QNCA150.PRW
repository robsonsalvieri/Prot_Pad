//Bibliotecas
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDef.ch'
#INCLUDE "QNCA150.CH"
 
Static cTitulo := STR0006 //"Cadastro de Tipos de Documento x Etapa"
 
/*/{Protheus.doc} QNCA150
Função para Cadastro de Tipos de Documento x Etapa (QUT)
@author Jefferson
@since 28/03/2025
/*/
 
Function QNCA150()
    Local aArea   := GetArea()
    Local oBrowse := Nil

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("QUT")
    oBrowse:SetDescription(cTitulo) //"Cadastro de Tipos de Documento x Etapa"
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil
 
/*/{Protheus.doc} MenuDef
Montagem do menu de opções da rotina QNCA150
@author Jefferson
@since 28/03/2025
/*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE STR0002 ACTION 'VIEWDEF.QNCA150' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // Visualizar
    ADD OPTION aRot TITLE STR0003 ACTION 'VIEWDEF.QNCA150' OPERATION MODEL_OPERATION_INSERT ACCESS 0 // Incluir
    ADD OPTION aRot TITLE STR0004 ACTION 'VIEWDEF.QNCA150' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // Alterar
    ADD OPTION aRot TITLE STR0005 ACTION 'VIEWDEF.QNCA150' OPERATION MODEL_OPERATION_DELETE ACCESS 0 // Excluir

Return aRot
 
/*/{Protheus.doc} ModelDef
Criação do modelo de dados da rotina QNCA150
@author Jefferson
@since 28/03/2025
/*/
 
Static Function ModelDef()

    Local oModel := Nil
    Local oStQUT := FWFormStruct(1, "QUT")

    oModel := MPFormModel():New("QNCA150M",/*bPre*/, { |oModel| QN40TudOk( oModel ) }, ,/*bCancel*/) 
     
    oModel:AddFields("FORMQUT",/*cOwner*/,oStQUT)
    oModel:SetDescription(cTitulo)

Return oModel
 
/*/{Protheus.doc} ViewDef
Criação do visão de dados da rotina QNCA150
@author Jefferson
@since 28/03/2025
/*/
 
Static Function ViewDef()

    Local oModel := FWLoadModel("QNCA150")
    Local oStQUT := FWFormStruct(2, "QUT")
    Local oView  := Nil
 
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    oView:AddField("VIEW_QUT", oStQUT, "FORMQUT")
     
    oView:CreateHorizontalBox("TELA",100)
     
    oView:EnableTitleView('VIEW_QUT', STR0006 )  
     
    oView:SetCloseOnOk({||.T.})

    //Criando grupos
	oStQUT:AddGroup( 'GRUPO01', '', '', 2 )
    oStQUT:AddGroup( 'GRUPO02', '', '', 2 )
    oStQUT:AddGroup( 'GRUPO03', '', '', 1 )

    oStQUT:SetProperty( 'QUT_ETAPA'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
    oStQUT:SetProperty( 'QUT_DESETA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
    oStQUT:SetProperty( 'QUT_TIPODC'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStQUT:SetProperty( 'QUT_DESDOC'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
    oStQUT:SetProperty( 'QUT_OBRIGA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
     
    oView:SetOwnerView("VIEW_QUT","TELA")

Return oView
 

 /*/{Protheus.doc} QN40TudOk
Criação da validação do cadastro de etapa e tipo de documento
@author Jefferson
@since 28/03/2025
/*/
Function QN40TudOk( oModel)

    Local aArea      := GetArea()
    Local lRetorno   := .T.
    Local nOperation := oModel:GetOperation()

    If nOperation != MODEL_OPERATION_INSERT
        Return .T.
    Endif

    dbSelectArea("QUT")
    QUT->(dbSetOrder(1))
    QUT->(dbSeek( xFilial("QUT")+AllTrim(M->QUT_ETAPA)+AllTrim(M->QUT_TIPODC)))

    If Found() 
        //STR0007 - Tipo de documento já cadastrado para essa etapa.
        //STR0010 - Selecione um Tipo de Documento diferente.
        Help("",1,"HELP",,STR0007,1,0,,,,,,{STR0010})
        lRetorno := .F.
    Endif

    RestaRea(aArea)

Return lRetorno
