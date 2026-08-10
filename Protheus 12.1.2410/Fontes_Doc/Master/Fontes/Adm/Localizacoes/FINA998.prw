
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FINA998.CH"
#INCLUDE "FWLIBVERSION.CH"
 
/*/{Protheus.doc} FINA998
FWCallApp funcion para inicar TOTVS RECIBOS
@type function
@version  1
@author luis.aboytes
@since 18/5/2021
/*/
Function FINA998()  

Local lfina846 :=  SuperGetmv( "MV_FINA846 ", .F., .F. )
Local lfina087a := SuperGetmv( "MV_FINA087 ", .F., .F. )
Local cVersion := GetRpoRelease()
Local lMata465n := IsInCallStack("MATA465N")
local oSay1    as object
local oSay2    as object
local oSay3    as object
local oSay4    as object
local oModal   as object
Local cMsg1    as character
Local cMsg2    as character
Local cMsg3    as character
Local cMsg4    as character
local oContainer as object
local cEndWeb := "https://tdn.totvs.com/x/ZWh6Mg"
Local aRestroca := {}

If cPaisLoc $ "ANG|COS|GUA|BRA|PTG|POR|VEN"
	MsgAlert(STR0017) //Opción solo disponible para Mercado Internacional
	Return
ENDIF

If 	lfina846 .and. cpaisloc == "ARG"  .and. cVersion == "12.1.2210"
	SetFunName("FINA846")
	if lMata465n
		FINA840()
		SetFunName(cFunName)
	Else
		FINA846()
	Endif
ELSEIF lfina087a .and. cVersion == "12.1.2210"
	SetFunName("FINA087A")
	FINA087A()
else
	If !(Alltrim(GetSX3Cache("FJT_SERIE"	,"X3_VALID")) <>"" .OR. Alltrim(GetSX3Cache("FJT_SERIE"		,"X3_VLDUSER")) <>"" ) .OR. ;
		!(Alltrim(GetSX3Cache("FJT_NATURE"	,"X3_VALID")) <>"" .OR. Alltrim(GetSX3Cache("FJT_NATURE"	,"X3_VLDUSER")) <>"" ) .OR. ;
		!(Alltrim(GetSX3Cache("FJT_CLIENT"	,"X3_VALID")) <>"" .OR. Alltrim(GetSX3Cache("FJT_CLIENT"	,"X3_VLDUSER")) <>"" ) .OR. ;
		!(Alltrim(GetSX3Cache("FJT_LOJA"	,"X3_VALID")) <>"" .OR. Alltrim(GetSX3Cache("FJT_LOJA"		,"X3_VLDUSER")) <>"" ) .OR. ;
		!(Alltrim(GetSX3Cache("FJT_RECIBO"	,"X3_VALID")) <>"" .OR. Alltrim(GetSX3Cache("FJT_RECIBO"	,"X3_VLDUSER")) <>"" ) .OR. ;
		!(Alltrim(GetSX3Cache("FJT_COBRAD"	,"X3_VALID")) <>"" .OR. Alltrim(GetSX3Cache("FJT_COBRAD"	,"X3_VLDUSER")) <>"" ) 

			oModal := FWDialogModal():New()
			oModal:SetCloseButton( .F. )
			oModal:SetEscClose( .F. )
			oModal:setTitle(STR0005) //"Actualización de diccionario de datos necesaria"
			oModal:setSize(120, 200)//establece la altura y el ancho de la ventana en píxeles
			oModal:createDialog()
			oModal:AddButton( STR0006, {||oModal:DeActivate()}, STR0006, , .T., .F., .T., ) //"Confirmar"
			oContainer := TPanel():New( ,,, oModal:getPanelMain() )
			oContainer:Align := CONTROL_ALIGN_ALLCLIENT
			cMsg1 := i18n(STR0007 ) //"Se identifica que faltan validaciones de campo en el ambiente"
			cMsg2 := i18n(STR0008 ) //"a partir de ajustes en la rutina de Totvs Recibos para los "
			cMsg4 := i18n(STR0009 ) //"campos de la Tabla FJT - Encabezado del Recibo."
			oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,200,20,,,,,,.T.)
			oSay2 := TSay():New( 20,10,{||cMsg2 },oContainer,,,,,,.T.,,,200,20,,,,,,.T.)
			oSay4 := TSay():New( 30,10,{||cMsg4 },oContainer,,,,,,.T.,,,200,20,,,,,,.T.)
			cMsg3 := Alltrim(STR0010 )+space(01) //"Para conocer más vea el punto 04 del siguiente " 
			cMsg3 += "<b><a target='_blank' href='"+cEndWeb+"'> "
			cMsg3 += Alltrim(STR0011) // "Documento Técnico"
			cMsg3 += " </a></b>."
			cMsg3 += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"
			oSay3 := TSay():New(45,10,{||cMsg3},oContainer,,,,,,.T.,,,200,20,,,,,,.T.)
			oSay3:bLClicked := {|| MsgRun( STR0012, "URL",{|| ShellExecute("open",cEndWeb,"","",1) } ) } // "Abriendo el enlace... Espere..."
			oModal:Activate()
		EndIf
		If !FWSX1Util():ExistPergunte("FINA998BUS")
			 FIN998BUSC()
		EndIf
	IF lMata465n
		aRestroca 	:= aClone(aTrocaF3)
		aTrocaF3	:= {} 
	EndIF
	FWCallApp( "FINA998" )
EndIf

IF lMata465n
	aTrocaF3 := aRestroca
