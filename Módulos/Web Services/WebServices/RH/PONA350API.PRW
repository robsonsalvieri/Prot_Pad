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
Local json as OBJECT
Local cBody As Character
Local cRecebe As Character
Local lRetorno as Logical
Local nItem as integer
Local cRetorno := ""
Local cId As Character 
Local cParEmp As Character
Local cParFil As Character
Local cParFun As Character
Local cParCod As Character
Local cParIDt As Character
Local cParFDt As Character
Local cParIHr As Character
Local cParFHr As Character
Local aParFun as ARRAY
Local aParCod as ARRAY
Local aCabec as ARRAY
Local aItens as ARRAY
Local aLinha as ARRAY
Local aInfor as Array
Local aArea as ARRAY
Local aSRAArea as ARRAY
Local aSP6Area as ARRAY
Local cMsg := ""
Local aLog := {} 
Local nOpca := 3
Local cOperacao := 0
Local cEmpAntBck	:= cEmpAnt	As Character
Local cFilAntBck	:= cFilAnt	As Character

Private cMsgErro	:= ""	// Mensagem de erro caso a transação não seja efetuada com sucesso
Private lPn350Api	:= .T.	// Indica se o execauto veio da API
Private lMsHelpAuto := .T.	// Se .t. direciona as mensagens de help para o arq. de log
Private lMsErroAuto := .F.	// Necessário a criação, pois sera atualizado quando houver alguma inconsistência nos parâmetros

BEGIN SEQUENCE

json		:= JsonObject():New()
cBody		:= Self:GetContent()
lRetorno	:= .F.
lCompact	:= .F. 
cRecebe   := json:FromJSON(EncodeUTF8(NoAcento(cBody)))
	
If cRecebe != Nil  .Or. Len(json:GetNames()) == 0  
	fSendMess(400,STR0005,.T.,400,STR0015,,) // STR0005: "Não foi possível reconhecer o pacote recebido. Verifique a informação e envie novamente."
	return (lRetorno)
EndIf

If (! ( fValidaDados(nOpca,@json)))
	return (lRetorno)
EndIf

aCampos := json:GetNames()

For nItem:= 1 to Len(aCampos)
	
	If UPPER(aCampos[nItem]) $ "COMPANYID"
		cParEmp := json[aCampos[nItem]]		
	EndIf
	
	If UPPER(aCampos[nItem]) =="BRANCHID" 
		cParFil := json[aCampos[nItem]]
	EndIf

	If UPPER(aCampos[nItem]) =="EMPLOYEEID" 
		cParFun := json[aCampos[nItem]]
		aParFun := StrTokArr2(cParFun,"|",.T.) 
	EndIf	
	
	If UPPER(aCampos[nItem]) =="CODE" 
		cParCod := json[aCampos[nItem]]
		aParCod := StrTokArr2(cParCod,"|",.T.) 
	EndIf	

	If UPPER(aCampos[nItem]) =="STARTDATE" 
		cParIDt := json[aCampos[nItem]]
	EndIf

	If UPPER(aCampos[nItem]) =="ENDDATE" 
		cParFDt := json[aCampos[nItem]]
	EndIf

	If UPPER(aCampos[nItem]) =="STARTTIME" 
		cParIHr := json[aCampos[nItem]]
	EndIf

	If UPPER(aCampos[nItem]) =="ENDTIME" 
		cParFHr := json[aCampos[nItem]]
	EndIf

Next nItem

If cEmpAntBck <> cParEmp .Or. cFilAntBck <> cParFil
	fTrGrpEmp(cParEmp, cParFil)
EndIf

aArea := (GetArea())
aSRAArea := SRA->(GetArea())
aSP6Area := SP6->(GetArea())

cOperacao := 3

aCabec := {}
aItens := {}
aLinha := {}
aInfor := {}

aAdd(aInfor,fClearDate(cParIDt))
aAdd(aInfor,Val(StrTran(cParIHr,":",".")))
aAdd(aInfor,fClearDate(cParFDt))
aAdd(aInfor,Val(StrTran(cParFHr,":",".")))

