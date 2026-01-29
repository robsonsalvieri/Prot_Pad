#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TMSAF97.CH"

//-- Totais dos waypoints
#Define TR_LATIT  01
#Define TR_LONGIT 02
#Define TR_QTDPRG 03
#Define TR_QTDDOC 04
#Define TR_QTDVOL 05
#Define TR_PESO   06
#Define TR_PESOM3 07
#Define TR_METRO3 08
#Define TR_VALMER 09
#Define TR_QTDCOL 09

//-- Programações dos waypoints
#Define PW_LATIT  01
#Define PW_LONGIT 02
#Define PW_FILORI 03
#Define PW_NUMPRG 04
#Define PW_SEQPRG 05
#Define PW_VIAGEM 06
#Define PW_DATPRV 07
#Define PW_HORPRV 08
#Define PW_QTDDOC 09
#Define PW_QTDVOL 10
#Define PW_PESO   11
#Define PW_PESOM3 12
#Define PW_METRO3 13
#Define PW_VALMER 14
#dEFINE PW_QTDCOL 14

Static aTitCols := {}

/*
{Protheus.doc} TMSAF97()
Monta a visualização do mapa da Here
Uso: TMSAF97
@sample
@author Valdemar Roberto Mognon 
@since 28/03/2024
@version 1.0
@type Function
*/
Function TMSAF97()
Local aCoors     := FWGetDialogSize(oMainWnd)
Local aButtons   := {}
Local nLarFolder := 0
Local nAltFolder := 0
Local cQuery     := ""

Local oDlgPrinc
Local oLayer
Local oPanelTot
Local oFolder
Local oMark

Private oWeb        := TWebChannel():New()
Private cMark       := GetMark()
Private nFldr       := 1
Private lTodos      := .F.
Private oWebChannel
Private oWebEngine

//-- Carrega título das colunas das programações do ponto
aTitCols := {{FWX3Titulo("DF8_FILORI"),PW_FILORI},{FWX3Titulo("DF8_NUMPRG"),PW_NUMPRG},{FWX3Titulo("DF8_VIAGEM"),PW_VIAGEM},;
			 {FWX3Titulo("DTW_DATPRE"),PW_DATPRV},{FWX3Titulo("DTW_HORPRE"),PW_HORPRV},{FWX3Titulo("DF8_QTDDOC"),PW_QTDDOC},;
			 {FWX3Titulo("DF8_QTDVOL"),PW_QTDVOL},{FWX3Titulo("DF8_PESO")  ,PW_PESO}  ,{FWX3Titulo("DF8_PESOM3"),PW_PESOM3},;
			 {FWX3Titulo("DF8_METRO3"),PW_METRO3},{FWX3Titulo("DF8_VALOR") ,PW_VALMER}}

DEFINE MSDIALOG oDlgPrinc TITLE STR0001 FROM aCoors[1],aCoors[2] To aCoors[3],aCoors[4] PIXEL	//-- "Visualiza o Mapa das Programações"

	//-- Cria container para os browses
	oLayer:= FWLayer():New()
	oLayer:Init(oDlgPrinc,.F.,.T.)

	//-- Define linhas
	oLayer:AddLine("LINHA",100,.F.)	//-- Adiciona linha

	//-- Define painel da markbrowse
	oPanelTot := oLayer:GetLinePanel("LINHA")

	nLarFolder := oPanelTot:nRight * 50 / 100
	nAltFolder := (oPanelTot:nBottom * 50 / 100) - 30

	oFolder := TFolder():New(0,0,{"Programações","Mapa"},{"Programações","Mapa"},oPanelTot,1,,,.T.,.F.,nLarFolder,nAltFolder)
	oFolder:bSetOption:={|n| nFldr := n,TMSAF97Map()}

	//-- Define markbrowse da programação de carregamento
	oMark := FWMarkBrowse():New()		
	oMark:SetAlias("DF8")
	oMark:AddMarkColumns({|| Iif(DF8_MARK == cMark,"LBOK","LBNO")},{|| TMSAF97Mrk(1,oMark)},{|| TMSAF97Mrk(2,oMark)})
	oMark:SetFilterDefault("DF8_FILIAL == '" + xFilial("DF8") + "' .And. (DF8_MARK == Space(Len(DF8->DF8_MARK)) .Or. DF8_MARK == cMark)")
	oMark:SetMenudef("")
	oMark:DisableReport()
	oMark:DisableFilter()
	oMark:DisableLocate()
	oMark:DisableSeek()
	oMark:Activate(oFolder:aDialogs[1])

	//-- Define tela do mapa
	WebChannel(oFolder:aDialogs[2])

ACTIVATE MSDIALOG oDlgPrinc ON INIT (EnchoiceBar(oDlgPrinc,{|| oDlgPrinc:End()},{|| oDlgPrinc:End()},,aButtons))