EndIF
Return

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	luis.aboytes
@since 		03/01/2023
@version	12.1.27 / Superior
@type function
/*/
Static Function MenuDef()
Local aRotina := FWLoadMenuDef("FINA887")

Return aRotina


/*/{Protheus.doc} JsToAdvpl
Envíe un mensaje JavaScript a ADVPL. Este mensaje será recibido por el bloque de código bJsToAdvpl del componente TWebChannel asociado con el componente TWebEngine que muestra la página / componente HTML.
@type function
@version  1
@author luis.aboytes
@since 18/5/2021
@param oWebChannel, Object, Objeto Web
@param cType, character, Nombre del metodo ADVPL a ejecutar
@param cContent, character, contenido a buscar dentro del metodo ADVPL
/*/
Function JsToAdvpl(oWebChannel,cType,cContent)
	Local jBody   	As Character
	Local nCont 	As Numeric
	Local aResponse	As Array
	Local jData		As Object
	Local cResponse	As Character
	Local jResponse As Object
	Local aTemp     As Array
	Local lIsCompen	:= .F. As Logical
	Local lValid	:= .F. As Logical
	Local cSuccess	As Character
	Local nX		As Numeric
	Local aResTmp	As Array
	Local nY		As Numeric
	Local cTemp		As Character
	local cSerieS :=""
	local cReciboS :=""
	local cMotC :=""
	local aRec :={}
	local nI := 1
	Local oMdlTab  	As Object 
	Local oStruFJT  As Object 
	Local oExecView	AS Object
	Local lView		As Logical
	local aHeader := {}
	local cOrder := ""
	local nCpo := 1
	local aCpos := {}
	local cProp := ""
	Local lIdente := .F. As Logical
	Local cBranch := '', cSerie:= '', cRecibo:= '', cVersion := '' As Character
	Private aDocuments	As Array
	Private dDataLanc	As Date
	Private cCadastro 	As Character
	Private aRotina 	As Array
	Private aTotRdpe	As Array
	Private cSublote	As Character
	Private __lCusto	As Logical
	Private __lItem 	As Logical
	Private __lCLVL		As Logical

	Static __lMetric  := FwLibVersion() >= "20210517"

	//Mensajes en la consola del  AppServer 
	conout("JsToAdvpl cType: "  + cValToChar(cType))
	conout("JsToAdvpl cContent: "  + cValToChar(cContent))
	conout("Inicio de JsToAdvpl ->" + Time())  
	//Comparamos el la variable cType y obtenemos el valor de un metodo ADVPL que sera regresado a la aplicacion WEB
	If  UPPER(Alltrim(cType)) == "GENERATEXML" .OR. UPPER(Alltrim(cType)) == "SENDEMAIL"
		jBody  		:= JsonObject():New()
		jData		:= JsonObject():New()
		jBody:fromJson(cContent)
		aResTmp		:= {}
		aResponse	:= {}
		aTemp		:= {}
		jData['origin']		:= "FINA998"
		jData['imppdf'] 	:= IIF(VAZIO(jBody["imppdf"]),.F.,.T.) 
		jData['sendemail']  := IIF(VAZIO(jBody["sendemail"]),.F.,.T.) 
		jData['email']		:= jBody["email"]
		jData['emailcc']	:= jBody['emailcc']

		If jBody['receiptsByClient'] !=  Nil
			jData['imppdf'] := .F.
			jData['joindocuments']	:= .T.
			For nCont := 1 to LEN(jBody['receiptsByClient'])
				aDocuments		:= {}
				jData['latest']	:= .F.

				//Se obtienen todos los recibos de un cliente y se agregan a un objeto json
				For nX := 1 to LEN(jBody['receiptsByClient'][nCont]['receipts'])
					cRecibo	:= jBody['receiptsByClient'][nCont]['receipts'][nX]['receipt']
					cSerie 	:= jBody['receiptsByClient'][nCont]['receipts'][nX]['serie']
					jData['serie']		:= cSerie
					jData['recibo']		:= cRecibo
					jData['filial']		:= jBody['receiptsByClient'][nCont]['receipts'][nX]['branch']
					jData['cliente']	:= jBody['receiptsByClient'][nCont]['client']
					jData['client']	    := jBody['receiptsByClient'][nCont]['client']
					jData['email']		:= jBody['receiptsByClient'][nCont]['email']

					IF nX == LEN(jBody['receiptsByClient'][nCont]['receipts'])
						jData['latest']	:= .T.
					EndIF

					//Se manda llamar la FISA815 para el timbrado
					//Los parametros son cRecibo el cual es el numero de recibo, cSerie la serie del recibo, aResponse es donde se retornaran los mensajes de error o mensajes satisfactorios para posteriormente mandarlos en un Json al front-end, y jData donde se mandara informacion reelevante como por ejemplo el nombre de origin paara dejar de usar cPaisLoc
					If cPaisLoc == "MEX" .And. !jBody["compensation"]
						FISA815(cRecibo, cSerie,1,,@aResTmp,jData)	
					Else
						FISA815A(cRecibo, cSerie,,@aResTmp,.T.,jData)
					EndIf
					AADD(aResponse, {cRecibo, aClone(aResTmp)})
					aResTmp := {}
				Next
			Next
		Else
			For nCont :=1  to LEN(jBody["values"])
				cRecibo := jBody["values"][nCont]["receipt"]
				cSerie	:= jBody["values"][nCont]["serie"]
				lIsCompen:=IIF(aScan(jBody["values"][nCont]["files"], {|x| x['valuetype'] == 'CO'})==1,.T.,.F.)
				jData['serie']		:= cSerie
				jData['recibo']		:= cRecibo
				jData['cliente']	:= jBody["values"][nCont]["client"] 
				jData['filial']		:= jBody["values"][nCont]["branch"] 
				aResTmp				:= {}

				//Objeto exclusivo para la seccion de enviar en buscar recibos, dado que puede traer mas de un cliente con diferentes recibos	
				//Se manda llamar la FISA815 para el timbrado
				//Los parametros son cRecibo el cual es el numero de recibo, cSerie la serie del recibo, aResponse es donde se retornaran los mensajes de error o mensajes satisfactorios para posteriormente mandarlos en un Json al front-end, y jData donde se mandara informacion reelevante como por ejemplo el nombre de origin paara dejar de usar cPaisLoc
				jData['client']	:= JBody["client"]

				If cPaisLoc == "MEX" .And. !jBody["compensation"]
					lValid := IIF(lIsCompen,.T.,aScan(jBody["values"][nCont]["files"], {|x| x['generatecfd'] == 'N'}) == 0)
					//Metodo que verifica los titulos que contenga el recibo a timbrar sean validos para timbrar
					If validTitles(jData) .And. lValid
						if !(alltrim(jBody['params']['mv_par04']) == "") .or.  !(alltrim(jBody['params']['mv_par05']) == "") 
							If SuperGetMv("MV_SERREC",.F.,.F.) 
								aRec := separa(jBody['params']['mv_par04'],"-")
								cSerieS 	:=aRec[1]
								cReciboS 	:= aRec[2]
							Else 
								cSerieS 	:= PadR( "",GetSx3Cache("EL_SERIE","X3_TAMANHO"))
								cReciboS 	:=  jBody['params']['mv_par05']
							EndIf
							cMotC := F998ObtMot(cSerieS,cReciboS) 
						EndIf
						If !( alltrim(jBody["values"][nCont]["sersus"]) == "") .or.  !(alltrim(jBody["values"][nCont]["recsus"]) == "") 
							If SuperGetMv("MV_SERREC",.F.,.F.)
								cSerieS 	:= PadR(alltrim(jBody["values"][nCont]["sersus"]),GetSx3Cache("EL_SERSUS","X3_TAMANHO"))
								cReciboS 	:= PadR(alltrim(jBody["values"][nCont]["recsus"]) ,GetSx3Cache("EL_RECSUS","X3_TAMANHO"))
							Else 
								cSerieS 	:= PadR( "",GetSx3Cache("EL_SERIE","X3_TAMANHO"))
								cReciboS 	:= PadR(alltrim(jBody["values"][nCont]["recsus"]) ,GetSx3Cache("EL_RECSUS","X3_TAMANHO"))
							EndIf
							cMotC := F998ObtMot(cSerieS,cReciboS) 
						EndIf
						IF jData['imppdf'] == .T. 
							FISA815(cRecibo, cSerie,1,,@aResTmp,jData,cSerieS,cReciboS,cMotC)
						ELSE
							FISA815(cRecibo, cSerie,,,@aResTmp,jData,cSerieS,cReciboS,cMotC)
						ENDIF
					ELSE
						aResTmp := {{.F.,400,STR0025}} //Este recibo contiene titulos que no pueden ser timbrados o es un Recibo Anticipado (RA).
					ENDIF
				Else
					FISA815A(cRecibo, cSerie,,@aResTmp,.T.,jData)
				EndIf
				AADD(aResponse, {cRecibo, aClone(aResTmp)})
			Next
		EndIf

		For nX := 1 To  LEN(aResponse)
			cRecibo 	:= aResponse[nX][1]
			For nY := 1 To Len(aResponse[nX][2])

				If aResponse[nx][2][nY][1] == .T.
					cSuccess:= "true"
				else
					cSuccess:= "false"
				Endif
				cTemp := '{"receipt":"'+cRecibo+'","success":'+cSuccess+',"message":"'+aResponse[nx][2][nY][3]+'"}'
				AADD(aTemp,cTemp)
			Next nY
		Next

		aResponse := {}

		cResponse := "["
		For nCont := 1 to LEN(aTemp)
			If  nCont < LEN(aTemp)
				cResponse += aTemp[nCont] +","
			else
				cResponse += aTemp[nCont]
			Endif
		Next
		cResponse += "]"

		conout("JsToAdvpl cContent: "  + cValToChar(cResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cResponse)//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "CANCEL"
		jBody:= JsonObject():New()
		jBody:fromJson(cContent)
		jResponse := JsonObject():New()	
		IF ExistBlock("F998BRANU")
			aRet := ExecBlock("F998BRANU",.F.,.F.,{jBody['serie'],jBody['receipt']})
			IF aRet[1] != .T.
				jResponse['success'] := .F.
				jResponse['message'] := aRet[2]
				jResponse['receipt'] := jBody['serie']+jBody['receipt']+" - "+aRet[2]
				conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
				oWebChannel:AdvplToJS('response', cValToChar(jResponse))//Se imprime en consola
				RETURN
			ENDIF
		EndIf
		FIN998TL("CANCELRECEIPT",cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "ADVPLVIEW"  
		
		jBody:= JsonObject():New()
		jBody:fromJson(cContent)
		IF !jBody["searchFilter"]
		oStruFJT:= FWFormStruct( 2,'FJT',,.F.) //2-View
		aCpos := oStruFJT:aFields
		oMdlTab  :=  FwLoadModel("FINA887")   
		oMdlTab:SetOperation(MODEL_OPERATION_INSERT)
		oMdlTab:Activate()
		aHeader := jBody["headerForm"]:GetNames()

		FOR nI:= 1 to len(aHeader)
			IF !VAZIO(jBody["headerForm"][aHeader[nI]]) .and. oMdlTab:GetModel('FJT_MASTER'):HasField("FJT_"+UPPER(aHeader[nI])) 
				IF oMdlTab:GetModel('FJT_MASTER'):GetStruct():GetProperty("FJT_"+UPPER(aHeader[nI]),MODEL_FIELD_TIPO ) == 'D'
					oMdlTab:LoadValue('FJT_MASTER', "FJT_"+UPPER(aHeader[nI]),STOD(StrTran(jBody["headerForm"][aHeader[nI]],"-","")))
				ELSE
					oMdlTab:LoadValue('FJT_MASTER', "FJT_"+UPPER(aHeader[nI]),jBody["headerForm"][aHeader[nI]])	
				ENDIF
			EndIf
		NEXT
		EndIF
		if jBody['openView']
			IF conpad1(,,,jBody['catalog'],,,,,,jBody['value'])
				jResponse := JsonObject():New()	
				If len(acporet) > 1 .and. !jBody["searchFilter"]
					for  nI:= 1 to len(acporet)
						IF nI==1
							jResponse[jBody['property']] := IIF(ValType(acporet[nI])=="C",Rtrim(acporet[nI]),acporet[nI])
							cOrder := GetSX3Cache("FJT_"+UPPER(jBody['property']),"X3_ORDEM")
						Else
							cOrder := Soma1(cOrder)
							nCpo := aScan(aCpos, {|x| x[2] == cOrder})
							cProp := lower(Alltrim(substr(aCpos[nCpo][1],at("_",aCpos[nCpo][1])+1)))
							jResponse[cProp] := IIF(ValType(acporet[nI])=="C",Rtrim(acporet[nI]),acporet[nI])
						EndIF
					Next
				else
					jResponse[jBody['property']] := IIF (ValType(acporet[1])=="C",Rtrim(acporet[1]),acporet[1])
				EndIf
			else
				jResponse := JsonObject():New()	
			EndIF
		EndIF 
		If !jBody["searchFilter"]
			oMdlTab:DeActivate()
		EndIF
		oWebChannel:AdvplToJS('response', cValToChar(jResponse))////Se retorna la respuesta al front-end
		conout("Fin JsToAdvpl ->" + Time())
		RETURN
	elseif UPPER(Alltrim(cType)) == "DELETE" 	
		jBody:= JsonObject():New()
		jBody:fromJson(cContent)
		jResponse := JsonObject():New()	
		IF ExistBlock("F998BRBOR")
			aRet := ExecBlock("F998BRBOR",.F.,.F.,{jBody['serial'],jBody['receipt']})
			IF aRet[1] != .T.
				jResponse['success'] := .F.
				jResponse['message'] := aRet[2]
				jResponse['receipt'] := jBody['serial']+jBody['receipt']+" - "+aRet[2]
				conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
				oWebChannel:AdvplToJS('response', cValToChar(jResponse))//Se imprime en consola
				RETURN
			ENDIF
		EndIf
		FIN998TL("DELETERECEIPT",cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "SAVERECEIPT" 
		jResponse := JsonObject():New()

		FIN998TL("SAVERECEIPT",cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse["response"]))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "FPVIEW"  
		jResponse := JsonObject():New() 

		FIN998TL("FPVIEW",cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse["response"])) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse["response"]))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "PAYMENTFORM" 
		jResponse := JsonObject():New()

		FIN998TL("PAYMENTFORM",cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse["response"]))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "GETCONTENTINI" 
		jResponse := JsonObject():New()

		FIN998TL("GETCONTENTINI",,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse["response"]))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "CHECKREADER" 
		jResponse := JsonObject():New()

		FIN998TL("CHECKREADER",,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "LOCKTITLE" 
		jResponse := JsonObject():New()

		FIN998TL(UPPER(Alltrim(cType)),cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse))//Se imprime en consola
	elseIf UPPER(Alltrim(cType)) == "RECEIPTROLLBACK"
		jResponse := JsonObject():New()

		FIN998TL(UPPER(Alltrim(cType)),cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse))//Se imprime en consola
	elseIf UPPER(Alltrim(cType)) == "RECEIPTFORM"
		jBody:= JsonObject():New()
		jBody:fromJson(cContent)
		IF jBody['onInitView']
			FIN998MVC()
		ENDIF
		jResponse := JsonObject():New()

		FIN998TL(UPPER(Alltrim(cType)),cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response',  cValToChar(jResponse["response"]) )//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "TRIGGERS" 
		jResponse := JsonObject():New()
		FIN998TL("TRIGGERS",cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse["response"]))//Se imprime en consola
	elseif UPPER(Alltrim(cType)) == "COPYARCH" 
		jResponse := JsonObject():New()
		FIN998TL("COPYARCH",cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse["response"]))//Se imprime en consola
		elseif UPPER(Alltrim(cType)) == "F887ROT" 
		jResponse := JsonObject():New()
		FIN998TL("F887ROT",cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) 
	oWebChannel:AdvplToJS('response', cValToChar(jResponse["response"]))
	elseif UPPER(Alltrim(cType)) == "F998VALBX" 
		jResponse := JsonObject():New()
		FIN998TL("F998VALBX",cContent,@JResponse)
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) 
		oWebChannel:AdvplToJS('response', cValToChar(jResponse["response"]))
	elseif UPPER(Alltrim(cType)) == "F998DEFPAN" 
		jResponse := JsonObject():New()
		FIN998TL("F998DEFPAN",cContent,@JResponse)
		oWebChannel:AdvplToJS('response', cValToChar(jResponse["response"]))
	elseif UPPER(Alltrim(cType)) == "RECMVC"
		lView := .T.
		lIdente := SEL->(ColumnPos("EL_IDENTEE")) > 0
		While lView
			IF lIdente  //Si es MEX se setearan los parametros de tipo Caracter (Editable por usuario)
				Pergunte("FIN998", .F.)
				SetMVValue("FIN998","MV_PAR04","")
				SetMVValue("FIN998","MV_PAR05","")
				SetMVValue("FIN998","MV_PAR07","")
			ENDIF
			oExecView := FWViewExec():New()
			oExecView:setTitle(OemToAnsi("Recibo"))
			oExecView:SetSource("FINA887")
			oExecView:setOperation(3)
			oExecView:SetCloseOnOk({|| .t.})
			oExecView:openView(.F.)
			lView := oExecView:getButtonPress() == 0
		EndDo
		jResponse := JsonObject():New()
		jResponse['success'] := .T.
		conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
		oWebChannel:AdvplToJS('response', cValToChar(jResponse))//Se imprime en consola
	ELSEIF UPPER(Alltrim(cType)) == "TRACKER"
		jData		:= JsonObject():New()
		jResponse 	:= JsonObject():New()
		jData:fromJson(cContent)

		cBranch := PADR(ALLTRIM(jData['branch'])			,GetSx3Cache("FJT_FILIAL","X3_TAMANHO"))
		cSerie  := PADR(ALLTRIM(jData['serie'])				,GetSx3Cache("FJT_SERIE ","X3_TAMANHO"))
		cRecibo := PADR(ALLTRIM(ALLTRIM(jData['receipt']))	,GetSx3Cache("FJT_RECIBO","X3_TAMANHO")) 
		cVersion:= PADR(IIF(VAZIO(ALLTRIM(jData['version'])),"00",ALLTRIM(jData['version'])),GetSx3Cache("FJT_VERSAO","X3_TAMANHO")) 

		FJT->(DbSetorder(1)) //FJT_FILIAL+FJT_SERIE+FJT_RECIBO+FJT_VERSAO
		IF FJT->(MSSeek(cBranch+cSerie+cRecibo+cVersion))
			IF __lMetric
				FWMetrics():addMetrics("CTBC662TR_TrackContable_FINA998", {{"financeiro-protheus_cantidad-de-accesos-en-track-contablei", 1 }} )
              	FWLsPutAsyncInfo("LS006", RetCodUsr(), '05', "CTBC662TR")
			ENDIF
       		CTBC662( "FJT", FJT->(Recno()) )
			jResponse["success"] :=  .T.
			conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
			oWebChannel:AdvplToJS('response',jResponse:toJson())//Se imprime en consola
		ELSE
			jResponse["success"] :=  .F.
			jResponse["message"] :=	STR0026 //"Este recibos no contiene información en la tabla Encabezado de recibo (FJT). Se requiere que sea informada esta tabla, para más información consulte el siguiente DT:"
			jResponse["link"] := "https://tdn.totvs.com/display/PROT/3.2.1+Track+contable+y+tabla+FJT"
			conout("JsToAdvpl cContent: "  + cValToChar(jResponse)) //Se retorna la respuesta al front-end
			oWebChannel:AdvplToJS('response', jResponse:toJson())//Se imprime en consola
		ENDIF
	ENDIF
	conout("Fin JsToAdvpl ->" + Time())
Return


/*/{Protheus.doc} validTitles
Metodo que verifica los titulos de cada recibo, si un recibo contiene titulos que son validos para timbrar traera un True de lo contrario un False
@type function
@version  1
@author luis.aboytes
@since 20/2/2022
@param jData, json, parametro que contiene datos del recibo
/*/
Function validTitles(jData)
	Local lTimbrar 		:= .T.
	Local nType			:= 0
	Local aTiposDoc 	:= ""
	Local cQueryFields	:= ""
	Local cQueryWhere	:= ""
	Local cQuery		:= ""
	Local cAlias		:= ""

	If ExistBLock('F998FLOTIT')
		cAlias := GetNextAlias()

		aTiposDoc 	:= StrTokArr(ExecBlock('F998FLOTIT',.F.,.F.), "/")
		cQueryFields := " EL_TIPO,EL_NUMERO "

		cQueryWhere := " EL_FILIAL ='"		+ xFilial("SEL",jData['filial'] )+"' "
		cQueryWhere += " AND EL_RECIBO ='"	+ jData['recibo'] 	+"' "
		cQueryWhere += " AND EL_CLIORIG ='"	+ jData['cliente']	+"' "
		cQueryWhere += " AND EL_SERIE ='"	+ jData['serie']	+"' "

		cQueryWhere += " AND D_E_L_E_T_ = ' ' "

		cQuery := "SELECT "+ cQueryFields +" FROM "+ RetSqlName("SEL") +" WHERE "+ cQueryWhere

		cQuery := ChangeQuery(cQuery)
		MPSysOpenQuery(cQuery, cAlias)

		WHILE (cAlias)->(!EOF())
			nType := AScanx(aTiposDoc,{|x| ALLTRIM(x) == ALLTRIM((cAlias)->EL_TIPO)})
			IF nType != 0
				lTimbrar := .F.
			ENDIF
			(cAlias)->(DbSkip())
		ENDDO
	EndIf
Return lTimbrar



/*/{Protheus.doc} F998ObtMot
Función que obtiene el motivo del recibo a sustituir.
@type function
@author José Gonzalez
@since 10/03/2022
@version 1.0
@param cSerSus, caracter, Serie el Recibo cancelado.
@param cRecSus, caracter, Folio de Recibo cancelado.
/*/
Function F998ObtMot(cSerSus,cRecSus)
	Local aSELArea := SEL->(GetArea())
	Local cFilSEL  := xFilial("SEL")
	Local cMotivo  := "01"
	
	Default cSerSus := ""
	Default cRecSus := ""

	DbSelectArea("SEL")
	SEL->(DbSetOrder(8)) //EL_FILIAL+EL_SERIE+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO
	If SEL->(DbSeek(cFilSEL + cSerSus + cRecSus))
		cMotivo := SEL->EL_TIPAGRO
	EndIf
	RestArea(aSELArea)
Return cMotivo

/*/{Protheus.doc} Bcotrigger
Función que obtiene la moneda del Banco 
@type function
@author José Gonzalez
@since 01/01/2022
@version 1.0
/*/                                                                             
Function Bcotrigger(cValor) 

local cresp := "1"
local aCampos :={}
local cCod
local cAgen
local cNum
default cValor := ""

If !(cValor == "")
	aCampos := Separa(cValor,"-")
	cCod 	:= PadR(  aCampos[1] ,GetSx3Cache("A6_COD","X3_TAMANHO"))
	cAgen	:= PadR(  aCampos[2] ,GetSx3Cache("A6_AGENCIA","X3_TAMANHO"))
	cNum	:= PadR(  aCampos[3] ,GetSx3Cache("A6_NUMCON","X3_TAMANHO"))

	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	If  SA6->(MsSeek(xFilial("SA6")+cCod+cAgen+cNum )	)		
		cresp := alltrim(STR(SA6->A6_MOEDA))
	EndIf
EndIf

Return cresp

/*/{Protheus.doc} BancosRec
Función que regresa el campo de Banco Agencia y Cuenta para el disparador del campo virtual buscar bancos
@type function
@author José Gonzalez
@since 02/02/2023
@version 1.0
/*/                                                                    
Function BancosRec(cValor, cCampo)
Local aSepara := separa(cValor,"|")
Local cReturn := ""

	If cCampo == "1"
		If len(aSepara)>0
			cReturn := aSepara[1]
		EndIF
	ElseIf cCampo == "2"
		If len(aSepara)>1
			cReturn := aSepara[2]
		EndIf
	ElseIf cCampo == "3"
		If len(aSepara)>2
			cReturn := aSepara[3]
		EndIf
	EndIf

Return cReturn

/*/{Protheus.doc} docReten
Función que regresa el campo de Serie documento, documento y cuota (PAR y PER)
@type function
@version  1
@author luis.aboytes
@since 8/3/2023
/*/
Function docsReten(cValor, cCampo)
Local aSepara := separa(cValor,"-")
Local cReturn := ""

	If cCampo == "1"
		If len(aSepara)>0
			cReturn := aSepara[1]
		EndIF
	ElseIf cCampo == "2"
		If len(aSepara)>1
			cReturn := aSepara[2]
		EndIf
	ElseIf cCampo == "3"
		If len(aSepara)>2
			cReturn := aSepara[3]
		EndIf
	EndIf
Return cReturn

/*/{Protheus.doc} FinCondTp
Función que regresa la cadena para el disparador de EL_TIPO
@type function
@author José Gonzalez
@since 03/01/2023
@version 1.0
/*/  
Function FinCondTp(cvalid)
local cret := ""
local lRCOPGER		:= !cPaisLoc $ "BRA|VEM|URU|SAL|TRI"
local cCredMed	:=	""
local cCredInm	:=	""
Local bFilt1 	:= {|| ((FJS->FJS_RCOP == "1") 	.and. (FJS->FJS_CARTE $ "1|3") .and. (FJS->FJS_FILIAL == xFilial("FJS")))} 
Local bFilt2 	:= {|| ((FJS->FJS_RCOP == "2") 	.and. (FJS->FJS_CARTE $ "1|3") .and. (FJS->FJS_FILIAL == xFilial("FJS")))} 
Local cChave	:= xFilial("FJS")
Local cAlias	:= "FJS"
Local cCampo	:= "FJS_TIPO" 
Local nOrder	:= 1 
Default cvalid := ""  

If cpaisloc == "ARG" 
	cCredMed	:=	FinGetTipo(bFilt1,cAlias,cChave,cCampo,nOrder)
	cCredInm	:=	FinGetTipo(bFilt2,cAlias,cChave,cCampo,nOrder)
	cCredMed	:=	IIf(Empty(cCredMed),GetSESNew("CH ","3"),cCredMed)
	cCredInm	:=	IIf(Empty(cCredInm),"TF |EF |CC |CD ",cCredInm)
Else
	cCredMed	:=	Iif(lRCOPGER, GetSESTipos({|| ES_RCOPGER == "1"},"1"), "")
	cCredInm	:=	Iif(lRCOPGER, GetSESTipos({|| ES_RCOPGER == "2"},"1"), "")
	cCredMed	:=	IIf(Empty(cCredMed),GetSESNew("CH |CC ","3") ,cCredMed)
	cCredInm	:=	IIf(Empty(cCredInm),"TF |EF |CC |CD ",cCredInm)
EndIF

IF UPPER(cvalid) == "CREDINM"
	cret := cCredInm
elseif  UPPER(cvalid) == "CREDMED"
	cret := cCredMed
EndIF

Return cret

/*/{Protheus.doc} reasonsBx
Funcion que retorna los motivos de baja en los titulos
@type function
@version  1
@author luis.aboytes
@since 29/8/2023
/*/

Function reasonsBx(nOpcion)
Local aMotBx 	:= {} as Array
Local aDescMotbx:= {} as Array
Local i := 1
Default nOpcion := 1

aMotBx := ReadMotBx() 

If len(aMotBx) > 0
	For i := 1 to len(aMotBx)
		If substr(aMotBx[i],34,01) == "A" .or. substr(aMotBx[i],34,01) =="R"
			IF  SEL->(ColumnPos('EL_FECTIMB')) > 0
				If !(substr(aMotBx[i],01,03) $ "FAT|LOJ|LIQ|CEC|CMP|STP")
					IIF(nOpcion==1,AADD( aDescMotbx,substr(aMotBx[i],07,10)),AADD(aDescMotbx,substr(aMotBx[i],01,03)))
				EndIf
			ELSE
				IIF(nOpcion==1,AADD( aDescMotbx,substr(aMotBx[i],07,10)),AADD(aDescMotbx,substr(aMotBx[i],01,03)))			
			ENDIF		
		EndIf
	Next
EndIf
	
Return aDescMotbx 


/*/{Protheus.doc} FA998Vld
Función que valida si el numero de recibo ya existe
@type function
@author José Gonzalez
@since 29/05/2024
@version 1.0
/*/  
Function FA998Vld( cSerie , cRecibo )
Local lRet 	:= .T. 
Local aArea		:= GetArea() 
Default cSerie  :=""
Default cRecibo :=""

DbSelectArea("SEL")
SEL->(DbSetorder(8))
If SEL->(MSSeek(xFilial("SEL")+cSerie+cRecibo))
	Help(" ",1,"EXISTNUM")
	Return(.F.)
EndIf

RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} FIN998MVC
@type function
@version  1
@author luis.aboytes
@since 8/1/2025
@return variant, return_description
/*/
Static Function FIN998MVC()
Local dDate      as date
Local oProfile   as object
Local aLoad      as array
Local cShow      as character
Local lCheck     as logical
Local nPauseDays 	:= 14 // número de días que el mensaje puede ser deshabilitado
Local cExpirFunc 	:="FIN998MVC"     

