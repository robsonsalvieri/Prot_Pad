#include 'protheus.ch'
#include 'FWMVCDEF.CH'

#DEFINE CMPCAMPO	1
#DEFINE CMPTIPO		2
#DEFINE CMPSIZE		3
#DEFINE CMPDECIMAL	4
#DEFINE CMPTITULO	5
#DEFINE CMPEXIBE	6
#DEFINE CMPOBRIG	7
#DEFINE CMPWHEN 	8

Static __cTabTmp := ""
Static __aCampos := {}

Class PrjWzPgPrm From PrjWzPg
	Data oBrowse

	Method new(aDados) Constructor
	Method getTabFlds()
	Method getTabTemp()
	Method makeScreen(oPanel)
	Method fillTabTemp()
	Method addLegend()
	Method vldNextAction()
	Method endProcess()
	Method atuParams()

EndClass

Method new(aDados) Class PrjWzPgPrm
	_Super:new(aDados)
	self:cTitle := "Parâmetros"
Return self

Method getTabTemp() Class PrjWzPgPrm
	if Empty(self:oTabTemp)
		self:oTabTemp := FWTemporaryTable():New( GetNextAlias(), self:getTabFlds() )
		self:oTabTemp:AddIndex("01", {"ORDENA"})
		self:oTabTemp:Create()
	EndIf
	__cTabTmp := self:oTabTemp:getAlias()
Return self:oTabTemp

Method getTabFlds() Class PrjWzPgPrm

	If Empty(self:aCampos)
		//{CMPCAMPO,CMPTIPO,CMPSIZE,CMPDECIMAL,CMPTITULO,CMPEXIBE,CMPOBRIG,CMPWHEN}
		aAdd(self:aCampos,{"ID"		,"C",015,0,"Id"				,.F.,.T.,.F.})
		aAdd(self:aCampos,{"NAME"	,"C",010,0,"Nome"			,.T.,.T.,.F.})
		aAdd(self:aCampos,{"CONTEUD","C",250,0,"Conteudo"		,.T.,.T.,.T.})
		aAdd(self:aCampos,{"TIPO"	,"C",001,0,"Tipo"			,.T.,.F.,.F.})
		aAdd(self:aCampos,{"DESCRI"	,"C",150,0,"Descrição"		,.T.,.T.,.F.})
		aAdd(self:aCampos,{"EXISTE"	,"C",003,0,"Existe?"		,.T.,.F.,.F.})
		aAdd(self:aCampos,{"ORDENA"	,"C",003,0,"Order By Desc"	,.F.,.F.,.F.})
		__aCampos := self:aCampos
	EndIf

Return self:aCampos

Method makeScreen(oPanel) Class PrjWzPgPrm
	self:fillTabTemp()
	self:oBrowse:= FWmBrowse():New()
	self:oBrowse:SetDescription( "Configuração de Parametros" )
	self:oBrowse:SetAlias( self:getTabTemp():getAlias() )
	self:oBrowse:SetFields(self:getGridFlds())
	self:oBrowse:SetProfileID( self:getTabTemp():getAlias() )
	self:oBrowse:SetExecuteDef(4)
	self:addLegend()
	self:oBrowse:SetMenuDef('PrjWzPgPrm')
	self:oBrowse:DisableDetails(.T.)
	If !isBlind()
		self:oBrowse:Activate(oPanel)
	EndIf

Return .T.

Method fillTabTemp() Class PrjWzPgPrm
	Local nDados	:= 0
	Local nMvParam	:= 0
	Local nLenAux	:= len(self:aDados)
	Local nLenDados	:= 0
	Local aDados 	:= {}
	Local cTabTemp 	:= self:getTabTemp():getAlias()
	SX6->(DbSetOrder(1))
	For nMvParam := 1 to nLenAux
		If SX6->(DbSeek(xFilial("SX6")+padr(self:aDados[nMvParam],10)))
			AAdd(aDados,{	SX6->X6_VAR,;
				AllTrim(SX6->X6_DESCRIC) + AllTrim(SX6->X6_DESC1) + AllTrim(SX6->X6_DESC2),;
				AllTrim(SX6->X6_CONTEUD),"SIM",AllTrim(SX6->X6_TIPO),"1"})
		Else
			AAdd(aDados,{	self:aDados[nMvParam],;
				"Parametro não cadastrado no sistema",;
				"","NAO","","2"})
		EndIf
	Next
	nLenDados := Len(aDados)
	self:nTotReg := nLenDados
	For nDados := 1 TO Len(aDados)
		RecLock(cTabTemp,.T.)
		(cTabTemp)->ID 		:= AllTrim(Str(nDados))
		(cTabTemp)->NAME 	:= aDados[nDados,1]
		(cTabTemp)->DESCRI	:= aDados[nDados,2]
		(cTabTemp)->CONTEUD	:= aDados[nDados,3]
		(cTabTemp)->EXISTE	:= aDados[nDados,4]
		(cTabTemp)->TIPO	:= aDados[nDados,5]
		(cTabTemp)->ORDENA	:= aDados[nDados,6]
		msUnLock()
	Next nDados
Return

Method addLegend() Class PrjWzPgPrm
	self:oBrowse:AddLegend("PrjLegPrm() == 'RED'"	, "RED"		, "Parametro não cadastrado no sistema")
	self:oBrowse:AddLegend("PrjLegPrm() == 'YELLOW'", "YELLOW"	, "Parametro não preenchido")
	self:oBrowse:AddLegend("PrjLegPrm() == 'GREEN'"	, "GREEN"	, "Parametro preenchido")
Return

