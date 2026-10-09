#INCLUDE "GFEC061.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC061
Consulta de Tabela de Frete.

@sample
GFEC061()

@author Octávio Augusto Felippe de Macedo / Alan Victor Lamb
@since 06/11/09
@version 1.0
--------------------------------------------------------------------------------------------------*/


/*/{Protheus.doc} GFEPanelCss
@author Alan Victor Lamb
@since 04/09/2013
@version 1.0

@description
Classe utilizada para ser um container do objeto FWMVCWindow sem a necessidade de ser um MSDialog.
No método Show do FWMVCWindow era setada a propriedade "lEscClose" que o TPanelCss não possui, 
gerando erro de execução no programa.
/*/
Class GFEPanelCss From TPanelCss
	Data lEscClose
	Method New() Constructor
EndClass

Method New(nRow, nCol, cText, oWnd, lCentered, lPar6, nClrText, nClrBack, nWidth, nHeight, lLowered, lRaised) Class GFEPanelCss
	:New(nRow, nCol, cText, oWnd, lCentered, lPar6, nClrText, nClrBack, nWidth, nHeight, lLowered, lRaised)
	self:lEscClose := .F.
Return Self

Class GFETree /*From LongNameClass*/
	Data oDlg
	Data oLayer
	Data oTree
	Data aLayer
	Data oMain
	Data aCompsAct
	Data oComp
	Data aNodes	
	Data oFWMVCWindow
	Data oView
	Data lAssembled
	Data oFwFilter
	Data cTblFilter
	Data cFilter
	Data aSeek
	Data aCols
	Data lSorted
	
	Method New() Constructor 
	Method SetNodes(aNodes)
	Method AssembleTree(aNodes, nLevel)
	Method AddMultiBrowse(aStruct, cCargo)
	Method TreeChange()
	Method Activate(lActAfter)
	Method LoadView(cView,oOwner)
	Method NewTree()
	Method Atualizar()
	Method CriaFilter()
	Method GetFilter()
	Method ShowFiltro()
	Method ShowPesquisa()
EndClass

//--------------------------------------------------------------

Method New() Class GFETree
	
	Local aSize
	Local oQuit
	Local oPanelBot
	
	aSize := MsAdvSize()
	
	self:lAssembled := .F.
	self:aLayer     := {}
	self:aCompsAct  := {}
	self:oComp      := Nil
	self:aSeek		 := {}
	self:aCols		 := {}
	self:lSorted := .F.
	
	self:oDlg := MSDialog():New(aSize[1], aSize[2], aSize[6], aSize[5], "Consulta de Tabelas de Frete",,,,, CLR_BLACK, CLR_WHITE,,, .T.)
	self:oDlg:lEscClose := .F.
			
		self:oLayer := FWLayer():New()
		
		self:oLayer:Init(self:oDlg, .F.)
		
		self:oLayer:AddCollumn('Col01', 30, .F.)
			
			self:oLayer:AddWindow('Col01', 'Win_Tree', 'Consultas', 100, .F., .F.,{|| },,{|| })
				
				oPanelBot := tPanel():New(0,0,"",self:oLayer:getWinPanel('Col01', 'Win_Tree'),,,,,RGB(239,243,247),000,015)
				oPanelBot:Align			:= CONTROL_ALIGN_BOTTOM
				
				oQuit := THButton():New(0, 0, "Sair", oPanelBot, {|| If(!Empty(self:oFWMVCWindow),self:oFWMVCWindow:oView:DeActivate(),),self:oDlg:End() }, , , , )
				oQuit:Align := CONTROL_ALIGN_RIGHT
				oQuit:SetColor(RGB(002,070,112),)
				
				oQuit := THButton():New(0, 0, "Filtrar", oPanelBot, {|| self:ShowFiltro(.F.) }, , , , )
				oQuit:Align := CONTROL_ALIGN_RIGHT
				oQuit:SetColor(RGB(002,070,112),)
				
				oQuit := THButton():New(0, 0, "Pesquisar", oPanelBot, {|| self:ShowPesquisa() }, , , , )
				oQuit:Align := CONTROL_ALIGN_RIGHT
				oQuit:SetColor(RGB(002,070,112),)
				
				self:NewTree()
			
		self:oLayer:AddCollumn('Col02', 70, .F.)
		
		self:oMain := self:oLayer:GetColPanel('Col02')
		
Return Self

Method ShowFiltro(lShow) Class GFETree
	If lShow
		If Empty(self:oFwFilter)
			self:CriaFilter()
		EndIf
		self:oFwFilter:Activate()
	Else
		MsgInfo("A utilização do filtro é permitida somente na abertura do programa. Após a utilização do filtro na abertura, utilizar a Pesquisa para localizar o transportador e tabela.")
	EndIf
Return

Method ShowPesquisa() Class GFETree
	Local nItem
	Local cCargo
	Local aCols := {"Item"}
	If !Empty(self:aSeek)
		
		If !self:lSorted
			aSort(self:aSeek,,,{|x,y|x[1] < y[1]})
			self:lSorted := .T.
		EndIf
		
		For nItem := 1 To Len(self:aCols)
			aAdd(aCols,self:aCols[nItem])
		Next nItem
		
		nItem := TmsF3Array( aCols, self:aSeek, "Lista" ,,,aCols)
		If nItem > 0
			cCargo := self:aSeek[nItem][Len(self:aSeek[nItem])]
			self:oTree:TreeSeek(cCargo)
			self:TreeChange()                    
		Endif		
	Else
		MsgInfo("Não há itens para pesquisa")
	EndIf
Return

Method GetFilter() Class GFETree
	If Empty(self:oFwFilter)
		self:CriaFilter(self:oDlg)
	EndIf
Return self:oFwFilter

Method CriaFilter() Class GFETree
	If Empty(self:oFwFilter)
		self:oFwFilter := FWFilter():New(self:oDlg)
		self:oFwFilter:SetAlias(self:cTblFilter)
		self:oFwFilter:SetProfileID("610C")
		self:oFwFilter:SetCanFilterAsk(.T.)
		self:oFwFilter:DisableValid(.F.)
		self:oFwFilter:CleanFilter(.T.)
		self:oFwFilter:DisableAdd(.T.)
		self:oFwFilter:DisableDel(.T.)
		self:oFwFilter:DisableSave(.T.)
		self:oFwFilter:DisableExecute(.F.)
		self:oFwFilter:SetExecute({|| self:cFilter := self:oFwFilter:GetExprAdvPL() , self:Atualizar()})
	EndIf
Return 

