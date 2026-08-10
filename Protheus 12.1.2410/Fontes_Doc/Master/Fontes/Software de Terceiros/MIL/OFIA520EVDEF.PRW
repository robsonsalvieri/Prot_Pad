#Include 'TOTVS.ch'
#Include 'FWMVCDef.ch'
#Include "FWEVENTVIEWCONSTS.CH"
#Include "OFIA520.CH"


Class OFIA520EVDEF From FWModelEvent

	Data dDataIni // Data Inicial do Periodo que será carregada na abertura da tela
	Data dDataFim // Data Final do Periodo que será carregada na abertura da tela
	
	Method New() Constructor
	Method Activate()
	Method FieldPreVld()
	Method ModelPosVld()

EndClass


// New //
Method New() Class OFIA520EVDEF

	::dDataIni := dDataBase + 1
	::dDataFim := dDataBase + 31

Return .T.


// Abertura TELA //
Method Activate(oModel, lCopy) Class OFIA520EVDEF
	
	oModel:LoadValue("MASTER", "DAT_INI", ::dDataIni)
	oModel:LoadValue("MASTER", "DAT_FIM", ::dDataFim)

Return .T.


// Campos Cabeçalho / Escala //
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class OFIA520EVDEF

	Local lRet    := .T.
	Local cCpoAux := ""
	Local lVldDt  := .T.

	If cModelId == "MASTER"
		If cAction == "SETVALUE" // Valid do campo
			If cId $ "ESCALA_01/ESCALA_02/ESCALA_03/ESCALA_04/ESCALA_05/ESCALA_06/ESCALA_07/ESCALA_08"
				If FWFldGet(cId) <> xValue
					lRet := OA520004D_Valida_Escala(xValue)
					If lRet .and. cId $ "ESCALA_02/ESCALA_03/ESCALA_04/ESCALA_05"
						cCpoAux := "ESCALA_0" + StrZero(Val(Right(cId,1)) + 1, 1)
						If Empty(oSubModel:GetValue(cCpoAux))
							oSubModel:SetValue(cCpoAux ,xValue)
						Endif	
					Endif
				Endif	
			Elseif cId == "DAT_INI"
				If	xValue <= dDataBase
					Help("", 1, STR0034, , STR0035 + dToc(dDataBase + 1) + ".", 1, 0) //"FieldPreVld", "Impossível Inserir Escala de Produtivo antes de "
					lRet := .F.	
				Elseif FWFldGet("DAT_FIM") < xValue
					lVldDt := .F.		
				Endif
			Elseif cId == "DAT_FIM"
				If xValue > (dDataBase + 365)
					Help("", 1, STR0034, , STR0036, 1, 0) //"FieldPreVld", "Período não pode ser maior que um ano."
					lRet := .F.	
				Elseif xValue < FWFldGet("DAT_INI")
					lVldDt := .F.	
				Endif	
			Endif
			If !lVldDt
				Help("", 1, STR0034, , STR0037, 1, 0) //"FieldPreVld", "Data Final menor que Data Inicial."
				lRet := .F.	
			Endif
		Endif	
	Endif

Return lRet


// Tudo OK da Tela //
Method ModelPosVld(oModel, cId) Class OFIA520EVDEF

	Local nI      := 0
	Local lVldGrd := .F.
	Local oGrid   := oModel:GetModel("PROD")
	Local lRet    := .T.
	
	For nI := 1 To oGrid:Length()
		oGrid:GoLine(nI)
		If oGrid:GetValue("L_MARK")
			lVldGrd := .T.
			Exit
		Endif
	Next nI

	If !lVldGrd
		Help("", 1, STR0038, , STR0039, 1, 0) //"ModelPosVld", "Necessário selecionar ao menos um Produtivo."
		lRet := .F.	
	Endif

Return lRet

 
