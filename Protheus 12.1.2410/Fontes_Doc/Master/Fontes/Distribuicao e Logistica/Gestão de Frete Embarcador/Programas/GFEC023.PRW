#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------------------------------------
/*{Protheus.doc} GFEC023
Curva ABC Transportador por Ocorrências
Uso Interno  
 
@author Felipe Mendes
@since 07/05/12  
@version 1.0                                                                                      
*/
//------------------------------------------------------------------------------------------------ 
Function GFEC023()	
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := 'Curva ABC Transportador por Ocorrências'   
	Local aParam := Array(7) // Armazena os valores do Pergunte
	Private oTree
	Private cAlias_Inf // Alias que conterá a tabela com todas as informações
	Private cNodeTree := "OCO_Oco"	 //Variavel responsavel por armazenar o nó atual,
	Private oPnl_Oco,   oGrf_Oco,;  //objetos do "Ocorrências Provocadas"
			 oPnl_VOc,   oGrf_VOc,;  //objetos do "Ocorrências Provocadas em Valor"
			 oPnl_OcP,   oGrf_OcP,;  //objetos do "Ocorrências Provocadas"
			 oPnl_OcV,   oGrf_OcV,;  //objetos do "Ocorrências Provocadas em Valor"
			 oPnl_OcS,   oGrf_OcS,;  //objetos do "Ocorrências de Sinistro"
			 oPnl_SiV,   oGrf_SiV  //objetos do "Sinistros em Valor da Carga"
	
	Private nTopGraf := 10
	Private oBrowse
	
	//Array principal que contém todos os campos e suas definições
	Private aGFEC022 := ;   
	 {{"Transp."                    ,"GU3_CDEMIT" ,"C",14,0,"",1} ,;  //Cod do transportador
	  {"Nome do Transp."           ,"GU3_NMEMIT" ,"C",50,0,"",1} ,;  //Nome do transp
	  {"Quantidade Ocorrências"   ,"QT_OCO"    ,"N",15,4,"@E 999,999,999",2} ,;  //quantidade de ocorrencias
	  {"%"			                  ,"QT_OCO_PE","N",6 ,2,"@E 999.99",2} 			 ,;  //Percentual - quantidade de ocorrencias
	  {"% Acum"			          ,"QT_OCO_PA","N",6 ,2,"@E 999.99",2} 			 ,;  //Percentual Acumulado - quantidade de ocorrencias
	  {"Class"	    	              ,"QT_OCO_CL","C",1 ,0,"",0} 			 ,;  //Percentual Acumulado - quantidade de ocorrencias
	  {"Valor Ocorrências"         ,"VL_OCO"     ,"N",15,4,"@E 999,999,999.99",2} ,;  //soma dos valores das ocorrencias
	  {"%"	                          ,"VL_OCO_PE"  ,"N",6 ,2,"@E 999.99",2} 			 ,;  //Percentual - soma dos valores das ocorrencias
	  {"% Acum"	                  ,"VL_OCO_PA"  ,"N",6 ,2,"@E 999.99",2} 			 ,;  //Percentual Acumulado - soma dos valores das ocorrencias
	  {"Class"		                  ,"VL_OCO_CL"  ,"C",1 ,0,"",0} 			 ,;  //Percentual Acumulado - soma dos valores das ocorrencias
 	  {"Qtde Ocor Provocadas"     ,"QT_PRO"    ,"N",15,4,"@E 999,999,999",2} ,;  //quantidade de ocorrencias provocadas
	  {"%"			                  ,"QT_PRO_PE","N",6 ,2,"@E 999.99",2} 			 ,;  //Percentual - quantidade de ocorrencias provocadas
	  {"% Acum"			          ,"QT_PRO_PA","N",6 ,2,"@E 999.99",2} 			 ,;  //Percentual Acumulado - quantidade de ocorrencias provocadas
	  {"Class"	    	              ,"QT_PRO_CL","C",1 ,0,"",0} 			 ,;  //Percentual Acumulado - quantidade de ocorrencias provocadas
	  {"Valor Ocor Provocadas"   ,"VL_PRO"     ,"N",15,4,"@E 999,999,999.99",2} ,;  //soma dos valores das ocorrencias provocadas
	  {"%"	                          ,"VL_PRO_PE"  ,"N",6 ,2,"@E 999.99",2} 			 ,;  //Percentual - soma dos valores das ocorrencias provocadas
	  {"% Acum"	                  ,"VL_PRO_PA"  ,"N",6 ,2,"@E 999.99",2} 			 ,;  //Percentual Acumulado - soma dos valores das ocorrencias provocadas
	  {"Class"		                  ,"VL_PRO_CL"  ,"C",1 ,0,"",0} 			 ,;  //Percentual Acumulado - soma dos valores das ocorrencias provocadas
 	  {"Quantidade Sinistros"	  ,"QT_SIN"    ,"N",15,4,"@E 999,999,999",2} ,;  //quantidade de sinistros provocados pelo transportador
	  {"%"			                  ,"QT_SIN_PE" ,"N",6 ,2,"@E 999.99",2} ,;  			 //Percentual - quantidade de sinistros provocados pelo transportador
	  {"% Acum"		 	          ,"QT_SIN_PA" ,"N",6 ,2,"@E 999.99",2} ,;  			 //Percentual Acumulado - quantidade de sinistros provocados pelo transportador
	  {"Class"		   		          ,"QT_SIN_CL" ,"C",1 ,0,"",0} ,;  			 //Percentual Acumulado - quantidade de sinistros provocados pelo transportador
	  {"Sinistros Valor Carga"  	  ,"VL_SIN"     ,"N",15,4,"@E 999,999,999.99",2} ,;  //soma dos valores do sinistros provocados pelo transportador
	  {"%"		                      ,"VL_SIN_PE"  ,"N",6 ,2,"@E 999.99",2} ,;  			 //Percentual - soma dos valores do sinistros provocados pelo transportador
 	  {"% Acum"		              ,"VL_SIN_PA"  ,"N",6 ,2,"@E 999.99",2} ,;  			 //Percentual Acumulado - soma dos valores do sinistros provocados pelo transportador
	  {"Class"	   		              ,"VL_SIN_CL"  ,"C",1 ,0,"",0},; 			 //Percentual Acumulado - soma dos valores do sinistros provocados pelo transportador
	  {"Grupo Tranp"		   		    ,"GU3_CDGRGL" ,"C",4 ,0,"@!",1					},; 
	  {"Descrição Grupo"		   		,"GU1_DSGREM" ,"C",50,0,"@!",1					}}
	
	If !Pergunte("GFEC023")
		Return
	Else
		aParam[1] := MV_PAR01 //Filial de
		aParam[2] := MV_PAR02 //Filial ate
		aParam[3] := MV_PAR03 //Data de
		aParam[4] := MV_PAR04 //Data ate 
		aParam[5] := MV_PAR05 //% de corte A
		aParam[6] := MV_PAR06 //% de corte B  
		aParam[7] := MV_PAR07 //Qtde séries 
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
		oFWLayer:Init(oDLG,.F.)  				   					
		
		/***Criando coluna esquerda (Tree)****/
		oFWLayer:AddLine('LINE_TOP',50,.F.) 							
		oFWLayer:AddCollumn('COL_TOP_LEFT',20,.T.,'LINE_TOP')
		oFWLayer:addWindow('COL_TOP_LEFT','WIN_TOP_LEFT','Sumário',100,.T.,.F.,,'LINE_TOP',)
	    oWIN_TOP_LEFT := oFWLayer:getWinPanel('COL_TOP_LEFT','WIN_TOP_LEFT', 'LINE_TOP')
		
		/***Criando coluna direita (Browse)****/	
		oFWLayer:AddCollumn('COL_TOP_RIGHT',80,.T.,'LINE_TOP')
		oWIN_TOP_RIGHT := oFWLayer:GetColPanel('COL_TOP_RIGHT','LINE_TOP') 			
	   
	 	/***Criando Linha abaixo (Grafico)****/
	   	oFWLayer:AddLine('LINE_BOTTOM',50,.F.) 		
		oFWLayer:AddCollumn('COL_BOTTOM', 100, .T.,'LINE_BOTTOM')
		oFWLayer:addWindow('COL_BOTTOM','WIN_BOTTOM','Gráfico',100,.T.,.F.,,'LINE_BOTTOM',)
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
	Local aStruct := {} , nCont
	                 
	For nCont := 1 to Len(aGFEC022)
		aADD(aStruct,{ aGFEC022[nCont][2],;  //Nome do campo
						 aGFEC022[nCont][3],;  //Tipo
						 aGFEC022[nCont][4],;  //Tamanho
						 aGFEC022[nCont][5] }) //Decimal
	Next nCont             
	
	cAlias := GFECriaTab({aStruct,{ "GU3_CDEMIT",;
								    "STR(QT_OCO_PE)+GU3_CDEMIT",;
									"STR(VL_OCO_PE)+GU3_CDEMIT",;
									"STR(QT_PRO_PE)+GU3_CDEMIT",;
									"STR(VL_PRO_PE)+GU3_CDEMIT",;
									"STR(QT_SIN_PE)+GU3_CDEMIT",;
									"STR(VL_SIN_PE)+GU3_CDEMIT",;
									"QT_OCO_CL+STR(QT_OCO_PA)+GU3_CDEMIT",;
									"VL_OCO_CL+STR(VL_OCO_PA)+GU3_CDEMIT",;
									"QT_PRO_CL+STR(QT_PRO_PA)+GU3_CDEMIT",;
									"VL_PRO_CL+STR(VL_PRO_PA)+GU3_CDEMIT",;
									"QT_SIN_CL+STR(QT_SIN_PA)+GU3_CDEMIT",;
									"VL_SIN_CL+STR(VL_SIN_PA)+GU3_CDEMIT"}})
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
    Local cBmp := "SDUCLOSE"
    Local cBmpOpen := "SDUOPEN"
    /* Cria o objeto Tree*/
	oFont := TFont():New('Arial',,-12,.T.)
	oTree := DbTree():New(0,0,0,0,oDialog,{|| ChangeItem()},,.T.,,oFont)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT                                        
	
	oTree:AddItem("Quantidade Ocorrências","OCO_Oco",cBmp,cBmpOpen,,,1) 
	oTree:AddItem("Valor Ocorrências"      ,"OCO_VOc",cBmp,cBmpOpen,,,1)
	oTree:AddItem("Qtde  Ocor Provocadas" ,"OCO_OcP",cBmp,cBmpOpen,,,1) 
	oTree:AddItem("Valor Ocor Provocadas" ,"OCO_OcV",cBmp,cBmpOpen,,,1)
	oTree:AddItem("Quantidade Sinistros"  ,"OCO_OcS",cBmp,cBmpOpen,,,1) 
	oTree:AddItem("Sinistros Valor Carga","OCO_SiV",cBmp,cBmpOpen,,,1) 
	oTree:TreeSeek("OCO_Oco")
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
	oPnl_Oco := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_Oco:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_VOc := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_VOc:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_OcP := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_OcP:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_OcV := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_OcV:Align := CONTROL_ALIGN_ALLCLIENT   
	
	oPnl_OcS := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_OcS:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_SiV := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_SiV:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPanelAtual := oPnl_Oco
	 
	oPnl_VOc:Hide()
	oPnl_OcP:Hide()
	oPnl_OcV:Hide()   
	oPnl_OcS:Hide()
	oPnl_SiV:Hide()
