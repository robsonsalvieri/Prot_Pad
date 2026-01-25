#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC012A
Análise de Despesa de Transporte por Períodos
Generico

@sample
GFEC012A(aParam)

Estrutura aParam
aParam[1] - Array com as filiais
aParam[2] - Tipo de Periodo
aParam[3] - Data Ref
aParam[4] - Qtd de periodos
aParam[5] - Grupo de Transp 
aParam[6] - Transp de
aParam[7] - Transp até
aParam[8] - Tipo de Frete

@author Felipe M. / Alan Victor Lamb
@since 26/07/12
@version 1.0                                                                          
*/
//------------------------------------------------------------------------------------------------  
Function GFEC012A(aParam)
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := 'Análise de Frete Previsto por Períodos' 
	
	Private aParamPadrao := aParam
	Private oTree 
	Private cNodeAnt := "1"  // armazena o nó anterior 
	Private oProcess := Nil  // barras de processamento
	
	// Carrega os intervalos de datas conforme parâmetros informados
	Private aIntervalos := GFEC011INT(aParam[2],aParam[4],aParam[3])    
	
	/*
	Frete Previsto por Período
	Frete Previsto/Tonelada por Período
	Frete Previsto/Volume por Período
	Frete Previsto/Valor Carga por Período
	Frete Previsto/Quantidade por Período
	Transportadores Contratados
	*/
	
	// Array com os dados do grafico
	Private aFrtPrev := {}
	Private aPrevTon := {}
	Private aPrevVol := {}
	Private aPrevVal := {}
	Private aPrevQtd := {}
	Private aTrpCont := {}

	//Objetos
	Private oGrf
	Private oPnlGraf 
	Private oFolder
	Private oBrwGraf 
	Private aObjetos // Array com a relação de obejtos graficos e os arrays de dados. Utilizado no loop de construção dos graficos	
	
	/*
	Estrutura aObjetos 
	aObjetos[][1] - Nome do Array com os dados para o Grafico
	aObjetos[][2] - Titulo do Grafico
	aObjetos[][3] - Picture dos dados
	*/
	
	aObjetos := {{"aFrtPrev", "Frete Previsto", "@E 999,999,999.99"}   ,;
				   {"aPrevTon", "Frete Previsto por Tonelada", "@E 999,999,999.99"}   ,;
				   {"aPrevVol", "Frete Previsto por Volume", "@E 999,999,999.99"}   ,;
				   {"aPrevVal", "Frete Previsto por Valor Carga", "@E 999,999,999.99"}   ,;
				   {"aPrevQtd", "Frete Previsto por Quantidade", "@E 999,999,999.99"}   ,;
				   {"aTrpCont", "Transportadores Contratados", "@E 999,999,999"}}     
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel     
	
	/*Criando objeto Layer*/
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)  
	
	/***Criando coluna esquerda (Tree)****/
	oFWLayer:AddLine('LINE_TOP',50,.F.) 							
	oFWLayer:AddCollumn('COL_TOP_LEFT',20,.T.,'LINE_TOP') 			
	oFWLayer:AddWindow('COL_TOP_LEFT','WIN_TOP_LEFT','Opções',100,.T.,.F.,,'LINE_TOP',)
    oWIN_TOP_LEFT := oFWLayer:GetWinPanel('COL_TOP_LEFT','WIN_TOP_LEFT','LINE_TOP')
	
	/***Criando coluna direita (Browse)****/	
	oFWLayer:AddCollumn('COL_TOP_RIGHT',80,.T.,'LINE_TOP') 			
	oWIN_TOP_RIGHT := oFWLayer:GetColPanel('COL_TOP_RIGHT','LINE_TOP') 			
    
 	/***Criando Linha abaixo (Grafico)****/
   	oFWLayer:AddLine('LINE_BOTTOM',50,.F.)   		
	oFWLayer:AddCollumn('COL_BOTTOM',100,.T.,'LINE_BOTTOM') 			
	oFWLayer:AddWindow('COL_BOTTOM','WIN_BOTTOM',,100,.T.,.F.,,'LINE_BOTTOM',)
    oWIN_BOTTOM := oFWLayer:GetWinPanel('COL_BOTTOM','WIN_BOTTOM','LINE_BOTTOM')
     
    oProcess := MsNewProcess():New({||Carregar(aParam,oWIN_TOP_LEFT,oWIN_TOP_RIGHT,oWIN_BOTTOM)}, "Carregando consultas", "Iniciando processo...")
     
 	// Ativa a janela e efetua a carga das consultas e criação dos browsers
	oDLG:Activate(,,,.T.,,,{||oProcess:Activate()})
