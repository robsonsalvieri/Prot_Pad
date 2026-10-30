#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PONA350API.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#include 'PROTHEUS.CH'
#Include 'FWMVCDef.ch'
#include "fileio.ch"
#INCLUDE "TBICODE.CH"

#DEFINE PAGESIZE_DEFAULT 2000
#DEFINE PAGE_DEFAULT     1

#DEFINE TAB 			 CHR ( 13 ) + CHR ( 10 )

/*
{Protheus.doc} allowanceControl
API de Controle de Abonos do processo de Ponto Eletronico                              
@author  Wesley Alves Pereira
@since   09/03/2020
@version 12.1.27
*/

WSRESTFUL allowanceControl DESCRIPTION STR0001 FORMAT "application/json" //"Serviço genérico para retorno das informações de Controle de Abonos"
	WSDATA companyId	 As Character
	WSDATA branchId	     As Character
	WSDATA product	     As Character
	WSDATA providerType  As Character
	WSDATA page			 As Integer Optional
	WSDATA pageSize		 As Integer Optional
	WSDATA dateModified	 As Character  Optional
	WSDATA allowanceId As Character

	WSMETHOD POST; 	
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0002)); // "Insere um abono no módulo de Ponto Eletrônico"
	WSSYNTAX "/api/rh/v1/allowanceControl" ;
	PATH "/api/rh/v1/allowanceControl" ;
	PRODUCES 'application/json;charset=utf-8'; 
	TTALK "v1" 

	WSMETHOD PUT allowanceId ;
  	DESCRIPTION EncodeUTF8(OemToAnsi(STR0004)) ; 
  	WSSYNTAX "/api/rh/v1/allowanceControl/{allowanceId}" ; //"Altera um abono no módulo de Ponto Eletrônico"
  	PATH "/api/rh/v1/allowanceControl/{allowanceId}" ;
  	PRODUCES 'application/json;charset=utf-8' ;
  	TTALK "v1"

	WSMETHOD DELETE allowanceId ;
  	DESCRIPTION EncodeUTF8(OemToAnsi(STR0003)) ; //"Deleta um abono no módulo de Ponto Eletrônico"
  	WSSYNTAX "/api/rh/v1/allowanceControl/{allowanceId}" ;
  	PATH "/api/rh/v1/allowanceControl/{allowanceId}" ;
  	PRODUCES 'application/json;charset=utf-8' ;
  	TTALK "v1"


END WSRESTFUL

// Insere um abono dentro do módulo de Ponto Eletrônico
/*/{Protheus.doc} POST
Método responsável pela inclusão de um registro de abono com valores passados como paramêtro no Header do REST/JSON
@author  Wesley Alves Pereira
@since   09/03/2020
@version 12.1.27
@return return, return_description
/*/
WSMETHOD POST HEADERPARAM authorization WSREST allowanceControl 
Local aParFun	:= {}					As Array
Local aParCod	:= {}					As Array
Local aCabec	:= {}					As Array
Local aItens	:= {}					As Array
Local aLinha	:= {}					As Array
Local aInfor	:= {}					As Array
Local aRet		:= {}					As Array
Local cBody		:= ""					As Character
Local cRecebe	:= ""					As Character
Local cRetorno	:= ""					As Character 
Local cId		:= ""					As Character 
Local cParEmp	:= ""					As Character
Local cParFil	:= ""					As Character
Local cParIDt	:= ""					As Character
Local cParFDt	:= ""					As Character
Local cParIHr	:= ""					As Character
Local cParFHr	:= ""					As Character
Local nOpca 	:= 3					As Integer
Local lRetorno	:= .F.					As Logical
Local oJson		:= JsonObject():New()	As Object

BEGIN SEQUENCE

oJson		:= JsonObject():New()
cBody		:= Self:GetContent()
lRetorno	:= .F.
lCompact	:= .F. 
cRecebe		:= oJson:FromJSON(EncodeUTF8(NoAcento(cBody)))
aCampos		:= oJson:GetNames()
	
If cRecebe != Nil  .Or. Len(aCampos) == 0  
	fSendMess(400, STR0005, .T., 400, STR0015) // STR0005: "Não foi possível reconhecer o pacote recebido. Verifique a informação e envie novamente."
	Return .F.
EndIf

aRet := fValidaDados(nOpca, @oJson)

If !aRet[1]
	fSendMess(aRet[2], aRet[3], .T., aRet[2], aRet[4])
	Return .F.