Method NewTree() Class GFETree
	self:oTree := dbTree():New(0, 0, 0, 0, self:oLayer:getWinPanel('Col01', 'Win_Tree'), {|| self:TreeChange()},, .T.)
	self:oTree:Align := CONTROL_ALIGN_ALLCLIENT
Return

Method Atualizar() Class GFETree

	// Tratamento caso seja selecionado os dois filtros da situação ou todos os filtros.
	If  self:OFWFILTER:ACHECKFIL[1]  == .T. .And. self:OFWFILTER:ACHECKFIL[2] == .T.
		self:cFilter := StrTran(self:cFilter,"(GV9->GV9_SIT == '1' )  .And. (GV9->GV9_SIT == '2' )","(GV9->GV9_SIT $ '12')",1,1)
	EndIf 

	If !Empty(self:cFilter)
		(self:cTblFilter)->(dbSetFilter(&("{||" + self:cFilter + "}"),self:cFilter))
	Else
		(self:cTblFilter)->(dbClearFilter())
	EndIf
	
	If self:lAssembled
		aSize(self:aSeek,0)
		self:lSorted := .F.
		self:oTree:BeginUpdate()
		self:oTree:Hide()
		self:oTree:Reset()
		self:oTree:Refresh()
		self:oTree:PTUpdateNodes('1')
		self:oTree:EndUpdate()
		self:oTree:Show()
		self:oTree:BeginUpdate()
		self:oTree:Hide()
		self:AssembleTree(self:aNodes)
		self:oTree:EndUpdate()
		self:oTree:Show()
		self:oTree:Refresh()
		self:TreeChange()
	EndIf
Return

//--------------------------------------------------------------

Method SetNodes(aNodes) Class GFETree
	
	self:aNodes := aNodes
	
Return

//--------------------------------------------------------------

Method AssembleTree(aNodes, nLevel, lLoop, cParSeek) Class GFETree
	
	Local nNode
	Local cCargo
	Local cTbl
	Local aArea
	Local nX
	Local aAlinha
	
	Default nLevel := 0
	Default lLoop  := .F.
	
	For nNode := 1 To Len(aNodes)
		
		If Len(aNodes[nNode]) < 7 .Or. Empty(aNodes[nNode][7]) .Or. &(aNodes[nNode][7][1]) 
			
			If Empty(aNodes[nNode][5]) .Or. lLoop
			
				If !Empty(aNodes[nNode][6])
					
					If !lLoop
					
						cCargo := IIf(nLevel == 0 , PadR(Str(nNode - 1), 100), cValToChar(nLevel - 1) + "." + PadR(cValToChar(nNode - 1), 100 - Len(cValToChar(nLevel - 1) + ".")))
						
					Else
						
						cCargo := "L" + cValToChar(nLevel - 1) + "." +  cValToChar(nNode - 1) + ";" + IIf(Empty(aNodes[nNode][5]), "", &( aNodes[nNode][5][3] ) )
						
					EndIf
					
					If !Empty(cParSeek)
					
						cCargo += ";" + cParSeek
						
					EndIf
					
					self:oTree:AddTree(IIf(lLoop .And. !Empty(aNodes[nNode][5]), &(aNodes[nNode][1]), aNodes[nNode][1]) + Replicate(" ", 50), .F.,,, aNodes[nNode][2], aNodes[nNode][3], cCargo)
					
					If Len(aNodes[nNode]) >= 8 .And. aNodes[nNode,8,1] == .T.
						aAlinha := {}
						aAdd(aAlinha,IIf(lLoop .And. !Empty(aNodes[nNode][5]), &(aNodes[nNode][1]), aNodes[nNode][1]))
						For nX := 1 To Len(aNodes[nNode,8,2])
							aAdd(aAlinha,&(aNodes[nNode,8,2,nX,1]))
							If aScan(self:aCols,{|x|x == aNodes[nNode,8,2,nX,2]}) == 0
								aAdd(self:aCols,aNodes[nNode,8,2,nX,2])
							EndIf
						Next nX
						aAdd(aAlinha,cCargo)
						aAdd(self:aSeek,aClone(aAlinha))
					EndIf
					
						self:AssembleTree(aNodes[nNode][6], nLevel + 1, If(!Empty(aNodes[nNode][6][1][5]), .F., lLoop), cParSeek)
					
					self:oTree:EndTree()
//					If self:lAssembled
//						self:oTree:TreeSeek(cCargo)
//						self:oTree:PTCollapse()
//					EndIf
				Else
					
					If !lLoop
		
						cCargo := cValToChar(nLevel - 1) + "." + PadR(cValToChar(nNode - 1), 100 - Len(cValToChar(nLevel - 1) + "."))
						
					Else
						
						cCargo := "L" + cValToChar(nLevel - 1) + "." +  cValToChar(nNode - 1) + ";" + IIf(Empty(aNodes[nNode][5]), "", &( aNodes[nNode][5][3] ) )
						
					EndIf
					
					If !Empty(cParSeek)
						cCargo += ";" + cParSeek
					EndIf
					
					self:oTree:AddTreeItem(IIf(lLoop .And. !Empty(aNodes[nNode][5]), &(aNodes[nNode][1]), aNodes[nNode][1]), aNodes[nNode][2],, cCargo)
					If Len(aNodes[nNode]) >= 8 .And. aNodes[nNode,8,1] == .T.
						aAlinha := {}
						aAdd(aAlinha,IIf(lLoop .And. !Empty(aNodes[nNode][5]), &(aNodes[nNode][1]), aNodes[nNode][1]))
						For nX := 1 To Len(aNodes[nNode,8,2])
							aAdd(aAlinha,&(aNodes[nNode,8,2,nX,1]))
							If aScan(self:aCols,{|x|x == aNodes[nNode,8,2,nX,2]}) == 0
								aAdd(self:aCols,aNodes[nNode,8,2,nX,2])
							EndIf
						Next nX
						aAdd(aAlinha,cCargo)
						aAdd(self:aSeek,aClone(aAlinha))
					EndIf
