#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA131.CH"

/*/{Protheus.doc} PCPA131EVDEF
Eventos padrões da manutenção dos processos produtivos
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
/*/
CLASS PCPA131EVDEF FROM FWModelEvent

	DATA oGridBkp

	METHOD New() CONSTRUCTOR

	METHOD Activate()
	METHOD Destroy()
	METHOD FieldPreVld()
	METHOD GridLinePreVld()
	METHOD GridLinePosVld()
	METHOD GridPosVld()

	METHOD ValidaDatas()
	METHOD CarregaGrid()
	METHOD ValidaHorario()
	METHOD GravaBackup()
	METHOD BuscaDataNoBackup()
	METHOD AddLinhaGrid()

ENDCLASS

METHOD New() CLASS  PCPA131EVDEF

Return

/*/{Protheus.doc} Activate
Método chamado pelo MVC quando ocorrer a ativação do Model.
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return
/*/
METHOD Activate(oModel, lCopy) CLASS PCPA131EVDEF

	//Inicializa o objeto de backup
	If ::oGridBkp <> NIL
		FreeObj(::oGridBkp)
		::oGridBkp := Nil
	EndIf

	::oGridBkp := JsonObject():New()

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oModel:GetModel("SVZ_DETAIL"):SetNoInsertLine( .F. )
		oModel:GetModel("SVZ_DETAIL"):SetNoUpdateLine( .F. )
		oModel:GetModel("SVZ_DETAIL"):SetNoDeleteLine( .F. )

		//Inicializa a variável de controle da alteração da Data Mestre
		oModel:GetModel("SVX_MASTER"):LoadValue("VX_DATALT", .F.)
	Else
		oModel:GetModel("SVZ_DETAIL"):SetNoUpdateLine( .T. )
	EndIf

	oModel:GetModel("SVZ_DETAIL"):SetNoInsertLine( .T. )
	oModel:GetModel("SVZ_DETAIL"):SetNoDeleteLine( .T. )
	oModel:GetModel('SVZ_DETAIL'):SetMaxLine( 3000 ) 

Return

/*/{Protheus.doc} Destroy
Método destrutor do evento
@author Marcelo Neumann
@since 23/07/2019
@version P12
/*/
METHOD Destroy() CLASS PCPA131EVDEF

	FreeObj(::oGridBkp)
	::oGridBkp := Nil

Return Self

