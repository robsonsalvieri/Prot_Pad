#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC001B
Painel Gerencial - Informações sobre Documentos de Carga

Uso Restrito. 

Param:
aParam[1] := Filial de
aParam[2] := Filial ate
aParam[3] := Data de
aParam[4] := Data ate
aParam[5] := Codigo do Emitente     

@sample
GFEC001B(aParam)

@author Felipe Mendes / Alan Victor Lamb
@since 05/05/12
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC001B(aParam)
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Transportador'
	
	Private oGrfDoc 
	Private aGrfDoc
	Private aBrowse := {}
	Private oBrowseEst
	Private cFilialDe  := aParam[1]
	Private cFilialAte := aParam[2]
	Private dDataDe    := If(Empty(aParam[3]),DDATABASE - 30 ,aParam[3])
	Private dDataAte   := If(Empty(aParam[4]),DDATABASE      ,aParam[4])  
	Private cCodEmit   := aParam[5]
	Private aFiltros
	Private cAliasGW1
	
	aFiltros := {{"GWU","GWU_CDTRP" ,"=" ,cCodEmit        },;
				  {"GW1","GW1_FILIAL",">=",cFilialDe		},;
				  {"GW1","GW1_FILIAL","<=",cFilialAte	 	},;   
				  {"GW1","GW1_DTEMIS",">=",Dtos(dDataDe)  },;
				  {"GW1","GW1_DTEMIS","<=",Dtos(dDataAte) }}  
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine( 'LINE_MIDDLE', 50, .F. )
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
  	oFWLayer:AddCollumn('COL_LEFT',40,.T.,'LINE_MIDDLE')
  	oFWLayer:AddCollumn('COL_RIGHT',60,.T.,'LINE_MIDDLE')
  	oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Estatísticas',100,.F.,.F.,,'LINE_MIDDLE',)
    oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Gráficos',100,.F.,.F.,,'LINE_MIDDLE',)
    
    oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT', 'LINE_MIDDLE')
	oWIN_RIGHT := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT', 'LINE_MIDDLE')
	 
    oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
    
    GFEDelTab(cAliasGW1) 
Return 