Return
//=========================================================================/
//Funcção Responsavel por criar o Grafico.
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
	
	//Array que contém a relação dos Paineis, campos e objetos graficos
	aArray :={{"oPnl_Oco","QT_OCO","oGrf_OcP","Quantidade Ocorrências","@E 9999,999,999"},;
			   {"oPnl_VOc","VL_OCO","oGrf_OcP","Valor Ocorrências"      ,"@E 9999,999,999"},;
			   {"oPnl_OcP","QT_PRO","oGrf_OcP","Qtde Ocor. Provocadas" ,"@E 9999,999,999"},;
			   {"oPnl_OcV","VL_PRO","oGrf_OcV","Valor Ocor. Provocadas","@E 9999,999,999"},;
			   {"oPnl_OcS","QT_SIN","oGrf_OcS","Quantidade Sinistros"  ,"@E 9999,999,999"},;
			   {"oPnl_SiV","VL_SIN","oGrf_SiV","Sinistros Valor Carga" ,"@E 9999,999,999"}}
    
	//Percorre o Array e cria dinamicamente todos os paineis.
	For nContGrf := 1 to Len(aArray)
		oTmpPnl := &(aArray[nContGrf][1])
		 
		oTmpGrf := FWChartFactory():New()
		oTmpGrf := oTmpGrf:getInstance( BARCHART )
		
		oTmpGrf:setTitle("Curva ABC " + aArray[nContGrf][4], CONTROL_ALIGN_CENTER)
		oTmpGrf:setPicture(aArray[nContGrf][5])
		oTmpGrf:setLegend(CONTROL_ALIGN_CENTER)
		
		oTmpGrf:Init( oTmpPnl,.T.,.T. )  
		aGrafico := CriaArray(cAlias,aArray[nContGrf][2])
		
		/* Define as cores conforme a classificação */
		aCorA := oTmpGrf:oFWChartColor:aRandom[1] 
		aCorB := oTmpGrf:oFWChartColor:aRandom[2]
		aCorC := oTmpGrf:oFWChartColor:aRandom[3]
		aCorOutros := oTmpGrf:oFWChartColor:aRandom[4]
		 
		For nCont := 1 To Len(aGrafico)       
			//Verifica se há mais de nTopGraf transp, caso haja, soma os transp restantes   
			If nCont > (nTopGraf - 1)
				//somando o resultado dos transp
				nOutrosTransp := 0 
				For nCont2 := nTopGraf to Len(aGrafico)
					nOutrosTransp := nOutrosTransp + aGrafico[nCont2][2]
				Next nCont2
				
				oTmpGrf:AddSerie("Outros transportadores", nOutrosTransp) 
				AADD(aRand, aCorOutros) // Se "Outros", muda a cor da barra
				Exit
			Else
				oTmpGrf:AddSerie(aGrafico[nCont][1], aGrafico[nCont][2])
				
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
		
		&(aArray[nContGrf][3]) := oTmpGrf
	Next nContGrf
