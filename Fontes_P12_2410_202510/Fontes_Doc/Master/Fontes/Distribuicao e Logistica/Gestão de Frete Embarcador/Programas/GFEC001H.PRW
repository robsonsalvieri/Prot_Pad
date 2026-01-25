#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC001H
Painel Gerencial de Transportadores - Informações sobre Pré-faturas

Uso Restrito. 

Param:
aParam[1] := Filial de
aParam[2] := Filial ate
aParam[3] := Data de
aParam[4] := Data ate
aParam[5] := Codigo do Emitente     

@sample
GFEC001H(aParam)

@author Alan Victor Lamb
@since 11/06/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC001H(aParam)   
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := 'Painel Gerencial - Transportador'     
	
	Private oBrowsePF
	Private aGrfQtd, aGrfVal, aGrfQtdS, aGrfFat
	Private oGrfQtd, oGrfVal, oGrfQtdS, oGrfFat
	Private cFilialDe  := aParam[1]
	Private cFilialAte := aParam[2]
	Private dDataDe  := If(Empty(aParam[3]),DDATABASE -30 ,aParam[3])
	Private dDataAte := If(Empty(aParam[4]),DDATABASE     ,aParam[4])                   
	Private cCodEmit := aParam[5]
	Private oFolder
	
	aFiltros := {{"GWJ","GWJ_CDTRP","=" ,cCodEmit},;
				   {"GWJ","GWJ_FILIAL",">=",cFilialDe},;
				   {"GWJ","GWJ_FILIAL","<=",cFilialAte},;   
				   {"GWJ","GWJ_DTIMPL",">=",Dtos(dDataDe)},;
				   {"GWJ","GWJ_DTIMPL","<=",Dtos(dDataAte)}}
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',50,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_MIDDLE',50,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',33,.T.,'LINE_MIDDLE')
    oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Pré-faturas por situação',100,.F.,.F.,,'LINE_MIDDLE',)
    oFWLayer:AddWindow('COL_MIDDLE','WIN_MIDDLE','Pré-faturas por vínculo',100,.F.,.F.,,'LINE_MIDDLE',)
  	
    oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
    oWIN_MIDDLE  := oFWLayer:GetWinPanel('COL_MIDDLE','WIN_MIDDLE','LINE_MIDDLE')
	
	oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
Return 

Static Function GetSituacao()
	Local aSituacao := StrToKArr(Posicione("SX3",2,"GWJ_SIT","X3_CBOX"),";")
	Local cRet := ""
	
	If !Empty(GWJ->GWJ_SIT) .AND. ;
	    Val(GWJ->GWJ_SIT) > 0 .AND.;
	    Val(GWJ->GWJ_SIT) <= Len(aSituacao)
	   cRet := SUBSTR(aSituacao[Val(GWJ->GWJ_SIT)],3)
	EndIf
Return cRet

Static Function Iniciar()
	Local cBrowseFiltro
	Local aColVlPrf
	
	cBrowseFiltro := "GWJ_CDTRP == '" + cCodEmit        + "' .AND. "  
	cBrowseFiltro += "GWJ_FILIAL >= '" + cFilialDe      + "' .AND. GWJ_FILIAL <= '" + cFilialAte     + "' .AND. "  
	cBrowseFiltro += "GWJ_DTIMPL >= '" + DtoS(dDataDe) + "' .AND. GWJ_DTIMPL <= '" + DtoS(dDataAte) + "'"
	
	CarregaDados(aFiltros)
	
	// Pré-faturas de Frete
	oBrowsePF:= FWMBrowse():New()
	oBrowsePF:SetOwner(oWIN_TOP)
	oBrowsePF:SetAlias('GWJ')
	oBrowsePF:SetDescription("Pré-faturas de Frete")
	oBrowsePF:SetLocate()
	oBrowsePF:SetAmbiente(.F.)
	oBrowsePF:SetWalkthru(.F.)
	oBrowsePF:DisableDetails()
	oBrowsePF:SetMenuDef("")
	oBrowsePF:AddButton("Visualizar","VIEWDEF.GFEC055",,2)
	oBrowsePF:ForceQuitButton(.T.)
	oBrowsePF:SetFilterDefault(cBrowseFiltro)
	oBrowsePF:BVLDEXECFILTER := {|aParam| GFEC001HFV(aParam)}
	
	aColVlPrf := {{"Val Pré Fat", {|| GFEC001PRF() }, "N","@E 999,999,999.99",2,15,2,.F.},;
				    {"Situação", {|| GetSituacao() }, "C","",1,10,0,.F.}}
	oBrowsePF:SetFields(aColVlPrf)
	
	oBrowsePF:Activate()
	
	// Pré-faturas por Situação de Aprovação em quantidade de registros 
   	GFEC001GRC("oGrfQtd","Pré-faturas por situação",oWIN_LEFT,aGrfQtd)
    
    // Pré-faturas sem vínculo
    GFEC001GRC("oGrfFat","Pré-faturas por vínculo",oWIN_MIDDLE,aGrfFat)
