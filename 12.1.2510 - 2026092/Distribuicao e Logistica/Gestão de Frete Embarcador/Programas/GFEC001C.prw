#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC001C
Painel Gerencial - Informações sobre o Romaneio

Uso Restrito. 

Param:
aParam[1] := Filial de
aParam[2] := Filial ate
aParam[3] := Data de
aParam[4] := Data ate
aParam[5] := Codigo do Emitente     

@sample
GFEC001C(aParam)

@author Felipe Mendes / Alan Victor Lamb
@since 05/05/12
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEC001C(aParam)
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := 'Painel Gerencial - Transportador'     
	
	Private aBrowse, aGrfRom
	Private aFiltros
	Private oBrowseEst, oBrowseRom 
	Private oGrfRom_Sit
	Private cFilialDe  := aParam[1]
	Private cFilialAte := aParam[2]
	Private dDataDe  := If(Empty(aParam[3]),DDATABASE -30 ,aParam[3])
	Private dDataAte := If(Empty(aParam[4]),DDATABASE     ,aParam[4])                   
	Private cCodEmit := aParam[5]
	
	//Carrega os dados do Grafico e do Resumo  
	aFiltros := {{"GWN","GWN_CDTRP" ,"=" ,cCodEmit       },;
				 {"GWN","GWN_FILIAL",">=",cFilialDe      },;
				 {"GWN","GWN_FILIAL","<=",cFilialAte	 },;   
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
	
	If !Empty(GWN->GWN_SIT) .AND. ;
	    Val(GWN->GWN_SIT) > 0 .AND.;
	    Val(GWN->GWN_SIT) <= Len(aSituacao)
	   cRet := SUBSTR(aSituacao[Val(GWN->GWN_SIT)],3)
	EndIf
Return cRet

Static Function Iniciar()
	Local cBrowseFiltro  
	
	//Filtro do Browse
	cBrowseFiltro := "GWN_CDTRP  == '" + cCodEmit      + "' .AND. "  
	cBrowseFiltro += "GWN_FILIAL >= '" + cFilialDe     + "' .AND. GWN_FILIAL <= '" + cFilialAte     + "' .AND. "  
	cBrowseFiltro += "GWN_DTIMPL >= '" + DtoS(dDataDe) + "' .AND. GWN_DTIMPL <= '" + DtoS(dDataAte) + "'"
	     
	CarregaDados(aFiltros)
	
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
	oBrowseRom:SetFields({{"Situação", {|| GetSituacao() }, "C","",1,10,0,.F.}})
	oBrowseRom:BVLDEXECFILTER := {|aParam| GFEC001CV(aParam)}
	oBrowseRom:AddButton("Visualizar","VIEWDEF.GFEC050",,2)
	oBrowseRom:ForceQuitButton(.T.)
	oBrowseRom:Activate()
   
	Define Font oFont Name 'Courier New' Size 0, -12
    
    // Browse com as estatísticas dos romaneios
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
   	
    //Grafico Pizza - Romaneio por Situação
    GFEC001GRC("oGrfRom_Sit","Romaneios de Carga por Situação",oWIN_RIGHT,aGrfRom)
Return Nil


Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local cQuery   := ''
	Local cTmp     := ''
	Local nPMRom   := 0
	Local nVMRom   := 0
	Local nROMDU   := 0
	Local nROMDC   := 0
	Local s_MULFIL := SuperGetMV("MV_MULFIL",.F.,"2")
	Default cBrwFiltro := ''
	
	aGrfRom := {}
	aBrowse := {}
	aADD(aBrowse, {"Transportador","-" ,Posicione("GU3", 1, xFilial("GU3")+cCodEmit,"GU3_NMEMIT")})
	
	cQuery += "  SELECT COUNT(CASE WHEN GWN_SIT = '1' THEN 1 END) GWN_SITDIG"
	cQuery += "		  , COUNT(CASE WHEN GWN_SIT = '2' THEN 1 END) GWN_SITIMP"
	cQuery += "		  , COUNT(CASE WHEN GWN_SIT = '3' THEN 1 END) GWN_SITLIB"
	cQuery += "		  , COUNT(CASE WHEN GWN_SIT = '4' THEN 1 END) GWN_SITENC"
	cQuery += "		  , COUNT(*) QTDROM"
	cQuery += "       , SUM(GW8_PESOR) GFE_PEBRTO"
	cQuery += "		  , SUM(GW8_PESOC) GFE_PECUTO"
	cQuery += "		  , SUM(GW8_VOLUME) GFE_VOLTOT" 
	cQuery += "		  , SUM(GW8_QTDE) GFE_QTVOTO"
	cQuery += "		  , SUM(GW8_VALOR) GFE_VLCATO"
	cQuery += "		  , SUM(GW8_QTDALT) GFE_QTDALT"
	cQuery += "		  , MAX(GWN_DTIMPL) ROMNOV"
	cQuery += "		  , MIN(GWN_DTIMPL) ROMANT"
	cQuery += "		  , QTDIAUTIL"
	cQuery += "	FROM " + RetSQLName("GWN") + " GWN"
	cQuery += "   INNER JOIN ( SELECT GW1_FILIAL"
	cQuery += "					    , GW1_FILROM"
	cQuery += "					    , GW1_NRROM"
	cQuery += "					    , SUM(GW8_PESOR) GW8_PESOR"
	cQuery += "					    , SUM(GW8_PESOC) GW8_PESOC"
	cQuery += "					    , SUM(GW8_VOLUME) GW8_VOLUME"
	cQuery += "					    , SUM(GW8_QTDE) GW8_QTDE"
	cQuery += "					    , SUM(GW8_VALOR) GW8_VALOR"
	cQuery += "					    , SUM(GW8_QTDALT) GW8_QTDALT" 
	cQuery += "				     FROM " + RetSQLName("GW1") + " GW1"
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
		cQuery += "		  ON GWN.GWN_FILIAL = GW1.GW1_FILROM "
	Else
		cQuery += "		  ON GWN.GWN_FILIAL = GW1.GW1_FILIAL  "
	EndIf
	cQuery += "			 AND GWN.GWN_NRROM = GW1.GW1_NRROM  "
	cQuery += "     LEFT JOIN (SELECT COUNT(*) QTDIAUTIL" 
	cQuery += "		  	         FROM " + RetSQLName("GUW") + " GUW"
	cQuery += "			        WHERE GUW.GUW_TPDIA = '1'"
	cQuery += "			          AND GUW.D_E_L_E_T_ = ' '"
	cQuery += "			          AND GUW.GUW_DATA >= '" + aFiltros[4][4] + "'"
	cQuery += "			          AND GUW.GUW_DATA <= '" + aFiltros[5][4] + "'"
	cQuery += "             ) QTD ON 1 = 1"
	cQuery += "   WHERE GWN.D_E_L_E_T_ = ' ' " + CriaQueryCondicao(aFiltros,"") + cBrwFiltro
	cQuery += "	  GROUP BY QTDIAUTIL "
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
	dbSelectArea(cTmp)	
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		//Dados Gráfico
		aADD(aGrfRom, {"Digitado" , (cTmp)->GWN_SITDIG})
		aADD(aGrfRom, {"Impresso" , (cTmp)->GWN_SITIMP})
		aADD(aGrfRom, {"Liberado" , (cTmp)->GWN_SITLIB})
		aADD(aGrfRom, {"Encerrado", (cTmp)->GWN_SITENC})
		
		//Dados estatísticas
		aADD(aBrowse, {"Peso Bruto Total"    			,"Kg", AllTrim(Transform((cTmp)->GFE_PEBRTO,'@E 99,999,999,999.99999')	)	} ) 
		aADD(aBrowse, {"Peso Cubado Total"   			,"Kg", AllTrim(Transform((cTmp)->GFE_PECUTO,'@E 99,999,999,999.99999')	)	} ) 
		aADD(aBrowse, {"Peso/Qtde Alternativa Cargas","Un", AllTrim(Transform((cTmp)->GFE_QTDALT,'@E 99,999,999,999.99999')  )	} )   
		aADD(aBrowse, {"Volume Total"        			,"M3", AllTrim(Transform((cTmp)->GFE_VOLTOT,'@E 99,999,999,999.99999')	)	} ) 
		aADD(aBrowse, {"Qtde Volumes Total"  			,"Un", AllTrim(Transform((cTmp)->GFE_QTVOTO,'@E 99,999,999,999.99999')	)	} ) 
		aADD(aBrowse, {"Valor Carga Total"   			,"$" , AllTrim(Transform((cTmp)->GFE_VLCATO,'@E 99,999,999,999.99999')	)	} )   
		aADD(aBrowse, {"Qtde de Romaneios"         		,"Un", Alltrim(STR((cTmp)->QTDROM) ) } )
		
		// Peso médio/Romaneio
		If (cTmp)->GFE_PEBRTO > 0 .And. (cTmp)->QTDROM > 0
			nPMRom := (cTmp)->GFE_PEBRTO / (cTmp)->QTDROM
		EndIf
		
		aADD(aBrowse, {"Peso médio/Romaneio","Kg",Alltrim(STR(nPMRom))})
		
		// Volume médio/Romaneio
		If (cTmp)->GFE_VOLTOT > 0 .And. (cTmp)->QTDROM > 0
			nVMRom := (cTmp)->GFE_VOLTOT / (cTmp)->QTDROM
		EndIf
		
		aADD(aBrowse, {"Volume médio/Romaneio"        ,"M3", Alltrim(STR(nVMRom))})
		aADD(aBrowse, {"Data do romaneio mais Antigo","Un", Transform(StoD((cTmp)->ROMANT), '99/99/9999')}) 
		aADD(aBrowse, {"Data do romaneio mais Recente","Un", Transform(StoD((cTmp)->ROMNOV), '99/99/9999')}) 
		aADD(aBrowse, {"Dias úteis do periodo","Un", Alltrim(STR((cTmp)->QTDIAUTIL))})
		
		// Romaneios/dia util
		If (cTmp)->QTDROM > 0 .And. (cTmp)->QTDIAUTIL > 0
			nROMDU  := (cTmp)->QTDROM / (cTmp)->QTDIAUTIL       
		EndIf
		
		aADD(aBrowse, {"Romaneios/Dias úteis"        	,"Un", Alltrim(STR(nROMDU))})
 		aADD(aBrowse, {"Dias corridos do periodo","Un", Alltrim(STR(StoD((cTmp)->ROMNOV) - StoD((cTmp)->ROMANT)))})
		
		// Romaneios/dia
		If (cTmp)->QTDROM > 0
			nROMDC := (cTmp)->QTDROM / (StoD((cTmp)->ROMNOV) - StoD((cTmp)->ROMANT))
		EndIf
		 
		aADD(aBrowse, {"Romaneios/Dias corridos"     	,"Un", Alltrim(STR(nROMDC) ) } )
	EndIf
	
	(cTmp)->(dbCloseArea())
Return

/*/--------------------------------------------------------------------------------------------------
CriaQueryCondicao()
Função que carrega os dados do Grafico e Grid

Uso Restrito. 

Param: Array com informações da Tabela, Campo, Operador Codigo
aParam[1] := Transportador
aParam[2] := Filial de
aParam[3] := Filial ate
aParam[4] := Data de
aParam[5] := Data ate

cNumAlias - Numero que será atribuido junto com o alias na expressão SQL

@sample
CriaQueryCondicao(aFiltros,cBrwFiltro)

@author Felipe Mendes
@since 05/05/12
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function CriaQueryCondicao(aFiltros,cNumAlias)   
	Local nCont
	Local cCondicao := ''
	
	For nCont := 1 To Len(aFiltros)   
		cCondicao += " AND " + aFiltros[nCont][1] + cNumAlias + "." + aFiltros[nCont][2] + aFiltros[nCont][3] + "'" + aFiltros[nCont][4] + "'"
	Next
Return cCondicao 

//
// Após aplicar filtro no Browse, atualiza gráfico/estatísticas
//
Function GFEC001CV(aParam) 
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
	//Atualiza o Grafico
	CarregaDados(aFiltros,cFiltro)
	GFEC001GRA(oGrfRom_Sit,.T.,aGrfRom)//Atualiza gráfico 
	
	//Atualiza o Grid
	oBrowseEst:SetArray(aBrowse)
	oBrowseEst:UpdateBrowse()
Return Nil
