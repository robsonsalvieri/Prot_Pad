#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC021
Curva ABC Transportador por Cargas
Uso Interno

@author Felipe Mendes
@since 07/05/12
@version 1.0                                                                                      
/*/
//--------------------------------------------------------------------------------------       
Function GFEC021()
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Curva ABC de Transportadores por Movimentação de Carga'   
	Local aParam := Array(7) // Armazena os valores do Pergunte
	Private oTree
	Private cAlias_Inf // Alias que conterá a tabela com todas as informações
	Private cNodeTree := "EXP_PeB"	 //Variavel responsavel por armazenar o nó atual,
	Private oPnl_PeB,   oGrf_PeB,;  //objetos do "Peso Bruto Carga"
			 oPnl_VlC,   oGrf_VlC,;  //objetos do "Valor Carga"
			 oPnl_VoC,   oGrf_VoC,;  //objetos do "Volume Carga"
			 oPnl_QdV,   oGrf_QdV,;  //objetos do "Qtde Volumes"
		 	 oPnl_Rom ,  oGrf_Rom,;  //objetos do "Romaneios"
			 oPnl_Ent,   oGrf_Ent    //objetos do "Entregas"
	
	Private nTopGraf := 10
	Private oBrowse
	
	//Array principal que contém todos os campos e suas definições
	Private aGFEC021 := ;
	{{"Transp."						,"GU3_CDEMIT"	,"C",14,0,"",1					} ,;  //Cod do transportador
	{"Nome do Transp."				,"GU3_NMEMIT"	,"C",50,0,"",1					} ,;  //Nome do transp
	{"Peso Bruto"  			    	,"SUM_PER"   	,"N",15,4,"@E 999,999,999.99999",2} ,;  //Soma do peso real
	{"%"	                            ,"SUM_PER_PE" ,"N",6 ,2,"@E 999.99",2} 			,;    //Percentual - Soma do peso real
	{"% Acum"	                        ,"SUM_PER_PA" ,"N",6 ,2,"@E 999.99",2} 			,;    //Percentual Acumulado - Soma do peso real
	{"Class"	                        ,"SUM_PER_CL" ,"C",1 ,2,"",0					},;    //Classificação - Soma do peso real
	{"Valor Carga"				    ,"SUM_VAL"    ,"N",15,4,"@E 999,999,999.99",2} ,;  //Soma do valor dos itens
	{"%"	                            ,"SUM_VAL_PE" ,"N",6 ,2,"@E 999.99",2} 			,;    //Percentual - Soma do valor dos itens
	{"% Acum"	                        ,"SUM_VAL_PA" ,"N",6 ,2,"@E 999.99",2} 			,;    //Percentual Acumulado - Soma do valor dos itens
	{"Class"	                        ,"SUM_VAL_CL" ,"C",1 ,2,"",0					},;    //Classificação- Soma do valor dos itens
	{"Volume Carga"				    ,"SUM_VOL"    ,"N",15,4,"@E 999,999,999.99999",2} ,;  //soma dos volumes dos itens
	{"%"		                        ,"SUM_VOL_PE" ,"N",6 ,2,"@E 999.99",2} 			,;    //Percentual - soma dos volumes dos itens
	{"% Acum"		                    ,"SUM_VOL_PA" ,"N",6 ,2,"@E 999.99",2} 			,;    //Percentual Acumulado - soma dos volumes dos itens
	{"Class"			                ,"SUM_VOL_CL" ,"C",1 ,2,"",0					},;    //Classificação - soma dos volumes dos itens
	{"Qtde Volumes"		            ,"SUM_QTD"    ,"N",15,4,"@E 999,999,999",2} ,;  //soma da quantidade dos itens
	{"%"		                        ,"SUM_QTD_PE" ,"N",6 ,2,"@E 999.99",2} 			,;    //Percentual - soma da quantidade dos itens
	{"% Acum"		                    ,"SUM_QTD_PA" ,"N",6 ,2,"@E 999.99",2} 			,;    //Percentual Acumulado - soma da quantidade dos itens
	{"Class"	   		                ,"SUM_QTD_CL" ,"C",1 ,2,"",0					},;    //Classificação - soma da quantidade dos itens
	{"Qtde Romaneios"					,"TOT_ROM"    ,"N",15,0,"@E 999,999,999",2} ,;  //total de romaneios
	{"%"			                    ,"TOT_ROM_PE" ,"N",6 ,2,"@E 999.99",2}			 ,;   //Percentual - total de romaneios
	{"% Acum"			                ,"TOT_ROM_PA" ,"N",6 ,2,"@E 999.99",2}			 ,;   //Percentual Acumulado - total de romaneios
	{"Class"		   		            ,"TOT_ROM_CL" ,"C",1 ,2,"",0					},;   //Classificação - total de romaneios
	{"Qtde Entregas"					,"TOT_ENT"    ,"N",15,0,"@E 999,999,999",2},;   //total de entregas
	{"%"		                        ,"TOT_ENT_PE" ,"N",6 ,2,"@E 999.99",2}			 ,;   //Percentual  - total de Entregas
	{"% Acum"			                ,"TOT_ENT_PA" ,"N",6 ,2,"@E 999.99",2}			 ,;   //Percentual Acumulado   - total de entregas
	{"Class"		   		            ,"TOT_ENT_CL" ,"C",1 ,2,"",0					},;   //Classificação - total de entregas
	{"Grupo Tranp"		   		    ,"GU3_CDGRGL" ,"C",4 ,0,"@!",1					},;
	{"Descrição Grupo"		   		,"GU1_DSGREM" ,"C",50,0,"@!",1					}}
	
	If !Pergunte("GFEC021")
		Return
	Else	
		aParam[1] := MV_PAR01 //Filial de
		aParam[2] := MV_PAR02 //Filial ate
		aParam[3] := MV_PAR03	 //Data de
		aParam[4] := MV_PAR04	 //Data ate  
		aParam[5] := MV_PAR05	 //% de corte A  
		aParam[6] := MV_PAR06	 //% de corte B
		aParam[7] := MV_PAR07	 //Qtde séries
	EndIf
 	
 	nTopGraf := aParam[7]
 	
	//Cria a tabela
	cAlias_Inf := CriaTab()    
	
	//Alimenta a tabela com as informações (não necessita informar o Alias, pois a variavel é Private)
	Processa({||QuerySQL(aParam)}, "Carregando dados da Curva ABC", "Aguarde...")
	Processa({||Percentual(aParam[5],aParam[6])}, "Gerando Curva ABC", "Aguarde...")
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel     

	/*Criando objeto Layer*/
	oFWLayer := FWLayer():New() // Método de criação do objeto da classe.
	oFWLayer:Init(oDLG, .F.)  				   					
	
	/***Criando coluna esquerda (Tree)****/
	oFWLayer:AddLine( 'LINE_TOP', 50, .F. ) 							
	oFWLayer:AddCollumn( 'COL_TOP_LEFT'  , 20, .T., 'LINE_TOP' ) 			
	oFWLayer:AddWindow('COL_TOP_LEFT','WIN_TOP_LEFT','Sumário',100,.T.,.F.,,'LINE_TOP',)
    oWIN_TOP_LEFT := oFWLayer:getWinPanel('COL_TOP_LEFT','WIN_TOP_LEFT', 'LINE_TOP')
	
	/***Criando coluna direita (Browse)****/	
	oFWLayer:AddCollumn( 'COL_TOP_RIGHT'  , 80, .T., 'LINE_TOP' ) 			
	oWIN_TOP_RIGHT := oFWLayer:GetColPanel( 'COL_TOP_RIGHT' , 'LINE_TOP' ) 			
   
 	/***Criando Linha abaixo (Grafico)****/
   	oFWLayer:AddLine( 'LINE_BOTTOM', 50, .F. ) 					   		
	oFWLayer:AddCollumn( 'COL_BOTTOM'  , 100, .T., 'LINE_BOTTOM' ) 			
	oFWLayer:AddWindow('COL_BOTTOM','WIN_BOTTOM','Gráfico',100,.T.,.F.,,'LINE_BOTTOM',)
    oWIN_BOTTOM := oFWLayer:getWinPanel('COL_BOTTOM','WIN_BOTTOM', 'LINE_BOTTOM')
    
    CriaTree(oWIN_TOP_LEFT)
	CriaPaineis(oWIN_BOTTOM)
	CriaGrafico(cAlias_Inf)    
    CriaGrid(oWIN_TOP_RIGHT)    
	Activate MsDialog oDLG Center
	
	GFEDelTab(cAlias_Inf)
