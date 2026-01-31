#INCLUDE "TOTVS.CH"
#INCLUDE "RESULTADOMRP.CH"
#INCLUDE "FWMVCDEF.CH"

Static _oCkptOP  := Nil
Static _oCkptEMP := Nil
Static _oCkptSC  := Nil
Static _oCkptPC  := Nil
Static _oCkptAE  := Nil
Static _oCkptDEM := Nil
Static _oCkptTRF := Nil
Static _cRetorno := Nil

/*/{Protheus.doc} resultadomrp
Chamada da tela de resultados do MRP (PO-UI)

@type  Function
@author lucas.franca
@since 26/11/2021
@version P12
@return Nil
/*/
Function resultadomrp()
	If PCPVldApp()
		FwCallApp("resultado-mrp")
	EndIf
Return Nil

/*/{Protheus.doc} JsToAdvpl
Bloco de código que receberá as chamadas da tela.
@type  Static Function
@author Lucas Fagundes
@since 30/08/2023
@version P12
@param 01 oWebChannel, Object  , Instancia da classe TWebEngine.
@param 02 cType      , Caracter, Parametro de tipo.
@param 03 cContent   , Caracter, Conteudo enviado pela tela.
@return .T.
/*/
Static Function JsToAdvpl(oWebChannel, cType, cContent)

	Do Case
		Case cType == "preLoad"
			loadCkpt(oWebChannel)

		Case cType == "cockpit"
			cockpit(cContent)

		Case cType == "descarregar"
			finishCkpt()
	EndCase

Return .T.

/*/{Protheus.doc} cockpit
Executa o programa solicitado pelo front-end.
@type  Static Function
@author Lucas Fagundes
@since 30/08/2023
@version P12
@param cDados, Caracter, Json com as informações recebidas do front-end.
@return Nil
/*/
Static Function cockpit(cDados)
	Local oDados := JsonObject():New()

	oDados:fromJson(cDados)

 	If oDados["programa"] == "OP"
		_oCkptOP:abrirTela(oDados["recno"], oDados["operacao"])

	ElseIf oDados["programa"] == "EMP"
		_oCkptEMP:abrirTela(oDados["recno"], oDados["operacao"])

	ElseIf oDados["programa"] == "SC"
		_oCkptSC:abrirTela(oDados["recno"], oDados["operacao"])

	ElseIf oDados["programa"] == "PC"
		_oCkptPC:abrirTela(oDados["recno"], oDados["operacao"])

	ElseIf oDados["programa"] == "AE"
		_oCkptAE:abrirTela(oDados["recno"], oDados["operacao"])

	ElseIf oDados["programa"] == "DEM"
		_oCkptDEM:abrirTela(oDados["recno"], oDados["operacao"])

	ElseIf oDados["programa"] == "TRF"
		_oCkptTRF:abrirTela(oDados["recno"], oDados["operacao"])

	EndIf

	FwFreeObj(oDados)
Return Nil

/*/{Protheus.doc} loadCkpt
Instancia as classe do cockpit da produção.
@type  Static Function
@author Lucas Fagundes
@since 01/09/2023
@version P12
@return Nil
/*/
Static Function loadCkpt(oWebChannel)

	_oCkptOP  := CockpitDaProducao():new("MATA650", oWebChannel)
	_oCkptEMP := CockpitDaProducao():new("MATA381", oWebChannel)
	_oCkptSC  := CockpitDaProducao():new("MATA110", oWebChannel)
	_oCkptPC  := CockpitDaProducao():new("MATA121", oWebChannel)
	_oCkptAE  := CockpitDaProducao():new("MATA122", oWebChannel)
	_oCkptDEM := CockpitDaProducao():new("PCPA136", oWebChannel)
	_oCkptTRF := CockpitDaProducao():new("MATA311", oWebChannel)

Return Nil

