#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC002A
Painel Gerencial Filiais - Informações sobre Documentos de Carga

Uso Restrito. 

Param:
aParam[1] := Filial de
aParam[2] := Filial ate
aParam[3] := Codigo da Filial     

@sample
GFEC002A(aParam)

@author Alan Victor Lamb
@since 28/06/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC002A(aParam)
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Filial'
	
	Private oGrfSit, oGrfTpdc, oGrfExp, oGrfEnt
	Private aBrowse, aGrfSit, aGrfTpdc, aGrfExp, aGrfEnt
	Private oBrowseEst
	Private cFil        := aParam[3]
	Private dDataDe    := If(Empty(aParam[1]),DDATABASE - 30,aParam[1])
	Private dDataAte   := If(Empty(aParam[2]),DDATABASE     ,aParam[2])
	Private aFiltros
	Private oWIN_TOP, oWIN_LEFT, oWIN_MIDDLE, oWIN_RIGHT
	
	//Carrega os dados do Grafico e do Resumo  
	aFiltros := {{"GW1","GW1_FILIAL","=",cFil	   },;
				  {"GW1","GW1_DTEMIS",">=",Dtos(dDataDe)  },;
				  {"GW1","GW1_DTEMIS","<=",Dtos(dDataAte) }}  
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	/*Criando objeto Layer*/
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
Return 

Static Function GetSituacao()
	Local aSituacao := StrToKArr(Posicione("SX3",2,"GW1_SIT","X3_CBOX"),";")
	Local cRet := ""
	
	If !Empty(GW1->GW1_SIT) .AND.;
	   Val(GW1->GW1_SIT) > 0 .AND.;
	   Val(GW1->GW1_SIT) <= Len(aSituacao)
		cRet := SUBSTR(aSituacao[Val(GW1->GW1_SIT)],3)
	EndIf
Return cRet 

Static Function Iniciar()
	CarregaDados(aFiltros)
	
	//Browse Doc carga
	oBrowseDoc:= FWMBrowse():New() 
	oBrowseDoc:SetOwner(oWIN_TOP)  
	oBrowseDoc:SetDescription("Documentos de Carga")
	oBrowseDoc:SetAlias('GW1')
	oBrowseDoc:SetLocate()
	oBrowseDoc:DisableDetails()
	oBrowseDoc:SetMenuDef("")
	oBrowseDoc:SetAmbiente(.F.)
	oBrowseDoc:SetWalkthru(.F.)
	oBrowseDoc:SetProfileID("1") 
	oBrowseDoc:ForceQuitButton(.T.)
	oBrowseDoc:SetFilterDefault("GW1_FILIAL == '" + cFil + "' .AND. GW1_DTEMIS >= '"+DtoS(dDataDe)+"' .AND. GW1_DTEMIS <= '"+DtoS(dDataAte)+"'")
	oBrowseDoc:BVLDEXECFILTER := {|aParam| GFEC002AV(aParam)}
	oBrowseDoc:AddButton("Visualizar","VIEWDEF.GFEC040",,2)
	oBrowseDoc:SetFields({{"Situação", {|| GetSituacao() }, "C","",1,10,0,.F.}})  
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
	
	oFolder := TFolder():New(0,0,{"Situação","Tipo Documento","Expedição","Entrega"},,oWIN_RIGHT,,,,.T.,,(oWIN_RIGHT:nwidth/2),(oWIN_RIGHT:nHeight/2))
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	GFEC001GRC("oGrfSit", "Doc Carga por Situação",oFolder:aDialogs[1],aGrfSit)
	GFEC001GRC("oGrfTpdc","Doc Carga por Tipo Documento",oFolder:aDialogs[2],aGrfTpdc)
	GFEC001GRC("oGrfExp","Doc Carga por Prazo Expedição",oFolder:aDialogs[3],aGrfExp)
	GFEC001GRC("oGrfEnt","Doc Carga por Prazo Embarcador",oFolder:aDialogs[4],aGrfEnt)
Return Nil