Return	
/*=====================================================================*/
Static Function CriaTab()
	Local cAlias
	Local nCont
	Local aStruct := {}
	               
	For nCont := 1 to Len(aGFEC021)
		aADD(aStruct,{aGFEC021[nCont][2],;  //Nome do campo
						aGFEC021[nCont][3],;  //Tipo
						aGFEC021[nCont][4],;  //Tamanho
						aGFEC021[nCont][5]}) //Decimal
	Next nCont
	
	cAlias := GFECriaTab({aStruct,{ "GU3_CDEMIT",;
										"STR(SUM_PER_PE)+GU3_CDEMIT",;
										"STR(SUM_VAL_PE)+GU3_CDEMIT",;
										"STR(SUM_VOL_PE)+GU3_CDEMIT",;
										"STR(SUM_QTD_PE)+GU3_CDEMIT",;
										"STR(TOT_ROM_PE)+GU3_CDEMIT",;
										"STR(TOT_ENT_PE)+GU3_CDEMIT",;
										"SUM_PER_CL+STR(SUM_PER_PA)+GU3_CDEMIT",;
										"SUM_VAL_CL+STR(SUM_VAL_PA)+GU3_CDEMIT",;
										"SUM_VOL_CL+STR(SUM_VOL_PA)+GU3_CDEMIT",;
										"SUM_QTD_CL+STR(SUM_QTD_PA)+GU3_CDEMIT",;
										"TOT_ROM_CL+STR(TOT_ROM_PA)+GU3_CDEMIT",;
										"TOT_ENT_CL+STR(TOT_ENT_PA)+GU3_CDEMIT"}})
