#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC002G
Painel Gerencial de Filiais - Informações sobre Pré-faturas

Uso Restrito. 

Param:
aParam[1] := Data de
aParam[2] := Data ate
aParam[3] := Filial     

@sample
GFEC002G(aParam)

@author Alan Victor Lamb
@since 01/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC002G(aParam)   
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := 'Painel Gerencial - Filial'     
	
	Private oBrowsePF
	Private aGrfQtd, aGrfFat
	Private oGrfQtd, oGrfFat
	Private cFil  := aParam[3]
	Private dDataDe  := If(Empty(aParam[1]),DDATABASE -30 ,aParam[1])
	Private dDataAte := If(Empty(aParam[2]),DDATABASE     ,aParam[2])               
	Private oFolder
	
	aFiltros := {{"GWJ","GWJ_FILIAL","=",cFil},;   
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
	
	If !Empty(GWJ->GWJ_SIT) .AND.;
	   Val(GWJ->GWJ_SIT) > 0 .AND.;
	   Val(GWJ->GWJ_SIT) <= Len(aSituacao)
		cRet := SUBSTR(aSituacao[Val(GWJ->GWJ_SIT)],3)
	EndIf
Return cRet 

Static Function Iniciar()
	Local cBrowseFiltro
	Local aColVlPrf
	
	cBrowseFiltro := "GWJ_FILIAL == '" + cFil + "' .AND. "  
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
	oBrowsePF:BVLDEXECFILTER := {|aParam| GFEC002GFV(aParam)}
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
Function GFEC002GFV(aParam)
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
	GFEC001GRA(oGrfQtd,.T.,aGrfQtd)
	GFEC001GRA(oGrfFat,.T.,aGrfFat)
Return Nil      
