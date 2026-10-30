#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------------------------------------
/*{Protheus.doc} GFEC024   
Curva ABC Transportador por Divergências   
Uso Interno
 
@author Felipe Mendes
@since 07/05/12
@version 1.0                                                                                      
*/
//------------------------------------------------------------------------------------------------ 
Function GFEC024()
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := 'Curva ABC Transportador por Divergências'   
	Local aParam := Array(7) // Armazena os valores do Pergunte
	Private oTree
	Private cAlias_Inf // Alias que conterá a tabela com todas as informações
	Private cNodeTree := "AUD_DiD"	 //Variavel responsavel por armazenar o nó atual,
	Private oPnl_DiD,   oGrf_DiD,;  //objetos do "Divergências de Doc Frete"
			oPnl_DFV,   oGrf_DFV,;  //objetos do "Divergências de Doc Frete em Valor"
			oPnl_Div,   oGrf_Div,;  //objetos do "Divergências de Faturas"
			oPnl_Fat,   oGrf_Fat    //objetos do "Divergências de Faturas em Valor"		
	
	Private nTopGraf := 10
	Private oBrowse
	
	//Array principal que contém todos os campos e suas definições
	Private aGFEC024 := ;
	{{"Transp."		 ,"GU3_CDEMIT"	,"C",14,0,"",1} ,;  //Cod do transportador
	{"Nome do Transp.","GU3_NMEMIT"	,"C",50,0,"",1} ,;  //Nome do transp
	{"Valor Doc Frete","DIVDFV"    ,"N",15,4,"@E 999,999,999.99",2} ,;  //Soma dos valores das divergencias dos DF
	{"%"			   ,"DIVDFV_PE" ,"N",6 ,2,"@E 999.99",2} ,;  			 //Percentual - Soma dos valores das divergencias dos DF
	{"% Acum"		   ,"DIVDFV_PA"    ,"N",6 ,2,"@E 999.99",2} ,;  			 //Percentual Acumulado - Soma dos valores das divergencias dos DF
	{"Class"		   ,"DIVDFV_CL" 	,"C",1 ,0,"",0} ,;  			 //Classificação - Soma dos valores das divergencias dos DF
	{"Qtde Doc Frete","DIV_DF"    	,"N",15,4,"@E 999,999,999",2} ,;  //quantidade de divergencias dos DF (Situação Bloqueado ou Apr Usu.)
	{"%"		   	  ,"DIV_DF_PE"    ,"N",6 ,2,"@E 999.99",2} ,;  			 //Percentual - quantidade de divergencias dos DF (Situação Bloqueado ou Apr Usu.)
	{"% Acum"		  ,"DIV_DF_PA"    ,"N",6 ,2,"@E 999.99",2} ,;  			 //Percentual Acumulado - quantidade de divergencias dos DF (Situação Bloqueado ou Apr Usu.)
	{"Class"		  ,"DIV_DF_CL" 	,"C",1 ,0,"",0} ,;  			 //Classificação - quantidade de divergencias dos DF (Situação Bloqueado ou Apr Usu.)
	{"Valor Fatura" ,"DIVFTV" 	,"N",15,4,"@E 999,999,999.99",2},;   //Soma dos valores das divergencias das Faturas
	{"%"			  ,"DIVFTV_PE" 	,"N",6 ,2,"@E 999.99",2},;    		     //Percentual - Soma dos valores das divergencias das Faturas
	{"% Acum"		  ,"DIVFTV_PA" 	,"N",6 ,2,"@E 999.99",2},;   		     //Percentual Acumulado - Soma dos valores das divergencias das Faturas
	{"Class"		  ,"DIVFTV_CL" 	,"C",1 ,0,"",0},;   		     //Classificação - Soma dos valores das divergencias das Faturas
	{"Qtde Fatura"  ,"DIV_FT"    	,"N",15,4,"@E 999,999,999",2} ,;  //quantidade de divergencias das Faturas (Situação Bloqueado ou Apr Usu.)
	{"%"			  ,"DIV_FT_PE"    ,"N",6 ,2,"@E 999.99",2}  ,; 			 //Percentual - quantidade de divergencias das Faturas (Situação Bloqueado ou Apr Usu.)
	{"% Acum"		  ,"DIV_FT_PA"    ,"N",6 ,2,"@E 999.99",2}  ,; 			 //Percentual Acumulado - quantidade de divergencias das Faturas (Situação Bloqueado ou Apr Usu.)
	{"Class"		  ,"DIV_FT_CL" 	,"C",1 ,0,"",0},; 			 //Classificação - quantidade de divergencias das Faturas (Situação Bloqueado ou Apr Usu.)
	{"Grupo Tranp"		   		    ,"GU3_CDGRGL" ,"C",4 ,0,"@!",1					},; 
	{"Descrição Grupo"		   		,"GU1_DSGREM" ,"C",50,0,"@!",1					}}
	
	If !Pergunte("GFEC024")
		Return
	Else
		aParam[1] := MV_PAR01 	//Filial de
		aParam[2] := MV_PAR02 	//Filial ate
		aParam[3] := MV_PAR03	//Data de
		aParam[4] := MV_PAR04	//Data ate
		aParam[5] := MV_PAR05	//% de corte A  
		aParam[6] := MV_PAR06	//% de corte B  
		aParam[7] := MV_PAR07	//Qtde séries
	EndIf
	 	
	//Cria a tabela
	cAlias_Inf := CriaTab()    
	//Alimenta a tabela com as informações (não necessita informar o Alias, pois a variavel é Private)
	QuerySQL(aParam) 
	Percentual(aParam[5],aParam[6])
	  
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		/*Criando objeto Layer*/
		oFWLayer := FWLayer():new()  	// Método de criação do objeto da classe.
		oFWLayer:Init( oDLG, .F. )  				   					
		
		/***Criando coluna esquerda (Tree)****/
		oFWLayer:AddLine( 'LINE_TOP', 50, .F. ) 							
		oFWLayer:AddCollumn( 'COL_TOP_LEFT'  , 20, .T., 'LINE_TOP' ) 			
		oFWLayer:addWindow('COL_TOP_LEFT','WIN_TOP_LEFT','Sumário',100,.T.,.F.,,'LINE_TOP',)
	    oWIN_TOP_LEFT := oFWLayer:getWinPanel('COL_TOP_LEFT','WIN_TOP_LEFT', 'LINE_TOP')
		
		/***Criando coluna direita (Browse)****/	
		oFWLayer:AddCollumn( 'COL_TOP_RIGHT'  , 80, .T., 'LINE_TOP' ) 			
		oWIN_TOP_RIGHT := oFWLayer:GetColPanel( 'COL_TOP_RIGHT' , 'LINE_TOP' ) 			
	   
	 	/***Criando Linha abaixo (Grafico)****/
	   	oFWLayer:AddLine( 'LINE_BOTTOM', 50, .F. ) 					   		
		oFWLayer:AddCollumn( 'COL_BOTTOM'  , 100, .T., 'LINE_BOTTOM' ) 			
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
	Local nCont
	Local aStruct := {}
               
	For nCont := 1 to Len(aGFEC024)
		aADD(aStruct,{aGFEC024[nCont][2],;  //Nome do campo
						aGFEC024[nCont][3],;  //Tipo
						aGFEC024[nCont][4],;  //Tamanho
						aGFEC024[nCont][5]}) //Decimal
	Next nCont                                  
				 
	cAlias := GFECriaTab({aStruct,{ "GU3_CDEMIT",;
									    "STR(DIV_DF_PE)+GU3_CDEMIT",;
									    "STR(DIVDFV_PE)+GU3_CDEMIT",;
									    "STR(DIV_FT_PE)+GU3_CDEMIT",;
									    "STR(DIVFTV_PE)+GU3_CDEMIT",;
									    "DIV_DF_CL+STR(DIV_DF_PA)+GU3_CDEMIT",;
									    "DIVDFV_CL+STR(DIVDFV_PA)+GU3_CDEMIT",;
									    "DIV_FT_CL+STR(DIV_FT_PA)+GU3_CDEMIT",;
									    "DIVFTV_CL+STR(DIVFTV_PA)+GU3_CDEMIT"}})          
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
	
	oTree:AddItem("Valor Doc Frete Divergente","AUD_DFV" ,cBmp,cBmpOpen,,,1)
	oTree:AddItem("Qtde Doc Frete Divergente","AUD_DiD" ,cBmp,cBmpOpen,,,1) 
	oTree:AddItem("Valor Fatura Divergente"  ,"AUD_Fat",cBmp,cBmpOpen,,,1)
	oTree:AddItem("Qtde Fatura Divergente"		 ,"AUD_Div" ,cBmp,cBmpOpen,,,1)
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
	oPnl_DiD := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_DiD:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_DFV := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_DFV:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_Div := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_Div:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_Fat := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_Fat:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPanelAtual := oPnl_DFV 
	
	oPnl_DiD:Hide()
	oPnl_Div:Hide()
	oPnl_Fat:Hide()
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
	aArray :={{"oPnl_DiD" ,"DIV_DF" ,"oGrf_DiD","Qtde Doc Frete Divergente","@E 9999,999,999" },;
			   {"oPnl_DFV" ,"DIVDFV" ,"oGrf_DFV","Valor Doc Frete Divergente","@E 9999,999,999" },;
			   {"oPnl_Div" ,"DIV_FT" ,"oGrf_Div","Qtde Fatura Divergente","@E 9999,999,999" },;
			   {"oPnl_Fat" ,"DIVFTV" ,"oGrf_Fat","Valor Fatura Divergente","@E 9999,999,999" }}
    
	//Percorre o Array e cria dinamicamente todos os paineis.
	For nContGrf := 1 to Len(aArray)
		oTmpPnl := &(aArray[nContGrf][1])
		
		oTmpGrf := FWChartFactory():New()
		oTmpGrf := oTmpGrf:getInstance( BARCHART )
		
		oTmpGrf:setTitle("Curva ABC " + aArray[nContGrf][4], CONTROL_ALIGN_CENTER)
		oTmpGrf:setPicture(aArray[nContGrf][5])
		oTmpGrf:setLegend ( CONTROL_ALIGN_CENTER )
		
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
	    aADD(aStruct, { ALLTRIM(Posicione("GU3", 1, xFilial("GU3") + (cAlias)->GU3_CDEMIT, "GU3_NMEMIT") ),(cAlias)->&(cCampo), (cAlias)->&(cCampo + "_CL")})
		(cAlias)->(dbSkip())
	EndDo  
	
	aSORT(aStruct,,,{ |x,y| x[2] > y[2] }) //Ordena o array do maior para o menor