Return cAlias        
//-------------------------------------------------------------------------------------------------
/*CriaTree()
Função que Cria a Tree
Uso Interno

As chaves de indicação dos itens devem seguir este padrão:
 [*] Nível superior
 	 3 Caracteres + '____'. Exemplo: DOC____
 [*] Sub-itens
 	3 Caracteres igual ao nível superior + número identificação. Exemplo DOC1111
 	
Estas instruções são necessárias pelas seguintes limitações:
- A função de evento de clique é uma só e retorna de forma geral a chave de identifcação do item selecionado,
assim, a função que trata o evento de seleção do item (clique) pode tratar qual item foi selecionado.
- A chave de identificação do sub-item é limitada a quantidade de caracteres do nível superior em que o item pertence

@author Felipe Mendes
@since 07/05/12
@version 1.0                                                                                      
*/
//------------------------------------------------------------------------------------------------ 
Static Function CriaTree(oDialog)    
    /* Cria o objeto Tree*/
    Local cBmp := "SDUCLOSE"
    Local cBmpOpen := "SDUOPEN"
	oFont := TFont():New('Arial',,-12,.T.)
	oTree := DbTree():New(0,0,0,0,oDialog,{||ChangeItem()},,.T.,,oFont)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT                                        
	
	/*Adiciona os Nós*/
	oTree:BeginUpdate()
	oTree:SetScroll(2, .T.) //Habilita rolagem vertical
	oTree:AddItem("Peso Bruto Carga","EXP_PeB",cBmp,cBmpOpen,,,1)
	oTree:AddItem("Valor Carga"	    ,"EXP_VlC",cBmp,cBmpOpen,,,1)
	oTree:AddItem("Volume Carga"	,"EXP_VoC",cBmp,cBmpOpen,,,1)
	oTree:AddItem("Qtde Volumes"	,"EXP_QdV",cBmp,cBmpOpen,,,1)
	oTree:AddItem("Qtde Romaneios"	,"EXP_Rom",cBmp,cBmpOpen,,,1)
	oTree:AddItem("Qtde Entregas"	,"EXP_Ent",cBmp,cBmpOpen,,,1)
	oTree:EndUpdate()
	oTree:TreeSeek("EXP_PeB")
Return  

//------------------------------------------------------------------------------------------------
/* CriaPaineis
Criação dos Painéis para os Graficos

	
@author Felipe Mendes
@since 14/05/12
@version 1.0
*/
//------------------------------------------------------------------------------------------------
Static Function CriaPaineis(oOwner)
	// Criação dos painéis dos graficos
	oPnl_PeB := tPanel():New(0,0,,oOwner,,,,,,0,0)
	oPnl_PeB:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_VlC := tPanel():New(0,0,,oOwner,,,,,,0,0)
	oPnl_VlC:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_VoC := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_VoC:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_QdV := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_QdV:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_Rom := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_Rom:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_Ent := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_Ent:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPanelAtual := oPnl_PeB 
	
  	oPnl_VlC:Hide()
	oPnl_VoC:Hide()
	oPnl_QdV:Hide()
	oPnl_Rom:Hide()
	oPnl_Ent:Hide()  