//					If self:lAssembled
//						self:oTree:TreeSeek(cCargo)
//						self:oTree:PTCollapse()
//					EndIf
				EndIf
				
				self:AddMultiBrowse(aNodes[nNode][4], cCargo, lLoop)			
			
			Else
				
				cTbl := aNodes[nNode][5][1]
				
				dbSelectArea(cTbl)
				(cTbl)->( dbSetOrder(aNodes[nNode][5][2]) )
				
				If !Empty(aNodes[nNode][5][4])
					(cTbl)->( dbSeek(&(aNodes[nNode][5][4])) ) 								
				Else
					(cTbl)->( dbGoTop() )
				EndIf
				
				If (cTbl)->( Found() ) .Or. Empty(aNodes[nNode][5][4])
							
					While !(cTbl)->( Eof() ) .And. ( Empty(aNodes[nNode][5][4]) .Or. &(aNodes[nNode][5][4]) == &(aNodes[nNode][5][5]))
						
						aArea := (cTbl)->( GetArea() )
						
						self:AssembleTree(aNodes, nLevel + 1, .T., (cTbl+"|"+AllTrim(Str((cTbl)->(IndexOrd())))+"|"+(cTbl)->(&(IndexKey()))))
						
						RestArea(aArea)
						
						(cTbl)->( dbSkip() )
						
					EndDo
				
				EndIf
				
			EndIf
		EndIf
	Next nNode
	
Return

//--------------------------------------------------------------

/*/{Protheus.doc} AddMultiBrowse
	
@author Octávio Augusto Felippe de Macedo / Alan Victor Lamb
@since 06/08/2013
@version 1.0

@param aStruct, Array
@param cTCargo, Caractere
@param lLoop, Lógico

@description
Método responsável pela criação do componente de exibição de um determinado nó.

/*/

Method AddMultiBrowse(aStruct, cTCargo, lLoop) Class GFETree
	
	Local oLayer
	Local oComp
	Local nHSize
	Local nVSize
	Local nLine
	Local nCol
	Local cLine
	Local cCol
	Local aFields
	Local cCargo := IIf(lLoop, SubStr(cTCargo, 1, At(";", cTCargo) - 1), cTCargo)
	Local nCount, nCount2
	Local aComps, aCoors
	Local aListFields
	Local nX
	Local nCnt
	
	If !Empty(aStruct)
		
		If lLoop .And. AScan(self:aLayer, {|x| x[1] == cCargo}) > 0
			Return
		EndIf
		
		nVSize := 100/Len(aStruct)
		
		oLayer := FWLayer():New()
		
		oLayer:Init(self:oMain, .F.)
		
		For nLine := 1 To Len(aStruct)
			
			nHSize := 100/Len(aStruct[nLine])
			
			cLine := 'Line' + StrZero(nLine, 2)
			
			oLayer:AddLine(cLine, nVSize, .F.)
			
			For nCol := 1 To Len(aStruct[nLine])
				
				cCol := 'Col' + StrZero(nCol, 2)
				
				oLayer:AddCollumn(cCol, nHSize, .F., cLine)
				
				If aStruct[nLine][nCol][3] == 1
				
					//Cria o browse
					oComp := FWMBrowse():New()
					oComp:DisableDetails()
					oComp:SetOwner(oLayer:getColPanel(cCol, cLine))
					oComp:SetDescription(aStruct[nLine][nCol][2])
					oComp:SetProfileID(cCargo)
					oComp:SetFixedBrowse(.T.)
					
					If !Empty(aStruct[nLine][nCol][4])
						
						//oComp:SetFilterDefault(aStruct[nLine][nCol][4] + If(aStruct[nLine][nCol][1] == self:cTblFilter .And. !Empty(self:cFilter)," .And. " + self:cFilter,"") )
						
					EndIf
					
					If !Empty(aStruct[nLine][nCol][5])
						
						oComp:SetTemporary(.T.)
						oComp:SetFields(aStruct[nLine][nCol][5])
						
						If !Empty(aStruct[nLine][nCol][6])
							oComp:SetQueryIndex(aStruct[nLine][nCol][6])
						EndIf
						
						If !Empty(aStruct[nLine][nCol][7])
							oComp:SetSeek(,aStruct[nLine][nCol][7])
						EndIf
						
					EndIf
					
					oComp:SetAlias(aStruct[nLine][nCol][1])
					
					If Len(aStruct[nLine][nCol]) >= 8
						For nX := 1 To Len(aStruct[nLine][nCol][8])
							oComp:AddButton(aStruct[nLine][nCol][8][nX,1], &("{||" +aStruct[nLine][nCol][8][nX,2] + "}"),,aStruct[nLine][nCol][8][nX,3],,.F.)
						Next nX
					EndIf
					
				ElseIf aStruct[nLine][nCol][3] == 2
					
					//Cria o formulário msmget
					aFields := {}
					
					dbSelectArea(aStruct[nLine][nCol][1])
					For nCnt := 1 To FCount()
						AAdd(aFields, FieldName(nCnt))
					Next nCnt

					oComp := MsmGet():New(aStruct[nLine][nCol][1],, MODEL_OPERATION_VIEW,,,, aFields, {0, 0, 0, 0},,;    
										  ,,,, oLayer:GetColPanel(cCol, cLine),,,,,.T.,,,,,,)
					
					oComp:oBox:Align := CONTROL_ALIGN_ALLCLIENT
					
				ElseIf aStruct[nLine][nCol][3] == 3
					
					// cria as pastas
					
					oComp := TFolder():New(0,0,{},,oLayer:GetColPanel(cCol, cLine),,,,.T.,,(oLayer:GetColPanel(cCol, cLine):nwidth/2),(oLayer:GetColPanel(cCol, cLine):nHeight/2))
					oComp:Align := CONTROL_ALIGN_ALLCLIENT
					
					aComps := {}
					
					For nCount := 1 To Len(aStruct[nLine][nCol][4])
						oComp:AddItem(aStruct[nLine][nCol][4][nCount][1], .F.)
						
						aAdd(aComps, { FWBrowse():New(), aStruct[nLine][nCol][4][nCount][3] } )
						
						aComps[nCount][1]:SetOwner(oComp:aDialogs[nCount])
						aComps[nCount][1]:SetAlias(aStruct[nLine][nCol][4][nCount][2])
						//aComps[nCount][1]:SetFilterDefault(aStruct[nLine][nCol][4][nCount][3] + If(aStruct[nLine][nCol][4][nCount][2] == self:cTblFilter .And. !Empty(self:cFilter)," .And. " + self:cFilter,""))
						
						If !Empty(aStruct[nLine][nCol][4][nCount][4])
							
							For nCount2 := 1 To Len(aStruct[nLine][nCol][4][nCount][4])
								aComps[nCount][1]:AddColumn(aStruct[nLine][nCol][4][nCount][4][nCount2])
							Next nCount2
							
						EndIf
						
						aComps[nCount][1]:SetDataTable()
						aComps[nCount][1]:DisableFilter()
						aComps[nCount][1]:DisableConfig()
						aComps[nCount][1]:DisableLocate()
						aComps[nCount][1]:DisableReport()
						aComps[nCount][1]:DisableSeek()
						aComps[nCount][1]:DisableSaveConfig()
												
					Next nCount
					
					oComp := { oComp, aComps }
				
				ElseIf aStruct[nLine][nCol][3] == 4
					// Execução de ViewDef
					
					oPanelCss := GFEPanelCss():New(/*nRow*/, /*nCol*/, /*cText*/, oLayer:GetColPanel(cCol, cLine), /*lCentered, lPar6, nClrText, nClrBack, nWidth, nHeight, lLowered, lRaised*/)
					oPanelCss:Align := CONTROL_ALIGN_ALLCLIENT
					//oPanelCss:SetOwner(oLayer:GetColPanel(cCol, cLine))
					
					oComp := { aStruct[nLine][nCol][4], oPanelCss }
					
					//oComp := { aStruct[nLine][nCol][4], oLayer:GetColPanel(cCol, cLine) }
					
					/*aCoors := FWGetDialogSize(oLayer:GetColPanel(cCol, cLine))
					
					oComp := FWMVCWindow():New()
					oComp:SetOwner(oLayer:GetColPanel(cCol, cLine))
					oComp:SetPos(aCoors[1],aCoors[2])
					oComp:SetSize(aCoors[3],aCoors[4])
					oComp:SetUseControlBar(.F.)
					
					oComp:SetView(FWLoadView(aStruct[nLine][nCol][4]))
					oComp:oView:SetOperation(1)
				
					// Remove as consultas padrão dos campos do formulário.
					// Se não forem removidas, dá erro de execução quando são acessadas.
					 
					aListFields := oComp:oView:GetListFields()
					For nCount := 1 To Len(aListFields)
						oComp:oView:GetViewStruct(aListFields[nCount,1]):SetProperty(aListFields[nCount,2], MVC_VIEW_LOOKUP, '')
					Next nCount
					
					oComp:Activate(,,Nil,,.F.)*/
					
				EndIf
				
				AAdd(self:aCompsAct, {cCargo, oComp, aStruct[nLine][nCol], .T., lLoop})
				
			Next nCol
			
		Next nLine
		
		oLayer:Hide()
		
		AAdd(self:aLayer, {cCargo, oLayer})
		
	EndIf
	