Return aStruct           
//=========================================================================/
Static Function CriaGrid(oDialog)
	Local nCont
	Local aCampos := aGFEC024
	
	(cAlias_Inf)->(dbSetOrder(7))
	                      						
	oBrowse := FWMBrowse():New()  
	oBrowse:SetAlias(cAlias_Inf)	
	oBrowse:SetMenuDef('GFEC024')				    
	oBrowse:SetDescription("Transportadores") 
		
	For nCont := 1 to Len( aCampos ) 
	 	oBrowse:AddColumn({aCampos[nCont][1],&("{|| (cAlias_Inf)->" + aCampos[nCont][2] + "}"),aCampos[nCont][3],aCampos[nCont][6],aCampos[nCont][7],aCampos[nCont][4],aCampos[nCont][5],.T.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.T.,{}})
	Next nCont
 
 	oBrowse:SetLocate()
 	oBrowse:SetOwner(oDialog)            
	oBrowse:DisableDetails() 
	oBrowse:ForceQuitButton(.T.)
	oBrowse:SetWidthColumns({7,30,7,2,2,2,7,2,2,2,7,2,2,2,7,2,2,2})
   	oBrowse:Activate()
Return  
//=========================================================================/
Static Function MenuDef()   
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Visualizar" ACTION 'GFEC024EMI()'    OPERATION 1  ACCESS 0 //"Visualizar"
Return aRotina                                      
//=========================================================================/
Function GFEC024EMI()   
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
	Local aDiD := {7,8,9,10}
	Local aDFV := {3,4,5,6}
	Local aDiv := {15,16,17,18}
	Local aFat := {11,12,13,14}
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
		Case cSubItem == "DiD"
			aPes := aDiD
			(cAlias_Inf)->(dbSetOrder(6))
		Case cSubItem == "DFV"
			aPes := aDFV
			(cAlias_Inf)->(dbSetOrder(7))
		Case cSubItem == "Div"
			aPes := aDiv
			(cAlias_Inf)->(dbSetOrder(8))
		Case cSubItem == "Fat"
			aPes := aFat
			(cAlias_Inf)->(dbSetOrder(9))
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
	Local cTmp   := ''

	cQuery := " SELECT  "
	cQuery += " 	GU3.GU3_CDEMIT, GU3.GU3_CDGRGL, GU1.GU1_DSGREM, "
	cQuery += " 	(SELECT COUNT(*)         FROM "+RetSQLName( 'GW6' )+" WHERE (GW6_SITAPR = '2' OR GW6_SITAPR = '4') AND GW6_EMIFAT = GU3_CDEMIT AND " + SQLWhereQuery("GW6_FILIAL","GW6_DTCRIA",aParam) + " )DIV_FT, "
	cQuery += " 	(SELECT SUM(GW6_VLFATU)  FROM "+RetSQLName( 'GW6' )+" WHERE (GW6_SITAPR = '2' OR GW6_SITAPR = '4') AND GW6_EMIFAT = GU3_CDEMIT AND " + SQLWhereQuery("GW6_FILIAL","GW6_DTCRIA",aParam) + " )DIVFTV, "
	cQuery += " 	(SELECT COUNT(*) 		 FROM "+RetSQLName( 'GW3' )+" WHERE (GW3_SIT = '2' OR GW3_SIT = '4' OR GW3_SIT = '5') AND GW3_EMISDF = GU3_CDEMIT AND " + SQLWhereQuery("GW3_FILIAL","GW3_DTENT",aParam) + " )DIV_DF, "
	cQuery += " 	(SELECT SUM(GW3_VLDF)    FROM "+RetSQLName( 'GW3' )+" WHERE (GW3_SIT = '2' OR GW3_SIT = '4' OR GW3_SIT = '5') AND GW3_EMISDF = GU3_CDEMIT AND " + SQLWhereQuery("GW3_FILIAL","GW3_DTENT",aParam) + " )DIVDFV "
	cQuery += " FROM " + RetSQLName( 'GU3' ) + " GU3 "
	cQuery += "   LEFT JOIN " + RetSQLName( 'GU1' ) + " GU1 ON GU1.GU1_CDGREM = GU3.GU3_CDGRGL"
    cQuery += "                       AND GU1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE GU3.GU3_TRANSP = '1' GROUP BY GU3.GU3_CDEMIT, GU3.GU3_CDGRGL, GU1.GU1_DSGREM"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
	dbSelectArea(cTmp)
	dbGoTop()
	While (cTmp)->(!Eof()) 
		RecLock(cAlias_Inf, .T.)
		(cAlias_Inf)->GU3_CDEMIT := (cTmp)->GU3_CDEMIT  													//transportador
		(cAlias_Inf)->GU3_NMEMIT := Posicione("GU3", 1, xFilial("GU3") + (cTmp)->GU3_CDEMIT, "GU3_NMEMIT") //nome do transportador
		(cAlias_Inf)->GU3_CDGRGL := (cTmp)->GU3_CDGRGL
		(cAlias_Inf)->GU1_DSGREM := (cTmp)->GU1_DSGREM
		(cAlias_Inf)->DIV_DF      := If(Empty((cTmp)->DIV_DF),0,(cTmp)->DIV_DF)     // Quatidade de DF com divergencias (Bloqueados ou Aprov. Usuario)
		(cAlias_Inf)->DIVDFV      := If(Empty((cTmp)->DIVDFV ),0,(cTmp)->DIVDFV)     // Valor dos DF com Divergencias por transportador  
		(cAlias_Inf)->DIV_FT 	     := If(Empty((cTmp)->DIV_FT),0,(cTmp)->DIV_FT)     // Quatidade de Faturas com divergencias (Bloqueados ou Aprov. Usuario)
		(cAlias_Inf)->DIVFTV      := If(Empty((cTmp)->DIVFTV ),0,(cTmp)->DIVFTV)     //  Valor das Faturas com Divergencias por transportador 
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
	Local aTotal := Array(4)
	Local nCont
	Local aArea := (cAlias_Inf)->(GetArea()) 
	Local lCorteA := .F. , lCorteB  := .F. // Variavel que indica se já foi classificado algum registro como A ou B
	Local nPDf   := 0
	Local nPVcFv := 0
	Local nPFt   := 0
	Local nPFtTv := 0
	
	AFILL(aTotal,0)
	
	dbSelectArea(cAlias_Inf)
	dbGoTop()
	While !( (cAlias_Inf)->(Eof()) )
		 aTotal[1] :=  (cAlias_Inf)->DIV_DF     + aTotal[1]
		 aTotal[2] :=  (cAlias_Inf)->DIVDFV  + aTotal[2]
		 aTotal[3] :=  (cAlias_Inf)->DIV_FT     + aTotal[3]
		 aTotal[4] :=  (cAlias_Inf)->DIVFTV  + aTotal[4]
		(cAlias_Inf)->(dbSkip())
	EndDo                          
	
	dbSelectArea(cAlias_Inf)
	dbGoTop()
	While !( (cAlias_Inf)->(Eof()) )
	 	RecLock((cAlias_Inf),.F.)
		(cAlias_Inf)->DIV_DF_PE  := IF(Empty( (cAlias_Inf)->DIV_DF    )  ,0,ROUND(( (cAlias_Inf)->DIV_DF      * 100 ) / aTotal[1],2) )  
		(cAlias_Inf)->DIVDFV_PE  := IF(Empty( (cAlias_Inf)->DIVDFV )  ,0,ROUND(( (cAlias_Inf)->DIVDFV   * 100 ) / aTotal[2],2) ) 
		(cAlias_Inf)->DIV_FT_PE  := IF(Empty( (cAlias_Inf)->DIV_FT    )  ,0,ROUND(( (cAlias_Inf)->DIV_FT      * 100 ) / aTotal[3],2) ) 
		(cAlias_Inf)->DIVFTV_PE  := IF(Empty( (cAlias_Inf)->DIVFTV )  ,0,ROUND(( (cAlias_Inf)->DIVFTV   * 100 ) / aTotal[4],2) ) 
		MsUnlock()
		
		nPDf   += (cAlias_Inf)->DIV_DF_PE
		nPVcFv += (cAlias_Inf)->DIVDFV_PE
		nPFt   += (cAlias_Inf)->DIV_FT_PE
		nPFtTv += (cAlias_Inf)->DIVFTV_PE
		
		(cAlias_Inf)->(dbSkip())
	EndDo                          
	
	/* Correção dos percentuais */
	AjusPerc(2, "DIV_DF_PE", nPDf)
	AjusPerc(3, "DIVDFV_PE", nPVcFv)
	AjusPerc(4, "DIV_FT_PE", nPFt)
	AjusPerc(5, "DIVFTV_PE", nPFtTv)
	
	aArray := {{2,"DIV_DF_PE","DIV_DF_PA","DIV_DF_CL"},;
				{3,"DIVDFV_PE","DIVDFV_PA","DIVDFV_CL"},;
				{4,"DIV_FT_PE","DIV_FT_PA","DIV_FT_CL"},;
				{5,"DIVFTV_PE","DIVFTV_PA","DIVFTV_CL"} }
	
	For nCont := 1 To Len(aArray)
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
Return Nil 

Static Function AjusPerc(nIndice, cCampo, nAcum)
	dbSelectArea(cAlias_Inf)
	(cAlias_Inf)->(dbSetOrder(nIndice))
	(cAlias_Inf)->(dbGoBottom())
	RecLock((cAlias_Inf),.F.) 
	(cAlias_Inf)->&(cCampo) := (cAlias_Inf)->&(cCampo) + (100 - nAcum)
	MsUnlock()
Return Nil
