#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC011B
Análise de Ocorrências por Períodos
Generico

@sample
GFEC011B(aParam)

Estrutura aParam
aParam[1] - Array com as filiais
aParam[2] - Tipo de Periodo
aParam[3] - Data Ref
aParam[4] - Qtd de periodos
aParam[5] - Grupo de Transp 
aParam[6] - Transp de
aParam[7] - Transp até

@author Felipe M. / Alan Victor Lamb
@since 26/07/12
@version 1.0                                                                                      
*/
//------------------------------------------------------------------------------------------------ 
Function GFEC011B(aParam)
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := 'Análise de Ocorrências por Períodos'  
	
	Private aParamPadrao := aParam
	Private oTree 
	Private cNodeAnt := "1"  // armazena o nó anterior
	Private oProcess := Nil  // barras de processamento
	
	// Carrega os intervalos de datas conforme parâmetros informados
	Private aIntervalos := GFEC011INT(aParam[2],aParam[4],aParam[3])  
	
	// Array com os dados do grafico
	Private aNUMGWD   := {}
	Private aVALGWD   := {}   
	
	//Objetos da tela
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
	
	aObjetos := {{"aNUMGWD","Número de Ocorrências","@E 999,999,999"},;
			       {"aVALGWD", "Valor das Ocorrências","@E 999,999,999.99"}} 
 	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel     
	
	/*Criando objeto Layer*/
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDLG, .F. )  
	
	/***Criando coluna esquerda (Tree)****/
	oFWLayer:AddLine('LINE_TOP',50,.F.) 							
	oFWLayer:AddCollumn('COL_TOP_LEFT',20, .T.,'LINE_TOP') 			
	oFWLayer:AddWindow('COL_TOP_LEFT','WIN_TOP_LEFT','Opções',100,.T.,.F.,,'LINE_TOP',)
    oWIN_TOP_LEFT := oFWLayer:GetWinPanel('COL_TOP_LEFT','WIN_TOP_LEFT','LINE_TOP')
	
	/***Criando coluna direita (Browse)****/	
	oFWLayer:AddCollumn( 'COL_TOP_RIGHT',80,.T.,'LINE_TOP') 			
	oWIN_TOP_RIGHT := oFWLayer:GetColPanel('COL_TOP_RIGHT','LINE_TOP') 			
    
 	/***Criando Linha abaixo (Folder/Grafico/GridDados)****/
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
	CarregaDados(aParam,,.T.)
	
	oProcess:incRegua1()
	CriaPanel(oWIN_BOTTOM)
	
	oProcess:incRegua1() 
	CriaGrafico()
	
	oProcess:incRegua1()
	CriaGrGraf(aParam,GridArray())
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
    /* Cria o objeto Tree*/
	oFont := TFont():New('Arial',,-12,.T.)
	oTree := DbTree():New(0,0,0,0,oDialog,{|| ChangeItem()},,.T.,,oFont)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT                                        
	
	/*Adiciona os Nós*/
	oTree:AddItem("Número de Ocorrências","1","FOLDER5",,,,1)
	oTree:AddItem("Valor das Ocorrências","2","FOLDER5",,,,1)
Return   

//=========================================================================/
//Função responsavel por criar o grid, recebe o painel "pai"
//=========================================================================/
Static Function CriaGrid(oDialog)
	Local aColValOco
	
	oProcess:setRegua2(3)
	oProcess:incRegua2("Criando browse ocorrências...")
	
	//Campos calculados do Browse
    aColValOco := {{"Val Ocorr", {|| CalcValOco() }, "N","@E 999,999,999.99",2,15,2,.F.}}
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWD")
	oBrowse:SetMenuDef('GFEC032')
	oBrowse:DisableConfig()
	oBrowse:SetDescription("Ocorrências")
	oBrowse:SetLocate()
	oBrowse:SetOwner(oDialog)
	oBrowse:DisableDetails()
	oBrowse:SetProfileID("1")
	oBrowse:BVLDEXECFILTER := {|aParam| GFEC011BFL(aParam)}
	oBrowse:ForceQuitButton(.T.)
	oBrowse:SetFilterDefault("GFEC011BBR()")
	oBrowse:SetFields(aColValOco)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkthru(.F.)
	
	oProcess:incRegua2()
	oBrowse:Activate()
	oBrowse:SetColumnOrder(1,3)
	oBrowse:UpdateBrowse()
	oProcess:incRegua2()
Return Nil