Else
	cParEmp := oJson["companyId"]
	cParFil := oJson["branchId"]
	aParFun := StrTokArr2(oJson["employeeId"], "|", .T.) 
	aParCod := StrTokArr2(oJson["code"], "|", .T.)
	cParIDt := oJson["startDate"]
	cParFDt := oJson["endDate"]
	cParIHr := oJson["startTime"]
	cParFHr := oJson["endTime"]

	aCabec := {}
	aItens := {}
	aLinha := {}
	aInfor := {}

	aAdd(aInfor, fClearDate(cParIDt))
	aAdd(aInfor, Val(StrTran(cParIHr, ":", ".")))
	aAdd(aInfor, fClearDate(cParFDt))
	aAdd(aInfor, Val(StrTran(cParFHr, ":", ".")))

	aadd(aCabec, {"RF0_FILIAL" , aParFun[2],})
	aadd(aCabec, {"RF0_MAT"    , aParFun[3],})
	aadd(aLinha, {"RF0_DTPREI" , aInfor[1],})
	aadd(aLinha, {"RF0_HORINI" , aInfor[2],})
	aadd(aLinha, {"RF0_DTPREF" , aInfor[3],})
	aadd(aLinha, {"RF0_HORFIM" , aInfor[4],})
	aadd(aLinha, {"RF0_CODABO" , aParCod[3],})

	aadd(aItens, aLinha)

	aRet := fVldJob(aCabec, aItens, aInfor, aParFun, aParCod, nOpca, {})

	If aRet[1]
		cId := cParEmp +";"
		cId += cParFil +";"
		cId += aParFun[1] + "|" + aParFun[2] + "|" + aParFun[3] +";"
		cId += cParIDt + ";"
		cId += cParIHr + ";"
		cId += aParCod[1] + "|" + aParCod[2] + "|" + aParCod[3] +";" 

		lRetorno := .T.
		cRetorno :=  fSendJson(oJson, cId)
		::SetResponse(cRetorno)
	Else
		fSendMess(aRet[2], aRet[3], .T., aRet[2], aRet[4])
		lRetorno := .F.
	EndIf
EndIf
END SEQUENCE

Return lRetorno

// Altera um abono dentro do módulo de Ponto Eletrônico
/*/{Protheus.doc} PUT
Método responsável pela alteração de um registro de abono com valores passados como paramêtro no Header do REST/JSON
@author  Wesley Alves Pereira
@since   13/03/2020
@version 12.1.27
@return return, return_description
/*/

WSMETHOD PUT allowanceId WSREST allowanceControl
Local aUrlParam		:= ::aUrlParms
Local aParFun		:= {}					As Array
Local aParCod		:= {}					As Array
Local aRetVld		:= {}					As Array
Local aRetorno		:= {}					As Array
Local aInfor		:= {}					As Array
Local aParam		:= {}					As Array
Local aCampos		:= {}					As Array
Local cBody			:= ""					As Character
Local cRecebe		:= ""					As Character
Local cId			:= ""					As Character
Local cRetDat		:= ""					As Character
Local cRetHor		:= ""					As Character
Local cParEmp		:= ""					As Character
Local cParFil		:= ""					As Character
Local cParIDt		:= ""					As Character
Local cParFDt		:= ""					As Character
Local cParIHr		:= ""					As Character
Local cParFHr		:= ""					As Character
Local cEmpPar		:= ""					As Character
Local cFilPar		:= ""					As Character
Local cDatPar		:= ""					As Character
Local cHorPar		:= ""					As Character
Local cEmpFun		:= ""					As Character
Local cFilFun		:= ""					As Character
Local cCodFun		:= ""					As Character
Local nOpca			:= 4					As Integer
Local lRetorno		:= .F.					As Logical
Local oJson			:= JsonObject():New()	As Object

BEGIN SEQUENCE

If Len(aUrlParam) == 0 .Or. Empty(aUrlParam[1])
	fSendMess(400, STR0018, .T., 400, STR0015) // STR0018: "Informação allowanceId ausente ou inválida."
	Return .F.
EndIf

aRetorno := fValidaChave(aUrlParam[1])

If Len(aRetorno) == 0
	fSendMess(400, STR0018, .T., 400, STR0015) // STR0018: "Informação allowanceId ausente ou inválida."
	Return .F.
EndIf

oJson		:= JsonObject():New()
cBody		:= Self:GetContent()
lRetorno	:= .F.
cRecebe		:= oJson:FromJSON(EncodeUTF8(NoAcento(cBody)))
aCampos		:= oJson:GetNames()