Return

Static function GFC61SUBST(cAlFilter, cFilter)
	Local nCont
	Local cCampo
	Local cValor
	Local aStructTMP
	
	If cAlFilter == 'GVA'
		aStructTMP := aStructGVA
	ElseIf cAlFilter == 'GV9'
		aStructTMP := aStructGV9
	EndIf
	
	if cAlFilter $ 'GVA|GV9|' 
		for nCont:= 1 to Len(aStructTMP)
			cCampo := cAlFilter+'->'+aStructTMP[nCont][1]
			if cCampo $ cFilter
				cValor := &(cCampo)
				cFilter := StrTran(cFilter,cCampo,"'"+cValor+"'")
			EndIf
		next
	EndIf

Return cFilter

//--------------------------------------------------------------
/*{Protheus.doc} TreeChange
	
@author Octávio Augusto Felippe de Macedo / Alan Victor Lamb
@since 06/08/2013
@version 1.0

@description
Método responsável pela atualização do componente de exibição de um determinado nó.

*/
Method TreeChange() Class GFETree
	
	Local nPos
	Local nComps
	Local cCargo
	Local cTmp
	Local aSeek
	Local nCount
	Local cFilter
	Local nGVA_FILIAL, nGVA_CDEMIT, nGVA_NRTAB, nGV9_NRNEG
	
	If !Empty(self:oComp)
		self:oComp:Hide()
	EndIf
	
	cCargo := IIf(At(";", self:oTree:GetCargo()) > 0, SubStr(self:oTree:GetCargo(), 1, At(";", self:oTree:GetCargo()) - 1), self:oTree:GetCargo())
	
	cTmp := SubStr(self:oTree:GetCargo(), At(";", self:oTree:GetCargo()) + 1) 
	
	//
	// Dá um seek em alguma tabela de nível "superior" (se necessário)
	// Utilizado para que apareça o registro correto do nó.
	//
	If At(";", cTmp) > 0
		aSeek	:= StrToKArr(Substr(cTmp, At(";",cTmp)+1), "|")
		cTmp	:= Substr(cTmp, 1, At(";",cTmp)-1)
		
		If !Empty(aSeek) .AND. Len(aSeek) == 3	
			nGVA_FILIAL	:= TamSX3("GVA_FILIAL")[1]
			nGVA_CDEMIT	:= TamSX3("GVA_CDEMIT")[1]
			nGVA_NRTAB	:= TamSX3("GVA_NRTAB")[1]
			If aSeek[1] == 'GVA'
				dbSelectArea('GVA')
				GVA->(dbSetOrder(1))
				GVA->(dbClearFilter())
				cFilter := 	"GVA_FILIAL == '" + SubStr(aSeek[3],1,nGVA_FILIAL) + ;
							"' .AND. GVA_CDEMIT == '"  + AllTrim(SubStr(aSeek[3],nGVA_FILIAL,nGVA_CDEMIT)) + ;
							"' .AND. GVA_NRTAB  == '"  + AllTrim(SubStr(aSeek[3],(nGVA_FILIAL+nGVA_CDEMIT),nGVA_NRTAB)) + "'"
				GVA->(dbSetFilter(&("{||" + cFilter + "}"),cFilter))
				GVA->( dbGoTop())
		
			ElseIf aSeek[1] == 'GV9'
				nGV9_NRNEG	:= TamSX3("GV9_NRNEG")[1]
				dbSelectArea('GV9')
				GV9->(dbSetOrder(1))
				GV9->( dbClearFilter() )
				cFilter := 	"GV9_FILIAL == '" + SubStr(aSeek[3],1,nGVA_FILIAL) + ;
							"' .AND. GV9_CDEMIT == '"  + AllTrim(SubStr(aSeek[3],nGVA_FILIAL,nGVA_CDEMIT)) + ;
							"' .AND. GV9_NRTAB  == '"  + AllTrim(SubStr(aSeek[3],(nGVA_FILIAL+nGVA_CDEMIT),nGVA_NRTAB)) + ;
							"' .AND. GV9_NRNEG  == '"  + AllTrim(SubStr(aSeek[3],(nGVA_FILIAL+nGVA_CDEMIT+nGVA_NRTAB),nGV9_NRNEG)) + "'"  
				GV9->(dbSetFilter(&("{||" + cFilter + "}"),cFilter))
				GV9->( dbGoTop())
			
			ElseIf aSeek[1] == 'GV6'
				nGV9_NRNEG	:= TamSX3("GV9_NRNEG")[1]
				dbSelectArea('GV6')
				GV6->(dbSetOrder(1))
				GV6->( dbClearFilter() )
				cFilter := 	"GV6_FILIAL == '" + SubStr(aSeek[3],1,nGVA_FILIAL) + ;
							"' .AND. GV6_CDEMIT == '"  + AllTrim(SubStr(aSeek[3],nGVA_FILIAL,nGVA_CDEMIT)) + ;
							"' .AND. GV6_NRTAB  == '"  + AllTrim(SubStr(aSeek[3],(nGVA_FILIAL+nGVA_CDEMIT),nGVA_NRTAB)) + ;
							"' .AND. GV6_NRNEG  == '"  + AllTrim(SubStr(aSeek[3],(nGVA_FILIAL+nGVA_CDEMIT+nGVA_NRTAB),nGV9_NRNEG)) + "'"  
				GV6->(dbSetFilter(&("{||" + cFilter + "}"),cFilter))
				GV6->( dbGoTop())
			EndIf

			dbSelectArea(aSeek[1])
			(aSeek[1])->(dbSetOrder(Val(aSeek[2])))
			If !Empty( (aSeek[1])->( dbFilter() ) )
				(aSeek[1])->( dbClearFilter() )
			EndIf
			(aSeek[1])->(dbSeek(aSeek[3]))
		EndIf
		
	EndIf
	
	For nComps := 1 To Len(self:aCompsAct)
		
		If AllTrim(self:aCompsAct[nComps][1]) == AllTrim(cCargo)
			
			If self:aCompsAct[nComps][3][3] == 1 .And. self:aCompsAct[nComps][4]  // FWMBROWSE
			
				// Quando FWMBrowse ainda não estiver ativado
				cFilter := self:aCompsAct[nComps][3][4] + If(self:aCompsAct[nComps][2]:Alias() == self:cTblFilter .And. !Empty(self:cFilter)," .And. " + self:cFilter,"")
				If !Empty(cFilter)
					cFilter := GFC61SUBST((aSeek[1]), cFilter)
					(self:aCompsAct[nComps][2]:Alias())->( dbSetFilter(&("{||" + cFilter + "}"),cFilter))
				Else
					(self:aCompsAct[nComps][2]:Alias())->(dbClearFilter())
				EndIf
				(self:aCompsAct[nComps][2]:Alias())->( dbGoTop())
				self:aCompsAct[nComps][4] := .F.
				self:aCompsAct[nComps][2]:Activate()
				
			ElseIf self:aCompsAct[nComps][3][3] == 1 .And. !self:aCompsAct[nComps][4] // FWMBROWSE
				
				// Quando FWMBrowse já estiver ativado
				cFilter := self:aCompsAct[nComps][3][4] + If(self:aCompsAct[nComps][2]:Alias() == self:cTblFilter .And. !Empty(self:cFilter)," .And. " + self:cFilter,"")
				If !Empty(cFilter)
					cFilter := GFC61SUBST((aSeek[1]), cFilter)
					(self:aCompsAct[nComps][2]:Alias())->( dbSetFilter(&("{||" + cFilter + "}"),cFilter))
				Else
					(self:aCompsAct[nComps][2]:Alias())->(dbClearFilter())
				EndIf 
				(self:aCompsAct[nComps][2]:Alias())->( dbGoTop())
				self:aCompsAct[nComps][2]:Refresh()
			ElseIf self:aCompsAct[nComps][3][3] == 2 // MSMGET
				
				
				dbSelectArea(self:aCompsAct[nComps][3][1])
				(self:aCompsAct[nComps][3][1])->( dbSetOrder(1) )
				
				If !Empty( (self:aCompsAct[nComps][3][1])->( dbFilter() ) )
					(self:aCompsAct[nComps][3][1])->( dbClearFilter() )
				EndIf
				
				If (self:aCompsAct[nComps][3][1])->( dbSeek(IIf(self:aCompsAct[nComps][5], cTmp, self:aCompsAct[nComps][1])) )
				
			  		self:aCompsAct[nComps][2]:Refresh()
			 	
			 	EndIf
			
			ElseIf self:aCompsAct[nComps][3][3] == 3  // FOLDER
				
				For nCount := 1 To Len(self:aCompsAct[nComps][2][1]:aDialogs)
					
					cfilter := self:aCompsAct[nComps][2][2][nCount][2] + If(self:aCompsAct[nComps][2][2][nCount][1]:Alias() == self:cTblFilter .And. !Empty(self:cFilter)," .And. " + self:cFilter,"")
					If !Empty(cFilter)
						(self:aCompsAct[nComps][2][2][nCount][1]:Alias())->(dbSetFilter(&("{||" + cFilter + "}"),cFilter))
					Else
						(self:aCompsAct[nComps][2][2][nCount][1]:Alias())->(dbClearFilter())
					EndIf 
					If !self:aCompsAct[nComps][2][2][nCount][1]:lActivate
						self:aCompsAct[nComps][2][2][nCount][1]:Activate()
					Else
						self:aCompsAct[nComps][2][2][nCount][1]:DeActivate(.T.)
						self:aCompsAct[nComps][2][2][nCount][1]:Activate()
					EndIf
					
				Next nCount
				
				If Len(self:aCompsAct[nComps][2][1]:aDialogs) > 0
					self:aCompsAct[nComps][2][1]:SetOption(1)
				EndIf
			
			ElseIf self:aCompsAct[nComps][3][3] == 4  // VIEW
				//self:aCompsAct[nComps][2]:oView:Refresh()
				
				IF self:aCompsAct[nComps][2][1] == 'GFEA061A'
				ElseIf self:aCompsAct[nComps][2][1] == 'GFEA061F'
				EndIf
				self:LoadView(self:aCompsAct[nComps][2][1], self:aCompsAct[nComps][2][2])
				
				/*self:aCompsAct[nComps][2]:oView:oModel:DeActivate()
				self:aCompsAct[nComps][2]:oView:oModel:Activate()
				self:aCompsAct[nComps][2]:oView:DeActivate()
				self:aCompsAct[nComps][2]:oView:Activate()
				//self:aCompsAct[nComps][2]:oView:Refresh()*/
				
				/*self:aCompsAct[nComps][2]:DeActivate()
				self:aCompsAct[nComps][2]:Activate()*/
								
			EndIf
			
		EndIf
		
	Next nComps
	
	If (nPos := AScan(self:aLayer, {|x| AllTrim(x[1]) == AllTrim(cCargo)})) > 0
		
		self:aLayer[nPos][2]:Show()
		
		self:oComp := self:aLayer[nPos][2]
		
	EndIf
	
