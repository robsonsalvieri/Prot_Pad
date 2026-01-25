#Include 'Protheus.ch'
#include "PLSMGER.CH" 
#Include 'FWMVCDEF.CH'
#INCLUDE "PLSA163.ch"
#Include "topconn.ch"
#Include "FWBROWSE.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA163
Cadastro de Tipos de Admissao 
@author Tulio Cesar
@since 09.04.2003
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA163()

Local oBrowse

//Instancia objeto
oBrowse := FWMBrowse():New() 


//Define tabela de origem do Browse
oBrowse:SetAlias('BDR') 

//Define o nome da tela
oBrowse:SetDescription(STR0001) //"Tipos de admissão"

oBrowse:Activate()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@author Jullia Barros
@since 15/05/2023
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title  STR0002	Action 'VIEWDEF.PLSA163' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0003 	Action "VIEWDEF.PLSA163" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0004	Action "VIEWDEF.PLSA163" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0005	Action "VIEWDEF.PLSA163"	Operation 5 Access 0  //Excluir 
Add Option aRotina Title  STR0006   Action "MsgRun('',,{||PLVINCTIS('BDR',BDR->BDR_CODTAD, 1)})" Operation 8 Access 0 //Vinculo TISS
Add Option aRotina Title  STR0007   Action "MsgRun('',,{||PLVINCTIS('BDR',BDR->BDR_CODTAD, 0)})" Operation 8 Access 0 //Excluir Vinculo TISS 

Return aRotina

                   
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@author Jullia Barros
@since 15/05/2023
@version P12
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel    := NIL
Local oStrBDR	:= FWFormStruct(1,'BDR')// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que irá considerar

oModel := MPFormModel():New( 'PLSA163', , , { || PLSCADOK(oModel) }  ) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação e de cancelamento

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'BDRMASTER', /*cOwner*/, oStrBDR ) 
 
// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( STR0001 )  //Tipos de Admissão

// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:SetPrimaryKey({"BDR_FILIAL", "BDR_CODOPE", "BDR_CODTAD"})

Return oModel // Retorna o Modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@author Jullia Barros
@since 15/05/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oView  // Interface de visualização construída
Local oModel	:= FWLoadModel( 'PLSA163' ) // Cria as estruturas a serem usadas na View
Local oStrBDR	:= FWFormStruct(2,'BDR')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_BDR', oStrBDR, 'BDRMASTER' )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_BDR', 'SUPERIOR' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCADOK
Valida a Sincronização com a SigaHSP.
@author Jullia Barros
@since 15/05/2023
@version P12
/*/
//-------------------------------------------------------------------

static Function PLSCADOK(oModel)
Local lRet        := .T.
local lAtivoSinc  := GetNewPar("MV_INTADMP",.F.)  // Parametro integração entre Tabelas GH e PLS 
local oBDR        := oModel:getmodel("BDRMASTER")
Local nOpc        := oModel:GetOperation()
local LNovGD0     := .T. 
local nRec        := 0

FwFormCommit(oModel) //Realiza a gravação dos submodelos
nRec := BDR->(Recno()) //Retorna o número do registro corrente de uma área de trabalho 

If nOpc == 3 // Inclusão
	if lAtivoSinc 
		If  ! Empty(oBDR:getValue('BDR_CODTAD')) //Empty enquanto não estiver vazio!
			GD0->(DbSetOrder(1)) 
			LNovGD0 := (GD0->(MsSeek(xFilial("GD0")+(oBDR:getValue('BDR_CODTAD')))))
		Endif
	Endif
	
	If  ! LNovGD0
		PLGRVGD0(nOpc, (oBDR:getValue('BDR_DESCRI')) , (oBDR:getValue('BDR_CODTAD')) , (oBDR:getValue('BDR_CARINT'))) 
	Endif
	
ElseIf nOpc == 4 //Alteração
	If lAtivoSinc
		GD0->(DbSetOrder(1))
		If BDR->(FieldPos("BDR_REFIGH"))>0
			If ! Empty(oBDR:getValue('BDR_REFIGH')) .and. GD0->(MsSeek(xFilial("GD0")+oBDR:getValue('BDR_REFIGH')))
				lAchou:= HS_VEAA5() // Função chamada no Gestão hospitalar para Validação de Sincronismo	 
			Else
				lAchou:= GD0->(MsSeek(xFilial("GD0")+oBDR:getValue('BDR_CODTAD')))
			Endif 

			If lAchou
			 	PLGRVGD0(nOpc, (oBDR:getValue('BDR_DESCRI')) , (oBDR:getValue('BDR_CODTAD')) , (oBDR:getValue('BDR_CARINT')))
			Endif
		Endif
	Endif

Elseif nOpc == 5 //Exclusão
 	If lAtivoSinc
		GD0->(DbSetOrder(1)) //BDR_FILIAL + BDR_CODOPE + BDR_CODTAD
		If GD0->(MsSeek(xFilial("GD0") + oBDR:getValue('BDR_CODTAD'))) .and. HS_VEAA5() 
			PLGRVGD0(nOpc, "" , "" , "" ) //Permite a inclusão ou alteração de um registro no alias informado
		Endif
	Endif
Endif

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLGRVGD0
Permite a inclusão ou alteração de um registro no alias informado.
@author Jullia Barros
@since 19/05/2023
@version P12
/*/
//-------------------------------------------------------------------
static function PLGRVGD0(nTipo, cDESCRI, cCODTAD , cCARINT) 
local lInclui := IIF( nTipo == 3 , .T. , .F.)

GD0->(RecLock("GD0", lInclui ))  
	if ntipo == 5
		GD0->(DbDelete())
	else
		GD0->GD0_FILIAL := xFilial("GD0")
		GD0->GD0_ORIPAC := cCODTAD
		GD0->GD0_DORIPA := cDESCRI
		GD0->GD0_CARINT := cCARINT
		GD0->GD0_LOGARQ := HS_LOGARQ()
	ENDIF
GD0->(MsUnlock()) 
RETURN