If cRecebe != Nil  .Or. Len(aCampos) == 0  
	fSendMess(400, STR0005, .T., 400, STR0015) // STR0005: "Não foi possível reconhecer o pacote recebido. Verifique a informação e envie novamente."
	Return .F.
EndIf

aRetVld := fValidaDados(nOpca, @oJson)

If !aRetVld[1]
	fSendMess(aRetVld[2], aRetVld[3], .T., aRetVld[2], aRetVld[4])
	Return .F.
Else
	cParEmp := oJson["companyId"]
	cParFil := oJson["branchId"]
	aParFun := StrTokArr2(oJson["employeeId"], "|", .T.) 
	aParCod := StrTokArr2(oJson["code"], "|", .T.)
	cParIDt := oJson["startDate"]
	cParFDt := oJson["endDate"]
	cParIHr := oJson["startTime"]
	cParFHr := oJson["endTime"]

	cEmpPar := aRetorno[1]
	cFilPar := aRetorno[2]
	cDatPar := aRetorno[3]
	cHorPar := aRetorno[8]
	cEmpFun := aRetorno[5]
	cFilFun := aRetorno[6]
	cCodFun := aRetorno[7]

	aCabec := {}
	aItens := {}
	aLinha := {}
	aInfor := {}

	If !Empty(cParIDt)
		aAdd(aInfor,fClearDate(cParIDt))
	Else 
		aAdd(aInfor,"")
	EndIf

	If !Empty(cParIHr)
		aAdd(aInfor,Val(StrTran(cParIHr,":",".")))
	Else 
		aAdd(aInfor,"")
	EndIf

	If !Empty(cParFDt)
		aAdd(aInfor,fClearDate(cParFDt))
	Else 
		aAdd(aInfor,"")
	EndIf

	If !Empty(cParFHr)
		aAdd(aInfor,Val(StrTran(cParFHr,":",".")))
	Else 
		aAdd(aInfor,"")
	EndIf

	aParam := {}
	
	If !Empty(cDatPar)
		cRetDat := cDatPar
		aAdd(aParam,fClearDate(cDatPar))
	Else 
		aAdd(aParam,"")
	EndIf

	If !Empty(cHorPar)
		cRetHor := cHorPar
		aAdd(aParam,Val(StrTran(cHorPar,":",".")))
	Else 
		aAdd(aParam,"")
	EndIf

	aadd(aCabec,{"RF0_FILIAL", cFilFun, Nil})
	aadd(aCabec,{"RF0_MAT", cCodFun, Nil})

	aAdd(aLinha, {"LINPOS", "RF0_DTPREI+RF0_HORINI", aParam[1], aParam[2]}) // Informações para posicionar no registro correto

	If ! Empty(cParIDt)
		aadd(aLinha,{"RF0_DTPREI" , fClearDate(cParIDt),})
	Else
		aadd(aLinha,{"RF0_DTPREI" , RF0->RF0_DTPREI,})
	EndIf

	If ! Empty(cParIHr)
		nValor1 := Val(StrTran(cParIHr,":","."))
		aadd(aLinha,{"RF0_HORINI" , nValor1,})
	Else
		aadd(aLinha,{"RF0_HORINI" , RF0->RF0_HORINI,})
	EndIf

	If ! Empty(cParFDt)
		aadd(aLinha,{"RF0_DTPREF" , fClearDate(cParFDt),})
	Else
		aadd(aLinha,{"RF0_DTPREF" , RF0->RF0_DTPREF,})
	EndIf

	If ! Empty(cParFHr)
		nValor2 := Val(StrTran(cParFHr,":","."))
		aadd(aLinha,{"RF0_HORFIM" , nValor2,})
	Else
		aadd(aLinha,{"RF0_HORFIM" , RF0->RF0_HORFIM,})
	EndIf

	If ! Empty(aParCod)
		aadd(aLinha,{"RF0_CODABO" , aParCod[3],})
	Else
		aadd(aLinha,{"RF0_CODABO" , RF0->RF0_CODABO,})
	EndIf

	aadd(aItens, aLinha)

	aRet := fVldJob(aCabec, aItens, aInfor, aParFun, aParCod, nOpca, aParam)

	If aRet[1]
		cId := cParEmp +";"
		cId += cParFil +";"
		cId += aParFun[1] + "|" + aParFun[2] + "|" + aParFun[3] +";"
		cId += cParIDt + ";"
		cId += cParIHr + ";"
		cId += aParCod[1] + "|" + aParCod[2] + "|" + aParCod[3] +";" 

		lRetorno := .T.
		cRetorno :=  fSendJson(oJson, cId)
		::SetResponse(cRetorno)
	Else
		lRetorno := .F.
		fSendMess(aRet[2], aRet[3], .T., aRet[2], aRet[4])
	EndIf