Return     
//=========================================================================/
//Função Responsavel por criar o Grafico.
//Parametros:  	oDialog = objeto conteiner do grafico
// 				cAlias = Alias da tabela
//				cCampo = Campo que será mostrado no grafico   
//Uso Restrito - Sem Retorno
//=========================================================================/
Static Function CriaGrafico(cAlias)  
	Local aGrafico := {}, nContGrf, nCont,nCont2, nOutrosTransp
	Local oTmpGrf, oTmpPnl
	Local aCorA, aCorB, aCorC, aCorOutros // Cores das barras conforme classificação
	Local aRand := {} // Nova paleta do gráfico
	
	//Array que contém a relação dos Paineis, campos, objetos graficos, título e picture do gráfico
	aArray := {{ "oPnl_PeB" ,"SUM_PER"   ,"oGrf_PeB", "Peso Bruto Carga", "@E 9999,999,999" },;
			   {  "oPnl_VlC" ,"SUM_VAL"   ,"oGrf_VlC", "Valor Carga", "@E 9999,999,999" },;
			   {  "oPnl_VoC" ,"SUM_VOL"   ,"oGrf_VoC", "Volume Carga", "@E 9999,999,999" },;
			   {  "oPnl_QdV" ,"SUM_QTD"   ,"oGrf_QdV", "Qtde Volumes", "@E 9999,999,999" },;
			   {  "oPnl_Rom" ,"TOT_ROM"   ,"oGrf_Rom", "Qtde Romaneios", "@E 9999,999,999" },;
			   {  "oPnl_Ent" ,"TOT_ENT"   ,"oGrf_Ent", "Qtde Entregas", "@E 9999,999,999" }}
    
	//Percorre o Array e cria dinamicamente todos os paineis.
	For nContGrf := 1 to Len(aArray)
		oTmpPnl := &(aArray[nContGrf][1])
		 
		oTmpGrf := FWChartFactory():New()   //Cria o objeto grafico em uma variavel temp
		oTmpGrf := oTmpGrf:getInstance(BARCHART)
		oTmpGrf:setTitle("Curva ABC " + aArray[nContGrf][4], CONTROL_ALIGN_CENTER)
		oTmpGrf:setPicture(aArray[nContGrf][5]) 
		oTmpGrf:setLegend(CONTROL_ALIGN_CENTER)
		
		oTmpGrf:Init(oTmpPnl,.T.,.T.)
		aGrafico := CriaArray(cAlias,aArray[nContGrf][2])
		
		/* Define as cores conforme a classificação */
		aCorA := oTmpGrf:oFWChartColor:aRandom[1] 
		aCorB := oTmpGrf:oFWChartColor:aRandom[2]
		aCorC := oTmpGrf:oFWChartColor:aRandom[3]
		aCorOutros := oTmpGrf:oFWChartColor:aRandom[4]
		 
		For nCont := 1 to Len(aGrafico)       
			//Verifica se há mais de 15 transp, caso haja, soma os transp restantes   
			If nCont > (nTopGraf - 1)
				//somando o resultado dos transp
				nOutrosTransp := 0 
				For nCont2 := nTopGraf to len(aGrafico)
					nOutrosTransp := nOutrosTransp + aGrafico[nCont2][2]
				Next nCont2
				
				oTmpGrf:AddSerie("Outros transportadores", nOutrosTransp) 
				AADD(aRand, aCorOutros) // Se "Outros", muda a cor da barra
				Exit			
			Else
				oTmpGrf:AddSerie( aGrafico[nCont][1], aGrafico[nCont][2])
				
				/* Monta a paleta de cores conforme a classificação da curva abc*/
				If AllTrim(aGrafico[nCont][3]) == "A"
					AADD(aRand, aCorA)
				ElseIf AllTrim(aGrafico[nCont][3]) == "B"
					AADD(aRand, aCorB)
				Else
					AADD(aRand, aCorC)
				EndIf
			EndIf      
		Next nCont  
		
		/* Modifica a paleta de cores do gráfico */
		oTmpGrf:oFWChartColor:aRandom := aRand
		oTmpGrf:oFWChartColor:SetColor("Random")
			
		oTmpGrf:Build()
		
		&(aArray[nContGrf][3]) := oTmpGrf //"copia" o objeto grafico no objeto certo
	Next nContGrf
