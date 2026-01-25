#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONA480A.CH"

/*/{Protheus.doc} PONA480A
Rotina de Scheduler para buscar os dados do Dashboard RH e enviar e-mail.
@author Marco Nakazawa
@since 28/07/2022
@Type Function
/*/
Function PONA480A(lDashBoard,oResp)
Local oClient
Local oJsonFunc		:= JsonObject():New()
Local oJsonClkIn	:= JsonObject():New()
Local oJsonGst		:= JsonObject():New()
Local oJsonSchd		:= JsonObject():New()
Local oGrpInPon		:= JsonObject():New()
Local oGrpInClk		:= JsonObject():New()
Local oGrpIndic		:= JsonObject():New()
Local oIndTotal		:= JsonObject():New()
Local oIndAccomp	:= JsonObject():New()
Local oIndAttent	:= JsonObject():New()
Local oIndCritic	:= JsonObject():New()
Local dData			:= Date()
Local cDia			:= Day2Str(dData)
Local cMes			:= Month2Str(dData)
Local cAno			:= Year2Str(dData)
Local cPerg 		:= "PNA480A"
Local cPergNova		:= "PNA480AN"
Local lExistPerg 	:= fExistPerg(cPerg)
Local lExstPergN 	:= fExistPerg(cPergNova)
Local cLogPatch		:= GetSrvProfString("Startpath","")
Local cURLRest		:= SuperGetMV("MV_PONREST",.F.,"") 
Local cGpeMail		:= SuperGetMV("MV_GPEMAIL",.F.,"")
Local cRelausr		:= SuperGetMV("MV_RELAUSR",.F.,"")
Local cBody			:= ""
Local cFilBody		:= ""
Local cDataIni		:= ""
Local cDataFim		:= ""
Local cDtIniFilt	:= ""
Local cDtFimFilt	:= ""
Local cFilFilt		:= ""
Local cFilHtml		:= ""
Local cHtml			:= ""
Local cMsg			:= ""
Local cDtHrAtual	:= ""
Local cEmail		:= ""
Local cEmailGstr	:= ""
Local cNi			:= ""
Local cFiltroBet	:= ""
Local cFiltroIn		:= ""
Local cFiltroGst	:= ""
Local cFilFormtG	:= ""
Local cGestor		:= ""
Local cApiGst		:= "/api/rh/v1/DbHrManagers"
Local cHoraAtual	:= Time()
Local aURLApi		:= {"/api/rh/v1/DbHrAttendanceControl","/api/rh/v1/DbHrClockin"}
Local cAuthWS		:= SuperGetMV("MV_AUTHWS",.F.,"")
Local aHeader		:= {}
Local aFiliais		:= {}
Local aGetFil 		:= {} 
Local aFrmtDados	:= {}
Local aExcel		:= {}
Local aFuncDados	:= {}
Local aData			:= {}
Local lSchedule		:= IsBlind()
Local lRet			:= .T.
Local nI			:= 0
Local nPeriodo		:= 0
Local nQtdDias		:= 0
Local nLenResp		:= 0
Local nDiasSem		:= Dow(Date())

Default lDashBoard	:= .F.
Default oResp		:= Nil