Return Nil



Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local   cQuery      := ""
	Local   cTmp        := ""
	Default cBrwFiltro := ""
	
	aGrfQtd := {}
	aGrfFat := {}
	
	cQuery += "	SELECT COUNT(CASE WHEN GWJ_SIT = '1' THEN 1 END) QTD_SIT1, " 
	cQuery += "	       COUNT(CASE WHEN GWJ_SIT = '2' THEN 1 END) QTD_SIT2, "
	cQuery += "	       COUNT(CASE WHEN GWJ_SIT = '3' THEN 1 END) QTD_SIT3, "
	cQuery += "	       COUNT(CASE WHEN GWJ_SIT = '4' THEN 1 END) QTD_SIT4, "
	cQuery += "	       COUNT(CASE WHEN GWJ_FILFAT || GWJ_DTEMFA || GWJ_NRFAT || GWJ_SERFAT || GWJ_EMIFAT  = '' THEN 1 END) QTD_SVINC, "
	cQuery += "	       COUNT(CASE WHEN GWJ_FILFAT || GWJ_DTEMFA || GWJ_NRFAT || GWJ_SERFAT || GWJ_EMIFAT != '' THEN 1 END) QTD_VINC "
	cQuery += "	  FROM 	" + RetSQLName("GWJ") + " GWJ "
	cQuery += "	 WHERE GWJ.D_E_L_E_T_ = ' ' " + cBrwFiltro + CriaQueryCondicao(aFiltros,"")
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	
	If (cTmp)->(Recno()) > 0
		aADD(aGrfQtd, {"Pendente",(cTmp)->QTD_SIT1})
		aADD(aGrfQtd, {"Enviada",(cTmp)->QTD_SIT2})
		aADD(aGrfQtd, {"Confirmada",(cTmp)->QTD_SIT3})
		aADD(aGrfQtd, {"Anulada",(cTmp)->QTD_SIT4})
		aADD(aGrfFat, {"com Fatura",(cTmp)->QTD_VINC})	
		aADD(aGrfFat, {"sem Fatura",(cTmp)->QTD_SVINC})
	EndIf
	(cTmp)->(dbCloseArea())
Return Nil

//=========================================================================/ 
// Aplica o filtro do browse na consulta SQL
//=========================================================================/
Function GFEC001HFV(aParam) 
	Local nCont 
	Local cFiltro := ""
	
	For nCont := 1 to Len(aParam)
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
	GFEC001GRA(oGrfQtd,.T.,aGrfQtd)
	GFEC001GRA(oGrfFat,.T.,aGrfFat)
Return Nil      

//
// Faz cálculo do valor da pré-fatura posicionada
//
Function GFEC001PRF()
	Local nRet := 0
	Local aAreaGWJ := GWJ->(GetArea())
	Local aAreaGWF
	Local aAreaGWI
	
	dbSelectArea("GWF")
	aAreaGWF := GWF->(GetArea())
	GWF->(dbSetOrder(3))
	
	If GWF->(dbSeek(GWJ->(GWJ_FILIAL+GWJ_NRPF)))
		dbSelectArea("GWI")
		aAreaGWI := GWI->(GetArea())
		GWI->(dbSetOrder(1))
		
		While GWF->(!Eof()) .And. ;
			   GWF->(GWF_FILPRE+GWF_NRPREF) == GWJ->(GWJ_FILIAL+GWJ_NRPF)
			
			If GWI->(dbSeek(GWF->(GWF_FILIAL+GWF_NRCALC)))
				While GWI->(!Eof()) .And. ;
			   		   GWI->(GWI_FILIAL+GWI_NRCALC) == GWF->(GWF_FILIAL+GWF_NRCALC)
			   		
			   		If GWI->GWI_TOTFRE == "1"
			   			nRet += GWI->GWI_VLFRET
			   		EndIf
			   		
					GWI->(dbSkip())
			    EndDo				
			EndIf
			
			nRet += GWF->GWF_VLAJUS
			
			GWF->(dbSkip())
		EndDo
		
		RestArea(aAreaGWI)
	EndIf
	
	RestArea(aAreaGWF)
	RestArea(aAreaGWJ)
Return nRet
