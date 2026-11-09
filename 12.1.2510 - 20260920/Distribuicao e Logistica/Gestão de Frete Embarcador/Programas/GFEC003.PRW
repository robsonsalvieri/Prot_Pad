#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC003
Painel Clientes
Generico

@sample
GFEC003()

@author Alan Victor Lamb
@since 02/07/13
@version 1.0                                                                                      
*/
//------------------------------------------------------------------------------------------------
Function GFEC003()                      
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GU3")					   // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC003")			   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Painel Clientes")// Descrição do browse   
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:DisableDetails()
	oBrowse:SetFilterDefault("GU3_CLIEN == '1'")
	oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina  := {}
	ADD OPTION aRotina TITLE "Parâmetros"    	ACTION "Pergunte('GFEC003')" 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 		ACTION "VIEWDEF.GFEA015"	    	OPERATION 2 ACCESS 0  
	ADD OPTION aRotina TITLE "Doc Cargas" 		ACTION "GFEC003OPC(1)" 	    	OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Ocorrências"    	ACTION "GFEC003OPC(2)" 	 		OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Estatísticas"    ACTION "GFEC003OPC(3)" 	 		OPERATION 2 ACCESS 0
Return aRotina

//Opções das Ações Relacionadas
Function GFEC003OPC(nOpc)
	Local aParam := {}
	Private dDataNeg := Date()
	
	Pergunte('GFEC003',.F.)
	aADD(aParam,MV_PAR01)		//Filial de
	aADD(aParam,MV_PAR02)		//Filial ate
	aADD(aParam,MV_PAR03)		//Data de
	aADD(aParam,MV_PAR04)		//Data ate
	aADD(aParam,GU3->GU3_CDEMIT)//Emitente
	
	Do Case
		//Doc Carga
		Case nOpc == 1
			GFEC003A(aParam)
		
		//Ocorrências
		Case nOpc == 2
			GFEC003B(aParam)

		//Estatísticas
		Case nOpc == 3
			GFEC003C(aParam)
	EndCase
Return