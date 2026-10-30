#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC002B
Painel Gerencial Filiais - Informações sobre Romaneios

Uso Restrito. 

Param:
aParam[1] := Data de
aParam[2] := Data ate
aParam[3] := Codigo do Emitente     

@sample
GFEC002B(aParam)

@author Alan Victor Lamb
@since 28/06/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEC002B(aParam)
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := 'Painel Gerencial - Filial'     
	
	Private aBrowse := {} 
	Private aFiltros, aDados
	Private aGrfSit, aGrfTpOp, aGrfClFr, aGrfTpVc, aGrfTrp
	Private oGrfSit, oGrfTpOp, oGrfClFr, oGrfTpVc, oGrfTrp
	Private oBrowseEst, oBrowseRom 
	Private cFil     := aParam[3]
	Private dDataDe  := If(Empty(aParam[1]),DDATABASE -30 ,aParam[1])
	Private dDataAte := If(Empty(aParam[2]),DDATABASE     ,aParam[2])                   
	
	//Carrega os dados do Grafico e do Resumo  
	aFiltros := {{"GWN","GWN_FILIAL","=",cFil	    },;   
				 {"GWN","GWN_DTIMPL",">=",Dtos(dDataDe)  },;
				 {"GWN","GWN_DTIMPL","<=",Dtos(dDataAte) }}  
	                                                                                
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine( 'LINE_MIDDLE', 50, .F. )
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn( 'COL_LEFT',40,.T.,'LINE_MIDDLE')
	oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Estatísticas',100,.F.,.F.,,'LINE_MIDDLE',)
	oFWLayer:AddCollumn('COL_RIGHT',60,.T.,'LINE_MIDDLE')
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Gráficos',100,.F.,.F.,,'LINE_MIDDLE',)
  	oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT', 'LINE_MIDDLE')
	oWIN_RIGHT := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT', 'LINE_MIDDLE')
	
	oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
Return

Static Function GetSituacao()
	Local aSituacao := StrToKArr(Posicione("SX3",2,"GWN_SIT","X3_CBOX"),";")
	Local cRet := ""
	
	If !Empty(GWN->GWN_SIT) .AND.;
	   Val(GWN->GWN_SIT) > 0 .AND.;
	   Val(GWN->GWN_SIT) <= Len(aSituacao)
		cRet := SUBSTR(aSituacao[Val(GWN->GWN_SIT)],3)
	EndIf
Return cRet 

Static Function Iniciar()
	Local cBrowseFiltro := '' 
	
	//Filtro do Browse
	cBrowseFiltro += "GWN_FILIAL == '" + cFil + "' .AND. "  
	cBrowseFiltro += "GWN_DTIMPL >= '" + DtoS(dDataDe) + "' .AND. GWN_DTIMPL <= '" + DtoS(dDataAte) + "'"
	     
	aDados := CarregaDados(aFiltros)
	
	//Browse Romaneio
	oBrowseRom:= FWmBrowse():New() 
	oBrowseRom:SetOwner(oWIN_TOP)  
	oBrowseRom:SetAlias('GWN')
	oBrowseRom:SetDescription("Romaneios de Carga")
	oBrowseRom:DisableDetails()
	oBrowseRom:SetAmbiente(.F.)
	oBrowseRom:SetWalkthru(.F.)
	oBrowseRom:SetLocate()
	oBrowseRom:SetMenuDef("")
	oBrowseRom:SetProfileID("1") 
	oBrowseRom:SetFilterDefault(cBrowseFiltro)
	oBrowseRom:BVLDEXECFILTER := {|aParam| GFEC002BV(aParam)}
	oBrowseRom:AddButton("Visualizar","VIEWDEF.GFEC050",,2)
	oBrowseRom:ForceQuitButton(.T.)
	oBrowseRom:SetFields({{"Situação", {|| GetSituacao() }, "C","",1,10,0,.F.}})
	oBrowseRom:Activate()
   
	Define Font oFont Name 'Courier New' Size 0, -12
    
    // Browse com as estatísticas dos romaneios
	FeedBrowse(aDados) 
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
   	
   	oFolder := TFolder():New(0,0,{"Situação","Tipo Operação","Class Frete","Tipo Veículo","Transportador"},,oWIN_RIGHT,,,,.T.,,(oWIN_RIGHT:nwidth/2),(oWIN_RIGHT:nHeight/2))
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
   	
	aGrfSit := {}
	aADD(aGrfSit, {"Digitado", aDados[1][2]})
	aADD(aGrfSit, {"Impresso", aDados[2][2]})
	aADD(aGrfSit, {"Liberado", aDados[3][2]})
	aADD(aGrfSit, {"Encerrado",aDados[4][2] })
	
    GFEC001GRC("oGrfSit", "Romaneios de Carga por Situação", oFolder:aDialogs[1], aGrfSit)
    GFEC001GRC("oGrfTpOp","Romaneios por Tipo Operação",oFolder:aDialogs[2], aGrfTpOp)
    GFEC001GRC("oGrfClFr","Romaneios por Class Frete"  ,oFolder:aDialogs[3], aGrfClFr)
    GFEC001GRC("oGrfTpVc","Romaneios por Tipo Veículo" ,oFolder:aDialogs[4], aGrfTpVc)
    GFEC001GRC("oGrfTrp", "Romaneios por Transportador",oFolder:aDialogs[5], aGrfTrp)