//-- Limpa o campo de marca da programação
cQuery := " UPDATE " + RetSqlName("DF8") + CRLF
cQuery += "    SET DF8_MARK = '" + Space(Len(DF8->DF8_MARK)) + "' " + CRLF
cQuery += "  WHERE DF8_FILIAL = '" + xFilial("DF8") + "'" + CRLF
cQuery += "    AND DF8_MARK   = '" + cMark + "' " + CRLF
cQuery += "    AND D_E_L_E_T_ = ' ' "
TCSqlExec(cQuery)

Return

/*
{Protheus.doc} TMSAF97Mrk()
Marca/Desmarca as linhas
Uso: TMSAF97
@sample
@author Valdemar Roberto Mognon 
@since 28/03/2024
@version 1.0
@type Function
*/
Function TMSAF97Mrk(nAcao,oMark)
Local cQuery := ""

Default nAcao     := 0
Default oDlgPrinc := Nil

If nAcao == 1	//-- Uma linha
	If DF8->DF8_MARK == cMark
		RecLock("DF8",.F.)
		DF8->DF8_MARK := ""
		DF8->(MsUnlock())
	ElseIf Empty(DF8->DF8_MARK)
		RecLock("DF8",.F.)
		DF8->DF8_MARK := cMark
		DF8->(MsUnlock())
	EndIf
ElseIf nAcao == 2	//-- Todas as linhas
	cQuery := " UPDATE " + RetSqlName("DF8")
	If lTodos
		cQuery += "    SET DF8_MARK = '" + Space(Len(DF8->DF8_MARK)) + "' "
	Else
		cQuery += "    SET DF8_MARK = '" + cMark + "' "
	EndIf
	cQuery += "  WHERE DF8_FILIAL = '" + xFilial("DF8") + "'"
	If lTodos
		cQuery += "    AND DF8_MARK   = '" + cMark + "' "
	Else
		cQuery += "    AND DF8_MARK   = '" + Space(Len(DF8->DF8_MARK)) + "' "
	EndIf
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	TCSqlExec(cQuery)
	lTodos := Iif(lTodos,.F.,.T.)
EndIf

oMark:Refresh()

Return

/*
{Protheus.doc} TMSAF97Map()
Atualiza o mapa
Uso: TMSAF97
@sample
@author Valdemar Roberto Mognon 
@since 01/04/2024
@version 1.0
@type Function
*/
Function TMSAF97Map()

If nFldr == 2	//-- Entrando no folder do mapa
	oWebEngine:Reload()
EndIf

Return

/*
{Protheus.doc} WebChannel()
Conecta o WebSocket
Uso: TMSAF97
@sample
@author Valdemar Roberto Mognon 
@since 01/04/2024
@version 1.0
@type Static Function
*/
Static Function WebChannel(oFolder)
Local nWebPort := 0

oWebChannel := TWebChannel():New()

nWebPort := oWebChannel:connect()

If !oWebChannel:lConnected
	Help("",1,"TMSAF9701",,,5,11)	//-- "Erro na conexão com o WebSocket"
Else
	oWebChannel:bjsToAdvpl := {|Self,CodeType,CodeContent| jsToAdvpl(Self,CodeType,CodeContent)}
	WebEngine(oFolder,nWebPort)
EndIf

Return

/*
{Protheus.doc} WebEngine()
Executa a exibição do mapa
Uso: TMSAF97
@sample
@author Valdemar Roberto Mognon 
@since 01/04/2024
@version 1.0
@type Static Function
*/
Static Function WebEngine(oFolder,nWebPort)
Local cLink := ""
Local cMapa := ""
Local oColEnt

oColEnt := TMSBCACOLENT():New("DNM")
If oColEnt:DbGetToken()
	DNM->(DbGoTo(oColEnt:config_recno))
	cLink := oColEnt:locmap
	cMapa := AllTrim(cLink) + "?totvstec_websocket_port=" + cValToChar(nWebPort) + "&totvstec_remote_type=" + cValToChar(GetRemoteType())
EndIf

oWebEngine := TWebEngine():New(oFolder,0,0,100,100,cMapa,nWebPort)

oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

Return 

/*
{Protheus.doc} jsToAdvpl()
Chama a função que executa a busca de dados no advpl
Uso: TMSAF97
@sample
@author Valdemar Roberto Mognon 
@since 02/04/2024
@version 1.0
@type Static Function
*/
Static Function jsToAdvpl(Self,CodeType,CodeContent)

If ValType(CodeType) == "C" .And. CodeType == "pageStarted"
	IniData()
EndIf

Return