Return

//--------------------------------------------------------------

Method Activate(lActAfter, aMsg) Class GFETree
	
	Default lActAfter	:= .F.
	Default aMsg     	:= {"Carregando", "Aguarde..."}
	If !Empty(self:cTblFilter)
		self:ShowFiltro(.T.)
	EndIf
	self:oDlg:Activate(,,, .T., {|| .T.},, {|| IIf(!lActAfter, Processa({|| ProcRegua(0), self:AssembleTree(self:aNodes),self:lAssembled := .T.}, aMsg[1], aMsg[2]), )})
	
	If lActAfter
		
		self:AssembleTree(self:aNodes)
		self:lAssembled := .T.
	EndIf
	
	
Return

//--------------------------------------------------------------

/*{Protheus.doc} LoadView
	
@author Alan Victor Lamb
@since 14/08/2013
@version 1.0

@param cView, CHARACTER
@param oOwner, OBJECT

@description
Executa uma determinada ViewDef dentro de um objeto em modo de visualização.

@example
self:LoadView("GFEA061", oOwner)

*/

Method LoadView(cView, oOwner) Class GFETree
	Local aCoors, aListFields, nCount
	
	// 
	// Esse controle faz com que não haja erro de Stack Depth Overflow 
	// ao sair da tela (dependendo do uso)
	//
	Local xTmp := self:oDlg:aControls[1]:bEnd
	
	CursorWait()
	
	aCoors := FWGetDialogSize(oOwner)
	
	self:oDlg:aControls[1]:bEnd := Nil
	
	//
	// Se já tiver uma View carregada, limpa o objeto
	//
	If !Empty(self:oFWMVCWindow)
		self:oFWMVCWindow:DeActivate()
		self:oView:DeActivate()
		self:oView:Destroy()
		self:oView:oModel:Destroy()
		self:oView:oModel := Nil
		oOwner:FreeChildren()
		FreeObj(self:oView)
		FreeObj(self:oFWMVCWindow)
		
		If !Empty(self:oDlg:aControls[1]:bEnd)
		
			Eval(self:oDlg:aControls[1]:bEnd)
			 
		EndIf
		
	EndIf
	
	//
	// Objeto que serve como container para um FWFormView
	//
	self:oFWMVCWindow := FWMVCWindow():New()
	self:oFWMVCWindow:SetOwner(oOwner)
	self:oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
	self:oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
	self:oFWMVCWindow:SetUseControlBar(.F.)
	
	self:oView := FWLoadView(cView)
	self:oView:SetOperation(1)
	self:oView:EnableControlBar(.F.)
	self:oView:oModel:SetOperation(1)
	
	 //troca o layout para deixar os campos com informações de faixa e rota maiores
	If cView == "GFEA061F"
		self:oView:GetViewObj("GFEA061F_GV6")[3]:SetLayout(,3,150)
	EndIf
	//
	// Remove as consultas padrão dos campos do formulário.
	// Se não forem removidas, dá erro de execução quando são acessadas.
	// 
	aListFields := self:oView:GetListFields()
	For nCount := 1 To Len(aListFields)
		self:oView:GetViewStruct(aListFields[nCount,1]):SetProperty(aListFields[nCount,2], MVC_VIEW_LOOKUP, '')
	Next nCount
	
	self:oFWMVCWindow:SetView(self:oView)
	self:oFWMVCWindow:Activate(,,Nil,.F.)
	
	//
	// Dá um refresh na view pois quando tem grids nas folders não 
	// posiciona direito nos registros
	//	
	self:oView:Refresh()
	
	//
	// Restaura a pilha padrão
	//
	self:oDlg:aControls[1]:bEnd := xTmp
	
	CursorArrow()