Return Nil

/*/--------------------------------------------------------------------------------------------------
CarregaDados()
Carrega dados da tela

Uso Restrito. 

Param: Array com informações da Tabela, Campo, Operador Codigo
aParam[1] := Data de
aParam[2] := Data ate
aParam[3] := Filial

cBrwFiltro - Expressão em SQL do Filtro aplicado no Browse    

@sample
CarregaDados(aFiltros,cBrwFiltro)

@author Alan Victor Lamb
@since 28/06/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local cQuery   := ''
	Local cTmp     := ''
	Local aQuery   := {}
	Local s_MULFIL := SuperGetMV("MV_MULFIL",.F.,"2")
	Default cBrwFiltro := ''
	
	cQuery += "  SELECT COUNT(CASE WHEN GWN_SIT = '1' THEN 1 END) GWN_SITDIG, "
	cQuery += "		  COUNT(CASE WHEN GWN_SIT = '2' THEN 1 END) GWN_SITIMP, "
	cQuery += "		  COUNT(CASE WHEN GWN_SIT = '3' THEN 1 END) GWN_SITLIB, "
	cQuery += "		  COUNT(CASE WHEN GWN_SIT = '4' THEN 1 END) GWN_SITENC, "
	cQuery += "		  COUNT(*) QTDROM, "
	cQuery += "         SUM(GW8_PESOR) GFE_PEBRTO,  "
	cQuery += "		  SUM(GW8_PESOC) GFE_PECUTO, "
	cQuery += "		  SUM(GW8_VOLUME) GFE_VOLTOT, " 
	cQuery += "		  SUM(GW8_QTDE) GFE_QTVOTO,  "
	cQuery += "		  SUM(GW8_VALOR) GFE_VLCATO,  "
	cQuery += "		  SUM(GW8_QTDALT) GFE_QTDALT, "
	cQuery += "		  MAX(GWN_DTIMPL) ROMNOV, "
	cQuery += "		  MIN(GWN_DTIMPL) ROMANT, "
	cQuery += "		  QTDIAUTIL "
	cQuery += "	FROM " + RetSQLName("GWN") + " GWN  "
	cQuery += "   INNER JOIN ( SELECT GW1_FILIAL"
	cQuery += "					    , GW1_FILROM"
	cQuery += "					    , GW1_NRROM"
	cQuery += "					    , SUM(GW8_PESOR) GW8_PESOR"
	cQuery += "					    , SUM(GW8_PESOC) GW8_PESOC"
	cQuery += "					    , SUM(GW8_VOLUME) GW8_VOLUME"
	cQuery += "					    , SUM(GW8_QTDE) GW8_QTDE"
	cQuery += "					    , SUM(GW8_VALOR) GW8_VALOR"
	cQuery += "					    , SUM(GW8_QTDALT) GW8_QTDALT " 
	cQuery += "				     FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += "				    INNER JOIN " + RetSQLName("GW8") + " GW8"
	cQuery += "				       ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
	cQuery += "					  AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "					  AND GW8.GW8_EMISDC = GW1.GW1_EMISDC"
	cQuery += "					  AND GW8.GW8_SERDC  = GW1.GW1_SERDC"
	cQuery += "					  AND GW8.GW8_NRDC   = GW1.GW1_NRDC"
	cQuery += "					  AND GW8.D_E_L_E_T_ = ' '"
	cQuery += "				    WHERE GW1.D_E_L_E_T_ = ' ' "
	cQuery += "				    GROUP BY GW1_FILIAL, GW1_FILROM, GW1_NRROM) GW1"
	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		cQuery += "	 ON GWN.GWN_FILIAL = GW1.GW1_FILROM"
	Else
		cQuery += "	 ON GWN.GWN_FILIAL = GW1.GW1_FILIAL"
	EndIf
	cQuery += "		AND GWN.GWN_NRROM  = GW1.GW1_NRROM"
	cQuery += "    LEFT JOIN (SELECT COUNT(*) QTDIAUTIL" 
	cQuery += "		  	        FROM " + RetSQLName("GUW") + " GUW"
	cQuery += "			       WHERE GUW.GUW_TPDIA = '1'"
	cQuery += "			         AND GUW.D_E_L_E_T_ = ' '"
	cQuery += "			         AND GUW.GUW_DATA >= '" + aFiltros[1][4] + "'"
	cQuery += "			         AND GUW.GUW_DATA <= '" + aFiltros[2][4] + "'"
	cQuery += "            ) QTD ON 1 = 1 "
	cQuery += "   WHERE GWN.D_E_L_E_T_ = ' ' " + CriaQueryCondicao(aFiltros,"") + cBrwFiltro
	cQuery += "	  GROUP BY QTDIAUTIL "
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		aADD(aQuery, {"GWN_SITDIG",(cTmp)->GWN_SITDIG}) //Numero de Romaneios Digitados
		aADD(aQuery, {"GWN_SITIMP",(cTmp)->GWN_SITIMP}) //Numero de Romaneios Impressos
		aADD(aQuery, {"GWN_SITLIB",(cTmp)->GWN_SITLIB}) //Numero de Romaneios Liberados
		aADD(aQuery, {"GWN_SITENC",(cTmp)->GWN_SITENC}) //Numero de Romaneios Encerrados
		aADD(aQuery, {"GFE_PEBRTO",(cTmp)->GFE_PEBRTO}) //Peso Bruto total
		aADD(aQuery, {"GFE_PECUTO",(cTmp)->GFE_PECUTO}) //Peso Cubado Total
		aADD(aQuery, {"GFE_VOLTOT",(cTmp)->GFE_VOLTOT}) //Volume Total
		aADD(aQuery, {"GFE_QTVOTO",(cTmp)->GFE_QTVOTO}) //Quantidade de Volumes total
		aADD(aQuery, {"GFE_VLCATO",(cTmp)->GFE_VLCATO}) //Valores da Carga Total
		aADD(aQuery, {"GFE_QTDALT",(cTmp)->GFE_QTDALT}) //Peso/Qtde Alternativa Cargas Total
		aADD(aQuery, {"GFE_ROMNOV",StoD((cTmp)->ROMNOV)}) // Romaneio mais novo
		aADD(aQuery, {"GFE_ROMANT",StoD((cTmp)->ROMANT)}) // Romaneio mais antigo
		aADD(aQuery, {"GFE_QTDROM",(cTmp)->QTDROM}) // Qtd total de romaneios
		
		// Peso médio/Romaneio
		If (cTmp)->GFE_PEBRTO > 0 .And. (cTmp)->QTDROM > 0
			aADD(aQuery,{"GFE_PESROM",(cTmp)->GFE_PEBRTO / (cTmp)->QTDROM})
		Else
			aADD(aQuery,{"GFE_PESROM",0})
		EndIf
		
		// Volume médio/Romaneio
		If (cTmp)->GFE_VOLTOT > 0 .And. (cTmp)->QTDROM > 0
			aADD(aQuery,{"GFE_VOLROM",(cTmp)->GFE_VOLTOT / (cTmp)->QTDROM})
		Else
			aADD(aQuery,{"GFE_VOLROM",0})
		EndIf
		
		aADD(aQuery, {"GFE_QTDIAUTIL",(cTmp)->QTDIAUTIL} )  //Qtde de dias uteis
		
		// Romaneios/dia util
		If (cTmp)->QTDROM > 0 .And. (cTmp)->QTDIAUTIL > 0
			aADD(aQuery, {"GFE_ROMDIAUTIL",(cTmp)->QTDROM / (cTmp)->QTDIAUTIL})       
		Else
			aADD(aQuery, {"GFE_ROMDIAUTIL",0})
		EndIf
		
 		// Quantidade de Dias no período
		aADD(aQuery, {"GFE_QTDDIA",StoD((cTmp)->ROMNOV) - StoD((cTmp)->ROMANT)})
		
		// Romaneios/dia
		If (cTmp)->QTDROM > 0
			aADD(aQuery, {"GFE_ROMDIA", (cTmp)->QTDROM / (StoD((cTmp)->ROMNOV) - StoD((cTmp)->ROMANT))})
		Else
			aADD(aQuery, {"GFE_ROMDIA", 0})
		EndIf 
	EndIf
	
	(cTmp)->(dbCloseArea())
	
	cQuery := ""
	cQuery += "SELECT GWN_CDTPOP, COUNT(*) TOTAL "
	cQuery += "  FROM " + RetSQLName("GWN") + " GWN "
	cQuery += " WHERE D_E_L_E_T_ = ' ' " + CriaQueryCondicao(aFiltros,"") + cBrwFiltro
	cQuery += " GROUP BY GWN_CDTPOP"
	aGrfTpOp := SelDados(cQuery, "TOTAL", "GWN_CDTPOP", "GV4", 1, xFilial("GV4"), "GV4_DSTPOP")
	
	cQuery := ""
	cQuery += "SELECT GWN_CDCLFR, COUNT(*) TOTAL "
	cQuery += "  FROM " + RetSQLName("GWN") + " GWN "
	cQuery += " WHERE D_E_L_E_T_ = ' ' " + CriaQueryCondicao(aFiltros,"") + cBrwFiltro
	cQuery += " GROUP BY GWN_CDCLFR"
	aGrfClFr := SelDados(cQuery, "TOTAL", "GWN_CDCLFR", "GUB", 1, xFilial("GUB"), "GUB_DSCLFR")
	
	cQuery := ""
	cQuery += "SELECT GWN_CDTPVC, COUNT(*) TOTAL "
	cQuery += "  FROM " + RetSQLName("GWN") + " GWN "
	cQuery += " WHERE D_E_L_E_T_ = ' ' " + CriaQueryCondicao(aFiltros,"") + cBrwFiltro
	cQuery += " GROUP BY GWN_CDTPVC"
	aGrfTpVc := SelDados(cQuery, "TOTAL", "GWN_CDTPVC", "GV3", 1, xFilial("GV3"), "GV3_DSTPVC")
	
	cQuery := ""
	cQuery += " SELECT GWN_CDTRP, COUNT(*) TOTAL " 
	cQuery += "  FROM " + RetSQLName("GWN") + " GWN "
	cQuery += " WHERE D_E_L_E_T_ = ' ' " + CriaQueryCondicao(aFiltros,"") + cBrwFiltro
	cQuery += " GROUP BY GWN_CDTRP"
	aGrfTrp := SelDados(cQuery, "TOTAL", "GWN_CDTRP", "GU3", 1, xFilial("GU3"), "GU3_NMABRV")
	aGrfTrp := GFEC002TOP(aGrfTrp, 6)
Return aQuery


Static Function SelDados(cQuery, cCamVal, cCamDes, cPosAli, cPosOrd, cPosPre, cPosCam)
	Local cTmp
	Local xTmpDes, xTmpVal
	Local aDados := {}
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
	dbSelectArea(cTmp)	
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			xTmpDes := (cTmp)->&(cCamDes)
			xTmpVal := (cTmp)->&(cCamVal)
			
			If !Empty(cPosAli)
				xTmpDes := Posicione(cPosAli, cPosOrd, cPosPre+xTmpDes, cPosCam)
			EndIf
			
			xTmpDes := If(Empty(xTmpDes),"Não informado",xTmpDes)
			
			aAdd(aDados, { xTmpDes, xTmpVal })
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	
	(cTmp)->(dbCloseArea())
Return aDados

//=========================================================================/
Function GFEC002BV(aParam) 
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
	
	Processa({||Atualiza(cFiltro)})
Return .T.         
          
Static Function Atualiza(cFiltro)
	CarregaDados(aFiltros,cFiltro)
	
	//Atualiza os Graficos
	GFEC001GRA(oGrfClFr,.T.,aGrfClFr)
	GFEC001GRA(oGrfSit,.T.,aGrfSit)
	GFEC001GRA(oGrfTpOp,.T.,aGrfTpOp)
	GFEC001GRA(oGrfTpVc,.T.,aGrfTpVc)
	GFEC001GRA(oGrfTrp,.T.,aGrfTrp)
	
	//Atualiza o Grid
	FeedBrowse(aDados)  
	oBrowseEst:SetArray(aBrowse)
	oBrowseEst:UpdateBrowse()
Return Nil
                                       
//=========================================================================/
Static Function FeedBrowse(aDados)
 	aBrowse := {} // Zera a variavel
 	aADD(aBrowse, {"Filial"                          ,"-" , AllTrim(FWFilialName(,cFil,))})
 	aADD(aBrowse, {"Peso Bruto Total"    			,"Kg", AllTrim(Transform(aDados[5][2] ,'@E 99,999,999,999.99999')	)	} ) 
	aADD(aBrowse, {"Peso Cubado Total"   			,"Kg", AllTrim(Transform(aDados[6][2] ,'@E 99,999,999,999.99999')	)	} ) 
	aADD(aBrowse, {"Peso/Qtde Alternativa Cargas","Un", AllTrim(Transform(aDados[10][2],'@E 99,999,999,999.99999')  )	} )   
	aADD(aBrowse, {"Volume Total"        			,"M3", AllTrim(Transform(aDados[7][2] ,'@E 99,999,999,999.99999')	)	} ) 
	aADD(aBrowse, {"Qtde Volumes Total"  			,"Un", AllTrim(Transform(aDados[8][2] ,'@E 99,999,999,999.99999')	)	} ) 
	aADD(aBrowse, {"Valor Carga Total"   			,"$" , AllTrim(Transform(aDados[9][2],'@E 99,999,999,999.99999')	)	} )   
	aADD(aBrowse, {"Qtde de Romaneios"         	    ,"Un", Alltrim(STR(aDados[13][2]) ) } )
	aADD(aBrowse, {"Peso médio/Romaneio"         	,"Kg", Alltrim(STR(aDados[14][2]) ) } )
	aADD(aBrowse, {"Volume médio/Romaneio"        ,"M3", Alltrim(STR(aDados[15][2]) ) } )
	aADD(aBrowse, {"Data do romaneio mais Antigo","Un", Transform(aDados[11][2], '99/99/9999' ) } ) 
	aADD(aBrowse, {"Data do romaneio mais Recente","Un", Transform(aDados[12][2], '99/99/9999' ) } ) 
	aADD(aBrowse, {"Dias úteis do periodo"       	,"Un", Alltrim(STR(aDados[16][2]) ) } ) 
	aADD(aBrowse, {"Romaneios/Dias úteis"        	,"Un", Alltrim(STR(aDados[17][2]) ) } )
	aADD(aBrowse, {"Dias corridos do periodo"    	,"Un", Alltrim(STR(aDados[18][2]) ) } ) 
	aADD(aBrowse, {"Romaneios/Dias corridos"     	,"Un", Alltrim(STR(aDados[19][2]) ) } )
Return Nil

//
// Função utilizada para fazer o recurso de "Outros" nos gráficos.
// Ordena os elementos de forma decrescente e agrupa todos que não estiverem entre os "nTop" - 1 na fatia "Outros"
//
Function GFEC002TOP(aDados, nTop)
	Local aTop := {}
	Local nSum := 0
	Local nCount := 0
	
	// Só faz o "Top" de houve mais elementos do que o definido
	If Len(aDados) > nTop
		aSort(aDados,,,{|x,y| x[2] > y[2]})
		For nCount := 1 To Len(aDados)
			If nCount < nTop
				aAdd(aTop, {aDados[nCount, 1], aDados[nCount ,2]})
			Else
				nSum += aDados[nCount,2]
			EndIf
		Next nCount
		
		aAdd(aTop, {"Outros", nSum })
	Else
		aTop := aDados
	EndIf
Return aTop