aadd(aCabec,{"RF0_FILIAL" , aParFun[2],})
aadd(aCabec,{"RF0_MAT"    , aParFun[3],})
aadd(aLinha,{"RF0_DTPREI" , aInfor[1] ,})
aadd(aLinha,{"RF0_HORINI" , aInfor[2] ,})
aadd(aLinha,{"RF0_DTPREF" , aInfor[3] ,})
aadd(aLinha,{"RF0_HORFIM" , aInfor[4] ,})
aadd(aLinha,{"RF0_CODABO" , aParCod[3] ,})

DBSelectArea("RF0")
DBSetOrder(1)
//RF0_FILIAL+RF0_MAT+DTOS(RF0_DTPREI)+STR(RF0_HORINI,5,2)
RF0->(DBGOTOP())
If ( RF0->(DBSEEK( cParFil+aParFun[3]+DTOS(aInfor[1])+STR(aInfor[2],5,2))))
	If cEmpAntBck <> cParEmp .Or. cFilAntBck <> cParFil
		fTrGrpEmp(cEmpAntBck, cFilAntBck)
	EndIf
	fSendMess(400,STR0019,.T.,400,STR0015,,) //"Esta solicitação de pré-abono já existe na base do Protheus. Verifique!"
	return (lRetorno)

EndIf

aadd(aItens, aLinha) 

DBSelectArea("SRA")
SRA->(DBGOTOP())
SRA->(DBSEEK( aParFun[2]+aParFun[3]))

MSExecAuto({|x,y,z,w,v| PONA350(x,y,z,w,v)}, aCabec, aItens, cOperacao, cMsgErro, lPn350Api)

If cEmpAntBck <> cParEmp .Or. cFilAntBck <> cParFil
	fTrGrpEmp(cEmpAntBck, cFilAntBck)
EndIf
 
 If lMsErroAuto
 	aLog := GetAutoGRLog()				
	cMsg := OemToAnsi(STR0012) + TAB
	For nItem := 1 to len(aLog)
		cMsg += aLog[nItem] + TAB
	Next nItem

	If (!Empty(cMsgErro), fSendMess(400,cMsg,.T.,400,cMsgErro,,), fSendMess(400,cMsg,.T.,400,STR0015,,)) // STR0005: "Erro no processamento desta operação"
	
	return (lRetorno)
 else

	cId := cParEmp+";"
	cId += cParFil+";"
	cId += aParFun[1]+"|"+aParFun[2]+"|"+aParFun[3]+";"
	cId += cParIDt + ";"
	cId += cParIHr + ";"
	cId += aParCod[1]+"|"+aParCod[2]+"|"+aParCod[3]+";" 

	lRetorno := .T.
	cRetorno :=  fSendJson(json,cId)
	::SetResponse(cRetorno)
	return (lRetorno)
 EndIf
	
RECOVER
	ErrorBlock(bErrorBlock)
	fSendMess(500,oError:Description,.T.,500,STR0009,,) // STR0002: "Ocorreu uma falha no retorno da informação."		
	lRetorno := .F.
END SEQUENCE

Return (lRetorno)

// Altera um abono dentro do módulo de Ponto Eletrônico
/*/{Protheus.doc} PUT
Método responsável pela alteração de um registro de abono com valores passados como paramêtro no Header do REST/JSON
@author  Wesley Alves Pereira
@since   13/03/2020
@version 12.1.27
@return return, return_description
/*/

WSMETHOD PUT allowanceId WSREST allowanceControl
Local aUrlParam	:= ::aUrlParms
Local cJsonObj	:= "JsonObject():New()"
Local oItem		:= &cJsonObj
Local oItemDetail	:= &cJsonObj
Local cToken := Self:GetHeader('Authorization')

Local json as OBJECT
Local cBody As Character
Local cRecebe As Character
Local cId := ""
Local cRetDat := ""
Local cRetHor := ""
Local aLog := {}

