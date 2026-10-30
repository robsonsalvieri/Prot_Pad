#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC011A
Análise de Movimentação por Períodos
Generico

@sample
GFEC011A(aParam)

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
Function GFEC011A(aParam)
	Local aCoors  := FWGetDialogSize( oMainWnd )
	Local cTitulo := "Análise de Movimentação por Períodos" 
	
	Private aParamPadrao := aParam
	Private oTree 
	Private cNodeAnt := "1"  // armazena o nó anterior 
	Private oProcess := Nil  // barras de processamento	
	
	// Carrega os intervalos de datas conforme parâmetros informados
	Private aIntervalos := GFEC011INT(aParam[2],aParam[4],aParam[3])  
	
	// Array com os dados do grafico
	Private aNumGW1   := {}
	Private aPesRel   := {}
	Private aVolume   := {} 
	Private aValore   := {}
	Private aQutade   := {} 
	
	//Objetos Tela
	Private oGrf 
	Private oPnlGraf 
	Private oFolder
	Private oBrwGraf 
	Private aObjetos // Array com a relação de objetos graficos e os arrays de dados. Utilizado no loop de construção dos graficos	
	
	/*
		Estrutura aObjetos 
		aObjetos[][1] - Nome do Array com os dados para o Grafico
		aObjetos[][2] - Titulo do Grafico
		aObjetos[][3] - Picture dos dados
	*/
	aObjetos := {{"aNumGW1","Documentos de Carga", "@E 999,999,999"},;
				  {"aPesRel","Peso Bruto Carga", "@E 999,999,999.99"},;
				  {"aVolume","Volume Carga", "@E 999,999,999.99"},;
				  {"aValore","Valor Carga", "@E 999,999,999.99"},;
				  {"aQutade","Quantidade Volumes", "@E 999,999,999"}} 

	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel     
	
	/*Criando objeto Layer*/
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG, .F.)  
	
	/***Criando coluna esquerda (Tree)****/
	oFWLayer:AddLine('LINE_TOP',50,.F.) 							
	oFWLayer:AddCollumn('COL_TOP_LEFT',20,.T.,'LINE_TOP') 			
	oFWLayer:AddWindow('COL_TOP_LEFT','WIN_TOP_LEFT','Opções',100,.T.,.F.,,'LINE_TOP',)
    oWIN_TOP_LEFT := oFWLayer:GetWinPanel('COL_TOP_LEFT','WIN_TOP_LEFT','LINE_TOP')
	
	/***Criando coluna direita (Browse)****/	
	oFWLayer:AddCollumn('COL_TOP_RIGHT',80,.T.,'LINE_TOP') 			
	oWIN_TOP_RIGHT := oFWLayer:GetColPanel('COL_TOP_RIGHT','LINE_TOP') 			
    
 	/***Criando Linha abaixo (Tree/Gráfico/Browse "Dados") ****/
   	oFWLayer:AddLine('LINE_BOTTOM',50,.F.)
	oFWLayer:AddCollumn('COL_BOTTOM',100,.T.,'LINE_BOTTOM')
	oFWLayer:AddWindow('COL_BOTTOM','WIN_BOTTOM',,100,.T.,.F.,,'LINE_BOTTOM',)    
	oWIN_BOTTOM := oFWLayer:GetWinPanel('COL_BOTTOM','WIN_BOTTOM', 'LINE_BOTTOM')
	
	oProcess := MsNewProcess():New({||Carregar(aParam,oWIN_TOP_LEFT,oWIN_TOP_RIGHT,oWIN_BOTTOM)}, "Carregando consultas", "Iniciando processo...")
     
 	// Ativa a janela e efetua a carga das consultas e criação dos browsers
	oDLG:Activate(,,,.T.,,,{||oProcess:Activate()} )
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
	CriaGrGraf(aParam, GridArray())
Return

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
	oTree:AddItem("Documentos de Carga" , "1" , "FOLDER5" ,,,,1)    
	oTree:AddItem("Peso Bruto Carga"	 , "2" , "FOLDER5" ,,,,1)    
	oTree:AddItem("Volume Carga"		 , "3" , "FOLDER5" ,,,,1)    
	oTree:AddItem("Valor Carga"		     , "4" , "FOLDER5" ,,,,1)    
   	oTree:AddItem("Quantidade Volumes"  , "5" , "FOLDER5" ,,,,1) 