If (lExistPerg .And. !Empty(cURLRest) .And. lSchedule .And. (!Empty(cGpeMail) .Or. !Empty(cRelausr))) .Or. (lDashBoard .And. oResp <> Nil)
	If !Empty(cGpeMail)
		cEmail := cGpeMail
	Else
		cEmail := cRelausr
	EndIf

	If !lDashBoard
		If lExstPergN
			MakeAdvplExpr(cPergNova)
		EndIf
		// Parâmetros preenchidos
		cFilFilt 	:= mv_par01
		nPeriodo	:= mv_par02
		nQtdDias	:= mv_par03
		If (ValType(mv_par04) == "C" .And. !Empty(mv_par04), cFiltroGst := AllTrim(mv_par04), cFiltroGst := "todos")
		
		// Data que foi gerado o Dashboard
		cDtHrAtual := SubStr(cHoraAtual,1,5) + " (" + cDia + "/" + cMes + "/" + cAno + ")"

		// Validação do pergunte antigo
		If !lExstPergN .And. lExistPerg .And. !Empty(cFilFilt)
			aAdd(aFiliais,cFilFilt)
		ElseIf lExstPergN
			// Formatação das Filiais que serão enviadas para as APIs
			If At("$",cFilFilt) > 0
				cFiltroIn	:= SubStr(cFilFilt, At("$",cFilFilt) + 2)
				cFiltroIn	:= StrTran(cFiltroIn,")","")
				cFiltroIn	:= StrTran(cFiltroIn,"'","")
				aFiliais	:= StrTokArr2(cFiltroIn,",")
			EndIf

			If At(">=",cFilFilt) > 0
				cFiltroBet := StrTran(cFilFilt, "RA_FILIAL","aGetFil[nI,1]")
				cFiltroBet := SubStr(cFiltroBet, At("aGetFil",cFiltroBet), At(")",cFiltroBet) - At("aGetFil",cFiltroBet))
				
				aGetFil := GetFilRecnos(cEmpAnt , Space(FWGETTAMFILIAL), Replicate("Z", FWGETTAMFILIAL))	

				For nI := 1 To Len(aGetFil)
					If &(cFiltroBet)
						aAdd(aFiliais,aGetFil[nI,1])
					EndIf
				Next
			EndIf
		EndIf

		If !Empty(aFiliais)
			aFiliais := aSort(aFiliais)
		EndIf

		If Empty(aFiliais)
			cFilFilt := "todas"
			cFilHtml := "Todas"
			aAdd(aFiliais,cFilFilt)
		Else
			If Len(aFiliais) > 2
				cFilHtml := aFiliais[1] + " " + aFiliais[2] + " +" + cValToChar(Len(aFiliais) - 2)
			ElseIf Len(aFiliais) ==  2
				cFilHtml := aFiliais[1] + " " + aFiliais[2]
			Else
				cFilHtml := aFiliais[1]
			EndIf

			cFilHtml := StrTran(cFilHtml," ","&nbsp;")
		EndIf
		
		// Formatação das Datas que será utilizada no filtro
		If nPeriodo == 1 // Mensal
			cDataIni	:= "01/" + cMes + "/" + cAno
			cDataFim	:= cDia + "/" + cMes + "/" + cAno
			cDtIniFilt	:= cAno + "-" + cMes + "-01"
			cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia
		ElseIf nPeriodo == 2 // Semanal
			cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia
			cDataFim	:= cDia + "/" + cMes + "/" + cAno

			If nDiasSem <> 2
				If nDiasSem == 1
					dData := dData - 6
				Else
					dData := dData - (nDiasSem - 2)
				EndIf

				cDia		:= Day2Str(dData)
				cMes		:= Month2Str(dData)
				cAno		:= Year2Str(dData)
				cDataIni	:= cDia + "/" + cMes + "/" + cAno
				cDtIniFilt	:= cAno + "-" + cMes + "-" + cDia
			Else
				cDataIni	:= cDia + "/" + cMes + "/" + cAno
				cDtIniFilt	:= cAno + "-" + cMes + "-" + cDia
			Endif
		ElseIf nPeriodo == 3 // Quinzenal
			If Val(Day2Str(cDia)) > 15
				cDataIni	:= "16/" + cMes + "/" + cAno
				cDataFim	:= cDia + "/" + cMes + "/" + cAno
				cDtIniFilt	:= cAno + "-" + cMes + "-" + "16"
				cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia
			Else
				cDataIni	:= "01/" + cMes + "/" + cAno
				cDataFim	:= cDia + "/" + cMes + "/" + cAno
				cDtIniFilt	:= cAno + "-" + cMes + "-" + "01"
				cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia
			EndIf
		ElseIf nPeriodo == 4 // Qtde Dias
			cDataFim	:= cDia + "/" + cMes + "/" + cAno
			cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia

			If nQtdDias > 60
				nQtdDias := 60
			EndIf

			dData	:= DaySub(dData,nQtdDias)
			cDia	:= Day2Str(dData)
			cMes	:= Month2Str(dData)
			cAno	:= Year2Str(dData)

			cDataIni	:= cDia + "/" + cMes + "/" + cAno
			cDtIniFilt	:= cAno + "-" + cMes + "-" + cDia
		EndIf

		// Montagem do body da chamada das APIs
		cFilBody := ArrTokStr(aFiliais,'","') 

		BeginContent var cBody
			{
				"startDate":"%Exp:cDtIniFilt%",
				"endDate":"%Exp:cDtFimFilt%",
				"branches":["%Exp:cFilBody%"],
				"managers":["%Exp:cFiltroGst%"]
			}
		EndContent

		// Header da chamada das APIs
		aAdd(aHeader,"Accept: application/json")
		aAdd(aHeader,"content-type: application/json")
		aAdd(aHeader,"charset: UTF-8")
		
		// Autenticação para utilização das APIs
		If !Empty(cAuthWS)
			aAdd(aHeader,"Authorization: BASIC " + ENCODE64(rc4crypt( cAuthWS ,"AuthWS#ReceiptID", .F.,.T.)))
		EndIf

		// Configuração para consumir as APIs
		oClient := FwRest():New(cURLRest)
		For nI := 1 To Len(aURLApi)
			oClient:SetPath(aURLApi[nI])
			oClient:SetPostParams(cBody)
			If oClient:Post(aHeader)
				If "DbHrAttendanceControl" $ aURLApi[nI]
					oJsonFunc:fromJson(oClient:GetResult())
					nLenResp := Len(oJsonFunc:GetNames())
				ElseIf "DbHrClockin" $ aURLApi[nI]
					oJsonClkIn:fromJson(oClient:GetResult())
				EndIf
			ElseIf "Unauthorized" $ AllTrim(oClient:cInternalError)
				Conout(AnsiToOEM(STR0027)) //"A chave Security está ativada, porém o parâmetro MV_AUTHWS está com um conteúdo inválido. Por favor configure novamente o parâmetro acessando a rotina AUTHWSRH."
				Return
			Else
				Conout(AnsiToOEM(STR0028)) //"Erro na reposta da API. Verifique se o parâmetro MV_PONREST está configurado corretamente"
				Return
			EndIf
		Next

		// Verifica se deve gerar a coluna de gestor
		oClient:SetPath(cApiGst)
		If oClient:Get(aHeader)
			oJsonGst:fromJson(oClient:GetResult())
			If (Empty(oJsonGst["managers"]), oJsonSchd["managerIsEmpty"] := .T., oJsonSchd["managerIsEmpty"] := .F.)
		EndIf

		// Formatação das respostas das APIs para a montagem do HTML e Excel	
		oJsonSchd["lastUpdate"]		:= cDtHrAtual
		oJsonSchd["startDate"]		:= cDtIniFilt
		oJsonSchd["endDate"]		:= cDtFimFilt
		oJsonSchd["branches"]		:= aFiliais

		For nI := 1 To nLenResp
			cNi := cValToChar(nI)

			If cFiltroGst != "todos"
				cGestor		:= EncodeUTF8(SubStr(cFiltroGst, 1, At("(", cFiltroGst) - 1))
				cGestor		:= StrTran(cGestor," ","&nbsp;")
				cFilFormtG	:= SubStr(cFiltroGst, At("(", cFiltroGst) + 1)
				cFilFormtG	:= StrTran(cFilFormtG, ")", "")
				
				oJsonSchd["manager"]		:= cFilFormtG
				oJsonSchd["sendToManager"]	:= .T.
			Else
				cGestor						:= "Todos"
				oJsonSchd["manager"]		:= ""
				oJsonSchd["sendToManager"]	:= .F.
			EndIf

			oGrpInPon["indicatorGroup"]		:= EncodeUTF8("Indicadores de Funcionários - " + oJsonFunc[cNi,"branch"])
			oGrpInPon["manager"]			:= cFilFormtG

			oIndTotal["indicatorBranch"]	:= oJsonFunc[cNi,"branch"]
			oIndTotal["classTitle"]			:= "totalCard_title"
			oIndTotal["amount"]				:= oJsonFunc[cNi,"totalEmployees"]
			oIndTotal["details"]			:= oJsonFunc[cNi,"totalDetails"]
		
			oIndAccomp["indicatorBranch"]	:= oJsonFunc[cNi,"branch"]
			oIndAccomp["classTitle"]		:= "accomplishedCard_title"
			oIndAccomp["amount"]			:= oJsonFunc[cNi,"clockMarkingsComplete"]
			oIndAccomp["details"]			:= oJsonFunc[cNi,"completeDetails"]
		
			oIndAttent["indicatorBranch"]	:= oJsonFunc[cNi,"branch"]
			oIndAttent["classTitle"]		:= "attentionCard_title"
			oIndAttent["amount"]			:= oJsonFunc[cNi,"clockMarkingsIncomplete"]
			oIndAttent["details"]			:= oJsonFunc[cNi,"incompleteDetails"]
		
			oIndCritic["indicatorBranch"]	:= oJsonFunc[cNi,"branch"]
			oIndCritic["classTitle"]		:= "criticalCard_title"
			oIndCritic["amount"]			:= oJsonFunc[cNi,"withoutClockMarkings"]
			oIndCritic["details"]			:= oJsonFunc[cNi,"withoutDetails"]
			oGrpInPon["indicators"]			:= {oIndTotal, oIndAccomp, oIndAttent, oIndCritic}

			oIndTotal	:= JsonObject():New()
			oIndAccomp	:= JsonObject():New()
			oIndAttent	:= JsonObject():New()
			oIndCritic	:= JsonObject():New()

			oGrpInClk["indicatorGroup"]		:= EncodeUTF8("Indicadores de Marcações Clock In - " + oJsonFunc[cNi,"branch"])
			oGrpInClk["manager"]			:= cFilFormtG
		
			oIndTotal["indicatorBranch"]	:= oJsonClkIn[cNi,"branch"]
			oIndTotal["classTitle"]			:= "totalCard_title"
			oIndTotal["amount"]				:= oJsonClkIn[cNi,"totalClockMarkings"]
			oIndTotal["details"]			:= oJsonClkIn[cNi,"totalDetails"]

			oIndAccomp["indicatorBranch"]	:= oJsonClkIn[cNi,"branch"]
			oIndAccomp["classTitle"]		:= "accomplishedCard_title"
			oIndAccomp["amount"]			:= oJsonClkIn[cNi,"totalIntegrated"]
			oIndAccomp["details"]			:= oJsonClkIn[cNi,"integratedDetails"]
		
			oIndAttent["indicatorBranch"]	:= oJsonClkIn[cNi,"branch"]
			oIndAttent["classTitle"]		:= "attentionCard_title"
			oIndAttent["amount"]			:= oJsonClkIn[cNi,"totalToBeIntegrated"]
			oIndAttent["details"]			:= oJsonClkIn[cNi,"toBeIntegratedDetails"]

			oIndCritic["indicatorBranch"]	:= oJsonClkIn[cNi,"branch"]
			oIndCritic["classTitle"]		:= "criticalCard_title"
			oIndCritic["amount"]			:= oJsonClkIn[cNi,"totalWhitoutNSR"]
			oIndCritic["details"]			:= oJsonClkIn[cNi,"whitoutNsrDetails"]
		
			oGrpInClk["indicators"]			:= {oIndTotal, oIndAccomp, oIndAttent, oIndCritic}
			
			aAdd(aData, oGrpInPon)
			aAdd(aData, oGrpInClk)

			oIndTotal	:= JsonObject():New()
			oIndAccomp	:= JsonObject():New()
			oIndAttent	:= JsonObject():New()
			oIndCritic	:= JsonObject():New()
			oGrpInPon	:= JsonObject():New()
			oGrpInClk	:= JsonObject():New()
		Next

		oGrpIndic["manager"]		:= cFilFormtG
		oGrpIndic["grpIndicators"]	:= aData

		oJsonSchd['data']		:= oGrpIndic

		aFrmtDados := fFormtDads(oJsonSchd["lastUpdate"], oJsonSchd["startDate"], oJsonSchd["endDate"], oJsonSchd["branches"])
		
		If oJsonSchd["sendToManager"] 
			aFuncDados := StrTokArr(oJsonSchd["manager"], "-")
			
			cEmailGstr := ""
			cEmailGstr := fEmailGstr(AllTrim(aFuncDados[1]), AllTrim(aFuncDados[2]))

			If !Empty(cEmailGstr)
				cEmailGstr := cEmail + ";" + cEmailGstr
			Else
				Conout(STR0056 + " " + aFuncDados[1] + " " + STR0057 + " " + AllTrim(aFuncDados[2])) // E-mail do gestor nao encontrado. Verfique o cadastro do funcionario da Filial: Matricula:
				Conout("Enviado e-mail apenas para " + cEmail)
				cEmailGstr := cEmail
			EndIf
		Else
			cEmailGstr := cEmail
		EndIf

		// Criação do HTML
		cHtml := ""
		cHtml := fGeraHMTL(oJsonSchd["data", "grpIndicators"], aFrmtDados[1,1], aFrmtDados[1,2], aFrmtDados[1,3], aFrmtDados[1,4], cGestor)

		// Criação o arquivo HTML
		nHandle := fcreate(cLogPatch + "dashboard_rh.html")
		FWrite(nHandle, cHtml)
		fclose(nHandle)

		cMsg := STR0017 + aFrmtDados[1,5] + STR0018 + aFrmtDados[1,6] + "."

		// Criação do Excel
		aExcel := fExcelDash(oJsonSchd["data", "grpIndicators"], !oJsonSchd["managerIsEmpty"] ,.F.)

		// Envio do E-mail
		If gpeMail("Dashboard",cMsg,cEmailGstr,{cLogPatch + "dashboard_rh.html", aExcel[1,3]})
			Conout(AnsiToOEM(STR0025)) // "E-mail com os dados do Dashboard RH foi enviado com sucesso."
			lRet := .F.
		Else
			Conout(AnsiToOEM(STR0026)) // "Falha no envio do e-mail com os dados do Dashboard RH. Verifique as configurações para o envio do e-mail."
			lRet := .F.
		EndIf

		FErase(cLogPatch + "dashboard_rh.html")
		FErase(aExcel[1,3])
	Else	
		aFrmtDados := fFormtDads(oResp["lastUpdate"], oResp["startDate"], oResp["endDate"], oResp["branches"])

		For nI := 1 To Len(oResp["data"])
			If oResp["sendToManager"]
				cFiltroGst	:= SubStr(oResp["data", nI, "manager"], At("(", oResp["data", nI, "manager"]) + 1)
				cFiltroGst	:= StrTran(cFiltroGst, ")", "")

				aFuncDados := {}
				aFuncDados := StrTokArr(cFiltroGst, "-")

				cEmailGstr := ""
				cEmailGstr := fEmailGstr(AllTrim(aFuncDados[1]), AllTrim(aFuncDados[2]))

				If !Empty(cEmailGstr)
					cEmail	:= cEmailGstr
					
					cGestor	:= EncodeUTF8(SubStr(oResp["data", nI, "manager"], 1, At("(", oResp["data", nI, "manager"]) - 1))
					cGestor	:= StrTran(cGestor," ","&nbsp;")
				Else
					Conout(STR0056 + " " + aFuncDados[1] + " " + STR0057 + " " + AllTrim(aFuncDados[2])) // E-mail do gestor nao encontrado. Verfique o cadastro do funcionario da Filial: Matricula:
					Loop
				EndIf
			Else
				If Len(oResp["managers"]) > 1
					cGestor	:= EncodeUTF8(SubStr(oResp["managers", 1], 1, At("(", oResp["managers", 1]) - 1)) + " +" + cValToChar(Len(oResp["managers"]) - 1)
					cGestor	:= StrTran(cGestor," ","&nbsp;")
				Else
					cGestor	:= If (oResp["managers", 1] == "todos", "Todos", EncodeUTF8(SubStr(oResp["managers", 1], 1, At("(", oResp["managers", 1]) - 1)))
					cGestor	:= StrTran(cGestor," ","&nbsp;")
				EndIf
			EndIf
			
			// Criação do HTML
			cHtml := ""
			cHtml := fGeraHMTL(oResp["data", nI, "grpIndicators"], aFrmtDados[1,1], aFrmtDados[1,2], aFrmtDados[1,3], aFrmtDados[1,4], cGestor)

			// Criação o arquivo HTML
			nHandle := fcreate(cLogPatch + "dashboard_rh.html")
			FWrite(nHandle, cHtml)
			fclose(nHandle)

			cMsg := STR0017 + aFrmtDados[1,5] + STR0018 + aFrmtDados[1,6] + "."

			// Criação do Excel
			aExcel := fExcelDash(oResp["data", nI, "grpIndicators"], !oResp["managerIsEmpty"] ,.F.)

			// Envio do E-mail
			If gpeMail("Dashboard",cMsg,cEmail,{cLogPatch + "dashboard_rh.html", aExcel[1,3]})
				Conout(AnsiToOEM(STR0025)) // "E-mail com os dados do Dashboard RH foi enviado com sucesso."
			Else
				Conout(AnsiToOEM(STR0026)) // "Falha no envio do e-mail com os dados do Dashboard RH. Verifique as configurações para o envio do e-mail."
				lRet := .F.
			EndIf
			FErase(cLogPatch + "dashboard_rh.html")
			FErase(aExcel[1,3])
		Next
	EndIf
