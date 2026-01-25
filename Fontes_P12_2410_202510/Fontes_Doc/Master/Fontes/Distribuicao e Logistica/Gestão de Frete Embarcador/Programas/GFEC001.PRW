#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'  
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC001
Painel Transportador
Generico

@sample
GFEC001()

@author Felipe M. / Alan Victor Lamb
@since 03/05/12
@version 1.0                                                                                      
/*/ 

//------------------------------------------------------------------------------------------------
Function GFEC001()                                                                                                       
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GU3")							  // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC001")				      // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Painel Transportador") // Descrição do browse   
	oBrowse:SetFilterDefault("GU3->GU3_TRANSP == '1' .OR. GU3->GU3_AUTON == '1'")
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:Activate()
Return Nil 

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina  := {}
	ADD OPTION aRotina TITLE "Visualizar"  		ACTION "VIEWDEF.GFEA015" 		OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE "Parâmetros"    	ACTION "Pergunte('GFEC001')" 	OPERATION 4 ACCESS 0  
	ADD OPTION aRotina TITLE "Recursos"    		ACTION "GFEC001OPC(1)" 	    	OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Doc Cargas" 		ACTION "GFEC001OPC(2)" 	    	OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Romaneios"    	ACTION "GFEC001OPC(3)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Agendamentos"		ACTION "GFEC001OPC(4)" 	 		OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Reprovações"		ACTION "GFEC001OPC(14)" 	 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Entregas"	    	ACTION "GFEC001OPC(5)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Ocorrências"    	ACTION "GFEC001OPC(6)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Doc Fretes"    	ACTION "GFEC001OPC(7)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Pré-Faturas"	   	ACTION "GFEC001OPC(8)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Faturas"	    	ACTION "GFEC001OPC(9)" 	 		OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Contratos"    	ACTION "GFEC001OPC(10)" 	 	OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Despesas"     	ACTION "GFEC001OPC(11)" 	 	OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Negociações"    	ACTION "GFEC001OPC(12)" 	 	OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE "Estatísticas"		ACTION "GFEC001OPC(13)" 	 	OPERATION 2 ACCESS 0
Return aRotina

//Opções das Ações Relacionadas
Function GFEC001OPC(nOpc)
	Local aParam := {}
	Private dDataNeg := Date()

	If nOpc != 1
		Pergunte('GFEC001',.F.)
		aADD(aParam,MV_PAR01)		//Filial de
		aADD(aParam,MV_PAR02)		//Filial ate
		aADD(aParam,MV_PAR03)		//Data de
		aADD(aParam,MV_PAR04)		//Data ate
		aADD(aParam,GU3->GU3_CDEMIT)//Emitente
	EndIf

	Do Case
		// Recursos
		Case nOpc == 1
		GFEC001A()

		//Doc Carga
		Case nOpc == 2
		GFEC001B(aParam)

		//Romaneios
		Case nOpc == 3
		GFEC001C(aParam)

		//Agendamentos
		Case nOpc == 4
		GFEC001D(aParam)  

		//Entregas
		Case nOpc == 5
		GFEC001E(aParam)

		//Ocorrências
		Case nOpc == 6
		GFEC001F(aParam)

		//Doc Fretes
		Case nOpc == 7
		If GU3->GU3_AUTON == '1'
			MsgStop("Opção de Documentos de Frete não disponível para transportadores autônomos")
		Else
			GFEC001G(aParam)
		EndIf

		//Pré Faturas
		Case nOpc == 8
		If GU3->GU3_AUTON == '1'
			MsgStop("Opção de Pré-Faturas não disponível para transportadores autônomos")
		Else
			GFEC001H(aParam)
		EndIf

		//Faturas
		Case nOpc == 9
		If GU3->GU3_AUTON == '1'
			MsgStop("Opção de Faturas não disponível para transportadores autônomos")
		Else
			GFEC001I(aParam)
		EndIf

		//Contratos
		Case nOpc == 10
		If GU3->GU3_AUTON == '1'
			GFEC001J(aParam)
		Else
			MsgStop("Opção de contratos disponível apenas para transportadores autônomos")
		EndIf

		//Despesas
		Case nOpc == 11
		If GU3->GU3_AUTON == '1'
			GFEC001N(aParam) // Transportadores Autonomos	
		Else
			GFEC001K(aParam) // Demais Transportadores
		EndIf

		//Negociações
		Case nOpc == 12
		If InfData()
			GFEC001L(aParam, dDataNeg)
		EndIf

		//Estatísticas
		Case nOpc == 13
		GFEC001M(aParam)

		//Reprovações
		Case nOpc == 14
		GFEC001O(aParam)
	EndCase
Return

//
// Função para usuário informar a data base das negociações
//
Static Function InfData()
	Local oDlg
	Local oSay
	Local oGet
	Local oButton
	Local lConfirma := .F.

	DEFINE MSDIALOG oDlg TITLE "Informe a data" From 0,0 To 105,220 Pixel OF oMainWnd

	oSay := tSay():New(11,2,{||"Data base negociações"},oDlg,,,,,,.T.,,,80,20)
	oGet := tGet():New(10,60,{|u| if(PCount()>0,dDataNeg:=u,dDataNeg)},oDlg,50,10,,,,,,,,.T.,,,,,,,,,,"dDataNeg")

	oButton := tButton():New(40,45,"Aplicar",oDlg,{||lConfirma:=.T.,oDlg:End()},30,10,,,,.T.)
	oButton := tButton():New(40,80,"Cancelar",oDlg,{||oDlg:End()},30,10,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED	
Return lConfirma
