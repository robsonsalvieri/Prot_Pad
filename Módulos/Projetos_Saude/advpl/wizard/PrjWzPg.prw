#include 'protheus.ch'

#DEFINE CMPCAMPO	1
#DEFINE CMPTIPO		2
#DEFINE CMPSIZE		3
#DEFINE CMPDECIMAL	4
#DEFINE CMPTITULO	5
#DEFINE CMPEXIBE	6
#DEFINE CMPOBRIG	7
#DEFINE CMPWHEN 	8

Class PrjWzPg
	Data oTabTemp
	Data aGridFields
	Data aTabFields
	Data oStepWiz
	Data aCampos
	Data aDados
	Data nTotReg
	Data cDescri
	Data cTitle
	Data cClassName

	Method new() Constructor
	Method destroy()
	Method getTabFlds()
	Method getGridFlds()
	Method makeScreen(oPanel)
	Method addLegend()
	Method marcaTodos()	
	Method getTabTemp()
	Method fillTabTemp()
	Method vldNextAction()
	Method vldCancelAction()
	Method cancelWhen()

EndClass

Method new(aDados) Class PrjWzPg
	self:aCampos	:= {}
	self:aDados		:= aDados
	self:nTotReg 	:= 0
	self:cClassName	:= GetClassName(self)
Return self

Method destroy() Class PrjWzPg
	If !Empty(self:oTabTemp)
		self:oTabTemp:delete()
	EndIf
Return

Method getTabFlds() Class PrjWzPg
Return self:aCampos

Method getGridFlds() Class PrjWzPg
	Local aColunas		:= {}
	Local cCampo		:= ""
	Local cTitulo		:= ""
	Local cPicture		:= ""
	Local nCampos		:= 1
	Local nLenCmps		:= Len(self:getTabFlds())
	Local nAlign		:= 0 
	Local nSize			:= 0
	Local nDecimal		:= 0

	For nCampos := 1 To nLenCmps
		if self:getTabFlds()[nCampos,CMPEXIBE]
			cCampo		:= self:getTabFlds()[nCampos,CMPCAMPO]
			cTipo 		:= self:getTabFlds()[nCampos,CMPTIPO]
			nSize		:= self:getTabFlds()[nCampos,CMPSIZE]
			nDecimal	:= self:getTabFlds()[nCampos,CMPDECIMAL]
			cTitulo		:= self:getTabFlds()[nCampos,CMPTITULO]
			cPicture	:= "@!" 
			nAlign		:= 1

			aadd(aColunas, GetColuna(cCampo,cTitulo,cTipo,cPicture,nAlign,nSize,nDecimal))
		EndIf
	Next

Return aColunas

// Carrega coluna dos campos em tela
Static Function GetColuna(cCampo,cTitulo,cTipo,cPicture,nAlign,nSize,nDecimal)

	Local aColuna		:= {}
	Local bData			:= {||}
	Default nAlign    	:= 1
	Default nSize		:= 20
	Default nDecimal	:= 0

	bData := &("{||" + cCampo +"}") 

	aColuna := {cTitulo,bData,cTipo,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{|| .T.},NIL,{||.T.},.F.,.F.,{}}

Return aColuna

Method makeScreen(oPanel) Class PrjWzPg

	self:fillTabTemp()
	self:oMark	:= FWMarkBrowse():New()
	self:oMark:SetDescription(self:cDescri)
	self:oMark:SetAlias(self:getTabTemp():getAlias())
	self:oMark:SetFieldMark("ENVDOK")
	self:oMark:oBrowse:SetDBFFilter(.F.)
	self:oMark:oBrowse:SetUseFilter(.F.)
	self:oMark:oBrowse:SetFixedBrowse(.T.)
	self:oMark:SetWalkThru(.F.)
	self:oMark:SetAmbiente(.F.)
	self:oMark:SetTemporary()
	self:addLegend()
	self:oMark:SetMenuDef(self:cClassName)
	self:oMark:oBrowse:SetFilterDefault("")
	self:oMark:SetMark("XX", self:getTabTemp():getAlias(), "ENVDOK")
	self:oMark:SetAllMark( { || self:marcaTodos() })
	self:oMark:ForceQuitButton()
	self:oMark:SetProfileID(self:cClassName)
	self:oMark:AddButton("Marca/Desmarca Todos"	, { || self:marcaTodos() },,,, .F., 2 )
	self:oMark:SetColumns(self:getGridFlds())
	
	If !isBlind()
		self:oMark:Activate(oPanel)
	EndIf
        
Return .T.

Method marcaTodos() Class PrjWzPg
	Local cTabTemp:= self:getTabTemp():getAlias()

	DbSelectArea(cTabTemp)
	DbGotop()
	While !Eof()
		If RecLock( cTabTemp, .F. )
			(cTabTemp)->ENVDOK := IIf(Empty((cTabTemp)->ENVDOK), self:oMark:cMark, Space(2) )
			MsUnLock()
		EndIf
		dbSkip()
	Enddo

	self:oMark:oBrowse:Gotop()
	self:oMark:Refresh( )      

Return

Method getTabTemp() Class PrjWzPg
	if Empty(self:oTabTemp)
		self:oTabTemp := FWTemporaryTable():New( GetNextAlias(), self:getTabFlds() )
		self:oTabTemp:AddIndex("01", {"ID"})
		self:oTabTemp:Create()
	EndIf
Return self:oTabTemp

Method fillTabTemp() Class PrjWzPg
Return

Method addLegend() Class PrjWzPg
Return

Method vldNextAction() Class PrjWzPg
Return .T.

Method vldCancelAction() Class PrjWzPg
Return .T.

Method cancelWhen() Class PrjWzPg
Return .T.