Return

//--------------------------------------------------------------

Function GFEC061()
	
	Local aNodes
	Local oTblFret	:= GFETree():New()
	Local oFilter
	Local nX
	Local aRotina1 := FWMVCMenu('GFEA061')
	Private cGVA2
	Private aStructGVA := GVA->(DbStruct())
	Private aStructGV9 := GV9->(DbStruct())
	Private aRotina := {}

	aAdd(aRotina,aRotina1[1]) 
	
	cGVA2 := CriaTab()
	FillTab()

	/*
		aNodes = 
		[1] = Título do nó. Caso a posição 5 seja preenchida, pode ser uma expressão AdvPL
			  Tipo: Caracteres
			  Ex: 'Cadastros'
			  
		[2] = Imagem do Tree (Fechado)
			  Tipo: Caracteres 
			  Ex:   'SDUCLOSE'
			  
		[3] = Imagem do Tree (Aberto)
			   Tipo: Caracteres 
			   Ex:   'SDUCLOSE'
			   
		[4] = Estrutura que monta os objetos que serão exibidos como detalhamento daquele nó.
			   Tipo: Array
			   
		 	[4, nLine, nCol, 1] = cTabela
		 	[4, nLine, nCol, 2] = cTitulo
		 	[4, nLine, nCol, 3] = nTipoComponente. 
		 							 1=FWMBrowse,
		 							 2=MsmGet,
		 							 3=Folder com FWBrowses (grids),
		 							 4=View
		 							 
		 	[4, nLine, nCol, 4] = complemento dos componentes.
		 							 Se nTipoComponente = 1:
		 							 cFilterDefault do FWMBrowse
		 							 
		 							 Se nTipoComponente = 2:
		 							 não é necessário informar
		 							 
		 		 					 Se nTipoComponente = 3:
		 							 Array com Folders (não é necessário informar cTabela e cTitulo)
		 	     					 [4, nLine, nCol, 4, 1] = cTituloAba
		 	     					 [4, nLine, nCol, 4, 2] = cTabela
									 [4, nLine, nCol, 4, 3] = cFilterDefault
									 [4, nLine, nCol, 4, 4] = aCols (deve seguir modelo do FWBrowse)
									 
									 Se nTipoComponente = 4:
									 cView (não é necessário informar cTabela e cTitulo)
									 
			[4, nLine, nCol, 5] = array com colunas para tabela temporária 
			[4, nLine, nCol, 6] = array com índices de tabela temporária
			[4, nLine, nCol, 7] = aSeek de tabela temporária.				 
			 					 
		[5] = Quando se deseja que os nós sejam criados recursivamente 
			  (ex: registros de uma tabela), utiliza-se a seguinte estrutura nesse índice:
		 	  {cTabela, nOrdem, cCampos Ex:"GVA->GVA_FILIAL + GVA->GVA_CDEMIT + GVA->GVA_NRTAB",}
		 	  
		[6] = Estrutura igual ao aNodes, que será o filho do nó atual.
		
		[7] = Opcional. Condição para que o nó seja exibido. 
			  Tipo: Array de Caracteres
			  Ex:	 {'Condição ADVPL'}
		[8] = Opcional. Condição para que o nó seja adicionado para pesquisa. 
			  Tipo: {Lógico, default .F.,Array com string para outras colunas}
	*/

	aNodes := {;
				{'Cadastros', 'SDUCLOSE', 'SDUOPEN', {}, {}, ;
					{;
						{'Componentes de Frete'   , 'SELECTALL', , {{{'GV2', 'Componentes de Frete'   , 1, "", }}}, {}, {}},;
						{'Classificações de Frete', 'AVGBOX1'  , , {{{'GUB', 'Classificações de Frete', 1, "", }}}, {}, {}},;
						{'Tipos de Operação'      , 'AVG_IOPT' , , {{{'GV4', 'Tipos de Operação'      , 1, "", }}}, {}, {}},;
						{'Tipos de Veículo'       , 'CARGASEQ' , , {{{'GV3', 'Tipos de Veículo'       , 1, "", }}}, {}, {}},;
						{'Regiões'                , 'ADD_RADAR', , {{{'GU9', 'Regiões'                , 1, "", , , , {{"Visualizar","FwExecView(,'GFEA021C')",2}} }}}, {}, {}};
					};
				},;
				{'Tabelas', 'SDUCLOSE', 'SDUOPEN', {{{'GVA', "Tabelas de Frete", 1, "",,,,{{"Visualizar Anexo","MsDocument('GVA',GVA->(RecNo()), 1)",2}} }}}, {}, ;
					{;
						{'AllTrim(Posicione("GU3", 1, xFilial("GU3") + GVA->GVA_CDEMIT, "GU3_NMEMIT")) + " - " + AllTrim(GVA->GVA_NRTAB)', 'RPMTABLE', , {{{'GVA', 'Tabelas de Frete', 4, "GFEA061"}}}, {'GVA', 1, "GVA->GVA_FILIAL + GVA->GVA_CDEMIT + GVA->GVA_NRTAB", }, ;
							{;
								{'Negociações', 'PEDIDO', , {{{'GV9', 'Negociações', 1, "GV9->GV9_FILIAL == GVA->GVA_FILIAL .AND. GV9->GV9_CDEMIT == GVA->GVA_CDEMIT .AND. GV9->GV9_NRTAB == GVA->GVA_NRTAB",,,,{{"Visualizar Anexo","MsDocument('GV9',GV9->(RecNo()), 1)",2}} }}}, {}, ;
									{;
										{"GV9->GV9_NRNEG + ' - ' + DTOC(GV9->GV9_DTVALI)", 'AVGLBPAR1', , ;
											{ { { '', '', 4, 'GFEA061A' } } },; 
											{'GV9', 1, "GV9->GV9_FILIAL + GV9->GV9_CDEMIT + GV9->GV9_NRTAB + GV9->GV9_NRNEG", "GVA->GVA_FILIAL + GVA->GVA_CDEMIT + GVA->GVA_NRTAB", "GV9->GV9_FILIAL + GV9->GV9_CDEMIT + GV9->GV9_NRTAB"}, ;
											{;
												{"Tarifas", "PRECO", , {{{"GV6", "Tarifas", 1, "GV6->GV6_FILIAL  == GV9->GV9_FILIAL .AND. GV6->GV6_CDEMIT == GV9->GV9_CDEMIT .AND. GV6->GV6_NRTAB == GV9->GV9_NRTAB .AND. GV6->GV6_NRNEG == GV9->GV9_NRNEG", }}}, {}, ;
													{;
												 		{"GV6->GV6_CDFXTV + ' - ' + GV6->GV6_NRROTA", "BUDGET", , ;
												 			{{{'', '', 4, 'GFEA061F'}}},;
												 			{"GV6", 1, "GV6->GV6_FILIAL + GV6->GV6_CDEMIT + GV6->GV6_NRTAB + GV6->GV6_NRNEG + GV6->GV6_CDFXTV + GV6->GV6_NRROTA", "GV9->GV9_FILIAL + GV9->GV9_CDEMIT + GV9->GV9_NRTAB + GV9->GV9_NRNEG", "GV6->GV6_FILIAL + GV6->GV6_CDEMIT + GV6->GV6_NRTAB + GV6->GV6_NRNEG "},{}};
													};
												};
											};
										};
									}, {"GVA->GVA_TPTAB == '1'"};
								},;
								{'Componentes da Tabela de Vínculo', 'SELECT', , {{{"GVB", "Componentes da tabela de Vínculo", 1, "GVB->GVB_FILIAL == GVA->GVA_FILIAL .AND. GVB->GVB_CDEMIT == GVA->GVA_CDEMIT .AND. GVB->GVB_NRTAB == GVA->GVA_NRTAB", }}}, {}, {}, {"GVA->GVA_TPTAB == '2'"} },;
								{'Tabelas Vinculadas', 'SDUFIELDS', , {{{cGVA2, "Tabelas Vinculadas", 1, cGVA2+"->GVA_FILIAL == GVA->GVA_FILIAL .AND. "+cGVA2+"->GVA_EMIVIN == GVA->GVA_CDEMIT .AND. "+cGVA2+"->GVA_TABVIN == GVA->GVA_NRTAB", GetCols(), GetInds(), GetSeek() }}}, {}, {}, {"GVA->GVA_TPTAB == '1'"} };
							};
						,,{.T.,{{"GVA->GVA_NRTAB","Nr. Tabela"}}}};
					};
				};
			  }

	oTblFret:SetNodes(aNodes)
	oTblFret:cTblFilter := "GV9"
	oFilter := oTblFret:GetFilter()
	
	If aScan(oFilter:aFilter,{|x|x[1] == "Negociações - Somente em negociação"}) == 0
		AAdd(oFilter:aCheckFil, .F.)
		AAdd(oFilter:aFilter, {"Negociações - Somente em negociação", "GV9->GV9_SIT == '1'", "GV9->GV9_SIT == '1'", {}, .F., .F., .F.,,})
	EndIf
	
	If aScan(oFilter:aFilter,{|x|x[1] == "Negociações - Somente liberadas"}) == 0
		AAdd(oFilter:aCheckFil, .F.)
		AAdd(oFilter:aFilter, {"Negociações - Somente liberadas", "GV9->GV9_SIT == '2'", "GV9->GV9_SIT == '2'", {}, .F., .F., .F.,,})
	EndIf
	
	If (nX := aScan(oFilter:aFilter,{|x|x[1] == "Negociações - Somente vigentes"})) == 0
		AAdd(oFilter:aCheckFil, .F.)
		AAdd(oFilter:aFilter, {"Negociações - Somente vigentes", "GV9->GV9_DTVALI <= CTOD('"+DTOC(DATE())+"') .And. ( (GV9->GV9_DTVALF == CTOD('  /  /    ') .OR. DTOS(GV9->GV9_DTVALF) == '        ') .OR. GV9->GV9_DTVALF >= CTOD('"+DTOC(DATE())+"') )", "GV9->GV9_DTVALI <= CTOD('"+DTOC(DATE())+"') .And. ( (GV9->GV9_DTVALF == CTOD('  /  /    ') .OR. DTOS(GV9->GV9_DTVALF) == '        ') .OR. GV9->GV9_DTVALF >= CTOD('"+DTOC(DATE())+"') )", {}, .F., .F., .F.,,})
	Else
		oFilter:aFilter[nX,2] := "GV9->GV9_DTVALI <= CTOD('"+DTOC(DATE())+"') .And. ( (GV9->GV9_DTVALF == CTOD('  /  /    ') .OR. DTOS(GV9->GV9_DTVALF) == '        ') .OR. GV9->GV9_DTVALF >= CTOD('"+DTOC(DATE())+"') )"
		oFilter:aFilter[nX,3] := "GV9->GV9_DTVALI <= CTOD('"+DTOC(DATE())+"') .And. ( (GV9->GV9_DTVALF == CTOD('  /  /    ') .OR. DTOS(GV9->GV9_DTVALF) == '        ') .OR. GV9->GV9_DTVALF >= CTOD('"+DTOC(DATE())+"') )"
	EndIf
	
	oTblFret:Activate(.F., {"Carregando Tabelas de Frete", "Aguarde..."})
	
	GFEDelTab( cGVA2 )