Return     

//=========================================================================/
//Funcção Responsavel por criar o array ordenado para que as informações no Grafico fiquem ordenadas do maior para o menor.
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
	    aADD(aStruct, { ALLTRIM(Posicione("GU3", 1, xFilial("GU3") + (cAlias)->GU3_CDEMIT, "GU3_NMEMIT") ),(cAlias)->&(cCampo),(cAlias)->&(cCampo + "_CL")})
		(cAlias)->(dbSkip())
	EndDo  
	
	aSORT(aStruct,,,{ |x,y| x[2] > y[2] }) //Ordena o array do maior para o menor
Return aStruct           

//=========================================================================/
Static Function CriaGrid(oDialog)
	Local nCont
	Local aCampos := aGFEC022
	
	(cAlias_Inf)->(dbSetOrder(8))
	                      							
	oBrowse := FWMBrowse():New()  
	oBrowse:SetAlias(cAlias_Inf)	
	oBrowse:SetMenuDef('GFEC022')
	oBrowse:SetDescription("Transportadores") 
		
	For nCont := 1 to Len( aCampos ) 
	 	oBrowse:AddColumn( {aCampos[nCont][1],&("{|| (cAlias_Inf)->" + aCampos[nCont][2] + "}"),aCampos[nCont][3],aCampos[nCont][6],aCampos[nCont][7],aCampos[nCont][4],aCampos[nCont][5],.T.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.T.,{} } )
	Next nCont
 
 	oBrowse:SetLocate()
 	oBrowse:SetOwner(oDialog)            
	oBrowse:DisableDetails() 
	oBrowse:ForceQuitButton(.T.)
	oBrowse:SetWidthColumns({7,30,7,2,2,2,7,2,2,2,7,2,2,2,7,2,2,2,7,2,2,2,7,2,2,2})
   	oBrowse:Activate()