Return    
//=========================================================================/
//Funcção Responsavel por criar o array ordenado para que as informações no Grafico 
//fiquem ordenadas do maior para o menor.
//Parametros:  	cAlias = Alias da tabela
//				cCampo = Campo que será mostrado no grafico   
//Uso Restrito - Retorna o array ordenado
//=========================================================================/
Static Function CriaArray(cAlias,cCampo)
	Local aStruct := {}
	
	//Transfere o conteudo da tabela para o array
	dbSelectArea(cAlias)
	dbGoTop()
	While (cAlias)->(!Eof())
	    AADD(aStruct, { ALLTRIM(Posicione("GU3", 1, xFilial("GU3") + (cAlias)->GU3_CDEMIT, "GU3_NMEMIT") ), (cAlias)->&(cCampo), (cAlias)->&(cCampo + "_CL") } )
		(cAlias)->(dbSkip())
	EndDo  
	
	aSORT(aStruct,,,{ |x,y| x[2] > y[2] }) //Ordena o array do maior para o menor
Return aStruct           
//=========================================================================/
Static Function CriaGrid(oDialog)
	Local nCont
	Local aCampos := aGFEC021
    
    (cAlias_Inf)->(dbSetOrder(8))
    
	oBrowse := FWMBrowse():New()  
	oBrowse:SetAlias(cAlias_Inf)	
	oBrowse:SetMenuDef('GFEC021')
	oBrowse:SetDescription("Transportadores") 
	
	For nCont := 1 to Len( aCampos )
		oBrowse:AddColumn( {aCampos[nCont][1],&("{|| (cAlias_Inf)->" + aCampos[nCont][2] + "}"),aCampos[nCont][3],aCampos[nCont][6],aCampos[nCont][7],aCampos[nCont][4],aCampos[nCont][5],.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{} } )
	Next nCont
	
	oBrowse:SetLocate()
 	oBrowse:SetOwner(oDialog)          
	oBrowse:DisableDetails()
	oBrowse:SetWidthColumns({7,30,7,2,2,2,7,2,2,2,7,2,2,2,7,2,2,2,7,2,2,2,7,2,2,2})
	oBrowse:ForceQuitButton(.T.)
   	oBrowse:Activate()
Return   
//=========================================================================/
Static Function MenuDef()   
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Visualizar" ACTION 'GFEC021EMI()'    OPERATION 1  ACCESS 0 //"Visualizar"
Return aRotina                                      
//=========================================================================/
Function GFEC021EMI()   
 	dbSelectArea("GU3")
	GU3->(dbSetOrder(1))
	If GU3->(dbSeek(xFilial("GU3")+(cAlias_Inf)->GU3_CDEMIT))
		FWExecView("Frete Embarcador",'GFEA015', 1, , {|| .F. },{|| .F.},,,{|| .T.}) 
	EndIf
Return	
//=========================================================================/
Static Function ChangeItem()    
	Local cTabela 	:= AllTrim(Substr(oTree:GetCargo(), 1, 3))
	Local cSubItem 	:= AllTrim(Substr(oTree:GetCargo(), 5, 3))
	Local oTmpPanel	
	Local aPeB := {3,4,5,6}
	Local aVlC := {7,8,9,10}
	Local aVoC := {11,12,13,14}
	Local aQdV := {15,16,17,18}
	Local aRom := {19,20,21,22}
	Local aEnt := {23,24,25,26}
	Local aPes
	
	CursorWait() 
	
    oTmpPanel := &( "oPnl_"+AllTrim(Substr(cNodeTree, 5, 3)) )  //Busca o objeto painel atual
    oTmpPanel:Hide()
    oTmpPanel := &( "oPnl_"+cSubItem)  //busca o objeto painel da opção selecionada
    oTmpPanel:Show()     
	
	Do Case
		Case cSubItem == "PeB"
			aPes := aPeB
			(cAlias_Inf)->(dbSetOrder(8))
		Case cSubItem == "VlC"
			aPes := aVlC
			(cAlias_Inf)->(dbSetOrder(9))
		Case cSubItem == "VoC"
			aPes := aVoC
			(cAlias_Inf)->(dbSetOrder(10))
		Case cSubItem == "QdV"
			aPes := aQdV
			(cAlias_Inf)->(dbSetOrder(11))
		Case cSubItem == "Rom"
			aPes := aRom
			(cAlias_Inf)->(dbSetOrder(12))
    	Case cSubItem == "Ent"
			aPes := aEnt
			(cAlias_Inf)->(dbSetOrder(13))
	EndCase
	
	oBrowse:SetColumnOrder(aPes[1], 3)
	oBrowse:SetColumnOrder(aPes[2], 4)
	oBrowse:SetColumnOrder(aPes[3], 5)
	oBrowse:SetColumnOrder(aPes[4], 6)
	
	oBrowse:UpdateBrowse()
	oBrowse:Refresh(.T.)
	
  	// Armazena o nó atual
	cNodeTree := oTree:GetCargo()  
	CursorArrow()