Return Nil

//
// Função auxiliar para retornar colunas exibidas no browse de Tabelas Vinculadas
//
Static Function GetCols()
	Local aCols := {}
	aAdd(aCols, {"Emitente", "GVA_CDEMIT", "C", 10, 0,""})
	aAdd(aCols, {"Nome", "GVA_NMEMIT", "C", 20, 0,""})
	aAdd(aCols, {"Tabela", "GVA_NRTAB", "C", TamSX3("GVA_NRTAB")[1], 0,""})
	aAdd(aCols, {"Descrição", "GVA_DSTAB", "C", 20, 0,""})
	aAdd(aCols, {"Tipo", "GVA_TPTAB", "C", 10, 0,""})
	aAdd(aCols, {"Data Criação", "GVA_DTCRIA", "D", 8, 0,""})
	aAdd(aCols, {"Hora Criação", "GVA_HRCRIA", "C", 6, 0,""})
	aAdd(aCols, {"Data Atual.", "GVA_DTATU", "D", 8, 0,""})
	aAdd(aCols, {"Hora Atual.", "GVA_HRATU", "C", 6, 0,""})
Return aCols

//
// Função auxiliar para retornar índice da tabela temporária de tabelas vinculadas
//
Static Function GetInds()
	Local aIndex	:= {}
	aAdd(aIndex, "GVA_FILIAL+GVA_CDEMIT+GVA_NRTAB	")