Return   
//=========================================================================/
Static Function MenuDef()   
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Visualizar" ACTION 'GFEC022EMI()'    OPERATION 1  ACCESS 0 //"Visualizar"
Return aRotina                                      
//=========================================================================/
Function GFEC022EMI()   
	dbSelectArea("GU3")
	dbSetOrder(1)
	If dbSeek(xFilial("GU3")+(cAlias_Inf)->GU3_CDEMIT)
		FWExecView("Frete Embarcador",'GFEA015', 1, , {|| .F. },{|| .F.},,,{|| .T.}) 
	EndIf
Return	
//=========================================================================/              
Static Function ChangeItem()    
	Local cTabela 	:= AllTrim(Substr(oTree:GetCargo(), 1, 3))
	Local cSubItem 	:= AllTrim(Substr(oTree:GetCargo(), 5, 3))
	Local oTmpPanel
	Local aOco := {3,4,5,6}
	Local aVOc := {7,8,9,10}
	Local aOcP := {11,12,13,14}
	Local aOcV := {15,16,17,18}
	Local aOcS := {19,20,21,22}
	Local aSiV := {23,24,25,26}
	
	Local aPes
	
	If Empty(cSubItem) // Verifica se o nó selecionado é um nó raiz, se sim volta para o ultimo nó selecionado  
		Return 
	EndIf

	CursorWait() 
	
    oTmpPanel := &( "oPnl_"+AllTrim(Substr(cNodeTree, 5, 3)) ) 
    oTmpPanel:Hide() 
    oTmpPanel := &( "oPnl_"+AllTrim(Substr(oTree:GetCargo(), 5, 3)) )
    oTmpPanel:Show()     
    
    Do Case
    	Case cSubItem == "Oco"
			aPes := aOco
			(cAlias_Inf)->(dbSetOrder(8))
		Case cSubItem == "VOc"
			aPes := aVOc
			(cAlias_Inf)->(dbSetOrder(9))	
		Case cSubItem == "OcP"
			aPes := aOcP
			(cAlias_Inf)->(dbSetOrder(10))
		Case cSubItem == "OcV"
			aPes := aOcV
			(cAlias_Inf)->(dbSetOrder(11))
		Case cSubItem == "OcS"
			aPes := aOcS
			(cAlias_Inf)->(dbSetOrder(12))
		Case cSubItem == "SiV"
			aPes := aSiV
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

	/*cQuery := "SELECT " 
	cQuery += "	GU3_CDEMIT, " 
	cQuery += "	( SELECT COUNT(*)        FROM "+RetSQLName( 'GWD' )+" JOIN "+RetSQLName( 'GU6' )+" ON GWD_CDMOT  = GU6_CDMOT WHERE GU6_PROVOC = '1' AND GWD_CDTRP = GU3_CDEMIT AND " + SQLWhereQuery("GWD_FILIAL","GWD_DTOCOR",aParam) + " )QT_PRO, "
	cQuery += "	( SELECT COALESCE(SUM(GWI_VLFRET),0) FROM "+RetSQLName( 'GWI' )+" JOIN "+RetSQLName( 'GWF' )+" ON GWI_NRCALC = GWF_NRCALC  JOIN "+RetSQLName( 'GWD' )+" ON GWF_NROCO = GWD_NROCO JOIN "+RetSQLName( 'GU6' )+" ON GWD_CDMOT  = GU6_CDMOT  WHERE GU6_PROVOC = '1' AND GWD_CDTRP = GU3_CDEMIT AND GWI_TOTFRE = '1' AND " + SQLWhereQuery("GWD_FILIAL","GWD_DTOCOR",aParam) + " )VL_PRO, "
	cQuery += "	( SELECT COUNT(*)        FROM "+RetSQLName( 'GWD' )+" JOIN "+RetSQLName( 'GU6' )+" ON GWD_CDMOT  = GU6_CDMOT   JOIN "+RetSQLName( 'GU5' )+" ON GU5_CDTIPO = GWD_CDTIPO WHERE GU5_EVENTO = '2' AND   GU6_PROVOC = '1' AND " + SQLWhereQuery("GWD_FILIAL","GWD_DTOCOR",aParam) + " )QT_SIN, "
	cQuery += "	( SELECT COALESCE(SUM(GWI_VLFRET),0) FROM "+RetSQLName( 'GWI' )+" JOIN "+RetSQLName( 'GWF' )+" ON GWI_NRCALC = GWF_NRCALC  JOIN "+RetSQLName( 'GWD' )+" ON GWF_NROCO = GWD_NROCO JOIN "+RetSQLName( 'GU6' )+" ON GWD_CDMOT  = GU6_CDMOT JOIN "+RetSQLName( 'GU5' )+" ON GU5_CDTIPO = GWD_CDTIPO WHERE GU5_EVENTO = '2' AND GU6_PROVOC = '1' AND  GWI_TOTFRE = '1' AND " + SQLWhereQuery("GWD_FILIAL","GWD_DTOCOR",aParam) + " )VL_SIN " 
	cQuery += "FROM "+RetSQLName( 'GU3' )+" " 
	
	cQuery += "WHERE GU3_TRANSP = '1' GROUP BY GU3_CDEMIT "*/
	
	/*cQuery += "SELECT	DISTINCT GU3.GU3_CDEMIT,"
 	cQuery += "		COUNT(*) QT_OCO,"
 	cQuery += "		SUM(GWI_VLFRET) VL_OCO,"
 	cQuery += "		COUNT(CASE WHEN GU6.GU6_PROVOC = '1' THEN 1 END) QT_PRO,"
 	cQuery += "		SUM(CASE WHEN GU6.GU6_PROVOC = '1' THEN GWI_VLFRET ELSE 0 END) VL_PRO,"
 	cQuery += "		COUNT(CASE WHEN GU5.GU5_EVENTO = '2' THEN 1 END) QT_SIN,"
	cQuery += "		SUM(CASE WHEN GU5.GU5_EVENTO = '2' THEN GWI_VLFRET ELSE 0 END) VL_SIN"
	cQuery += "  FROM "+RetSQLName( 'GU3' )+" GU3"
	cQuery += "  LEFT JOIN "+RetSQLName('GWD')+" GWD ON GWD.GWD_CDTRP = GU3.GU3_CDEMIT" 
	cQuery += "                       AND GWD.D_E_L_E_T_ = ' ' AND " + SQLWhereQuery("GWD.GWD_FILIAL","GWD.GWD_DTOCOR",aParam)
	cQuery += "  LEFT JOIN "+RetSQLName( 'GU6' )+" GU6 ON GU6.GU6_CDMOT = GWD.GWD_CDMOT" 
	cQuery += "                       AND GU6.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN "+RetSQLName( 'GU5' )+" GU5 ON GU5.GU5_CDTIPO = GWD.GWD_CDTIPO" 
	cQuery += "                       AND GU5.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN "+RetSQLName( 'GWF' )+" GWF ON GWF.GWF_NROCO = GWD.GWD_NROCO" 
	cQuery += "   					   AND GWD.D_E_L_E_T_ = ' '   "
	cQuery += "  LEFT JOIN (SELECT DISTINCT GWI1.GWI_NRCALC," 
	cQuery += "  							  SUM(GWI1.GWI_VLFRET) GWI_VLFRET" 
	cQuery += "   				FROM "+RetSQLName( 'GWI' )+" GWI1 "
	cQuery += "   			   WHERE GWI1.D_E_L_E_T_ = ' '" 
	cQuery += "   			     AND GWI1.GWI_TOTFRE = '1' "
	cQuery += "   			   GROUP BY GWI1.GWI_NRCALC"
	cQuery += "   			  ) GWI ON GWI.GWI_NRCALC = GWF.GWF_NRCALC"
	cQuery += "  WHERE (GU3.GU3_TRANSP = '1' OR GU3.GU3_AUTON = '1')"
	cQuery += "    AND GU3.D_E_L_E_T_ = ' '"
	cQuery += "  GROUP BY GU3.GU3_CDEMIT"*/
	
	cQuery += " SELECT DISTINCT GU3.GU3_CDEMIT, GU3.GU3_CDGRGL, GU1.GU1_DSGREM, "
	cQuery += " 		 COUNT(GWD.GWD_FILIAL) QT_OCO,"
	cQuery += " 		 SUM(GWI_VLFRET) VL_OCO,"
	cQuery += " 		 COUNT(CASE WHEN GU6.GU6_PROVOC = '1' THEN 1 END) QT_PRO,"
	cQuery += " 		 SUM(CASE WHEN GU6.GU6_PROVOC = '1' THEN GWI_VLFRET ELSE 0 END) VL_PRO,"
	cQuery += " 		 COUNT(CASE WHEN GU5.GU5_EVENTO = '2' THEN 1 END) QT_SIN,"
	cQuery += "		 SUM(CASE WHEN GU5.GU5_EVENTO = '2' THEN GW8L.GW8_VALOR ELSE 0 END) VL_SIN"
	cQuery += "   FROM " + RetSQLName( 'GU3' ) + " GU3"
	cQuery += "   LEFT JOIN " + RetSQLName( 'GWD' ) + " GWD ON GWD.GWD_CDTRP = GU3.GU3_CDEMIT" 
	cQuery += "                       AND GWD.D_E_L_E_T_ = ' ' AND " + SQLWhereQuery("GWD.GWD_FILIAL","GWD.GWD_DTOCOR",aParam)
	cQuery += "   LEFT JOIN " + RetSQLName( 'GU6' ) + " GU6 ON GU6.GU6_CDMOT = GWD.GWD_CDMOT" 
	cQuery += "                       AND GU6.D_E_L_E_T_ = ' '"
	cQuery += "   LEFT JOIN " + RetSQLName( 'GU5' ) + " GU5 ON GU5.GU5_CDTIPO = GWD.GWD_CDTIPO" 
	cQuery += "                       AND GU5.D_E_L_E_T_ = ' '"
	cQuery += "   LEFT JOIN " + RetSQLName( 'GWF' ) + " GWF ON GWF.GWF_FILIAL = GWD.GWD_FILIAL" 
	cQuery += "   					   AND GWF.GWF_NROCO = GWD.GWD_NROCO" 
	cQuery += "   					   AND GWF.D_E_L_E_T_ = ' '"   
	cQuery += "   LEFT JOIN (SELECT GWL.GWL_NROCO,"
	cQuery += "   					   GWL.GWL_FILIAL,"
	cQuery += "   					   SUM(GW8.GW8_VALOR) GW8_VALOR"
	cQuery += "   			    FROM " + RetSQLName( 'GWL' ) + " GWL"
	cQuery += "   			   INNER JOIN " + RetSQLName( 'GW8' ) + " GW8 ON GW8.GW8_FILIAL = GWL.GWL_FILDC"
	cQuery += "					   				AND GW8.GW8_CDTPDC = GWL.GWL_TPDC"
	cQuery += "					   				AND GW8.GW8_EMISDC = GWL.GWL_EMITDC"
	cQuery += "					   				AND GW8.GW8_SERDC  = GWL.GWL_SERDC"
	cQuery += "					   				AND GW8.GW8_NRDC   = GWL.GWL_NRDC"
	cQuery += "					   				AND GW8.D_E_L_E_T_ = ' '"
	cQuery += "			   WHERE GWL.D_E_L_E_T_ = ' '"
	cQuery += "			   GROUP BY GWL.GWL_NROCO, GWL.GWL_FILIAL"
	cQuery += "             ) GW8L ON GW8L.GWL_NROCO  = GWD.GWD_NROCO"
	cQuery += "             	     AND GW8L.GWL_FILIAL = GWD.GWD_FILIAL"
	cQuery += "   LEFT JOIN (SELECT DISTINCT GWI1.GWI_NRCALC, GWI1.GWI_FILIAL," 
	cQuery += "   							  SUM(GWI1.GWI_VLFRET) GWI_VLFRET" 
	cQuery += "   				FROM " + RetSQLName( 'GWI' ) + " GWI1 "
	cQuery += "   			   WHERE GWI1.D_E_L_E_T_ = ' ' AND GWI1.GWI_TOTFRE = '1'"
	cQuery += "   			   GROUP BY GWI1.GWI_NRCALC, GWI1.GWI_FILIAL"
	cQuery += "   			  ) GWI ON GWI.GWI_FILIAL = GWF.GWF_FILIAL"
	cQuery += "   			       AND GWI.GWI_NRCALC = GWF.GWF_NRCALC   "
	cQuery += "   LEFT JOIN " + RetSQLName( 'GU1' ) + " GU1 ON GU1.GU1_CDGREM = GU3.GU3_CDGRGL"
    cQuery += "                       AND GU1.D_E_L_E_T_ = ' '"
	cQuery += "  WHERE (GU3.GU3_TRANSP = '1' OR GU3.GU3_AUTON = '1')"
	cQuery += "    AND GU3.D_E_L_E_T_ = ' '"
	cQuery += "  GROUP BY GU3.GU3_CDEMIT,GU3.GU3_CDGRGL, GU1.GU1_DSGREM"
	
	cTmp   := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
	dbSelectArea(cTmp)
	dbGoTop()
	
	While (cTmp)->(!Eof())
		RecLock(cAlias_Inf, .T.)
		(cAlias_Inf)->GU3_CDEMIT  	:= (cTmp)->GU3_CDEMIT  													//transportador
		(cAlias_Inf)->GU3_NMEMIT  	:= Posicione("GU3", 1, xFilial("GU3") + (cTmp)->GU3_CDEMIT, "GU3_NMEMIT") //nome do transportador
		(cAlias_Inf)->GU3_CDGRGL  	:= (cTmp)->GU3_CDGRGL
		(cAlias_Inf)->GU1_DSGREM  	:= (cTmp)->GU1_DSGREM
		(cAlias_Inf)->QT_OCO 		    := (cTmp)->QT_OCO   //Quantidada de ocorrencias do transportador
		(cAlias_Inf)->VL_OCO   		:= (cTmp)->VL_OCO     //valor acumulado das ocorrencias do transportador
		(cAlias_Inf)->QT_PRO 		    := (cTmp)->QT_PRO   //Quantidada de ocorrencias provocadas pelo transportador
		(cAlias_Inf)->VL_PRO   		:= (cTmp)->VL_PRO     //valor acumulado das ocorrencias provocadas pelo transportador
		(cAlias_Inf)->QT_SIN 		    := (cTmp)->QT_SIN   //Quantidade de sinistros por transportador
		(cAlias_Inf)->VL_SIN   		:= (cTmp)->VL_SIN     //valor acumulado dos sinistros por transportador
		MsUnlock()
		
		dbSelectArea(cTmp)
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
	Local nPQtOco := 0
	Local nPVlOco := 0
	Local nPQtPro := 0
	Local nPVlPro := 0
	Local nQtSin  := 0
	Local nVlSin := 0 
	AFILL(aTotal,0)

	dbSelectArea(cAlias_Inf)
	dbGoTop()
	While !((cAlias_Inf)->(Eof()))
		 aTotal[1] := (cAlias_Inf)->QT_OCO + aTotal[1]
		 aTotal[2] := (cAlias_Inf)->VL_OCO + aTotal[2]
		 aTotal[3] := (cAlias_Inf)->QT_PRO + aTotal[3]
		 aTotal[4] := (cAlias_Inf)->VL_PRO + aTotal[4]
		 aTotal[5] := (cAlias_Inf)->QT_SIN + aTotal[5]
		 aTotal[6] := (cAlias_Inf)->VL_SIN + aTotal[6]
		 
		(cAlias_Inf)->(dbSkip())
	EndDo
	
	dbSelectArea(cAlias_Inf)
	dbGoTop()
	While !( (cAlias_Inf)->(Eof()) )
		(cAlias_Inf)->QT_OCO_PE := ROUND(((cAlias_Inf)->QT_OCO * 100) / aTotal[1],2)	 
		(cAlias_Inf)->VL_OCO_PE := ROUND(((cAlias_Inf)->VL_OCO * 100) / aTotal[2],2)	 
	 	(cAlias_Inf)->QT_PRO_PE := ROUND(((cAlias_Inf)->QT_PRO * 100) / aTotal[3],2)	 
		(cAlias_Inf)->VL_PRO_PE := ROUND(((cAlias_Inf)->VL_PRO * 100) / aTotal[4],2)	 
	 	(cAlias_Inf)->QT_SIN_PE := ROUND(((cAlias_Inf)->QT_SIN * 100) / aTotal[5],2)	 
	 	(cAlias_Inf)->VL_SIN_PE := ROUND(((cAlias_Inf)->VL_SIN * 100) / aTotal[6],2)
	 	
	 	nPQtOco += (cAlias_Inf)->QT_OCO_PE 
	 	nPVlOco += (cAlias_Inf)->VL_OCO_PE 
	 	nPQtPro += (cAlias_Inf)->QT_PRO_PE 
	 	nPVlPro += (cAlias_Inf)->VL_PRO_PE 
	 	nQtSin  += (cAlias_Inf)->QT_SIN_PE 
	 	nVlSin  += (cAlias_Inf)->VL_SIN_PE
	 	
		(cAlias_Inf)->(dbSkip())
	EndDo                          
	
	/* Correção dos percentuais */
	AjusPerc(2, "QT_OCO_PE", nPQtOco)
	AjusPerc(3, "VL_OCO_PE", nPVlOco)
	AjusPerc(4, "QT_PRO_PE", nPQtPro)
	AjusPerc(5, "VL_PRO_PE", nPVlPro)
	AjusPerc(6, "QT_SIN_PE", nQtSin)
	AjusPerc(7, "VL_SIN_PE", nVlSin)
	
	//Array com a relação dos indices e campos para armazenas o Percentual Acumulado
	aArray := { {2,"QT_OCO_PE" ,"QT_OCO_PA","QT_OCO_CL"},;
				 {3,"VL_OCO_PE"  ,"VL_OCO_PA","VL_OCO_CL"},;
				 {4,"QT_PRO_PE" ,"QT_PRO_PA","QT_PRO_CL"},;
				 {5,"VL_PRO_PE"  ,"VL_PRO_PA","VL_PRO_CL"},;
				 {6,"QT_SIN_PE" ,"QT_SIN_PA","QT_SIN_CL"},;
				 {7,"VL_SIN_PE"  ,"VL_SIN_PA","VL_SIN_CL"} }
	
	For nCont := 1 To Len(aArray)
		//Variavel responsavel por acumular o percentual 
		nPercAcum := 0 
	    lCorteA   := .F.   
	    lCorteB   := .F.
	    
		dbSelectArea(cAlias_Inf)
	    dbSetOrder(aArray[nCont][1])  //Set o indice correspondente 
		dbGoBottom() // ordena a tabela do maior para o menor
		While !Bof() 
			nPercAcum := (cAlias_Inf)->&(aArray[nCont][2]) + nPercAcum   //Soma o percentual acumulado com o percentual do registro atual
			
			RecLock((cAlias_Inf),.F.)    
			(cAlias_Inf)->&(aArray[nCont][3]) := nPercAcum  //Atribui no registro o perc acum
			
			If (nPercAcum <= nCorteA .And. (cAlias_Inf)->&(aArray[nCont][2]) != 0 ) .Or. (nPercAcum > nCorteA .And. !lCorteA .And. (cAlias_Inf)->&(aArray[nCont][2]) != 0)
				(cAlias_Inf)->&(aArray[nCont][4])  := "A"  
				lCorteA := .T.
			ElseIf (nPercAcum <= nCorteB .And. (cAlias_Inf)->&(aArray[nCont][2]) != 0 ) .Or. (nPercAcum > nCorteB .And. !lCorteB .And. (cAlias_Inf)->&(aArray[nCont][2]) != 0)
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
	RecLock((cAlias_Inf),.F.) 
	(cAlias_Inf)->&(cCampo) := (cAlias_Inf)->&(cCampo) + (100 - nAcum)
	MsUnlock()
Return Nil