/*
{Protheus.doc} IniData()
Executa a busca de dados no advpl
Uso: TMSAF97
@sample
@author Valdemar Roberto Mognon 
@since 02/04/2024
@version 1.0
@type Static Function
*/
Static Function IniData()
Local cJson     := ""
Local cQuery    := ""
Local cAliasDF8 := ""
Local cPrgAnt   := ""
Local cWayAnt   := ""
Local cTexto    := ""
Local cPosAnt   := ""
Local aAreas    := {GetArea()}
Local aSM0Dados := {}
Local aPosFil   := {}
Local aLatLong  := {}
Local oJSon     := {}
Local aViagens  := {}
Local aResumo   := {}
Local aCorPrg   := {{"blue"  ,"azul"   ,  0,  0,255,1},{"yellow","amarelo" ,255,255,  0,1},;
					{"orange","laranja",255,265,  0,1},{"pink"  ,"rosa"    ,255,192,203,1},;
					{"purple","roxo"   ,128,  0,128,1},{"cyan"  ,"ciano"   ,  0,255,255,1},;
					{"lime"  ,"lima"   ,  0,255,  0,1},{"gray"  ,"cinza"   ,128,128,128,1},;
					{"brown" ,"marrom" ,165, 42, 42,1},{"silver","prata"   ,192,192,192,1}}
Local aCorWay   := {{"green" ,"verde"  ,  0,128,  0,1},{"red"   ,"vermelho",255,  0,  0,1}}
Local nSeqPrg   := 0
Local nSeqWay   := 0
Local nSeqDoc   := 0
Local nSeqVga   := 0
Local nQtVgMp   := 10
Local nLinha    := 0
Local nCntFor1  := 0
Local nCntFor2  := 0
Local oColEnt   := TMSBCACOLENT():New("DNM")

If oColEnt:DbGetToken()
	DNM->(DbGoTo(oColEnt:config_recno))
	nQtVgMp := oColEnt:QtVgMap
EndIf