dDate := dDataBase
oProfile := FwProFile():New()
oProfile:SetTask(cExpirFunc) //nombre de la sesión
oProfile:SetType(cExpirFunc) //Valor
aLoad := oProfile:Load()
If Empty(aLoad)
	cShow := "00000000"
Else
	cShow := aLoad[1]
Endif
// restablece el control de nPauseDays días y vuelve a mostrar la pantalla de advertencia
If cShow <> "00000000" .and. STOD(cShow) + nPauseDays <= dDate
	cShow := "00000000"
	oProfile:SetProfile({cShow})
	oProfile:Save()
ENDIF
If cShow == "00000000"
	lCheck := DLG998MVC()
	If lCheck
		cShow := dtos(dDataBase)	
		oProfile:SetProfile({cShow})
		oProfile:Save()
	EndIf
EndIf
oProfile:Destroy()
aLoad := aSize(aLoad,0)

RETURN

/*/{Protheus.doc} DLG998MVC
Función que contiene la estructura del mensaje a visualizar para descontinuación de PO UI de nuevo recibo
@type function
@version  1
@author luis.aboytes
@since 8/1/2025
@return variant, return_description
/*/
Static Function DLG998MVC()
Local oSay1    as object
Local oSay2    as object
Local oSay3    as object
Local oSay4    as object
Local oCheck1  as object
Local oModal   as object
Local cMsg1    as character
Local cMsg2    as character
Local cMsg3    as character
Local cMsg4    as character
Local lCheck   as logical
Local cWeb	:= "https://tdn.totvs.com/x/LwAhN" 

