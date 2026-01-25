#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------------------------------------
/*{Protheus.doc} GFEC022
Curva ABC Transportador por Fretes
Uso Interno   
  
@author Felipe Mendes
@since 07/05/12
@version 1.0                                                                                      
*/
//------------------------------------------------------------------------------------------------ 
Function GFEC022() 
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Curva ABC de Transportadores por Despesa de Frete'   
	Local aParam := Array(7) // Armazena os valores do Pergunte
	Private oTree
	Private cAlias_Inf // Alias que conterá a tabela com todas as informações
	Private cNodeTree := "DES_FrR"	 //Variavel responsavel por armazenar o nó atual,
	Private oPnl_FrP,   oGrf_FrP,;  //objetos do "Frete Previsto"
			oPnl_FrR,   oGrf_FrR  //objetos do "Frete Realizado"		
	
	Private nTopGraf := 10
	Private oBrowse
	
	//Array principal que contém todos os campos e suas definições
	Private aGFEC023 := ;
	{{"Transp."					   ,"GU3_CDEMIT","C",14,0,""                   ,1},;  //Cod do transportador
	{"Nome do Transp."			   ,"GU3_NMEMIT","C",50,0,""                   ,1},;  //Nome do transp
	{"Frete Realizado"			   ,"FRT_REA"   ,"N",15,4,"@E 999,999,999.99",2},;  //total do frete realizado
	{"%"		                       ,"FRT_REA_PE","N",6 ,2,"@E 999.99"         ,2},;   //Percentual - total do frete realizado
	{"% Acum"		                   ,"FRT_REA_PA","N",6 ,2,"@E 999.99"         ,2},;   //Percentual Acumulado - total do frete realizado
	{"Class"			               ,"FRT_REA_CL","C",1 ,0,""                   ,0},;   //Classificação  - total do frete realizado
	{"Frete Previsto"				   ,"FRT_PRE"   ,"N",15,4,"@E 999,999,999.99",2},;  //total do frete previsto
	{"%"		                       ,"FRT_PRE_PE","N",6 ,2,"@E 999.99"         ,2},;   //Percentual - total do frete previsto
	{"% Acum"		                   ,"FRT_PRE_PA","N",6 ,2,"@E 999.99"         ,2},;   //Percentual Acumulado - total do frete previsto
	{"Class"			               ,"FRT_PRE_CL","C",1 ,0,""                   ,0},;   //Classificação - total do frete previsto
	{"Grupo Tranp"		   		    ,"GU3_CDGRGL" ,"C",4 ,0,"@!",1					},; 
	{"Descrição Grupo"		   		,"GU1_DSGREM" ,"C",50,0,"@!",1					}}
	Private lReg := .F. //Verifica se há o retorno de dados da query
	
	
	If !Pergunte("GFEC022")
		Return
	Else
		aParam[1] := MV_PAR01//Filial de
		aParam[2] := MV_PAR02//Filial ate
		aParam[3] := MV_PAR03	//Data de
		aParam[4] := MV_PAR04	//Data ate    
		aParam[5] := MV_PAR05	//% de corte A  
		aParam[6] := MV_PAR06	//% de corte B 
		aParam[7] := MV_PAR07	//Qtde séries 
	EndIf
	
	nTopGraf := aParam[7]
	
	//Cria a tabela
	cAlias_Inf := CriaTab()    
	//Alimenta a tabela com as informações (não necessita informar o Alias, pois a variavel é Private)
	Processa({||QuerySQL(aParam)}, "Carregando dados da Curva ABC", "Aguarde...")
	If lReg
		Processa({||Percentual(aParam[5],aParam[6])}, "Gerando Curva ABC", "Aguarde...")
	Else
		msgInfo("Não há dados para serem exibidos.")
		Return	
	EndIf	
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel     
		/*Criando objeto Layer*/
		oFWLayer := FWLayer():New() // Método de criação do objeto da classe.
		oFWLayer:Init(oDLG,.F.)  				   					
		
		/***Criando coluna esquerda (Tree)****/
		oFWLayer:AddLine('LINE_TOP', 50, .F.) 							
		oFWLayer:AddCollumn('COL_TOP_LEFT',20,.T.,'LINE_TOP') 			
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
	Local aStruct := {}
	Local nCont
	                  
	For nCont := 1 to Len(aGFEC023)
		AADD(aStruct,{ aGFEC023[nCont][2],;  //Nome do campo
						 aGFEC023[nCont][3],;  //Tipo
						 aGFEC023[nCont][4],;  //Tamanho
						 aGFEC023[nCont][5] }) //Decimal
	Next nCont   
			 
	cAlias := GFECriaTab({aStruct,{ "GU3_CDEMIT",;
									    "STR(FRT_PRE_PE)+GU3_CDEMIT",;
									    "STR(FRT_REA_PE)+GU3_CDEMIT" ,;
								 	    "FRT_PRE_CL+STR(FRT_PRE_PA)+GU3_CDEMIT",;
									    "FRT_REA_CL+STR(FRT_REA_PA)+GU3_CDEMIT"}}) 
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
	
	oTree:AddItem("Frete Realizado","DES_FrR",cBmp,cBmpOpen,,,1)
	oTree:AddItem("Frete Previsto" ,"DES_FrP",cBmp,cBmpOpen,,,1) 
	 
	oTree:TreeSeek( "DES_FrR")  
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
	oPnl_FrP := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_FrP:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnl_FrR := tPanel():New(30,0,,oOwner,,,,,,0,0)
	oPnl_FrR:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPanelAtual := oPnl_FrR 

	oPnl_FrP:Hide()
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
	
	//Array que contém a relação dos Paineis, campos e objetos graficos
	aArray :={{ "oPnl_FrP","FRT_PRE","oGrf_FrP","Frete Previsto"       ,"@E 9999,999,999" },;
			   { "oPnl_FrR","FRT_REA","oGrf_FrR","Frete Realizado"      ,"@E 9999,999,999" }}
    
	//Percorre o Array e cria dinamicamente todos os paineis.
	For nContGrf := 1 to Len(aArray)
		oTmpPnl := &(aArray[nContGrf][1])
		 
		oTmpGrf := FWChartFactory():New()
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
			//Verifica se há mais de nTopGraf transp, caso haja, soma os transp restantes   
			If nCont > (nTopGraf - 1)
				//somando o resultado dos transp
				nOutrosTransp := 0 
				For nCont2 := nTopGraf To Len(aGrafico)
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
	DbSelectArea(cAlias)
	dbGoTop()
	While (cAlias)->(!Eof())
	    aADD(aStruct,{ALLTRIM(Posicione("GU3", 1, xFilial("GU3") + (cAlias)->GU3_CDEMIT, "GU3_NMEMIT")),(cAlias)->&(cCampo),(cAlias)->&(cCampo + "_CL")})
		(cAlias)->(dbSkip())
	EndDo  
	
	aSORT(aStruct,,,{ |x,y| x[2] > y[2] }) //Ordena o array do maior para o menor