Else
	If lSchedule
		If !lExistPerg
			Conout(OemToAnsi(STR0019) + ": " + OemToAnsi(STR0020)) // "Erro de dicionário" "O grupo de perguntas PNA480A não está criado. Execute o UPPDISTR com o pacote de dicionários da expedição contínua para a criação."
		ElseIf Empty(cURLRest)
			Conout(OemToAnsi(STR0021) + ": " + OemToAnsi(STR0022)) // "Erro no parâmetro MV_PONREST." "O parâmetro MV_PONREST não está preenchido."
		ElseIf Empty(cGpeMail) .And. Empty(cRelausr)
			Conout(OemToAnsi(STR0026)) // "Falha no envio do e-mail com os dados do Dashboard RH. Verifique as configurações para o envio do e-mail."
		EndIf
	Else
		Help(,,STR0023,,STR0024,1,0) // "Erro na execução da rotina." "Esta rotina só deve ser executada pelo Scheduler."
	EndIf
EndIf	
Return lRet

/*/{Protheus.doc} fExistPerg
//Função para verificar se existe o grupo de perguntas
@author marco.nakazawa
@since 25/07/2022
@version 1.0
@return NIL
@type static function
/*/
Static Function fExistPerg(cPergunte)
Local lRet	:= .F.
Local oSX1	:= FWSX1Util():New()

oSX1:AddGroup(cPergunte)
oSX1:SearchGroup()

If !Empty(oSX1:aGrupo[1,2])
	lRet:= .T.
EndIf

FreeObj(oSX1)
Return lRet