/*/{Protheus.doc} FieldPreVld
Método chamado pelo MVC quando ocorrer a ação de pré validação do Field
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return lOk
/*/
METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS PCPA131EVDEF

	Local lOk 	  := .T.
	Local cCalend := ""

	If cModelID == "SVX_MASTER"
		cCalend   := oSubModel:GetValue("VX_CALEND")
		If cAction == "SETVALUE"
			If cId == "VX_DATAINI" .Or. cId == "VX_DATAFIM"
				lOk := ::ValidaDatas(cId, xValue)
			EndIf
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} GridLinePreVld
Método chamado pelo MVC quando ocorrer as ações de pre validação da linha do Grid
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return lOk
/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS PCPA131EVDEF

	Local lOk := .T.

	If cModelID == "SVZ_DETAIL"
		If cAction == "SETVALUE"
			If xValue != xCurrentValue
				oSubModel:LoadValue("SVZ_LINALT", .T.)
				oSubModel:LoadValue("SVZ_INTLIN", .T.)
			EndIf
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} GridLinePosVld
Método chamado pelo MVC quando ocorrer as ações de pos validação da linha do Grid
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return lOk
/*/
METHOD GridLinePosVld(oSubModel, cModelID, nLine) CLASS PCPA131EVDEF

	Local lOk := .T.

	If cModelID == "SVZ_DETAIL" .And. oSubModel:GetValue("SVZ_LINALT", nLine)
		If ::ValidaHorario(oSubModel, nLine)
			If oSubModel:GetValue("SVZ_LINALT", nLine)
				oSubModel:LoadValue("SVZ_LINALT", .F.)
			EndIf
		Else
			lOk := .F.
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} GridPosVld
Método chamado pelo MVC quando ocorrer as ações de pós validação do Grid
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return lOk
/*/
METHOD GridPosVld(oSubModel, cModelId) CLASS PCPA131EVDEF

	Local oModelPai		:= FWModelActive()
	Local oModelCommit	:= oModelPai:GetModel("SVZ_COMMIT")
	Local nIndDia		:= 0
	Local dData			:= NIL
	Local cHoraIni		:= ""
	Local cHoraFim		:= ""
	Local cIntervalo	:= ""
	Local lIntegra		:= .F.
	Local lOk			:= .T.

	If cModelID == "SVZ_DETAIL"
		For nIndDia := 1 To oSubModel:Length()
			If oSubModel:IsDeleted(nIndDia)
				Loop
			Endif
			If !::ValidaHorario(oSubModel, nIndDia)
				oSubModel:GoLine(nIndDia)
				lOk := .F.
				Exit
			EndIf
		Next nIndDia

		oModelPai:GetModel('SVZ_COMMIT'):SetMaxLine( 3000 ) 

		If lOk
			//Carrega o modelo de COMMIT
			If oModelPai:GetOperation() == MODEL_OPERATION_INSERT

				For nIndDia := 1 To oSubModel:Length()
					If oSubModel:IsDeleted(nIndDia)
						Loop
					Endif
					dData		:= oSubModel:GetValue("VZ_DATA",    nIndDia)
					cHoraIni	:= oSubModel:GetValue("VZ_HORAINI", nIndDia)
					cHoraFim	:= oSubModel:GetValue("VZ_HORAFIM", nIndDia)
					cIntervalo	:= oSubModel:GetValue("VZ_INTERVA", nIndDia)

					::AddLinhaGrid(oModelCommit, dData, cHoraIni, cHoraFim, cIntervalo, .T.)
				Next nIndDia

			ElseIf oModelPai:GetOperation() == MODEL_OPERATION_UPDATE

				//Se foi alterada a Data Inicial e/ou Data Final, apaga todas as linhas do modelo de COMMIT e adiciona novamente
				If oModelPai:GetModel("SVX_MASTER"):GetValue("VX_DATALT")

					//Marca as linhas apagadas como Pendentes para integrar com o MRP
 					For nIndDia := 1 To oModelCommit:Length()
						If oModelCommit:GetValue("VZ_DATA", nIndDia) < oModelPai:GetModel("SVX_MASTER"):GetValue("VX_DATAINI") .Or. ;
						   oModelCommit:GetValue("VZ_DATA", nIndDia) > oModelPai:GetModel("SVX_MASTER"):GetValue("VX_DATAFIM")

							oModelCommit:GoLine(nIndDia)
							oModelCommit:LoadValue("SVZ_INTLIN", .T.)
						EndIf
					Next nIndDia

					oModelCommit:DelAllLine()

 					For nIndDia := 1 To oSubModel:Length()
						If oSubModel:IsDeleted(nIndDia)
							Loop
						Endif
						
						dData		:= oSubModel:GetValue("VZ_DATA",    nIndDia)
						cHoraIni	:= oSubModel:GetValue("VZ_HORAINI", nIndDia)
						cHoraFim	:= oSubModel:GetValue("VZ_HORAFIM", nIndDia)
						cIntervalo	:= oSubModel:GetValue("VZ_INTERVA", nIndDia)
						lIntegra	:= oSubModel:GetValue("SVZ_INTLIN", nIndDia)

						::AddLinhaGrid(oModelCommit, dData, cHoraIni, cHoraFim, cIntervalo, lIntegra)
					Next nIndDia
				Else
					//Se não foi alterada a Data Inicial e/ou Data Final, as linhas do model DETAIL e COMMIT estão iguais
					For nIndDia := 1 To oSubModel:Length()
						If oSubModel:IsDeleted(nIndDia)
							Loop
						Endif

						oModelCommit:GoLine(nIndDia)
						oModelCommit:LoadValue("VZ_DATA",    oSubModel:GetValue("VZ_DATA",    nIndDia))
						oModelCommit:LoadValue("VZ_HORAINI", oSubModel:GetValue("VZ_HORAINI", nIndDia))
						oModelCommit:LoadValue("VZ_HORAFIM", oSubModel:GetValue("VZ_HORAFIM", nIndDia))
						oModelCommit:LoadValue("VZ_INTERVA", oSubModel:GetValue("VZ_INTERVA", nIndDia))
						oModelCommit:LoadValue("SVZ_INTLIN", oSubModel:GetValue("SVZ_INTLIN", nIndDia))
					Next nIndDia
				EndIf

			EndIf
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} ValidaDatas
Método para validar as Datas informadas no Header
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return lOk
/*/
METHOD ValidaDatas(cId, xValue) CLASS PCPA131EVDEF

	Local oModel	:= FWModelActive()
	Local oModelSVX	:= oModel:GetModel("SVX_MASTER")
	Local dDataIni	:= IIF(cId == "VX_DATAINI", xValue, oModelSVX:GetValue("VX_DATAINI"))
	Local dDataFim	:= IIF(cId == "VX_DATAFIM", xValue, oModelSVX:GetValue("VX_DATAFIM"))
	Local lOk		:= .T.

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		If Empty(dDataFim)
			Return .T.
		EndIf

		If Empty(dDataIni)
			Return .T.
		EndIf
	EndIf

	If cId == "VX_DATAINI"
		If dDataIni > dDataFim
			Help( ,  , "Help", ,  STR0009,;	//"Data Inicial maior que Data Final."
				 1, 0, , , , , , {STR0010}) //"Informe uma data menor ou igual a data Final."
			Return .F.
		EndIf
	EndIf

	If cId == "VX_DATAFIM"
		If dDataFim < dDataIni
			Help( ,  , "Help", ,  STR0011,;	//"Data Final menor que Data Inicial."
				 1, 0, , , , , , {STR0012})	//"Informe uma data maior ou igual a data Inicial."
			Return .F.
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} CarregaGrid
Método para recarregar a Grid com as Datas do intervalo Data Inicial -> Data Final
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return
/*/
METHOD CarregaGrid(cId, xValue) CLASS PCPA131EVDEF

	Local oModel		:= FWModelActive()
	Local oModelSVX		:= oModel:GetModel("SVX_MASTER")
	Local oModelSVZ		:= oModel:GetModel("SVZ_DETAIL")
	Local dData			:= NIL
	Local cHoraIni		:= ""
	Local cHoraFim		:= ""
	Local cIntervalo	:= ""
	Local lIntegra		:= .T.
	Local dDataIni		:= IIF(cId == "VX_DATAINI", xValue, oModelSVX:GetValue("VX_DATAINI"))
	Local dDataFim		:= IIF(cId == "VX_DATAFIM", xValue, oModelSVX:GetValue("VX_DATAFIM"))
	Local nLinha        := 1

	If Empty(dDataFim) .Or. Empty(dDataIni)
		Return
	EndIf

	oModelSVZ:SetNoInsertLine( .F. )
	oModelSVZ:SetNoUpdateLine( .F. )
	oModelSVZ:SetNoDeleteLine( .F. )

	If oModelSVZ:IsEmpty()
		//Carrega a Grid
		oModelSVZ:ClearData( .T., .F. )
		For dData := dDataIni To dDataFim
			::AddLinhaGrid(oModelSVZ, dData, , , , lIntegra)
		Next dData
	Else
		//Salva os horários "apagados"
		::GravaBackup(oModelSVZ)

		nLinha := oModelSVZ:Length() + 1

		//Recarrega a Grid
		oModelSVZ:DelAllLine()
		For dData := dDataIni To dDataFim
			::BuscaDataNoBackup(dData, @cHoraIni, @cHoraFim, @cIntervalo, @lIntegra)
			::AddLinhaGrid(oModelSVZ, dData, cHoraIni, cHoraFim, cIntervalo, lIntegra)
		Next dData
	EndIf

	oModelSVZ:SetNoInsertLine( .T. )
	oModelSVZ:SetNoDeleteLine( .T. )

	oModelSVZ:GoLine(nLinha)