oModal := FWDialogModal():New()
oModal:SetCloseButton( .F. )
oModal:SetEscClose( .F. )
oModal:setTitle(STR0018) //"Aviso importante"
oModal:setSize(150, 250)
oModal:createDialog()
oModal:AddButton(STR0020, {||oModal:DeActivate()},STR0020, , .T., .F., .T., ) //"Confirmar"
oContainer := TPanel():New( ,,, oModal:getPanelMain() )
oContainer:Align := CONTROL_ALIGN_ALLCLIENT

cMsg1 := STR0019  //'El nuevo modelo de captura del recibo está disponible activando el parámetro  MV_RECMVC, para más información consulte el enlace '
oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
If ! Empty(cWeb)
	cMsg2 := "<b><a target='_blank' href='"+cWeb+"'> "
	cMsg2 += Alltrim(STR0021) //'Nuevo Recibo en MVC '
	cMsg2 += " </a></b>."
	cMsg2 += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"
	oSay2 := TSay():New( 25,10,{||cMsg2 },oContainer,,,,,,.T.,,,200,20,,,,,,.T.)
	oSay2:bLClicked := {|| MsgRun(  STR0012, "URL",{|| ShellExecute("open",cWeb,"","",1) } ) } //'Abriendo enlace'
EndIf
cMsg3 := STR0022  //'A partir del 2 de Junio del 2025 será obligatorio el uso del nuevo modelo de captura y no habrá mantenimiento  para el modelo en POUI.' 
oSay3 := TSay():New( 40,10,{||cMsg3},oContainer,,,,,,.T.,,,225,20,,,,,,.T.)