//
//	Faz o cálculo do valor da ocorrência posicionada
//
Static Function CalcValOco()
	Local nValor   := 0
	Local aAreaGWD := GWD->(GetArea())
	Local aAreaGWF
	Local aAreaGWI
	
	dbSelectArea("GWF")
	aAreaGWF := GWF->(GetArea())
	
	dbSelectArea("GWI")
	aAreaGWI := GWI->(GetArea())
	
	GWF->(dbSetOrder(5)) // GWF_FILIAL+GWF_NROCO+GWF_NRCALC
	
	If GWF->(dbSeek(xFilial("GWF")+GWD->GWD_NROCO))
		While GWF->(!Eof()) .And. ;
			   GWF->GWF_NROCO == GWD->GWD_NROCO
			GWI->(dbSetOrder(1))
			If GWI->(dbSeek(GWF->(GWF_FILIAL+GWF_NRCALC)))
				While GWI->(!Eof()) .And. ;
				       GWI->(GWI_FILIAL+GWI_NRCALC) == GWF->(GWF_FILIAL+GWF_NRCALC) 
					
					If GWI->GWI_TOTFRE == "1"
						nValor += GWI_VLFRET
					EndIf
					
					GWI->(dbSkip())
				EndDo
			EndIf
			
			GWF->(dbSkip())
		EndDo
	EndIf
	
	RestArea(aAreaGWF)
	RestArea(aAreaGWI)
	RestArea(aAreaGWD)
Return nValor 

