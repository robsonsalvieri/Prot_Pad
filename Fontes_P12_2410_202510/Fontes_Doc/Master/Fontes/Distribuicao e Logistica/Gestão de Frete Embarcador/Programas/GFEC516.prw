#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} GFEC516
Rotina para visualização de filas por endereço

@author Alexandre José Cuchi	
@since 06/05/2014
@version 1.0
/*/

Function GFEC516()
	Local oBrowseT 		
	Local aCampos     := {} // Array para campos da tabela temporária e campos da View
	Private cCmpAlias := "" // Variavel para armazenar o alias da tabela temporaria
	// Criando tabela temporária
	aCampos :=	{;
				  {"TMP_FILIAL"	,"C",TamSX3("GVD_FILIAL")[1],0},;// Filial do sistema
				  {"TMP_CDENDE"	,"C",TamSX3("GVD_CDENDE")[1],0},;// Código do Endereço
				  {"TMP_ORDEM"	,"C",08		 		    	,0},;// Ordem dos campos
				  {"TMP_TPREG"	,"L",01 				    	,0},;// Tipo do campo, .T. para Pai, .F. para Filho
				  {"TMP_DESCRI"	,"C",TamSX3("GVD_DSENDE")[1],0},;// Descrição do registro
				  {"TMP_CDPTCT"	,"C",TamSX3("GVK_CDPTCT")[1],0},;// Código do ponto de controle
				  {"TMP_SEQ"		,"C",TamSX3("GX5_SEQ"   )[1],0},;// Número da posição
				  {"TMP_PLACA"	,"C",TamSX3("GU8_PLACA" )[1],0},;// Número da placa
				  {"TMP_DTENT" 	,"C",10        		    	,0} ;// Data de entrada
				} 	
	cCmpAlias := GFECriaTab({aCampos,{"TMP_ORDEM"}})
	// Criado tabela de visualização no browse
	aCampos := {;
				 	{"Nr Movimento" ,"TMP_DESCRI" ,"C",50,0,""}   ,;// Descrição do registro
				 	{"Pto Controle" ,"TMP_CDPTCT" ,"C",15,0,""}   ,;// Código do ponto de controle
				 	{"Posição"		  ,"TMP_SEQ"	  ,"C",15,0,"999"},;// Número da posição
				 	{"Veículo"		  ,"TMP_PLACA"  ,"C",12,0,""}   ,;// Número da placa
				 	{"Data Entrada" ,"TMP_DTENT"  ,"C",10,0,""}    ;// Data de entrada
				 }
	MontaTab() // Função que carrega a tabela com as informações
	// Criação do browse de tela
	oBrowseT := FWMBrowse():New()
	oBrowseT:SetTemporary(.T.) 
	oBrowseT:DisableDetails()
	oBrowseT:SetFixedBrowse(.T.)
	oBrowseT:SetAlias(cCmpAlias)
	oBrowseT:SetFields(aCampos)
	oBrowseT:SetMenuDef("")
	oBrowseT:ForceQuitButton()
	oBrowseT:AddButton("Consultar Endereço",{||ConsultEnd()}) // Botão de consulta de endereços
	oBrowseT:SetGroup({|| (cCmpAlias)->TMP_TPREG}, .T.) 
	oBrowseT:SetDescription("Monitor de Filas")
	oBrowseT:Activate()
	// Deletando a tabela temporária
	GFEDelTab(cCmpAlias)	
Return 
/**************************
Função para colocar iformaçoes na tabela temporaria

***************************/
Static Function MontaTab()
	Local nCont := 0 // Contador para ordem da tabela
	Local nContMov := 0 // Contador para quantidade de movimentos registrados em cada endereço 
	Local cPictPlaca := PesqPict('GU8','GU8_PLACA')
	
	dbSelectArea("GVD")
	GVD->( dbSetOrder(1) )
	
	// Posicionando na tabela de filas de endereço  de mercadoria
	If GVD->( dbSeek( xFilial("GVD") ) )
		dbSelectArea(cCmpAlias)
		(cCmpAlias)->( dbSetOrder(1) )
		(cCmpAlias)->( dbGoTop() )
		
		While !GVD->( EoF() ) .And. GVD->GVD_FILIAL == xFilial("GVD")
			nCont++
			// Adicionado endereço 
			RecLock(cCmpAlias,.T.)
				(cCmpAlias)->TMP_FILIAL := GVD->GVD_FILIAL
				(cCmpAlias)->TMP_CDENDE := GVD->GVD_CDENDE
				(cCmpAlias)->TMP_ORDEM  := StrZero(nCont, 8)
				(cCmpAlias)->TMP_TPREG  := .T.
				(cCmpAlias)->TMP_DESCRI := GVD->GVD_DSENDE
			(cCmpAlias)->(MsUnlock())
			
			dbSelectArea("GVK")
			GVK->( dbSetOrder(1) )
			
			// posicionando na tabela de filas de endereço  de mercadoria
			If GVK->( dbSeek(GVD->GVD_FILIAL + GVD->GVD_CDENDE) )
				dbSelectArea("GX6")
				GX6->( dbSetOrder(1) )
				
				dbSelectArea("GU8")
				GU8->( dbSetOrder(1) )
				
				dbSelectArea("GX5")
				GX5->( dbSetOrder(1) )
				
				nContMov := 0 // Zerar o contador para cada movimentação 
				While !GVK->( Eof() ) .And. GVK->GVK_FILIAL == GVD->GVD_FILIAL;
										 .And. GVK->GVK_CDENDE == GVD->GVD_CDENDE
					
					// Adicionado movimentações do endereço.
					RecLock(cCmpAlias,.T.)
						nCont++
						nContMov++
						(cCmpAlias)->TMP_FILIAL := GVD->GVD_FILIAL
						(cCmpAlias)->TMP_CDENDE := GVD->GVD_CDENDE
						(cCmpAlias)->TMP_ORDEM  := StrZero(nCont, 8)
						(cCmpAlias)->TMP_TPREG  := .F.
						(cCmpAlias)->TMP_DESCRI := GVK->GVK_NRMOV
						(cCmpAlias)->TMP_CDPTCT := GVK->GVK_CDPTCT 
						(cCmpAlias)->TMP_SEQ	   := GVK->GVK_SEQ		
						// Posicionando a tabela de movimentações
						If GX6->( dbSeek(GVD->GVD_FILIAL + GVK->GVK_NRMOV) ) 
							// Data de entrada do veiculo
							If !Empty(GX6->GX6_DTENTR)
								(cCmpAlias)->TMP_DTENT := DToC(GX6->GX6_DTENTR)
							EndIf
							// Pegando a placa do veiculo relacionado a movimentação
							If GU8->(dbSeek(xFilial("GU8") + GX6->GX6_CDVEIC))
								(cCmpAlias)->TMP_PLACA:= Transform(GU8->GU8_PLACA,cPictPlaca)
							EndIf
						EndIf
					(cCmpAlias)->(MsUnlock())
					GVK->(dbSkip())
				EndDo
			EndIf
			
			nCont++
			// Registro informando quantos lugares estão disponiveis na fila
			RecLock(cCmpAlias,.T.)
				(cCmpAlias)->TMP_FILIAL := GVD->GVD_FILIAL
				(cCmpAlias)->TMP_CDENDE := GVD->GVD_CDENDE
				(cCmpAlias)->TMP_ORDEM  := StrZero(nCont, 8)
				(cCmpAlias)->TMP_TPREG  := .F.
				(cCmpAlias)->TMP_DESCRI := ("Lugares disponíveis na fila: " + PadL((Val(GVD->GVD_QTPOFI) - nContMov),2,'0'))
			(cCmpAlias)->(MsUnlock())
			GVD->( dbSkip() )
		EndDo
	EndIf
Return
/*****************
Função para consulta de endereço
*****************/
Static Function ConsultEnd()
	Local aAreaGVD := GVD->(GetArea())
	
	dbSelectArea("GVD")
	GVD->(dbSetOrder(1))
		
	If GVD->( dbSeek((cCmpAlias)->TMP_FILIAL+(cCmpAlias)->TMP_CDENDE))
		FwExecView("Consulta de Endereço","GFEC517",MODEL_OPERATION_VIEW)
	Else	
		Help( ,,'VAZIO',,"Registro não encontrado", 1, 0,)
	EndIf
	RestArea(aAreaGVD)
Return