EndIf
END SEQUENCE

Return lRetorno

// Altera um abono dentro do módulo de Ponto Eletrônico
/*/{Protheus.doc} DELETE
Método responsável pela exclusão de um registro de abono com valores passados como paramêtro no Header do REST/JSON
@author  Wesley Alves Pereira
@since   09/03/2020
@version 12.1.27
@return return, return_description
/*/
WSMETHOD DELETE allowanceId WSREST allowanceControl
Local aUrlParam	:= ::aUrlParms
Local lRetorno	:= .F.
Local aRetorno	:= {}
Local aParFun	:= {}
Local cEmpPar	:= ""
Local cFilPar	:= ""
Local cDatPar	:= ""
Local cHorPar	:= ""
Local cEmpFun	:= ""
Local cFilFun	:= ""
Local cCodFun	:= ""
Local cRetorno	:= ""
Local aInfor	:= {}
Local nOpca		:= 5

BEGIN SEQUENCE

If Len(aUrlParam) == 0 .Or. Empty(aUrlParam[1])
	fSendMess(400, STR0018, .T., 400, STR0015) // STR0018: "Informação allowanceId ausente ou inválida."
	Return .F.
EndIf

aRetorno := fValidaChave(aUrlParam[1])

If Len(aRetorno) == 0
	fSendMess(400, STR0018, .T., 400, STR0015) // STR0018: "Informação allowanceId ausente ou inválida."
	Return .F.
EndIf

cEmpPar := aRetorno[1]
cFilPar := aRetorno[2]
cDatPar := aRetorno[3]
cHorPar := aRetorno[8]
cEmpFun := aRetorno[5]
cFilFun := aRetorno[6]
cCodFun := aRetorno[7]

aCabec := {}
aItens := {}
aLinha := {}
aInfor := {}

aAdd(aInfor, fClearDate(cDatPar))
aAdd(aInfor, Val(StrTran(cHorPar, ":", ".")))

aAdd(aCabec, {"RF0_FILIAL", cFilFun, NIL})
aAdd(aCabec, {"RF0_MAT", cCodFun, NIL})
aAdd(aLinha, {"LINPOS", "RF0_DTPREI+RF0_HORINI", aInfor[1], aInfor[2]}) // Informações para posicionar no registro correto
aAdd(aLinha, {"AUTDELETA", "S", NIL}) // Marca o registro como deletado

aAdd(aItens, aLinha)

aAdd(aParFun, cEmpFun)
aAdd(aParFun, cFilFun)
aAdd(aParFun, cCodFun)

aRet := fVldJob(aCabec, aItens, aInfor, aParFun, {}, nOpca, {})

If aRet[1]
	lRetorno := .T.
	cRetorno := fSendDelete(STR0017) //"Operação realizada com sucesso!"
	::SetResponse(cRetorno)
Else
	lRetorno := .F.
	fSendMess(aRet[2], aRet[3], .T., aRet[2], aRet[4])
