#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "RMIPUBMVC.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubMvc
Publicações

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiPubMvc()

	Local oBrowse := Nil
	If AmIIn(12)// Acesso apenas para modulo e licença do Varejo
		oBrowse := FWMBrowse():New()
		
		oBrowse:SetDescription(STR0001)   //"Publicações"
		oBrowse:SetAlias("MHQ")
		oBrowse:SetLocate()
		oBrowse:Activate()
	else
        MSGALERT(STR0009)// "Esta rotina deve ser executada somente pelo módulo 12 (Controle de Lojas)"
	EndIf
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0002, "PesqBrw"          , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.RMIPUBMVC", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.RMIPUBMVC", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.RMIPUBMVC", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.RMIPUBMVC", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.RMIPUBMVC", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Base da Decisão

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := Nil
	Local oModel     := FWLoadModel("RMIPUBMVC")
	Local oStructMHQ := FWFormStruct(2, "MHQ")

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription(STR0001)   //"Publicações"

	oView:AddField("RMIPUBMVC_FIELD_MHQ", oStructMHQ, "MHQMASTER")

	oView:CreateHorizontalBox("FORMFIELD", 100)

	oView:SetOwnerView("RMIPUBMVC_FIELD_MHQ", "FORMFIELD")

    oView:EnableTitleView("RMIPUBMVC_FIELD_MHQ", STR0008)    //"Publicação"

	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Base da Decisão

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0

@obs MHQMASTER - Publicações
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := Nil
	Local oStructMHQ := FWFormStruct(1, "MHQ")
	
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "RMIPUBMVC", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:SetDescription(STR0008)    //"Publicação"

	oModel:AddFields( "MHQMASTER", NIL, oStructMHQ, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:GetModel( "MHQMASTER" ):SetDescription(STR0001)    //"Publicações"

Return oModel