/*/{Protheus.doc} fExcelDash
//Função para verificar se existe o grupo de perguntas
@author marco.nakazawa
@since 25/07/2022
@version 1.0
@return NIL
@type static function
/*/
Function fExcelDash(oResp, lTemGestor, lDeleta)
local oPrtXlsx		:= FwPrinterXlsx():New()
local oFile			:= Nil
local cFilename		:= ""
local cStatus		:= ""
local cHorAlign		:= ""
local cVertAlign	:= ""
local cMatAnt		:= ""
local cFilialAnt	:= ""
Local cFont			:= FwPrinterFont():Calibri()
Local cLogPatch		:= GetSrvProfString("Startpath","")
Local nPosPtInc		:= 0
Local nI			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nLenGrpInd	:= 0
Local nLenCard		:= 0
Local nLenDetalh	:= 0
Local nLinha		:= 0
local aRet			:= {}
Local oCellHorAl	:= FwXlsxCellAlignment():Horizontal()
Local oCellVerAl	:= FwXlsxCellAlignment():Vertical()

Default lDeleta		:= .F.
Default lTemGestor	:= .F.

cFilename	:= cLogPatch + "dashboard_rh.rel"
cHorAlign	:= oCellHorAl:Center()
cVertAlign	:= oCellVerAl:Center()

oPrtXlsx:Activate(cFilename)

nLenGrpInd := Len(oResp)