Return Nil
//=========================================================================/
//Função responsavel por criar o grid, recebe o painel "pai"
//=========================================================================/
Static Function CriaGrid(oDialog)
	oProcess:setRegua2(3)
	oProcess:incRegua2("Criando browse documentos de carga...")
	
	oBrowse := FWMBrowse():New()  
	oBrowse:SetAlias("GW1")	
	oBrowse:SetMenuDef('GFEC040')
	oBrowse:DisableConfig()
	oBrowse:SetDescription("Documentos de Carga")
	oBrowse:SetLocate()
	oBrowse:SetOwner(oDialog)
	oBrowse:DisableDetails()
	oBrowse:SetProfileID("1")
	oBrowse:BVLDEXECFILTER := {|aParam| GFEC011FL(aParam)}
	oBrowse:ForceQuitButton(.T.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetFilterDefault("GFEC011ABR()")
	
	oProcess:incRegua2()	
	oBrowse:Activate()
	oProcess:incRegua2()
Return Nil

//
// Cria array de dados para o grid que exibe as séries dos gráficos
// 
Static Function GridArray()
	Local nCount := 0
	Local aGraf := {}
	
	For nCount := 1 To Len(aNumGW1)
		AADD(aGraf, {aNumGW1[nCount, 1], aNumGW1[nCount, 2], ;
			  aNumGW1[nCount, 3], aPesRel[nCount, 3], aVolume[nCount, 3],;
			  aValore[nCount, 3], aQutade[nCount, 3]})
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
	
	oBrwGraf:SetColumns(GFEC011COL("Documentos de Carga",3,"@E 999,999,999",2,20))
	oBrwGraf:SetColumns(GFEC011COL("Peso Bruto Carga",4,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("Volume Carga",5,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("Valor Carga",6,"@E 999,999,999.99",2,20))
	oBrwGraf:SetColumns(GFEC011COL("Quantidade Volumes",7,"@E 999,999,999",2,20))
	oBrwGraf:SetColumns(GFEC011COL("",,,,2))
	oBrwGraf:Activate()
Return Nil

// 
// Cria colunas para serem adicionadas ao browse que contém 
// os dados das séries do gráfico
//
// Parametros
// cTitulo = Titulo da coluna
// nArrData = índice no array que contém o dado da coluna
// cPicture = picture da coluna
// nAlign = Alinhamento (0 - centro, 1 - esquerda, 2 - direita)
// nSize = Tamanho da coluna
//

Function GFEC011COL(cTitulo,nArrData,cPicture,nAlign,nSize)
	Local aColumn
	Local bData := {||}
	Default nAlign := 1
	Default nSize := 20
	Default nArrData := 0
	
	If nArrData > 0
		bData := &("{||oBrwGraf:oData:aArray[oBrwGraf:At(),"+STR(nArrData)+"]}")
	EndIf
	
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não) */
	
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}

//=========================================================================/
Function GFEC011ABR()                                                       
	Local aAreaGWU
	Local aAreaGU3
	Local aAreaGW1 := GW1->(GetArea())
	Local lRet := .F.
	Local lSair := .F.
	
	dbSelectArea("GWU")
	dbSelectArea("GU3")
	aAreaGWU := GWU->(GetArea())
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
	If aScan(aParamPadrao[1], GW1->GW1_FILIAL) <= 0
		lSair := .T.
	EndIf
	
	//
	// Verificação da data de emissão
	//
	If !lSair
		//Compara data do registro
		//Maior data "até" aIntervalos[1][2]
		//Menor data "de"  aIntervalos[Len(aIntervalos)][1]
		If !(GW1->GW1_DTEMIS >= aIntervalos[Len(aIntervalos)][1] .And. GW1->GW1_DTEMIS <= aIntervalos[1][2])
			lSair := .T.
		EndIf
	EndIf
	
	//
	// Verificação da faixa de transportadores / Grupo Transportadores
	//
	If !lSair
		dbSelectArea("GWU")
		GWU->(dbSetOrder(1))
		GWU->(dbSeek(xFilial("GWU")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))    
		
		While GWU->(!Eof()) .AND. xFilial("GWU")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC == ;
			   GWU->GWU_FILIAL+GWU->GWU_CDTPDC+GWU->GWU_EMISDC+GWU->GWU_SERDC+GWU->GWU_NRDC                                                                                                  
			
			If !Empty(aParamPadrao[5]) 
				dbSelectArea("GU3")
	        	GU3->(dbSetOrder(1))
	        	If GU3->(dbSeek(xFilial("GU3")+GWU->GWU_CDTRP) .AND. aParamPadrao[5] == GU3->GU3_CDGRGL)
			    	lRet := .T.
			    	Exit
				EndIf 
		    ElseIf GWU->GWU_CDTRP >= aParamPadrao[6] .AND.  GWU->GWU_CDTRP <= aParamPadrao[7] 
				lRet := .T.
				Exit
			Endif
			GWU->(DbSkip())
		EndDo
	EndIf
	
	RestArea(aAreaGWU)
	RestArea(aAreaGU3)
	RestArea(aAreaGW1)	
Return lRet
//=========================================================================/
//Função responsavel por adaptar o filtro do Browse na Query SQL
//=========================================================================/  
Function GFEC011FL(aParam) 
	Local nCont
	Local cFiltro := ""
	 
	For nCont := 1 To Len(aParam)
		If !aParam[nCont][5]
	       	If !Empty(cFiltro)
	       		cFiltro := cFiltro + " AND (" +  aParam[nCont][3] + ")"
	       	Else
	       	    cFiltro := " AND (" +  aParam[nCont][3] + ")"
	       	Endif
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
Function GFEC011GRA(oGrf,aDados,lAtual,cTitle,cPicture)
	Local nCont1
	Local aRand := {}
	  
	Default lAtual := .F.   
	Default cTitle := ''
    Default cPicture := ''
   	
   	If lAtual
		oGrf:Reset()
	EndIf
	
	oGrf:SetTitle(cTitle, CONTROL_ALIGN_CENTER)
	oGrf:SetPicture(cPicture)
	
	nCont1 := Len(aDados) 
	While nCont1 > 0
		Aadd(aRand, oGrf:oFWChartColor:aRandom[1])
		oGrf:AddSerie( Legenda(aDados[nCont1][1],aDados[nCont1][2])  ,aDados[nCont1][3])
		nCont1 := nCont1 - 1
	EndDo
	
	If Len(aRand) > 0
		oGrf:oFWChartColor:aRandom := aRand
		oGrf:oFWChartColor:SetColor("Random")
	EndIf
	
	oGrf:Build()
Return Nil
//=========================================================================/
Static Function Legenda(dDataDe,dDataAte)   
	Local cLegenda
	
	If dDataAte - dDataDe == 1
		cLegenda := DtoC(dDataDe)
	Else
	 	cLegenda := DtoC(dDataDe) + " a " + DtoC(dDataAte)
	EndIf
Return cLegenda  	
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
	    cQueryTransp := " ( GU3.GU3_CDGRGL = '"+cGrupoTransp+"' ) AND "
	Else
		cQueryTransp := " ( GU3.GU3_CDEMIT >= '"+cTranspDe+"' AND GU3.GU3_CDEMIT <= '"+cTranspAte+"' ) AND "   
	Endif
   
	aNumGW1   := {}
	aPesRel   := {}
	aVolume   := {}
	aValore   := {}
	aQutade   := {}
	
	For nCont := 1 To Len(aIntervalos)
		If cTpPeriodo != 5
			cParamData := " GW1.GW1_DTEMIS >= '"+DtoS(aIntervalos[nCont][1])+"' AND GW1.GW1_DTEMIS <= '"+DtoS(aIntervalos[nCont][2])+"' "
		Else
			cParamData := " GW1.GW1_DTEMIS = '"+DtoS(aIntervalos[nCont][1])+"' "
		EndIf
		
		cQuery := ""
		cQuery += "SELECT COUNT(*) COUNT_GW1,"
		cQuery += "	   SUM(GW8_PESOR) PESOR,"
		cQuery += "	   SUM(GW8_VOLUME) VOLUME,"
		cQuery += "	   SUM(GW8_VALOR) VALOR,"
		cQuery += "	   SUM(GW8_QTDE) QTDE"
		cQuery += "  FROM (SELECT DISTINCT GW1.GW1_FILIAL,"
		cQuery += "		       GW1.GW1_CDTPDC,"
		cQuery += "		       GW1.GW1_EMISDC,"
		cQuery += "		       GW1.GW1_SERDC,"
		cQuery += "		       GW1.GW1_NRDC"
		cQuery += "		  FROM " + RetSQLName('GW1') + " GW1"
		cQuery += "		 INNER JOIN " + RetSQLName( 'GWU' ) + " GWU ON GW1.GW1_FILIAL = GWU.GWU_FILIAL "
		cQuery += "							  AND GW1.GW1_CDTPDC = GWU.GWU_CDTPDC "
		cQuery += "							  AND GW1.GW1_EMISDC = GWU.GWU_EMISDC "
		cQuery += "							  AND GW1.GW1_SERDC  = GWU.GWU_SERDC " 
		cQuery += "							  AND GW1.GW1_NRDC   = GWU.GWU_NRDC "
		cQuery += "							  AND GWU.D_E_L_E_T_ = ' '"
		cQuery += "		 INNER JOIN " + RetSQLName('GU3') + " GU3 ON GU3.GU3_CDEMIT = GWU.GWU_CDTRP "
		cQuery += "		 WHERE GW1.D_E_L_E_T_ = ' '"
		cQuery += "          AND " + cParamData + " AND  " + cQueryTransp
		cQuery += QueryFilial("GW1.GW1_FILIAL",aParam[1]) +  cBrwFiltro 
		cQuery += "   		) GW1"
		cQuery += " LEFT JOIN (SELECT GW8_FILIAL,"
		cQuery += "					GW8_CDTPDC,"
		cQuery += "					GW8_EMISDC,"
		cQuery += "					GW8_SERDC,"
		cQuery += "					GW8_NRDC,"
		cQuery += "					SUM(GW8_PESOR) GW8_PESOR, "
		cQuery += "					SUM(GW8_VOLUME) GW8_VOLUME,"
		cQuery += "					SUM(GW8_VALOR) GW8_VALOR,"
		cQuery += "					SUM(GW8_QTDE) GW8_QTDE"
		cQuery += "			   FROM " + RetSQLName( 'GW8' ) 
		cQuery += "			  WHERE D_E_L_E_T_ = ' '"
		cQuery += "			  GROUP BY GW8_FILIAL,"
		cQuery += "					GW8_CDTPDC,"
		cQuery += "					GW8_EMISDC,"
		cQuery += "					GW8_SERDC,"
		cQuery += "					GW8_NRDC) GW8 ON GW8.GW8_FILIAL = GW1_FILIAL "
		cQuery += "								 AND GW8.GW8_CDTPDC = GW1_CDTPDC "
		cQuery += "								 AND GW8.GW8_EMISDC = GW1_EMISDC "
		cQuery += "								 AND GW8.GW8_SERDC  = GW1_SERDC " 
		cQuery += "								 AND GW8.GW8_NRDC   = GW1_NRDC"
		
		cTmp := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
		dbSelectArea(cTmp)
		(cTmp)->(dbGoTop())
		
		If (cTmp)->(Eof())
			aADD(aNumGW1,{aIntervalos[nCont][1],aIntervalos[nCont][2],0})
			aADD(aPesRel,{aIntervalos[nCont][1],aIntervalos[nCont][2],0})
			aADD(aVolume,{aIntervalos[nCont][1],aIntervalos[nCont][2],0})
			aADD(aValore,{aIntervalos[nCont][1],aIntervalos[nCont][2],0})			
			aADD(aQutade,{aIntervalos[nCont][1],aIntervalos[nCont][2],0})
		EndIf
		
		While (cTmp)->(!Eof())
	    	aADD(aNumGW1,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->COUNT_GW1 })
			aADD(aPesRel,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->PESOR     })
			aADD(aVolume,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->VOLUME    })
			aADD(aValore,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->VALOR     })			
			aADD(aQutade,{aIntervalos[nCont][1],aIntervalos[nCont][2], (cTmp)->QTDE      })
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
Static function QueryFilial(cCampo,aFilial)
	Local cQuery
	Local nCont
	
	cQuery := " ( "
	For nCont := 1 To Len(aFilial)
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