cMsg4 := STR0024 //"En 2025 cualquier solicitud de mejora será realizada únicamente en el nuevo modelo de captura"
oSay4 := TSay():New( 60,10,{||cMsg4 },oContainer,,,,,,.T.,,,200,20,,,,,,.T.)

lCheck := .F.
oCheck1 := TCheckBox():New(85,10, STR0023,{|x|If(Pcount()==0,lCheck,lCheck:=x)},oContainer,200,20,,,,,,,,.T.,,,) //"Desactivar este mensaje por los próximos  14 días"
oModal:Activate()

Return lCheck

/*/{Protheus.doc} FIN998BUSC
	Presenta la pantalla de una Actualización de diccionario de datos necesaria
	@type  Function
	@author josé Gonzalez
	@since 19/07/2024
	@version 1.0
/*/
Static Function FIN998BUSC()
Local dDate      as date
Local oProfile   as object
Local aLoad      as array
Local cShow      as character
Local lCheck     as logical
Local nPauseDays 	:= 10 // número de días que el mensaje puede ser deshabilitado
Local cExpirFunc 	:="FINA998BUS"    

dDate := dDataBase
oProfile := FwProFile():New()
oProfile:SetTask(cExpirFunc) //nombre de la sesión
oProfile:SetType(cExpirFunc) //Valor
aLoad := oProfile:Load()
If Empty(aLoad)
	cShow := "00000000"