Return 
//=============================================================
Static Function Carregar(aParam,oWIN_TOP_LEFT,oWIN_TOP_RIGHT,oWIN_BOTTOM)
	oProcess:setRegua1(6)
	
	oProcess:incRegua1("Iniciando... ")
	CriaTree(oWIN_TOP_LEFT)
	
	oProcess:incRegua1()
	CriaGrid(oWIN_TOP_RIGHT)
	
	oProcess:incRegua1()
	CarregaDados(aParam,'',.T.)
	
	oProcess:incRegua1()
	CriaPanel(oWIN_BOTTOM)
	
	oProcess:incRegua1() 
	CriaGrafico()
	
	oProcess:incRegua1()
	CriaGrGraf(aParam, GridArray())
Return Nil
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
	oProcess:setRegua2(3)
	oProcess:incRegua2("Criando menu...")
    
    /* Cria o objeto Tree*/
	oFont := TFont():New('Arial',,-12,.T.)
	oTree := DbTree():New(0,0,0,0,oDialog,{|| ChangeItem()},,.T.,,oFont)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT                                        
	
	oProcess:incRegua2()
	
	/*Adiciona os Nós*/
	oTree:AddItem("Frete Previsto     ", "1" , "FOLDER5" ,,,,1)    
	oTree:AddItem("$ por Tonelada"      , "2" , "FOLDER5" ,,,,1)    
	oTree:AddItem("$ por m³"		        , "3" , "FOLDER5" ,,,,1)    
	oTree:AddItem("$ por Valor Carga"	, "4" , "FOLDER5" ,,,,1)    
   	oTree:AddItem("$ por Qtde Itens"    , "5" , "FOLDER5" ,,,,1)    
 	oTree:AddItem("Transp Contratados"	, "6" , "FOLDER5" ,,,,1)
 	
 	oProcess:incRegua2()			  
Return Nil

//=========================================================================/
//Função responsavel por criar o grid, recebe o painel "pai"
//=========================================================================/
Static Function CriaGrid(oDialog)
	Local aCols := {}
	Local nI := 0
	
	oProcess:setRegua2(3)
	oProcess:incRegua2("Criando browse rateios de frete...")
	
	oBrowse := FWMBrowse():New()  
	oBrowse:SetAlias("GWM")	
	oBrowse:DisableConfig()
	oBrowse:SetDescription("Rateios de Frete")
	oBrowse:SetLocate()
	oBrowse:SetMenuDef("")
	oBrowse:SetOwner(oDialog)
	oBrowse:DisableDetails()
	oBrowse:SetProfileID("1")
	oBrowse:BVLDEXECFILTER := {|aParam| GFEC012AFL(aParam)}
	oBrowse:ForceQuitButton(.T.)
	oBrowse:SetFilterDefault("@"+GFEC012ABR())
	
	oProcess:incRegua2()	
	oBrowse:Activate()
	
	oBrowse:DelColumn(2)
	oBrowse:DelColumn(4)
	oBrowse:UpdateBrowse()
	
	oProcess:incRegua2()
Return  

//
// Cria array de dados para o grid que exibe as séries dos gráficos
// 
Static Function GridArray()
	Local nCount := 0
	Local aGraf := {}
	
	For nCount := 1 To Len(aFrtPrev)
		AADD(aGraf, {aFrtPrev[nCount, 1], aFrtPrev[nCount, 2], ;
			  aFrtPrev[nCount, 3], aPrevTon[nCount, 3], aPrevVol[nCount, 3],;
			  aPrevVal[nCount, 3], aPrevQtd[nCount, 3], aTrpCont[nCount, 3]})
	Next nCount