/*/{Protheus.doc} finishCkpt
Destroi as instâncias do cockpit da produção.
@type  Static Function
@author Lucas Fagundes
@since 01/09/2023
@version P12
@return Nil
/*/
Static Function finishCkpt()

	_oCkptOP:destroy()
	_oCkptOP := Nil

	_oCkptEMP:destroy()
	_oCkptEMP := Nil

	_oCkptSC:destroy()
	_oCkptSC := Nil

	_oCkptPC:destroy()
	_oCkptPC := Nil

	_oCkptAE:destroy()
	_oCkptAE := Nil

	_oCkptDEM:destroy()
	_oCkptDEM := Nil

	_oCkptTRF:destroy()
	_oCkptTRF := Nil

Return Nil

/*/{Protheus.doc} CockpitDaProducao
Classe de execução do cockpit da produção.
@author Lucas Fagundes
@since 01/09/2023
@version P12
/*/
Class CockpitDaProducao From LongNameClass
	Private Data cPrograma   as Character
	Private Data oModel      as Object
	Private Data oRotina     as Object
	Private Data oWebChannel as Object

	Public Method new(cProg, oWebChannel) Constructor
	Public Method destroy()

	Public Method abrirTela(nRecno, nOperac)
	Private Method carregaPrograma()
	Private Method desbloquearTela()
	Private Method posiciona(nRecno)

	Static Method defineRetorno(cKey, aDados)

EndClass

/*/{Protheus.doc} new
Método construtor da classe CockpitDaProducao
@author Lucas Fagundes
@since 30/08/2023
@version P12
@param 01 cPrograma  , Caracter, Programa que a instância da classe irá executar.
@param 02 oWebChannel, Object  , WebSocket que faz ligação com o front-end  (instância da classe TWebEngine).
@return Self, Object, Instância da classe.
/*/
Method new(cProg, oWebChannel) Class CockpitDaProducao

	Self:cPrograma   := cProg
	Self:oWebChannel := oWebChannel

	Self:carregaPrograma()

Return Self

/*/{Protheus.doc} destroy
Método destrutor da classe.
@author Lucas Fagundes
@since 30/08/2023
@version P12
@return Nil
/*/
Method destroy() Class CockpitDaProducao
	::cPrograma   := ""
	::oWebChannel := Nil

	FwFreeObj(::oRotina)
Return Nil

/*/{Protheus.doc} carregaPrograma
Carrega as informações do programa que será executado.
@author Lucas Fagundes
@since 30/08/2023
@version P12
@return Nil
/*/
Method carregaPrograma() Class CockpitDaProducao
	Self:oRotina := JsonObject():New()

	Self:oRotina["idRetornoFront"] := "unlockScreen"

	If ::cPrograma == "MATA650"
		::oRotina["funcao"        ] := "MATA650"
		::oRotina["posParamOperac"] := 2
		::oRotina["alias"         ] := "SC2"
		::oRotina["isMVC"         ] := .F.
		::oRotina["menu"          ] := {}

	ElseIf ::cPrograma == "MATA381"
		::oRotina["funcao"        ] := "MATA381"
		::oRotina["posParamOperac"] := 3
		::oRotina["alias"         ] := "SD4"
		::oRotina["isMVC"         ] := .F.
		::oRotina["menu"          ] := {}

	ElseIf ::cPrograma == "MATA110"
		::oRotina["funcao"        ] := "MATA110"
		::oRotina["posParamOperac"] := 3
		::oRotina["alias"         ] := "SC1"
		::oRotina["isMVC"         ] := .F.
		::oRotina["menu"          ] := {}

	ElseIf ::cPrograma == "MATA121"
		::oRotina["funcao"        ] := "MATA120(1, "
		::oRotina["posParamOperac"] := 3
		::oRotina["alias"         ] := "SC7"
		::oRotina["isMVC"         ] := .F.
		::oRotina["menu"          ] := {}

	ElseIf ::cPrograma == "MATA122"
		::oRotina["funcao"        ] := "MATA120(2, "
		::oRotina["posParamOperac"] := 3
		::oRotina["alias"         ] := "SC7"
		::oRotina["isMVC"         ] := .F.
		::oRotina["menu"          ] := {}

	ElseIf ::cPrograma == "PCPA136"
		::oRotina["funcao"        ] := "PCPA136"
		::oRotina["posParamOperac"] := -1
		::oRotina["alias"         ] := "SVB"
		::oRotina["isMVC"         ] := .T.
		::oRotina["menu"          ] := FWLoadMenuDef(::cPrograma)

	ElseIf ::cPrograma == "MATA311"
		::oRotina["funcao"        ] := "MATA311"
		::oRotina["posParamOperac"] := -1
		::oRotina["alias"         ] := "NNS"
		::oRotina["isMVC"         ] := .T.
		::oRotina["menu"          ] := FWLoadMenuDef(::cPrograma)

	ElseIf ::cPrograma == "MATA681"
		::oRotina["funcao"        ] := "MATA681"
		::oRotina["posParamOperac"] := 2
		::oRotina["alias"         ] := "SH6"
		::oRotina["isMVC"         ] := .F.
		::oRotina["menu"          ] := {}
		::oRotina["idRetornoFront"] := "executaApontamento"

	EndIf

	::oRotina["compartilhamento"] := FWModeAccess(::oRotina["alias"], 1)+FWModeAccess(::oRotina["alias"], 2)+FWModeAccess(::oRotina["alias"], 3)