//Variaveis do corpo
Local cParEmp := ""
Local cParFil := ""
Local cParFun := ""
Local cParCod := ""
Local cParIDt := ""
Local cParFDt := ""
Local cParIHr := ""
Local cParFHr := ""
Local aParCod := {}
Local aParFun := {}

Local cChave := ""
Local lRetorno := .F.
Local aRetorno := {}
Local cEmpPar := ""
Local cFilPar := ""
Local cDatPar := ""
Local cHorPar := ""
Local cEmpFun := ""
Local cFilFun := ""
Local cCodFun := ""
Local aInfor := {}
Local aParam := {}
Local nOpca := 4
Local cEmpAntBck	:= cEmpAnt	As Character
Local cFilAntBck	:= cFilAnt	As Character

Local nItem

Private cMsgErro	:= ""	// Mensagem de erro caso a transação não seja efetuada com sucesso
Private lPn350Api	:= .T.	// Indica se o execauto veio da API
Private lMsHelpAuto := .T.	// Se .t. direciona as mensagens de help para o arq. de log
Private lMsErroAuto := .F.	// Necessário a criação, pois sera atualizado quando houver alguma inconsistência nos parâmetros

BEGIN SEQUENCE

if Empty(aUrlParam) .OR. Len(aUrlParam) == 0
	fSendMess(400,STR0018,.T.,400,STR0015,,) // STR0018: "Informação allowanceId ausente ou inválida."
	lRetorno := .F.
	return (lRetorno)
else 
	cChave = aUrlParam[1]
EndIf

If Empty(cChave)
	fSendMess(400,STR0018,.T.,400,STR0015,,) // STR0018: "Informação allowanceId ausente ou inválida."
	lRetorno := .F.
	Return (lRetorno)
EndIf

aRetorno := fValidaChave(cChave)

If (Len(aRetorno) == 0)
	fSendMess(400,STR0018,.T.,400,STR0015,,) // STR0018: "Informação allowanceId ausente ou inválida."
	lRetorno := .F.
	Return (lRetorno)
EndIf

json		:= JsonObject():New()
cBody		:= Self:GetContent()
lRetorno	:= .F.
lCompact	:= .F. 
cRecebe   := json:FromJSON(EncodeUTF8(NoAcento(cBody)))
	
If cRecebe != Nil  .Or. Len(json:GetNames()) == 0  
	fSendMess(400,STR0005,.T.,400,STR0015,,) // STR0005: "Não foi possível reconhecer o pacote recebido. Verifique a informação e envie novamente."
	return (lRetorno)
EndIf

If (! ( fValidaDados(nOpca,@json)))
	lRetorno := .F.
	return (lRetorno)
EndIf

aCampos := json:GetNames()

For nItem:= 1 to Len(aCampos)
	
	If UPPER(aCampos[nItem]) $ "COMPANYID"
		cParEmp := json[aCampos[nItem]]		
	EndIf
	
	If UPPER(aCampos[nItem]) =="BRANCHID" 
		cParFil := json[aCampos[nItem]]
	EndIf

	If UPPER(aCampos[nItem]) =="EMPLOYEEID" 
		cParFun := json[aCampos[nItem]]
		aParFun := StrTokArr2(cParFun,"|",.T.) 
	EndIf	
	
	If UPPER(aCampos[nItem]) =="CODE" 
		cParCod := json[aCampos[nItem]]
		aParCod := StrTokArr2(cParCod,"|",.T.) 
	EndIf	

	If UPPER(aCampos[nItem]) =="STARTDATE" 
		cParIDt := json[aCampos[nItem]]
	EndIf

	If UPPER(aCampos[nItem]) =="ENDDATE" 
		cParFDt := json[aCampos[nItem]]
	EndIf

	If UPPER(aCampos[nItem]) =="STARTTIME" 
		cParIHr := json[aCampos[nItem]]
	EndIf

	If UPPER(aCampos[nItem]) =="ENDTIME" 
		cParFHr := json[aCampos[nItem]]
	EndIf