Return aIndex

//
// Função auxiliar para retornar aSeek da tabela temporária de tabelas vinculadas
//
Static Function GetSeek()
	Local aSeek	:= {}
	aAdd(aSeek, {"Emitente + Nr Tabela", { {"", "C", TamSX3("GVA_CDEMIT")[1], 0, "Emitente", ""}, {"", "C", TamSX3("GVA_NRTAB")[1], 0, "Nr Tabela", ""} }, 1 })
Return aSeek

Static Function FillTab()
	GVA->( dbSetOrder(1) )
	GVA->( dbGoTop() )
	While !GVA->( Eof() )
		RecLock(cGVA2,.T.)
		(cGVA2)->GVA_FILIAL	:= GVA->GVA_FILIAL
		(cGVA2)->GVA_CDEMIT	:= GVA->GVA_CDEMIT
		(cGVA2)->GVA_NMEMIT	:= Posicione("GU3",1,xFilial("GU3")+GVA->GVA_CDEMIT,"GU3_NMEMIT")
		(cGVA2)->GVA_NRTAB	:= GVA->GVA_NRTAB
		(cGVA2)->GVA_DSTAB	:= GVA->GVA_DSTAB
		(cGVA2)->GVA_TPTAB	:= GFEFldInfo("GVA_TPTAB", GVA->GVA_TPTAB, 2)
		(cGVA2)->GVA_DTCRIA	:= GVA->GVA_DTCRIA
		(cGVA2)->GVA_HRCRIA	:= GVA->GVA_HRCRIA
		(cGVA2)->GVA_DTATU	:= GVA->GVA_DTATU
		(cGVA2)->GVA_HRATU	:= GVA->GVA_HRATU
		(cGVA2)->GVA_EMIVIN	:= GVA->GVA_EMIVIN
		(cGVA2)->GVA_TABVIN	:= GVA->GVA_TABVIN
		MsUnlock()
		
		GVA->(dbSkip())
	EndDo
Return Nil

Static Function CriaTab()
	Local aCampos
	Local cAlias
	
	aCampos := {{"GVA_FILIAL","C",TamSX3("GVA_FILIAL")[1],0},;
				 {"GVA_CDEMIT","C",TamSX3("GVA_CDEMIT")[1],0},;
				 {"GVA_NMEMIT","C",TamSX3("GU3_NMEMIT")[1],0},;
				 {"GVA_NRTAB","C",TamSX3("GVA_NRTAB")[1],0},;
				 {"GVA_DSTAB","C",TamSX3("GVA_DSTAB")[1],0},;
				 {"GVA_TPTAB","C",10,0},;
				 {"GVA_DTCRIA","D",8,0},;
				 {"GVA_HRCRIA","C",TamSX3("GVA_HRCRIA")[1],0},;
				 {"GVA_DTATU","D",8,0},;
				 {"GVA_HRATU","C",TamSX3("GVA_HRATU")[1],0},;
				 {"GVA_EMIVIN","C",TamSX3("GVA_EMIVIN")[1],0},;
				 {"GVA_TABVIN","C",TamSX3("GVA_TABVIN")[1],0}}
		
	cAlias := GFECriaTab({aCampos,{"GVA_FILIAL+GVA_CDEMIT+GVA_NRTAB"}})   
Return cAlias