Return Nil

/*/{Protheus.doc} abrirTela
Abre a tela do programa na operação recebida.
@author Lucas Fagundes
@since 30/08/2023
@version P12
@param 01 nRecno , Numerico, Recno do registro que será aberto.
@param 02 nOperac, Numerico, Operação que será realizada no registro (-1: Browse, 2: Visualização, 3: Inclusão, 4: Update, 5: Delete).
@return Nil
/*/
Method abrirTela(nRecno, nOperac) Class CockpitDaProducao
	Local aArea     := GetArea()
	Local cExec     := ""
	Local cFilAux   := cFilAnt
	Local cFunc     := FunName()
	Local cTitle    := ""
	Local lInclusao := Empty(nRecno) .And. nOperac == 3
	Local nInd      := 0
	Local nOperMenu := 0
	Local nOperMVC  := 0
	Local nPos      := 0

	SetFunName(::cPrograma)

	If nOperac > -1

		If lInclusao
			dbSelectArea(::oRotina["alias"])
		Else
			::posiciona(nRecno)
		EndIf

		If !::oRotina["isMVC"]
			INCLUI := lInclusao
			ALTERA := .F.

			If nOperac == 4
				ALTERA := .T.
			EndIf

			cExec := ::oRotina["funcao"]

			If Left(::oRotina["funcao"], 7) != "MATA120"
				cExec += "("
			EndIf

			For nInd := 1 To ::oRotina["posParamOperac"]
				If nInd == ::oRotina["posParamOperac"]
					cExec += cValToChar(nOperac)
				Else
					cExec += "Nil, "
				EndIf
			Next

			If ::oRotina["funcao"] == "MATA650"
				cExec += ", .F."
			EndIf
			cExec += ")"

			&(cExec)
		Else
			Do Case
				Case nOperac == 2
					nOperMVC  := MODEL_OPERATION_VIEW
					nOperMenu := OP_VISUALIZAR
					cTitle    := STR0297 // "Visualizar"
				Case nOperac == 4
					nOperMVC  := MODEL_OPERATION_UPDATE
					nOperMenu := OP_ALTERAR
					cTitle    := STR0298 // "Alterar"
				Case nOperac == 5
					nOperMVC  := MODEL_OPERATION_DELETE
					nOperMenu := OP_EXCLUIR
					cTitle    := STR0299 // "Excluir"
			EndCase

			nPos := aScan(::oRotina["menu"], {|x| x[4] == nOperMenu})

			If Upper(::oRotina["menu"][nPos][2]) == "VIEWDEF." + ::cPrograma
				FWExecView(cTitle, ::cPrograma, nOperMVC)
			Else
				cExec := ::oRotina["menu"][nPos][2]

				If Right(cExec, 1) != ")"
					cExec += "()"
				EndIf

				&(cExec)
			EndIf
		EndIf

		cFilAnt := cFilAux
	Else

		If ::cPrograma == "MATA121" .Or. ::cPrograma == "MATA122"
			cExec := ::cPrograma
		Else
			cExec := ::oRotina["funcao"]
		EndIf

		cExec += "()"

		&(cExec)
	EndIf

	SetFunName(cFunc)
	RestArea(aArea)

	::desbloquearTela()