//
// Cria array de dados para o grid que exibe as séries dos gráficos
// 
Static Function GridArray()
	Local nCount := 0
	Local aGraf := {}
	
	For nCount := 1 To Len(aNUMGWD)
		AADD(aGraf, {aNUMGWD[nCount, 1], aNUMGWD[nCount, 2], ;
			           aNUMGWD[nCount, 3], aVALGWD[nCount, 3]})
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
	
	oBrwGraf:SetColumns(GFEC011COL("Número de Ocorrências",3,"@E 999,999,999",2,20))
	oBrwGraf:SetColumns(GFEC011COL("Valor Ocorrências",4,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("",,,,2))	
	oBrwGraf:Activate()
Return Nil
//=========================================================================/
Function GFEC011BBR()                                                       
	Local aAreaGU3
	Local aAreaGWD := GWD->(GetArea())
	Local lRet := .F.
	Local lSair := .F.
	
	dbSelectArea("GU3")
	aAreaGU3 := GU3->(GetArea())
	
	/*
		aParam[1] - Array com as filiais
		aParam[2] - Tipo de Periodo
		aParam[3] - Data Ref
		aParam[4] - Qtd de periodos
		aParam[5] - Grupo de Transp 
		aParam[6] - Transp de
		aParam[7] - Transp até 
	*/
	
	//
	// Verificação da Filial
	//
	If aScan(aParamPadrao[1], GWD->GWD_FILIAL) <= 0
		lSair := .T.
	EndIf
	
	//
	// Verificação da data de emissão
	//
	If !lSair
		//Compara data do registro
		//Maior data "até" aIntervalos[1][2]
		//Menor data "de"  aIntervalos[Len(aIntervalos)][1]
		If !(GWD->GWD_DTOCOR >= aIntervalos[Len(aIntervalos)][1] .And. GWD->GWD_DTOCOR <= aIntervalos[1][2])
			lSair := .T.
		EndIf
	EndIf
	
	//
	// Verificação da faixa de transportadores / Grupo Transportadores
	//
	If !lSair
		If !Empty(aParamPadrao[5]) 
			dbSelectArea("GU3")
        	GU3->(dbSetOrder(1))
        	If GU3->(dbSeek(xFilial("GU3")+GWD->GWD_CDTRP) .AND. aParamPadrao[5] == GU3->GU3_CDGRGL)
		    	lRet := .T.
			EndIf 
	    ElseIf GWD->GWD_CDTRP >= aParamPadrao[6] .AND.  GWD->GWD_CDTRP <= aParamPadrao[7] 
			lRet := .T.
		EndIf
	EndIf
	
	RestArea(aAreaGU3)
	RestArea(aAreaGWD)
Return lRet
//=========================================================================/
//Função responsavel por adaptar o filtro do Browse na Query SQL
//=========================================================================/
Function GFEC011BFL(aParam) 
	Local nCont
	Local cFiltro := ""
	 
	For nCont := 1 To Len(aParam)
		If !aParam[nCont][5]
	       	If !Empty(cFiltro)
	       		cFiltro := cFiltro + " AND (" +  aParam[nCont][3] + ")"
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
Static Function CarregaDados(aParam,cBrwFiltro,lProcessa)
	Local nCont
	Local cTpPeriodo 	    := aParam[2]
	Local cGrupoTransp 	:= aParam[5] 
	Local cTranspDe  	    := aParam[6]
	Local cTranspAte 	    := aParam[7]
	Local cParamData      := ""
	Local cQuery           := ""
	Default cBrwFiltro    := ''
	Default lProcessa     := .F.
	
	If lProcessa
		oProcess:setRegua2(Len(aIntervalos))
		oProcess:incRegua2("Realizando consultas")
	EndIf
	
	If !Empty(cGrupoTransp)
	    cQueryTransp := " ( GU3_CDGRGL = '"+cGrupoTransp+"' ) AND "
	Else
		cQueryTransp := " ( GU3_CDEMIT >= '"+cTranspDe+"' AND GU3_CDEMIT <= '"+cTranspAte+"' ) AND "   
	Endif
	
	aNUMGWD   := {}
	aVALGWD   := {}  
	
	For nCont := 1 To Len(aIntervalos)
		If cTpPeriodo != 5
			cParamData := " GWD_DTOCOR >= '"+DtoS(aIntervalos[nCont][1])+"' AND GWD_DTOCOR <= '"+DtoS(aIntervalos[nCont][2])+"' "
		Else
			cParamData := " GWD_DTOCOR = '"+DtoS(aIntervalos[nCont][1])+"' "
		EndIf
		
		cQuery := "" 	
		cQuery += " SELECT COUNT(*) NUM_OCO, "
		cQuery += "       VAL.VAL_OCO "
		cQuery += "   FROM "+RetSQLName( 'GWD' )+ " GWD2 "
		cQuery += "   JOIN "+RetSQLName( 'GU3' )+ " GU32 ON GU32.GU3_CDEMIT = GWD2.GWD_CDTRP AND GU32.D_E_L_E_T_ = ' ' "
		cQuery += "   LEFT JOIN ( SELECT SUM(GWI_VLFRET) VAL_OCO "
		cQuery += " 	     FROM "+RetSQLName( 'GWI' )+ " GWI "
		cQuery += " 		 JOIN "+RetSQLName( 'GWF' )+ " GWF ON GWF_NRCALC = GWI_NRCALC AND GWF.D_E_L_E_T_ = ' ' "
		cQuery += " 	     JOIN "+RetSQLName( 'GWD' )+ " GWD ON GWF_NROCO = GWD_NROCO AND GWD.D_E_L_E_T_ = ' ' "
		cQuery += " 		 JOIN "+RetSQLName( 'GU3' )+ " GU3 ON GU3_CDEMIT = GWF_TRANSP AND GU3.D_E_L_E_T_ = ' '  "
		cQuery += " 	    WHERE  GWI.D_E_L_E_T_ = ' ' AND " + cQueryTransp  
		cQuery += cParamData + " AND "
		cQuery += QueryFilial("GWD_FILIAL",aParam[1]) + cBrwFiltro
		cQUery += "   ) VAL ON 1 = 1"
		cQuery += "  WHERE  GWD2.D_E_L_E_T_ = ' ' AND " + cQueryTransp  
		cQuery += cParamData + " AND "
		cQuery += QueryFilial("GWD_FILIAL",aParam[1]) + cBrwFiltro
		cQuery += " GROUP BY VAL_OCO"
		
		cTmp := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
   		dbSelectArea(cTmp)	
		(cTmp)->(dbGoTop())
		
		If (cTmp)->(Eof())
			aADD(aNUMGWD,{aIntervalos[nCont][1],aIntervalos[nCont][2],0})
			aADD(aVALGWD,{aIntervalos[nCont][1],aIntervalos[nCont][2],0})
		EndIf
		
		While (cTmp)->(!Eof())
			aADD(aNUMGWD,{aIntervalos[nCont][1],aIntervalos[nCont][2],(cTmp)->NUM_OCO})
			aADD(aVALGWD,{aIntervalos[nCont][1],aIntervalos[nCont][2],(cTmp)->VAL_OCO})
			(cTmp)->(dbskip())	
		EndDo
		(cTmp)->(dbCloseArea())
		
		If lProcessa
			oProcess:incRegua2()
		EndIf
	Next nCont
	GFEDelTab(cTmp)  
Return          		
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
/*===================================================================*/
//Função que esconde o painel do nó anterior e mostra o painel do nó selecionado  
/*===================================================================*/  
Static Function ChangeItem()
	Local cNode := AllTrim(Substr(oTree:GetCargo(), 1, 6))

	CursorWait()   
     
    //Atualiza o Gráfico	
	GFEC011GRA(oGrf,&(aObjetos[Val(cNode)][1]),.T.,aObjetos[Val(cNode)][2],aObjetos[Val(cNode)][3])
	
	oBrwGraf:SetColumnOrder((Val(cNode)+2),3)
	oBrwGraf:UpdateBrowse()
	
	cNodeAnt := cNode // Armazena o nó 
	
	CursorArrow()
Return Nil  