Static Function Iniciar()
	Local aFieldsGW1
	Local nCount 
	
	aFieldsGW1 := ;
	{{"Filial"	     ,"GW1_FILIAL","C",TamSX3("GW1_FILIAL")[1],0,"",1,TamSX3("GW1_FILIAL")[1]},;
	{"Tp Doc"	   	 ,"GW1_CDTPDC","C",TamSX3("GW1_CDTPDC")[1],0,"",1,10},;
	{"Emissor"      ,"GW1_NMEMIS","C",TamSX3("GU3_NMEMIT")[1],0,"",1,10},;
	{"Série",		"GW1_SERDC",	"C",TamSX3("GW1_SERDC")[1],	0,"!!!",1,10},;	
	{"Número"       ,"GW1_NRDC"  ,"C",TamSX3("GW1_NRDC")[1]  ,0,"",1,10},;
	{"Dt Emissão"  ,"GW1_DTEMIS","D",8,0,"",1,10},;
	{"Situação"    ,"GW1_SIT","C",20,0,"",1,10},;
	{"Remetente"   ,"GW1_NMREM" ,"C",TamSX3("GU3_NMEMIT")[1] ,0,"",1,10},;
	{"Destinatário","GW1_NMDEST","C",TamSX3("GU3_NMEMIT")[1],0,"",1,10},;
	{"Tipo Frete"  ,"GW1_TPFRET","C",20,0,"",1,10},;
	{"Nr Romaneio" ,"GW1_NRROM" ,"C",TamSX3("GW1_NRROM")[1] ,0,"",1,10},;
	{"Seq Trecho"  ,"GWU_SEQ" 	,"C",TamSX3("GWU_SEQ")[1]   ,0,"",1,10}}
	
	CarregaDados(aFiltros)
	cAliasGW1 := CriaTab()
	
	//Browse Doc carga
	oBrowseDoc:= FWMBrowse():New() 
	oBrowseDoc:SetOwner(oWIN_TOP)  
	oBrowseDoc:SetDescription("Documentos de Carga")
	oBrowseDoc:SetAlias(cAliasGW1)
	oBrowseDoc:SetLocate()
	oBrowseDoc:DisableDetails()
	oBrowseDoc:DisableConfig()
	oBrowseDoc:SetAmbiente(.F.)
	oBrowseDoc:SetWalkthru(.F.)
	oBrowseDoc:SetProfileID("1") 
	oBrowseDoc:SetMenuDef("")
	oBrowseDoc:AddButton("Sair",{|| oDLG:End()},,1)
	oBrowseDoc:AddButton("Visualizar",{|| VisualGW1() },,2)
	
	For nCount := 1 To Len(aFieldsGW1)
		oBrowseDoc:AddColumn({aFieldsGW1[nCount][1],;
							     &("{|| (cAliasGW1)->" + aFieldsGW1[nCount][2] + "}"),;
							     aFieldsGW1[nCount][3],;
							     aFieldsGW1[nCount][6],;
							     aFieldsGW1[nCount][7],;
							     aFieldsGW1[nCount][8],;
							     aFieldsGW1[nCount][5],;
							     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount
	
	oBrowseDoc:Activate()
	
	Define Font oFont Name 'Courier New' Size 0, -12

   	oBrowseEst := FWBrowse():New()
	oBrowseEst:SetOwner(oWIN_LEFT)
	oBrowseEst:SetDescription("Dados") 
	oBrowseEst:SetDataArray()
	oBrowseEst:DisableFilter()
	oBrowseEst:DisableConfig()
	oBrowseEst:SetArray(aBrowse)
   	oBrowseEst:SetColumns(GFEC001COL("Descrição",1,,1,20,"oBrowseEst"))
	oBrowseEst:SetColumns(GFEC001COL("Unidade",2,,1,2,"oBrowseEst"))
	oBrowseEst:SetColumns(GFEC001COL("Conteúdo",3,,1,20,"oBrowseEst"))
	oBrowseEst:Activate()
	
    // Gráfico - Documentos de Carga por Situação
	GFEC001GRC("oGrfDoc", "Documentos de Carga por Situação", oWIN_RIGHT, aGrfDoc)
	
	//
	// Seta as cores das séries do gráfico conforme status dos documentos
	// Parecido com a legenda do Browse na tela GFEC040
	//
	/*
	aAdd(aSeries, {"175,175,175", "011,011,011"}) // Digitado
	aAdd(aSeries, {"199,199,070", "022,022,008"}) // Bloqueado
	aAdd(aSeries, {"100,100,100", "008,008,008"}) // Liberado
	aAdd(aSeries, {"054,090,134", "007,013,017"}) // Embarcado
	aAdd(aSeries, {"141,225,078", "017,019,010"}) // Entregue
	aAdd(aSeries, {"177,106,047", "020,020,006"}) // Retornado
	aAdd(aSeries, {"136,055,052", "017,007,007"}) // Cancelado
	aAdd(aSeries, {"001,001,001", "001,001,001"}) // Sinistrado
	*/
	//oGrfDoc:oFWChartColor:aRandom := aSeries
	//oGrfDoc:oFWChartColor:SetColor("Random")
Return Nil

//
// Chama consulta dos documentos de carga
//
Static Function VisualGW1()
	dbSelectArea("GW1")
	GW1->(dbSetOrder(1))
	If GW1->(dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))
		FWExecView("Visualizar", "GFEC040", 1,, {||.T.})
	EndIf 
Return Nil

//
// Criação de colunas padrão para os browses de estatísticas utilizados nas 
// telas do gerencial
//
Function GFEC001COL(cTitulo,xArrData,cPicture,nAlign,nSize,cBrowse,cTipo,nDecimal)
	Local aColumn
	Local bData := {||}
	Default nAlign := 1
	Default nSize := 20
	
	If !Empty(xArrData)
		If ValType(xArrData) == "B"
			bData := xArrData
		ElseIf ValType(xArrData) == "N" .AND. xArrData > 0 .AND. !Empty(cBrowse)
			bData := &("{||"+cBrowse+":oData:aArray["+cBrowse+":At(),"+STR(xArrData)+"]}")
		EndIf
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
	
	aColumn := {cTitulo,bData,cTipo,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}

//
// Criação de componentes de gráfico
// cGrf: nome da variável private 
// cTitulo: título do gráfico
// oOwner: objeto pai do gráfico
// aSerie: array de dados das séries
// cPicture: picture dos dados
// bSerieAction: bloco de código para executar ação das séries (duplo clique)
// xTipo: tipo de gráfico. (Padrão PIECHART)
// xAlignTi: CONTROL_ALIGN do Título
// xAlignLe: CONTROL_ALIGN da Legenda
Function GFEC001GRC(cGrf,cTitulo,oOwner,aSerie,cPicture,bSerieAction,xTipo, xAlignTi, xAlignLe)
	Default xTipo := PIECHART
	Default xAlignTi := CONTROL_ALIGN_CENTER
	Default xAlignLe := CONTROL_ALIGN_BOTTOM
	&(cGrf) := FWChartFactory():New()
	&(cGrf) := &(cGrf):GetInstance(xTipo)
	&(cGrf):SetTitle(cTitulo,xAlignTi) 
	&(cGrf):Init(oOwner,.F.)
	&(cGrf):SetLegend(xAlignLe)
	
	If cPicture != Nil
		&(cGrf):SetPicture(cPicture)
	EndIf
	
	If bSerieAction != Nil
		&(cGrf):SetSerieAction(bSerieAction)
	EndIf
	
    GFEC001GRA(&(cGrf),,aSerie)
Return Nil

//
// Insere/atualiza as informações do gráfico
// oGrf: objeto do gráfico
// lAtual: indica se é atualização de um componente já existente. (Padrão .F.)
// aSerie: array contendo nome e dados das séries
// cTitulo: título do gráfico
//
Function GFEC001GRA(oGrf,lAtual,aSerie,cTitulo)  
	Local nCont
	Default lAtual := .F.
	   
	If lAtual
		oGrf:Reset()
	EndIf 
	
	If cTitulo != Nil
		oGrf:SetTitle(cTitulo)
	EndIf
	
	For nCont := 1 To Len(aSerie)
		oGrf:AddSerie(AllTrim(aSerie[nCont][1]), aSerie[nCont][2])
	Next
	
	oGrf:Build()
Return Nil 

Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local cQuery := ''
	Local cTmp   := ''
	Local aQuery := {}	   
	Default cBrwFiltro := ''
	
	aGrfDoc := {}
	aBrowse := {}
	
	aADD(aBrowse, {"Transportador","-" ,Posicione("GU3", 1, xFilial("GU3")+cCodEmit,"GU3_NMEMIT")})
	
	cQuery += "SELECT COUNT(CASE WHEN GW1.GW1_SIT = '1' THEN 1 END) GW1_SITDIG,"
	cQuery += "		COUNT(CASE WHEN GW1.GW1_SIT = '2' THEN 1 END) GW1_SITBLO,"
	cQuery += "       COUNT(CASE WHEN GW1.GW1_SIT = '3' THEN 1 END) GW1_SITLIB,"
	cQuery += "       COUNT(CASE WHEN GW1.GW1_SIT = '4' THEN 1 END) GW1_SITEMB,"
	cQuery += "       COUNT(CASE WHEN GW1.GW1_SIT = '5' THEN 1 END) GW1_SITENT,"
	cQuery += "       COUNT(CASE WHEN GW1.GW1_SIT = '6' THEN 1 END) GW1_SITRET,"
  	cQuery += "       COUNT(CASE WHEN GW1.GW1_SIT = '7' THEN 1 END) GW1_SITCAN,"
  	cQuery += "       COUNT(CASE WHEN GW1.GW1_SIT = '8' THEN 1 END) GW1_SITSIN,"
  	cQuery += "		SUM(GW8.GW8_PESOR) GFE_PEBRTO,"
  	cQuery += "		SUM(GW8.GW8_PESOC) GFE_PECUTO,"
 	cQuery += "		SUM(GW8.GW8_QTDALT) GFE_QTDALT,"
  	cQuery += "		SUM(GW8.GW8_VOLUME) GFE_VOLTOT,"
  	cQuery += "		SUM(GW8.GW8_QTDE) GFE_QTVOTO,"
  	cQuery += "		SUM(GW8.GW8_VALOR) GFE_VLCATO,"
  	cQuery += "		COUNT(*) QTDDC"
  	cQuery += "  FROM " + RetSQLName( 'GW1' ) + " GW1"
  	cQuery += "  LEFT JOIN ( SELECT GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC, "
	cQuery += "	                     SUM(GW8_PESOR) GW8_PESOR,SUM(GW8_PESOC) GW8_PESOC,SUM(GW8_QTDALT) GW8_QTDALT,"
	cQuery += "	                     SUM(GW8_VOLUME) GW8_VOLUME,SUM(GW8_QTDE) GW8_QTDE,SUM(GW8_VALOR) GW8_VALOR"
	cQuery += "	                FROM " + RetSQLName("GW8")
	cQuery += "	               WHERE D_E_L_E_T_ = ' '"
	cQuery += "	               GROUP BY GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC"
	cQuery += "	             ) GW8 ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	                  AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "	                  AND GW8.GW8_EMISDC = GW1.GW1_EMISDC "
	cQuery += "	                  AND GW8.GW8_SERDC  = GW1.GW1_SERDC "
	cQuery += "	                  AND GW8.GW8_NRDC   = GW1.GW1_NRDC "
  	cQuery += " INNER JOIN ( SELECT DISTINCT GWU2.GWU_CDTRP,"
  	cQuery += "                              GWU2.GWU_FILIAL,"
  	cQuery += "                              GWU2.GWU_CDTPDC,"
  	cQuery += "                              GWU2.GWU_EMISDC,"
  	cQuery += "                              GWU2.GWU_SERDC,"
  	cQuery += "                              GWU2.GWU_NRDC"
  	cQuery += "                FROM " + RetSQLName( 'GWU' ) + " GWU2 WHERE D_E_L_E_T_ = ' ' AND GWU_PAGAR = '1') GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
  	cQuery += "                                      AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
  	cQuery += "                                      AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
  	cQuery += "                                      AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
  	cQuery += "                                      AND GWU.GWU_NRDC   = GW1.GW1_NRDC"
  	cQuery += " WHERE GW1.D_E_L_E_T_ = ' ' " + CriaQueryCondicao(aFiltros,"") + cBrwFiltro
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)	
	(cTmp)->(dbGoTop())
	If (cTmp)->(RecNo()) > 0
		aADD(aBrowse,  {"Peso Bruto Total"    			,"Kg", AllTrim(Transform((cTmp)->GFE_PEBRTO,'@E 99,999,999,999.99999'))}) 
		aADD(aBrowse,  {"Peso Cubado Total"   			,"Kg", AllTrim(Transform((cTmp)->GFE_PECUTO,'@E 99,999,999,999.99999'))}) 
		aADD(aBrowse,  {"Peso/Qtde Alternativa Cargas","Un", AllTrim(Transform((cTmp)->GFE_QTDALT,'@E 99,999,999,999.99999'))})   
		aADD(aBrowse,  {"Volume Total"        			,"M3", AllTrim(Transform((cTmp)->GFE_VOLTOT,'@E 99,999,999,999.99999'))}) 
		aADD(aBrowse,  {"Qtde Volumes Total"  			,"Un", AllTrim(Transform((cTmp)->GFE_QTVOTO,'@E 99,999,999,999'))}) 
		aADD(aBrowse,  {"Valor Carga Total"   			,"$" , AllTrim(Transform((cTmp)->GFE_VLCATO,'@E 99,999,999,999.99'))})   
		aADD(aBrowse,  {"Qtde de Documentos"         	,"Un", Alltrim(STR((cTmp)->QTDDC) ) } )
		
		aAdd(aGrfDoc, {"Digitado", (cTmp)->GW1_SITDIG })
		aAdd(aGrfDoc, {"Bloqueado",(cTmp)->GW1_SITBLO })
		aAdd(aGrfDoc, {"Liberado", (cTmp)->GW1_SITLIB })
		aAdd(aGrfDoc, {"Embarcado",(cTmp)->GW1_SITEMB })
		aAdd(aGrfDoc, {"Entregue", (cTmp)->GW1_SITENT })
		aAdd(aGrfDoc, {"Retornado",(cTmp)->GW1_SITRET })
		aAdd(aGrfDoc, {"Cancelado",(cTmp)->GW1_SITCAN })
		aAdd(aGrfDoc, {"Sinistrado", (cTmp)->GW1_SITSIN })
	EndIf
	
	(cTmp)->(dbCloseArea())