Else
	cShow := aLoad[1]
Endif
// restablece el control de nPauseDays días y vuelve a mostrar la pantalla de advertencia
If cShow <> "00000000" .and. STOD(cShow) + nPauseDays <= dDate
	cShow := "00000000"
	oProfile:SetProfile({cShow})
	oProfile:Save()
ENDIF
If cShow == "00000000"
	lCheck := DLG998BUSC()
	If lCheck
		cShow := dtos(dDataBase)	
		oProfile:SetProfile({cShow})
		oProfile:Save()
	EndIf
EndIf
oProfile:Destroy()
aLoad := aSize(aLoad,0)

RETURN

/*/{Protheus.doc} DLG998BUSC
	Presenta la pantalla de una Actualización de diccionario de datos necesaria
	@type  Function
	@author Jose Gonzalez
	@since 19/07/2024
	@version 1.0
/*/
Static Function DLG998BUSC()
local oSay1    as object
local oSay2    as object
local oSay3    as object
local oSay4    as object
local oCheck1  as object
local oModal   as object
Local cMsg1    as character
Local cMsg2    as character
Local cMsg3    as character
Local cMsg4    as character
Local lCheck   as logical
local cEndWeb	:= "https://tdn.totvs.com/x/dZMiMw" 

oModal := FWDialogModal():New()
oModal:SetCloseButton( .F. )
oModal:SetEscClose( .F. )
oModal:setTitle(STR0005) //"Actualización de diccionario de datos necesaria"
oModal:setSize(150, 200)//establece la altura y el ancho de la ventana en píxeles
oModal:createDialog()
oModal:AddButton( STR0006, {||oModal:DeActivate()}, STR0006, , .T., .F., .T., ) //"Confirmar"
oContainer := TPanel():New( ,,, oModal:getPanelMain() )
oContainer:Align := CONTROL_ALIGN_ALLCLIENT