Return         
//=========================================================================/
Static Function QuerySQL(aParam)   
	Local cQuery := ''
	Local cTmp := ''
	
	cQuery += "  SELECT GU3.GU3_CDEMIT, GU3.GU3_CDGRGL, GU1.GU1_DSGREM, "
	cQuery += "         SUM(GW8.GW8_PESOR) SUM_PER,"
	cQuery += "         SUM(GW8.GW8_VALOR) SUM_VAL,"
	cQuery += "         SUM(GW8.GW8_VOLUME) SUM_VOL,"
	cQuery += "         SUM(GW8.GW8_QTDE) SUM_QTD,"
	cQuery += "         (SELECT COUNT(*) FROM " + RetSQLName( 'GWN' )  + " WHERE GWN_CDTRP = GU3_CDEMIT AND D_E_L_E_T_ =  ' ' AND " + SQLWhereQuery("GWN_FILIAL","GWN_DTIMPL",aParam)   + " ) TOT_ROM,"
	cQuery += "         ("
	cQuery += " 		   SELECT COUNT(*) FROM " + RetSQLName( 'GWU' ) + " GWU2 " 
	cQuery += " 		     JOIN " + RetSQLName( 'GW1' ) + " GW12 ON GW12.GW1_FILIAL = GWU2.GWU_FILIAL"
	cQuery += " 		 	                                     AND GW12.GW1_CDTPDC = GWU2.GWU_CDTPDC"  
	cQuery += " 		 	                                     AND GW12.GW1_EMISDC = GWU2.GWU_EMISDC" 
	cQuery += " 		 	                                     AND GW12.GW1_SERDC  = GWU2.GWU_SERDC"
	cQuery += " 		 	                                     AND GW12.GW1_NRDC   = GWU2.GWU_NRDC"
	cQuery += " 		    WHERE GU3_CDEMIT = GWU2.GWU_CDTRP"
	cQuery += "             AND GWU2.GWU_DTENT <> '' "
	cQuery += "             AND GWU2.D_E_L_E_T_ =  ' '"
	cQuery += " 	          AND GW12.D_E_L_E_T_ =  ' '"
	cQuery += "             AND " + SQLWhereQuery("GW1_FILIAL","GW1_DTEMIS",aParam)
	cQuery += "     	) TOT_ENT "
	cQuery += "   FROM " + RetSQLName( 'GW1' ) + " GW1"
	cQuery += "  INNER JOIN " + RetSQLName( 'GW8' )+ " GW8 ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
	cQuery += "				                             AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC" 
	cQuery += "				                             AND GW8.GW8_EMISDC = GW1.GW1_EMISDC"
	cQuery += "				                             AND GW8.GW8_SERDC  = GW1.GW1_SERDC"
	cQuery += "				                             AND GW8.GW8_NRDC   = GW1.GW1_NRDC"
	cQuery += "  INNER JOIN (   SELECT DISTINCT GWU2.GWU_CDTRP, " 
	cQuery += "                            GWU2.GWU_FILIAL, "
	cQuery += "                            GWU2.GWU_CDTPDC, "
	cQuery += "             					GWU2.GWU_EMISDC, "
	cQuery += "             					GWU2.GWU_SERDC, "
	cQuery += "             					GWU2.GWU_NRDC "
	cQuery += "        			  FROM " + RetSQLName( 'GWU' ) + " GWU2 WHERE GWU2.D_E_L_E_T_ =  ' ' ) GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL" 
	cQuery += "		                                   AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "		                                   AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
	cQuery += "		                                   AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
	cQuery += "		                                   AND GWU.GWU_NRDC   = GW1.GW1_NRDC"
	cQuery += "  INNER JOIN " + RetSQLName('GU3') + " GU3 ON GWU.GWU_CDTRP = GU3.GU3_CDEMIT"
	cQuery += "   LEFT JOIN " + RetSQLName('GU1') + " GU1 ON GU1.GU1_CDGREM = GU3.GU3_CDGRGL"
    cQuery += "                       AND GU1.D_E_L_E_T_ =  ' '"
	cQuery += "  WHERE (GU3.GU3_TRANSP = '1' OR GU3.GU3_AUTON = '1')"
	cQuery += "    AND GU3.D_E_L_E_T_ =  ' '"
    cQuery += "    AND GW1.D_E_L_E_T_ =  ' '"
    cQuery += "    AND GW8.D_E_L_E_T_ =  ' '"
	cQuery += "    AND " + SQLWhereQuery("GW1_FILIAL","GW1_DTEMIS",aParam)
	cQuery += "  GROUP BY GU3.GU3_CDEMIT, GU3.GU3_CDGRGL, GU1.GU1_DSGREM"

	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
	dbSelectArea(cTmp)
	dbGoTop()
	While (cTmp)->(!Eof())
		RecLock(cAlias_Inf, .T.)
		(cAlias_Inf)->GU3_CDEMIT  := (cTmp)->GU3_CDEMIT  													//transportador
		(cAlias_Inf)->GU3_NMEMIT  := Posicione("GU3", 1, xFilial("GU3") + (cTmp)->GU3_CDEMIT, "GU3_NMEMIT") //nome do transportador
		(cAlias_Inf)->GU3_CDGRGL  := (cTmp)->GU3_CDGRGL
        (cAlias_Inf)->GU1_DSGREM  := (cTmp)->GU1_DSGREM
		(cAlias_Inf)->SUM_PER     := (cTmp)->SUM_PER  //Soma do peso real total por transportador  																	
		(cAlias_Inf)->SUM_VAL     := (cTmp)->SUM_VAL  //Soma do valor total  por transportador  	
		(cAlias_Inf)->SUM_VOL     := (cTmp)->SUM_VOL  //Soma do volume total  por transportador  	  
		(cAlias_Inf)->SUM_QTD     := (cTmp)->SUM_QTD  //Soma da quantidad de itens total  por transportador  	
		(cAlias_Inf)->TOT_ROM     := (cTmp)->TOT_ROM  //total de romaneios por transportador  	
		(cAlias_Inf)->TOT_ENT     := (cTmp)->TOT_ENT  //total de entregas realizadas  
		MsUnlock()
		(cTmp)->(dbSkip())
	EndDo
	
	(cTmp)->(dbCloseArea())