Return

/*/{Protheus.doc} ValidaHorario
Método para validar a combinação Hora Inicial, Hora Final e Intervalo
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return .T. ou .F.
/*/
METHOD ValidaHorario(oSubModel, nLine) CLASS PCPA131EVDEF

	Local cHoraIni		:= oSubModel:GetValue("VZ_HORAINI", nLine)
	Local cHoraFim		:= oSubModel:GetValue("VZ_HORAFIM", nLine)
	Local cIntervalo	:= oSubModel:GetValue("VZ_INTERVA", nLine)
	Local dData			:= oSubModel:GetValue("VZ_DATA"   , nLine)

	If !P131HoraOk(cHoraIni, cHoraFim, cIntervalo, DToC(dData))
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} GravaBackup
Método para gravar o array de backup da Grid
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return
/*/
METHOD GravaBackup(oModelSVZ) CLASS PCPA131EVDEF

	Local nInd			:= 1
	Local cHoraIni		:= ""
	Local cHoraFim		:= ""
	Local cIntervalo	:= ""
	Local lIntegra		:= .F.
	Local dData			:= NIL

	For nInd := 1 To oModelSVZ:Length()
		dData := oModelSVZ:GetValue("VZ_DATA", nInd)

		If !Empty(dData)
			cHoraIni	:= oModelSVZ:GetValue("VZ_HORAINI", nInd)
			cHoraFim	:= oModelSVZ:GetValue("VZ_HORAFIM", nInd)
			cIntervalo	:= oModelSVZ:GetValue("VZ_INTERVA", nInd)
			lIntegra	:= oModelSVZ:GetValue("SVZ_INTLIN", nInd)

			If ::oGridBkp[DToS(dData)] == NIL
				::oGridBkp[DToS(dData)] := Array(4)
			EndIf

			::oGridBkp[DToS(dData)][1] := cHoraIni
			::oGridBkp[DToS(dData)][2] := cHoraFim
			::oGridBkp[DToS(dData)][3] := cIntervalo
			::oGridBkp[DToS(dData)][4] := lIntegra
		EndIf
	Next nInd

Return

/*/{Protheus.doc} BuscaDataNoBackup
Método para buscar uma data no array de backup
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return
/*/
METHOD BuscaDataNoBackup(dData, cHoraIni, cHoraFim, cIntervalo, lIntegra) CLASS PCPA131EVDEF

	If ::oGridBkp[DToS(dData)] == Nil
		cHoraIni	:= NIL
		cHoraFim	:= NIL
		cIntervalo	:= NIL
		lIntegra	:= NIL
	Else
		cHoraIni	:= ::oGridBkp[DToS(dData)][1]
		cHoraFim	:= ::oGridBkp[DToS(dData)][2]
		cIntervalo	:= ::oGridBkp[DToS(dData)][3]
		lIntegra	:= ::oGridBkp[DToS(dData)][4]
	EndIf

Return

/*/{Protheus.doc} AddLinhaGrid
Método para adicionar uma linha no grid
@author Marcelo Neumann
@since 09/07/2018
@version 1.0
@return lOk
/*/
METHOD AddLinhaGrid(oModel, dData, cHoraIni, cHoraFim, cIntervalo, lIntegra) CLASS PCPA131EVDEF

	Local lOk := .T.

	Default cHoraIni	:= "00:00"
	Default cHoraFim	:= "00:00"
	Default cIntervalo	:= "00:00"
	Default lIntegra	:= .T.

	oModel:AddLine()
	oModel:LoadValue("VZ_DATA",    dData)
	oModel:LoadValue("VZ_DSEMANA", cValToChar( DOW(dData) ))
	oModel:LoadValue("VZ_HORAINI", cHoraIni)
	oModel:LoadValue("VZ_HORAFIM", cHoraFim)
	oModel:LoadValue("VZ_INTERVA", cIntervalo)
	oModel:LoadValue("SVZ_LINALT", .F.)
	oModel:LoadValue("SVZ_INTLIN", lIntegra)

Return lOk