Next nItem

cEmpPar := aRetorno[1]
cFilPar := aRetorno[2]
cDatPar := aRetorno[3]
cHorPar := aRetorno[8]
cEmpFun := aRetorno[5]
cFilFun := aRetorno[6]
cCodFun := aRetorno[7]

If cEmpAntBck <> cEmpPar .Or. cFilAntBck <> cFilPar
	fTrGrpEmp(cEmpPar, cFilPar)
EndIf

aArea := (GetArea())
aSRAArea := SRA->(GetArea())
aSP6Area := SP6->(GetArea())

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

DBSelectArea("RF0")
DBSetOrder(1)
If ! DBSeek(cFilPar+cCodFun+DTOS(aParam[1])+Alltrim(Str(aParam[2])))
	fSendMess(400,STR0015,.T.,400,STR0016) // "Erro na TAG allowanceId. Verifique o conteúdo das chaves informadas."
	If cEmpAntBck <> cEmpPar .Or. cFilAntBck <> cFilPar
		fTrGrpEmp(cEmpAntBck, cFilAntBck)
	EndIf
	return (lRetorno)
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

DBSelectArea("SRA")
SRA->(DBGOTOP())
SRA->(DBSEEK( cFilFun+cCodFun))

MSExecAuto({|x,y,z,w,v| PONA350(x,y,z,w,v)}, aCabec, aItens, 4, cMsgErro, lPn350Api)

If cEmpAntBck <> cEmpPar .Or. cFilAntBck <> cFilPar
	fTrGrpEmp(cEmpAntBck, cFilAntBck)
EndIf

 If lMsErroAuto
 	aLog := GetAutoGRLog()				
	cMsg := OemToAnsi(STR0012) + TAB
	For nItem := 1 to len(aLog)
		If ValType(aMsgErro[nX]) == "C"
			cMsg += StrTran( StrTran( aLog[nItem], "<", "" ), "-", "" ) + (" ") 
		EndIf
	Next nItem

	If (!Empty(cMsgErro), fSendMess(400,cMsg,.T.,400,cMsgErro,,), fSendMess(400,cMsg,.T.,400,STR0015,,)) // STR0005: "Erro no processamento desta operação"
	
	return (lRetorno)
 else
	lRetorno := .T.
	
	If Empty(cParIDt)
		cParIDt := cDatPar
	EndIf
	If Empty(cParIHr)
		cParIHr := cHorPar
	EndIf
	If Empty(aParCod)
		aParCod:= StrToArray(aRetorno[4],"|") 
	EndIf


	cId := cEmpAnt+";"
	cId += RF0->RF0_FILIAL+";"
	cId += cEmpFun+"|"+cFilFun+"|"+cCodFun+";"
	cId += cParIDt + ";"
	cId += cParIHr + ";"
	cId += aParCod[1]+"|"+aParCod[2]+"|"+aParCod[3] 

	cRetorno :=  fSendJson(json,cId)
	::SetResponse(cRetorno)
	return (lRetorno)
 EndIf
	
RECOVER
	ErrorBlock(bErrorBlock)
	fSendMess(500,oError:Description,.T.,500,STR0009,,) // STR0002: "Ocorreu uma falha no retorno da informação."

END SEQUENCE

Return (lRetorno)

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
Local cJsonObj	:= "JsonObject():New()"
Local oItem		:= &cJsonObj
Local oItemDetail	:= &cJsonObj
Local cToken := Self:GetHeader('Authorization')

Local cChave := ""
Local lRetorno := .F.
Local aRetorno := {}
Local cEmpPar := ""
Local cFilPar := ""
Local cDatPar := ""
Local cHorPar := ""
Local cEmpFun := ""
Local cFilFun := ""
Local cCodFun := ""
Local aInfor := {}
Local aLog := {}
Local cEmpAntBck	:= cEmpAnt	As Character
Local cFilAntBck	:= cFilAnt	As Character

Local nItem