Return 

/* ======================================================================================
Cria a clausula Where para as Query SQL
Param:
cCampoFilial - nome do campo filial
cCampoData - Nome do campo data
aParam - Array de 4 posições sendo [1] filial de, [2] filial até, [3]Data de, [4]Data ate
Return cWhere (clausula SQL Where)
======================================================================================= */                                   
Static Function SQLWhereQuery(cCampoFilial,cCampoData,aParam)
	Local cWhere
	
	cWhere := cCampoFilial + " >= '" +      aParam[1]  + "' AND " + cCampoFilial + " <= '" +      aParam[2]  + "' AND " + ; 
			   cCampoData   + " >= '" + DtoS(aParam[3]) + "' AND " + cCampoData   + " <= '" + DtoS(aParam[4]) + "' " 	
	
Return cWhere  

/* ======================================================================================
Calcula o Percentual e o Percentual Acumulado 

Return NULL
======================================================================================= */                     
Static Function Percentual(nCorteA,nCorteB)
	Local aTotal := Array(6), nCont
	Local aArea := (cAlias_Inf)->(GetArea())  
	Local lCorteA := .F. , lCorteB  := .F. // Variavel que indica se já foi classificado algum registro como A ou B
	Local nPPer := 0
	Local nPVal := 0
	Local nPVol := 0
	Local nPQtd := 0
	Local nPRom := 0
	Local nPEnt := 0
	
	AFILL(aTotal,0)
	
	dbSelectArea(cAlias_Inf)
	(cAlias_Inf)->(dbGoTop())
	While !((cAlias_Inf)->(Eof()))
		aTotal[1] := (cAlias_Inf)->SUM_PER + aTotal[1]
		aTotal[2] := (cAlias_Inf)->SUM_VAL + aTotal[2]
		aTotal[3] := (cAlias_Inf)->SUM_VOL + aTotal[3]
		aTotal[4] := (cAlias_Inf)->SUM_QTD + aTotal[4]
		aTotal[5] := (cAlias_Inf)->TOT_ROM + aTotal[5]
		aTotal[6] := (cAlias_Inf)->TOT_ENT + aTotal[6]
		
		(cAlias_Inf)->(dbSkip())
	EndDo                          
	
	dbSelectArea(cAlias_Inf)
	(cAlias_Inf)->(dbGoTop())
	While !( (cAlias_Inf)->(Eof()) )
		(cAlias_Inf)->SUM_PER_PE := ROUND(((cAlias_Inf)->SUM_PER * 100) / aTotal[1],2)
		(cAlias_Inf)->SUM_VAL_PE := ROUND(((cAlias_Inf)->SUM_VAL * 100) / aTotal[2],2)
		(cAlias_Inf)->SUM_VOL_PE := ROUND(((cAlias_Inf)->SUM_VOL * 100) / aTotal[3],2)
		(cAlias_Inf)->SUM_QTD_PE := ROUND(((cAlias_Inf)->SUM_QTD * 100) / aTotal[4],2)
		(cAlias_Inf)->TOT_ROM_PE := ROUND(((cAlias_Inf)->TOT_ROM * 100) / aTotal[5],2)
		(cAlias_Inf)->TOT_ENT_PE := ROUND(((cAlias_Inf)->TOT_ENT * 100) / aTotal[6],2)
		
		nPPer += (cAlias_Inf)->SUM_PER_PE
		nPVal += (cAlias_Inf)->SUM_VAL_PE
		nPVol += (cAlias_Inf)->SUM_VOL_PE
		nPQtd += (cAlias_Inf)->SUM_QTD_PE
		nPRom += (cAlias_Inf)->TOT_ROM_PE
		nPEnt += (cAlias_Inf)->TOT_ENT_PE
		
		(cAlias_Inf)->(dbSkip())
	EndDo                          
	
	/* Correção dos percentuais */
	AjusPerc(2, "SUM_PER_PE", nPPer)
	AjusPerc(3, "SUM_VAL_PE", nPVal)
	AjusPerc(4, "SUM_VOL_PE", nPVol)
	AjusPerc(5, "SUM_QTD_PE", nPQtd)
	AjusPerc(6, "TOT_ROM_PE", nPRom)
	AjusPerc(7, "TOT_ENT_PE", nPEnt)
	
	//Array com a relação dos indices e campos para armazenas o Percentual Acumulado
	aArray :={{2,"SUM_PER_PE","SUM_PER_PA","SUM_PER_CL"},;
	          {3,"SUM_VAL_PE","SUM_VAL_PA","SUM_VAL_CL"},;
	          {4,"SUM_VOL_PE","SUM_VOL_PA","SUM_VOL_CL"},;
	          {5,"SUM_QTD_PE","SUM_QTD_PA","SUM_QTD_CL"},;
	          {6,"TOT_ROM_PE","TOT_ROM_PA","TOT_ROM_CL"},;
	          {7,"TOT_ENT_PE","TOT_ENT_PA","TOT_ENT_CL"}} 
	          
	For nCont := 1 to Len(aArray)
		//Variavel responsavel por acumular o percentual 
		nPercAcum := 0 
	    lCorteA := .F.   
	    lCorteB := .F.
		dbSelectArea(cAlias_Inf)
	    dbSetOrder(aArray[nCont][1])  //Set o indice correspondente 
		dbGoBottom()  // ordena a tabela do maior para o menor
		While !Bof() 
			nPercAcum := (cAlias_Inf)->&(aArray[nCont][2]) + nPercAcum   //Soma o percentual acumulado com o percentual do registro atual
			RecLock((cAlias_Inf),.F.)    
			(cAlias_Inf)->&(aArray[nCont][3])  := nPercAcum  //Atribui no registro o perc acum
			If (nPercAcum <= nCorteA .AND. (cAlias_Inf)->&(aArray[nCont][2]) != 0 ) .OR. (nPercAcum > nCorteA .AND. !lCorteA .AND. (cAlias_Inf)->&(aArray[nCont][2]) != 0 )
				(cAlias_Inf)->&(aArray[nCont][4])  := "A"  
				lCorteA := .T.
			ElseIf (nPercAcum <= nCorteB .AND. (cAlias_Inf)->&(aArray[nCont][2]) != 0 ) .OR. (nPercAcum > nCorteB .AND. !lCorteB .AND. (cAlias_Inf)->&(aArray[nCont][2]) != 0 )
				(cAlias_Inf)->&(aArray[nCont][4])  := "B"      
				lCorteB := .T.
			Else
				(cAlias_Inf)->&(aArray[nCont][4])  := "C"
			EndIf
			
			MsUnlock()
			dbSkip(-1)
		EndDo	
	Next nCont

	RestArea(aArea)   
Return	 

Static Function AjusPerc(nIndice, cCampo, nAcum)
	
	dbSelectArea(cAlias_Inf)
	(cAlias_Inf)->(dbSetOrder(nIndice))
	(cAlias_Inf)->(dbGoBottom())
	If !( (cAlias_Inf)->(Eof()) )
		RecLock((cAlias_Inf),.F.) 
		(cAlias_Inf)->&(cCampo) := (cAlias_Inf)->&(cCampo) + (100 - nAcum)
		MsUnlock()
	EndIf
	
Return Nil
