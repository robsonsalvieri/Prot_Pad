#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "RMIDISMVC.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiDisMvc
Distribuições

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiDisMvc()

	Local oBrowse := Nil
	If AmIIn(12)// Acesso apenas para modulo e licença do Varejo
		oBrowse := FWMBrowse():New()
		
		oBrowse:SetDescription(STR0001)   //"Distribuições"
		oBrowse:SetAlias("MHR")
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
	aAdd( aRotina, { STR0003, "VIEWDEF.RMIDISMVC", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.RMIDISMVC", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.RMIDISMVC", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.RMIDISMVC", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.RMIDISMVC", 0, 8, 0, NIL } ) //"Imprimir"

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
	Local oModel     := FWLoadModel("RMIDISMVC")
	Local oStructMHR := FWFormStruct(2, "MHR")

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription(STR0001)   //"Distribuições"

	oView:AddField("RMIDISMVC_FIELD_MHR", oStructMHR, "MHRMASTER")

	oView:CreateHorizontalBox("FORMFIELD", 100)

	oView:SetOwnerView("RMIDISMVC_FIELD_MHR", "FORMFIELD")

    oView:EnableTitleView("RMIDISMVC_FIELD_MHR", STR0008)    //"Distribuição"

	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Base da Decisão

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0

@obs MHRMASTER - Distribuições
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := Nil
	Local oStructMHR := FWFormStruct(1, "MHR")
	
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "RMIDISMVC", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:SetDescription(STR0008)    //"Distribuição"

	oModel:AddFields( "MHRMASTER", NIL, oStructMHR, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:GetModel( "MHRMASTER" ):SetDescription(STR0001)    //"Distribuições"

Return oModel