Private cMsgErro	:= ""	// Mensagem de erro caso a transação não seja efetuada com sucesso
Private lPn350Api	:= .T.	// Indica se o execauto veio da API
Private lMsHelpAuto := .T.	// Se .t. direciona as mensagens de help para o arq. de log
Private lMsErroAuto := .F.	// Necessário a criação, pois sera atualizado quando houver alguma inconsistência nos parâmetros

BEGIN SEQUENCE

if Empty(aUrlParam) .OR. Len(aUrlParam) == 0
	fSendMess(400,STR0018,.T.,400,STR0015,,) // STR0018: "Informação allowanceId ausente ou inválida."
	lRetorno := .F.
	return (lRetorno)
else 
	cChave = aUrlParam[1]
EndIf

If Empty(cChave)
	fSendMess(400,STR0018,.T.,400,STR0015,,) // STR0018: "Informação allowanceId ausente ou inválida."
	lRetorno := .F.
	Return (lRetorno)
EndIf

aRetorno := fValidaChave(cChave)

If (Len(aRetorno) == 0)
	fSendMess(400,STR0018,.T.,400,STR0015,,) // STR0018: "Informação allowanceId ausente ou inválida."
	lRetorno := .F.
	Return (lRetorno)
EndIf

cEmpPar := aRetorno[1]
cFilPar := aRetorno[2]
cDatPar := aRetorno[3]
cHorPar := aRetorno[8]
cEmpFun := aRetorno[5]
cFilFun := aRetorno[6]
cCodFun := aRetorno[7]

If cEmpAntBck <> cEmpPar .Or. cFilAntBck <> cFilPar
	fTrGrpEmp(cEmpPar, cFilPar)
EndIf

aArea := (GetArea())
aSRAArea := SRA->(GetArea())
aSP6Area := SP6->(GetArea())

aCabec := {}
aItens := {}
aLinha := {}
aInfor := {}

aAdd(aInfor, fClearDate(cDatPar))
aAdd(aInfor, Val(StrTran(cHorPar, ":", ".")))

aadd(aCabec,{"RF0_FILIAL", cFilFun, NIL})
aadd(aCabec,{"RF0_MAT", cCodFun, NIL})
aAdd(aLinha, {"LINPOS", "RF0_DTPREI+RF0_HORINI", aInfor[1], aInfor[2]}) // Informações para posicionar no registro correto
aAdd(aLinha, {"AUTDELETA", "S", NIL}) // Marca o registro como deletado

aadd(aItens, aLinha) 

DBSelectArea("SRA")
SRA->(DBGOTOP())
SRA->(DBSEEK( cFilFun+cCodFun))

MSExecAuto({|x,y,z,w,v| PONA350(x,y,z,w,v)}, aCabec, aItens, 4, cMsgErro, lPn350Api)

If cEmpAntBck <> cEmpPar .Or. cFilAntBck <> cFilPar
	fTrGrpEmp(cEmpAntBck, cFilAntBck)
EndIf

 If lMsErroAuto
 	aLog := GetAutoGRLog()				
	cMsg := OemToAnsi(STR0012) + TAB
	For nItem := 1 to len(aLog)
		cMsg += aLog[nItem] + TAB
	Next nItem

	If (!Empty(cMsgErro), fSendMess(400,cMsg,.T.,400,cMsgErro,,), fSendMess(400,cMsg,.T.,400,STR0015,,)) // STR0005: "Erro no processamento desta operação"
	
	return (lRetorno)
 else
	lRetorno := .T.
	cRetorno :=  fSendDelete(STR0017) //"Operação realizada com sucesso!"
	::SetResponse(cRetorno)
	return (lRetorno)
 EndIf
	
RECOVER
	ErrorBlock(bErrorBlock)
	fSendMess(500,oError:Description,.T.,500,STR0009,,) // STR0002: "Ocorreu uma falha no retorno da informação."

END SEQUENCE