For nI := 1 To nLenGrpInd
	If (Mod(nI,2) == 1) // Grupo de indicadores de funcionários

		nLenCard := Len(oResp[nI, "indicators"])

		For nY := 1 To nLenCard
			// Define o título da aba do Excel de acordo com o indicador que está sendo processado e guarda
			// a posição do detalhamento do indicador Pontos Incompletos para a montagem da aba de ocorrências
			Do Case
				Case oResp[nI, "indicators", nY, "classTitle"] == "totalCard_title"
					Loop
				Case oResp[nI, "indicators", nY, "classTitle"] == "accomplishedCard_title"
					cStatus		:= STR0029	// Ponto completo
				Case oResp[nI, "indicators", nY, "classTitle"] == "attentionCard_title"
					cStatus		:= STR0030	// Ponto incompleto
					nPosPtInc	:= nY
				Case oResp[nI, "indicators", nY, "classTitle"] == "criticalCard_title"
					cStatus		:= STR0031	// Sem marcações
			EndCase

			If nY == 2
				// Criação da aba Indicadores Funcionários
				oPrtXlsx:AddSheet(STR0032) // "Indicadores Funcionários"

				// Configuração da fonte e das colunas
				oPrtXlsx:SetFont(cFont, 12, .F., .T., .F.)
				oPrtXlsx:SetColumnsWidth(1, 1, 10)
				oPrtXlsx:SetColumnsWidth(2, 2, 13)
				oPrtXlsx:SetColumnsWidth(3, 3, 40)
				oPrtXlsx:SetColumnsWidth(4, 4, 25)
				
				// Cabeçalho
				oPrtXlsx:SetText(2, 1, STR0033)	// Filial
				oPrtXlsx:SetText(2, 2, STR0034)	// Matrícula
				oPrtXlsx:SetText(2, 3, STR0035)	// Funcionário
				oPrtXlsx:SetText(2, 4, STR0036)	// Departamento

				// Condição para verificar se inclui a coluna Gestor para aplicar o merge, filtro e apresentação do título
				If lTemGestor
					oPrtXlsx:SetColumnsWidth(5, 5, 40)
					oPrtXlsx:SetColumnsWidth(6, 6, 17)
					oPrtXlsx:MergeCells(1, 1, 1, 6)
					oPrtXlsx:SetText(2, 5, STR0037)	// Gestor
					oPrtXlsx:SetText(2, 6, STR0038)	// Status
					oPrtXlsx:ApplyAutoFilter(2, 1, 2, 6)
				Else
					oPrtXlsx:SetColumnsWidth(5, 5, 17)
					oPrtXlsx:MergeCells(1, 1, 1, 5)
					oPrtXlsx:SetText(2, 5, STR0038)	// Status
					oPrtXlsx:ApplyAutoFilter(2, 1, 2, 5)
				EndIf

				// Configuração e impressão do título
				oPrtXlsx:SetFont(cFont, 16, .F., .T., .F.)
				oPrtXlsx:SetCellsFormat(cHorAlign, cVertAlign, .F., 0, "000000", "FFFFFF")
				oPrtXlsx:SetText(1, 1, STR0039)	// Detalhamento dos Funcionários
				
				// Volta para a configuração padrão das células do Excel
				oPrtXlsx:ResetCellsFormat()
				
				// Define a fonte para a impressão dos dados
				oPrtXlsx:SetFont(cFont, 11, .F., .F., .F.)

				// Controle da linha para impressão dos dados
				nLinha := 3
			EndIf

			nLenDetalh := Len(oResp[nI, "indicators", nY, 'details'])

			// Impressão dos dados
			For nZ := 1 To nLenDetalh
				// Caso seja o indicador Pontos Incompletos, imprimi o funcionário apenas 1 vez
				If nY == 3
					If cFilialAnt <> AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'branch']) .Or. cMatAnt <> AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'registration'])
						cFilialAnt	:= AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'branch'])
						cMatAnt		:= AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'registration'])
					Else
						Loop
					EndIf
				EndIf

				oPrtXlsx:SetText(nLinha, 1, If (!Empty(oResp[nI, "indicators", nY, 'details', nZ, 'branch']), AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'branch']), ""))
				oPrtXlsx:SetText(nLinha, 2, If (!Empty(oResp[nI, "indicators", nY, 'details', nZ, 'registration']), AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'registration']), ""))
				oPrtXlsx:SetText(nLinha, 3, If (!Empty(oResp[nI, "indicators", nY, 'details', nZ, 'name']), DecodeUTF8(AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'name'])), ""))
				oPrtXlsx:SetText(nLinha, 4, If (!Empty(oResp[nI, "indicators", nY, 'details', nZ, 'department']), DecodeUTF8(AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'department'])), ""))
				
				// Validação para imprimir o gestor do funcionário
				If lTemGestor
					oPrtXlsx:SetText(nLinha, 5, If (!Empty(oResp[nI, "indicators", nY, 'details', nZ, 'manager']), DecodeUTF8(AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'manager'])),""))
					oPrtXlsx:SetText(nLinha, 6, cStatus)
				Else
					oPrtXlsx:SetText(nLinha, 5, cStatus)
				EndIf

				nLinha++
			Next
		Next

		//Criação da aba Ocorrências - Ponto Incompleto
		oPrtXlsx:AddSheet(STR0040) // Pontos Incompletos

		// Configuração da fonte e das colunas
		oPrtXlsx:SetFont(cFont, 12, .F., .T., .F.)
		oPrtXlsx:SetColumnsWidth(1,1,10)
		oPrtXlsx:SetColumnsWidth(2,2,13)
		oPrtXlsx:SetColumnsWidth(3,3,40)
		oPrtXlsx:SetColumnsWidth(4,4,25)
		oPrtXlsx:SetColumnsWidth(5,5,11)
		oPrtXlsx:SetColumnsWidth(6,6,20)
		oPrtXlsx:SetColumnsWidth(7,7,40)
		oPrtXlsx:SetColumnsWidth(8,8,40)

		// Cabeçalho
		oPrtXlsx:SetText(2, 1, STR0033)	// Filial
		oPrtXlsx:SetText(2, 2, STR0034)	// Matrícula
		oPrtXlsx:SetText(2, 3, STR0035)	// Funcionário
		oPrtXlsx:SetText(2, 4, STR0036)	// Departamento
		oPrtXlsx:SetText(2, 5, STR0041)	// Data
		oPrtXlsx:SetText(2, 6, STR0042)	// Motivo
		oPrtXlsx:SetText(2, 7, STR0043)	// Previsto
		oPrtXlsx:SetText(2, 8, STR0044)	// Realizado

		// Condição para verificar se inclui a coluna Gestor para aplicar o merge, filtro e apresentação do título
		If lTemGestor
			oPrtXlsx:SetColumnsWidth(9, 9, 40)
			oPrtXlsx:SetText(2, 9, STR0037)	// Gestor
			oPrtXlsx:MergeCells(1, 1, 1, 9)
			oPrtXlsx:ApplyAutoFilter(2, 1, 2, 9)
		Else
			oPrtXlsx:MergeCells(1, 1, 1, 8)
			oPrtXlsx:ApplyAutoFilter(2, 1, 2, 8)
		EndIf

		// Merge das colunas para ser apresentado o título e aplicação do filtro no cabeçalho
		oPrtXlsx:SetFont(cFont, 16, .F., .T., .F.)
		oPrtXlsx:SetCellsFormat(cHorAlign, cVertAlign, .F., 0, "000000", "FFFFFF")
		oPrtXlsx:SetText(1, 1, STR0045) // Ocorrências - Ponto Incompleto

		// Volta para a configuração padrão das células do Excel
		oPrtXlsx:ResetCellsFormat()

		// Define a fonte para a impressão dos dados
		oPrtXlsx:SetFont(cFont, 11, .F., .F., .F.)

		// Controle da linha para impressão dos dados
		nLinha := 3

		nLenDetalh := Len(oResp[nI, "indicators", nPosPtInc, 'details'])

		// Impressão dos dados
		For nZ := 1 To nLenDetalh
			oPrtXlsx:SetText(nLinha, 1, If (!Empty(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'branch']), AllTrim(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'branch']), ""))
			oPrtXlsx:SetText(nLinha, 2, If (!Empty(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'registration']), AllTrim(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'registration']), ""))
			oPrtXlsx:SetText(nLinha, 3, If (!Empty(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'name']), DecodeUTF8(AllTrim(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'name'])), ""))
			oPrtXlsx:SetText(nLinha, 4, If (!Empty(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'department']), DecodeUTF8(AllTrim(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'department'])), ""))
			oPrtXlsx:SetText(nLinha, 5, If (!Empty(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'dateTime']), AllTrim(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'dateTime']), ""))
			oPrtXlsx:SetText(nLinha, 6, If (!Empty(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'reason']), DecodeUTF8(AllTrim(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'reason'])), ""))
			oPrtXlsx:SetText(nLinha, 7, If (!Empty(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'estimated']), AllTrim(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'estimated']), ""))
			oPrtXlsx:SetText(nLinha, 8, If (!Empty(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'performed']), AllTrim(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'performed']), ""))
			If (lTemGestor, oPrtXlsx:SetText(nLinha, 9, If (!Empty(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'manager']), DecodeUTF8(AllTrim(oResp[nI, "indicators", nPosPtInc, 'details', nZ, 'manager'])), "")),Nil)
			
			nLinha++
		Next
	Else
		//Grupo de indicadores do Clock In
		nLenCard := Len(oResp[nI, "indicators"])
		
		// Criação da aba Indicadores Clock In
		For nY := 1 To nLenCard
			// Define o status da marcação bom base no detalhamento enviado pelo Dashboard
			Do Case
				Case oResp[nI, "indicators", nY, "classTitle"] == "totalCard_title"
					Loop
				Case oResp[nI, "indicators", nY, "classTitle"] == "accomplishedCard_title"
					cStatus := STR0053	// Marcação processada
				Case oResp[nI, "indicators", nY, "classTitle"] == "attentionCard_title"
					cStatus := STR0054	// Integração pendente
				Case oResp[nI, "indicators", nY, "classTitle"] == "criticalCard_title"
					cStatus := STR0055	// Marcação sem NSR
			EndCase

			If nY == 2
				// Criação da aba Indicadores Clock In
				oPrtXlsx:AddSheet("Indicadores Clock In") // Indicadores Clock In
				
				// Configuração da fonte e das colunas
				oPrtXlsx:SetFont(cFont, 12, .F., .T., .F.)
				oPrtXlsx:SetColumnsWidth(1, 1, 12)
				oPrtXlsx:SetColumnsWidth(2, 2, 12)
				oPrtXlsx:SetColumnsWidth(3, 3, 12)
				oPrtXlsx:SetColumnsWidth(4, 4, 10)
				oPrtXlsx:SetColumnsWidth(5, 5, 40)
				oPrtXlsx:SetColumnsWidth(6, 6, 40)
				oPrtXlsx:SetColumnsWidth(7, 7, 12)
				oPrtXlsx:SetColumnsWidth(8, 8, 23)
				oPrtXlsx:SetColumnsWidth(9, 9, 20)

				// Cabeçalho
				oPrtXlsx:SetText(2, 1, STR0046)	// CNPJ
				oPrtXlsx:SetText(2, 2, STR0047)	// CPF
				oPrtXlsx:SetText(2, 3, STR0048)	// PIS
				oPrtXlsx:SetText(2, 4, STR0033)	// Filial
				oPrtXlsx:SetText(2, 5, STR0035)	// Funcionário
				oPrtXlsx:SetText(2, 6, STR0049)	// Dispositivo
				oPrtXlsx:SetText(2, 7, STR0050)	// NSR
				oPrtXlsx:SetText(2, 8, STR0051)	// Data Hora Marcação
				oPrtXlsx:SetText(2, 9, STR0038)	// Status

				// Merge das colunas para ser apresentado o título e aplicação do filtro no cabeçalho
				oPrtXlsx:MergeCells(1, 1, 1, 9)
				oPrtXlsx:ApplyAutoFilter(2, 1, 2, 9)

				// Configuração e impressão do título
				oPrtXlsx:SetFont(cFont, 16, .F., .T., .F.)
				oPrtXlsx:SetCellsFormat(cHorAlign, cVertAlign, .F., 0, "000000", "FFFFFF")
				oPrtXlsx:SetText(1, 1, STR0052) // Detalhamento das Marcações do Clock In

				// Volta para a configuração padrão das células do Excel
				oPrtXlsx:ResetCellsFormat()

				// Define a fonte para a impressão dos dados
				oPrtXlsx:SetFont(cFont, 11, .F., .F., .F.)

				// Controle da linha para impressão dos dados
				nLinha := 3
			EndIf
			
			nLenDetalh := Len(oResp[nI, "indicators", nY, 'details'])
			
			// Impressão dos dados
			For nZ := 1 To nLenDetalh
				oPrtXlsx:SetText(nLinha, 1, If (!Empty(oResp[nI, "indicators", nY, 'details', nZ, 'cnpj']), AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'cnpj']), ""))
				oPrtXlsx:SetText(nLinha, 2, If (!Empty(oResp[nI, "indicators", nY, 'details', nZ, 'cpf']), AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'cpf']), ""))
				oPrtXlsx:SetText(nLinha, 3, If (!Empty(oResp[nI, "indicators", nY, 'details', nZ, 'pis']), AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'pis']), ""))
				oPrtXlsx:SetText(nLinha, 4, If (!Empty(oResp[nI, "indicators", nY, 'details', nZ, 'branch']), AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'branch']), ""))
				oPrtXlsx:SetText(nLinha, 5, If (!Empty(oResp[nI, "indicators", nY, 'details', nZ, 'name']), DecodeUTF8(AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'name'])), ""))
				oPrtXlsx:SetText(nLinha, 6, If (!Empty(oResp[nI, "indicators", nY, 'details', nZ, 'device']), AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'device']), ""))
				oPrtXlsx:SetText(nLinha, 7, If (!Empty(cValToChar(oResp[nI, "indicators", nY, 'details', nZ, 'nsr'])), cValToChar(oResp[nI, "indicators", nY, 'details', nZ, 'nsr']),"0"))
				oPrtXlsx:SetText(nLinha, 8, If (!Empty(oResp[nI, "indicators", nY, 'details', nZ, 'dateTime']), AllTrim(oResp[nI, "indicators", nY, 'details', nZ, 'dateTime']), ""))
				oPrtXlsx:SetText(nLinha, 9, cStatus)

				nLinha++
			Next
		Next
	EndIf