//---------------------------------------------------------------------------------------------------            
Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local cQuery := ''
	Local cTmp   := ''
	Local nSitDig := 0
	Local nSitBlo := 0
	Local nSitLib := 0
	Local nSitEmb := 0
	Local nSitEnt := 0
	Local nSitRet := 0	
	Local nSitCan := 0
	Local nSitSin := 0
	Local nTotal := 0
	Local nPesoB := 0
	Local nPesoC := 0
	Local nPesoA := 0
	Local nVolum := 0
	Local nQtdeV := 0
	Local nValor := 0
	Local nQtdEPrz := 0
	Local nQtdEAtr := 0
	Local nQtdEAdi := 0
	Local nQtdEInd := 0
	Local nQtdEnSem := 0
	Local nQtdEnPen := 0
	Local nQtdEnAdi := 0
	Local nQtdEnAtr := 0
	Local nQtdEnPrz := 0
	Default cBrwFiltro := ''
	
	aGrfSit  := {}
	aGrfTpdc := {}
	aGrfExp  := {}
	aGrfEnt  := {}
	aBrowse  := {}
	
	cQuery += "SELECT GW1.GW1_CDTPDC, "
	cQuery += "      COUNT(CASE WHEN GW1.GW1_SIT = '1' THEN 1 END) GW1_SITDIG, "
	cQuery += "	   COUNT(CASE WHEN GW1.GW1_SIT = '2' THEN 1 END) GW1_SITBLO, "
	cQuery += "       COUNT(CASE WHEN GW1.GW1_SIT = '3' THEN 1 END) GW1_SITLIB, "
	cQuery += "       COUNT(CASE WHEN GW1.GW1_SIT = '4' THEN 1 END) GW1_SITEMB, "
	cQuery += "       COUNT(CASE WHEN GW1.GW1_SIT = '5' THEN 1 END) GW1_SITENT, "
	cQuery += "       COUNT(CASE WHEN GW1.GW1_SIT = '6' THEN 1 END) GW1_SITRET, "
	cQuery += "       COUNT(CASE WHEN GW1.GW1_SIT = '7' THEN 1 END) GW1_SITCAN, "
	cQuery += "       COUNT(CASE WHEN GW1.GW1_SIT = '8' THEN 1 END) GW1_SITSIN, "
	cQuery += "       COUNT(*) GW1_TOTAL, "
	cQuery += "       COUNT(CASE WHEN GW1.GW1_DTPSAI = '' THEN 1 END) GW1_PIND, "
	cQuery += "       COUNT(CASE WHEN GW1.GW1_DTPSAI != '' AND GW1.GW1_DTPSAI = GW1.GW1_DTSAI THEN 1 END) GW1_PPRZ, "
	cQuery += "       COUNT(CASE WHEN GW1.GW1_DTPSAI != '' AND GW1.GW1_DTPSAI > GW1.GW1_DTSAI THEN 1 END) GW1_PADI, "
	cQuery += "       COUNT(CASE WHEN GW1.GW1_DTPSAI != '' AND GW1.GW1_DTPSAI < GW1.GW1_DTSAI THEN 1 END) GW1_PATR, "
	cQuery += "	   SUM(GW8.GW8_PESOR) GFE_PEBRTO,"
	cQuery += "	   SUM(GW8.GW8_PESOC) GFE_PECUTO,"
	cQuery += "	   SUM(GW8.GW8_QTDALT) GFE_QTDALT,"
	cQuery += "	   SUM(GW8.GW8_VOLUME) GFE_VOLTOT,"
	cQuery += "	   SUM(GW8.GW8_QTDE) GFE_QTVOTO,"
	cQuery += "	   SUM(GW8.GW8_VALOR) GFE_VLCATO,"
	cQuery += "		COUNT(CASE WHEN GW1_DTPENT = '' THEN 1 END) SEM_PRV, "
	cQuery += "		COUNT(CASE WHEN GW1_DTPENT != '' AND GWU_DTENT = '' THEN 1 END) PEND, "
	cQuery += "		COUNT(CASE WHEN GW1_DTPENT != '' AND GWU_DTENT != '' AND GW1_DTPENT = GWU_DTENT THEN 1 END) PRZ, "
	cQuery += "		COUNT(CASE WHEN GW1_DTPENT != '' AND GWU_DTENT != '' AND GW1_DTPENT < GWU_DTENT THEN 1 END) ATR, "
	cQuery += "		COUNT(CASE WHEN GW1_DTPENT != '' AND GWU_DTENT != '' AND GW1_DTPENT > GWU_DTENT THEN 1 END) ADI "
	cQuery += "  FROM " + RetSQLName('GW1') + " GW1 "
	cQuery += "  LEFT JOIN ( SELECT GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC, "
	cQuery += "                     SUM(GW8_PESOR) GW8_PESOR,SUM(GW8_PESOC) GW8_PESOC,SUM(GW8_QTDALT) GW8_QTDALT,"
	cQuery += "                     SUM(GW8_VOLUME) GW8_VOLUME,SUM(GW8_QTDE) GW8_QTDE,SUM(GW8_VALOR) GW8_VALOR"
	cQuery += "                FROM " + RetSQLName( 'GW8' )
	cQuery += "               WHERE D_E_L_E_T_ = ' '"
	cQuery += "               GROUP BY GW8_FILIAL, GW8_CDTPDC, GW8_EMISDC, GW8_SERDC, GW8_NRDC) GW8 ON GW8.GW8_FILIAL = GW1.GW1_FILIAL"
	cQuery += "                      AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "                      AND GW8.GW8_EMISDC = GW1.GW1_EMISDC "
	cQuery += "                      AND GW8.GW8_SERDC  = GW1.GW1_SERDC "
	cQuery += "                      AND GW8.GW8_NRDC   = GW1.GW1_NRDC "
	cQuery += "	  LEFT JOIN ( "
	cQuery += "		   	SELECT GWU1.GWU_FILIAL, GWU1.GWU_CDTPDC, GWU1.GWU_EMISDC, GWU1.GWU_SERDC, GWU1.GWU_NRDC, GWU1.GWU_DTENT"
	cQuery += "			  FROM " + RetSQLName("GWU") + " GWU1"
	cQuery += "			 INNER JOIN ("
	cQuery += "			 	SELECT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC, MAX(GWU_SEQ) GWU_SEQ"
	cQuery += "			 	  FROM " + RetSQLName("GWU")
	cQuery += "			 	 WHERE D_E_L_E_T_ = ' ' "
	cQuery += "			 	   AND GWU_PAGAR = '1' "
	cQuery += "			     GROUP BY GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC"
	cQuery += "			 ) GWU2 ON GWU1.GWU_FILIAL = GWU2.GWU_FILIAL "
	cQuery += "				   AND GWU1.GWU_CDTPDC = GWU2.GWU_CDTPDC"
	cQuery += "				   AND GWU1.GWU_EMISDC = GWU2.GWU_EMISDC"
	cQuery += "				   AND GWU1.GWU_SERDC  = GWU2.GWU_SERDC"
	cQuery += "				   AND GWU1.GWU_NRDC   = GWU2.GWU_NRDC"
	cQuery += "				   AND GWU1.GWU_SEQ    = GWU2.GWU_SEQ"
	cQuery += "			WHERE GWU1.D_E_L_E_T_ = ' '"
	cQuery += "			  AND GWU1.GWU_PAGAR = '1'"
	cQuery += "		 ) GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += "		      AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "		      AND GWU.GWU_EMISDC = GW1.GW1_EMISDC "
	cQuery += "		      AND GWU.GWU_SERDC  = GW1.GW1_SERDC "
	cQuery += "		      AND GWU.GWU_NRDC   = GW1.GW1_NRDC "
	cQuery += " WHERE GW1.D_E_L_E_T_ = ' '" + CriaQueryCondicao(aFiltros,"") + cBrwFiltro
	cQuery += " GROUP BY GW1.GW1_CDTPDC "
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)	
	(cTmp)->(dbGoTop())
	If (cTmp)->(RecNo()) > 0
		While (cTmp)->(!Eof())
			// Quantidade de documentos de carga por tipo de documento
			aADD(aGrfTpdc, {(cTmp)->GW1_CDTPDC, (cTmp)->GW1_TOTAL})
			
			// Gráfico por situação
			nSitDig += (cTmp)->GW1_SITDIG
			nSitBlo += (cTmp)->GW1_SITBLO
			nSitLib += (cTmp)->GW1_SITLIB
			nSitEmb += (cTmp)->GW1_SITEMB
			nSitEnt += (cTmp)->GW1_SITENT
			nSitRet += (cTmp)->GW1_SITRET
			nSitCan += (cTmp)->GW1_SITCAN
			nSitSin += (cTmp)->GW1_SITSIN
			
			// Estatísticas
			nTotal += (cTmp)->GW1_TOTAL
			nPesoB += (cTmp)->GFE_PEBRTO
			nPesoC += (cTmp)->GFE_PECUTO 
			nPesoA += (cTmp)->GFE_QTDALT
			nVolum += (cTmp)->GFE_VOLTOT
			nQtdeV += (cTmp)->GFE_QTVOTO
			nValor += (cTmp)->GFE_VLCATO
			
			// Expedição
			nQtdEPrz += (cTmp)->GW1_PPRZ
			nQtdEAtr += (cTmp)->GW1_PATR
			nQtdEAdi += (cTmp)->GW1_PADI
			nQtdEInd += (cTmp)->GW1_PIND
			
			// Entrega
			nQtdEnSem += (cTmp)->SEM_PRV
			nQtdEnPen += (cTmp)->PEND
			nQtdEnAdi += (cTmp)->ADI
			nQtdEnAtr += (cTmp)->ATR
			nQtdEnPrz += (cTmp)->PRZ
			
			(cTmp)->(dbSkip())
		EndDo
		
		aADD(aGrfSit, {"Digitado"  ,nSitDig})
		aADD(aGrfSit, {"Bloqueado" ,nSitBlo})
		aADD(aGrfSit, {"Liberado"  ,nSitLib})
		aADD(aGrfSit, {"Embarcado" ,nSitEmb})
		aADD(aGrfSit, {"Entregue"  ,nSitEnt})
		aADD(aGrfSit, {"Retornado" ,nSitRet})
		aADD(aGrfSit, {"Cancelado" ,nSitCan})
		aADD(aGrfSit, {"Sinistrado",nSitSin})
		
		aADD(aGrfExp, {"No Prazo"  ,nQtdEPrz})
		aADD(aGrfExp, {"Atrasado" ,nQtdEAtr})
		aADD(aGrfExp, {"Adiantado"  ,nQtdEAdi})
		aADD(aGrfExp, {"Indeterminado" ,nQtdEInd})		
		
		aADD(aGrfEnt, {"Adiantado", nQtdEnAdi})
		aADD(aGrfEnt, {"Atrasado", nQtdEnAtr})
		aADD(aGrfEnt, {"No prazo", nQtdEnPrz})
		aADD(aGrfEnt, {"Pendente",nQtdEnPen})
		aADD(aGrfEnt, {"Sem previsão",nQtdEnSem})		
		
		aADD(aBrowse, {"Filial"                          ,"-" , AllTrim(FWFilialName(,cFil,))})
		aADD(aBrowse, {"Peso Bruto Total"    			,"Kg", AllTrim(Transform(nPesoB,'@E 99,999,999,999.99999'))}) 
		aADD(aBrowse, {"Peso Cubado Total"   			,"Kg", AllTrim(Transform(nPesoC ,'@E 99,999,999,999.99999'))}) 
		aADD(aBrowse, {"Peso/Qtde Alternativa Cargas","Un", AllTrim(Transform(nPesoA,'@E 99,999,999,999.99999'))})   
		aADD(aBrowse, {"Volume Total"        			,"M3", AllTrim(Transform(nVolum ,'@E 99,999,999,999.99999'))}) 
		aADD(aBrowse, {"Qtde Volumes Total"  			,"Un", AllTrim(Transform(nQtdeV ,'@E 99,999,999,999'))}) 
		aADD(aBrowse, {"Valor Carga Total"   			,"$" , AllTrim(Transform(nValor ,'@E 99,999,999,999.99'))})   
		aADD(aBrowse, {"Qtde de Documentos"         	,"Un", Alltrim(STR(nTotal)) } )
	EndIf
	
	(cTmp)->(dbCloseArea())
Return Nil		   

//=========================================================================/
Function GFEC002AV(aParam) 
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
	
	//Atualiza Gráficos
	GFEC001GRA(oGrfSit,.T.,aGrfSit)
	GFEC001GRA(oGrfTpdc,.T.,aGrfTpdc)
	GFEC001GRA(oGrfExp,.T.,aGrfExp)
	GFEC001GRA(oGrfEnt,.T.,aGrfEnt)
	
	//Atualiza o Grid  
	oBrowseEst:SetArray(aBrowse)
	oBrowseEst:UpdateBrowse()
Return Nil 

//=========================================================================/