Return aGraf

//
// Utilizada para atualizar o Grid de dados das séries
//
Static Function AtuGrid(aDados)
	oBrwGraf:SetArray(aDados)
	oBrwGraf:UpdateBrowse()
Return	

//
// Cria o Grid para exibição dos valores das séries dos gráficos
//
Static Function CriaGrGraf(aParam, aDados)
	Local cTpPeriodo 	:= aParam[2]
	
	oBrwGraf := FWBrowse():New()
	oBrwGraf:SetOwner(oFolder:aDialogs[2])
	oBrwGraf:SetDescription("Dados")
	oBrwGraf:SetDataArray()
	oBrwGraf:DisableFilter()
	oBrwGraf:DisableConfig()
	
	oBrwGraf:SetArray(aDados)
	oBrwGraf:SetColumns(GFEC011COL("De",1,,1,10))
	
	If cTpPeriodo != 5 // Se for diário não adiciona a coluna "Até"
		oBrwGraf:SetColumns(GFEC011COL("Até",2,,1,10))
	EndIf
	
	oBrwGraf:SetColumns(GFEC011COL("Frete Previsto",3,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("$ por Tonelada",4,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("$ por m³",5,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("$ por Valor Carga",6,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("$ por Qtde Itens",7,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("Transp Contratados",8,"@E 999,999,999",2,20))
	oBrwGraf:SetColumns(GFEC011COL("",,,,2))
	oBrwGraf:Activate()
Return Nil
       
//=========================================================================/
Function GFEC012ABR()                                                       
Local nQtdFil := Len(aParamPadrao[1])
Local cQuery  := ""

	/*
	aParam[1] - Array com as filiais
	aParam[2] - Tipo de Periodo
	aParam[3] - Data Ref
	aParam[4] - Qtd de periodos
	aParam[5] - Grupo de Transp 
	aParam[6] - Transp de
	aParam[7] - Transp até */

	// Valida as filiais selecionadas no browse
	// O primeiro 'AND' o próprio totvstec coloca
	If nQtdFil == 1
		cQuery := " GWM_FILIAL = '"+aParamPadrao[1][1]+"'"
	Else
		cQuery := " GWM_FILIAL >= '"+aParamPadrao[1][1]+"' AND GWM_FILIAL <= '"+aParamPadrao[1][nQtdFil]+"'"
	EndIf

	// Valida o tipo do documento de carga, deve ser igual a 1 = Calculo Frete (previsto)
	cQuery += " AND GWM_TPDOC = '1'"

	// Valida a data de emissão do documento de carga
	cQuery += " AND EXISTS(SELECT 1 FROM "+RetSqlName('GW1')+" GW1"
	cQuery +=             " WHERE GW1.GW1_FILIAL = GWM_FILIAL"
	cQuery +=               " AND GW1.GW1_CDTPDC = GWM_CDTPDC"
	cQuery +=               " AND GW1.GW1_EMISDC = GWM_EMISDC"
	cQuery +=               " AND GW1.GW1_SERDC  = GWM_SERDC"
	cQuery +=               " AND GW1.GW1_NRDC   = GWM_NRDC"
	cQuery +=               " AND GW1.GW1_DTEMIS >= '"+DtoS(aIntervalos[Len(aIntervalos)][1])+"'"
	cQuery +=               " AND GW1.GW1_DTEMIS <= '"+DtoS(aIntervalos[1][2])+"'"
	cQuery +=               " AND GW1.D_E_L_E_T_ = ' ')"

	// Valida grupo do transportador
	If !Empty(aParamPadrao[5]) 
		cQuery += " AND EXISTS(SELECT 1 FROM "+RetSqlName('GU3')+" GU3"
		cQuery +=             " WHERE GU3.GU3_FILIAL = '"+xFilial('GU3')+"'"
		cQuery +=               " AND GU3.GU3_CDEMIT = GWM_CDTRP"
		cQuery +=               " AND GU3.GU3_CDGRGL = '"+aParamPadrao[5]+"'"
		cQuery +=               " AND GU3.D_E_L_E_T_ = ' ')"
	Else
		cQuery += " AND GWM_CDTRP >= '"+aParamPadrao[6]+"'"
		cQuery += " AND GWM_CDTRP <= '"+aParamPadrao[7]+"'"
	EndIf

Return cQuery 

//=========================================================================/
//Função responsavel por adaptar o filtro do Browse na Query SQL
//=========================================================================/
Function GFEC012AFL(aParam)
	Local nCont
	Local cFiltro := ""
	 
	For nCont := 1 to Len(aParam)
		If !aParam[nCont][5]
	       	If !Empty(cFiltro)
	       		cFiltro := cFiltro + " AND (" + aParam[nCont][3] + ")"
	       	Else
	       	    cFiltro := " AND (" +  aParam[nCont][3] + ")"
	       	EndIf
		EndIf
	Next nCont
	
	CarregaDados(aParamPadrao,cFiltro)
	GFEC011GRA(oGrf,&(aObjetos[Val(cNodeAnt)][1]),.T.,aObjetos[Val(cNodeAnt)][2],aObjetos[Val(cNodeAnt)][3])
	AtuGrid(GridArray())
Return 
//=========================================================================/ 
//Cria todos os paineis que conteram os graficos, recebe como parametro o Dialog "pai" 
//=========================================================================/
Static Function CriaPanel(oOwner)
	oFolder :=  tFolder():New(30,0,{"Gráfico","Dados"},{"GRAFICO","TABELA"}, oOwner,)
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPnlGraf := tPanel():New(30,0,,oFolder:aDialogs[1],,,,,,)
	oPnlGraf:Align := CONTROL_ALIGN_ALLCLIENT
Return Nil
//=========================================================================/ 
//Função responsavel por criar os graficos, utiliza o array aObjetos para criar os graficos dinamicamente
//=========================================================================/
Static Function CriaGrafico()   
	Local nCont, nCont1
	
 	oGrf := FWChartFactory():New()
 	oGrf := oGrf:getInstance( BARCHART )
 	oGrf:Init(oPnlGraf,.F.)
 	oGrf:setTitle( aObjetos[1][2], CONTROL_ALIGN_CENTER) 
 	oGrf:setLegend( CONTROL_ALIGN_RIGHT  )
 	GFEC011GRA(oGrf,&(aObjetos[1][1]),,aObjetos[1][2],aObjetos[1][3])
Return Nil
//=========================================================================/

/*===================================================================*/
//Função responsavel por criar a condição SQL de filiais, Param: Campo (ex: GW1_FILIAL) e o Array com as filiais
//Retorna a expressão Query montada
/*===================================================================*/
Static Function QueryFilial(cCampo,aFilial)
	Local cQuery
	Local nCont
	
	cQuery := " ( "
	For nCont := 1 to len(aFilial)    
	
		If nCont > 1
			cQuery += " OR "	
		EndIf  
		cQuery += cCampo + " = '" +aFilial[nCont]+ "' "
	
	Next nCont
	cQuery += " ) "
Return cQuery  

//=========================================================================/
//Carrega os dados para os graficos
/*
Estrutura aParam
aParam[1] - Array com as filiais
aParam[2] - Tipo de Periodo
aParam[3] - Data Ref
aParam[4] - Qtd de periodos
aParam[5] - Grupo de Transp 
aParam[6] - Transp de
aParam[7] - Transp até
*/
//=========================================================================/
Static Function CarregaDados(aParam,cBrwFiltro,lProcess)
	Local nCont
	Local cTpPeriodo 	    := aParam[2]
	Local cGrupoTransp 	:= aParam[5] 
	Local cTranspDe  	    := aParam[6]
	Local cTranspAte 	    := aParam[7]
	Local cParamData      := ""
	Local cQuery           := ""
	Default cBrwFiltro    := ''
	Default lProcess      := .F.   
	Private cWhere         := ''
	
	If lProcess
		oProcess:setRegua2(Len(aIntervalos))
		oProcess:incRegua2("Realizando consultas")
	EndIf
	
    If !Empty(cGrupoTransp)
	    cQueryTransp := " ( GU3_CDGRGL = '"+cGrupoTransp+"' ) AND "
	Else
		cQueryTransp := " ( GU3_CDEMIT >= '"+cTranspDe+"' AND GU3_CDEMIT <= '"+cTranspAte+"' ) AND "   
	EndIf
 	   
	aFrtPrev := {}
	aPrevTon := {}
	aPrevVol := {}
	aPrevVal := {}
	aPrevQtd := {}
	aTrpCont := {}
				
	For nCont := 1 To Len(aIntervalos)
        If cTpPeriodo != 5
			cParamData := " GW1_DTEMIS >= '"+DtoS(aIntervalos[nCont][1])+"' AND GW1_DTEMIS <= '"+DtoS(aIntervalos[nCont][2])+"' "
		Else
			cParamData := " GW1_DTEMIS = '"+DtoS(aIntervalos[nCont][1])+"' "
		EndIf
		
		/*Cria a variavel cWhere*/
		cWhere := cQueryTransp 
		cWhere += cParamData + " AND GWM_TPDOC = '1' AND  "
		cWhere += QueryFilial("GW1_FILIAL",aParam[1]) + cBrwFiltro 
		cWhere += " AND GWM.D_E_L_E_T_ =  ' ' "
		cWhere += " AND GW1.D_E_L_E_T_ =  ' ' "
		cWhere += " AND GU3.D_E_L_E_T_ =  ' ' "
		
		cQuery := ""
		cQuery += "  SELECT SUM(GWM_VLFRET)FRT_PREV,"
		cQuery += "		  CASE WHEN SUM(GW8_PESOR) > 0 THEN (SUM(GWM_VLFRET) / SUM(GW8_PESOR) * 1000) ELSE 0 END FRT_PESOR,"
		cQuery += "		  CASE WHEN SUM(GW8_VOLUME) > 0 THEN (SUM(GWM_VLFRET) / SUM(GW8_VOLUME)) ELSE 0 END FRT_VOLUME,"
		cQuery += "		  CASE WHEN SUM(GW8_VALOR) > 0 THEN (SUM(GWM_VLFRET) / SUM(GW8_VALOR)) ELSE 0 END FRT_VALOR,"
		cQuery += "		  CASE WHEN SUM(GW8_QTDE) > 0 THEN (SUM(GWM_VLFRET) / SUM(GW8_QTDE)) ELSE 0 END FRT_QDTE"  	     
		cQuery += "    FROM "+RetSQLName( 'GWM' )+ " GWM "
		cQuery += "   INNER JOIN "+RetSQLName( 'GW1' )+ " GW1 ON GWM_FILIAL = GW1.GW1_FILIAL" 
		cQuery += "			AND GWM_CDTPDC = GW1.GW1_CDTPDC "
		cQuery += "					AND GWM_EMISDC = GW1.GW1_EMISDC" 
		cQuery += "					AND GWM_SERDC  = GW1.GW1_SERDC"  
		cQuery += "					AND GWM_NRDC   = GW1.GW1_NRDC"  
		cQuery += "   INNER JOIN (SELECT GW8_FILIAL,"
		cQuery += "					  GW8_CDTPDC,"
		cQuery += "					  GW8_EMISDC,"
		cQuery += "					  GW8_SERDC,"
		cQuery += "					  GW8_NRDC,"
		cQuery += "					  SUM(GW8_PESOR) GW8_PESOR,"
		cQuery += "					  SUM(GW8_VOLUME) GW8_VOLUME,"
		cQuery += "					  SUM(GW8_VALOR) GW8_VALOR,"
		cQuery += "					  SUM(GW8_QTDE) GW8_QTDE"
		cQuery += "				 FROM "+RetSQLName( 'GW8' )
		cQuery += "			    WHERE D_E_L_E_T_ =  ' ' "
		cQuery += "				GROUP BY GW8_FILIAL," 
		cQuery += "				GW8_CDTPDC,"
		cQuery += "				GW8_EMISDC,"
		cQuery += "				GW8_SERDC,"
		cQuery += "				GW8_NRDC) GW8 ON GW8.GW8_FILIAL = GW1.GW1_FILIAL" 
		cQuery += "				    AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC "
		cQuery += "					AND GW8.GW8_EMISDC = GW1.GW1_EMISDC" 
		cQuery += "					AND GW8.GW8_SERDC  = GW1.GW1_SERDC"  
		cQuery += "					AND GW8.GW8_NRDC   = GW1.GW1_NRDC" 
		cQuery += "   INNER JOIN "+RetSQLName( 'GU3' )+ " GU3 ON GWM_CDTRP = GU3_CDEMIT"  
		cQuery += "   WHERE " + cWhere
		
		cTmp := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
		dbSelectArea(cTmp)	
		(cTmp)->(dbGoTop())
		
		If (cTmp)->(Eof())
			aADD(aFrtPrev   ,{aIntervalos[nCont][1],aIntervalos[nCont][2],0})
			aADD(aPrevTon   ,{aIntervalos[nCont][1],aIntervalos[nCont][2],0})
			aADD(aPrevVol   ,{aIntervalos[nCont][1],aIntervalos[nCont][2],0})
			aADD(aPrevVal   ,{aIntervalos[nCont][1],aIntervalos[nCont][2],0}) 		
			aADD(aPrevQtd   ,{aIntervalos[nCont][1],aIntervalos[nCont][2],0})
		EndIf
		
		While (cTmp)->(!Eof())
			aADD(aFrtPrev   ,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->FRT_PREV 		} )
			aADD(aPrevTon   ,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->FRT_PESOR      } )
			aADD(aPrevVol   ,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->FRT_VOLUME     } )
			aADD(aPrevVal   ,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->FRT_VALOR      } ) 		
			aADD(aPrevQtd   ,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->FRT_QDTE       } ) 
			(cTmp)->(dbskip())	
		EndDo

		(cTmp)->(dbCloseArea())   
		
		cQuery := " SELECT GWM_CDTRP FROM "+RetSQLName( 'GWM' )+ " GWM "
		cQuery += " JOIN "+RetSQLName( 'GU3' )+ " GU3 ON "
		cQuery += " 	GWM_CDTRP = GU3_CDEMIT  AND GU3.D_E_L_E_T_ =  ' ' "
		cQuery += " JOIN "+RetSQLName( 'GW1' )+ " GW1 ON "
		cQuery += " 	GWM_FILIAL = GW1_FILIAL AND "
   		cQuery += " 	GWM_CDTPDC = GW1_CDTPDC AND "
		cQuery += " 	GWM_EMISDC = GW1_EMISDC AND "
		cQuery += " 	GWM_SERDC  = GW1_SERDC  AND " 
		cQuery += " 	GWM_NRDC   = GW1_NRDC AND "
		cQuery += "   GW1.D_E_L_E_T_ =  ' ' "
		cQuery += " WHERE GWM_CDTRP <> '' AND GWM.D_E_L_E_T_ =  ' ' AND " + cWhere
		cQuery += " GROUP BY GWM_CDTRP "
		 
		nCont1 := 0
		
		cTmp := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
		dbSelectArea(cTmp)
		(cTmp)->(dbGoTop())
		
		While (cTmp)->(!Eof())
			nCont1 += 1
			(cTmp)->(dbSkip())
		EndDo
		
		aADD(aTrpCont,{aIntervalos[nCont][1],aIntervalos[nCont][2],nCont1})
		
		(cTmp)->(dbCloseArea())
		
	    If lProcess
			oProcess:incRegua2()
		EndIf
	Next nCont
	GFEDelTab(cTmp)
Return                  


/*===================================================================*/
//Função que esconde o painel do nó anterior e mostra o painel do nó selecionado  
/*===================================================================*/  
Static Function ChangeItem()
	Local cNode := AllTrim(Substr(oTree:GetCargo(), 1, 6))

	CursorWait()
	   
    GFEC011GRA(oGrf,&(aObjetos[Val(cNode)][1]),.T.,aObjetos[Val(cNode)][2],aObjetos[Val(cNode)][3])
	
	oBrwGraf:SetColumnOrder((Val(cNode)+2),3)
	oBrwGraf:UpdateBrowse()
	
	cNodeAnt := cNode // Armazena o nó  
	
	CursorArrow()
Return Nil