Return aStruct           

//=========================================================================/
Static Function CriaGrid(oDialog)
	Local nCont
	Local aCampos := aGFEC023  
	
	(cAlias_Inf)->(dbSetOrder(5))
	                      						
	oBrowse := FWMBrowse():New()  
	oBrowse:SetAlias(cAlias_Inf)	
	oBrowse:SetMenuDef('GFEC023')				    
	oBrowse:SetDescription("Transportadores") 
		
	For nCont := 1 to Len(aCampos) 
	 	oBrowse:AddColumn({aCampos[nCont][1],&("{|| (cAlias_Inf)->" + aCampos[nCont][2] + "}"),aCampos[nCont][3],aCampos[nCont][6],aCampos[nCont][7],aCampos[nCont][4],aCampos[nCont][5],.T.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.T.,{} })
	Next nCont
 
 	oBrowse:SetLocate()
 	oBrowse:SetOwner(oDialog)            
	oBrowse:DisableDetails() 
	oBrowse:ForceQuitButton(.T.)
	oBrowse:SetWidthColumns({7,30,7,2,2,2,7,2,2,2})
   	oBrowse:Activate()
Return    
//=========================================================================/
Static Function MenuDef()   
	Local aRotina := {}	
	ADD OPTION aRotina TITLE "Visualizar" ACTION 'GFEC023EMI()'    OPERATION 1  ACCESS 0 //"Visualizar"