Next

oPrtXlsx:toXlsx()
oPrtXlsx:EraseBaseFile()

oFile := FwFileReader():New(cLogPatch + "dashboard_rh.xlsx")

If (oFile:Open())
	cBlob := oFile:FullRead() 
	cBlob := Encode64(cBlob)

	aAdd(aRet,{"dashboard_rh.xlsx", cBlob, cLogPatch + "dashboard_rh.xlsx"})

	oFile:Close()

	If (lDeleta, fErase(cLogPatch + "dashboard_rh.xlsx"), Nil)
EndIf

oPrtXlsx:DeActivate()
oPrtXlsx:Destroy()
Return aRet

/*/{Protheus.doc} fFormtDads
//Função para formatar os dados dos filtros para serem usando no HTML que será gerado com as informações do Dashboard.
@author marco.nakazawa
@since 25/07/2022
@version 1.0
@return NIL
@type static function
/*/
Static Function fFormtDads(cDtHrAtual,cDataIni,cDataFim,aFiliais)
Local cData			:= ""
Local cHora			:= ""
Local cFilHtml		:= ""
Local aRet			:= {}

Default cDtHrAtual	:= ""
Default cDataIni	:= ""
Default cDataFim	:= ""
Default aFiliais	:= {}

cData := SubStr(cDtHrAtual,8,10)
cHora := SubStr(cDtHrAtual,1,5)

cDataIni := SubStr(cDataIni,9,2) + "/" + SubStr(cDataIni,6,2) + "/" + SubStr(cDataIni,1,4)
cDataFim := SubStr(cDataFim,9,2) + "/" + SubStr(cDataFim,6,2) + "/" + SubStr(cDataFim,1,4)

If Len(aFiliais) > 2
	cFilHtml := aFiliais[1] + " " + aFiliais[2] + " +" + cValToChar(Len(aFiliais) - 2)
ElseIf Len(aFiliais) ==  2
	cFilHtml := aFiliais[1] + " " + aFiliais[2]
Else
	If (aFiliais[1] == "todas", cFilHtml := "Todas", cFilHtml := aFiliais[1])
EndIf

cFilHtml := StrTran(cFilHtml," ","&nbsp;")

aAdd(aRet,{cDtHrAtual, cDataIni, cDataFim, cFilHtml, cData, cHora})
Return aRet

/*/{Protheus.doc} fExcelDash
//Função limpar e restaurar o conteúdo do HMTL
@author marco.nakazawa
@since 13/11/2023
@version 1.0
@return NIL
@type static function
/*/
Static Function fGeraHMTL(oResp, cDtHrAtual, cDataIni, cDataFim, cFilHtml, cGestor)
Local cHtml		:= ""
Local nI		:= 0

Default oResp		:= ""
Default cDtHrAtual	:= ""
Default cDataIni	:= ""
Default cDataFim	:= ""
Default cFilHtml	:= ""
Default cGestor		:= ""