/*===================================================================*/ 
//Cria o Array com as datas de acordo com o intervalo selecionado 
//Param: cTpPeriodo (1-Anual 2-Mesal 3- Quizenal 4- Semanal 5- Diario)
//nQdtePeriodo - Quantidade de periodo  
//dDataRef - Data de referencia
/*===================================================================*/ 
Function GFEC011INT(cTpPeriodo, nQdtePeriodo, dDataRef) 
	Local cDataDe, cDataAte 
	Local nAnoTmp, nMesTmp, nDiaTmp, nCont
	Local dDataDe, dDataAte 
    Local aDatas := {}
    
    Do Case
    	//=========================Anual=========================
    	Case cTpPeriodo  == 1  
    		nAnoTmp := YEAR(dDataRef)
			//Cria os periodos de 01/01 até 31/12
			For nCont := 1 To nQdtePeriodo  
			    cDataDe  := "01/01/"+STR(nAnoTmp)  
			    cDataAte := "31/12/"+STR(nAnoTmp)
				aADD(aDatas, {CtoD(cDataDe), CtoD(cDataAte)})	 
				nAnoTmp := nAnoTmp - 1    
			Next nCont
			
		//=========================Mensal=========================			
    	Case cTpPeriodo  == 2 
    		nMesTmp := MONTH(dDataRef)    
			nAnoTmp := YEAR(dDataRef)     
			
		 	For nCont := 1 To nQdtePeriodo
		 		cDataDe  := "01/"+ PADL(nMesTmp, 2, "0") +"/"+STR(nAnoTmp)
				nDiaTmp := f_UltDia(CtoD(cDataDe)) // Retorna último dia do mês da data passada
				
				If nMesTmp == 1   //Se for janeiro, seta o mes para dezembro e diminui 1 ano da variavel nAnoTmp
					cDataAte := STR(nDiaTmp) + "/01/" + STR(nAnoTmp)
		 			nMesTmp := 12             	
			 		nAnoTmp := nAnoTmp -1
		 		Else
		 	   		cDataAte := STR(nDiaTmp) + "/" + PADL(nMesTmp, 2, "0") + "/" + STR(nAnoTmp)
			   		nMesTmp  := nMesTmp - 1
		 		EndIf
				
		 	 	aADD(aDatas,{CtoD(cDataDe),CtoD(cDataAte)}) 
	    	Next nCont
	    	
		//=========================Quinzenal=========================	    	
    	Case cTpPeriodo  == 3
   			dDataDe  := dDataRef - 14
	    	dDataAte := dDataRef
	    	
	   		For nCont := 1 To nQdtePeriodo
				aADD(aDatas, {dDataDe, dDataAte})
				dDataDe  := dDataDe - 15
				dDataAte := dDataAte - 15
			Next nCont 
    	
    	//=========================Semanal=========================	
    	Case cTpPeriodo  == 4
    		//Posiciona no proximo domingo 
			While DiaExtenso(dDataRef) != "Domingo"
				dDataRef := dDataRef + 1	
			EndDo
			
	        //Armazena a data de referencia, mas agora sendo o domingo do periodo informado
	        For nCont := 1 To nQdtePeriodo
	         	aADD(aDatas, { dDataRef - 6  , dDataRef } )	 
	 	        dDataRef := dDataRef -7 
	        Next nCont
	        
    	//=========================Diário=========================
    	Case cTpPeriodo  == 5
    		For nCont := 1 To nQdtePeriodo
	         	aADD(aDatas, { dDataRef -1  , dDataRef } )	 
	 	        dDataRef := dDataRef -1
	        Next nCont 		
    		
    EndCase
Return aDatas