Return aQuery		   

//
// Cria tabela temporária para o browse com os documentos 
// de carga para o emitente selecionadao
//
// OBS
// Não é feito com SetFilterDefault pois precisa validar o transportador 
// através dos trechos na GWU e utilizando função como filtro fica muito lento
// com muitos registros.
//
Static Function CriaTab()
	Local cQuery := ""
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local cTmp
	Local aStruct := {}
	Local aTpFret := {"CIF","CIF Redesp","FOB","FOB Redesp","Consignado","Consig Redesp"} 
	Local aSituacao := StrToKArr(Posicione("SX3",2,"GW1_SIT","X3_CBOX"),";")
	
	aFields := ;
	{{"Filial"	     ,"GW1_FILIAL","C",TamSX3("GW1_FILIAL")[1],0},;
	{"Tp Doc"	   	 ,"GW1_CDTPDC","C",TamSX3("GW1_CDTPDC")[1],0},;
	{"Emissor"      ,"GW1_EMISDC","C",TamSX3("GW1_EMISDC")[1],0},;
	{"Nm Emiss"     ,"GW1_NMEMIS","C",TamSX3("GU3_NMEMIT")[1],0},;
	{"Série"        ,"GW1_SERDC" ,"C",TamSX3("GW1_SERDC")[1] ,0},;
	{"Número"       ,"GW1_NRDC"  ,"C",TamSX3("GW1_NRDC")[1]  ,0},;
	{"Dt Emissão"  ,"GW1_DTEMIS","D",TamSX3("GW1_DTEMIS")[1],0},;
	{"Situação"    ,"GW1_SIT","C",20,0},;
	{"Remetente"   ,"GW1_CDREM" ,"C",TamSX3("GW1_CDREM")[1] ,0},;
	{"Nm Remetente","GW1_NMREM" ,"C",TamSX3("GU3_NMEMIT")[1] ,0},;
	{"Destinatário","GW1_CDDEST","C",TamSX3("GW1_CDDEST")[1],0},;
	{"Nm Dest"	     ,"GW1_NMDEST","C",TamSX3("GU3_NMEMIT")[1],0},;
	{"Tipo Frete"  ,"GW1_TPFRET","C",20,0},;
	{"Nr Romaneio" ,"GW1_NRROM" ,"C",TamSX3("GW1_NRROM")[1] ,0},;
	{"Seq Trecho"  ,"GWU_SEQ" 	,"C",TamSX3("GWU_SEQ")[1]   ,0}}
	
	aIndices := {"GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC+DtoS(GW1_DTEMIS)"}
	
	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  //Nome do campo
						aFields[nCont][3],;  //Tipo
						aFields[nCont][4],;  //Tamanho
						aFields[nCont][5]}) //Decimal
	Next nCont
	
	cAlias := GFECriaTab({aStruct,aIndices})
	
	cQuery += "	SELECT GW1_FILIAL, "
	cQuery += "		   GW1_CDTPDC, "
	cQuery += "		   GW1_EMISDC, "
	cQuery += "		   GW1_SERDC, "
	cQuery += "		   GW1_NRDC, "
	cQuery += "		   GW1_DTEMIS, "
	cQuery += "		   GW1_CDREM, "
	cQuery += "		   GW1_CDDEST, "
	cQuery += "		   GW1_TPFRET, "
	cQuery += "		   GW1_NRROM, "
	cQuery += "		   GW1_SIT, "
	cQuery += "		   GWU_SEQ "
	cQuery += "	  FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "	 INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += "	 					  AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "	 					  AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
	cQuery += "	 					  AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
	cQuery += "	 					  AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += "	 WHERE GW1.D_E_L_E_T_ = '' "
	cQuery += "	   AND GWU.D_E_L_E_T_ = '' "
	cQuery += "	   AND GW1.GW1_FILIAL >= '"+cFilialDe+"' "
	cQuery += "	   AND GW1.GW1_FILIAL <= '"+cFilialAte+"' "
	cQuery += "	   AND GW1.GW1_DTEMIS >= '"+DtoS(dDataDe)+"' "
	cQuery += "	   AND GW1.GW1_DTEMIS <= '"+DtoS(dDataAte)+"' "
	cQuery += "	   AND GWU.GWU_CDTRP   = '"+cCodEmit+"' "
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	While (cTmp)->(!Eof())
		RecLock(cAlias,.T.)
		(cAlias)->GW1_FILIAL := (cTmp)->GW1_FILIAL
		(cAlias)->GW1_CDTPDC := (cTmp)->GW1_CDTPDC
		(cAlias)->GW1_EMISDC := (cTmp)->GW1_EMISDC
		(cAlias)->GW1_NMEMIS := Posicione("GU3",1,xFilial("GU3")+(cTmp)->GW1_EMISDC,"GU3_NMEMIT")
		(cAlias)->GW1_SERDC  := (cTmp)->GW1_SERDC
		(cAlias)->GW1_NRDC   := (cTmp)->GW1_NRDC
		(cAlias)->GW1_SIT    := SUBSTR(aSituacao[Val((cTmp)->GW1_SIT)],3)
		(cAlias)->GW1_DTEMIS := StoD((cTmp)->GW1_DTEMIS)
		(cAlias)->GW1_CDREM  := (cTmp)->GW1_CDREM
		(cAlias)->GW1_NMREM  := Posicione("GU3",1,xFilial("GU3")+(cTmp)->GW1_CDREM,"GU3_NMEMIT")
		(cAlias)->GW1_CDDEST := (cTmp)->GW1_CDDEST
		(cAlias)->GW1_NMDEST := Posicione("GU3",1,xFilial("GU3")+(cTmp)->GW1_CDDEST,"GU3_NMEMIT")
		(cAlias)->GW1_TPFRET := aTpFret[Val((cTmp)->GW1_TPFRET)]
		(cAlias)->GW1_NRROM  := (cTmp)->GW1_NRROM
		(cAlias)->GWU_SEQ    := (cTmp)->GWU_SEQ
		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo
	
	(cTmp)->(dbCloseArea())
Return cAlias