Return (lRetorno)

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
Local cJsonObj := "JsonObject():New()"
Local oMsgReturn	:= &cJsonObj
Local oItem		 	:= &cJsonObj
Local aMessages := {}
Local cJson			:= ""
Local lcompact := .F.

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
@return lRet, logical, variável que verifica se ocorreu erro ou não
/*/
Static Function fValidaDados(nOpc,json)
Local aNames	As Array //array de nomes das propriedades
Local aCpoObt	As Array
Local aAlias	As Character //Proteger a area atual
Local cCpoObgt	As Character //Campos obrigatórios
Local cMsgRest	As Character //Mensagem de erro
lOCAL cTabSX5	As Character //Tabela Dinâmica para busca no SX5
Local nItem		As Integer //Posição do item para varredura
Local ctmpCia   As Character 
Local ctmpfil   As Character
Local ctmpDtI   As Character
Local ctmpDtF   As Character
Local ctmpHrI   As Character
Local ctmpHrF   As Character
Local aCode     as ARRAY
Local aFunc     as ARRAY
Local cEmpAntBck	:= cEmpAnt	As Character
Local cFilAntBck	:= cFilAnt	As Character

	
Local lResult	As Logical //Retorno lógico de erro ou sucesso.
Default json := JsonObject():New()

cCpoObt	:= "code/employeeId/startDate/endDate/startTime/endTime/companyId/branchId/"
lResult	:= .T. 

aNames		:= json:GetNames()
aCpoObt		:= StrToArray(cCpoObt,"/") 
cMsgRest	:= ""
If ( nOpc <> 4 )
	//Verifica TAGS obrigatórias	
	For nItem:= 1 to Len(aCpoObt)
		If aScan(aNames,{|x| UPPER(x) == UPPER(aCpoObt[nItem])})== 0
			cMsgRest+=  OemToAnsi(STR0007)+ aCpoObt[nItem] +OemToAnsi(STR0008) + CRLF //"Verifique se a TAG ("") foi informada, pois ela é obrigatória para manipulação do registro de abono."
		EndIf
	Next nItem
	If !Empty(cMsgRest)
		lResult:= .F.
		fSendMess(400,cMsgRest,.T.,400,STR0015,,) 
		return (lResult)
	EndIf
EndIf

If ( nOpc <> 4 )
	//Verifica TAGS preenchidas
	For nItem:= 1 to Len(aNames)
		if aScan(aCpoObt,{|x| UPPER(x) == UPPER(aNames[nItem])}) > 0
			If (json[aNames[nItem]]== NIL .Or. Empty(json[aNames[nItem]]))
				cMsgRest+=  OemToAnsi(STR0010)+ aNames[nItem] +OemToAnsi(STR0008) + CRLF//"Verifique se a TAG ("") foi informada, pois ela é obrigatória para manipulação do registro de abono."
			Endif
		EndIf 
	Next nItem
	If !Empty(cMsgRest)
		lResult:= .F.
		fSendMess(400,cMsgRest,.T.,400,STR0015,,) 
		return (lResult)
	EndIf
EndIf

aCode := {}
aFunc := {}

For nItem:= 1 to Len(aNames)
	If UPPER(aNames[nItem]) $ "COMPANYID"
		ctmpCia := json[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) =="BRANCHID" 
		ctmpFil := json[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) $ "STARTDATE"
		ctmpDtI := json[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) $ "ENDDATE"
		ctmpDtF := json[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) $ "STARTTIME"
		ctmpHrI := json[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) $ "ENDTIME"
		ctmpHrF := json[aNames[nItem]]
	ElseIf UPPER(aNames[nItem]) $ "EMPLOYEEID" 
		If !Empty(json[aNames[nItem]])                                                                                             
			aFunc = StrTokArr2(json[aNames[nItem]],"|",.T.) 
		EndIf
	ElseIf UPPER(aNames[nItem]) $ "CODE" 
		If !Empty(json[aNames[nItem]])                                                                                             
			aCode = StrTokArr2(json[aNames[nItem]],"|",.T.) 
		EndIf
	EndIf

Next nItem
If ( nOpc <> 4 )
	//Verifica Empresa/Filial
	If ! FWFilExist(ctmpCia,ctmpFil)
		cMsgRest+= OemToAnsi(STR0010) +"companyId + branchId "+ OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
		lResult:= .F.
		fsendMess(400,cMsgRest,.T.,400,STR0015,,) 
		return (lResult)
	EndIf
EndIf

If cEmpAntBck <> ctmpCia .Or. cFilAntBck <> ctmpFil
	fTrGrpEmp(ctmpCia, ctmpFil)
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
If ( nOpc <> 4 )
	//Verifica Funcionario
	If ( Len (aFunc) <> 3)
		cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
	else
		DBSelectArea("SRA")
		DBSetOrder(1)
		If ! DBseek (aFunc[2]+aFunc[3])
			cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
		Endif
	Endif	
Else
	If ( Len (aFunc) == 3)
		DBSelectArea("SRA")
		DBSetOrder(1)
		If ! DBseek (aFunc[2]+aFunc[3])
			cMsgRest+= OemToAnsi(STR0010) +"employeeId" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
		Endif
	Endif	
EndIf

//Verifica Tipo do Abono
If ( nOpc <> 4 )
	If ( Len (aCode) <> 3)
		cMsgRest+= OemToAnsi(STR0010) +"code" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
	else
		DBSelectArea("SP6")
		DBSetOrder(1)
		If !DBseek(aCode[2] + aCode[3])
			cMsgRest+= OemToAnsi(STR0010) +"code" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
		ElseIf SP6->P6_PREABO != "S"
			cMsgRest += OemToAnsi(STR0010) + "code) " + OemToAnsi(STR0020) + CRLF // "Verifique o conteúdo da TAG () "O tipo de abono informado não pode ser utilizado para laçamentos de pré-abonos."
		Endif
	EndIf
Else
	If ( Len (aCode) == 3)
		DBSelectArea("SP6")
		DBSetOrder(1)
		If ! DBseek (aCode[2]+aCode[3])
			cMsgRest+= OemToAnsi(STR0010) +"code" + OemToAnsi(STR0011) + CRLF //"Verifique o conteúdo da TAG () pois não foi possível encontrar esta informação no Protheus."
		ElseIf SP6->P6_PREABO != "S"
			cMsgRest += OemToAnsi(STR0010) + "code) " + OemToAnsi(STR0020) + CRLF // "Verifique o conteúdo da TAG () "O tipo de abono informado não pode ser utilizado para laçamentos de pré-abonos."
		EndIf
	EndIf
EndIf

If cEmpAntBck <> ctmpCia .Or. cFilAntBck <> ctmpFil
	fTrGrpEmp(cEmpAntBck, cFilAntBck)
EndIf

If !Empty(cMsgRest)
	lResult:= .F.
	fsendMess(400,cMsgRest,.T.,400,STR0015,,) 
EndIf 	

Return lResult

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
Local aReto := {}
Local aErro := {}
Local aFunc := {}
Local aTemp := {}

Local ctmpDtI   As Character
Local ctmpHrI   As Character
Local cEmpAntBck	:= cEmpAnt	As Character
Local cFilAntBck	:= cFilAnt	As Character

//alowanceId = companyId;branchId;employeeId;startDate;startTime;code

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

If cEmpAntBck <> aReto[1] .Or. cFilAntBck <> aReto[2]
	fTrGrpEmp(aReto[1], aReto[2])
EndIf

DBSelectArea("SRA")
DBSetOrder(1)
If ! DBseek (aFunc[2]+aFunc[3])
	If cEmpAntBck <> aReto[1] .Or. cFilAntBck <> aReto[2]
		fTrGrpEmp(cEmpAntBck, cFilAntBck)
	EndIf
	return (aErro)
Endif

If cEmpAntBck <> aReto[1] .Or. cFilAntBck <> aReto[2]
	fTrGrpEmp(cEmpAntBck, cFilAntBck)
EndIf
Return (aReto)