If !Empty(oResp)
	// Montagem do HTML
	cHtml := "<!DOCTYPE html>"
	cHtml += "<html>"
	cHtml += 	"<head>"
	cHtml += 		"<meta charset='UTF-8'/>"
	cHtml += 		"<style type='text/css'>"
	cHtml += 			".title{"
	cHtml += 				"font-family: Roboto-Condensed-Light,sans-serif;"
	cHtml += 				"font-style: normal;"
	cHtml += 				"font-weight: 200;"
	cHtml += 				"font-size: 25px;"
	cHtml += 				"line-height: 55px;"
	cHtml += 				"color: #1D2426;"
	cHtml += 				"vertical-align: bottom;"
	cHtml += 				"width: 100%;"
	cHtml += 				"display: inline-block;"
	cHtml += 			"}"
	cHtml += 			".lastUpdate {"
	cHtml += 				"font-family: Roboto,sans-serif;"
	cHtml += 				"font-style: normal;"
	cHtml += 				"font-weight: 400;"
	cHtml += 				"font-size: 14px;"
	cHtml += 				"line-height: 24px;"
	cHtml += 				"text-align: left;"
	cHtml += 				"color: #4A5C60;"
	cHtml += 				"white-space: nowrap;"
	cHtml += 				"vertical-align: bottom;"
	cHtml += 				"width: 11%;"
	cHtml += 			"}"
	cHtml += 			".lastUpdateDate {"
	cHtml += 				"font-family: Roboto,sans-serif;"
	cHtml += 				"font-style: normal;"
	cHtml += 				"font-weight: 700;"
	cHtml += 				"font-size: 14px;"
	cHtml += 				"line-height: 24px;"
	cHtml += 				"text-align: left;"
	cHtml += 				"color: #4A5C60;"
	cHtml += 				"white-space: nowrap;"
	cHtml += 				"vertical-align: bottom;"
	cHtml += 			"}"
	cHtml += 			".filters {"
	cHtml += 				"white-space: nowrap;"
	cHtml += 				"font-family: Roboto-Bold,sans-serif;"
	cHtml += 				"font-size: 14px;"
	cHtml += 				"line-height: 24px;"
	cHtml += 				"color: #4a5c60;"
	cHtml += 			"}"
	cHtml += 			".inputFilter {"
	cHtml += 				"padding-left: 8px;"
	cHtml += 				"margin-top: 5px;"
	cHtml += 				"margin-right: 12px;"
	cHtml += 				"text-align: left;"
	cHtml += 				"height: 34.5px;"
	cHtml += 				"width: 150px;"
	cHtml += 				"border: 1px solid #D3D3D3;"
	cHtml += 				"border-radius: 3px;"
	cHtml += 			"}"
	cHtml += 			".inputRefresh {"
	cHtml += 				"border: 1px solid #0C9ABE;"
	cHtml += 				"margin-top: 5px;"
	cHtml += 				"border-radius: 3px;"
	cHtml += 				"margin-right: 4px;"
	cHtml += 				"font-weight: bold;"
	cHtml += 				"text-align: center;"
	cHtml += 				"height: 34.5px;"
	cHtml += 				"width: 90px;"
	cHtml += 				"color: #0c9abe;"
	cHtml += 			"}"
	cHtml += 			".inputEmail {"
	cHtml += 				"border: 1px solid #0C9ABE;"
	cHtml += 				"margin-top: 5px;"
	cHtml += 				"border-radius: 3px;"
	cHtml += 				"font-weight: bold;"
	cHtml += 				"text-align: center;"
	cHtml += 				"height: 37.5px;"
	cHtml += 				"width: 100px;"
	cHtml += 				"color: #0c9abe;"
	cHtml += 			"}"
	cHtml += 			".inputExcel {"
	cHtml += 				"border: 1px solid #0C9ABE;"
	cHtml += 				"margin-top: 5px;"
	cHtml += 				"border-radius: 3px;"
	cHtml += 				"font-weight: bold;"
	cHtml += 				"text-align: center;"
	cHtml += 				"height: 37.5px;"
	cHtml += 				"width: 90px;"
	cHtml += 				"color: #0c9abe;"
	cHtml += 			"}"
	cHtml += 			".inputEmailGestor {"
	cHtml += 				"border: 1px solid #0C9ABE;"
	cHtml += 				"margin-top: 5px;"
	cHtml += 				"border-radius: 3px;"
	cHtml += 				"font-weight: bold;"
	cHtml += 				"text-align: center;"
	cHtml += 				"height: 37.5px;"
	cHtml += 				"width: 160px;"
	cHtml += 				"color: #0c9abe;"
	cHtml += 			"}"
	cHtml += 			".indicators {"
	cHtml += 				"font-family:Roboto-Condensed-Light,sans-serif;"
	cHtml += 				"height: 80px;"
	cHtml += 				"padding: 8px;"
	cHtml += 				"font-size: 24px;"
	cHtml += 				"line-height: 32px;"
	cHtml += 				"align-items: center;"
	cHtml += 				"color: #374548;"
	cHtml += 			"}"
	cHtml += 			".alert {"
	cHtml += 				"font-family:Roboto-Condensed-Light,sans-serif;"
	cHtml += 				"font-size: 10px;"
	cHtml += 				"color: #1D2426;"
	cHtml += 				"border-radius: 3px;"
	cHtml += 				"display: inline-block;"
	cHtml += 				"float: right;"
	cHtml += 				"margin-right: 25px;"
	cHtml += 				"margin-top: 10px;"
	cHtml += 				"padding: 5px;"
	cHtml += 			"}"
	cHtml += 			"tableCards {"
	cHtml += 				"border: 1px solid #000;"
	cHtml += 			"}"
	cHtml += 			".divIndicators {"
	cHtml += 				"display: flex;"
	cHtml += 			"}"
	cHtml += 			".cardDescriptionTotal{"
	cHtml += 				"font-family: Roboto,sans-serif;"
	cHtml += 				"font-size: 16px;"
	cHtml += 				"color: #ffffff;"
	cHtml += 				"text-align: center;"
	cHtml += 				"vertical-align: top;"
	cHtml += 			"}"
	cHtml += 			".cardAmountTotal{"
	cHtml += 				"font-family: Calibri,sans-serif;"
	cHtml += 				"font-size: 50px;"
	cHtml += 				"vertical-align: top;"
	cHtml += 				"justify-content: center;"
	cHtml += 				"flex: 1 1 auto;"
	cHtml += 				"color: #ffffff;"
	cHtml += 				"text-align: center;"
	cHtml += 			"}"
	cHtml += 			".cardDescription{"
	cHtml += 				"font-family: Roboto,sans-serif;"
	cHtml += 				"font-size: 16px;"
	cHtml += 				"color: #4a5c60;"
	cHtml += 				"text-align: center;"
	cHtml += 				"vertical-align: top;"
	cHtml += 			"}"
	cHtml += 			".cardAmount{"
	cHtml += 				"font-family: Calibri,sans-serif;"
	cHtml += 				"font-size: 50px;"
	cHtml += 				"color: #4a5c60;"
	cHtml += 				"justify-content: center;"
	cHtml += 				"flex-direction: column;"
	cHtml += 				"flex: 1 1 auto;"
	cHtml += 				"text-align: center;"
	cHtml += 				"vertical-align: top;"
	cHtml += 			"}"
	cHtml += 			".separator {"
	cHtml += 			"border: 1px dotted #4a5c60;"
	cHtml += 			"}"
	cHtml += 		"</style>"
	cHtml += 	"</head>"
	cHtml += 	"<body>"
	cHtml += 		"<div style='display: flex;'>"
	cHtml += 			"<div class='title'>Dashboard</div>"
	cHtml += 			"<div style='display:inline;'>"
	cHtml += 				"<div class='lastUpdate'>" + EncodeUTF8(STR0001) + "</div>"
	cHtml += 				"<div class='lastUpdateDate'>" + cDtHrAtual + "</div>"
	cHtml += 			"</div>"
	cHtml += 		"</div>"
	cHtml += 		"<div style='height: 25px'></div>"
	cHtml += 		"<div>"
	cHtml += 			"<table class='filters'>"
	cHtml += 				"<tr>"
	cHtml += 					"<td><b>" + EncodeUTF8(STR0002) + "</b></td>"
	cHtml += 					"<td><b>" + EncodeUTF8(STR0003) + "</b></td>"
	cHtml += 					"<td><b>Selecione a Filial</b></td>"
	cHtml += 					"<td><b>Selecione o Gestor</b></td>"
	cHtml += 					"<td></td>"
	cHtml += 				"</tr>"
	cHtml += 				"<tr>"
	cHtml += 					"<td><input class='inputFilter'	type='text' value=" + cDataIni + "></td>"
	cHtml += 					"<td><input class='inputFilter'	type='text' value=" + cDataFim + "></td>"
	cHtml += 					"<td><input class='inputFilter'	type='text' value=" + cFilHtml + " style='width:280px; color: #0c9abe;'></td>"
	cHtml += 					"<td><input class='inputFilter'	type='text' value=" + cGestor + " style='width:350px; color: #0c9abe;'></td>"
	cHtml += 					"<td><input class='inputRefresh' type='text' value='Atualizar'></td>"
	cHtml += 				"</tr>"
	cHtml += 				"<tr>
	cHtml += 					"<th colspan='4' align='left'>"
	cHtml += 						"<input class='inputExcel' type='text' value='Gerar Excel'>&nbsp;&nbsp;"
	cHtml += 						"<input class='inputEmail' type='text' value='Enviar E-mail'>&nbsp;&nbsp;"
	cHtml += 						"<input class='inputEmailGestor' type='text' value='Enviar E-mail Gestores'>&nbsp;&nbsp;"
	cHtml += 					"</th>"
	cHtml += 				"</tr>"
	cHtml += 			"</table>"
	cHtml += 		"</div>"
	For nI := 1 To Len(oResp)
		cHtml += 		"<div class='indicators'>"
		cHtml += 			"<p><b>" + oResp[nI, "indicatorGroup"] + "</b></p>"
		cHtml += 		"</div>"
		cHtml += 		"<div class='divIndicators'>"
		cHtml += 			"<table class='tableCards' style='border-radius: 3px; width: 300px; height:220px; background-color: #0C9ABE; color: #ffffff;'>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 					"<td style='width:100%;'></td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 					"<td class='cardAmountTotal'>" + cValToChar(oResp[nI, "indicators", 1, 'amount']) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 				"<td class='cardDescriptionTotal'>" + If (Mod(nI,2) == 1, EncodeUTF8(STR0005), EncodeUTF8(STR0013)) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 			"</table>"
		cHtml += 			"<div style='width: 15px' ></div>"
		cHtml += 			"<table class='tableCards' style='border: 1px solid #D3D3D3; border-radius: 3px; width: 300px; height:220px;'>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 					"<td class='alert' style='background-color: #DAECE5;'>" + EncodeUTF8(STR0006) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 					"<td class='cardAmount'>" + cValToChar(oResp[nI, "indicators", 2, "amount"]) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 				"<td class='cardDescription'>" + If (Mod(nI,2) == 1, EncodeUTF8(STR0007),EncodeUTF8(STR0014)) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 			"</table>"
		cHtml += 			"<div style='width: 15px' ></div>"
		cHtml += 			"<table class='tableCards' style='border: 1px solid #D3D3D3; border-radius: 3px; width: 300px; height:220px;'>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 				"<td class='alert' style='background-color: #FFEACB;'>" + EncodeUTF8(STR0008) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr>"
		cHtml += 					"<td class='cardAmount'>" + cValToChar(oResp[nI, "indicators", 3, "amount"]) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 				"<td class='cardDescription'>" + If (Mod(nI,2) == 1, EncodeUTF8(STR0009),EncodeUTF8(STR0015)) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 			"</table>"
		cHtml += 			"<div style='width: 15px' ></div>"
		cHtml += 			"<table class='tableCards' style='border: 1px solid #D3D3D3; border-radius: 3px; width: 300px; height:220px;'>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 				"<td class='alert' style='background-color: #F6E0E0;'>" + EncodeUTF8(STR0010) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 					"<td class='cardAmount'>" + cValToChar(oResp[nI, "indicators", 4, "amount"]) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 				"<tr style='height:33%'>"
		cHtml += 				"<td class='cardDescription'>" + If (Mod(nI,2) == 1, EncodeUTF8(STR0011),EncodeUTF8(STR0016)) + "</td>"
		cHtml += 				"</tr>"
		cHtml += 			"</table>"
		cHtml += 		"</div>"
		If Mod(nI,2) == 0
			cHtml +=	"<br>"
			cHtml +=	"<hr class='separator'>"			
			cHtml +=	"<p></p>"			
			cHtml +=	"<hr class='separator'>"
		EndIf
	Next

	cHtml +=	"</body>"
	cHtml += "</html>"
