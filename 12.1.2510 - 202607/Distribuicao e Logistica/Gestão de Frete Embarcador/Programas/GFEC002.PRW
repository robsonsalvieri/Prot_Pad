#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//---------------------------------------------------------------------------------------------------
/*/
{Protheus.doc} GFEC002
Painel Filiais
Generico

@sample
GFEC002()

@author Alan Victor Lamb
@since 28/06/13
@version 1.0                                                                                      
*/
//------------------------------------------------------------------------------------------------
Function GFEC002()                                              
	Local oBrowse
	Local nCount
	Local aStruct := {}
	Local aFiliais := {}
	
	//Array principal com os campos
	aCampos := {{"Código Filial"   ,"M0_CODFIL"   	,"C",TamSX3("GW1_FILIAL")[1],0,"",1,TamSX3("GW1_FILIAL")[1]},;
				{"Nome Filial"	   ,"M0_FILIAL"	,"C",25,0, ""},;
				{"Nome Comercial"  ,"M0_NOMECOM"    ,"C",25,0, ""  },;
	            {"Cid. de Entrega" ,"M0_CIDENT"     ,"C",15,0, ""  },;
	            {"UF de Entrega"   ,"M0_ESTENT"     ,"C",2 ,0, ""  }}
	             
	For nCount := 1 To Len(aCampos)
		aADD(aStruct,{ aCampos[nCount][1],;
					   aCampos[nCount][2],;
					   aCampos[nCount][3],;
					   aCampos[nCount][4],;
					   aCampos[nCount][5],;
					   aCampos[nCount][6]})
	Next nCont
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SM0")					   // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC002")			   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Painel Filiais") // Descrição do browse   
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:DisableDetails()
	oBrowse:SetTemporary(.T.)
	oBrowse:SetFields(aStruct)
	oBrowse:Activate()
Return Nil 

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina  := {}
	ADD OPTION aRotina TITLE "Parâmetros"    	ACTION "Pergunte('GFEC0021')" 	OPERATION 2 ACCESS 0  
	ADD OPTION aRotina TITLE "Doc Cargas" 		ACTION "GFEC002OPC(1)" 	    	OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Romaneios"    	ACTION "GFEC002OPC(2)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Agendamentos"    ACTION "GFEC002OPC(3)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Ocorrências"    	ACTION "GFEC002OPC(4)" 	 		OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Entregas"	    	ACTION "GFEC002OPC(5)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Doc Fretes"    	ACTION "GFEC002OPC(6)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Pré-Faturas"	   	ACTION "GFEC002OPC(7)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Faturas"	    	ACTION "GFEC002OPC(8)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Contratos"    	ACTION "GFEC002OPC(9)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Despesas"     	ACTION "GFEC002OPC(10)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Estatísticas"    ACTION "GFEC002OPC(11)" 	 		OPERATION 2 ACCESS 0
Return aRotina

//Opções das Ações Relacionadas
Function GFEC002OPC(nOpc)
	Local aParam := {}
	Private dDataNeg := Date()
	
	Pergunte('GFEC0021',.F.)
	aADD(aParam,MV_PAR01)		//Data de
	aADD(aParam,MV_PAR02)		//Data ate
	aADD(aParam,SM0->M0_CODFIL)//Emitente
	
	Do Case
		//Doc Carga
		Case nOpc == 1
			GFEC002A(aParam)
		
		//Romaneios
		Case nOpc == 2
			GFEC002B(aParam)
			
		//Agendamentos
		Case nOpc == 3
			GFEC002C(aParam)
		
		//Ocorrências
		Case nOpc == 4
			GFEC002E(aParam)
		
		//Entregas
		Case nOpc == 5
			GFEC002D(aParam)
		
		//Doc Fretes
		Case nOpc == 6
			GFEC002F(aParam)
			
		//Pré Faturas
		Case nOpc == 7
			GFEC002G(aParam)
		
		//Faturas
		Case nOpc == 8
			GFEC002H(aParam)
		
		//Contratos
		Case nOpc == 9
			GFEC002I(aParam)
		
		// Despesas
		Case nOpc == 10
			GFEC002J(aParam)
		
		//Estatísticas
		Case nOpc == 11
			GFEC002K(aParam)
	EndCase
	
Return