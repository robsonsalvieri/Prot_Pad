#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC512
Painel de Motoristas
Generico

@sample
GFEC512()

@author Helder Fuckner dos Santos
@since 17/04/14
@version 1.0                                                                                      
/*/
//------------------------------------------------------------------------------------------------
Function GFEC512()
	Private oBrowse512

	oBrowse512 := FWMBrowse():New()
	oBrowse512:SetAlias("GUU")								// Alias da tabela utilizada
	oBrowse512:SetMenuDef("GFEC512")			      		// Nome do fonte onde esta a função MenuDef
	oBrowse512:SetDescription("Painel de Motoristas") 	// Descrição do browse   
	oBrowse512:SetWalkthru(.F.)
	oBrowse512:SetAmbiente(.F.)
	oBrowse512:DisableDetails()
	oBrowse512:Activate()
Return Nil

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Parâmetros"    			ACTION "Pergunte('GFEC512')"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Movimentação"    		ACTION "GFEC512OPC()"			OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE "Consultar Motorista" 	ACTION "VIEWDEF.GFEA012"			OPERATION 2 ACCESS 0 //"Consultar Veículo"
Return aRotina

//Opções das Ações Relacionadas
Function GFEC512OPC()
	Local aParam := {}
	Private dDataNeg := Date()
	
	Pergunte('GFEC512',.F.)
	
	aADD(aParam,MV_PAR01)		// Filial de
	aADD(aParam,MV_PAR02)		// Filial ate
	aADD(aParam,MV_PAR03)		// Data de
	aADD(aParam,MV_PAR04)		// Data ate
	aADD(aParam,MV_PAR05)		// Emitente (Transportador) TAMANHO = 14

	GFEC512A(aParam)

Return