EndIf
END SEQUENCE

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendMess
Gera as mensagens para o retorno REST/JSON
@author  Wesley Alves Pereira
@since   09/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSendMess(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

DEFAULT nCode := 500
DEFAULT cMessage := STR0006
DEFAULT lJson := .T.
DEFAULT nStatus := 500
Default cDetailMsg := STR0006
Default cHelpUrl := "https://tdn.totvs.com/x/BJuMHw"
DEFAULT aDetails := {}

SetRestFault(nCode,EncodeUTF8(NoAcento(OemToAnsi(cMessage))),lJson,nStatus,EncodeUTF8(NoAcento(OemToAnsi(cDetailMsg))),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendJson
Gera as mensagens para o retorno REST/JSON
@author  Wesley Alves Pereira
@since  12/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSendJson(ojson,cId)
Local cJson		:= ""
Local lcompact	:= .F.

If Type("Self:GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(Self:GetHeader('Accept-Encoding') )        
	lCompact := .T.
EndIf

ojson["id"] := cId

If(lCompact)    	
	cJson := fCompress(ojson)				
Else
	cJson :=  FWJsonSerialize(ojson, .F., .F., .T.)   	
Endif

Return (cJson)
//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendDelete
Gera as mensagens para o retorno REST/JSON
@author  Wesley Alves Pereira
@since  12/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSendDelete(cMessage)
Local cJsonObj := "JsonObject():New()"
Local oMsgReturn	:= &cJsonObj
Local cJson			:= ""
Local lcompact := .F.

If Type("Self:GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(Self:GetHeader('Accept-Encoding') )        
	lCompact := .T.
EndIf

oMsgReturn["code"] 		:= "200"
oMsgReturn["description"] := cMessage

If(lCompact)    	
	cJson := fCompress(oMsgReturn)				
Else
	cJson :=  FWJsonSerialize(oMsgReturn, .F., .F., .T.)   	
Endif

Return (cJson)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendPut
Gera as mensagens para o retorno REST/JSON
@author  Wesley Alves Pereira
@since  12/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fSendPut(cMessage,oJson)
Local cJsonObj := "JsonObject():New()"
Local oMsgReturn	:= &cJsonObj
Local cJson			:= ""
Local lcompact := .F.

If Type("Self:GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(Self:GetHeader('Accept-Encoding') )        
	lCompact := .T.
EndIf

oMsgReturn["code"] 		:= "200"
oMsgReturn["description"] := cMessage

If(lCompact)    	
	cJson := fCompress(oMsgReturn)				
Else
	cJson :=  FWJsonSerialize(oMsgReturn, .F., .F., .T.)   	
Endif

Return (cJson)

/*/{Protheus.doc} fValidaDados
//Tratamento e validação de dados do Json
@author  Wesley Alves Pereira
@since   09/03/2020
@version 12.1.27
@param nOpc,integer, 3 = Insert; 4 = Upsert
@param json,object, variável de objeto que contém os dados de json
@return aRet, array, Retorna um array com os dados validados e buscados ou mensagens de erro
/*/
Static Function fValidaDados(nOpc, oJson)
Local aNames		:= {}				As Array		// array de nomes das propriedades
Local aCpoObt		:= {}				As Array
Local aCode     	:= {}				As Array
Local aFunc     	:= {}				As Array
Local aRet 			:= {.T., 200, ""}	As Array
Local cCpoObt		:= ""				As Character	// Campos obrigatórios
Local cMsgRest		:= ""				As Character	// Mensagem de erro
Local ctmpCia		:= ""				As Character
Local ctmpfil		:= ""				As Character
Local ctmpDtI		:= ""				As Character
Local ctmpDtF		:= ""				As Character
Local ctmpHrI		:= ""				As Character
Local ctmpHrF		:= ""				As Character
Local nItem			:= 0				As Integer		// Posição do item para varredura

Default oJson := JsonObject():New()

cCpoObt	:= "code/employeeId/startDate/endDate/startTime/endTime/companyId/branchId/"

aNames		:= oJson:GetNames()
aCpoObt		:= StrToArray(cCpoObt,"/") 
cMsgRest	:= ""

If nOpc <> 4
	// Verifica TAGS obrigatórias	
	For nItem:= 1 to Len(aCpoObt)
		If aScan(aNames, {|x| UPPER(x) == UPPER(aCpoObt[nItem])}) == 0
			cMsgRest +=  OemToAnsi(STR0007)+ aCpoObt[nItem] +OemToAnsi(STR0008) + CRLF // "Verifique se a TAG ("") foi informada, pois ela é obrigatória para manipulação do registro de abono."
			aRet := {.F., 400, cMsgRest, STR0015}
			Return aRet
		EndIf
	Next nItem

	// Verifica TAGS preenchidas
	For nItem:= 1 to Len(aNames)
		If aScan(aCpoObt,{|x| UPPER(x) == UPPER(aNames[nItem])}) > 0
			If (oJson[aNames[nItem]] == NIL .Or. Empty(oJson[aNames[nItem]]))
				cMsgRest +=  OemToAnsi(STR0010)+ aNames[nItem] +OemToAnsi(STR0008) + CRLF // "Verifique se a TAG ("") foi informada, pois ela é obrigatória para manipulação do registro de abono."
				aRet := {.F., 400, cMsgRest, STR0015}
				Return aRet
			EndIf
		EndIf 
	Next nItem
EndIf

aCode := {}
aFunc := {}

For nItem:= 1 to Len(aNames)
	If UPPER(aNames[nItem]) $ "COMPANYID"
		ctmpCia := oJson[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) =="BRANCHID" 
		ctmpFil := oJson[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) $ "STARTDATE"
		ctmpDtI := oJson[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) $ "ENDDATE"
		ctmpDtF := oJson[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) $ "STARTTIME"
		ctmpHrI := oJson[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) $ "ENDTIME"
		ctmpHrF := oJson[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) $ "EMPLOYEEID" 
		If !Empty(oJson[aNames[nItem]])                                                                                             
			aFunc = StrTokArr2(oJson[aNames[nItem]],"|",.T.) 
		EndIf
	ElseIf UPPER(aNames[nItem]) $ "CODE" 
		If !Empty(oJson[aNames[nItem]])                                                                                             
			aCode = StrTokArr2(oJson[aNames[nItem]],"|",.T.) 
		EndIf
	EndIf
Next nItem

//Verifica Empresa/Filial
If !FWFilExist(ctmpCia, ctmpFil)
	cMsgRest := OemToAnsi(STR0010) +"companyId + branchId "+ OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
	aRet := {.F., 400, cMsgRest, STR0015}
	Return aRet
EndIf

// Formato Considerado como válido: "2001-01-01T18:25:43"
//Verifica Data Inicial
If !Empty(ctmpDtI)
	If  SubStr(ctmpDtI, 5,  1) != "-" .OR. SubStr(ctmpDtI, 8,  1) != "-" .OR. ;
		SubStr(ctmpDtI, 11, 1) != "T" .OR. SubStr(ctmpDtI, 14, 1) != ":" .OR. ; 
		SubStr(ctmpDtI, 17, 1) != ":" 
			cMsgRest+= OemToAnsi(STR0010) +"startDate" + OemToAnsi(STR0014) + CRLF //"Verifique o conteúdo da TAG () pois a data não está no formato correto: 'YYYY-MM-DDTHH:MM:SS'"
	EndIf
EndIf

//Verifica Data Final
If !Empty(ctmpDtF)
	If  SubStr(ctmpDtF, 5,  1) != "-" .OR. SubStr(ctmpDtF, 8,  1) != "-" .OR. ;
		SubStr(ctmpDtF, 11, 1) != "T" .OR. SubStr(ctmpDtF, 14, 1) != ":" .OR. ; 
		SubStr(ctmpDtF, 17, 1) != ":" 
			cMsgRest+= OemToAnsi(STR0010) +"endDate" + OemToAnsi(STR0014) + CRLF //"Verifique o conteúdo da TAG () pois a data não está no formato correto: 'YYYY-MM-DDTHH:MM:SS'"
	EndIf
EndIf

// Formato Considerado como válido: "HH:MM"
//Verifica Hora Inicial
If !Empty(ctmpHrI)
	If  SubStr(ctmpHrI, 3,  1) != ":"
		cMsgRest+= OemToAnsi(STR0010) +"startTime" + OemToAnsi(STR0013) + CRLF //"Verifique o conteúdo da TAG () pois a hora não está no formato correto: 'HH:MM'""
	ElseIf ! ( ( SubStr(ctmpHrI, 1,  1) $ "0123456789") .AND. ( SubStr(ctmpHrI, 2,  1) $ "0123456789") .AND. ( SubStr(ctmpHrI, 4,  1) $ "0123456789") .AND. ( SubStr(ctmpHrI, 5,  1) $ "0123456789") )
		cMsgRest+= OemToAnsi(STR0010) +"startTime" + OemToAnsi(STR0013) + CRLF //"Verifique o conteúdo da TAG () pois a hora não está no formato correto: 'HH:MM'""
	EndIf	
EndIf

//Verifica Hora Final
If !Empty(ctmpHrF)
	If  SubStr(ctmpHrF, 3,  1) != ":"
		cMsgRest+= OemToAnsi(STR0010) +"endTime" + OemToAnsi(STR0013) + CRLF //"Verifique o conteúdo da TAG () pois a hora não está no formato correto: 'HH:MM'""
	ElseIf ! ( ( SubStr(ctmpHrF, 1,  1) $ "0123456789") .AND. ( SubStr(ctmpHrF, 2,  1) $ "0123456789") .AND. ( SubStr(ctmpHrF, 4,  1) $ "0123456789") .AND. ( SubStr(ctmpHrF, 5,  1) $ "0123456789") )
		cMsgRest+= OemToAnsi(STR0010) +"endTime" + OemToAnsi(STR0013) + CRLF //"Verifique o conteúdo da TAG () pois a hora não está no formato correto: 'HH:MM'""
	EndIf	
EndIf

// Verifca o código de abono enviado
If Len(aCode) <> 3
	cMsgRest := OemToAnsi(STR0010) +"code" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
EndIf

// Verifca o código de funcionário enviado
If Len(aFunc) <> 3
	cMsgRest := OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
EndIf

If !Empty(cMsgRest)
	aRet := {.F., 400, cMsgRest, STR0015}
	Return aRet
EndIf
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function ClearDate
Clean especial character from Date Input. Input Format: 2012-04-23T18:25:43
@author  Wesley Alves Pereira
@since   02/05/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fClearDate(cDate)
Local dData := STOD("")
	
	cDate := StrTran(cDate, "T", "")
	cDate := StrTran(cDate, ":", "")
	cDate := StrTran(cDate, "-", "")
	cDate := SubStr(cDate,1,8)
	dData := StoD(cDate)
	
Return ( dData )

//-------------------------------------------------------------------
/*/{Protheus.doc} function fCompress
Compacta os dados do retorno solicitado
@author  Wesley Alves Pereira
@since   12/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := FWJsonSerialize(oObj,.T.,.T.)

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf
	
	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif

Return cComp

/*/{Protheus.doc} fValidaChave
//Tratamento e validação de dados do Json
@author  Wesley Alves Pereira
@since   13/03/2020
@version 12.1.27
@param json,object, variável de objeto que contém os dados de json
@return lRet, logical, variável que verifica se ocorreu erro ou não
/*/
Static Function fValidaChave(cChave)
Local aReto		:= {}	As Array
Local aErro		:= {}	As Array
Local aFunc		:= {}	As Array
Local aTemp		:= {}	As Array
Local ctmpDtI	:= ""	As Character
Local ctmpHrI   := ""	As Character

aTemp := StrTokArr2(cChave,";",.T.)

If ( Len(aTemp) < 6 )
	return (aErro)
EndIf

aFunc := StrTokArr2(aTemp[3],"|",.T.)

If ( Len(aFunc) <> 3)
	return (aErro)
EndIf

aReto := { aTemp[1],; //companyId
		   aTemp[2],; //branchId
		   aTemp[4],; //startDate
		   aTemp[6],; //code
		   aFunc[1],; //employeecompanyId
		   aFunc[2],; //employeebranchId
		   aFunc[3],; //employeeId
		   aTemp[5],; //startTime
	   }

//Verifica Empresa/Filial
If ! FWFilExist(aReto[1],aReto[2])
	return (aErro)
EndIf

// Formato Considerado como válido: "2001-01-01T18:25:43"
//Verifica Data Inicial
ctmpDtI :=  aReto[3]
If !Empty(ctmpDtI)
	If  SubStr(ctmpDtI, 5,  1) != "-" .OR. SubStr(ctmpDtI, 8,  1) != "-" .OR. ;
		SubStr(ctmpDtI, 11, 1) != "T" .OR. SubStr(ctmpDtI, 14, 1) != ":" .OR. ; 
		SubStr(ctmpDtI, 17, 1) != ":" 
			return (aErro)
	EndIf
EndIf

ctmpHrI := aReto[8]
// Formato Considerado como válido: "HH:MM"
//Verifica Hora Inicial
If !Empty(ctmpHrI)
	If  SubStr(ctmpHrI, 3,  1) != ":"
		return (aErro)
	EndIf
EndIf
Return (aReto)

/*/{Protheus.doc} fVldJob
Verifica se deve iniciar um job com o grupo de empresa ou filial informado nos parâmetros para validar e buscar os dados
@type static function
@author Marco Nakazawa
@since 27/04/2026
@param cCompanId, character, grupo de empresas
@param cBranchId, character, filial
@param nNumePage, numeric, número da página para paginação
@param nPageSize, numeric, tamanho da página para paginação
@param cDtUpDate, character, data de atualização
@return aRet, array, Retorna um array com os dados validados e buscados ou mensagens de erro
/*/
Static Function fVldJob(aCabec, aItens, aInfor, aParFun, aParCod, nOpca, aParam)
Local aRet		:= {.T., 200, ""}
Local lExecJob	:= .F.
Local cUID		:= ""
Local nCount	:= 0
Local nTime		:= 1000

If lExecJob := (cEmpAnt <> aParFun[1] .Or. cFilAnt <> aParFun[2])
	//Define o nome da variavel de controle
	cUID := "PON350_EMP_" + AllTrim(Str(ThreadID()))

	//Atribui a variavel de controle				
	PutGlbValue(cUID, "0")

	//Define a criação e o retorno do Job				
	aRet := StartJob("fVldDds350", GetEnvServer(), .T., aCabec, aItens, aInfor, aParFun, aParCod, nOpca, lExecJob, cUID, aParam)
	
	While lExecJob
		//Obtem o valor da variavel global
		If (GetGlbValue(cUID) == "1", nCount := 10, (nCount++, Sleep(nTime)))
		
		lExecJob := (nCount < 10)
	EndDo
	
	//Limpa a variavel global da memoria
	If !Empty(cUID)
		ClearGlbValue(cUID)
	EndIf	
Else
	aRet := fVldDds350(aCabec, aItens, aInfor, aParFun, aParCod, nOpca, lExecJob, cUID, aParam)
EndIf
Return aRet

/*/{Protheus.doc} fVldDds350
Valida os dados para inclusão ou alteração de um registro de pré-abono
@type static function
@author Marco Nakazawa
@since 14/04/2026
@param cCompanId, character, grupo de empresas
@param cBranchId, character, filial
@param nNumePage, numeric, número da página para paginação
@param nPageSize, numeric, tamanho da página para paginação
@param cDtUpDate, character, data de atualização
@return aRet, array, Retorna um array com os dados validados e buscados ou mensagens de erro
/*/
Function fVldDds350(aCabec, aItens, aInfor, aParFun, aParCod, nOpca, lExecJob, cUID, aParam)
Local aRet			:= {.T., 200, ""}
Local cMsgRest		:= ""

Private cMsgErro	:= ""	// Mensagem de erro caso a transação não seja efetuada com sucesso
Private lPn350Api	:= .T.	// Indica se o execauto veio da API
Private lMsHelpAuto := .T.	// Se .T. direciona as mensagens de help para o arq. de log
Private lMsErroAuto := .F.	// Necessário a criação, pois sera atualizado quando houver alguma inconsistência nos parâmetros

Default aCabec		:= {}
Default aItens		:= {}
Default aInfor		:= {}
Default aParFun		:= {}
Default aParCod		:= {}
Default aParam		:= {}
Default nOpca		:= 0
Default lExecJob	:= .F.
Default cUID		:= ""

If lExecJob
	RPCSetType(3)
	RPCSetEnv(aParFun[1], aParFun[2]) // Grupo de Empresa, Filial
	//Atualiza a variavel de controle que indica a finalizacao do JOB
	PutGlbValue(cUID, "1")
EndIf

//Verifica se exite o Tipo do Abono
If Len(aParCod) == 3 .And. nOpca <> 5
	DbSelectArea("SP6")
	DbSetOrder(1)

	If !(SP6->(DbSeek(aParCod[2] + aParCod[3])))
		cMsgRest += OemToAnsi(STR0010) +"code" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
	ElseIf SP6->P6_PREABO == "N"
		cMsgRest += OemToAnsi(STR0010) + "code) " + OemToAnsi(STR0020) + CRLF // "Verifique o conteúdo da TAG () "O tipo de abono informado não pode ser utilizado para laçamentos de pré-abonos."
	EndIf

	If !Empty(cMsgRest)
		aRet := {.F., 400, cMsgRest, STR0015}
		Return aRet
	EndIf
EndIf

//Verifica se existe o Funcionario e se o pré-abono já está cadastrado.
If Len(aParFun) == 3
	DBSelectArea("SRA")
	DBSetOrder(1)

	If !(SRA->(DbSeek(aParFun[2]+aParFun[3])))
		cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
		aRet := {.F., 400, cMsgRest, STR0015}
		Return aRet
	EndIf

	DBSelectArea("RF0")
	DBSetOrder(1)
	//RF0_FILIAL+RF0_MAT+DTOS(RF0_DTPREI)+STR(RF0_HORINI,5,2)
	RF0->(DbGoTop())

	If nOpca == 3
		If RF0->(DbSeek( aParFun[2] + aParFun[3] + dToS(aInfor[1]) + Str(aInfor[2], 5, 2)))
			aRet := {.F., 400, STR0019, STR0015}
			Return aRet
		EndIf
	ElseIf nOpca == 4
		If !RF0->(DbSeek( aParFun[2] + aParFun[3] + dToS(aParam[1]) + Alltrim(Str(aParam[2]))))
			aRet := {.F., 400, STR0021, STR0015}
			Return aRet
		EndIf
	EndIf
EndIf

MSExecAuto({|x,y,z,w,v| PONA350(x,y,z,w,v)}, aCabec, aItens, nOpca, cMsgErro, lPn350Api)

If (!Empty(cMsgErro), aRet := {.F., 400, cMsgErro, STR0009},)

Return aRet