Return aRotina                                      
//=========================================================================/
Function GFEC023EMI()   
	dbSelectArea("GU3")
	dbSetOrder(1)
	If dbSeek(xFilial("GU3")+(cAlias_Inf)->GU3_CDEMIT)
		FWExecView("Frete Embarcador",'GFEA015', 1, , {|| .F. },{|| .F.},,,{|| .T.}) 
	EndIf
Return	
//=========================================================================/  
Static Function ChangeItem()
	Local cTabela 	 := AllTrim(Substr(oTree:GetCargo(), 1, 3))
	Local cSubItem := AllTrim(Substr(oTree:GetCargo(), 5, 3))
	Local oTmpPanel
	Local aFrR := {3,4,5,6}
	Local aFrP := {7,8,9,10}
	
	Local aPes
	
	If Empty(cSubItem) // Verifica se o nó selecionado é um nó raiz, se sim volta para o ultimo nó selecionado  
		Return 
	EndIf

	CursorWait() 
	
    oTmpPanel := &("oPnl_"+AllTrim(Substr(cNodeTree, 5, 3))) 
    oTmpPanel:Hide()
    oTmpPanel := &("oPnl_"+AllTrim(Substr(oTree:GetCargo(), 5, 3)))
    oTmpPanel:Show()
    
    Do Case
		Case cSubItem == "FrP"
			aPes := aFrP
			(cAlias_Inf)->(dbSetOrder(4))
		Case cSubItem == "FrR"
			aPes := aFrR
			(cAlias_Inf)->(dbSetOrder(5))
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
	 
	/*cQuery := " SELECT "
	cQuery += " 	GU3_CDEMIT, "
	cQuery += " 	(SELECT SUM(GWI_VLFRET) FROM "+RetSQLName( 'GWI' )+" JOIN "+RetSQLName( 'GWF' )+" ON GWF_NRCALC = GWI_NRCALC WHERE GWF_TRANSP = GU3_CDEMIT AND " + SQLWhereQuery("GWF_FILIAL","GWF_DTCRIA",aParam)  + " )FRT_PRE,	"
	cQuery += " 	(SELECT	SUM(GW3_VLDF)   FROM "+RetSQLName( 'GW3' )+" WHERE GW3_EMISDF = GU3_CDEMIT AND " + SQLWhereQuery("GW3_FILIAL","GW3_DTEMIS",aParam) + " )FRT_REA, "
	cQuery += " 	(SELECT SUM(GW3_VLDF)   FROM "+RetSQLName( 'GW3' )+" WHERE GW3_EMISDF = GU3_CDEMIT AND GW3_TPDF <> '1' AND GW3_TPDF <> '6' AND " + SQLWhereQuery("GW3_FILIAL","GW3_DTEMIS",aParam) + " )VL_ADIC, "
	cQuery += " 	(SELECT COUNT(*)        FROM "+RetSQLName( 'GW3' )+" WHERE GW3_EMISDF = GU3_CDEMIT AND GW3_TPDF <> '1' AND GW3_TPDF <> '6' AND " + SQLWhereQuery("GW3_FILIAL","GW3_DTEMIS",aParam) + " )QTD_ADI "
	cQuery += " FROM "+RetSQLName( 'GU3' )+" "
	cQuery += " WHERE GU3_TRANSP = '1' GROUP BY GU3_CDEMIT	"*/
	
	cQuery += "SELECT GU3.GU3_CDEMIT, GU3.GU3_CDGRGL, GU1.GU1_DSGREM,"
	cQuery += "   		SUM(CASE WHEN GWM.GWM_TPDOC = '1' THEN GWM.GWM_VLFRET END) FRT_PRE,"
	cQuery += "   		SUM(CASE WHEN GWM.GWM_TPDOC = '2' OR GWM.GWM_TPDOC = '3' THEN GWM.GWM_VLFRET END) FRT_REA"	   
    cQuery += "  FROM "+RetSQLName( 'GW1' )+" GW1 "
 	cQuery += " INNER JOIN "+RetSQLName( 'GWM' )+" GWM ON GWM.GWM_FILIAL = GW1.GW1_FILIAL"
 	cQuery += "				  AND GWM.GWM_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "				  AND GWM.GWM_EMISDC = GW1.GW1_EMISDC"
	cQuery += "				  AND GWM.GWM_SERDC  = GW1.GW1_SERDC"
	cQuery += "				  AND GWM.GWM_NRDC   = GW1.GW1_NRDC"
	cQuery += "				  AND GWM.D_E_L_E_T_ =  ' '  "
	cQuery += " INNER JOIN " + RetSQLName( 'GU3' ) + " GU3 ON GU3.GU3_CDEMIT = GWM.GWM_CDTRP"
	cQuery += "				  AND (GU3.GU3_TRANSP = '1' OR GU3.GU3_AUTON = '1')"
	cQuery += "				  AND GU3.D_E_L_E_T_ =  ' '"
	cQuery += "   LEFT JOIN " + RetSQLName( 'GU1' ) + " GU1 ON GU1.GU1_CDGREM = GU3.GU3_CDGRGL"
    cQuery += "                       AND GU1.D_E_L_E_T_ =  ' '"
	cQuery += " WHERE GW1.D_E_L_E_T_ =  ' '"
	cQuery += "   AND " + SQLWhereQuery("GW1.GW1_FILIAL","GW1.GW1_DTEMIS", aParam)
	cQuery += " GROUP BY GU3.GU3_CDEMIT, GU3.GU3_CDGRGL, GU1.GU1_DSGREM"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
	dbSelectArea(cTmp)
	dbGoTop()
	
	While (cTmp)->(!Eof())
		lReg := .T. 
		RecLock(cAlias_Inf, .T.)
		(cAlias_Inf)->GU3_CDEMIT := (cTmp)->GU3_CDEMIT  													//transportador
		(cAlias_Inf)->GU3_NMEMIT := Posicione("GU3", 1, xFilial("GU3") + (cTmp)->GU3_CDEMIT, "GU3_NMEMIT") //nome do transportador
		(cAlias_Inf)->GU3_CDGRGL := (cTmp)->GU3_CDGRGL
		(cAlias_Inf)->GU1_DSGREM := (cTmp)->GU1_DSGREM
		(cAlias_Inf)->FRT_PRE    := (cTmp)->FRT_PRE  //frete previsto
		(cAlias_Inf)->FRT_REA    := (cTmp)->FRT_REA  //frete realizado		
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
	Local aTotal := Array(2), nCont
	Local aArea := (cAlias_Inf)->(GetArea()) 
	Local lCorteA := .F. , lCorteB  := .F. // Variavel que indica se já foi classificado algum registro como A ou B
	Local nPFPre := 0
	Local nPFRea := 0
	
	AFILL(aTotal,0)

	dbSelectArea(cAlias_Inf)
	dbGoTop()
	While !((cAlias_Inf)->(Eof()))
		 aTotal[1] :=  (cAlias_Inf)->FRT_PRE   + aTotal[1]
		 aTotal[2] :=  (cAlias_Inf)->FRT_REA   + aTotal[2]
		
		(cAlias_Inf)->(dbSkip())
	EndDo                       

	dbSelectArea(cAlias_Inf)
	dbGoTop()
	While !((cAlias_Inf)->(Eof()))
		(cAlias_Inf)->FRT_PRE_PE := ROUND(( (cAlias_Inf)->FRT_PRE * 100 ) / aTotal[1],2)
		(cAlias_Inf)->FRT_REA_PE := ROUND(( (cAlias_Inf)->FRT_REA * 100 ) / aTotal[2],2)	 
		
		nPFPre += (cAlias_Inf)->FRT_PRE_PE
		nPFRea += (cAlias_Inf)->FRT_REA_PE
		
		(cAlias_Inf)->(dbSkip())
	EndDo
	
	/* Correção dos percentuais */
	AjusPerc(2, "FRT_PRE_PE", nPFPre)
	AjusPerc(3, "FRT_REA_PE", nPFRea)
	                    
	//Array com a relação dos indices e campos para armazenas o Percentual Acumulado
	aArray := {{2,"FRT_PRE_PE","FRT_PRE_PA","FRT_PRE_CL"},;
				{3,"FRT_REA_PE","FRT_REA_PA","FRT_REA_CL"}}

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
Return Nil
		   
Static Function AjusPerc(nIndice, cCampo, nAcum)
	dbSelectArea(cAlias_Inf)
	(cAlias_Inf)->(dbSetOrder(nIndice))
	(cAlias_Inf)->(dbGoBottom())
	RecLock((cAlias_Inf),.F.) 
	(cAlias_Inf)->&(cCampo) := (cAlias_Inf)->&(cCampo) + (100 - nAcum)
	MsUnlock()
Return Nil
