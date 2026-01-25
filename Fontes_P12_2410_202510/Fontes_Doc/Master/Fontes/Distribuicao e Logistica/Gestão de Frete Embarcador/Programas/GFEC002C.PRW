#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC002C
Painel Gerencial Filiais - Agendamentos

Uso Restrito. 

Param:
aParam[1] := Data de
aParam[2] := Data ate
aParam[3] := Filial     

@sample
GFEC002C(aParam)

@author Alan Victor Lamb
@since 01/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC002C(aParam)   
	Local aCoors  := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Painel Gerencial - Filial'     
	
	Private oBrowseAge, oBrowseEst
	Private  aFiltros, aBrowse, aGrfSit, aGrfTrp
	Private oGrfSit, oGrfTrp
	Private cFil      := aParam[3]
	Private dDataDe  := If(Empty(aParam[1]),DDATABASE -30 ,aParam[1])
	Private dDataAte := If(Empty(aParam[2]),DDATABASE     ,aParam[2])
	Private oWIN_TOP, oWIN_LEFT, oWIN_RIGHT
	
	aFiltros := {{"GWV","GWV_FILIAL","=",cFil},;   
				   {"GWV","GWV_DTAGEN",">=",Dtos(dDataDe)},;
				   {"GWV","GWV_DTAGEN","<=",Dtos(dDataAte)}}  
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',50,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',50,.T.,'LINE_MIDDLE')
    oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Agendamentos por Situação',100,.F.,.F.,,'LINE_MIDDLE',)
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Agendamentos por Transportador',100,.F.,.F.,,'LINE_MIDDLE',)
    
    oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
	oWIN_RIGHT := oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')
	
	oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
Return 

Static Function Iniciar()
	Local cBrowseFiltro  
	
	//Filtro do Browse
	cBrowseFiltro := "GWV_FILIAL == '" + cFil + "' .AND. "  
	cBrowseFiltro += "GWV_DTAGEN >= '" + DtoS(dDataDe)    + "' .AND. GWV_DTAGEN <= '" + DtoS(dDataAte) + "'"
	
	CarregaDados(aFiltros)
	
	// Agendamentos
	oBrowseAge:= FWMBrowse():New()
	oBrowseAge:SetOwner(oWIN_TOP)
	oBrowseAge:SetAlias('GWV')
	oBrowseAge:SetDescription("Agendamentos")
	oBrowseAge:SetLocate()
	oBrowseAge:SetAmbiente(.F.)
	oBrowseAge:SetWalkthru(.F.)
	oBrowseAge:DisableDetails()
	oBrowseAge:SetMenuDef("")
	oBrowseAge:AddButton("Visualizar","VIEWDEF.GFEA517",,2)
	oBrowseAge:ForceQuitButton(.T.) 
	oBrowseAge:SetFilterDefault(cBrowseFiltro)
	oBrowseAge:BVLDEXECFILTER := {|aParam| GFEC002CV(aParam)}
	oBrowseAge:Activate()
	
    GFEC001GRC("oGrfSit", "Agendamentos por Situação", oWIN_LEFT, aGrfSit)
    GFEC001GRC("oGrfTrp", "Agendamentos por Transportador", oWIN_RIGHT, aGrfTrp)
Return Nil

Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local cQuery := ''
	Local cTmp   := ''
	Default cBrwFiltro := ''
	
	// Array do browse estatísticas
	aGrfSit := {}
	aGrfTrp := {}
	
	cQuery += "	SELECT COUNT(CASE WHEN GWV.GWV_SIT = '1' THEN 1 END) SIT_ABERTO, "
	cQuery += "	       COUNT(CASE WHEN GWV.GWV_SIT = '2' THEN 1 END) SIT_CONCLU, "
	cQuery += "	       COUNT(CASE WHEN GWV.GWV_SIT = '3' THEN 1 END) SIT_CANCEL "
	cQuery += "     FROM " + RetSQLName("GWV") + " GWV "
	cQuery += "    WHERE GWV.D_E_L_E_T_ = ' ' " + cBrwFiltro + CriaQueryCondicao(aFiltros,"")
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		aADD(aGrfSit, {"Abertos"   ,(cTmp)->SIT_ABERTO } ) //Numero de Agendamentos em Aberto
		aADD(aGrfSit, {"Concluidos",(cTmp)->SIT_CONCLU } ) //Numero de Agendamentos Concluidos
		aADD(aGrfSit, {"Cancelados",(cTmp)->SIT_CANCEL } ) //Numero de Agendamentos Cancelados
	EndIf
	(cTmp)->(dbCloseArea())
	
	cQuery := ""
	cQuery += "SELECT GWV_CDEMIT, COUNT(*) TOTAL "
	cQuery += "  FROM " + RetSQLName("GWV") + " GWV"
	cQuery += " WHERE GWV.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY GWV_CDEMIT"	
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			aADD(aGrfTrp, {Posicione("GU3",1,xFilial("GU3")+(cTmp)->GWV_CDEMIT,"GU3_NMABRV"),(cTmp)->TOTAL})
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	(cTmp)->(dbCloseArea())
	
	aGrfTrp := GFEC002TOP(aGrfTrp,6)
Return Nil

//=========================================================================/ 
//Validação do filtro do Browse, adapta a expressão do filtro para uma expressão SQL
//=========================================================================/
Function GFEC002CV(aParam) 
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
	GFEC001GRA(oGrfSit,.T.,aGrfSit)
	GFEC001GRA(oGrfTrp,.T.,aGrfTrp)
Return Nil      