Function PrjLegPrm()
	Local cColor	:= ""
	Local cTabTemp 	:= __cTabTmp
	If (cTabTemp)->EXISTE == "SIM"
		If Empty((cTabTemp)->CONTEUD)
			cColor := "YELLOW"
		Else
			cColor := "GREEN"
		EndIf
	Else
		cColor := "RED"
	EndIf
Return cColor

Method vldNextAction() Class PrjWzPgPrm
Return .T.

Method endProcess() Class PrjWzPgPrm
	Processa({|| self:atuParams()}, "Atualizando Parâmetros")
Return

Method atuParams() Class PrjWzPgPrm
	Local cTabTemp:= self:getTabTemp():getAlias()

	ProcRegua(self:nTotReg)
	(cTabTemp)->(DbGoTop())
	While (cTabTemp)->(!Eof())
		If (__cTabTmp)->EXISTE == "SIM"
			IncProc("Atualizando parametro " + (cTabTemp)->NAME)
			PutMv((cTabTemp)->NAME,(cTabTemp)->CONTEUD)
		EndIf
		(cTabTemp)->(dbSkip())
	Enddo
Return .T.

Static Function MenuDef()
	Local aRotina 	:= {}

	aAdd( aRotina, { "Alterar Parametro"	,'PrjVlEdtPr()' , 0 , MODEL_OPERATION_UPDATE	} )

Return aRotina

Static Function ModelDef()
	Local oModel 	:= MPFormModel():New( "PrjWzPgPrm" )
	Local oStruTmp 	:= FWFormModelStruct():New()
	Local nField := 0
	Local nLenCmps := Len(__aCampos)
	Local aCampos := {}

	Local cTitulo	:= ""
	Local cTooltip	:= ""
	Local cIdField	:= ""
	Local cTipo		:= "C"
	Local nTamanho	:= 10
	Local nDecimal	:= 0
	Local bValid	:= {||.T.}
	Local bWhen		:= {||.T.}
	Local aValues	:= {}
	Local lObrigat	:= .T.
	Local bInit		:= {||}
	Local lKey		:= .F.
	Local lNoUpd	:= .F.
	Local lVirtual	:= .F.
	Local cValid	:= ""

	For nField := 1 to nLenCmps
		aAdd(aCampos, __aCampos[nField][CMPCAMPO])
		cTitulo	 := __aCampos[nField][CMPTITULO]
		cTooltip := __aCampos[nField][CMPTITULO]
		cIdField := __aCampos[nField][CMPCAMPO]
		cTipo	 := __aCampos[nField][CMPTIPO]
		nTamanho := __aCampos[nField][CMPSIZE]
		nDecimal := __aCampos[nField][CMPDECIMAL]
		lObrigat := __aCampos[nField][CMPOBRIG]
		oStruTmp:AddField(cTitulo, cTooltip, cIdField, cTipo, nTamanho, nDecimal, bValid, bWhen, aValues, lObrigat, bInit, lKey, lNoUpd, lVirtual, cValid)
	Next nField

	oStruTmp:AddTable(__cTabTmp, aCampos, "Parametros do Módulo")

	oModel:AddFields( 'WZMASTER', , oStruTmp )
	oModel:SetPrimaryKey({"ID"})
	oModel:GetModel( 'WZMASTER' ):SetDescription( "Parametros" )
	oModel:SetDescription( "Parametros" )

Return oModel

Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PrjWzPgPrm' )
	Local oStruTmp := FWFormViewStruct():New()
	Local oView    := FWFormView():New()
	Local nField := 0
	Local nLenCmps := Len(__aCampos)

	Local cIdField		:= ""
	Local cOrdem		:= ""
	Local cTitulo		:= ""
	Local cDescric		:= ""
	Local aHelp			:= {}
	Local cType			:= ""
	Local cPicture		:= "@"
	Local bPictVar		:= {||}
	Local cLookUp		:= ""
	Local lCanChange	:= .T.
	Local cFolder		:= ""
	Local cGroup		:= ""
	Local aComboValues	:= {}
	Local nMaxLenCombo	:= 0
	Local cIniBrow		:= ""
	Local lVirtual		:= .F.
	Local cPictVar		:= ""
	Local lInsertLine	:= .F.
	Local nWidth		:= 0

	For nField := 1 to nLenCmps
		If __aCampos[nField][CMPEXIBE]
			cIdField := __aCampos[nField][CMPCAMPO]
			cOrdem	 := Alltrim(Str(nField))
			cTitulo	 := __aCampos[nField][CMPTITULO]
			cDescric := __aCampos[nField][CMPTITULO]
			cType	 := __aCampos[nField][CMPTIPO]
			nWidth	 := __aCampos[nField][CMPSIZE]
			lCanChange := __aCampos[nField][CMPWHEN]
			oStruTmp:AddField(cIdField, cOrdem, cTitulo, cDescric, aHelp, cType, cPicture, bPictVar, cLookUp, lCanChange, cFolder, cGroup,aComboValues,nMaxLenCombo, cIniBrow, lVirtual, cPictVar,lInsertLine,nWidth)
		EndIf
	Next nField

	oView:SetModel( oModel )
	oView:AddField( 'PrjWzPgPrm' , oStruTmp, 'WZMASTER' )
	oView:CreateHorizontalBox( 'GERAL', 100 )
	oView:SetOwnerView( 'PrjWzPgPrm' , 'GERAL'  )
	oView:SetCloseOnOK( { || .T. } )

Return oView

Function PrjVlEdtPr()
	If isBlind() .OR. (__cTabTmp)->EXISTE == "NAO"
		MsgAlert("Parâmetro não cadastrado no SX6. Atualize o sistema para poder editar seu conteúdo.")
	Else
		FWExecView("Parametros", "PrjWzPgPrm", MODEL_OPERATION_UPDATE, , { || .T. }, , , , , , , , , , { || .T. })
	EndIf
Return