cMsg1 := STR0013 // "Se identifica que no existe el grupo de preguntas FINA998BUS
cMsg2 := STR0014 //"en el ambiente a partir de ajustes en la rutina de Totvs Recibos 
cMsg3 := STR0015 //"para mejorar los filtros de buscar Recibo"
cMsg4 := (STR0010)//Para conocer más vea el punto 04 del siguiente

oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
oSay2 := TSay():New( 20,10,{||cMsg2 },oContainer,,,,,,.T.,,,200,20,,,,,,.T.)
oSay3 := TSay():New( 30,10,{||cMsg3},oContainer,,,,,,.T.,,,200,20,,,,,,.T.)
If ! Empty(cEndWeb)
	cMsg4 += "<b><a target='_blank' href='"+cEndWeb+"'> "
	cMsg4 += Alltrim( STR0011) // "haga clic aquí"
	cMsg4 += " </a></b>."
	cMsg4 += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"
	oSay4 := TSay():New( 45,10,{||cMsg4 },oContainer,,,,,,.T.,,,200,20,,,,,,.T.)
	oSay4:bLClicked := {|| MsgRun(  STR0012, "URL",{|| ShellExecute("open",cEndWeb,"","",1) } ) } // "Abriendo el enlace... Espere..."
EndIf
lCheck := .F.
oCheck1 := TCheckBox():New(65,10,STR0016 ,{|x|If(Pcount()==0,lCheck,lCheck:=x)},oContainer,200,20,,,,,,,,.T.,,,) // "No presentar este mensaje en los próximos 10 días."
oModal:Activate()

Return lCheck

/*/{Protheus.doc} FA998VlSAQ
Función que valida si el Cobrador tiene estatus Activo o Inactivo
@type function
@param  Cadena, Código del Cobrador.
@return Lógico, Indica si el Cobrador está activo o no.
@author Oswaldo Diego
@since 16/05/2025
@version 1.0
/*/  
Function FA998VlSAQ( cCobrador )
	
	Local lRet 	      := .T.
	Local aArea	      := GetArea()
	Default cCobrador := ""

	If SAQ->(ColumnPos("AQ_STATUS")) > 0 //Se realiza validación solo si el campo AQ_STATUS existe.
		DbSelectArea("SAQ")
		SAQ->(DbSetorder(1)) //AQ_FILIAL+AQ_COD
		If SAQ->(MSSeek(xFilial("SAQ")+cCobrador))
			If SAQ->AQ_STATUS == '2'
				lRet := .F.
				Help("",1,"INACTCOL") //"Cobrador Inactivo"
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return(lRet)