//-- Busca os dados da filial de origem da viagem
aSM0Dados := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt)
If Len(aSM0Dados) > 0
	aPosFil := HereBscLoc("SM0",cEmpAnt + cFilAnt,AllTrim(aSM0Dados[Ascan(aSM0Dados,{|x| x[1] == "M0_ENDENT" })][2]),;
												  Alltrim(aSM0Dados[Ascan(aSM0Dados,{|x| x[1] == "M0_BAIRENT"})][2]),;
												  AllTrim(aSM0Dados[Ascan(aSM0Dados,{|x| x[1] == "M0_CIDENT" })][2]),;
												  AllTrim(aSM0Dados[Ascan(aSM0Dados,{|x| x[1] == "M0_ESTENT" })][2]),;
												  Alltrim(aSM0Dados[Ascan(aSM0Dados,{|x| x[1] == "M0_CEPENT" })][2]),;
												  "BRASIL")
	cAliasDF8 := GetNextAlias()
	cQuery := "SELECT DF8_FILORI,DF8_NUMPRG,DF8_SEQPRG,DF8_VIAGEM,"
	cQuery += "       DD9_ITEM  ,DD9_FILDOC,DD9_DOC   ,DD9_SERIE ,"
	cQuery += "       DT6_DOCTMS,DT6_QTDVOL,DT6_PESO  ,DT6_PESOM3,DT6_METRO3,DT6_VALMER,DT6_CLIDES,DT6_LOJDES,"
	cQuery += "       DDZ_CODVEI "

	cQuery += "  FROM " + RetSqlName("DF8") + " DF8 "

	cQuery += "  JOIN " + RetSqlName("DD9") + " DD9 "
	cQuery += "    ON DD9_FILIAL = '" + xFilial("DD9") + "' "
	cQuery += "   AND DD9_FILORI = DF8_FILORI "
	cQuery += "   AND DD9_NUMPRG = DF8_NUMPRG "
	cQuery += "   AND DD9_SEQPRG = DF8_SEQPRG "
	cQuery += "   AND DD9.D_E_L_E_T_ = ' ' "

	cQuery += "  JOIN " + RetSqlName("DT6") + " DT6 "
	cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
	cQuery += "   AND DT6_FILDOC = DD9_FILDOC "
	cQuery += "   AND DT6_DOC    = DD9_DOC "
	cQuery += "   AND DT6_SERIE  = DD9_SERIE "
	cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "

	cQuery += "  JOIN " + RetSqlName("DDZ") + " DDZ "
	cQuery += "    ON DDZ_FILIAL = '" + xFilial("DDZ") + "' "
	cQuery += "   AND DDZ_FILORI = DF8_FILORI "
	cQuery += "   AND DDZ_NUMPRG = DF8_NUMPRG "
	cQuery += "   AND DDZ_SEQPRG = DF8_SEQPRG "
	cQuery += "   AND DDZ.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE DF8_FILIAL = '" + xFilial("DF8") + "' "
	cQuery += "   AND DF8_MARK   = '" + cMark + "' "
	cQuery += "   AND DF8.D_E_L_E_T_ = ' ' "

	cQuery += " ORDER BY DF8_FILORI,DF8_NUMPRG,DF8_SEQPRG,DD9_ITEM"
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDF8,.F.,.T.)		

	TCSetField(cAliasDF8,"QTDVOL","N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])
	TCSetField(cAliasDF8,"PESO"  ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
	TCSetField(cAliasDF8,"PESOM3","N",TamSx3("DT6_PESOM3")[1],TamSx3("DT6_PESOM3")[2])
	TCSetField(cAliasDF8,"METRO3","N",TamSx3("DT6_METRO3")[1],TamSx3("DT6_METRO3")[2])
	TCSetField(cAliasDF8,"VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])

	oJSon := JsonObject():New()
	oJSon["Protheus"] := JsonObject():New()
	oJSon["Protheus"]["Prog"] := {}

	If (cAliasDF8)->(Eof())
		nSeqPrg ++
		Aadd(oJSon["Protheus"]["Prog"],JsonObject():New())
		oJSon["Protheus"]["Prog"][nSeqPrg]["LatitFil"]  := Val(aPosFil[1])
		oJSon["Protheus"]["Prog"][nSeqPrg]["LongitFil"] := Val(aPosFil[2])
	Else
		While (cAliasDF8)->(!Eof())
			nSeqPrg ++
			If nSeqPrg <= nQtVgMp
				Aadd(oJSon["Protheus"]["Prog"],JsonObject():New())
				oJSon["Protheus"]["Prog"][nSeqPrg]["LatitFil"]     := Val(aPosFil[1])
				oJSon["Protheus"]["Prog"][nSeqPrg]["LongitFil"]    := Val(aPosFil[2])
				oJSon["Protheus"]["Prog"][nSeqPrg]["FilOri"]       := (cAliasDF8)->DF8_FILORI
				oJSon["Protheus"]["Prog"][nSeqPrg]["NumProg"]      := (cAliasDF8)->DF8_NUMPRG
				oJSon["Protheus"]["Prog"][nSeqPrg]["Roteiro"]      := ""
				oJSon["Protheus"]["Prog"][nSeqPrg]["ParRoteiro"]   := ""
				oJSon["Protheus"]["Prog"][nSeqPrg]["RotWayPoints"] := ""
				oJSon["Protheus"]["Prog"][nSeqPrg]["LinRota"]      := ""
				oJSon["Protheus"]["Prog"][nSeqPrg]["LatOrigem"]    := Val(aPosFil[1])
				oJSon["Protheus"]["Prog"][nSeqPrg]["LongOrigem"]   := Val(aPosFil[2])
				oJSon["Protheus"]["Prog"][nSeqPrg]["NomeOrigem"]   := (cAliasDF8)->DF8_NUMPRG
				oJSon["Protheus"]["Prog"][nSeqPrg]["CorOrigem"]    := "rgba(" + AllTrim(Str(aCorWay[2,3])) + "," + ;
																				AllTrim(Str(aCorWay[2,4])) + "," + ;
																				AllTrim(Str(aCorWay[2,5])) + "," + ;
																				AllTrim(Str(aCorWay[2,6])) + ")"
				oJSon["Protheus"]["Prog"][nSeqPrg]["LatDestino"]   := Val(aPosFil[1])
				oJSon["Protheus"]["Prog"][nSeqPrg]["LongDestino"]  := Val(aPosFil[2])
				oJSon["Protheus"]["Prog"][nSeqPrg]["NomeDestino"]  := (cAliasDF8)->DF8_NUMPRG
				oJSon["Protheus"]["Prog"][nSeqPrg]["CorDestino"]   := "rgba(" + AllTrim(Str(aCorWay[2,3])) + "," + ;
																				AllTrim(Str(aCorWay[2,4])) + "," + ;
																				AllTrim(Str(aCorWay[2,5])) + "," + ;
																				AllTrim(Str(aCorWay[2,6])) + ")"
	
				oJSon["Protheus"]["Prog"][nSeqPrg]["CorLinha"]     := "rgba(" + AllTrim(Str(aCorWay[2,3])) + "," + ;
																				AllTrim(Str(aCorWay[2,4])) + "," + ;
																				AllTrim(Str(aCorWay[2,5])) + "," + ;
																				AllTrim(Str(aCorWay[2,6])) + ")"
				oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"]     := {}
	
				//-- Inicializa/acumula os totais do ponto de origem
				If (nLinha := Ascan(aResumo,{|x| x[TR_LATIT] == Val(aPosFil[1]) .And. x[TR_LONGIT] == Val(aPosFil[2])})) == 0
					Aadd(aResumo,Array(TR_QTDCOL))
					aResumo[Len(aResumo),TR_LATIT]  := Val(aPosFil[1])
					aResumo[Len(aResumo),TR_LONGIT] := Val(aPosFil[2])
					aResumo[Len(aResumo),TR_QTDPRG] := 1
					aResumo[Len(aResumo),TR_QTDDOC] := 0
					aResumo[Len(aResumo),TR_QTDVOL] := 0
					aResumo[Len(aResumo),TR_PESO]   := 0
					aResumo[Len(aResumo),TR_PESOM3] := 0
					aResumo[Len(aResumo),TR_METRO3] := 0
					aResumo[Len(aResumo),TR_VALMER] := 0
				Else
					aResumo[nLinha,TR_QTDPRG] ++
				EndIf
	
				//-- Inicializa as programações do ponto de origem
				If Ascan(aViagens,{|x| x[PW_LATIT]  == Val(aPosFil[1])         .And. x[PW_LONGIT] == Val(aPosFil[2]) .And. ;
									   x[PW_FILORI] == (cAliasDF8)->DF8_FILORI .And. x[PW_NUMPRG] == (cAliasDF8)->DF8_NUMPRG .And. ;
									   x[PW_SEQPRG] == (cAliasDF8)->DF8_SEQPRG .And. x[PW_VIAGEM] == (cAliasDF8)->DF8_VIAGEM}) == 0
					Aadd(aViagens,Array(PW_QTDCOL))
					aViagens[Len(aViagens),PW_LATIT]  := Val(aPosFil[1])
					aViagens[Len(aViagens),PW_LONGIT] := Val(aPosFil[2])
					aViagens[Len(aViagens),PW_FILORI] := (cAliasDF8)->DF8_FILORI
					aViagens[Len(aViagens),PW_NUMPRG] := (cAliasDF8)->DF8_NUMPRG
					aViagens[Len(aViagens),PW_SEQPRG] := (cAliasDF8)->DF8_SEQPRG
					aViagens[Len(aViagens),PW_VIAGEM] := (cAliasDF8)->DF8_VIAGEM
					aViagens[Len(aViagens),PW_DATPRV] := CToD("")
					aViagens[Len(aViagens),PW_HORPRV] := "0000"
					aViagens[Len(aViagens),PW_QTDDOC] := 0
					aViagens[Len(aViagens),PW_QTDVOL] := 0
					aViagens[Len(aViagens),PW_PESO]   := 0
					aViagens[Len(aViagens),PW_PESOM3] := 0
					aViagens[Len(aViagens),PW_METRO3] := 0
					aViagens[Len(aViagens),PW_VALMER] := 0
				EndIf
				
				nSeqWay := 0
				cPrgAnt := (cAliasDF8)->(DF8_FILORI + DF8_NUMPRG + DF8_SEQPRG)
				While (cAliasDF8)->(!Eof()) .And. (cAliasDF8)->(DF8_FILORI + DF8_NUMPRG + DF8_SEQPRG) == cPrgAnt
					aLatLong := AtuLatLong((cAliasDF8)->DD9_FILDOC,(cAliasDF8)->DD9_DOC,(cAliasDF8)->DD9_SERIE,,,(cAliasDF8)->DT6_DOCTMS)
					nSeqWay ++
					Aadd(oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"],JSonObject():New())
					oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Latitude"]  := Val(aLatLong[1])
					oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Longitude"] := Val(aLatLong[2])
					oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Nome"]      := (cAliasDF8)->DF8_NUMPRG + StrZero(nSeqWay,4)
					//-- Busca apontamento da DTW
					DTW->(DbSetOrder(8))
					If DTW->(DbSeek(xFilial("DTW") + (cAliasDF8)->DF8_FILORI + (cAliasDF8)->DF8_VIAGEM + (cAliasDF8)->DT6_CLIDES + ;
													 (cAliasDF8)->DT6_LOJDES)) .And. !Empty(DTW->DTW_DATREA)
						oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Cor"]   := "rgba(" + AllTrim(Str(aCorWay[1,3])) + "," + ;
										 															  AllTrim(Str(aCorWay[1,4])) + "," + ;
																									  AllTrim(Str(aCorWay[1,5])) + "," + ;
																									  AllTrim(Str(aCorWay[1,6])) + ")"
					Else
						oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Cor"]   := "rgba(" + AllTrim(Str(aCorWay[2,3])) + "," + ;
										 															  AllTrim(Str(aCorWay[2,4])) + "," + ;
																									  AllTrim(Str(aCorWay[2,5])) + "," + ;
																									  AllTrim(Str(aCorWay[2,6])) + ")"
					EndIf
					oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Documento"] := {}
	
					//-- Inicializa/acumula os totais do waypoint
					If (nLinha := Ascan(aResumo,{|x| x[TR_LATIT] == Val(aLatLong[1]) .And. x[TR_LONGIT] == Val(aLatLong[2])})) == 0
						Aadd(aResumo,Array(TR_QTDCOL))
						aResumo[Len(aResumo),TR_LATIT]  := Val(aLatLong[1])
						aResumo[Len(aResumo),TR_LONGIT] := Val(aLatLong[2])
						aResumo[Len(aResumo),TR_QTDPRG] := 1
						aResumo[Len(aResumo),TR_QTDDOC] := 0
						aResumo[Len(aResumo),TR_QTDVOL] := 0
						aResumo[Len(aResumo),TR_PESO]   := 0
						aResumo[Len(aResumo),TR_PESOM3] := 0
						aResumo[Len(aResumo),TR_METRO3] := 0
						aResumo[Len(aResumo),TR_VALMER] := 0
					Else
						aResumo[nLinha,TR_QTDPRG] ++
					EndIf

					//-- Inicializa as programações do waypoint
					If (nLinha := Ascan(aViagens,{|x| x[PW_LATIT] == Val(aLatLong[1]) .And. x[PW_LONGIT] == Val(aLatLong[2]) .And. ;
													  x[PW_FILORI] == (cAliasDF8)->DF8_FILORI .And. x[PW_NUMPRG] == (cAliasDF8)->DF8_NUMPRG .And. ;
													  x[PW_VIAGEM] == (cAliasDF8)->DF8_VIAGEM})) == 0
						Aadd(aViagens,Array(PW_QTDCOL))
						aViagens[Len(aViagens),PW_LATIT]  := Val(aLatLong[1])
						aViagens[Len(aViagens),PW_LONGIT] := Val(aLatLong[2])
						aViagens[Len(aViagens),PW_FILORI] := (cAliasDF8)->DF8_FILORI
						aViagens[Len(aViagens),PW_NUMPRG] := (cAliasDF8)->DF8_NUMPRG
						aViagens[Len(aViagens),PW_SEQPRG] := (cAliasDF8)->DF8_SEQPRG
						aViagens[Len(aViagens),PW_VIAGEM] := (cAliasDF8)->DF8_VIAGEM
						aViagens[Len(aViagens),PW_DATPRV] := CToD("")
						aViagens[Len(aViagens),PW_HORPRV] := "0000"
						aViagens[Len(aViagens),PW_QTDDOC] := 0
						aViagens[Len(aViagens),PW_QTDVOL] := 0
						aViagens[Len(aViagens),PW_PESO]   := 0
						aViagens[Len(aViagens),PW_PESOM3] := 0
						aViagens[Len(aViagens),PW_METRO3] := 0
						aViagens[Len(aViagens),PW_VALMER] := 0
					EndIf
				
					nSeqDoc := 0
					cWayAnt := cPrgAnt + AllTrim(aLatLong[1]) + AllTrim(aLatLong[2])
					While (cAliasDF8)->(!Eof()) .And. (cAliasDF8)->(DF8_FILORI + DF8_NUMPRG + DF8_SEQPRG) + AllTrim(aLatLong[1]) + AllTrim(aLatLong[2]) == cWayAnt
						nSeqDoc ++
						Aadd(oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Documento"],JSonObject():New())
						oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Documento"][nSeqDoc]["FilialDocumento"] := (cAliasDF8)->DD9_FILDOC
						oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Documento"][nSeqDoc]["NumDocumento"]    := (cAliasDF8)->DD9_DOC
						oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Documento"][nSeqDoc]["SerieDocumento"]  := (cAliasDF8)->DD9_SERIE
						oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Documento"][nSeqDoc]["QtdeVolumes"]     := (cAliasDF8)->DT6_QTDVOL
						oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Documento"][nSeqDoc]["PesoReal"]        := (cAliasDF8)->DT6_PESO
						oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Documento"][nSeqDoc]["PesoCubado"]      := (cAliasDF8)->DT6_PESOM3
						oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Documento"][nSeqDoc]["Metragem3"]       := (cAliasDF8)->DT6_METRO3
						oJSon["Protheus"]["Prog"][nSeqPrg]["WayPoint"][nSeqWay]["Documento"][nSeqDoc]["ValMercadoria"]   := (cAliasDF8)->DT6_VALMER
	
						//-- Acumula os totais do waypoint
						If (nLinha := Ascan(aResumo,{|x| x[TR_LATIT] == Val(aLatLong[1]) .And. x[TR_LONGIT] == Val(aLatLong[2])})) > 0
							aResumo[nLinha,TR_QTDDOC] ++
							aResumo[nLinha,TR_QTDVOL] += (cAliasDF8)->DT6_QTDVOL
							aResumo[nLinha,TR_PESO]   += (cAliasDF8)->DT6_PESO
							aResumo[nLinha,TR_PESOM3] += (cAliasDF8)->DT6_PESOM3
							aResumo[nLinha,TR_METRO3] += (cAliasDF8)->DT6_METRO3
							aResumo[nLinha,TR_VALMER] += (cAliasDF8)->DT6_VALMER
						EndIf
	
						//-- Acumula as programações do waypoint
						If (nLinha := Ascan(aViagens,{|x| x[PW_LATIT] == Val(aLatLong[1]) .And. x[PW_LONGIT] == Val(aLatLong[2]) .And. ;
														  x[PW_FILORI] == (cAliasDF8)->DF8_FILORI .And. x[PW_NUMPRG] == (cAliasDF8)->DF8_NUMPRG .And. ;
														  x[PW_VIAGEM] == (cAliasDF8)->DF8_VIAGEM})) > 0
							aViagens[nLinha,PW_QTDDOC] ++
							aViagens[nLinha,PW_QTDVOL] += (cAliasDF8)->DT6_QTDVOL
							aViagens[nLinha,PW_PESO]   += (cAliasDF8)->DT6_PESO
							aViagens[nLinha,PW_PESOM3] += (cAliasDF8)->DT6_PESOM3
							aViagens[nLinha,PW_METRO3] += (cAliasDF8)->DT6_METRO3
							aViagens[nLinha,PW_VALMER] += (cAliasDF8)->DT6_VALMER
						EndIf
					
						//-- Acumula os totais do ponto de origem
						If (nLinha := Ascan(aResumo,{|x| x[TR_LATIT] == Val(aPosFil[1]) .And. x[TR_LONGIT] == Val(aPosFil[2])})) > 0
							aResumo[nLinha,TR_QTDDOC] ++
							aResumo[nLinha,TR_QTDVOL] += (cAliasDF8)->DT6_QTDVOL
							aResumo[nLinha,TR_PESO]   += (cAliasDF8)->DT6_PESO
							aResumo[nLinha,TR_PESOM3] += (cAliasDF8)->DT6_PESOM3
							aResumo[nLinha,TR_METRO3] += (cAliasDF8)->DT6_METRO3
							aResumo[nLinha,TR_VALMER] += (cAliasDF8)->DT6_VALMER
						EndIf
	
						//-- Acumula as programações do ponto de origem
						If (nLinha := Ascan(aViagens,{|x| x[PW_LATIT] == Val(aPosFil[1]) .And. x[PW_LONGIT] == Val(aPosFil[2]) .And. ;
														  x[PW_FILORI] == (cAliasDF8)->DF8_FILORI .And. x[PW_NUMPRG] == (cAliasDF8)->DF8_NUMPRG .And. ;
														  x[PW_VIAGEM] == (cAliasDF8)->DF8_VIAGEM})) > 0
							aViagens[nLinha,PW_QTDDOC] ++
							aViagens[nLinha,PW_QTDVOL] += (cAliasDF8)->DT6_QTDVOL
							aViagens[nLinha,PW_PESO]   += (cAliasDF8)->DT6_PESO
							aViagens[nLinha,PW_PESOM3] += (cAliasDF8)->DT6_PESOM3
							aViagens[nLinha,PW_METRO3] += (cAliasDF8)->DT6_METRO3
							aViagens[nLinha,PW_VALMER] += (cAliasDF8)->DT6_VALMER
						EndIf
						
						(cAliasDF8)->(DbSkip())
						aLatLong := AtuLatLong((cAliasDF8)->DD9_FILDOC,(cAliasDF8)->DD9_DOC,(cAliasDF8)->DD9_SERIE,,,(cAliasDF8)->DT6_DOCTMS)
					EndDo
				EndDo
			Else
				Exit	
			EndIf
		EndDo
	EndIf
(cAliasDF8)->(DbCloseArea())
EndIf

If !Empty(aResumo)
	oJSon["Protheus"]["Resumo"] := {}
	For nCntFor1 := 1 To Len(aResumo)
		Aadd(oJSon["Protheus"]["Resumo"],JsonObject():New())
		cTexto := "<h1>Totais do Ponto</h1>"
		cTexto += "<p>"
		cTexto += "Programações : " + Transform(aResumo[nCntFor1,TR_QTDPRG],PesqPict("DEF","DEF_QTDVOL"))
		cTexto += "<br>"
		cTexto += "Documentos : " + Transform(aResumo[nCntFor1,TR_QTDDOC],PesqPict("DEF","DEF_QTDVOL"))
		cTexto += "<br>"
		cTexto += "Volumes : " + Transform(aResumo[nCntFor1,TR_QTDVOL],PesqPict("DT6","DT6_QTDVOL"))
		cTexto += "<br>"
		cTexto += "Peso Real : " + Transform(aResumo[nCntFor1,TR_PESO]  ,PesqPict("DT6","DT6_PESO"))
		cTexto += "<br>"
		cTexto += "Peso Cubado : " + Transform(aResumo[nCntFor1,TR_PESOM3],PesqPict("DT6","DT6_PESOM3"))
		cTexto += "<br>"
		cTexto += "Metragem Cúbica : " + Transform(aResumo[nCntFor1,TR_METRO3],PesqPict("DT6","DT6_METRO3"))
		cTexto += "<br>"
		cTexto += "Valor da Mercadoria : " + Transform(aResumo[nCntFor1,TR_VALMER],PesqPict("DT6","DT6_VALMER"))
		cTexto += "</p>"
		oJSon["Protheus"]["Resumo"][nCntFor1]["ResLigado"] := 0
		oJSon["Protheus"]["Resumo"][nCntFor1]["Latitude"]  := aResumo[nCntFor1,TR_LATIT]
		oJSon["Protheus"]["Resumo"][nCntFor1]["Longitude"] := aResumo[nCntFor1,TR_LONGIT]
		oJSon["Protheus"]["Resumo"][nCntFor1]["Detalhes"]  := cTexto
	Next nCntFor1
EndIf

aSort(aViagens,,,{|x,y| AllTrim(Str(x[PW_LATIT])) + AllTrim(Str(x[PW_LONGIT])) + x[PW_FILORI] + x[PW_NUMPRG] + x[PW_VIAGEM] < ;
						AllTrim(Str(y[PW_LATIT])) + AllTrim(Str(y[PW_LONGIT])) + y[PW_FILORI] + y[PW_NUMPRG] + y[PW_VIAGEM]})	//-- Ordena pela latitude e longitude

If !Empty(aViagens)
	oJSon["Protheus"]["Viagens"] := {}
	For nCntFor1 := 1 To Len(aViagens)
		//-- Na quebra de latitude e longitude desenhar o cabeçalho
		If cPosAnt != AllTrim(Str(aViagens[nCntFor1,PW_LATIT])) + AllTrim(Str(aViagens[nCntFor1,PW_LONGIT]))
			nSeqVga ++
			Aadd(oJSon["Protheus"]["Viagens"],JsonObject():New())
			cPosAnt := AllTrim(Str(aViagens[nCntFor1,PW_LATIT])) + AllTrim(Str(aViagens[nCntFor1,PW_LONGIT]))
			cTexto := "<table>"
			cTexto += "<caption>"
			cTexto += "<h1>Viagens do Ponto</h1>"
			cTexto += "</caption>"
			If !Empty(aTitCols)
				cTexto += "<tr>"
				For nCntFor2 := 1 To Len(aTitCols)
					cTexto += "<th>" + aTitCols[nCntFor2,1] + "</th>"
				Next nCntFor2
				cTexto += "</tr>"
			EndIf
		EndIf
		cTexto += "<tr>"
			cTexto += "<td>" + aViagens[nCntFor1,PW_FILORI] + "</td>
			cTexto += "<td>" + aViagens[nCntFor1,PW_NUMPRG] + "</td>
			cTexto += "<td>" + aViagens[nCntFor1,PW_VIAGEM] + "</td>
			cTexto += "<td>" + DToC(aViagens[nCntFor1,PW_DATPRV]) + "</td>
			cTexto += "<td>" + SubStr(aViagens[nCntFor1,PW_HORPRV],1,2) + ":" + SubStr(aViagens[nCntFor1,PW_HORPRV],3,2) + "</td>
			cTexto += "<td>" + Transform(aViagens[nCntFor1,PW_QTDDOC],PesqPict("DEF","DEF_QTDVOL")) + "</td>
			cTexto += "<td>" + Transform(aViagens[nCntFor1,PW_QTDVOL],PesqPict("DEF","DEF_QTDVOL")) + "</td>
			cTexto += "<td>" + Transform(aViagens[nCntFor1,PW_PESO],PesqPict("DT6","DT6_PESO")) + "</td>
			cTexto += "<td>" + Transform(aViagens[nCntFor1,PW_PESOM3],PesqPict("DT6","DT6_PESOM3")) + "</td>
			cTexto += "<td>" + Transform(aViagens[nCntFor1,PW_METRO3],PesqPict("DT6","DT6_METRO3")) + "</td>
			cTexto += "<td>" + Transform(aViagens[nCntFor1,PW_VALMER],PesqPict("DT6","DT6_VALMER")) + "</td>
		cTexto += "</tr>"

		//-- Se for quebrar a latitude e longitude, ou no final do vetor, encerrar a tabela
		If (nCntFor1 + 1) > Len(aViagens) .Or. cPosAnt != AllTrim(Str(aViagens[(nCntFor1 + 1),PW_LATIT])) + AllTrim(Str(aViagens[(nCntFor1 + 1),PW_LONGIT]))
			cTexto += "</table>"
			oJSon["Protheus"]["Viagens"][nSeqVga]["VgeLigado"] := 0
			oJSon["Protheus"]["Viagens"][nSeqVga]["Latitude"]  := aViagens[nCntFor1,PW_LATIT]
			oJSon["Protheus"]["Viagens"][nSeqVga]["Longitude"] := aViagens[nCntFor1,PW_LONGIT]
			oJSon["Protheus"]["Viagens"][nSeqVga]["Detalhes"]  := cTexto
		EndIf
	Next nCntFor1
EndIf

cJson := oJSon:GetJsonText("Protheus")
oWebChannel:advplToJs("initMap",cJson)

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return