Return Nil

/*/{Protheus.doc} desbloquearTela
Desbloqueia a tela do cockpit que fica aguardando o fim da execução do programa.
@author Lucas Fagundes
@since 11/09/2023
@version P12
@return Nil
/*/
Method desbloquearTela() Class CockpitDaProducao
	Local cRetorno := ""

	If !Empty(_cRetorno)
		cRetorno := _cRetorno
	EndIf

	_cRetorno := Nil

	::oWebChannel:AdvplToJs(::oRotina["idRetornoFront"], cRetorno)
Return Nil

/*/{Protheus.doc} posiciona
Posiciona o registro que será aberto e seta a filial

@author Lucas Fagundes
@since 16/10/2023
@version P12
@param nRecno, Numerico, Recno do registro que será posicionado.
@return Nil
/*/
Method posiciona(nRecno) Class CockpitDaProducao
	Local aFiliais := {}
	Local cExec    := ""
	Local cFilReg  := ""
	Local nIndex   := 1
	Local nTotal   := 0

	(::oRotina["alias"])->(dbGoTo(nRecno))

	cExec   := ::oRotina["alias"] + "->" + getCmpFil(::oRotina["alias"])
	cFilReg := &(cExec)

	If ::oRotina["compartilhamento"] == "EEE"
		cFilAnt := cFilReg
	Else
		aFiliais := FWAllFilial(,,cEmpAnt, .F.)
		nTotal   := Len(aFiliais)

		For nIndex := 1 To nTotal
			If xFilial(::oRotina["alias"], aFiliais[nIndex]) == cFilReg
				cFilAnt := aFiliais[nIndex]
				Exit
			EndIf
		Next

		aSize(aFiliais, 0)
	EndIf

Return Nil

/*/{Protheus.doc} defineRetorno
Define um retorno que será disparado para o front-end via AdvplToJs

@author lucas.franca
@since 09/09/2024
@version P12
@param 01, cKey  , Caractere, Identificador que deve ser retornado
@param 02, aDados, Array    , Array com informações adicionais para retornar, contendo chave e valor.
@return Nil
/*/
Method defineRetorno(cKey, aDados) Class CockpitDaProducao
	Local nIndex   := 0
	Local nTotal   := 0
	Local oRetorno := JsonObject():New()

	Default aDados := {}

	oRetorno["key"] := cKey

	nTotal := Len(aDados)
	For nIndex := 1 To nTotal
		oRetorno[aDados[nIndex][1]] := aDados[nIndex][2]
	Next nIndex

	_cRetorno := oRetorno:toJson()

	FreeObj(oRetorno)
	aSize(aDados, 0)
Return Nil

/*/{Protheus.doc} getCmpFil
Retorna o campo _FILIAL do alias recebido.

@type  Static Function
@author Lucas Fagundes
@since 16/10/2023
@version P12
@param cAlias, Caracter, Alias que irá buscar o campo filial
@return cCampo, Caracter, Campo filial do alias.
/*/
Static Function getCmpFil(cAlias)
	Local cCampo := cAlias + "_FILIAL"

	If Left(cAlias, 1) == "S"
		cCampo := SubStr(cCampo, 2, Len(cCampo))
	EndIf

Return cCampo