EndIf
Return cHtml

/*/{Protheus.doc} fEmailGstr
//Função para retornar o e-mail do gestor
@author marco.nakazawa
@since 13/11/2023
@version 1.0
@return NIL
@type static function
/*/
Static Function fEmailGstr(cFil, cMat)
Local cAlias		:= GetNextAlias()
Local cQuery		:= ""
Local cEmailGstr	:= ""

Static __oST1

Default	cFil := ""
Default	cMat := ""

If __oSt1 == Nil
	__oSt1 := FWPreparedStatement():New()

	cQuery := "SELECT RA_EMAIL"
	cQuery += "FROM  " + RetSqlName("SRA") + " SRA"
	cQuery += "WHERE RA_FILIAL = ? "
	cQuery += "AND RA_MAT = ? "
	cQuery += "AND D_E_L_E_T_= ' '"	
	
	cQuery := ChangeQuery(cQuery)
	
	__oSt1:SetQuery(cQuery)
EndIf

If !Empty(cFil) .And. !Empty(cMat)
	__oSt1:SetString(1,cFil)
	__oSt1:SetString(2,cMat)
	
	cQuery := __oSt1:getFixQuery()

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias)

	If (cAlias)->(!EoF())
		cEmailGstr := AllTrim((cAlias)->RA_EMAIL)
	EndIf

	dbSelectArea(cAlias)
	dbCloseArea()
EndIf
Return cEmailGstr

/*/{Protheus.doc} fBscGestor
//Função para retornar os gestores na consulta padrão
@author marco.nakazawa
@since 16/11/2023
@version 1.0
@return NIL
@type function
/*/
Function fBscGestor(lDashboard, aGestores)
Local aGetFil		:= {}									as Array
Local cAlias		:= GetNextAlias()						as Character
Local cOrgCfg		:= SuperGetMV("MV_ORGCFG", .F., "0")	as Character
Local cFilAccess	:= ""									as Character
Local cWhereFil		:= ""									as Character
Local cValidFil		:= ""									as Character
Local MvPar			:= ""									as Character
Local lRet			:= .T.									as Logical
Local nLeFil		:= 0									as Numeric
Local nI			:= 0									as Numeric
Local nTmnChave		:= 0									as Numeric

Default lDashboard	:= .F.
Default aGestores	:= {}

aGetFil		:= GetFilRecnos(cEmpAnt , Space(FWGETTAMFILIAL), Replicate("Z", FWGETTAMFILIAL))
cValidFil 	:= fValidFil()
nLeFil		:= Len(aGetFil)

If !Empty(aGetFil)
	For nI := 1 To nLeFil
		If aGetFil[nI,1] $ cValidFil
			If Empty(cFilAccess)
				cFilAccess := "'" + aGetFil[nI,1] + "'"
			Else
				cFilAccess += ",'" + aGetFil[nI,1] + "'"
			EndIf
		EndIf
	Next
EndIf

cWhereFil := "%SRA.RA_FILIAL IN (" + cFilAccess + ")%"

If cOrgCfg == "0" .Or. cOrgCfg == "2"
	BeginSql alias cAlias
		SELECT
		SRA.RA_MAT,
		SRA.RA_FILIAL,
		SRA.RA_NOME
		FROM %table:SRA% SRA
		INNER JOIN %table:SQB% SQB ON SRA.RA_MAT = SQB.QB_MATRESP AND SRA.RA_FILIAL = SQB.QB_FILRESP
		WHERE SRA.%notDel%
		  AND %exp:cWhereFil%
		  AND SRA.RA_SITFOLH <> 'D'
		GROUP BY SRA.RA_MAT, SRA.RA_FILIAL, SRA.RA_NOME
	EndSql
Else
	BeginSql alias cAlias
		SELECT 
		RA_FILIAL,
		RA_MAT,
		RA_NOME
		FROM %table:RD4% RD4
		INNER JOIN %table:RCX% RCX ON RCX.RCX_POSTO = RD4.RD4_CODIDE
		INNER JOIN %table:SRA% SRA ON RCX.RCX_FILFUN = SRA.RA_FILIAL AND RCX.RCX_MATFUN = SRA.RA_MAT 
		INNER JOIN (
			SELECT RD4_TREE FROM %table:RD4% RD4
			INNER JOIN %table:RCX% RCX ON RCX.RCX_POSTO = RD4.RD4_CODIDE 
			INNER JOIN %table:SRA% SRA ON RCX.RCX_FILFUN = SRA.RA_FILIAL AND RCX.RCX_MATFUN = SRA.RA_MAT 
			WHERE RD4_TREE <> ''
			GROUP BY RD4_TREE
		) RD4TREE ON RD4TREE.RD4_TREE = RD4.RD4_ITEM
		WHERE SRA.%notDel%
		  AND %exp:cWhereFil%
		  AND SRA.RA_SITFOLH <> 'D'
		GROUP BY SRA.RA_MAT, SRA.RA_FILIAL, SRA.RA_NOME
	EndSql
EndIf

While !(cAlias)->(Eof())
	aAdd(aGestores, AllTrim((cAlias)->RA_NOME) + " (" + (cAlias)->RA_FILIAL + " - " + (cAlias)->RA_MAT + ")")
	(cAlias)->(dbSkip())
Enddo

If !lDashboard
	MvPar		:= ""
	nTmnChave	:= GetSx3Cache("RA_FILIAL", "X3_TAMANHO") + GetSx3Cache("RA_MAT", "X3_TAMANHO") + GetSx3Cache("RA_NOME", "X3_TAMANHO") + 6
	VAR_IXB		:= Space(nTmnChave)

	If (f_Opcoes(@MvPar, STR0058, aGestores, , , , 1, nTmnChave, 1, .F.), VAR_IXB := MvPar, lRet := .F.)
EndIf

(cAlias)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} Scheddef
//Função para execução da rotina pelo Scheduler
@author marco.nakazawa
@since 25/07/2022
@version 1.0
@return NIL
@type static function
/*/
Static Function Scheddef()
Local aOrd			:= {}
Local aParam		:= {}
Local lExstPergN	:= fExistPerg("PNA480AN")

If lExstPergN
	aParam := {	"P"			, ; // Tipo R para relatorio P para processo
				"PNA480AN"	, ;	// Pergunte do relatorio, caso nao use passar ParamDef
				""			, ; // Alias para o relatório
				aOrd		, ; // Array de ordens para o relatório
				""			}
Else
	aParam := {	"P"			, ; // Tipo R para relatorio P para processo
				"PNA480A"	, ;	// Pergunte do relatorio, caso nao use passar ParamDef
				""			, ; // Alias para o relatório
				aOrd		, ; // Array de ordens para o relatório
				""			}
EndIf
Return aParam



